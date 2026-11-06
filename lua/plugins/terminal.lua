-- Terminales integradas, sobre snacks.terminal (lo mismo que LazyVim ya usa en
-- <C-/>). La flotante venia de serie: snacks.win tiene position = "float" por
-- defecto, asi que aqui solo se le fija tamano y borde.
--
-- Lo que se anade son las variantes que no traia: splits abajo/derecha y
-- terminales numeradas independientes (cada count es un proceso aparte, no un
-- toggle de la misma).
--
-- Prefijo <leader>t porque neotest no esta instalado. A proposito no se mapea
-- nada nuevo en modo terminal: cualquier <C-x> ahi dentro se lo roba a la TUI
-- que este corriendo.

---@param opts? snacks.terminal.Opts
---@param root? boolean usar la raiz del proyecto en vez del cwd
local function term(opts, root)
  return function()
    opts = vim.tbl_deep_extend("force", opts or {}, {
      cwd = root ~= false and LazyVim.root() or vim.uv.cwd(),
    })
    Snacks.terminal(nil, opts)
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          style = "terminal",
          border = "rounded",
          width = 0.85,
          height = 0.8,
        },
      },
    },
    keys = {
      { "<leader>t", "", desc = "+terminal" },
      { "<leader>tt", term(), desc = "Flotante (root dir)" },
      { "<leader>tT", term(nil, false), desc = "Flotante (cwd)" },
      { "<leader>th", term({ win = { position = "bottom", height = 0.3 } }), desc = "Split abajo" },
      { "<leader>tv", term({ win = { position = "right", width = 0.4 } }), desc = "Split derecha" },
      { "<leader>t1", term({ count = 1 }), desc = "Terminal 1" },
      { "<leader>t2", term({ count = 2 }), desc = "Terminal 2" },
      { "<leader>t3", term({ count = 3 }), desc = "Terminal 3" },
    },
  },
}
