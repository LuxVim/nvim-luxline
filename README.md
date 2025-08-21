<h1 align="left">
  <img src="https://github.com/user-attachments/assets/546ee0e5-30fd-4e37-b219-e390be8b1c6e"
       alt="LuxVim Logo"
       style="width: 40px; height: 40px; position: relative; top: 6px; margin-right: 10px;" />
  nvim-luxline
</h1>

A highly customizable statusline and winbar plugin for Neovim, featuring intelligent item loading, gradient-based theming, git integration, and context-aware configurations designed for modern development workflows.

---

## ✨ Features

- **Dual-Bar Architecture**
  - Independent statusline and winbar configurations
  - Context-aware item selection based on filetype and buffer type
  - Flexible item positioning with separator customization
  - Winbar can be disabled per filetype for optimal workflow

- **Intelligent Item System**
  - Auto-discovery of statusline items with variant support
  - Comprehensive built-in items (file, git, position, encoding)
  - Extensible item registration with caching and async support
  - Rich context passed to items (buffer, window, filetype data)

- **Advanced Theming**
  - Gradient-based theme system with 7-color transitions
  - Built-in lux colorscheme integration and auto-detection
  - Custom theme creation with color interpolation helpers
  - Semantic highlighting with positional fallback

- **Performance Optimized**
  - Intelligent caching with configurable TTL per item
  - Throttled updates to prevent excessive rendering
  - Debounced git operations with smart repository caching
  - Hot-reload capability for development workflows

- **Git Integration**
  - Async git operations with debounced updates for performance
  - Smart repository caching with configurable timeouts
  - Branch and diff statistics with visual indicators
  - Multi-repository support with per-repo state management

- **Compatibility**
  - Neovim 0.5.0+ required (uses modern Lua APIs)
  - Cross-platform support (Linux, macOS, Windows)
  - No external dependencies required

---

## 📦 Installation

### **using lazy.nvim**
```lua
{
  "LuxVim/nvim-luxline",
  config = function()
    require("luxline").setup({
      -- Optional configuration
      left_active_items = { 'windownumber', 'filename', 'modified' },
      right_active_items = { 'position', 'filetype', 'encoding' },
      winbar_enabled = true,
      default_theme = 'lux-vesper',
    })
  end
}
```

### **using packer.nvim**
```lua
use {
  "LuxVim/nvim-luxline",
  config = function()
    require("luxline").setup()
  end
}
```

### **using vim-plug**
```vim
Plug 'LuxVim/nvim-luxline'
```

Then in your `init.lua`:
```lua
require("luxline").setup({
  -- Your configuration here
})
```

## 🛠️ Configuration

```lua
require("luxline").setup({
  -- Statusline item configuration
  left_active_items = { 'windownumber', 'filename', 'modified' },      -- Active window left items
  left_inactive_items = { 'windownumber', 'filename', 'modified' },    -- Inactive window left items
  right_active_items = { 'position', 'filetype', 'encoding' },         -- Active window right items
  right_inactive_items = { 'position', 'filetype', 'encoding' },       -- Inactive window right items
  
  -- Winbar configuration (top bar in each window)
  winbar_enabled = true,                                               -- Enable winbar
  left_active_items_winbar = { 'windownumber' },                      -- Winbar left items
  right_active_items_winbar = { 'filename:tail' },                    -- Winbar right items
  winbar_disabled_filetypes = { 'help', 'startify', 'dashboard' },    -- Disable winbar for these filetypes
  
  -- Visual appearance
  left_separator = '█',                                                -- Left side separator
  right_separator = '█',                                               -- Right side separator
  left_separator_winbar = '█',                                         -- Winbar left separator
  right_separator_winbar = '█',                                        -- Winbar right separator
  
  -- Performance and behavior
  update_throttle = 20,                                                -- Update throttle in milliseconds
  default_theme = 'default',                                           -- Default theme name
  
  -- Git integration
  git_enabled = true,                                                  -- Enable git integration
  git_cache_timeout = 5000,                                            -- Git cache timeout in milliseconds
  git_diff_debounce = 200,                                             -- Git diff debounce in milliseconds
  
  -- Buffer exclusions
  buffer_exclude = {},                                                 -- Buffers to exclude from statusline
})
```

### Filetype-Specific Configuration

nvim-luxline supports context-aware configurations that change based on filetype and buffer type:

