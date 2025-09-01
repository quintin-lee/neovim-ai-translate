local M = {}
local config = require('neovim-ai-translate.config')
local translator = require('neovim-ai-translate.translator')

-- Default configuration
local default_config = {
  openai_api_key = os.getenv('OPENAI_API_KEY') or nil,
  openai_base_url = os.getenv('OPENAI_BASE_URL') or 'https://api.openai.com/v1',
  model = os.getenv('MODE_NAME') or 'gpt-3.5-turbo',
  default_source_lang = 'auto',
  default_target_lang = 'zh-CN',
  max_tokens = 1024,
  temperature = 0.3,
  timeout = 5000,
  display_mode = 'float_win',
  float_win = {
    border = 'single',
    width = 100,
    height = 25,
  }
}

-- Setup function to configure the plugin
function M.setup(user_config)
  -- Merge user config with default config
  M.config = vim.tbl_deep_extend('force', default_config, user_config or {})
  
  -- Validate required configuration
  if not M.config.openai_api_key then
    vim.notify('Neovim AI Translate: openai_api_key is required', vim.log.levels.ERROR)
    return
  end
  
  -- Store config for other modules to use
  config.set_config(M.config)
  
  -- Setup commands
  M.setup_commands()
  
  -- Setup keymaps
  M.setup_keymaps()
end

-- Get current configuration
function M.get_config()
  return M.config or default_config
end

-- Setup Vim commands
function M.setup_commands()
  vim.api.nvim_create_user_command('Translate', function(opts)
    local source_lang = opts.args and opts.fargs[1] or nil
    local target_lang = opts.args and opts.fargs[2] or nil
    
    translator.translate({
      source_lang = source_lang,
      target_lang = target_lang
    })
  end, {
    nargs = '*',
    range = true,
    desc = 'Translate selected text or current line using OpenAI'
  })
end

-- Setup default keymaps
function M.setup_keymaps()
  -- Visual mode mappings
  vim.api.nvim_set_keymap('v', '<leader>t', '<ESC><CMD>lua require("neovim-ai-translate.translator").translate_visual()<CR>', {
    noremap = true,
    silent = true,
    desc = 'Translate selected text using default languages'
  })
  
  vim.api.nvim_set_keymap('v', '<leader>te', '<ESC><CMD>lua require("neovim-ai-translate.translator").translate_visual(nil, "en")<CR>', {
    noremap = true,
    silent = true,
    desc = 'Translate selected text to English'
  })
  
  vim.api.nvim_set_keymap('v', '<leader>tc', '<ESC><CMD>lua require("neovim-ai-translate.translator").translate_visual(nil, "zh-CN")<CR>', {
    noremap = true,
    silent = true,
    desc = 'Translate selected text to Chinese'
  })
end

return M
