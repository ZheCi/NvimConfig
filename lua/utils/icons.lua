local M = {}

-- 1. 文件/文件夹基础图标（覆盖 nvim-tree 默认 glyphs）
M.file = {
    default = "", -- 默认文件图标
    symlink = "", -- 符号链接图标
}
M.folder = {
    default = "", -- 关闭的文件夹
    open = "", -- 打开的文件夹
    empty = "", -- 空文件夹
    empty_open = "", -- 打开的空文件夹
    symlink = "", -- 符号链接文件夹
    arrow_closed = "", -- 文件夹关闭时的箭头
    arrow_open = "", -- 文件夹打开时的箭头
} 

-- 2. Git 状态图标(主要用于文件浏览器)
M.git = {
    unstaged = "󰡅", -- 未暂存
    staged = "󰍕", -- 已暂存
    unmerged = "", -- 未合并
    renamed = "➜", -- 已重命名
    untracked = "★", -- 未跟踪
    deleted = "", -- 已删除
    ignored = "◌", -- 已忽略
}

-- 3. nvim-cmp 补全项类型图标
M.kind_icons = {
    Text = "",           -- 文本
    Function = "",       -- 函数
    Constructor = "",    -- 构造函数
    Variable = "",       -- 变量
    Interface = "",      -- 接口
    Module = "",         -- 模块
    Property = "",       -- 属性
    Unit = "塞",          -- 单位
    Enum = "",           -- 枚举
    Snippet = "",        -- 代码片段
    File = "",           -- 文件
    EnumMember = "",     -- 枚举成员
    Struct = "פּ",         -- 结构体
    Event = "",          -- 事件
    TypeParameter = "",  -- 类型参数
    Operator = "⊕",        -- 运算符
    Method = "ƒ",          -- 方法
    Field = "",           -- 字段
    Class = "𝓒",           -- 类
    Color = "🎨",          -- 颜色
    Reference = "",       -- 引用
    Folder = "📂",         -- 文件夹
    Constant = "π",        -- 常量
    Value = "📌",          -- 值
    Keyword = "🔑"        -- 键
}

-- 4. nvim-cmp 补全源图标
M.source_icons = {
    nvim_lsp = "",      -- LSP源
    luasnip = "",       -- LuaSnip代码片段
    buffer = "",        -- 缓冲区内容
    path = "",          -- 文件路径
    cmdline = " ",       -- 命令行
    git = "",           -- Git相关
    calc = "",          -- 计算器
    vsnip = "",         -- VSCode代码片段
    ultisnips = "",     -- UltiSnips代码片段
    snippy = ""         -- Snippy代码片段
}

-- 5. gitsigns 图标, 主要用于git插件(gitsigns)
M.gitsigns = {
    add = '┃',          -- 新增行
    change = '┃',       -- 修改行
    delete = '▁',       -- 删除行
    topdelete = '▔',    -- 顶部删除行
    changedelete = '~', -- 修改并删除行
    untracked = '┆',    -- 未跟踪行
}

-- 其他图标（如修改、隐藏文件）
M.misc = {
    modified = "●", -- 修改过的文件
    hidden = "󰜌", -- 隐藏文件
    bookmark = "󰆤", -- 书签
    ellipsis = "…", -- 省略号（用于长文本截断）
    error = "",   -- 错误
    warn = "",    -- 警告
    info = "",    -- 信息
    hint = "󰌵"     -- 提示
}

return M
