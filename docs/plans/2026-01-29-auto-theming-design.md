# Auto-Theming Design

## Overview

Automatically generate a luxline theme by extracting colors from the active Neovim colorscheme's highlight groups. No pre-defined theme mappings - pure auto-detection with caching.

## Theme Structure

New format with per-position foregrounds:

```lua
{
    gradient = {
        { bg = '#0f0f23', fg = '#e0e7ff' },  -- position 1
        { bg = '#1a1a2e', fg = '#e0e7ff' },  -- position 2
        { bg = '#2A305E', fg = '#e0e7ff' },  -- position 3
        { bg = '#4a3674', fg = '#e0e7ff' },  -- position 4
        { bg = '#7c3aed', fg = '#ffffff' },  -- position 5
        { bg = '#8b5cf6', fg = '#ffffff' },  -- position 6
        { bg = '#a855f7', fg = '#1a1a1a' },  -- position 7
    },
    middle = '#1a1a2e',
    semantic = {
        LuxlineFilename = { fg = '...', bg = '...' },
        LuxlineGit = { fg = '...', bg = '...' },
        -- etc.
    }
}
```

**Removed fields**: `foreground`, `fallback` - no longer needed since each gradient position has its own fg.

## Gradient Extraction

### Highlight Group → Gradient Position Mapping

| Position | Primary Source | Fallback Chain |
|----------|----------------|----------------|
| 1 | `Normal.bg` | `StatusLine.bg` → `#1a1a1a` |
| 2 | `CursorLine.bg` | `StatusLineNC.bg` → position 1 |
| 3 | `Visual.bg` | `Pmenu.bg` → position 2 |
| 4 | `StatusLine.bg` | `Normal.bg` → position 3 |
| 5 | `Search.bg` | `WildMenu.bg` → position 4 |
| 6 | `IncSearch.bg` | `Substitute.bg` → position 5 |
| 7 | `Cursor.bg` | `Title.fg` → `MatchParen.bg` |

### Extraction Function

```lua
local function get_hl_colors(group)
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    return {
        bg = hl.bg and string.format('#%06x', hl.bg) or nil,
        fg = hl.fg and string.format('#%06x', hl.fg) or nil,
    }
end
```

### Fallback Logic

For each position, try primary source. If `bg` is nil, try each fallback in order. If all fail, use the previous position's color (positions 2-7) or a hardcoded dark/light default (position 1).

**Foreground**: Extract `fg` from the same highlight group that provided the `bg`. If nil, use `Normal.fg`.

## Semantic Highlight Mapping

| Semantic Highlight | Primary Source | Fallback |
|--------------------|----------------|----------|
| `LuxlineFilename` | `Title` | gradient position 5 |
| `LuxlineWinbarFilename` | `Title` | gradient position 4 |
| `LuxlineModified` | `DiagnosticWarn` | `WarningMsg` |
| `LuxlineWinbarModified` | `DiagnosticWarn` | `WarningMsg` |
| `LuxlineGit` | `GitSignsAdd` | `DiffAdd` → `String` |
| `LuxlineWinbarGit` | `GitSignsAdd` | `DiffAdd` → `String` |
| `LuxlinePosition` | `StatusLine` | gradient position 5 |
| `LuxlineWinbarPosition` | `WinBar` | gradient position 4 |
| `LuxlinePercent` | `Search` | gradient position 6 |
| `LuxlineWinbarPercent` | `IncSearch` | gradient position 5 |
| `LuxlineWindownumber` | `Title` | gradient position 3 |
| `LuxlineWinbarWindownumber` | `WinBar` | gradient position 2 |
| `LuxlineSpacer` | `StatusLine` | gradient position 2 |
| `LuxlineWinbarSpacer` | `WinBar` | gradient position 2 |

Bold is added to `Modified` and `Windownumber` items.

## Caching

- Cache stored in memory keyed by `vim.g.colors_name`
- Invalidated on `ColorScheme` autocmd when the name changes
- Structure: `local theme_cache = {}  -- { [colorscheme_name] = generated_theme }`

## Integration

### New Module: `lua/luxline/themes/auto.lua`

```lua
local M = {}

M.generate(colorscheme_name)  -- Returns theme or nil
M.invalidate(colorscheme_name)  -- Clears cache entry
M.invalidate_all()  -- Clears entire cache

return M
```

### Modified Flow in `themes/init.lua`

```lua
function M.set_theme(theme_name)
    theme_name = theme_name or vim.g.colors_name or 'default'

    local theme = M.get_theme(theme_name)

    if not theme then
        -- Try auto-generation
        local auto = require('luxline.themes.auto')
        theme = auto.generate(vim.g.colors_name)
    end

    if not theme then
        -- Final fallback to default
        theme = M.get_theme('default')
    end

    -- ... rest unchanged
end
```

### ColorScheme Autocmd

```lua
events.on('colorscheme_changed', function()
    local auto = require('luxline.themes.auto')
    auto.invalidate(vim.g.colors_name)
    M.set_theme(vim.g.colors_name)
end)
```

## File Changes

### New File
- `lua/luxline/themes/auto.lua` - Color extraction and theme generation

### Modified Files
- `lua/luxline/themes/init.lua` - Integrate auto-generation fallback
- `lua/luxline/themes/data/lux-themes.lua` - Migrate to new format
- `lua/luxline/themes/default.lua` - Migrate to new format
- `lua/luxline/themes/validation.lua` - Validate new structure only
- `lua/luxline/rendering/highlight.lua` - Use per-position fg/bg
- `lua/luxline/rendering/bar_builder.lua` - Update gradient access

## Migration

Full migration to new format. No backwards compatibility with old format.

All existing themes in `lux-themes.lua` will be converted to:

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
    semantic = { ... }
}
```
