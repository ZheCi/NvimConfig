local lspsaga_plugin = {
  "glepnir/lspsaga.nvim",
  event = 'LspAttach',
  -- event = "VeryLazy",
  config = function()
    require("lspsaga").setup({
      -- keybinds for navigation in lspsaga window
      move_in_saga = { prev = "<C-k>", next = "<C-j>" },
      -- use enter to open file with finder
      finder_action_keys = {
        open = "<CR>",
      },
      -- use enter to open file with definition preview
      definition_action_keys = {
        edit = "<CR>",
      },
      outline = {
        win_position = 'right',  -- 窗口位置
        close_after_jump = true, -- 跳转后关闭
        win_width = 30,          -- 窗格宽度
        auto_preview = false,    -- 自动预览
        detail = true,           -- 显示详细信息
        auto_close = true,       -- 当大纲窗口是最后一个窗口时自动关闭自身
        layout = 'normal'        -- 普通模式, 浮动模式为float
      },
      finder = {
        keys = {
          tabe = 't',     -- 在新的标签页打开
          split = 's',    -- 水平打开
          vsplit = 'v',   -- 垂直打开
          quit = 'q',     -- 退出
          close = '<C-C>' -- 关闭
        },
        left_width = 0.3,
        right_width = 0.7,
        layout = 'float', -- 'normal'
      }
    })
  end,
}

return lspsaga_plugin
