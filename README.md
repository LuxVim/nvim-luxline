# nvim-luxline

A sophisticated, modular Neovim statusline and winbar plugin designed for performance and extensibility.

## ✨ Features

- **🚀 High Performance**: Optimized rendering with intelligent caching and debouncing
- **🧩 Modular Design**: Extensive library of customizable statusline items
- **🎨 Rich Theming**: Beautiful built-in themes with easy customization
- **📊 Git Integration**: Advanced git status with diff stats and branch information
- **🔧 LSP Support**: Diagnostics, server status, and intelligent context awareness
- **📱 Dual Bars**: Both statusline and winbar support with independent configuration
- **⚡ Event-Driven**: Reactive updates based on Neovim events
- **🎯 Context Aware**: Per-filetype and per-buftype configuration overrides

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'your-username/nvim-luxline',
  config = function()
    require('luxline').setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'your-username/nvim-luxline',
  config = function()
    require('luxline').setup()
  end
}
```

### Using vim-plug
```vim
Plug 'your-username/nvim-luxline'
```

## 🚀 Quick Start

```lua
-- Minimal setup
require('luxline').setup()

-- Custom configuration
require('luxline').setup({
  left_active_items = { 'mode', 'filename', 'git', 'diagnostic' },
  right_active_items = { 'lsp', 'filesize', 'position', 'clock' },
  default_theme = 'lux-aurora',
  winbar_enabled = true,
})
```

## 📋 Available Items

### 📄 File Items
- **filename** - Current file name with variants: `full`, `relative`, `tail`
- **filetype** - File type with optional devicon support (`icon` variant)
- **filesize** - Current file size (`bytes`, `short` variants)
- **encoding** - File encoding (`short` variant)
- **modified** - File modification indicator (`icon`, `short` variants)
- **readonly** - Read-only file indicator
- **cwd** - Current working directory (`full`, `short` variants)

### 🎮 Editor Items
- **mode** - Current Neovim mode (`short`, `icon` variants)
- **position** - Cursor position (`line`, `column` variants)
- **percent** - Buffer percentage
- **macro** - Macro recording indicator (`short`, `icon` variants)
- **search** - Search results info (`count`, `current_total`, `pattern`, `short` variants)

### 🔧 Development Items
- **git** - Git repository info (`branch`, `diff`, `combined`, `status` variants)
- **diagnostic** - LSP diagnostics (`errors_only`, `warnings_only`, `count`, `summary` variants)
- **lsp** - LSP server status (`count`, `names`, `first`, `status` variants)

### 🖥️ System Items
- **clock** - Current time (`12h`, `seconds`, `short`, `full` variants)
- **windownumber** - Window number

### 🎨 Layout Items
- **spacer** - Flexible spacer for layout

## ⚙️ Configuration

### Default Configuration
```lua
{
  -- Statusline items
  left_active_items = { 'windownumber', 'filename', 'modified' },
  left_inactive_items = { 'windownumber', 'filename', 'modified' },
  right_active_items = { 'position', 'filetype', 'encoding' },
  right_inactive_items = { 'position', 'filetype', 'encoding' },
  
  -- Winbar items
  winbar_enabled = true,
  left_active_items_winbar = { 'windownumber' },
  left_inactive_items_winbar = { 'windownumber' },
  right_active_items_winbar = { 'filename:tail' },
  right_inactive_items_winbar = { 'filename:tail' },
  
  -- Separators
  left_separator = '█',
  right_separator = '█',
  left_separator_winbar = '█',
  right_separator_winbar = '█',
  
  -- Performance settings
  update_throttle = 20,
  git_cache_timeout = 5000,
  git_diff_debounce = 200,
  
  -- Theme
  default_theme = 'default',
  
  -- Features
  git_enabled = true,
  buffer_exclude = {},
}
```

### Item Variants
Items support variants using the `:variant` syntax:
```lua
{
  left_active_items = {
    'mode:short',        -- Show short mode (N, I, V)
    'filename:relative', -- Show relative path
    'git:branch',        -- Show only git branch
    'diagnostic:count'   -- Show diagnostic count only
  }
}
```

### Per-Filetype Configuration
```lua
require('luxline').setup({
  -- Global config
  left_active_items = { 'filename', 'modified' },
  
  -- Filetype-specific overrides
  filetype_config = {
    lua = {
      left_active_items = { 'mode', 'filename', 'lsp' }
    },
    markdown = {
      right_active_items = { 'clock', 'position' }
    }
  }
})
```

## 🎨 Themes

### Built-in Themes
- `default` - Clean default theme
- `lux-aurora` - Vibrant aurora-inspired theme
- `lux-chroma` - Colorful chromatic theme
- `lux-eos` - Elegant dawn theme
- `lux-umbra` - Dark shadow theme
- `lux-vesper` - Evening twilight theme

### Using Themes
```lua
require('luxline').setup({
  default_theme = 'lux-aurora'
})
```

### Custom Themes
Create custom themes by extending the base theme:
```lua
local base = require('luxline.themes.base')

