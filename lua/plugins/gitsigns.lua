-- utils/icons.lua 里需要定义 gitsigns 图标
local icons = require('utils.icons')

local M = {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = "BufReadPre", -- 打开文件时延迟加载插件，避免启动卡顿
}

M.config = function()
    local ok, gitsigns = pcall(require, 'gitsigns')
    if not ok then
        -- 安全处理，如果 gitsigns 没有被安装，不报错
        return
    end

    -- ===========================
    -- 检查当前缓冲区是否在 Git 仓库中
    -- ===========================
    local inside_git = false
    local status = vim.fn.systemlist('git rev-parse --is-inside-work-tree')
    if status[1] == 'true' then
        inside_git = true
    end

    gitsigns.setup({
        -- ===========================
        -- Git 符号配置
        -- ===========================
        signs = {
            add          = { text = icons.gitsigns.add },
            change       = { text = icons.gitsigns.change },
            delete       = { text = icons.gitsigns.delete },
            topdelete    = { text = icons.gitsigns.topdelete },
            changedelete = { text = icons.gitsigns.changedelete },
            untracked    = { text = icons.gitsigns.untracked },
        },

        signs_staged = {
            add          = { text = icons.gitsigns.add },
            change       = { text = icons.gitsigns.change },
            delete       = { text = icons.gitsigns.delete },
            topdelete    = { text = icons.gitsigns.topdelete },
            changedelete = { text = icons.gitsigns.changedelete },
        },
        signs_staged_enable = true,

        -- ===========================
        -- 显示相关配置
        -- ===========================
        signcolumn     = true,
        numhl          = false,
        linehl         = false,
        culhl          = false,

        -- ===========================
        -- Git 仓库监控
        -- ===========================
        watch_gitdir = {
            enable       = true,
            follow_files = true,
        },

        -- ===========================
        -- 性能优化
        -- ===========================
        max_file_length = 40000,
        update_debounce = 100,

        -- ===========================
        -- 当前行 Blame 配置
        -- ===========================
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text         = true,
            virt_text_pos     = 'eol',
            delay             = 1000,
            ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author> · <author_time:%Y-%m-%d> · <summary>',

        -- ===========================
        -- 预览窗口配置
        -- ===========================
        preview_config = {
            style    = 'minimal',
            relative = 'cursor',
            row      = 0,
            col      = 1,
        },

        -- ===========================
        -- 核心设置
        -- ===========================
        auto_attach         = inside_git, -- 只有 Git 仓库才自动附加
        attach_to_untracked = false,
        word_diff           = false,
        diff_opts = { algorithm = 'myers' },

        -- ===========================
        -- 缓冲区快捷键配置
        -- ===========================
        on_attach = function(bufnr)
            if not inside_git then return end -- 非 Git 文件不绑定快捷键

            local gs = package.loaded.gitsigns

            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Gitsigns: ' .. desc })
            end

            -- 导航变更块
            map('n', ']g', function()
                if vim.wo.diff then return ']g' end
                vim.schedule(function() gs.nav_hunk('next') end)
                return '<Ignore>'
            end, '跳转到下一个变更块')

            map('n', '[g', function()
                if vim.wo.diff then return '[g' end
                vim.schedule(function() gs.nav_hunk('prev') end)
                return '<Ignore>'
            end, '跳转到上一个变更块')

            -- 操作变更块
            map('n', '<leader>gs', gs.stage_hunk, '暂存当前变更块')
            map('n', '<leader>gr', gs.reset_hunk, '重置当前变更块')
            map('v', '<leader>gs', function()
                gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, '可视模式：暂存选中变更块')
            map('v', '<leader>gr', function()
                gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, '可视模式：重置选中变更块')

            -- 全缓冲区操作
            map('n', '<leader>gS', gs.stage_buffer, '暂存缓冲区所有变更')
            map('n', '<leader>gR', gs.reset_buffer, '重置缓冲区所有变更')
            map('n', '<leader>gu', gs.undo_stage_hunk, '撤销上一次暂存')

            -- 预览与对比
            map('n', '<leader>gp', gs.preview_hunk, '预览当前变更块')
            map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, '显示完整 Blame 信息')
            map('n', '<leader>gd', gs.diffthis, '与索引 diff')
            map('n', '<leader>gD', function() gs.diffthis('~') end, '与上一次提交 diff')

            -- 功能切换
            map('n', '<leader>gtb', gs.toggle_current_line_blame, '切换行尾 Blame 显示')
            map('n', '<leader>gtw', gs.toggle_word_diff, '切换单词级 diff')
            map('n', '<leader>gts', gs.toggle_signs, '切换符号列')
            map('n', '<leader>gc', ':only<CR>', '关闭其他窗格')

            -- 文本对象
            map({ 'o', 'x' }, 'ih', gs.select_hunk, '选中当前变更块')
        end,
    })
end

return M
