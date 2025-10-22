-- InsertLeave 事件无法通过C-c触发， 只能通过Esc、C-o触发
-- 离开插入模式时, 切换输入法为英文
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    pattern = { "*" },
    callback = function()
        -- 可通过fcitx5-remote -n查看当前输入法模式的名称
        vim.fn.system('fcitx5-remote -s keyboard-us')
    end,
})
