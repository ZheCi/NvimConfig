-- 定义键映射的全局函数
local keymap     = vim.keymap
local myFunction = require("utils.function")

-- 定义选项
local opts       = {
  noremap = true, -- 使用 noremap 方式映射
  silent = true,  -- 静默映射,不在命令行显示
}

-- vim 模式
-- "n" 表示普通模式,用于常规的键映射操作。
-- "v" 表示视觉(visual)模式,选中文本状态。
-- "i" 表示插入(insert)模式。
-- "c" 表示命令(command)模式,输入":"命令时。

-- --------------------------------------------------------------------------
-- 将<C-c> 映射为 <Esc>, 为了触发InsertLeave事件(自动切换输入法)
vim.keymap.set({ "n", "i", "v", "x", "o" }, "<C-c>", "<Esc>", opts)
-- 关闭当前窗格
keymap.set("n", "<C-S-d>", ":only<CR>", opts)
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- 禁用默认快捷键
keymap.set("n", "<C-o>", "<Nop>", opts)
keymap.set("n", "<C-i>", "<Nop>", opts)

-- --------------------------------------------------------------------------
-- Shift + Ctrl + h 映射到上一个缓冲区
-- keymap.set("n", "<S-C-h>", "<cmd>BufferLineCyclePrev<CR>", opts)
keymap.set("n", "<S-C-h>", "<cmd>BufferPrevious<CR>", opts)

-- Shift + Ctrl + l 映射到下一个缓冲区
-- keymap.set("n", "<S-C-l>", "<cmd>BufferLineCycleNext<CR>", opts)
keymap.set("n", "<S-C-l>", "<cmd>BufferNext<CR>", opts)

-- 将当前Buffer往前移动
keymap.set("n", "<S-A-h>", "<cmd>BufferMovePrevious<CR>", opts)

-- 将当前Buffer往后移动
keymap.set("n", "<S-A-l>", "<cmd>BufferMoveNext<CR>", opts)

-- Shift + Ctrl + q 关闭缓冲区
keymap.set("n", "<C-S-q>", "<cmd>BufferClose<CR>", opts)

-- 固定当前buffer
keymap.set("n", "<A-p>", "<cmd>BufferPin<CR>", opts)

-- 关闭当前窗口
keymap.set("n", "<leader>wc", myFunction.close_pane_and_buffer_if_unused, opts)
