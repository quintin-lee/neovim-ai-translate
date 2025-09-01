-- Only require config when needed, not at the top level
local config = require("neovim-ai-translate").get_config()
local curl = require("plenary.curl")
local json = vim.json

local M = {}

-- 获取视觉模式下选中的文本
local function get_visual_selection()
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1]-1, end_pos[1], false)
  
  if #lines == 0 then return "" end
  
  lines[1] = string.sub(lines[1], start_pos[2]+1)
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[2]+1)
  
  return table.concat(lines, "\n")
end

-- 向OpenAI API发送请求
local function request_openai(text, source_lang, target_lang, callback)
  -- 确保基础URL存在
  local base_url = config.openai_base_url or "https://api.openai.com/v1"
  local url = base_url .. "/chat/completions"
  
  local messages = {
    {
      role = "system",
      content = string.format(
        "You are a translator. Translate the following text from %s to %s. " ..
        "Only return the translated text without any additional explanation.",
        source_lang or "auto", target_lang or "en"
      )
    },
    {
      role = "user",
      content = text
    }
  }
  
  local body = {
    model = config.model or "gpt-3.5-turbo",
    messages = messages,
    max_tokens = config.max_tokens or 1024,
    temperature = config.temperature or 0.3
  }
  
  -- 确保API密钥存在
  if not config.openai_api_key or config.openai_api_key == "" then
    vim.notify("Error: OpenAI API key is not set!", vim.log.levels.ERROR)
    return
  end
  
  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. config.openai_api_key
  }
  
  -- 使用vim.json.encode确保JSON序列化功能可用
  local encoded_body, encode_err = json.encode(body)
  if not encoded_body then
    vim.notify("Error encoding request body: " .. (encode_err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  
  -- 发送请求
  curl.post(url, {
    body = encoded_body,
    headers = headers,
    timeout = config.timeout or 5000,
    callback = function(response)
      if not response or response.status ~= 200 then
        vim.notify("Translation failed: " .. (response and response.body or "Unknown error"), vim.log.levels.ERROR)
        return
      end
      
      -- 解析响应
      local data, decode_err = json.decode(response.body)
      if decode_err then
        vim.notify("Error parsing response: " .. decode_err, vim.log.levels.ERROR)
        return
      end
      
      if data and data.choices and data.choices[1] and data.choices[1].message then
        callback(data.choices[1].message.content)
      else
        vim.notify("Failed to parse translation response", vim.log.levels.ERROR)
      end
    end
  })
end

-- Display translation based on config
local function display_translation(result)
  if config.display_mode == "float_win" then
    M.display_float_win(result)
  elseif config.display_mode == "current_line" then
    M.display_current_line(result)
  elseif config.display_mode == "new_buffer" then
    M.display_new_buffer(result)
  else
    vim.notify("Unknown display mode: " .. config.display_mode, vim.log.levels.WARN)
    M.display_float_win(result) -- Fallback
  end
end

-- Display in floating window
function M.display_float_win(content)
  local width = config.float_win.width or 100
  local height = config.float_win.height or 25
  
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
  
  local win_opts = {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    border = config.float_win.border or "single",
    style = "minimal"
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Close window with 'q'
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<CMD>close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Display after current line
function M.display_current_line(content)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line, line, false, { "", "-- Translation --", "" })
  vim.api.nvim_buf_set_lines(0, line + 3, line + 3, false, vim.split(content, "\n"))
end

-- Display in new buffer
function M.display_new_buffer(content)
  vim.cmd("new Translation")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
  vim.api.nvim_buf_set_option(0, "modifiable", false)
  vim.api.nvim_buf_set_option(0, "filetype", "markdown")
end

-- Main translation function
function M.translate(opts)
  local text = opts.text or get_visual_selection()
  if not text or text == "" then
    vim.notify("No text selected for translation", vim.log.levels.WARN)
    return
  end
  
  local source_lang = opts.source_lang or config.default_source_lang
  local target_lang = opts.target_lang or config.default_target_lang
  
  vim.notify(string.format("Translating from %s to %s...", source_lang, target_lang))
  
  request_openai(text, source_lang, target_lang, function(result)
    if result then
      display_translation(result)
    end
  end)
end

-- Wrapper for visual mode translation
function M.translate_visual(source_lang, target_lang)
  M.translate({
    source_lang = source_lang,
    target_lang = target_lang
  })
end

return M
