local M = {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,

    dependencies = {
        "nvim-telescope/telescope.nvim", -- 添加 Telescope 依赖
        "nvim-lua/plenary.nvim",         -- Telescope 核心依赖
    },

    config = function()
        local github_theme = require("github-theme")

        -- ================== GitHub 主题配置 ==================
        github_theme.setup({
            options = {
                compile_file_suffix = "_compiled",
                compile_path = vim.fn.stdpath("cache") .. "/github-theme",
                hide_end_of_buffer = true,
                hide_nc_statusline = true,
                transparent = false,
                terminal_colors = true,
                dim_inactive = false,
                module_default = true,
                styles = {
                    comments = "italic",
                    functions = "bold",
                    keywords = "NONE",
                    variables = "NONE",
                    conditionals = "NONE",
                    constants = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                },
                inverse = { match_paren = false, visual = false, search = false },
                darken = { floats = true, sidebars = { enable = true, list = { "nvimtree", "terminal" } } },
                modules = {
                    cmp = true,
                    coc = { enable = true, background = true },
                    dapui = true,
                    gitsigns = true,
                    indent_blankline = true,
                    lsp_semantic_tokens = true,
                    native_lsp = { enable = true, background = true },
                    neotree = true,
                    telescope = true,
                    treesitter = true,
                    whichkey = true,
                },
            },
        })

        -- 默认加载主题
        vim.cmd.colorscheme("github_dark")

        -- ================== Telescope 主题选择功能 ==================
        local telescope = require("telescope.builtin")
        local themes = { 
            "github_dark", 
            "github_light", 
            "github_dark_dimmed",
            "github_dark_default",
            "github_light_default",
            "github_dark_high_contrast",
            "github_light_high_contrast",
            "github_dark_colorblind",
            "github_light_colorblind",
            "github_dark_tritanopia",
            "github_light_tritanopia"
        }

        -- 定义函数，通过 Telescope 选择主题
        function _G.SelectThemeWithTelescope()
            local opts = {
                prompt_title = "Select Neovim Theme",
                finder = require("telescope.finders").new_table {
                    results = themes
                },
                sorter = require("telescope.config").values.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    local actions = require("telescope.actions")
                    local action_state = require("telescope.actions.state")

                    -- 回车选择主题
                    map("i", "<CR>", function()
                        local selection = action_state.get_selected_entry()
                        vim.cmd.colorscheme(selection[1])  -- 切换主题
                        actions.close(prompt_bufnr)
                    end)
                    map("n", "<CR>", function()
                        local selection = action_state.get_selected_entry()
                        vim.cmd.colorscheme(selection[1])
                        actions.close(prompt_bufnr)
                    end)
                    return true
                end,
            }

            require("telescope.pickers").new({}, opts):find()
        end

        -- 可选：绑定快捷键，比如 <leader>ct 调出主题选择
        vim.keymap.set("n", "<leader>st", "<cmd>lua SelectThemeWithTelescope()<CR>", { noremap = true, silent = true })
    end,
}

return M
