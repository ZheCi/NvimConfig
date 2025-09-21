local M = {
    'romgrk/barbar.nvim', -- 插件名称：barbar.nvim（核心功能：缓冲区标签栏）
    lazy = true, -- 懒加载开关：true 表示不随 Neovim 启动加载，仅在触发条件时加载
    event = "VeryLazy", -- 懒加载触发事件："VeryLazy" 表示 Neovim 完全启动后再加载（优化启动速度）
    dependencies = { -- 插件依赖：加载当前插件前需先加载的其他插件
        'nvim-tree/nvim-web-devicons', -- 依赖功能：提供文件类型对应的图标（如 .lua 文件显示 Lua 图标）和默认颜色
    },
    init = function() -- 插件加载前执行的初始化函数（优先级高于 config）
        -- 关闭 barbar 的自动配置功能：避免插件默认配置与自定义配置冲突
        vim.g.barbar_auto_setup = false 
        -- 清空 bufferline 残留配置：barbar 基于 bufferline 开发，兼容部分 bufferline 配置，清空可防止旧配置干扰
        vim.g.bufferline = { highlights = {} } 
    end,
}

-- 插件加载后执行的核心配置函数（接收 opts 参数，即下方 M.opts 的配置）
M.config = function(_, opts)
    -- 初始化 barbar 插件，将 opts 中的配置应用到插件
    require('barbar').setup(opts)

    -- 【辅助函数】安全获取主题中指定高亮组的颜色属性
    -- 参数：group（高亮组名称，如 'Normal' 表示正常文本区域）、attr（颜色属性，'fg' 前景色/'bg' 背景色）
    -- 作用：用 pcall 包裹避免高亮组不存在时抛出错误，返回颜色值或 nil（容错性处理）
    local function get_hl_color(group, attr)
        -- vim.api.nvim_get_hl(0, ...)：获取当前窗口（0 表示当前窗口）的高亮组信息
        -- link = false：禁止跟随高亮组的链接（确保获取的是原始颜色，而非继承的颜色）
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        -- 若获取成功则返回对应颜色属性，失败则返回 nil
        return ok and hl[attr] or nil
    end

    -- 【核心函数】自适应主题的高亮设置（控制标签栏所有元素的颜色和样式）
    local function set_highlights()
        -- -------------------------- 1. 基础颜色提取（从当前主题动态获取，实现主题适配） --------------------------
        -- 正常文本区域的背景色（默认兜底值 #1e1e1e，深灰色，适配多数深色主题）
        local normal_bg = get_hl_color('Normal', 'bg') or '#1e1e1e'
        -- 正常文本区域的前景色（默认白色 #ffffff，作为激活标签的文件名颜色，确保醒目）
        local normal_fg = get_hl_color('Normal', 'fg') or '#ffffff' 
        -- 未激活标签的背景色（优先用主题 TabLine 高亮组背景，无则复用 normal_bg，视觉统一）
        local tabline_bg = get_hl_color('TabLine', 'bg') or normal_bg
        -- 未激活标签的前景色（优先用主题 TabLine 高亮组前景，兜底 #bbbbbb 浅灰色，弱化显示）
        local tabline_fg = get_hl_color('TabLine', 'fg') or '#bbbbbb'
        -- 激活标签的背景色（优先用主题 CursorLine 高亮组背景，即光标所在行的背景色，突出当前标签）
        local cursorline_bg = get_hl_color('CursorLine', 'bg') or '#3b4252'
        -- 缓冲区索引的颜色（优先用主题 Comment 高亮组颜色，即注释色，避免索引抢焦点）
        local comment_fg = get_hl_color('Comment', 'fg') or '#585b70' 

        -- 未保存修改状态的提示色（优先用主题 WarningMsg 高亮组颜色，即警告色，直观提示未保存）
        local modified_fg = get_hl_color('WarningMsg', 'fg') or '#e0af68' 
        -- 备选方案：若主题有专门的诊断警告色，可替换为 DiagnosticWarn（更贴合代码诊断场景）
        -- local modified_fg = get_hl_color('DiagnosticWarn', 'fg') or '#e0af68'

        -- Git 状态颜色（与 GitSigns 插件颜色保持一致，确保整个编辑器 Git 视觉统一）
        local git_added_fg = get_hl_color('GitSignsAdd', 'fg') or '#a6e3a1' -- 新增文件：绿色
        local git_changed_fg = get_hl_color('GitSignsChange', 'fg') or '#94e2d5' -- 修改文件：青色
        local git_deleted_fg = get_hl_color('GitSignsDelete', 'fg') or '#f38ba8' -- 删除文件：粉色

        -- -------------------------- 2. 侧边栏偏移文字高亮（解决 NvimTree 与标签栏重叠问题） --------------------------
        -- 作用：当 NvimTree（文件浏览器）打开时，标签栏会显示一段偏移文本，避免标签被挤压
        vim.api.nvim_set_hl(0, 'BufferOffset', {
            fg = get_hl_color('Identifier', 'fg') or '#89b4fa', -- 文本色：优先用标识符颜色，兜底蓝色
            bg = tabline_bg, -- 背景色：与未激活标签背景一致，视觉连贯
            bold = true -- 文字加粗：突出偏移文本，明确分隔区域
        })

        -- -------------------------- 3. 未保存修改状态高亮（提示文件未保存） --------------------------
        -- 当前激活标签的未保存修改（如 ● 图标）：警告色+激活标签背景，突出提示
        vim.api.nvim_set_hl(0, 'BufferCurrentMod', {
            fg = modified_fg, -- 前景色：未保存提示色
            bg = cursorline_bg, -- 背景色：激活标签背景
            bold = true -- 加粗：增强视觉提醒
        })
        -- 未激活标签的未保存修改：警告色+未激活标签背景，不抢焦点但仍提示
        vim.api.nvim_set_hl(0, 'BufferInactiveMod', {
            fg = modified_fg,
            bg = tabline_bg
        })
        -- 可见但未激活标签的未保存修改（如分屏中显示的标签）：同未激活标签，保持一致
        vim.api.nvim_set_hl(0, 'BufferVisibleMod', {
            fg = modified_fg,
            bg = tabline_bg
        })

        -- -------------------------- 4. Git 状态高亮（显示文件的 Git 变更） --------------------------
        -- 激活标签的 Git 新增状态（+ 图标）：绿色+激活背景
        vim.api.nvim_set_hl(0, 'BufferCurrentADDED', { fg = git_added_fg, bg = cursorline_bg })
        -- 激活标签的 Git 修改状态（~ 图标）：青色+激活背景
        vim.api.nvim_set_hl(0, 'BufferCurrentCHANGED', { fg = git_changed_fg, bg = cursorline_bg })
        -- 激活标签的 Git 删除状态（- 图标）：粉色+激活背景
        vim.api.nvim_set_hl(0, 'BufferCurrentDELETED', { fg = git_deleted_fg, bg = cursorline_bg })

        -- 未激活标签的 Git 新增状态：绿色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferInactiveADDED', { fg = git_added_fg, bg = tabline_bg })
        -- 未激活标签的 Git 修改状态：青色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferInactiveCHANGED', { fg = git_changed_fg, bg = tabline_bg })
        -- 未激活标签的 Git 删除状态：粉色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferInactiveDELETED', { fg = git_deleted_fg, bg = tabline_bg })

        -- 可见但未激活标签的 Git 新增状态：绿色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferVisibleADDED', { fg = git_added_fg, bg = tabline_bg })
        -- 可见但未激活标签的 Git 修改状态：青色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferVisibleCHANGED', { fg = git_changed_fg, bg = tabline_bg })
        -- 可见但未激活标签的 Git 删除状态：粉色+未激活背景
        vim.api.nvim_set_hl(0, 'BufferVisibleDELETED', { fg = git_deleted_fg, bg = tabline_bg })

        -- -------------------------- 5. 缓冲区索引高亮（标签前的数字，如 1、2、3） --------------------------
        -- 激活标签的索引：注释色+激活背景，弱化索引，突出文件名
        vim.api.nvim_set_hl(0, 'BufferCurrentIndex', {
            fg = comment_fg,
            bg = cursorline_bg,
            bold = true -- 轻微加粗，确保索引可辨
        })
        -- 未激活标签的索引：注释色+未激活背景，进一步弱化
        vim.api.nvim_set_hl(0, 'BufferInactiveIndex', {
            fg = comment_fg,
            bg = tabline_bg
        })

        -- -------------------------- 6. 基础缓冲区样式（标签的核心视觉效果） --------------------------
        -- 激活标签（当前编辑的标签）：正常文本色+光标行背景，加粗突出
        vim.api.nvim_set_hl(0, 'BufferCurrent', {
            fg = normal_fg, -- 文件名颜色：与编辑区文本色一致，视觉统一
            bg = cursorline_bg, -- 背景色：与光标行背景一致，强化“当前”焦点
            bold = true -- 加粗：明确区分激活/未激活标签
        })
        -- 未激活标签（未选中且不可见的标签）：浅灰色+未激活背景，弱化显示
        vim.api.nvim_set_hl(0, 'BufferInactive', {
            fg = tabline_fg,
            bg = tabline_bg
        })
        -- 可见但未激活标签（分屏中显示的非当前标签）：正常文本色+未激活背景，既可见又不抢焦点
        vim.api.nvim_set_hl(0, 'BufferVisible', {
            fg = normal_fg, -- 文件名颜色：保持清晰，方便分屏时识别
            bg = tabline_bg -- 背景色：与未激活标签一致，区分“可见”与“激活”
        })

        -- -------------------------- 7. 标签分隔符样式（标签之间的竖线，区分不同标签） --------------------------
        -- 激活标签的分隔符：未保存提示色+激活背景，强化激活标签的边界
        vim.api.nvim_set_hl(0, 'BufferCurrentSeparator', {
            fg = modified_fg, -- 复用未保存色，减少颜色种类，保持简洁
            bg = cursorline_bg
        })
        -- 未激活标签的分隔符：注释色+未激活背景，弱化分隔符，不干扰视觉
        vim.api.nvim_set_hl(0, 'BufferInactiveSeparator', {
            fg = comment_fg,
            bg = tabline_bg
        })
    end

    -- -------------------------- 自动命令：主题切换时更新高亮 --------------------------
    -- 作用：当执行 :colorscheme 切换主题时，自动重新执行 set_highlights()，确保标签栏颜色与新主题适配
    vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*', -- 匹配所有主题（无论切换到哪个主题，都触发）
        callback = set_highlights -- 主题切换后执行的函数：重新设置所有高亮
    })

    -- -------------------------- 初始化高亮 --------------------------
    -- 插件加载完成后立即执行一次 set_highlights()，确保初始状态下标签栏颜色正确
    set_highlights()
