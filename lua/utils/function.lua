local M = {}

-- 关闭当前窗格，若文件未在其他窗格打开则同时关闭文件
M.close_pane_and_buffer_if_unused = function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)

  -- 过滤有效窗口：仅保留正常编辑窗口（排除临时窗口、悬浮窗等）
  local valid_wins = {}
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(winid) then
      local buf = vim.api.nvim_win_get_buf(winid)
      local buftype = vim.bo[buf].buftype
      -- 只统计正常文件缓冲区的窗口（buftype为空）
      if buftype == '' then
        table.insert(valid_wins, winid)
      end
    end
  end

  -- 如果只剩一个有效编辑窗口，提示无法关闭
  if #valid_wins <= 1 then
    vim.notify("当前只有一个窗口，无法关闭~", vim.log.levels.WARN)
    return
  end

  -- 检查当前缓冲区是否在其他有效窗口中被使用
  local is_used_in_other_win = false
  for _, winid in ipairs(valid_wins) do
    if winid ~= current_win then
      if vim.api.nvim_win_get_buf(winid) == current_buf then
        is_used_in_other_win = true
        break
      end
    end
  end

  -- 关闭当前窗格（双重检查窗口有效性）
  if vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_win_close(current_win, true)
  end

  -- 若缓冲区未在其他有效窗口使用，且无未保存更改，则删除缓冲区
  if not is_used_in_other_win and vim.api.nvim_buf_is_valid(current_buf) then
    if vim.bo[current_buf].modified then
      vim.notify("缓冲区有未保存的更改，已取消删除", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_buf_delete(current_buf, { force = true })
  end
end

return M
