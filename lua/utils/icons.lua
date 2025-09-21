local M = {}

-- 1. 文件/文件夹基础图标（覆盖 nvim-tree 默认 glyphs）
M.file = {
  default = "", -- 默认文件图标
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

-- 4. gitsigns 图标, 主要用于git插件(gitsigns)
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
}

return M
