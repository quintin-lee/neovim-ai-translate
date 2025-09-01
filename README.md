# neovim-ai-translate

A Neovim plugin for translation using OpenAI API, supporting multiple display modes and customizable parameters.

## Features

- Translate selected text in visual mode
- Multiple display modes for translation results
- Customizable OpenAI parameters
- Support for environment variables for API configuration
- Easy-to-use keybindings and commands

## Installation

### Requirements

- Neovim 0.7 or later
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (required dependency)
- OpenAI API key

### Using Packer
use {
  'quintin-lee/neovim-ai-translate',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('neovim-ai-translate').setup({
      -- Your configuration here
      openai_api_key = 'your-api-key', -- or set OPENAI_API_KEY environment variable
    })
  end
}
### Using Plug
Plug 'nvim-lua/plenary.nvim'
Plug 'quintin-lee/neovim-ai-translate'

" Then configure in your init.vim or init.lua:
lua require('neovim-ai-translate').setup({
  -- Your configuration here
})
## Configuration

Example configuration with custom parameters:
require('neovim-ai-translate').setup({
  openai_api_key = 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  openai_base_url = 'https://api.openai.com/v1',
  model = 'gpt-4',
  default_target_lang = 'en',
  display_mode = 'float_win',
  float_win = {
    border = 'single',
    width = 100,
    height = 25,
  }
})
All available configuration options:

- `openai_api_key`: Your OpenAI API key (required)
  - Environment variable fallback: `OPENAI_API_KEY`
  
- `openai_base_url`: Base URL for the OpenAI API (default: "https://api.openai.com/v1")
  - Environment variable fallback: `OPENAI_BASE_URL`
  
- `model`: The OpenAI model to use (default: "gpt-3.5-turbo")
  - Environment variable fallback: `MODE_NAME`
  
- `default_source_lang`: Default source language (default: "auto")
- `default_target_lang`: Default target language (default: "zh-CN")
- `max_tokens`: Maximum tokens for the response (default: 1024)
- `temperature`: Controls randomness (default: 0.3)
- `timeout`: Request timeout in milliseconds (default: 5000)
- `display_mode`: How to display results: "float_win", "current_line", or "new_buffer" (default: "float_win")
- `float_win`: Configuration for floating window display

## Usage

### Visual Mode

1. Select text in visual mode
2. Press `<leader>t` to translate using default languages
3. Press `<leader>te` to translate to English
4. Press `<leader>tc` to translate to Chinese

### Command Mode
" Translate using default languages
:Translate

" Translate with specified languages
:Translate [source_lang] [target_lang]

" Examples
:Translate en zh-CN  " Translates from English to Chinese
:Translate auto fr   " Translates from auto-detected language to French
### Closing the Floating Window

Press `q` when the cursor is in the floating window to close it.

## License

MIT License
