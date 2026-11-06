-- Previsualizacion de markdown como panel lateral derecho, igual que el de Claude.
--
-- No abre navegador: el panel es un buffer espejo (scratch, solo lectura) del
-- archivo actual, renderizado por render-markdown.nvim con los colores del
-- tema. Se actualiza al teclear y el cursor del panel sigue al del archivo.
--
-- render-markdown va desactivado por defecto a proposito: el buffer que se edita
-- se queda con markdown crudo y solo el espejo se renderiza (buf_enable).

local PANEL_WIDTH = 0.4

local state = { win = nil, buf = nil, src = nil, group = nil }

local function valid(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function sync_lines()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end
  if not vim.api.nvim_buf_is_valid(state.src) then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(state.src, 0, -1, false)
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

local function sync_cursor()
  if not valid(state.win) then
    return
  end
  local src_win = vim.fn.bufwinid(state.src)
  if src_win == -1 then
    return
  end
  local line = vim.api.nvim_win_get_cursor(src_win)[1]
  local last = vim.api.nvim_buf_line_count(state.buf)
  vim.api.nvim_win_call(state.win, function()
    vim.api.nvim_win_set_cursor(state.win, { math.min(line, last), 0 })
    vim.cmd("normal! zz")
  end)
end

local function close()
  if state.group then
    pcall(vim.api.nvim_del_augroup_by_id, state.group)
  end
  if valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state = { win = nil, buf = nil, src = nil, group = nil }
end

local function open()
  local src = vim.api.nvim_get_current_buf()
  local src_win = vim.api.nvim_get_current_win()

  state.src = src
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].filetype = "markdown"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false

  state.win = vim.api.nvim_open_win(state.buf, false, {
    split = "right",
    win = -1, -- ventana de borde a borde, como el panel de Claude
    width = math.floor(vim.o.columns * PANEL_WIDTH),
  })
  vim.wo[state.win].wrap = true
  vim.wo[state.win].linebreak = true
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].cursorline = false
  vim.wo[state.win].winfixwidth = true

  sync_lines()
  vim.api.nvim_win_call(state.win, function()
    require("render-markdown").buf_enable()
  end)

  vim.keymap.set("n", "q", close, { buffer = state.buf, desc = "Cerrar previsualizacion" })

  state.group = vim.api.nvim_create_augroup("MarkdownPreviewPanel", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = state.group,
    buffer = src,
    callback = sync_lines,
  })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = state.group,
    buffer = src,
    callback = sync_cursor,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = state.group,
    buffer = src,
    callback = close,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.group,
    pattern = tostring(state.win),
    callback = function()
      vim.schedule(close)
    end,
  })

  sync_cursor()
  vim.api.nvim_set_current_win(src_win)
end

local function toggle()
  if valid(state.win) then
    close()
  elseif vim.bo.filetype == "markdown" then
    open()
  else
    vim.notify("El buffer actual no es markdown", vim.log.levels.WARN)
  end
end

return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
  ft = "markdown",
  opts = {
    enabled = false,
    file_types = { "markdown" },
  },
  init = function()
    vim.api.nvim_create_user_command("MdPreview", toggle, { desc = "Panel de previsualizacion de markdown" })
  end,
  keys = {
    { "<leader>mp", toggle, desc = "Previsualizar markdown (panel)" },
  },
}
