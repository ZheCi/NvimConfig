local M = {
  "uga-rosa/translate.nvim",
  keys = {                    -- 触发加载的按键
    { "<leader>er", "viw:Translate ZH -output=replace<CR>", mode = "n", desc = "翻译当前光标下的字段(替换)"},
    { "<leader>er", "<cmd>'<,'>Translate ZH -output=replace<CR><Esc>", mode = "v", desc = "翻译选中的的字段(替换)"},
    { "<leader>es", "viw:Translate ZH<CR>", mode = "n", desc = "翻译当前光标下的字段"},
    { "<leader>es", "<cmd>'<,'>Translate ZH<CR><Esc>", mode = "v", desc = "翻译选中的的字段"},
    { "<leader>zr", "viw:Translate EN -output=replace<CR>", mode = "n", desc = "翻译当前光标下的字段(替换)"},
    { "<leader>zr", "<cmd>'<,'>Translate EN -output=replace<CR><Esc>", mode = "v", desc = "翻译选中的的字段(替换)"},
    { "<leader>zs", "viw:Translate EN<CR>", mode = "n", desc = "翻译当前光标下的字段"},
    { "<leader>zs", "<cmd>'<,'>Translate EN<CR><Esc>", mode = "v", desc = "翻译选中的的字段"},
  },
  config = function()
    require("translate").setup({
      default = {
        command = "translate_shell",
      },
      preset = {
        command = {
          translate_shell = {
            args = { "-e", "bing" }
          }
        }
      }
    })
  end
}

return M
