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

user_config = {}

-- Set configuration
function M.setup(config)
  user_config = vim.tbl_deep_extend("force", {}, default_config, config or {})
end

-- Get configuration
function M.get_config()
  return vim.tbl_deep_extend("force", {}, default_config, user_config)
end

return M
