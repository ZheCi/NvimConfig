---@diagnostic disable: undefined-global, undefined-field, unused-local
--------------------------------------------------------------------------------
-- 插件: nvim-dap 调试系统（含 UI、虚拟文本、Telescope 集成等）
-- 功能增强:
--   ① 调试界面布局优化（右侧+底部）
--   ② 调试时禁止编辑源代码（防止误操作）
--   ③ 自动启用/恢复鼠标支持
--   ④ 自动适配布局、符号高亮、美观提示
--------------------------------------------------------------------------------
-- 关闭dap的函数, dd对cppdbg无效, 所以创建这个函数用适配
-- 关闭 DAP 的安全终止函数（兼容 cppdbg / codelldb）
local function safe_terminate()
    local dap = require("dap")
    local dapui = require("dapui")

    -- 获取当前会话
    local session = dap.session()

    if session then
        -- 尝试断开（cppdbg 需要 terminateDebuggee）
        local ok1 = pcall(function()
            dap.disconnect({ terminateDebuggee = true })
        end)

        -- 若断开失败，再尝试 terminate（适配 codelldb）
        local ok2 = pcall(dap.terminate)

        -- 若仍然有活动 session，则强制关闭
        vim.defer_fn(function()
            if dap.session() then
                pcall(function() dap.disconnect({ terminateDebuggee = true }) end)
                pcall(dap.close) -- 强制关闭会话
            end
            dapui.close()
            dap.repl.close()

            -- 🚀 强制触发 unlock_edit（防止 cppdbg 不触发事件）
            if package.loaded["dap"] then
                local listeners = require("dap").listeners
                if listeners and listeners.after and listeners.after.event_exited
                    and listeners.after.event_exited["unlock_edit"] then
                    listeners.after.event_exited["unlock_edit"]()
                end
            end

            vim.notify("🛑 调试已安全终止（强制）", vim.log.levels.INFO)
        end, 200)
    else
        dapui.close()
        vim.notify("⚠️ 当前无活动调试会话", vim.log.levels.WARN)
    end
end

local nvim_dap_ui_opts = {
    ---------------------------------------------------------------------------
    -- 🧱 布局配置
    ---------------------------------------------------------------------------
    layouts = {
        -- ▶ 右侧布局：展示调试信息（变量作用域、断点、堆栈、监视）
        {
            elements = {
                { id = "scopes",      size = 0.3 }, -- 作用域信息
                { id = "breakpoints", size = 0.2 }, -- 断点列表
                { id = "stacks",      size = 0.3 }, -- 调用堆栈
                { id = "watches",     size = 0.2 }, -- 监视变量
            },
            size = 0.3,                             -- 占编辑器宽度的 30%
            position = "right",                     -- 右侧
            resize_mode = "fixed"                   -- 固定大小
        },
        -- ▶ 底部布局：展示 REPL 与 控制台
        {
            elements = {
                { id = "repl", size = 0.6, min_height = 10 }, -- 交互式终端
                { id = "console", size = 0.4 }                -- 输出控制台
            },
            size = 0.25,                                      -- 占总高度的 25%
            position = "bottom",                              -- 底部
            resize_mode = "flexible"                          -- 灵活调整
        }
    },

    ---------------------------------------------------------------------------
    -- 🎮 控制栏按钮
    ---------------------------------------------------------------------------
    controls = {
        enabled = true,
        icons = {
            disconnect = " ",
            pause = " ",
            play = " ",
            run_last = " ",
            step_back = " ",
            step_into = " ",
            step_out = " ",
            step_over = " ",
            terminate = ""
        }
    },

    ---------------------------------------------------------------------------
    -- 🪟 浮动窗口样式
    ---------------------------------------------------------------------------
    floating = {
        border = "rounded",  -- 圆角边框
        relative = "editor", -- 相对整个编辑器
        width_ratio = 0.6,   -- 宽度占比
        height_ratio = 0.6,  -- 高度占比
        persist_size = true  -- 保持上次窗口尺寸
    }
}