end

-- -------------------------- barbar 插件的具体功能选项 --------------------------
-- 这些选项会传递给 require('barbar').setup(opts)，控制插件的行为逻辑
M.opts = {
    animation = false, -- 关闭标签切换动画：减少性能消耗，提升操作流畅度
    clickable = true, -- 允许鼠标点击标签切换缓冲区：支持鼠标操作，适合习惯图形界面的用户
    tabpages = true, -- 显示 TabPage 标签：支持 Neovim 的多标签页功能（:tabnew 新建标签页）
    insert_at_end = false, -- 新缓冲区不插入到标签栏末尾：默认插入到当前标签后，符合操作直觉
    insert_at_start = false, -- 新缓冲区不插入到标签栏开头：同上，保持操作一致性

    -- 侧边栏偏移配置（针对 NvimTree 等侧边栏插件的适配）
    sidebar_filetypes = {
        NvimTree = { -- 针对 NvimTree（文件浏览器）的偏移设置
            event = 'BufWinLeave', -- 触发时机：当 NvimTree 窗口关闭时
            text = '======= 󰙅 文件浏览器 󰙅 ======', -- 偏移区域显示的文本：明确标识侧边栏区域
            align = 'center', -- 文本对齐方式：居中显示
            hl = 'BufferOffset' -- 文本高亮组：使用前面定义的 BufferOffset 样式
        }
    },

    -- 标签尺寸控制（避免标签过长或过短，保持视觉整洁）
    maximum_length = 30, -- 标签最大长度：超过 30 字符会截断（避免标签过宽挤压其他标签）
    minimum_length = 0, -- 标签最小长度：允许标签根据内容自适应（0 表示无最小限制）
    maximum_padding = 4, -- 标签内最大内边距：最多添加 4 个空格（避免标签内空白过多）
    minimum_padding = 1, -- 标签内最小内边距：至少添加 1 个空格（避免文字紧贴标签边缘）

    -- 标签栏图标配置（控制各类图标的显示逻辑和样式）
    icons = {
        buffer_index = true, -- 显示缓冲区索引（标签前的数字，如 1、2）：方便快速定位标签
        button = '', -- 标签关闭按钮的图标：使用 Nerd Font 图标，视觉更友好

        -- Git 状态图标（显示文件的 Git 变更，如新增/修改/删除）
        gitsigns = {
            added = { enabled = true, icon = '+' }, -- 新增文件：显示 '+' 图标
            changed = { enabled = true, icon = '~' }, -- 修改文件：显示 '~' 图标
            deleted = { enabled = true, icon = '-' } -- 删除文件：显示 '-' 图标
        },

        -- 未保存修改的图标（标签右上角的提示，标识文件未保存）
        modified = { button = '●' }, -- 图标为实心圆点，使用前面定义的 BufferXXXMod 高亮组控制颜色

        -- 文件类型图标配置（控制文件类型图标的显示）
        filetype = {
            custom_colors = false, -- 关闭自定义颜色：使用 nvim-web-devicons 的默认颜色（如 .lua 蓝色、.py 绿色）
            enabled = true -- 启用文件类型图标：显示每个标签对应的文件类型图标（增强辨识度）
        },

        -- 标签分隔符（标签之间的竖线）
        separator = {
            left = '│', -- 左侧分隔符：竖线 '│'，区分不同标签
            right = '' -- 右侧无分隔符：避免标签右侧多余线条，保持简洁
        },

        -- 固定标签的图标（将标签固定在标签栏，不被关闭或排序）
        pinned = { button = '📍', filename = true }, -- 按钮图标为定位针，显示固定标签的文件名
        alternate = { filetype = { enabled = false } }, -- 关闭交替文件图标：避免不必要的图标干扰
        current = { buffer_index = true }, -- 激活标签显示索引：与 buffer_index = true 一致，确保激活标签也显示数字
        inactive = { button = '×' }, -- 未激活标签的关闭按钮：使用 '×' 图标，与激活标签区分
        visible = { modified = { buffer_number = false } } -- 可见标签的未保存状态不显示缓冲区编号：避免信息冗余
    }
}

return M
