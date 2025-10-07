local icons = require("utils.icons")

-- Mason的路径由core.mason-path处理（Mason是Neovim的包管理器，用于安装LSP等工具）
-- 启用指定的语言服务器（这些服务器需通过Mason安装）
vim.lsp.enable({
  "clangd",
  "python",
  "cmake",
  "lua"
})

-- 配置诊断信息的显示样式（错误、警告等提示的外观）
vim.diagnostic.config({
  virtual_lines = {
    current_line = true
  },                        -- 在代码行尾显示诊断文本（虚拟文本）
  underline = true,         -- 为有诊断信息的代码添加下划线
  update_in_insert = false, -- 插入模式下不更新诊断信息（提升性能）
  severity_sort = true,     -- 按严重程度排序诊断信息（错误 > 警告 > 信息 > 提示）

  -- 浮动窗口配置（鼠标悬停时显示的详细诊断窗口）
  float = {
    border = "rounded", -- 浮动窗口使用圆角边框
    source = true,      -- 显示诊断信息的来源（如哪个LSP服务器）
  },

  -- 诊断符号配置（左侧符号列显示的图标）
  signs = {
    text = {
      -- 错误、警告、信息、提示对应的图标（使用nerdfont）
      [vim.diagnostic.severity.ERROR] = icons.misc.error,
      [vim.diagnostic.severity.WARN] = icons.misc.warn,
      [vim.diagnostic.severity.INFO] = icons.misc.info,
      [vim.diagnostic.severity.HINT] = icons.misc.hint,
    },
    numhl = {
      -- 诊断信息对应的行号高亮组（复用内置高亮）
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",  -- 错误行号用错误色
      [vim.diagnostic.severity.WARN] = "WarningMsg", -- 警告行号用警告色
    },
  },
})

-- 配置lsp相关快捷键
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc, silent = true })
    end
    -- 跳转定义
    map("<C-S-j>", "<cmd>Lspsaga goto_definition<CR>", "跳转到定义 (Lspsaga)")
    -- 跳转到上次跳转的地方
    map("<C-S-k>", "<C-t>", "跳转到上次跳转的地方 (Lspsaga)")
    -- 查看引用
    map("<leader>ld", "<cmd>Lspsaga finder def+ref+imp<CR>", "查看引用 (Lspsaga)")
    -- 查看定义
    map("<leader>li", "<cmd>Lspsaga peek_definition<CR>", "查看定义 (Lspsaga)")
    -- 查看声明
    map("<leader>ii", "<cmd>Lspsaga hover_doc<CR>", "查看声明 (Lspsaga)")
    -- 批量重命名
    map("<leader>rn", "<cmd>Lspsaga rename ++project<CR>", "批量重命令 (Lspsaga)")
    -- 显示行诊断
    map("<leader>ll", "<cmd>Lspsaga show_line_diagnostics<CR>", "显示诊断信息 (Lspsaga)")
    -- 显示所有诊断
    map("<leader>la", "<cmd>Telescope diagnostics<CR>", "显示所有诊断信息 (Lspsaga)")
    -- 显示大纲
    map("<leader>lf", "<cmd>Lspsaga outline<CR>", "显示大纲信息 (Lspsaga)")
    -- 查看代码建议
    map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "查看代码建议 (Lspsaga)")
    -- 查看上一个诊断
    map("<leader>lj", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "跳转到上一个诊断 (Lspsaga)")
    -- 查看下一个诊断
    map("<leader>lk", "<cmd>Lspsaga diagnostic_jump_next<CR>", "跳转到下一个诊断 (Lspsaga)")
    -- 使用lsp默认的format程序（normal和visual模式）
    map("==", "<cmd>lua vim.lsp.buf.format()<CR>", "使用LSP格式化代码 (Lspsaga)", { "n", "v" })
    -- 添加源文件/头文件转换
    map("<C-o>",
      "<cmd>lua vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', { uri = vim.uri_from_bufnr(0) })<CR>",
      "跳转头文件/源文件 (Lspsaga)")
    -- 删除lsp默认快捷键K
    map("K", "", "Disable default K shortcut")
  end,
})