--------------------------------------------------------------------------------
-- 主插件配置表
--------------------------------------------------------------------------------
local nvim_dap = {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "nvim-telescope/telescope-dap.nvim",
    },

    ---------------------------------------------------------------------------
    -- ⌨️ 快捷键定义
    ---------------------------------------------------------------------------
    keys = {
        { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "设置/删除断点" },
        { "<Leader>dr", function() require("telescope").extensions.dap.configurations() end, desc = "选择调试配置" },
        {
            "<Leader>dc",
            function()
                local dap = require("dap"); if dap.session() then dap.continue() end
            end,
            desc = "继续运行"
        },
        { "<Leader>dj", function() require("dap").step_over() end, desc = "单步调试" },
        { "<Leader>dn", function() require("dap").step_into() end, desc = "步入函数" },
        { "<Leader>dk", function() require("dap").step_out() end, desc = "步出函数" },
        { "<Leader>dJ", function() require("dap").down() end, desc = "向下堆栈" },
        { "<Leader>dK", function() require("dap").up() end, desc = "向上堆栈" },
        { "<Leader>dd", function() safe_terminate() end, desc = "终止调试（安全）" },
    },

    ---------------------------------------------------------------------------
    -- 🧠 核心配置逻辑
    ---------------------------------------------------------------------------
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- 记录启动时的鼠标配置（防止调试结束后丢失原设置）
        local default_mouse = vim.opt.mouse:get()

        -----------------------------------------------------------------------
        -- 🔒 调试期间禁止修改源文件
        -----------------------------------------------------------------------
        local code_filetypes = { c = true, cpp = true, rust = true, go = true, python = true, lua = true }
        local debugging_active = false
        local group = vim.api.nvim_create_augroup("DAP_NoEditDuringDebug", { clear = true })
        local original_keymaps = {}

        -- 需被锁定的按键（常见的编辑操作）
        local blocked_keys = {
            "d ", "dj", "dk", "dd", "cc", "yy", "p", "P", "o", "O", "r", "R", "x", "X", "s", "S", "J", "C", "D"
        }

        -- 判断是否为代码文件（仅这些文件被保护）
        local function is_code_file(bufnr)
            return code_filetypes[vim.bo[bufnr].filetype] or false
        end

        -- 锁定编辑按键
        local function lock_keymaps()
            for _, key in ipairs(blocked_keys) do
                local existing = vim.fn.maparg(key, "n", false, true)
                if existing and existing.rhs and existing.rhs ~= "" then
                    original_keymaps[key] = existing
                end

                vim.keymap.set("n", key, function()
                    if debugging_active then
                        vim.notify("⚠️ 调试中禁止修改源代码（键：" .. key .. "）", vim.log.levels.WARN)
                    else
                        -- 若解锁后恢复旧映射
                        local restored = original_keymaps[key]
                        if restored and restored.rhs then
                            vim.api.nvim_feedkeys(
                                vim.api.nvim_replace_termcodes(restored.rhs, true, false, true),
                                "n",
                                false
                            )
                        end
                    end
                end, { noremap = true, silent = true, desc = "调试锁定" })
            end
        end

        -- 解锁编辑按键（恢复用户原有映射）
        local function unlock_keymaps()
            for _, key in ipairs(blocked_keys) do
                pcall(vim.keymap.del, "n", key)
                local restored = original_keymaps[key]
                if restored and restored.rhs then
                    vim.keymap.set("n", key, restored.rhs, restored)
                end
            end
        end

        -- 禁止插入模式：进入 Insert 模式时强制退出
        vim.api.nvim_create_autocmd("InsertEnter", {
            group = group,
            callback = function(args)
                if debugging_active and is_code_file(args.buf) then
                    -- 立即退出插入模式
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
                    vim.notify("⚠️ 调试中禁止编辑代码文件！", vim.log.levels.WARN)
                end
            end,
        })

        -----------------------------------------------------------------------
        -- 📡 DAP 事件监听：启动→锁定；结束→解锁
        -----------------------------------------------------------------------
        local has_unlocked = false -- 防止重复触发 "调试结束" 提示

        -- 启动调试时启用锁定机制
        local function enable_debug_lock()
            debugging_active = true
            lock_keymaps()
            has_unlocked = false
            vim.notify("🧩 调试启动：代码文件进入只读模式", vim.log.levels.INFO)
        end

        -- 结束调试时解锁（带防重复机制）
        local function disable_debug_lock()
            if has_unlocked then return end -- 若已执行过则跳过
            has_unlocked = true
            debugging_active = false
            unlock_keymaps()
            vim.notify("✅ 调试结束：退出只读模式", vim.log.levels.INFO)
            -- 延迟重置状态，确保下一次调试仍可使用
            vim.defer_fn(function() has_unlocked = false end, 200)
        end

        -- 注册 DAP 生命周期事件
        dap.listeners.before.launch["lock_edit"] = enable_debug_lock
        dap.listeners.before.attach["lock_edit"] = enable_debug_lock
        dap.listeners.after.event_terminated["unlock_edit"] = disable_debug_lock
        dap.listeners.after.event_exited["unlock_edit"] = disable_debug_lock
        -- 清理自动布局 autocmd，防止窗口调整后重新打开 dapui
        dap.listeners.after.event_terminated["cleanup_autocmd"] = function()
            pcall(vim.api.nvim_del_augroup_by_name, "DAP_AutoLayout")
        end
        dap.listeners.after.event_exited["cleanup_autocmd"] = function()
            pcall(vim.api.nvim_del_augroup_by_name, "DAP_AutoLayout")
        end

        -----------------------------------------------------------------------
        -- 🖱️ 鼠标支持：调试期间启用 → 结束后恢复
        -----------------------------------------------------------------------
        dap.listeners.before.launch["mouse_on"] = function() vim.opt.mouse = "a" end
        dap.listeners.before.attach["mouse_on"] = function() vim.opt.mouse = "a" end
        dap.listeners.after.event_terminated["mouse_off"] = function() vim.opt.mouse = default_mouse end
        dap.listeners.after.event_exited["mouse_off"] = function() vim.opt.mouse = default_mouse end

        -----------------------------------------------------------------------
        -- 🧩 调试器适配器配置
        -----------------------------------------------------------------------
        local mason_root = vim.fn.stdpath("data") .. "/mason/bin/"

        dap.adapters.codelldb = {
            type = "executable",
            command = mason_root .. "codelldb",
            setupCommands = {
                { text = "-enable-pretty-printing", description = "启用漂亮打印", ignoreFailures = false },
            },
        }

        dap.adapters.cppdbg = {
            id = "cppdbg",
            type = "executable",
            command = mason_root .. "OpenDebugAD7",
            setupCommands = {
                { text = "-enable-pretty-printing", description = "启用漂亮打印", ignoreFailures = false },
            },
        }

        dap.configurations.cpp = {
            {
                name = "Launch with codelldb",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
            {
                name = "Launch with cppdbg",
                type = "cppdbg",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopAtEntry = true,
            },
        }

        -----------------------------------------------------------------------
        -- 🧱 UI 初始化
        -----------------------------------------------------------------------
        dapui.setup(vim.tbl_deep_extend("force", nvim_dap_ui_opts, {
            render = { max_value_lines = 5, indent = 2, max_children = 30 }
        }))

        -- 自动布局调整：窗口尺寸变化时自动刷新调试界面
        local function adaptive_layout()
            -- 先确保不会重复创建
            pcall(vim.api.nvim_del_augroup_by_name, "DAP_AutoLayout")
            local group = vim.api.nvim_create_augroup("DAP_AutoLayout", { clear = true })
            vim.api.nvim_create_autocmd("VimResized", {
                group = group,
                callback = function()
                    -- 仅在有调试会话时才重绘 UI
                    if require("dap").session() then
                        require("dapui").close()
                        vim.defer_fn(function()
                            require("dapui").open({ reset = true })
                        end, 10)
                    end
                end
            })
        end

        dap.listeners.before.attach.dapui_config = function()
            adaptive_layout(); dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            adaptive_layout(); dapui.open()
        end

        -- 调试结束时关闭界面
        dap.listeners.before.event_terminated["cleanup"] = function()
            dapui.close()
            dap.repl.close()
        end

        -----------------------------------------------------------------------
        -- 🎨 符号高亮与样式定义
        -----------------------------------------------------------------------
        vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff5252", bg = "#31353f", bold = true })
        vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#7dcfff", bg = "#31353f", bold = true })
        vim.api.nvim_set_hl(0, "DapStopped", { fg = "#c3e88d", bg = "#31353f", bold = true, underline = true })

        local signs = {
            DapBreakpoint = { text = "", texthl = "DapBreakpoint", numhl = "DapBreakpoint" },
            DapBreakpointCondition = { text = "", texthl = "DapBreakpoint", numhl = "DapBreakpoint" },
            DapBreakpointRejected = { text = "", texthl = "DapBreakpoint", numhl = "DapBreakpoint" },
            DapLogPoint = { text = "", texthl = "DapLogPoint", numhl = "DapLogPoint" },
            DapStopped = { text = "", texthl = "DapStopped", numhl = "DapStopped" },
        }

        for name, cfg in pairs(signs) do vim.fn.sign_define(name, cfg) end

        -----------------------------------------------------------------------
        -- ⚙️ 实验性画布模式（增强 UI 绘制）
        -----------------------------------------------------------------------
        vim.g.dapui_experimental = { use_canvas = true, dynamic_layout = false, canvas_padding = 2 }
    end
}

return nvim_dap
