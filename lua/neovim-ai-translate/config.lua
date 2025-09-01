local M = {}
local config = {}

-- Set configuration
function M.set_config(cfg)
  config = cfg
end

-- Get configuration
function M.get_config()
  return config
end

return M