```lua
require("luxline").setup({
  -- Default configuration
  left_active_items = { 'filename', 'modified' },
  
  -- Filetype-specific overrides (higher priority)
  left_active_items_help = { 'filename' },                            -- For help files
  left_active_items_lua = { 'filename', 'modified', 'git' },          -- For Lua files
  
  -- Buffer type overrides (highest priority)
  left_active_items_buftype_terminal = { 'filename:tail' },           -- For terminal buffers
  left_active_items_buftype_quickfix = { 'filename:relative' },       -- For quickfix buffers
  
  -- Winbar filetype-specific configuration
  right_active_items_winbar_help = { 'filename:full' },               -- Full path for help files
})
```

---

## 📊 Available Items

| Item | Description | Variants | Example |
|------|-------------|----------|---------|
| `filename` | Current file name | `full`, `relative`, `tail` | `filename:relative` |
| `filetype` | File type | `icon` (requires nvim-web-devicons) | `filetype:icon` |
| `cwd` | Current working directory | `full`, `short` | `cwd:short` |
| `modified` | File modification indicator | `icon`, `short` | `modified:icon` |
| `readonly` | Read-only file indicator | `icon`, `short` | `readonly:icon` |
| `encoding` | File encoding | `short` | `encoding:short` |
| `position` | Line and column position | `line`, `column` | `position:line` |
| `windownumber` | Window number | - | `windownumber` |
| `git` | Git branch and status | - | `git` |
| `spacer` | Flexible space for alignment | - | `spacer` |

### Item Variants

Items support variants specified with colon notation for additional customization:

```lua
require("luxline").setup({
  left_active_items = { 
    'filename:relative',     -- Show relative file path
    'filetype:icon',         -- Show filetype with icon
    'modified:icon',         -- Show as icon (●)
    'cwd:short'             -- Show shortened working directory
  },
  right_active_items_winbar = { 'filename:tail' }  -- Show only filename in winbar
})
```

---

## 🎨 Theming

### Built-in Themes

nvim-luxline includes several professionally designed themes:

| Theme | Type | Description |
|-------|------|-------------|
| `default` | Universal | Basic grayscale theme for any colorscheme |
| `lux-vesper` | Dark | Elegant dark theme (default in LuxVim) |
| `lux-aurora` | Light | Northern lights inspired theme |
| `lux-chroma` | Light | Vibrant spectrum theme |
| `lux-eos` | Light | Dawn/coral inspired theme |
| `lux-umbra` | Dark | Deep purple theme |

### Setting Themes

```lua
-- Set theme manually
require("luxline.themes").set_theme("lux-vesper")

-- Or configure default theme
require("luxline").setup({
  default_theme = "lux-aurora"
})

-- Preview a theme for 3 seconds
require("luxline.themes").preview_theme("lux-chroma")
```

### Creating Custom Themes

#### Gradient-based Theme (Recommended)

```lua
local themes = require("luxline.themes")

themes.register("my-theme", {
  foreground = "#ffffff",
  gradient = {
    "#1a1a1a", "#2a2a2a", "#3a3a3a", "#4a4a4a",
    "#5a5a5a", "#6a6a6a", "#7a7a7a"
  }
})
```

#### Automatic Gradient Generation

```lua
-- Create theme with automatic color interpolation
themes.create_gradient_theme(
  "sunset",           -- theme name
  "#ff6b35",         -- start color
  "#f7931e",         -- end color  
  "#ffffff"          -- foreground text color
)
```

---

## 🔧 Lua API

```lua
local luxline = require("luxline")

-- Core plugin management
luxline.setup(config)                    -- Initialize plugin with configuration
luxline.reload()                         -- Hot-reload plugin (useful for development)
luxline.reset()                          -- Reset to default configuration
local stats = luxline.get_stats()        -- Get plugin statistics

-- Manual updates
luxline.update()                         -- Force update all statuslines
luxline.throttled_update()               -- Throttled update (respects update_throttle)
```

### Theme API

```lua
local themes = require("luxline.themes")

-- Theme management
themes.set_theme("theme-name")           -- Set active theme
themes.preview_theme("theme-name")       -- Preview theme for 3 seconds
local names = themes.get_theme_names()   -- Get all available theme names
local current = themes.get_current_theme() -- Get current theme object

-- Theme creation
themes.register("my-theme", theme_table) -- Register new theme
themes.create_gradient_theme(name, start_color, end_color, foreground)
```

