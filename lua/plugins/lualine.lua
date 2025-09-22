local M ={
    -- 插件名称：nvim-lualine/lualine.nvim（基于 Lua 的 Neovim 状态栏插件）
    "nvim-lualine/lualine.nvim",
    -- lazy=true：标记为懒加载插件（仅在需要时加载，提高启动速度）
    lazy = true,
    -- event="VeryLazy"：在 Neovim 完全启动后（VeryLazy 事件触发时）加载插件
    event = "VeryLazy",
    -- 依赖插件列表（这些插件会在当前插件加载前先加载）
    dependencies = {
        -- 提供文件类型图标支持（如不同文件显示不同图标）
        "nvim-tree/nvim-web-devicons",
        -- 与 lazy.nvim 插件管理器集成（显示插件管理状态）
        "folke/lazy.nvim",
        -- 提供 Git 状态信息（如文件修改、新增、删除等状态）
        "lewis6991/gitsigns.nvim",
    },
    -- 插件配置函数（插件加载后执行，用于初始化设置）
    config = function()
        -- 导入 lualine 模块（核心功能入口）
        local lualine = require("lualine")
        -- 导入图标模块（用于获取文件类型图标）
        local icons = require("nvim-web-devicons")

        -- 引用 gitsigns 模块（确保其已加载，无需重复 setup，因为 gitsigns 自身已有配置）
        -- 目的是确保 lualine 能获取到 Git 状态信息（依赖 gitsigns 提供的数据）
        require("gitsigns")

        -- 配置 lualine 核心参数
        lualine.setup({
            -- 全局选项配置
            options = {
                -- 主题设置："auto" 表示自动适配当前 Neovim 的颜色主题
                theme = "auto",
                -- 是否启用图标（需要依赖 nvim-web-devicons）
                icons_enabled = true,
                -- 组件分隔符（状态栏内不同组件之间的分隔符号）
                component_separators = { left = "", right = "" },
                -- 区域分隔符（状态栏内不同区域块之间的分隔符号）
                section_separators = { left = "", right = "" },
                -- 禁用状态栏的文件类型列表
                disabled_filetypes = {
                    statusline = { "NvimTree", "neo-tree" }, -- 这些文件浏览器不显示独立状态栏
                    winbar = {}, -- 不禁用任何 winbar（此处留空）
                },
                -- 是否启用全局状态栏（true 表示整个 Neovim 窗口共用一个状态栏，而非每个子窗口一个）
                globalstatus = true,
                -- 刷新频率配置（毫秒）
                refresh = {
                    statusline = 100, -- 状态栏刷新频率（100ms 一次，确保 Git 状态等及时更新）
                    tabline = 1000,   -- 标签栏刷新频率（1秒一次，无需高频）
                    winbar = 1000,    -- 窗口栏刷新频率（1秒一次，无需高频）
                },
            },

            -- 活动窗口的状态栏配置（当前正在操作的窗口）
            sections = {
                -- lualine_a 区域：最左侧区域，通常显示编辑模式
                lualine_a = { "mode" }, -- "mode" 组件：显示当前编辑模式（如 normal、insert、visual 等）

                -- lualine_b 区域：左侧第二个区域，通常显示版本控制相关信息
                lualine_b = {
                    "branch", -- "branch" 组件：显示当前 Git 分支
                    {
                        -- "diff" 组件：显示 Git 差异（新增、修改、删除的文件数量）
                        "diff",
                        -- 自定义 Git 差异图标（使用 Nerd Font 图标）
                        symbols = { 
                            added = " ",    -- 新增文件图标
                            modified = " ", -- 修改文件图标
                            removed = " "   -- 删除文件图标
                        },
                        -- 强制设置差异图标的颜色（确保在任何主题下可见）
                        color_added = "#a3be8c",   -- 新增文件颜色（绿色系）
                        color_modified = "#ebcb8b",-- 修改文件颜色（黄色系）
                        color_removed = "#bf616a", -- 删除文件颜色（红色系）
                        -- 条件判断：仅当窗口宽度 > 80 时才显示（避免窄窗口下显示拥挤）
                        cond = function()
                            return vim.fn.winwidth(0) > 80
                        end
                    },
                    {
                        -- "diagnostics" 组件：显示语法诊断信息（错误、警告等）
                        "diagnostics",
                        sources = { "nvim_diagnostic" }, -- 数据源：使用 nvim-lspconfig 提供的诊断
                        -- 自定义诊断图标
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                    },
                },

                -- lualine_c 区域：中间左侧区域，通常显示文件名
                lualine_c = {
                    {
                        -- "filename" 组件：显示当前文件名称
                        "filename",
                        path = 1, -- 显示路径类型：1 表示相对路径（0=仅文件名，2=绝对路径）
                        file_status = true, -- 显示文件状态（如是否修改、只读）
                        -- 自定义文件状态符号
                        symbols = {
                            modified = "[+]",   -- 文件已修改的标识
                            readonly = "[-]",   -- 文件只读的标识
                            unnamed = "[No Name]", -- 无文件名时的显示
                            newfile = "[New]",  -- 新文件（未保存）的标识
                        },
                    },
                },

                -- lualine_x 区域：中间右侧区域，通常显示文件属性相关信息
                lualine_x = {
                    {
                        -- 自定义组件：显示文件类型图标和名称
                        function()
                            local ft = vim.bo.filetype -- 获取当前文件类型
                            -- 根据文件类型获取对应的图标（若无则使用默认）
                            local icon, _ = icons.get_icon_color_by_filetype(ft, { default = true })
                            -- 格式化显示：图标 + 文件类型名称
                            return string.format("%s %s", icon, ft)
                        end,
                    },
                    {
                        -- "fileformat" 组件：显示文件格式（如 Unix、DOS、Mac）
                        "fileformat",
                        -- 自定义文件格式图标
                        symbols = { unix = "", dos = "", mac = "" },
                    },
                    "encoding", -- "encoding" 组件：显示文件编码格式（如 utf-8、gbk）
                },

                -- lualine_y 区域：右侧第二个区域，通常显示进度
                lualine_y = { "progress" }, -- "progress" 组件：显示当前光标在文件中的进度（如 30%）

                -- lualine_z 区域：最右侧区域，通常显示光标位置
                lualine_z = { "location" }, -- "location" 组件：显示当前光标位置（行:列）
            },

            -- 非活动窗口的状态栏配置（未选中的窗口）
            inactive_sections = {
                -- 非活动窗口简化显示，只保留必要信息
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" }, -- 显示文件名
                lualine_x = { "location" }, -- 显示光标位置
                lualine_y = {},
                lualine_z = {},
            },

            -- tabline 配置：顶部标签栏（设为空表表示禁用顶部标签栏）
            tabline = {},

            -- 扩展配置：为特定插件或文件类型提供定制化状态栏
            extensions = {
                "lazy",       -- 适配 lazy.nvim 插件管理界面
                "man",        -- 适配 man 文档查看界面
                "nvim-tree",  -- 适配 nvim-tree 文件浏览器
                "fugitive"    -- 适配 fugitive.vim Git 工具
            },
        })
    end,
}
    
return M
