local M = {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
        { "<c-tab>", "ToggleTerm", mode = "n", desc = "打开/关闭终端" },
  },
  opts = {
    -- 1. 基础设置
    size = 20,
    hide_numbers = true,
    open_mapping = [[<c-tab>]],

    -- 2. 终端样式与阴影
    shade_terminals = true,
    shading_factor = -30,
    shading_ratio = -3,
    shade_filetypes = {},

    -- 3. 模式与行为
    insert_mappings = true,
    terminal_mappings = true,
    start_in_insert = true,
    persist_size = true,
    persist_mode = false,
    close_on_exit = true,
    clear_env = false,

    -- 4. 布局设置
    direction = 'float',
    autochdir = false,
    auto_scroll = true,

    -- 5. 浮动窗口配置
    float_opts = {
      border = 'curved',
      winblend = 0,
      title_pos = 'center',
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
      row = function()
        local height = math.floor(vim.o.lines * 0.8)
        return math.floor((vim.o.lines - height) / 2)
      end,
      col = function()
        local width = math.floor(vim.o.columns * 0.8)
        return math.floor((vim.o.columns - width) / 2)
      end,
    },

    -- 6. 状态栏（winbar）配置
    winbar = {
      enabled = false,
      name_formatter = function(term)
        return string.format('%d:%s', term.id, term:_display_name())
      end,
    },

    -- 7. 响应式布局
    responsiveness = {
      horizontal_breakpoint = 120,
    },
  },

  -- 仅保留终端 1-3 的快捷键，去掉 lazygit 部分
  config = function(_, opts)
    require('toggleterm').setup(opts)

    -- 为 1-3 号终端绑定 <leader>1、<leader>2、<leader>3
    for i = 1, 3 do
      vim.keymap.set('n', string.format('<leader>%d', i), function()
        require('toggleterm').toggle(i, 15, nil, 'float')
      end, { desc = string.format('Toggle terminal %d', i) })
    end
  end,
}

return M
