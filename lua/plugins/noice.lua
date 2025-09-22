local M = {
    "folke/noice.nvim",
    event = "VeryLazy", -- 延迟加载，在 Neovim 启动完成后加载
    dependencies = {
        -- 必选依赖：UI 渲染核心
        "MunifTanjim/nui.nvim",
        -- 可选依赖：通知弹窗（不安装则使用内置 mini 视图）
        {
            "rcarriga/nvim-notify",
            opts = {
                background_colour = "NormalFloat", -- 或与你的主题背景色匹配的值
            }
        },
        -- 可选依赖：增强 LSP 文档的 Markdown 渲染（需配合 treesitter）
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        -- 1. 命令行配置（替代 :, /, ? 等命令行）
        cmdline = {
            enabled = true, -- 启用 noice 的命令行 UI
            view = "cmdline", 
            opts = {}, -- 视图全局选项（如边框、位置等）
            -- 命令行格式配置（不同命令行的样式）
            format = {
                cmdline = { pattern = "^:", icon = "", lang = "vim" }, -- 普通命令行（:）
                search_down = { pattern = "^/", icon = " ", lang = "regex" }, -- 向下搜索（/）
                search_up = { pattern = "^%?", icon = " ", lang = "regex" }, -- 向上搜索（?）
                filter = { pattern = "^:%s*!", icon = "$", lang = "bash" }, -- 终端命令（:!）
                lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*" }, icon = "", lang = "lua" }, -- Lua 命令
                help = { pattern = "^:%s*he?l?p?%s+", icon = "" }, -- 帮助命令（:h）
                input = { view = "cmdline_input", icon = "󰥻 " }, -- input() 函数的输入框
            },
        },

        -- 2. 消息配置（处理 vim.notify、print 等消息）
        messages = {
            enabled = true, -- 启用 noice 的消息 UI
            view = "notify", -- 默认消息视图（弹窗）
            view_error = "notify", -- 错误消息视图
            view_warn = "notify", -- 警告消息视图
            view_history = "messages", -- :messages 命令的视图（分屏）
            view_search = "virtualtext", -- 搜索计数消息（如 "搜索到 3 项"）
        },

        -- 3. 弹窗菜单配置（命令行补全菜单）
        popupmenu = {
            enabled = true, -- 启用 noice 的补全菜单
            backend = "nui", -- 后端：nui（内置）或 cmp（配合 nvim-cmp）
            kind_icons = true, -- 显示补全项类型图标（需 Nerd Font）
        },

        -- 4. LSP 集成配置
        lsp = {
            progress = {
                enabled = true, -- 启用 LSP 进度提示（如 "正在索引..."）
                format = "lsp_progress", -- 进度格式
                format_done = "lsp_progress_done", -- 完成时的格式
                throttle = 100, -- 刷新频率（毫秒）
                view = "mini", -- 进度条视图（mini 为精简模式）
            },
            -- 覆盖 Neovim 原生 LSP 渲染函数（使用 noice 的渲染）
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true, -- 转换输入为 Markdown
                ["vim.lsp.util.stylize_markdown"] = true, -- 美化 Markdown 渲染
                ["cmp.entry.get_documentation"] = true, -- 让 nvim-cmp 的文档使用 noice 渲染
            },
            -- LSP hover 提示（光标悬停时的文档）
            hover = {
                enabled = true, -- 启用
                silent = false, -- 无内容时是否显示提示
                view = nil, -- 视图（nil 为默认）
                opts = { border = "rounded" }, -- 选项（如边框样式）
            },
            -- LSP 签名帮助（输入函数参数时的提示）
            signature = {
                enabled = true, -- 启用
                auto_open = {
                    enabled = true, -- 自动触发
                    trigger = true, -- 输入触发字符（如 ( 时触发）
                    luasnip = true, -- 配合 luasnip 时触发
                    snippets = true, -- 配合内置 snippet 时触发
                    throttle = 100, -- 防抖（毫秒）
                },
                view = nil, -- 视图（nil 为默认）
                opts = { border = "rounded" }, -- 选项（如边框样式）
            },
            -- LSP 消息（如 "格式化完成"）
            message = {
                enabled = true,
                view = "notify", -- 消息视图
                opts = {},
            },
        },

        -- 5. 通知配置（对接 vim.notify）
        notify = {
            enabled = true, -- 启用 noice 处理 vim.notify
            view = "notify", -- 通知视图（需 nvim-notify）
        },

        -- 6. 预设配置（快速启用常用功能组合）
        presets = {
            bottom_search = true, -- 搜索命令行显示在底部（类似原生）
            command_palette = false, -- 命令行和补全菜单合并显示
            long_message_to_split = true, -- 长消息自动显示在分屏中
            inc_rename = false, -- 配合 inc-rename.nvim 显示重命名输入框
            lsp_doc_border = true, -- LSP 文档添加边框（美观）
        },

        -- 7. 视图配置（自定义各类组件的显示方式）
        views = {
            -- 弹窗视图（如命令行、通知）
            popup = {
                border = { style = "rounded" }, -- 边框样式
                position = { row = 5, col = "50%" }, -- 位置（居中）
                size = { width = "80%", height = "60%" }, -- 大小
            },
            -- 通知视图（需 nvim-notify）
            notify = {
                timeout = 2000, -- 通知自动关闭时间（毫秒）
                border = { style = "rounded" },
            },
            -- 底部消息视图（如 :messages）
            messages = {
                view = "split", -- 分屏显示
                enter = true, -- 打开时自动进入
            },
            -- 精简视图（如 LSP 进度）
            mini = {
                position = { row = -1, col = 0 }, -- 底部显示
            },
        },

        -- 8. 路由配置（控制消息如何被处理和显示）
        routes = {
            -- 示例：将错误消息路由到错误视图
            {
                filter = { error = true }, -- 过滤条件：错误消息
                view = "notify", -- 显示在通知视图
                opts = { level = vim.log.levels.ERROR }, -- 级别：错误
            },
            -- 示例：忽略无意义的 "written" 消息（如保存文件时）
            {
                filter = {
                    event = "msg_show",
                    kind = "",
                    find = "written",
                },
                opts = { skip = true }, -- 跳过显示
            },
        },

        -- 9. 调试配置（开发/排错用）
        debug = false, -- 关闭调试模式
        log = vim.fn.stdpath("state") .. "/noice.log", -- 日志文件路径
    },
}

return M
