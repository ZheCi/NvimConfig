local opt = vim.opt
local global = vim.g

-- 关闭nvim自带的文件浏览
global.loaded_netrw = 1
global.loaded_netrwPlugin = 1

-- 折叠功能
opt.foldenable = true

-- 设置折叠级别为最大值99
opt.foldlevel = 99

-- 定义折叠行的填充字符为 "fold: "
opt.fillchars = "fold: "

-- 设置折叠方法为基于缩进的折叠 (拼写修正为 "indent")
opt.foldmethod = "manual"

-- 设置制表符显示的宽度为 4 个空格
opt.tabstop = 4

-- 设置自动缩进时使用的空格数为 4 个
opt.shiftwidth = 4

-- 设置插入模式下按下 Tab 键时插入或删除的空格数为 4 个
opt.softtabstop = 4

-- 启用 expandtab 选项，将 Tab 键转换为空格
opt.expandtab = true

--  在制定列显示竖线 
vim.opt.colorcolumn = "0"

-- 启用 smarttab 选项，根据上下文调整 Tab 键的行为
opt.smarttab = true

-- 智能缩进
opt.smartindent = true

-- 自动换行
opt.wrap = true

-- 智能换行，在适当的位置（如单词边界）进行换行
opt.linebreak = true

-- 搜索时实时预览
opt.incsearch = true

-- 搜索时忽略大小写
opt.ignorecase = true

-- 搜索包含大写时不忽略大小写  
opt.smartcase = true

-- 搜索高亮关闭
opt.hlsearch = false

-- 显示绝对行号
opt.number = true

-- 显示相对行号
opt.relativenumber = true 

-- 启用真色彩
opt.termguicolors = true

-- 显示标号列
opt.signcolumn = "yes"

-- 命令行高度 
opt.cmdheight = 0

-- 上下滚动边距行数
opt.scrolloff = 10

-- 补全菜单样式
opt.completeopt = "menuone,noinsert,noselect"

-- 缓冲区背景交换
opt.hidden = true

-- 禁止错误提示音
opt.errorbells = false

-- 禁用交换文件
opt.swapfile = false

-- 禁用备份文件
opt.backup = false

-- 设置备份文件存储目录
opt.undodir = vim.fn.expand("~/.vim/undodir")

-- 禁用持久化撤销
opt.undofile = false

-- 退格键可回到行首行尾
opt.backspace = "indent,eol,start"

-- 垂直分割窗口在右边打开  
opt.splitright = true

-- 水平分割窗口在下边打开
opt.splitbelow = true

-- 禁用自动切换工作目录
opt.autochdir = false

-- 将连接线-视为关键字的一部分
opt.iskeyword:append("-")

-- 视觉选择模式  
opt.selection = "exclusive"

-- 启用鼠标支持
opt.mouse = ""

-- 使用系统剪贴板  
opt.clipboard:append("unnamedplus")

-- 允许修改只读文件
opt.modifiable = true

-- 设置编码格式  
opt.encoding = "UTF-8"

-- 隐藏模式提示
opt.showmode = false

-- 高亮显示当前行
vim.opt.cursorline = true
