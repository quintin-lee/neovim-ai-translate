local M = {}
local config = {}

-- Default configuration
local default_config = {
  openai_api_key = os.getenv("OPENAI_API_KEY") or "",
  openai_base_url = os.getenv("OPENAI_BASE_URL") or "https://api.openai.com/v1",
  model = os.getenv("MODE_NAME") or "gpt-3.5-turbo",
  default_source_lang = "auto",
  default_target_lang = "zh-CN",
  max_tokens = 1024,
  temperature = 0.3,
  timeout = 5000,
  display_mode = "float_win",
  float_win = {
    border = "single",
    width = 100,
    height = 25,
  }
}

-- Setup function to configure the plugin
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config or {})
  
  -- Validate required configuration
  if config.openai_api_key == "" then
    vim.notify("neovim-ai-translate: OpenAI API key is required!", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Get current configuration
function M.get_config()
  return config
end

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
