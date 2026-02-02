# Auto-Theming Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Automatically generate luxline themes by extracting colors from any Neovim colorscheme's highlight groups.

**Architecture:** New `themes/auto.lua` module extracts colors from highlight groups, builds gradient with per-position fg/bg, generates semantic highlights, and caches by colorscheme name. Full migration to new theme format - no backwards compatibility.

**Tech Stack:** Lua, Neovim API (`nvim_get_hl`)

---

### Task 1: Create auto.lua - Color Extraction

**Files:**
- Create: `lua/luxline/themes/auto.lua`

**Step 1: Create the module with extraction helper**

```lua
local M = {}

local theme_cache = {}

local function get_hl_colors(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if not ok or not hl then
        return { bg = nil, fg = nil }
    end
    return {
        bg = hl.bg and string.format('#%06x', hl.bg) or nil,
        fg = hl.fg and string.format('#%06x', hl.fg) or nil,
    }
end

local function get_color_with_fallbacks(primary, fallbacks, attr, default)
    local colors = get_hl_colors(primary)
    if colors[attr] then
        return colors
    end

    for _, fallback in ipairs(fallbacks or {}) do
        colors = get_hl_colors(fallback)
        if colors[attr] then
            return colors
        end
    end

    return { bg = default, fg = default }
end

return M
```

**Step 2: Verify module loads**

Run in Neovim: `:lua print(vim.inspect(require('luxline.themes.auto')))`
Expected: Table with empty functions

**Step 3: Commit**

```bash
git add lua/luxline/themes/auto.lua
git commit -m "feat(themes): add auto.lua with color extraction helpers"
```

---

### Task 2: Implement Gradient Generation

**Files:**
- Modify: `lua/luxline/themes/auto.lua`

**Step 1: Add gradient position mapping**

```lua
local GRADIENT_MAPPING = {
    { primary = 'Normal', fallbacks = { 'StatusLine' }, attr = 'bg', default = '#1a1a1a' },
    { primary = 'CursorLine', fallbacks = { 'StatusLineNC' }, attr = 'bg', default = nil },
    { primary = 'Visual', fallbacks = { 'Pmenu' }, attr = 'bg', default = nil },
    { primary = 'StatusLine', fallbacks = { 'Normal' }, attr = 'bg', default = nil },
    { primary = 'Search', fallbacks = { 'WildMenu' }, attr = 'bg', default = nil },
    { primary = 'IncSearch', fallbacks = { 'Substitute' }, attr = 'bg', default = nil },
    { primary = 'Cursor', fallbacks = { 'Title', 'MatchParen' }, attr = 'bg', default = nil },
}

local function build_gradient()
    local gradient = {}
    local normal_fg = get_hl_colors('Normal').fg or '#d0d0d0'

    for i, mapping in ipairs(GRADIENT_MAPPING) do
        local colors = get_color_with_fallbacks(mapping.primary, mapping.fallbacks, mapping.attr, mapping.default)
        local bg = colors.bg
        local fg = colors.fg or normal_fg

        if not bg and i > 1 then
            bg = gradient[i - 1].bg
        end

        if not bg then
            bg = mapping.default or '#1a1a1a'
        end

        gradient[i] = { bg = bg, fg = fg }
    end

    return gradient
end
```

**Step 2: Verify gradient builds**

Run in Neovim:
```lua
:lua local auto = require('luxline.themes.auto'); print(vim.inspect(auto._build_gradient()))
```
Expected: Table with 7 entries, each having bg and fg

**Step 3: Commit**

```bash
git add lua/luxline/themes/auto.lua
git commit -m "feat(themes): add gradient generation from highlight groups"
```

---

### Task 3: Implement Semantic Highlight Generation

**Files:**
- Modify: `lua/luxline/themes/auto.lua`

**Step 1: Add semantic mapping and generator**