-- 重启当前缓冲区的LSP客户端
local function restart_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- 检查当前文件是否未保存
  if vim.bo[bufnr].modified then
    vim.notify("文件未保存，请先保存文件再重启 LSP", vim.log.levels.ERROR, { title = "LSP 重启失败" })
    return -- 终止后续操作
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end

  vim.defer_fn(function()
    vim.cmd('edit') -- 此时文件已保存，无需强制刷新
  end, 100)
end

-- 创建用户命令`:LspRestart`，用于手动重启LSP
vim.api.nvim_create_user_command('LspRestart', function()
  restart_lsp()
end, {})

-- 显示当前缓冲区的LSP状态详情
local function lsp_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  -- 无LSP客户端时提示
  if #clients == 0 then
    print("󰅚 没有附加的LSP客户端")
    return
  end

  print("󰒋 当前缓冲区 " .. bufnr .. " 的LSP状态:")
  print("─────────────────────────────────")

  -- 遍历所有LSP客户端，打印详细信息
  for i, client in ipairs(clients) do
    print(string.format("󰌘 客户端 %d: %s (ID: %d)", i, client.name, client.id))
    print("  根目录: " .. (client.config.root_dir or "N/A")) -- 项目根目录
    print("  文件类型: " .. table.concat(client.config.filetypes or {}, ", ")) -- 支持的文件类型

    -- 检查客户端支持的功能（如补全、格式化等）
    local caps = client.server_capabilities
    local features = {}
    if caps.completionProvider then table.insert(features, "补全") end
    if caps.hoverProvider then table.insert(features, "悬停提示") end
    if caps.definitionProvider then table.insert(features, "定义跳转") end
    if caps.referencesProvider then table.insert(features, "查找引用") end
    if caps.renameProvider then table.insert(features, "重命名") end
    if caps.codeActionProvider then table.insert(features, "代码动作") end
    if caps.documentFormattingProvider then table.insert(features, "格式化") end

    print("  支持功能: " .. table.concat(features, ", "))
    print("")
  end
end

-- 创建用户命令`:LspStatus`，用于查看LSP状态详情
vim.api.nvim_create_user_command('LspStatus', lsp_status, { desc = "显示详细的LSP状态" })


-- 检查当前缓冲区LSP客户端的能力（支持哪些功能）
local function check_lsp_capabilities()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    print("没有附加的LSP客户端")
    return
  end

  -- 遍历客户端，打印支持的能力
  for _, client in ipairs(clients) do
    print(client.name .. " 的能力:")
    local caps = client.server_capabilities

    -- 定义需要检查的能力列表
    local capability_list = {
      { "补全", caps.completionProvider },
      { "悬停提示", caps.hoverProvider },
      { "签名帮助", caps.signatureHelpProvider },
      { "跳转定义", caps.definitionProvider },
      { "跳转声明", caps.declarationProvider },
      { "跳转实现", caps.implementationProvider },
      { "跳转类型定义", caps.typeDefinitionProvider },
      { "查找引用", caps.referencesProvider },
      { "文档高亮", caps.documentHighlightProvider },
      { "文档符号", caps.documentSymbolProvider },
      { "工作区符号", caps.workspaceSymbolProvider },
      { "代码动作", caps.codeActionProvider },
      { "代码透镜", caps.codeLensProvider },
      { "文档格式化", caps.documentFormattingProvider },
      { "范围格式化", caps.documentRangeFormattingProvider },
      { "重命名", caps.renameProvider },
      { "折叠范围", caps.foldingRangeProvider },
      { "选择范围", caps.selectionRangeProvider },
    }

    -- 打印每个能力的支持状态（✓支持，✗不支持）
    for _, cap in ipairs(capability_list) do
      local status = cap[2] and "✓" or "✗"
      print(string.format("  %s %s", status, cap[1]))
    end
    print("")
  end
end

-- 创建用户命令`:LspCapabilities`，用于查看LSP能力
vim.api.nvim_create_user_command('LspCapabilities', check_lsp_capabilities, { desc = "显示LSP支持的能力" })


