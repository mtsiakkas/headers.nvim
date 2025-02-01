<h1> Headers.nvim </h1>

### Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'mtsiakkas/headers.nvim',
    opts = { keymaps = true }
}

```

### Usage
#### User Commands
```help
`CreateHeader` - Replaces the selected lines/current line with header
`NewHeader` - Creates new header from user input
```

#### Normal Mode
```help
`<leader>gh` - Replaces the current line with header (`CreateHeader`)
`<leader>gH` - Creates new header from user input (`AddHeader`)
```

#### Visual Mode
```help
`<leader>gh` - Replaces the selected lines with header (`CreateHeader`)
```