```lua
local SEMANTIC_MAPPING = {
    LuxlineFilename = { primary = 'Title', fallback_pos = 5 },
    LuxlineWinbarFilename = { primary = 'Title', fallback_pos = 4 },
    LuxlineModified = { primary = 'DiagnosticWarn', fallbacks = { 'WarningMsg' }, bold = true },
    LuxlineWinbarModified = { primary = 'DiagnosticWarn', fallbacks = { 'WarningMsg' }, bold = true },
    LuxlineGit = { primary = 'GitSignsAdd', fallbacks = { 'DiffAdd', 'String' } },
    LuxlineWinbarGit = { primary = 'GitSignsAdd', fallbacks = { 'DiffAdd', 'String' } },
    LuxlinePosition = { primary = 'StatusLine', fallback_pos = 5 },
    LuxlineWinbarPosition = { primary = 'WinBar', fallback_pos = 4 },
    LuxlinePercent = { primary = 'Search', fallback_pos = 6 },
    LuxlineWinbarPercent = { primary = 'IncSearch', fallback_pos = 5 },
    LuxlineWindownumber = { primary = 'Title', fallback_pos = 3, bold = true },
    LuxlineWinbarWindownumber = { primary = 'WinBar', fallback_pos = 2, bold = true },
    LuxlineSpacer = { primary = 'StatusLine', fallback_pos = 2 },
    LuxlineWinbarSpacer = { primary = 'WinBar', fallback_pos = 2 },
}

local function build_semantic(gradient)
    local semantic = {}

    for group_name, mapping in pairs(SEMANTIC_MAPPING) do
        local colors = get_color_with_fallbacks(mapping.primary, mapping.fallbacks, 'bg', nil)
        local bg = colors.bg
        local fg = colors.fg

        if not bg and mapping.fallback_pos and gradient[mapping.fallback_pos] then
            bg = gradient[mapping.fallback_pos].bg
            fg = fg or gradient[mapping.fallback_pos].fg
        end

        if bg then
            semantic[group_name] = {
                bg = bg,
                fg = fg or gradient[1].fg or '#d0d0d0',
                bold = mapping.bold,
            }
        end
    end

    return semantic
end
```

**Step 2: Verify semantic builds**

Run in Neovim:
```lua
:lua local auto = require('luxline.themes.auto'); local g = auto._build_gradient(); print(vim.inspect(auto._build_semantic(g)))
```
Expected: Table with semantic highlight definitions

**Step 3: Commit**

```bash
git add lua/luxline/themes/auto.lua
git commit -m "feat(themes): add semantic highlight generation"
```

---

### Task 4: Implement Public API and Caching

**Files:**
- Modify: `lua/luxline/themes/auto.lua`

**Step 1: Add public API functions**

```lua
function M.generate(colorscheme_name)
    colorscheme_name = colorscheme_name or vim.g.colors_name or 'default'

    if theme_cache[colorscheme_name] then
        return theme_cache[colorscheme_name]
    end

    local gradient = build_gradient()
    local semantic = build_semantic(gradient)

    local theme = {
        gradient = gradient,
        middle = gradient[2].bg,
        semantic = semantic,
    }

    theme_cache[colorscheme_name] = theme
    return theme
end

function M.invalidate(colorscheme_name)
    if colorscheme_name then
        theme_cache[colorscheme_name] = nil
    end
end

function M.invalidate_all()
    theme_cache = {}
end

M._build_gradient = build_gradient
M._build_semantic = build_semantic
```

**Step 2: Verify full generation**

Run in Neovim:
```lua
:lua local auto = require('luxline.themes.auto'); print(vim.inspect(auto.generate()))
```
Expected: Complete theme table with gradient, middle, and semantic

**Step 3: Commit**

```bash
git add lua/luxline/themes/auto.lua
git commit -m "feat(themes): add public API with caching"
```

---

### Task 5: Migrate lux-themes.lua to New Format

**Files:**
- Modify: `lua/luxline/themes/data/lux-themes.lua`

**Step 1: Convert nami theme**

