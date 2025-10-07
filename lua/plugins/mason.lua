local M = {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
        -- 安装包的根目录，默认位于Neovim的数据目录下
        -- 可通过 :echo stdpath('data') 查看具体路径
        install_root_dir = vim.fn.stdpath("data") .. "/mason",

        -- Mason的bin目录在PATH中的位置
        -- "prepend"：放在PATH最前面（默认）
        -- "append"：放在PATH最后面
        -- "skip"：不修改PATH
        PATH = "prepend",

        -- 日志级别，调试时可改为vim.log.levels.DEBUG
        log_level = vim.log.levels.INFO,

        -- 最大并发安装数，超过则进入队列等待
        max_concurrent_installers = 4,

        -- 包注册表来源，默认使用官方注册表
        -- 可添加自定义注册表，优先级按列表顺序
        registries = {
            "github:mason-org/mason-registry",
        },

        -- 元数据解析提供者，用于获取包的版本等信息
        -- 优先使用API，失败时回退到本地解析
        providers = {
            "mason.providers.registry-api",
            "mason.providers.client",
        },

        -- GitHub相关配置
        github = {
            -- 下载GitHub资产的URL模板
            -- 占位符依次为：仓库名、版本、资产名
            download_url_template = "https://github.com/%s/releases/download/%s/%s",
        },

        -- pip相关配置
        pip = {
            -- 是否在安装包前升级pip
            upgrade_pip = false,

            -- pip安装时的额外参数（不建议随意修改）
            install_args = {},
        },

        -- UI界面配置
        ui = {
            -- 打开:Mason窗口时是否自动检查过时包
            check_outdated_packages_on_open = true,

            -- 窗口边框样式，默认使用Neovim的winborder设置
            -- 可选值："none", "single", "double", "rounded", "solid", "shadow"
            border = nil,

            -- 背景透明度（0-100，0完全不透明，100完全透明）
            backdrop = 60,

            -- 窗口宽度（可以是绝对值或屏幕百分比）
            width = 0.8,

            -- 窗口高度（可以是绝对值或屏幕百分比）
            height = 0.9,

            -- 图标配置
            icons = {
                package_installed = "✓",  -- 已安装包的图标
                package_pending = "➜",    -- 安装中/排队中的图标
                package_uninstalled = "✗" -- 未安装包的图标
            },

            -- 快捷键配置
            keymaps = {
                toggle_package_expand = "<CR>",       -- 展开/折叠包信息
                install_package = "i",                -- 安装当前选中包
                update_package = "u",                 -- 更新当前选中包
                check_package_version = "c",          -- 检查当前包版本
                update_all_packages = "U",            -- 更新所有已安装包
                check_outdated_packages = "C",        -- 检查所有过时包
                uninstall_package = "X",              -- 卸载当前选中包
                cancel_installation = "<C-c>",        -- 取消安装
                apply_language_filter = "<C-f>",      -- 应用语言筛选
                toggle_package_install_log = "<CR>",  -- 查看安装日志
                toggle_help = "g?",                   -- 显示帮助信息
            },
        },
    },
}

return M