-- 显示当前缓冲区的诊断信息统计（错误、警告等数量）
local function lsp_diagnostics_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr) -- 获取当前缓冲区的所有诊断信息

  -- 初始化统计计数
  local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

  -- 遍历诊断信息，累加各等级的数量
  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity]
    counts[severity] = counts[severity] + 1
  end

  -- 打印统计结果
  print("󰒡 当前缓冲区的诊断信息:")
  print("  错误: " .. counts.ERROR)
  print("  警告: " .. counts.WARN)
  print("  信息: " .. counts.INFO)
  print("  提示: " .. counts.HINT)
  print("  总计: " .. #diagnostics)
end

-- 创建用户命令`:LspDiagnostics`，用于查看诊断信息统计
vim.api.nvim_create_user_command('LspDiagnostics', lsp_diagnostics_info, { desc = "显示LSP诊断信息计数" })

-- 显示综合的LSP信息（比LspStatus更详细）
local function lsp_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  print("═══════════════════════════════════")
  print("           LSP 综合信息           ")
  print("═══════════════════════════════════")
  print("")

  -- 基础信息
  print("󰈙 语言客户端日志: " .. vim.lsp.get_log_path()) -- LSP日志文件路径
  print("󰈮 缓冲区ID: " .. bufnr) -- 当前缓冲区ID
  print("󰈔 文件类型: " .. vim.bo.filetype) -- 当前文件类型
  print("󰈔 当前目录: " .. (vim.fn.getcwd() or "N/A")) -- 当前工作目录
  print("")

  -- 无LSP客户端时的提示
  if #clients == 0 then
    print("󰅚 缓冲区 " .. bufnr .. " 没有附加LSP客户端")
    print("")
    print("可能的原因:")
    print("  • 未安装 " .. vim.bo.filetype .. " 对应的语言服务器")
    print("  • 语言服务器未配置")
    print("  • 不在项目根目录下")
    print("  • 文件类型未被识别")
    return
  end

  -- 打印每个LSP客户端的详细信息
  print("󰒋 附加到缓冲区 " .. bufnr .. " 的LSP客户端:")
  print("─────────────────────────────────")

  for i, client in ipairs(clients) do
    print(string.format("󰌘 客户端 %d: %s", i, client.name))
    print("  ID: " .. client.id) -- 客户端ID
    print("  根目录: " .. (client.config.root_dir or "N/A")) -- 项目根目录
    print("  启动命令: " .. table.concat(client.config.cmd or {}, " ")) -- 启动命令
    print("  支持的文件类型: " .. table.concat(client.config.filetypes or {}, ", ")) -- 支持的文件类型

    -- 服务器状态（运行中/已停止）
    if client.is_stopped() then
      print("  状态: 󰅚 已停止")
    else
      print("  状态: 󰄬 运行中")
    end

    -- 工作区文件夹（若有）
    if client.workspace_folders and #client.workspace_folders > 0 then
      print("  工作区文件夹:")
      for _, folder in ipairs(client.workspace_folders) do
        print("    • " .. folder.name)
      end
    end

    -- 附加的缓冲区数量
    local attached_buffers = {}
    for buf, _ in pairs(client.attached_buffers or {}) do
      table.insert(attached_buffers, buf)
    end
    print("  附加的缓冲区数量: " .. #attached_buffers)

    -- 核心功能支持情况
    local caps = client.server_capabilities
    local key_features = {}
    if caps.completionProvider then table.insert(key_features, "补全") end
    if caps.hoverProvider then table.insert(key_features, "悬停") end
    if caps.definitionProvider then table.insert(key_features, "定义跳转") end
    if caps.documentFormattingProvider then table.insert(key_features, "格式化") end
    if caps.codeActionProvider then table.insert(key_features, "代码动作") end

    if #key_features > 0 then
      print("  核心功能: " .. table.concat(key_features, ", "))
    end

    print("")
  end

  -- 诊断信息汇总
  local diagnostics = vim.diagnostic.get(bufnr)
  if #diagnostics > 0 then
    print("󰒡 诊断信息汇总:")
    local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

    for _, diagnostic in ipairs(diagnostics) do
      local severity = vim.diagnostic.severity[diagnostic.severity]
      counts[severity] = counts[severity] + 1
    end

    print("  󰅚 错误: " .. counts.ERROR)
    print("  󰀪 警告: " .. counts.WARN)
    print("  󰋽 信息: " .. counts.INFO)
    print("  󰌶 提示: " .. counts.HINT)
    print("  总计: " .. #diagnostics)
  else
    print("󰄬 无诊断信息")
  end

  print("─────────────────────────────────")
  print("使用 :LspLog 查看详细日志")
  print("使用 :LspCapabilities 查看完整能力列表")
end

-- 创建用户命令`:LspInfo`，用于查看综合LSP信息
vim.api.nvim_create_user_command('LspInfo', lsp_info, { desc = "显示综合的LSP信息" })

-- 创建用户命令':LspLog', 用于查看lsp日志信息
vim.api.nvim_create_user_command('LspLog', ":lua vim.cmd('tabnew ' .. vim.lsp.log.get_filename())", { desc = "查看LSP日志" })


-- 状态栏相关功能（在底部状态栏显示精简信息）
-- 生成简短的LSP状态（用于状态栏）
local function lsp_status_short()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    return "" -- 无LSP客户端时返回空
  end

  -- 收集所有LSP客户端名称
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end

  return "󰒋 " .. table.concat(names, ",") -- 格式：󰒋 客户端1,客户端2
end

-- 获取当前Git分支（用于状态栏）
local function git_branch()
  -- 执行git命令获取当前分支（错误输出重定向到/dev/null避免干扰）
  local ok, handle = pcall(io.popen, "git branch --show-current 2>/dev/null")
  if not ok or not handle then
    return ""
  end
  local branch = handle:read("*a") -- 读取命令输出
  handle:close() -- 关闭文件句柄
  if branch and branch ~= "" then
    branch = branch:gsub("\n", "") -- 移除换行符
    return " 󰊢 " .. branch -- 格式： 󰊢 分支名
  end
  return "" -- 非Git仓库时返回空
end

-- 获取当前文件的格式化工具状态（用于状态栏）
local function formatter_status()
  -- 尝试加载conform.nvim（格式化工具管理插件）
  local ok, conform = pcall(require, "conform")
  if not ok then
    return ""
  end

  -- 获取当前缓冲区要运行的格式化工具
  local formatters = conform.list_formatters_to_run(0)
  if #formatters == 0 then
    return ""
  end

  -- 收集格式化工具名称
  local formatter_names = {}
  for _, formatter in ipairs(formatters) do
    table.insert(formatter_names, formatter.name)
  end

  return "󰉿 " .. table.concat(formatter_names, ",") -- 格式：󰉿 工具1,工具2
end

-- 获取当前文件的Linter状态（用于状态栏）
local function linter_status()
  -- 尝试加载lint.nvim（Linter管理插件）
  local ok, lint = pcall(require, "lint")
  if not ok then
    return ""
  end

  -- 获取当前文件类型对应的Linter
  local linters = lint.linters_by_ft[vim.bo.filetype] or {}
  if #linters == 0 then
    return ""
  end

  return "󰁨 " .. table.concat(linters, ",") -- 格式：󰁨 工具1,工具2
end


-- 安全包装函数（避免状态栏报错）
local function safe_git_branch()
  local ok, result = pcall(git_branch) -- 捕获错误
  return ok and result or ""           -- 出错时返回空
end

local function safe_lsp_status()
  local ok, result = pcall(lsp_status_short)
  return ok and result or ""
end

local function safe_formatter_status()
  local ok, result = pcall(formatter_status)
  return ok and result or ""
end

local function safe_linter_status()
  local ok, result = pcall(linter_status)
  return ok and result or ""
end

-- 将安全函数挂载到全局变量（供状态栏调用）
_G.git_branch = safe_git_branch
_G.lsp_status = safe_lsp_status
_G.formatter_status = safe_formatter_status
_G.linter_status = safe_linter_status


-- 配置状态栏（底部的信息栏）
vim.opt.statusline = table.concat({
  "%{v:lua.git_branch()}",       -- Git分支信息
  "%f",                          -- 当前文件名
  "%m",                          --  modified标记（[+]表示修改未保存）
  "%r",                          --  readonly标记（[RO]表示只读）
  "%=",                          -- 右对齐分隔符（左侧内容居左，右侧居右）
  "%{v:lua.linter_status()}",    -- Linter状态
  "%{v:lua.formatter_status()}", -- 格式化工具状态
  "%{v:lua.lsp_status()}",       -- LSP状态
  " %l:%c",                      -- 当前光标位置（行:列）
  " %p%%"                        -- 当前位置占文件总长度的百分比
}, " ")
