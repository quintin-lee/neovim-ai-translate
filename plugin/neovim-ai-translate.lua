-- Safe plugin initialization
local ok, ai_translate = pcall(require, "neovim-ai-translate")
if not ok then
  vim.notify("Failed to load neovim-ai-translate: " .. ai_translate, vim.log.levels.ERROR)
  return
end

-- Setup default keymaps
local function setup_keymaps()
  -- Visual mode translations
  vim.keymap.set('v', '<leader>t', function()
    require('neovim-ai-translate').translate_visual()
  end, { desc = "Translate selected text" })
  
  vim.keymap.set('v', '<leader>te', function()
    require('neovim-ai-translate').translate_visual(nil, 'en')
  end, { desc = "Translate selected text to English" })
  
  vim.keymap.set('v', '<leader>tc', function()
    require('neovim-ai-translate').translate_visual(nil, 'zh-CN')
  end, { desc = "Translate selected text to Chinese" })
end

-- Only setup keymaps if plugin loaded successfully
setup_keymaps()

-- Create user command
vim.api.nvim_create_user_command('Translate', function(args)
  local source_lang = args.fargs[1]
  local target_lang = args.fargs[2]
  require('neovim-ai-translate').translate_visual(source_lang, target_lang)
end, {
  nargs = '*',
  range = true,
  desc = "Translate selected text using OpenAI"
})