### Item API

```lua
local items = require("luxline.items")

-- Item management
local value = items.get_value("filename", "relative", context)  -- Get item value
items.clear_cache("filename")            -- Clear cache for specific item
items.clear_cache()                      -- Clear all item caches
local all = items.get_all_items()        -- Get list of all registered items
local info = items.get_item_info("filename") -- Get item metadata
```

### Custom Item Registration

```lua
local items = require("luxline.items")

items.register("my_item", function(variant, context)
  -- variant: optional variant like 'my_item:short'
  -- context: { bufnr, winid, filetype, buftype, active, filename, cwd }
  
  if variant == "short" then
    return "brief"
  end
  
  return "my custom item: " .. context.filename
end, {
  description = "My custom statusline item",
  category = "custom",
  variants = { "short", "long" },
  cache = true,                          -- Enable caching for performance
  cache_ttl = 5000,                     -- Cache duration in milliseconds
  async = false                         -- Whether item supports async operations
})
```

---

## 🎮 Customization Examples

### Minimal Configuration
```lua
require("luxline").setup({
  winbar_enabled = false,          -- Disable winbar completely
  left_active_items = { "filename", "modified" },  -- Minimal left items
  right_active_items = { "position" },             -- Minimal right items
  git_enabled = false,             -- Disable git integration
  update_throttle = 50,           -- Slower updates for better performance
})
```

### Development-Focused Setup
```lua
require("luxline").setup({
  left_active_items = { "filename:relative", "modified", "git" },
  right_active_items = { "position", "filetype:icon", "encoding" },
  left_active_items_winbar = { "windownumber" },
  right_active_items_winbar = { "cwd:short" },
  
  -- Enhanced git integration for development
  git_enabled = true,
  git_cache_timeout = 2000,       -- Faster git updates
  git_diff_debounce = 100,        -- More responsive git diff
  
  default_theme = "lux-vesper",   -- Development-friendly theme
})
```

### Performance Optimized
```lua
require("luxline").setup({
  -- Minimal item set for performance
  left_active_items = { "filename:tail", "modified" },
  right_active_items = { "position" },
  
  -- Disable resource-intensive features
  winbar_enabled = false,
  git_enabled = false,
  
  -- Conservative update settings
  update_throttle = 100,          -- Less frequent updates
})
```

---

## 🐛 Troubleshooting

### Common Issues

**Statusline not appearing**
- Verify no conflicting statusline plugins are active
- Check that `laststatus` is set appropriately: `:set laststatus=2`
- Ensure plugin was loaded: `:lua print(require("luxline").get_stats().initialized)`

**Themes not switching**
- Verify theme name spelling with `:lua print(vim.inspect(require("luxline.themes").get_theme_names()))`
- Check for lux colorscheme integration: themes auto-switch with `lux-*` colorschemes
- Try manual theme setting: `:lua require("luxline.themes").set_theme("default")`

**Performance issues**
- Increase update throttle: `update_throttle = 100`
- Disable winbar: `winbar_enabled = false`
- Disable git integration: `git_enabled = false`
- Clear item caches: `:lua require("luxline.items").clear_cache()`

**Items not displaying correctly**
- Verify item names are correct: `:lua print(vim.inspect(require("luxline.items").get_all_items()))`
- Check context requirements for custom items
- Ensure dependencies are installed (e.g., nvim-web-devicons for `filetype:icon`)

### Debug Information

```lua
-- Check plugin status and statistics
:lua print(vim.inspect(require("luxline").get_stats()))

-- Verify theme configuration
:lua print(vim.inspect(require("luxline.themes").get_current_theme()))

-- List all available items
:lua print(vim.inspect(require("luxline.items").get_all_items()))

-- Check configuration
:lua print(vim.inspect(require("luxline.config").get()))
```

### Development and Hot-Reload

```lua
-- Full plugin reload (preserves configuration)
:lua require("luxline").reload()

-- Reset to defaults
:lua require("luxline").reset()

-- Force update
:lua require("luxline").update()
```

---

## 🙏 Acknowledgments

nvim-luxline is part of the [LuxVim](https://github.com/LuxVim/LuxVim) ecosystem - a high-performance Neovim distribution focused on modern UI design and developer productivity.

---

## 📄 License

MIT License – see [LICENSE](LICENSE) for details.