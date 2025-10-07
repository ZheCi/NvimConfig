-- 定义一个辅助函数：切换源文件和头文件（例如 .cpp ↔ .h）
local function switch_source_header(bufnr, client)
  local method_name = 'textDocument/switchSourceHeader'
  -- 检查当前缓冲区是否有活跃的 LSP 客户端，并且是否支持该方法
  if not client or not client:supports_method(method_name) then
    return vim.notify(
      ('当前缓冲区的活跃 LSP 客户端不支持 %s 方法'):format(method_name),
      vim.log.levels.ERROR
    )
  end

  -- 生成 LSP 所需的参数（即当前文件的 URI）
  local params = vim.lsp.util.make_text_document_params(bufnr)

  -- 向 clangd 发送请求，尝试切换对应的源/头文件
  client.request(method_name, params, function(err, result)
    if err then
      vim.notify('切换文件失败: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result then
      vim.notify('无法确定对应的源/头文件', vim.log.levels.WARN)
      return
    end
    -- 使用 Neovim 内置命令打开对应文件
    vim.cmd('edit ' .. vim.uri_to_fname(result))
  end, { bufnr = bufnr })
end

-- 定义一个辅助函数：显示光标所在符号的详细信息（名称 + 容器）
local function symbol_info(bufnr, client)
  local method_name = 'textDocument/symbolInfo'
  -- 检查 clangd 是否支持该扩展方法
  if not client or not client:supports_method(method_name) then
    return vim.notify(
      '未找到 clangd 客户端（或客户端不支持符号信息查询）',
      vim.log.levels.ERROR
    )
  end

  local win = vim.api.nvim_get_current_win()
  -- 获取当前光标所在的位置参数（包含行列等信息）
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)

  -- 向 clangd 请求符号信息
  client:request(method_name, params, function(err, res)
    if err or not res or #res == 0 then
      return
    end

    -- clangd 返回的结果中，第一个元素包含 containerName 和 name
    local container = string.format('容器: %s', res[1].containerName)
    local name = string.format('名称: %s', res[1].name)

    -- 在浮动窗口中展示
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = '符号信息',
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string
-- ↑ 用于类型注释，说明 clangd 初始化时可能返回 offsetEncoding

---@type vim.lsp.Config
return {
  -- 启动 clangd 的命令
  cmd = { 'clangd' },

  -- 关联的文件类型
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },

  -- 工程根目录标志（类似 VSCode 的 "root markers"）
  root_markers =  { ".git", "compile_commands.json" },

  -- 客户端能力声明，用于增强 LSP 交互
  capabilities = {
    textDocument = {
      completion = { editsNearCursor = true }, -- 更好地处理补全编辑
    },
    offsetEncoding = { 'utf-8', 'utf-16' }, -- 同时支持 UTF-8 和 UTF-16 偏移
  },

  -- 初始化时的回调（比如设置 offsetEncoding）
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,

  -- 当 clangd 成功附加到缓冲区时执行
  on_attach = function(client, bufnr)
    ------------------------------------------------------------------
    -- ✅ 注册 LSP Handler，避免 Neovim 对 clangd 扩展方法报错
    -- Neovim 默认没有内置 'textDocument/switchSourceHeader' 的 handler，
    -- 所以如果不手动注册，调用时会出现 E5108 报错（你之前遇到的错误）
    ------------------------------------------------------------------
    vim.lsp.handlers['textDocument/switchSourceHeader'] = function(_, result, ctx)
      if not result then
        vim.notify('无法找到对应的源/头文件', vim.log.levels.WARN)
        return
      end
      vim.cmd('edit ' .. vim.uri_to_fname(result))
    end

    ------------------------------------------------------------------
    -- 自定义命令：方便在命令行执行源/头文件切换
    -- :LspClangdSwitchSourceHeader
    ------------------------------------------------------------------
    vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdSwitchSourceHeader', function()
      switch_source_header(bufnr, client)
    end, { desc = '切换源文件和头文件' })

    ------------------------------------------------------------------
    -- 自定义命令：显示符号信息
    -- :LspClangdShowSymbolInfo
    ------------------------------------------------------------------
    vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdShowSymbolInfo', function()
      symbol_info(bufnr, client)
    end, { desc = '显示光标处符号信息' })
  end,
}