local my_theme = vim.tbl_deep_extend('force', base, {
  normal = {
    a = { fg = '#ffffff', bg = '#0066cc', style = 'bold' },
    b = { fg = '#ffffff', bg = '#004499' },
    c = { fg = '#cccccc', bg = '#002266' }
  },
  insert = {
    a = { fg = '#ffffff', bg = '#00cc66', style = 'bold' }
  }
})

require('luxline.themes').register('my_theme', my_theme)
```

## 📊 Git Integration

Advanced git integration with caching and performance optimizations:

```lua
{
  git_enabled = true,
  git_cache_timeout = 5000,  -- Cache timeout in ms
  git_diff_debounce = 200,   -- Debounce git updates
  left_active_items = {
    'git:branch',     -- Show only branch
    'git:diff',       -- Show only diff stats
    'git:status',     -- Show formatted status
    'git:combined'    -- Show branch + diff (default)
  }
}
```

## 🔧 LSP Integration

Rich LSP integration with diagnostics and server status:

```lua
{
  left_active_items = {
    'diagnostic',           -- All diagnostics with icons
    'diagnostic:errors_only', -- Only errors
    'diagnostic:count',     -- Total count only
    'lsp:status',          -- Server status with icon
    'lsp:names'            -- Active server names
  }
}
```

## 🎯 Advanced Usage

### Custom Items
Create custom items following the plugin's architecture:

```lua
local items = require('luxline.items')

items.register('custom_item', function(variant, context)
  if variant == 'short' then
    return 'C'
  else
    return 'Custom: ' .. context.filename
  end
end, {
  description = "My custom item",
  category = "custom",
  variants = { 'short' },
  cache = true,
  cache_ttl = 1000
})
```

### Buffer Exclusions
Exclude specific buffer types:
```lua
{
  buffer_exclude = {
    buftype = { 'terminal', 'quickfix' },
    filetype = { 'NvimTree', 'help' }
  }
}
```

### Event Handling
The plugin emits events for extensibility:
```lua
local events = require('luxline.core.events')

events.on('item_cache_cleared', function(data)
  print('Cache cleared for:', data.item_name)
end)
```

## 🛠️ Development Commands

```lua
-- Reload the plugin during development
:lua require('luxline').reload()

-- Debug functionality
:lua require('luxline').debug()

-- Preview current configuration
:lua require('luxline').preview_config()

-- View performance stats
:lua print(vim.inspect(require('luxline').get_stats()))
```

## 🏗️ Architecture

nvim-luxline features a sophisticated modular architecture:

- **Core System**: Lifecycle management, state handling, and event system
- **Rendering Engine**: Unified bar builder for statusline and winbar
- **Item Registry**: Dynamic item discovery and caching system
- **Theme Engine**: Flexible theming with inheritance support
- **Integration Layer**: Git, LSP, and other tool integrations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### Adding New Items
1. Create a new file in `lua/luxline/items/`
2. Follow the existing item patterns
3. Register the item with appropriate metadata
4. Add documentation and variants

### Adding New Themes
1. Create a new file in `lua/luxline/themes/`
2. Extend the base theme
3. Define colors for all modes and components

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by lualine.nvim and other statusline plugins
- Thanks to the Neovim community for feedback and contributions
