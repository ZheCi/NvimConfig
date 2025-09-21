local M = {
    'romgrk/barbar.nvim',
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    init = function() 
        vim.g.barbar_auto_setup = false 
        vim.g.bufferline = { highlights = {} } -- 清除冲突配置
    end,
}

M.config = function(_, opts)
    require('barbar').setup(opts)

    -- 安全获取高亮颜色的辅助函数
    local function get_hl_color(group, attr)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        return ok and hl[attr] or nil
    end

    -- 自适应主题的高亮设置
    local function set_highlights()
        -- 基础颜色提取
        local normal_bg = get_hl_color('Normal', 'bg') or '#1e1e1e'
        local normal_fg = get_hl_color('Normal', 'fg') or '#ffffff' -- 文件名默认颜色
        local tabline_bg = get_hl_color('TabLine', 'bg') or normal_bg
        local tabline_fg = get_hl_color('TabLine', 'fg') or '#bbbbbb'
        local cursorline_bg = get_hl_color('CursorLine', 'bg') or '#3b4252'
        local comment_fg = get_hl_color('Comment', 'fg') or '#585b70' -- buffer_index 颜色（注释色）

        -- 核心：为「未保存修改」状态设置专用颜色（与文件名协调，与 buffer_index 区分）
        local modified_fg = get_hl_color('WarningMsg', 'fg') or '#e0af68' -- 警告色（适合未保存提示）
        -- 备选：如果主题有专门的修改色，可替换为 DiagnosticWarn 等
        -- local modified_fg = get_hl_color('DiagnosticWarn', 'fg') or '#e0af68'

        -- Git 状态颜色（与系统 GitSigns 保持一致）
        local git_added_fg = get_hl_color('GitSignsAdd', 'fg') or '#a6e3a1'
        local git_changed_fg = get_hl_color('GitSignsChange', 'fg') or '#94e2d5'
        local git_deleted_fg = get_hl_color('GitSignsDelete', 'fg') or '#f38ba8'

        -- 1. 侧边栏偏移文字高亮（解决不可见问题）
        vim.api.nvim_set_hl(0, 'BufferOffset', {
            fg = get_hl_color('Identifier', 'fg') or '#89b4fa',
            bg = tabline_bg,
            bold = true
        })

        -- 2. 未保存修改状态高亮（重点修复）
        -- 当前选中缓冲区的未保存修改
        vim.api.nvim_set_hl(0, 'BufferCurrentMod', {
            fg = modified_fg, -- 警告色（与文件名 normal_fg 区分）
            bg = cursorline_bg,
            bold = true
        })
        -- 非活动缓冲区的未保存修改
        vim.api.nvim_set_hl(0, 'BufferInactiveMod', {
            fg = modified_fg,
            bg = tabline_bg
        })
        -- 可见但未选中缓冲区的未保存修改
        vim.api.nvim_set_hl(0, 'BufferVisibleMod', {
            fg = modified_fg,
            bg = tabline_bg
        })

        -- 3. Git 状态高亮（与文件名协调）
        -- 当前缓冲区 Git 状态
        vim.api.nvim_set_hl(0, 'BufferCurrentADDED', { fg = git_added_fg, bg = cursorline_bg })
        vim.api.nvim_set_hl(0, 'BufferCurrentCHANGED', { fg = git_changed_fg, bg = cursorline_bg })
        vim.api.nvim_set_hl(0, 'BufferCurrentDELETED', { fg = git_deleted_fg, bg = cursorline_bg })
        -- 非活动缓冲区 Git 状态
        vim.api.nvim_set_hl(0, 'BufferInactiveADDED', { fg = git_added_fg, bg = tabline_bg })
        vim.api.nvim_set_hl(0, 'BufferInactiveCHANGED', { fg = git_changed_fg, bg = tabline_bg })
        vim.api.nvim_set_hl(0, 'BufferInactiveDELETED', { fg = git_deleted_fg, bg = tabline_bg })
        -- 可见缓冲区 Git 状态
        vim.api.nvim_set_hl(0, 'BufferVisibleADDED', { fg = git_added_fg, bg = tabline_bg })
        vim.api.nvim_set_hl(0, 'BufferVisibleCHANGED', { fg = git_changed_fg, bg = tabline_bg })
        vim.api.nvim_set_hl(0, 'BufferVisibleDELETED', { fg = git_deleted_fg, bg = tabline_bg })

        -- 4. 缓冲区索引（与修改状态颜色区分）
        vim.api.nvim_set_hl(0, 'BufferCurrentIndex', {
            fg = comment_fg, -- 注释色（与 modified_fg 不同）
            bg = cursorline_bg,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'BufferInactiveIndex', {
            fg = comment_fg,
            bg = tabline_bg
        })

        -- 5. 基础缓冲区样式
        vim.api.nvim_set_hl(0, 'BufferCurrent', {
            fg = normal_fg, -- 文件名颜色
            bg = cursorline_bg,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'BufferInactive', {
            fg = tabline_fg,
            bg = tabline_bg
        })
        vim.api.nvim_set_hl(0, 'BufferVisible', {
            fg = normal_fg, -- 文件名颜色
            bg = tabline_bg
        })

        -- 6. 分隔符样式
        vim.api.nvim_set_hl(0, 'BufferCurrentSeparator', {
            fg = modified_fg, -- 复用修改色作为分隔符强调
            bg = cursorline_bg
        })
        vim.api.nvim_set_hl(0, 'BufferInactiveSeparator', {
            fg = comment_fg,
            bg = tabline_bg
        })
    end

    -- 主题切换时自动更新高亮
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = set_highlights
    })

    -- 初始化时设置一次
    set_highlights()
end

M.opts = {
    animation = false,
    clickable = true,
    tabpages = true,
    insert_at_end = false,
    insert_at_start = false,

    -- 侧边栏偏移配置（关联自定义高亮）
    sidebar_filetypes = {
        NvimTree = {
            event = 'BufWinLeave',
            text = '======= 󰙅 文件浏览器 󰙅 ======',
            align = 'center',
            hl = 'BufferOffset' -- 应用专用高亮
        }
    },

    maximum_length = 30,
    minimum_length = 0,
    maximum_padding = 4,
    minimum_padding = 1,

    icons = {
        buffer_index = true, -- 显示缓冲区索引
        button = '',
        -- Git 状态图标
        gitsigns = {
            added = { enabled = true, icon = '+' },
            changed = { enabled = true, icon = '~' },
            deleted = { enabled = true, icon = '-' }
        },
        -- 未保存修改的图标（使用 ● 作为提示）
        modified = { button = '●' }, -- 该图标会使用上面配置的 BufferXXXMod 高亮
        filetype = {
            custom_colors = false,
            enabled = true
        },
        separator = {
            left = '│',
            right = ''
        },
        pinned = { button = '📍', filename = true },
        alternate = { filetype = { enabled = false } },
        current = { buffer_index = true },
        inactive = { button = '×' },
        visible = { modified = { buffer_number = false } }
    }
}

return M
