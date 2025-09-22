-- 彩色缩进线配置
local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

-- indent-blankline 插件选项
local option = {
    indent = {
        -- char = "│┆",             -- 缩进线使用字符
        char = "│",             -- 缩进线使用字符
        highlight = highlight,  -- 循环使用上面定义的高亮组
        smart_indent_cap = true,-- 自动限制最大缩进级别，防止太深的缩进显示
        repeat_linebreak = true,-- 在折行处重复显示缩进线
        priority = 1,           -- 虚拟文本优先级
    },

    scope = {
        enabled = true,         -- 启用光标块范围显示
        show_start = true,      -- 显示范围起始行下划线
        show_end = true,        -- 显示范围结束行下划线
        highlight = "RainbowRed", -- 默认高亮，后续会被循环覆盖
        priority = 1024,        -- 范围虚拟文本优先级，高于普通缩进线
    },

    whitespace = {
        highlight = "Whitespace",-- 空白字符使用默认高亮
        remove_blankline_trail = true, -- 移除空白行尾部空白
    },

    exclude = {
        filetypes = {
            "help", "packer", "lspinfo", "checkhealth", "man",
            "gitcommit", "TelescopePrompt", "TelescopeResults", "",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
    },
}

-- 插件主配置
local blankline_plugin = {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,            -- 延迟加载插件
    event = "VeryLazy",     -- 在 Neovim 启动后的 VeryLazy 事件加载
    main = "ibl",           -- 指定主模块入口
    config = function()
        local ibl = require("ibl")
        local hooks = require("ibl.hooks")

        -- 注册高亮设置钩子，每次 colorscheme 改变都会调用
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD", nocombine = true })
            vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2", nocombine = true })
        end)

        -- 注册钩子：跳过 C/C++ 的预处理行（#include 等）
        hooks.register(hooks.type.SKIP_LINE, hooks.builtin.skip_preproc_lines, {
            --  filetypes = { "c", "cpp" }
        })

        -- 应用配置
        ibl.setup(option)
    end
}

return blankline_plugin
