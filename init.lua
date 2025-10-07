---@diagnostic disable: trailing-space
-- 加载核心配置, 非插件相关
require("core.options") 
require("core.keymaps") 
require("core.autocmds") 
require("core.lsp") 

-- 加载管理插件Lazy
require("core.lazy")
