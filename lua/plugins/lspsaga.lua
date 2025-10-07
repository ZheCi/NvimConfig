local lspsaga_plugin = {
    "glepnir/lspsaga.nvim",
    event = 'LspAttach',
    -- event = "VeryLazy",
    config = function()
        require("lspsaga").setup({
            -- keybinds for navigation in lspsaga window
            move_in_saga = { prev = "<C-k>", next = "<C-j>" },
            -- use enter to open file with finder
            finder_action_keys = {
                open = "<CR>",
            },
            -- use enter to open file with definition preview
            definition_action_keys = {
                edit = "<CR>",
            },
            finder = {
                keys = {
                    tabe = 't',      -- 在新的标签页打开
                    split = 's',     -- 水平打开
                    vsplit = 'v',    -- 垂直打开
                    quit = 'q',      -- 退出
                    close = '<C-C>'  -- 关闭
                },
                left_width = 0.3,
                right_width = 0.7,
                layout = 'float',    -- 'normal'
            }
        })
    end,
}

return lspsaga_plugin
