local M = {
  -- 插件名称：folke/tokyonight.nvim，一款流行的Neovim主题
  "folke/tokyonight.nvim",
  -- lazy=false：不延迟加载，在启动时就加载该主题
  lazy = false,
  -- priority=1000：设置加载优先级为最高，确保在其他插件之前加载，避免颜色显示问题
  priority = 1000,
  -- opts：主题的配置选项
  opts = {
    -- 主题风格设置为"moon"（柔和深色风格）
    style = "moon",
    -- 日间模式的亮度调节（0-1之间），仅在day风格下生效
    day_brightness = 0.3,
    -- 是否降低非活动窗口的亮度（false表示不降低）
    dim_inactive = false,
    -- 是否让lualine（状态栏）中的文字加粗
    lualine_bold = true,
    -- 是否缓存主题生成的高亮组（true表示缓存，提升性能）
    cache = true,
    -- 控制主题对其他插件的样式影响
    plugins = {
      -- auto=true：自动检测并适配已安装的插件
      auto = true,
      -- telescope=false：不使用主题自带的telescope样式（后续会自定义切换逻辑）
      telescope = false,
      -- gitsigns=true：启用对gitsigns插件的样式支持
      gitsigns = true,
    },
    -- 以下是颜色自定义示例（已注释），可取消注释并修改以自定义主题基础颜色
    -- on_colors = function(colors)
    --   colors.bg = "#1a1b26"        -- 背景色
    --   colors.bg_dark = "#16161e"  -- 深色背景（如侧边栏）
    --   colors.border = "#589ed7"   -- 边框颜色
    --   colors.blue = "#7da6ff"     -- 蓝色
    --   colors.red = "#ff757f"      -- 红色
    --   colors.yellow = "#ffc777"   -- 黄色
    --   colors.green = "#c3e88d"    -- 绿色
    -- end,
    -- 自定义高亮组（覆盖主题默认设置）
    on_highlights = function(highlights, colors)
      -- 注释的样式：使用dark5颜色，斜体，不加粗
      highlights.Comment = {
        fg = colors.dark5,
        italic = true,
        bold = true,
      }
      -- 函数名的样式：使用blue2颜色，加粗
      highlights.Function = {
        fg = colors.blue2,
        bold = true,
      }
      -- 折叠文本的样式：使用fg_gutter颜色，背景色#24283b，斜体
      highlights.Folded = {
        fg = colors.fg_gutter,
        bg = "#24283b",
        italic = true,
      }
      -- 可视模式选中区域的样式：使用主题自带的bg_visual背景，前景色为fg，加粗
      highlights.Visual = {
        bg = colors.bg_visual,
        fg = colors.fg,
        bold = true,
      }
    end,
  },

  -- config：插件加载后的初始化函数，参数为默认配置和用户配置（opts）
  config = function(_, opts)
    -- 应用上述配置到Tokyonight主题
    require("tokyonight").setup(opts)
    -- 激活Tokyonight主题
    vim.cmd.colorscheme("tokyonight-storm")

    -- 配置终端颜色（与主题配色保持一致）
    vim.g.terminal_color_0 = "#1a1b26"  -- 终端黑色（背景色）
    vim.g.terminal_color_1 = "#ff757f"  -- 终端红色（错误提示等）
    vim.g.terminal_color_2 = "#c3e88d"  -- 终端绿色（成功提示等）
    vim.g.terminal_color_3 = "#ffc777"  -- 终端黄色（警告提示等）
    vim.g.terminal_color_4 = "#7da6ff"  -- 终端蓝色（链接等）

    -- 定义Tokyonight支持的所有主题风格
    local themes = {
      "tokyonight",          -- 默认风格（跟随opts中的style配置）
      "tokyonight-night",    -- 纯黑深色风格
      "tokyonight-storm",    -- 深灰深色风格
      "tokyonight-moon",     -- 柔和深色风格
      "tokyonight-day",      -- 浅色风格
    }

    -- 定义通过Telescope选择主题风格的函数（全局可见）
    function _G.SelectTokyoNightTheme()
      -- 安全加载Telescope的pickers组件（避免未安装时出错）
      local ok, pickers = pcall(require, "telescope.pickers")
      if not ok then
        -- 若加载失败，显示错误提示
        vim.notify("Telescope 插件未安装或 pickers 模块缺失", vim.log.levels.ERROR)
        return
      end
      -- 加载Telescope的其他必要组件
      local finders = require("telescope.finders")  -- 用于创建选择列表
      local actions = require("telescope.actions")  -- 用于定义选择器行为
      local action_state = require("telescope.actions.state")  -- 用于获取选中项
      local conf = require("telescope.config").values  -- 用于获取Telescope默认配置

      -- Telescope选择器的配置
      local opts_telescope = {
        prompt_title = "选择 TokyoNight 主题风格",  -- 选择器标题
        -- 定义选择列表的内容和显示方式
        finder = finders.new_table {
          results = themes,  -- 使用前面定义的themes数组作为数据源
          -- 定义每个选项的显示格式
          entry_maker = function(entry)
            -- 为每个主题添加描述信息
            local descriptions = {
              ["tokyonight"] = "默认风格（跟随配置的 style）",
              ["tokyonight-night"] = "纯黑深色风格",
              ["tokyonight-storm"] = "深灰深色风格",
              ["tokyonight-moon"] = "柔和深色风格",
              ["tokyonight-day"] = "浅色风格",
            }
            return {
              value = entry,  -- 实际值（主题名称）
              -- 显示格式：左对齐20字符的主题名 + 描述
              display = string.format("%-20s %s", entry, descriptions[entry]),
              ordinal = entry,  -- 排序用的值
            }
          end,
        },
        -- 使用Telescope的默认排序器
        sorter = conf.generic_sorter({}),
        -- 定义选择器的按键映射和行为
        attach_mappings = function(prompt_bufnr, map)
          -- 应用选中主题的函数
          local apply_selected_theme = function()
            local selection = action_state.get_selected_entry()  -- 获取当前选中项
            if selection then
              vim.cmd.colorscheme(selection.value)  -- 应用选中的主题
              vim.notify(string.format("已应用主题: %s", selection.value))  -- 显示成功提示
            end
            actions.close(prompt_bufnr)  -- 关闭选择器
          end

          -- 绑定回车键（插入模式和普通模式）触发应用主题
          map("i", "<CR>", apply_selected_theme)
          map("n", "<CR>", apply_selected_theme)
          -- 绑定ESC键关闭选择器
          map("i", "<ESC>", actions.close)
          map("n", "<ESC>", actions.close)

          return true
        end,
      }

      -- 创建并显示Telescope选择器
      pickers.new({}, opts_telescope):find()
    end

    -- 绑定快捷键：normal模式下按<leader>st触发主题选择器
    vim.keymap.set(
      "n",  -- 仅在normal模式下生效
      "<leader>st",  -- 快捷键组合（leader键 + s + t）
      "<cmd>lua SelectTokyoNightTheme()<CR>",  -- 执行的命令
      { 
        noremap = true,  -- 不允许递归映射
        silent = true,   -- 执行时不显示命令
        desc = "通过 Telescope 选择 TokyoNight 主题风格"  -- 快捷键描述（可在which-key等插件中显示）
      }
    )
  end,
}

return M
