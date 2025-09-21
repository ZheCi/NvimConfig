-- 导入自定义图标配置
local icons = require("utils.icons")

-- nvim-tree 核心配置选项
local opts = {
    -- 操作行为配置
    actions = {
        -- 打开文件相关设置
        open_file = {
            quit_on_open = true,  -- 打开文件后关闭文件树
            eject = true,         -- 打开文件后将光标聚焦到文件窗口
        },
        -- 删除文件相关设置
        remove_file = {
            close_window = true,  -- 删除文件后关闭文件树窗口
        }
    },

    -- 诊断信息配置（需要 LSP 支持）
    diagnostics = {
        enable = true,  -- 启用诊断信息显示（错误、警告等）
    },

    -- 视图相关配置
    view = {
        preserve_window_proportions = true,  -- 调整窗口大小时保持比例
        float = {  -- 浮动窗口配置（默认禁用）
            enable = false,  -- 不启用浮动窗口
            quit_on_focus_loss = true,  -- 失去焦点时关闭浮动窗口
            open_win_config = {  -- 浮动窗口位置和样式
                relative = "editor",  -- 相对于编辑器定位
                border = "rounded",   -- 圆角边框
                row = 1,              -- 起始行位置
                col = 1,              -- 起始列位置
            },
        }
    },

    -- 过滤规则配置
    filters = {
        dotfiles = false,  -- 过滤隐藏文件（.开头的文件）
    },

    -- 渲染配置（图标、样式等）
    renderer = {
        icons = {
            -- 集成 nvim-web-devicons 插件（文件类型图标）
            web_devicons = {
                file = {
                    enable = true,   -- 为文件显示类型图标
                    color = true,    -- 使用图标自带颜色
                },
                folder = {
                    enable = false,  -- 不为文件夹显示类型图标（使用自定义图标）
                    color = true,
                },
            },

            -- 图标位置配置
            git_placement = "before",          -- Git 图标显示在文件名之前
            modified_placement = "after",      -- 修改状态图标显示在文件名之后
            diagnostics_placement = "signcolumn",  -- 诊断图标显示在符号列
            bookmarks_placement = "signcolumn",    -- 书签图标显示在符号列
            
            padding = " ",             -- 图标与文本之间的间距
            symlink_arrow = " ➛ ",     -- 符号链接的箭头符号

            -- 控制哪些图标显示
            show = {
                file = true,            -- 显示文件图标
                folder = true,          -- 显示文件夹图标
                folder_arrow = true,    -- 显示文件夹展开/折叠箭头
                git = true,             -- 显示 Git 状态图标
                modified = true,        -- 显示文件修改状态图标
                diagnostics = true,     -- 显示诊断信息图标
                bookmarks = true,       -- 显示书签图标
            },

            -- 图标符号配置（使用自定义图标）
            glyphs = {
                default = icons.file.default,       -- 默认文件图标
                symlink = icons.file.symlink,       -- 符号链接图标
                bookmark = icons.misc.bookmark,     -- 书签图标
                modified = icons.misc.modified,     -- 文件修改状态图标

                -- 文件夹图标配置
                folder = {
                    default = icons.folder.default,         -- 关闭的文件夹
                    open = icons.folder.open,               -- 打开的文件夹
                    empty = icons.folder.empty,             -- 空文件夹
                    empty_open = icons.folder.empty_open,   -- 打开的空文件夹
                    symlink = icons.folder.symlink,         -- 符号链接文件夹
                    symlink_open = icons.folder.symlink_open, -- 打开的符号链接文件夹
                },

                -- Git 状态图标配置
                git = {
                    unstaged = icons.git.unstaged,    -- 未暂存状态
                    staged = icons.git.staged,        -- 已暂存状态
                    unmerged = icons.git.unmerged,    -- 未合并状态
                    renamed = icons.git.renamed,      -- 已重命名状态
                    untracked = icons.git.untracked,  -- 未跟踪状态
                    deleted = icons.git.deleted,      -- 已删除状态
                    ignored = icons.git.ignored,      -- 已忽略状态
                },
            },
        },
    }
}

-- 插件最终配置（符合 lazy.nvim 规范）
local M = {
    "nvim-tree/nvim-tree.lua",  -- 插件名称
    lazy = true,                -- 启用懒加载
    keys = {                    -- 触发加载的按键
        { "<leader>f", "<cmd>NvimTreeToggle<CR>", mode = "n", desc = "开启/关闭文件浏览窗口" },
    },
    opts = opts,                -- 插件配置（会自动传递给 setup() 方法）
    dependencies = {            -- 依赖插件（确保图标正常显示）
        "nvim-tree/nvim-web-devicons",
    }
}

return M
