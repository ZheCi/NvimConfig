local M = {
  -- 插件名称：akinsho/toggleterm.nvim（一个Neovim终端管理插件）
  'akinsho/toggleterm.nvim',
  -- 使用最新版本
  version = '*',
  -- 按键映射配置
  keys = {
    -- 在普通模式下按<C-tab>触发ToggleTerm命令，功能是打开/关闭终端
    { "<c-tab>", "ToggleTerm", mode = "n", desc = "打开/关闭终端" },
  },
  -- 插件选项配置
  opts = {
    -- 1. 基础设置
    size = 20, -- 终端默认大小（当方向为水平/垂直时生效，单位为行数/列数）
    hide_numbers = true, -- 隐藏终端窗口的行号
    open_mapping = [[<c-tab>]], -- 用于打开/关闭终端的快捷键映射（与上面keys配置呼应）

    -- 2. 终端样式与阴影
    shade_terminals = true, -- 开启终端窗口阴影效果
    shading_factor = -30, -- 阴影明暗程度（负值表示变暗，范围-100到100）
    shading_ratio = -3, -- 阴影比例（影响阴影范围）
    shade_filetypes = {}, -- 对特定文件类型启用阴影（空表表示对所有类型生效）

    -- 3. 模式与行为
    insert_mappings = true, -- 在插入模式下启用终端相关映射
    terminal_mappings = true, -- 在终端模式下启用默认映射（如<C-\><C-n>退出终端模式）
    start_in_insert = true, -- 终端打开时默认进入插入模式
    persist_size = true, -- 关闭后重新打开时保持终端大小
    persist_mode = false, -- 关闭后不保留之前的模式（避免与其他插件冲突）
    close_on_exit = true, -- 终端进程退出时自动关闭终端窗口
    clear_env = false, -- 不清除环境变量（使用当前Neovim的环境变量）

    -- 4. 布局设置
    direction = 'float', -- 终端默认布局方向（float：浮动窗口；horizontal：水平分割；vertical：垂直分割；tab：新标签页）
    autochdir = false, -- 不随当前缓冲区目录自动切换终端工作目录
    auto_scroll = true, -- 终端输出过长时自动滚动到底部

    -- 5. 浮动窗口配置（当direction为float时生效）
    float_opts = {
      border = 'curved', -- 浮动窗口边框样式（curved：曲线边框）
      winblend = 0, -- 窗口透明度（0为不透明，100为完全透明）
      title_pos = 'center', -- 窗口标题位置（center：居中）
      -- 浮动窗口宽度：屏幕宽度的80%
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      -- 浮动窗口高度：屏幕高度的80%
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
      -- 浮动窗口行位置：垂直居中
      row = function()
        local height = math.floor(vim.o.lines * 0.8)
        return math.floor((vim.o.lines - height) / 2)
      end,
      -- 浮动窗口列位置：水平居中
      col = function()
        local width = math.floor(vim.o.columns * 0.8)
        return math.floor((vim.o.columns - width) / 2)
      end,
    },

    -- 6. 状态栏（winbar）配置
    winbar = {
      enabled = false, -- 不启用终端窗口的winbar
      -- 状态栏名称格式化函数（当enabled为true时生效）
      name_formatter = function(term)
        return string.format('%d:%s', term.id, term:_display_name())
      end,
    },

    -- 7. 响应式布局
    responsiveness = {
      horizontal_breakpoint = 120, -- 当屏幕宽度超过120列时，水平布局可能自适应调整
    },

    -- 终端打开时的回调函数：强制进入插入模式
    -- 解决关闭dapui后终端可能默认进入普通模式的问题
    on_open = function(term)
      vim.cmd("startinsert") -- 强制执行插入模式命令
    end,
  },

  -- 插件初始化配置
  config = function(_, opts)
    -- 加载toggleterm插件并应用上述配置
    require('toggleterm').setup(opts)

    -- 为1-3号终端绑定快捷键：<leader>1、<leader>2、<leader>3
    for i = 1, 3 do
      -- 定义快捷键映射
      vim.keymap.set('n', string.format('<leader>%d', i), function()
        -- 切换第i号终端的显示状态，大小15，使用浮动布局
        require('toggleterm').toggle(i, 15, nil, 'float')
      end, { desc = string.format('切换第%d号终端', i) }) -- 快捷键描述（用于帮助信息）
    end
  end,
}

-- 导出配置模块（供插件管理器加载）
return M
