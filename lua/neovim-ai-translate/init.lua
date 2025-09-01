local M = {}
local config = require('neovim-ai-translate.config')

-- Setup function to configure the plugin
function M.setup(user_config)
  config.setup(user_config)

  cfg = config.get_config()
  -- Validate required configuration
  if cfg.openai_api_key or cfg.openai_api_key == "" then
    vim.notify("neovim-ai-translate: OpenAI API key is required!", vim.log.levels.ERROR)
  end
end

-- Get current configuration
M.get_config = config.get_config

-- Load translator module with proper dependency handling
local translator_loaded, translator = pcall(require, "neovim-ai-translate.translator")
if translator_loaded then
  -- Export translator functions
  M.translate = translator.translate
  M.translate_visual = translator.translate_visual
  M.display_float_win = translator.display_float_win
  M.display_current_line = translator.display_current_line
  M.display_new_buffer = translator.display_new_buffer
else
  vim.notify("neovim-ai-translate: Failed to load translator module: " .. translator, vim.log.levels.ERROR)
end

return M
