local M = {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        -- 按键映射配置表（通常用于自动补全/代码提示插件，如 nvim-cmp，定义补全窗口的交互快捷键）
        keymap = { 
            -- 预设按键映射模式：'none' 表示不使用插件自带的默认映射，完全使用下方自定义配置
            preset = 'none',

            -- 【Ctrl+空格】组合键：补全文档相关操作（多状态切换）
            -- 作用：根据当前上下文切换行为，通常用于触发/控制补全文档的显示状态
            ['<c-Tab>'] = { 
                'show',               -- 1. 首次/默认：显示补全提示窗口（或文档说明）
                'show_documentation', -- 2. 再次按下：显示选中补全项的详细文档（如函数参数、说明）
                'hide_documentation'  -- 3. 第三次按下：隐藏已显示的文档（简化界面）
            },

            -- 【Ctrl+e】组合键：关闭补全窗口
            -- 作用：退出补全交互，恢复正常编辑状态
            ['<C-e>'] = { 
                'hide',     -- 1. 首次按下：隐藏补全提示窗口
                'fallback'  -- 2. 若窗口已隐藏/无法隐藏，则执行回退操作（通常是默认的 Ctrl+e 行为）
            },

            -- 【Ctrl+y】组合键：确认并接受补全项
            -- 作用：快速选中当前高亮的补全项并插入到代码中
            ['<C-cr>'] = { 
                'select_and_accept',  -- 1. 首次按下：选中当前高亮的补全项并确认插入
                'fallback'            -- 2. 若无可选补全项，则执行回退操作（默认的 Ctrl+y 行为）
            },

            -- 【上方向键】：选择上一个补全项
            -- 作用：在补全列表中向上导航，切换高亮的候选项
            ['<Up>'] = { 
                'select_prev',  -- 1. 补全窗口打开时：选中上一个候选项
                'fallback'      -- 2. 补全窗口未打开时：执行默认上方向键行为（光标上移）
            },

            -- 【下方向键】：选择下一个补全项
            -- 作用：在补全列表中向下导航，切换高亮的候选项
            ['<Down>'] = { 
                'select_next',  -- 1. 补全窗口打开时：选中下一个候选项
                'fallback'      -- 2. 补全窗口未打开时：执行默认下方向键行为（光标下移）
            },

            -- 【Ctrl+p】组合键：选择上一个补全项（与上方向键功能类似，适配习惯终端快捷键的用户）
            ['<C-k>'] = { 
                'select_prev',          -- 1. 补全窗口打开时：选中上一个候选项
                'fallback_to_mappings'  -- 2. 补全窗口未打开时：回退到原生 Ctrl+p 映射（通常是历史命令/文本粘贴）
            },

            -- 【Ctrl+n】组合键：选择下一个补全项（与下方向键功能类似，适配习惯终端快捷键的用户）
            ['<C-j>'] = { 
                'select_next',          -- 1. 补全窗口打开时：选中下一个候选项
                'fallback_to_mappings'  -- 2. 补全窗口未打开时：回退到原生 Ctrl+n 映射（通常是历史命令/文本粘贴）
            },

            -- 【Ctrl+b】组合键：向上滚动补全文档
            -- 作用：当补全项显示详细文档时，向上滚动文档内容（查看更多上方内容）
            ['<C-b>'] = { 
                'scroll_documentation_up',  -- 1. 文档打开时：向上滚动文档
                'fallback'                  -- 2. 文档未打开时：执行默认 Ctrl+b 行为（光标向前翻页）
            },

            -- 【Ctrl+f】组合键：向下滚动补全文档
            -- 作用：当补全项显示详细文档时，向下滚动文档内容（查看更多下方内容）
            ['<C-f>'] = { 
                'scroll_documentation_down',  -- 1. 文档打开时：向下滚动文档
                'fallback'                    -- 2. 文档未打开时：执行默认 Ctrl+f 行为（光标向后翻页）
            },

            -- 【Tab】键：代码片段向前导航
            -- 作用：在插入的代码片段（snippet）中，跳转到下一个编辑点（如占位符 ${1} -> ${2}）
            ['<Tab>'] = { 
                'snippet_forward',  -- 1. 存在代码片段时：跳转到下一个编辑点
                'fallback'          -- 2. 无代码片段时：执行默认 Tab 键行为（插入制表符/缩进）
            },

            -- 【Shift+Tab】组合键：代码片段向后导航
            -- 作用：在插入的代码片段中，跳转到上一个编辑点（如 ${2} -> ${1}）
            ['<S-Tab>'] = { 
                'snippet_backward',  -- 1. 存在代码片段时：跳转到上一个编辑点
                'fallback'           -- 2. 无代码片段时：执行默认 Shift+Tab 行为（减少缩进）
            },

            -- 【Ctrl+k】组合键：函数签名提示切换
            -- 作用：显示/隐藏当前函数的签名提示（参数列表、类型说明等）
            ['<C-k>'] = { 
                'show_signature',   -- 1. 首次按下：显示函数签名提示
                'hide_signature',   -- 2. 再次按下：隐藏已显示的签名提示
                'fallback'          -- 3. 无签名可显示时：执行默认 Ctrl+k 行为（通常是删除前一个单词）
            },
        },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
}

return M