```lua
['nami'] = {
    gradient = {
        { bg = '#0d1821', fg = '#e8dcc8' },
        { bg = '#1a2734', fg = '#e8dcc8' },
        { bg = '#2a3a4a', fg = '#e8dcc8' },
        { bg = '#3a9ba8', fg = '#e8dcc8' },
        { bg = '#4fc9c9', fg = '#0d1821' },
        { bg = '#ff8c6b', fg = '#0d1821' },
        { bg = '#ffd48c', fg = '#0d1821' },
    },
    middle = '#1a2734',
    semantic = {
        LuxlineFilename = { fg = '#e8dcc8', bg = '#4fc9c9' },
        LuxlineWinbarFilename = { fg = '#e8dcc8', bg = '#3a9ba8' },
        LuxlineModified = { fg = '#ffd48c', bg = '#ff6b4a', bold = true },
        LuxlineWinbarModified = { fg = '#ffd48c', bg = '#ff6b4a', bold = true },
        LuxlineGit = { fg = '#4fc9c9', bg = '#2a3a4a' },
        LuxlineWinbarGit = { fg = '#4fc9c9', bg = '#1a2734' },
        LuxlinePosition = { fg = '#e8dcc8', bg = '#ff8c6b' },
        LuxlineWinbarPosition = { fg = '#e8dcc8', bg = '#3a9ba8' },
        LuxlinePercent = { fg = '#0d1821', bg = '#ffd48c' },
        LuxlineWinbarPercent = { fg = '#0d1821', bg = '#ffa857' },
        LuxlineWindownumber = { fg = '#ffd48c', bg = '#2a3a4a', bold = true },
        LuxlineWinbarWindownumber = { fg = '#ffd48c', bg = '#1a2734', bold = true },
        LuxlineSpacer = { fg = '#1a2734', bg = '#1a2734' },
        LuxlineWinbarSpacer = { fg = '#1a2734', bg = '#1a2734' },
    },
},
```

**Step 2: Convert lux-vesper theme**

```lua
['lux-vesper'] = {
    gradient = {
        { bg = '#0f0f23', fg = '#e0e7ff' },
        { bg = '#1a1a2e', fg = '#e0e7ff' },
        { bg = '#2A305E', fg = '#e0e7ff' },
        { bg = '#4a3674', fg = '#e0e7ff' },
        { bg = '#7c3aed', fg = '#ffffff' },
        { bg = '#8b5cf6', fg = '#ffffff' },
        { bg = '#a855f7', fg = '#1a1a1a' },
    },
    middle = '#1a1a2e',
    semantic = {
        LuxlineFilename = { fg = '#e0e7ff', bg = '#7c3aed' },
        LuxlineWinbarFilename = { fg = '#e0e7ff', bg = '#6d28d9' },
        LuxlineModified = { fg = '#fbbf24', bg = '#dc2626', bold = true },
        LuxlineWinbarModified = { fg = '#fbbf24', bg = '#b91c1c', bold = true },
        LuxlineGit = { fg = '#22c55e', bg = '#4a3674' },
        LuxlineWinbarGit = { fg = '#22c55e', bg = '#3c2e60' },
        LuxlinePosition = { fg = '#e0e7ff', bg = '#8b5cf6' },
        LuxlineWinbarPosition = { fg = '#e0e7ff', bg = '#7c3aed' },
        LuxlinePercent = { fg = '#e0e7ff', bg = '#a855f7' },
        LuxlineWinbarPercent = { fg = '#e0e7ff', bg = '#9333ea' },
        LuxlineWindownumber = { fg = '#fbbf24', bg = '#4a3674', bold = true },
        LuxlineWinbarWindownumber = { fg = '#fbbf24', bg = '#3c2e60', bold = true },
        LuxlineSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
        LuxlineWinbarSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
    },
},
```

**Step 3: Convert remaining themes (lux-aurora, lux-chroma, lux-eos, lux-umbra)**

