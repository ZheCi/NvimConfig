-- 自动获取mason安装路径, 但是会增加启动时间
-- local mason_settings = require("mason.settings")
-- local mason_root = mason_settings.current.install_root_dir

-- 配置mason安装路径
local mason_root = vim.fn.stdpath("data") .. "/mason/"

local M = {
  -- 引用上面定义的变量
  cmd = { mason_root .. "/bin/lua-language-server" },
  filetypes = { "lua" },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' }
}

return M


