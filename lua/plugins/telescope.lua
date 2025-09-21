local M = {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',  
    dependencies = {
        'nvim-lua/plenary.nvim',  -- 必需依赖
        'nvim-telescope/telescope-fzf-native.nvim',  -- 提升搜索性能
        'nvim-tree/nvim-web-devicons',  -- 图标支持
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local themes = require('telescope.themes')

        -- 初始化配置
        telescope.setup({
            -- 全局默认设置
            defaults = {
                -- 基础行为
                sorting_strategy = 'descending',  -- 结果排序方向（descending/ascending）
                selection_strategy = 'reset',     -- 选择策略（reset/follow/row等）
                scroll_strategy = 'cycle',        -- 滚动策略（cycle/limit）
                initial_mode = 'insert',          -- 初始模式（insert/normal）
                path_display = { 'truncate' },    -- 路径显示方式（truncate/tail/smart等）
                wrap_results = false,             -- 是否换行显示结果

                -- 外观
                prompt_prefix = '🔍 ',            -- 搜索框前缀
                selection_caret = '➤ ',           -- 选中项前缀
                entry_prefix = '  ',              -- 普通项前缀
                multi_icon = '+',                 -- 多选标记
                border = true,                    -- 是否显示边框
                borderchars = {                   -- 边框字符（8个字符）
                    '─', '│', '─', '│', '╭', '╮', '╯', '╰'
                },
                winblend = 30,                     -- 窗口透明度（0-100）

                -- 布局配置
                layout_strategy = 'vertical',   -- 默认布局（horizontal/vertical/center等）
                layout_config = {
                    horizontal = {
                        width = 0.9,    -- 宽度占比
                        height = 0.9,   -- 高度占比
                        prompt_position = 'top',  -- 搜索框位置
                        preview_width = 0.6,         -- 预览窗宽度占比
                    },
                    vertical = {
                        width = 0.8,
                        height = 0.9,
                        preview_height = 0.6,        -- 预览窗高度占比
                    },
                },

                -- 功能设置
                file_ignore_patterns = {          -- 忽略文件/目录
                    'node_modules/', '.git/', 'dist/', 'build/'
                },
                dynamic_preview_title = true,     -- 动态预览标题
                preview = {
                    filesize_limit = 1,             -- 预览文件大小限制（MB）
                    timeout = 200,                  -- 预览超时时间（ms）
                },

                -- 快捷键映射
                mappings = {
                    i = {  -- 插入模式
                        ['<C-j>'] = actions.move_selection_next,    -- 下一项
                        ['<C-k>'] = actions.move_selection_previous,-- 上一项
                        ['<C-c>'] = actions.close,                  -- 关闭
                        ['<CR>'] = actions.select_default,          -- 选中
                        ['<C-o>'] = actions.select_default,         -- 选中
                        ['<C-CR>'] = actions.select_default,          -- 选中
                        ['<C-x>'] = actions.select_horizontal,      -- 水平分屏打开
                        ['<C-v>'] = actions.select_vertical,        -- 垂直分屏打开
                        ['<C-t>'] = actions.select_tab,             -- 新标签页打开
                        ['<C-u>'] = actions.preview_scrolling_up,   -- 预览上滚
                        ['<C-d>'] = actions.preview_scrolling_down, -- 预览下滚
                    },
                    n = {  -- 普通模式
                        ['q'] = actions.close,
                        ['o'] = actions.select_default,
                        ['j'] = actions.move_selection_next,
                        ['k'] = actions.move_selection_previous,
                        ['gg'] = actions.move_to_top,
                        ['G'] = actions.move_to_bottom,
                        ['<C-c>'] = actions.close,                  -- 关闭
                    },
                },
            },

            -- 特定picker配置（覆盖默认值）
            pickers = {
                find_files = {
                    layout_strategy = 'horizontal',  -- 水平布局
                    layout_config = {
                        horizontal = {
                            preview_width = 0.6,  -- 预览框宽度占比（0.7 表示 70%，结果框则占 30%）
                            width = 0.9,  -- 整体宽度占屏幕 90%
                            height = 0.8, -- 整体高度占屏幕 90%
                            prompt_position = "bottom" -- 搜索框在下
                        }
                    },
                    hidden = true,
                },
                live_grep = {
                    theme = 'ivy',       -- 使用ivy主题
                    additional_args = function()
                        return { '--hidden' }  -- 搜索隐藏文件
                    end,
                },
                buffers = {
                    show_all_buffers = true,
                    sort_lastused = true,
                    mappings = {
                        i = {
                            ['<C-d>'] = actions.delete_buffer,  -- 删除缓冲区
                        },
                    },
                },
            },

            -- 扩展配置
            extensions = {
                fzf = {
                    fuzzy = true,                   -- 模糊匹配
                    override_generic_sorter = true, -- 覆盖通用排序器
                    override_file_sorter = true,    -- 覆盖文件排序器
                    case_mode = 'smart_case',       -- 智能大小写（大写精确匹配）
                },
            },
        })

        -- 加载扩展
        pcall(telescope.load_extension, 'fzf')  -- 加载fzf扩展（需提前安装）
        pcall(telescope.load_extension, 'projects')  -- 如有项目管理扩展

        -- 自定义快捷键（根据个人习惯调整）
        local keymap = vim.keymap.set
        keymap('n', '<leader>sk', '<cmd>Telescope keymaps<CR>', { desc = '查找快捷键' })
        keymap('n', '<leader>sf', '<cmd>Telescope find_files<CR>', { desc = '查找文件' })
        keymap('n', '<leader>sg', '<cmd>Telescope live_grep<CR>', { desc = '实时文本搜索' })
        keymap('n', '<leader>sb', '<cmd>Telescope buffers<CR>', { desc = '查找缓冲区' })
        keymap('n', '<leader>sh', '<cmd>Telescope help_tags<CR>', { desc = '帮助文档' })
        keymap('n', '<leader>sd', '<cmd>Telescope diagnostics<CR>', { desc = '诊断信息' })
        keymap('n', '<leader>sr', '<cmd>Telescope lsp_references<CR>', { desc = 'LSP引用' })
        keymap('n', '<leader>sm', '<cmd>Telescope marks<CR>', { desc = '书签' })
    end,
}


return M