Each needs gradient converted from array of strings to array of {bg, fg} objects. For themes without semantic, generate basic semantic from gradient positions.

**Step 4: Commit**

```bash
git add lua/luxline/themes/data/lux-themes.lua
git commit -m "feat(themes): migrate lux-themes.lua to new format"
```

---

### Task 6: Update validation.lua for New Format

**Files:**
- Modify: `lua/luxline/themes/validation.lua`

**Step 1: Update DEFAULT_THEME and get_default_theme**

```lua
M.DEFAULT_THEME = {
    gradient = {},
    middle = '#1a1a2e',
}

function M.get_default_theme()
    local default = vim.deepcopy(M.DEFAULT_THEME)
    local normal_fg = '#d0d0d0'

    for i = 1, 7 do
        local gray_value = math.floor(0x40 + (i - 1) * 0x10)
        local bg = string.format('#%02x%02x%02x', gray_value, gray_value, gray_value)
        default.gradient[i] = { bg = bg, fg = normal_fg }
    end

    default.middle = default.gradient[2].bg
    return default
end
```

**Step 2: Update validate_theme function**

```lua
function M.validate_theme(theme, name)
    if type(theme) ~= 'table' then
        vim.notify('Theme must be a table: ' .. (name or 'unknown'), vim.log.levels.WARN)
        return M.get_default_theme()
    end

    local validated = utils.deep_merge(M.get_default_theme(), theme)

    if not validated.gradient or #validated.gradient ~= 7 then
        if name then
            vim.notify('Theme gradient must have exactly 7 colors: ' .. name, vim.log.levels.WARN)
        end
        validated = M.get_default_theme()
    end

    for i, entry in ipairs(validated.gradient) do
        if type(entry) ~= 'table' or not entry.bg then
            vim.notify('Invalid gradient entry at position ' .. i, vim.log.levels.WARN)
            validated.gradient[i] = { bg = '#808080', fg = '#d0d0d0' }
        end
    end

    return validated
end
```

**Step 3: Update validate_gradient function**

```lua
function M.validate_gradient(gradient)
    if type(gradient) ~= 'table' then
        return false, 'Gradient must be a table'
    end

    if #gradient ~= 7 then
        return false, 'Gradient must have exactly 7 entries'
    end

    for i, entry in ipairs(gradient) do
        if type(entry) ~= 'table' then
            return false, 'Gradient entry ' .. i .. ' must be a table'
        end
        if not M.validate_color(entry.bg) then
            return false, 'Invalid bg color at position ' .. i
        end
        if entry.fg and not M.validate_color(entry.fg) then
            return false, 'Invalid fg color at position ' .. i
        end
    end

    return true
end
```

**Step 4: Remove legacy itemLeft/Right generation from validate_theme**

Delete lines 53-57 that generate legacy `itemLeft1`, `itemRight1`, etc.

**Step 5: Commit**

```bash
git add lua/luxline/themes/validation.lua
git commit -m "feat(themes): update validation for new gradient format"
```

---

### Task 7: Update highlight_strategies.lua for Per-Position Foreground

**Files:**
- Modify: `lua/luxline/rendering/highlight_strategies.lua`

**Step 1: Update positional strategy create_highlight**

```lua
create_highlight = function(group_name, side, idx, bar_type)
    local themes = require('luxline.themes')
    local theme = themes.get_current_theme()

    if not theme or not theme.gradient then
        return nil
    end

    local gradient_idx = math.min(idx, #theme.gradient)
    local entry = theme.gradient[gradient_idx]

    if not entry then
        return nil
    end

    local bg = entry.bg or '#808080'
    local fg = entry.fg or '#d0d0d0'

    if bar_type == 'winbar' then
        bg = M.adjust_color(bg, -10)
    end

    return {
        fg = fg,
        bg = bg,
    }
end
```

**Step 2: Update semantic strategy create_highlight**

```lua
create_highlight = function(group_name, bar_type)
    local themes = require('luxline.themes')
    local theme = themes.get_current_theme()

    if not theme or not theme.semantic or not theme.semantic[group_name] then
        return nil
    end

    local semantic_def = theme.semantic[group_name]
    local fg = semantic_def.fg or (theme.gradient[1] and theme.gradient[1].fg) or '#d0d0d0'
    local bg = semantic_def.bg or (theme.gradient[4] and theme.gradient[4].bg) or '#808080'

    if bar_type == 'winbar' then
        bg = M.adjust_color(bg, -10)
    end

    return {
        fg = fg,
        bg = bg,
        bold = semantic_def.bold,
        italic = semantic_def.italic,
        underline = semantic_def.underline,
    }
end
```

**Step 3: Commit**

```bash
git add lua/luxline/rendering/highlight_strategies.lua
git commit -m "feat(rendering): update strategies for per-position fg/bg"
```

---

### Task 8: Integrate Auto-Generation into themes/init.lua

**Files:**
- Modify: `lua/luxline/themes/init.lua`

**Step 1: Update set_theme to try auto-generation**

```lua
function M.set_theme(theme_name)
    theme_name = theme_name or vim.g.colors_name or 'default'

    local theme = M.get_theme(theme_name)

    if not theme then
        local auto = require('luxline.themes.auto')
        theme = auto.generate(vim.g.colors_name)

        if theme then
            theme = M.validate_theme(theme, 'auto:' .. (vim.g.colors_name or 'unknown'))
        end
    end

    if not theme then
        if theme_name ~= 'default' then
            vim.notify('Theme not found: ' .. theme_name .. ', falling back to default', vim.log.levels.WARN)
            theme = M.get_theme('default')
        end

        if not theme then
            vim.notify('Default theme not available!', vim.log.levels.ERROR)
            return false
        end
    end

    current_theme = theme
    state.set('theme', theme_name)

    local highlight = require('luxline.rendering.highlight')
    highlight.clear_highlights()

    events.emit('theme_changed', {
        name = theme_name,
        theme = theme
    })

    return true
end
```

**Step 2: Update colorscheme_changed handler in setup**

```lua
events.on('colorscheme_changed', function()
    local auto = require('luxline.themes.auto')
    auto.invalidate(vim.g.colors_name)
    M.set_theme(vim.g.colors_name)
end)
```

**Step 3: Commit**

```bash
git add lua/luxline/themes/init.lua
git commit -m "feat(themes): integrate auto-generation fallback"
```

---

### Task 9: Update default.lua

**Files:**
- Modify: `lua/luxline/themes/default.lua`

**Step 1: Update to use auto-generation or lux-vesper**

```lua
local themes = require('luxline.themes')

themes.register('default', function()
    local lux_vesper = themes.get_theme('lux-vesper')
    if lux_vesper then
        return lux_vesper
    end

    local auto = require('luxline.themes.auto')
    return auto.generate()
end)
```

**Step 2: Commit**

```bash
git add lua/luxline/themes/default.lua
git commit -m "feat(themes): update default to use auto-generation fallback"
```

---

### Task 10: Manual Testing

**Step 1: Reload luxline**

```lua
:lua require('luxline').reload()
```

**Step 2: Test with current colorscheme**

```lua
:lua print(vim.inspect(require('luxline.themes').get_current_theme()))
```
Expected: Theme with gradient array of {bg, fg} objects

**Step 3: Test colorscheme switch**

```vim
:colorscheme default
:lua print(vim.inspect(require('luxline.themes').get_current_theme()))
```
Expected: Auto-generated theme for 'default' colorscheme

**Step 4: Test cache invalidation**

```lua
:lua require('luxline.themes.auto').invalidate_all()
:colorscheme <your-theme>
```
Expected: Theme regenerates

**Step 5: Verify statusline renders correctly**

Visual inspection - statusline and winbar should render with proper colors

**Step 6: Final commit**

```bash
git add -A
git commit -m "feat(themes): complete auto-theming implementation"
```
