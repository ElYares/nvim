-- Notebooks de Jupyter dentro de nvim.
--
-- Tres piezas que se reparten el trabajo:
--   jupytext.nvim  convierte el .ipynb a texto plano al abrirlo y lo devuelve
--                  a json al guardar, asi que editas celdas como si fuera .py
--   molten-nvim    ejecuta las celdas contra un kernel real y pinta la salida
--   image.nvim     dibuja las graficas con el protocolo kitty
--
-- Sobre imagenes: molten solo habla con image.nvim o wezterm, y wezterm no
-- pasa por tmux. Como aqui todo vive en tmux, va image.nvim con backend kitty
-- (ghostty lo entiende) y processor magick_cli, que usa el binario de
-- ImageMagick en vez del luarock magick.
--
-- El host de python de nvim apunta a un venv propio (ver config/options.lua):
-- molten es un remote plugin y necesita pynvim, que no esta en el python de mise.
return {
  {
    "3rd/image.nvim",
    build = false, -- sin luarocks: el processor magick_cli usa el CLI de ImageMagick
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      -- molten dibuja sus propias salidas; la integracion de markdown solo
      -- estorbaria renderizando imagenes por su cuenta en el mismo buffer
      integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
      },
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "" },
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    -- No lazy: el manifest de remote plugins solo se genera si molten esta en
    -- el runtimepath cuando corre :UpdateRemotePlugins. Cargado por keys, el
    -- build de lazy produce un manifest vacio y ningun comando :Molten* existe.
    lazy = false,
    init = function()
      -- Estas vars se leen cuando arranca el host de python, no despues
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_virt_lines = true -- salida como virtual lines bajo la celda
      vim.g.molten_virt_text_output = true -- texto inline en vez de ventana flotante
      vim.g.molten_virt_lines_off_by_1 = true -- cuadra la salida con el final real de la celda
      vim.g.molten_auto_open_output = false -- necesario si virt_text_output esta activo
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_virt_text_max_lines = 20
      vim.g.molten_use_border_highlights = true -- borde en rojo cuando la celda falla
      vim.g.molten_cover_empty_lines = true
    end,
    keys = {
      { "<leader>j", "", desc = "Jupyter/Molten" },
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Iniciar kernel" },
      { "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Evaluar (operador)" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluar linea" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Evaluar seleccion" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-evaluar celda" },
      { "<leader>ja", "<cmd>MoltenReevaluateAll<cr>", desc = "Re-evaluar todas" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Ver salida" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Ocultar salida" },
      { "<leader>jO", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Entrar a la salida" },
      { "<leader>jn", "<cmd>MoltenNext<cr>", desc = "Celda siguiente" },
      { "<leader>jp", "<cmd>MoltenPrev<cr>", desc = "Celda anterior" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Borrar celda" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrumpir kernel" },
      { "<leader>jR", "<cmd>MoltenRestart!<cr>", desc = "Reiniciar kernel" },
      { "<leader>jb", "<cmd>MoltenOpenInBrowser<cr>", desc = "Abrir salida en navegador" },
      { "<leader>jI", "<cmd>MoltenImportOutput<cr>", desc = "Importar salidas del .ipynb" },
      { "<leader>jE", "<cmd>MoltenExportOutput!<cr>", desc = "Exportar salidas al .ipynb" },
    },
  },

  -- La capa que hace que las celdas se vean y se manejen como en VSCode:
  -- resalta la linea "# %%", permite saltar de celda en celda y ejecutar la
  -- celda bajo el cursor sin tener que seleccionarla a mano.
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      "nvim-mini/mini.comment",
      "nvim-mini/mini.hipatterns", -- pinta el marcador de celda
      "benlubas/molten-nvim",
    },
    event = "VeryLazy",
    opts = {
      activate_hydra_keys = nil, -- sin hydra.nvim: una dependencia menos
      repl_provider = "molten",
      cell_markers = { python = "# %%" },
      syntax_highlight = false,
      cell_highlight_group = "NotebookCellSeparator",
    },
    config = function(_, opts)
      -- El separador de celda se pinta con un color de acento del tema en vez
      -- de un fondo: transparency.lua deja Normal sin bg, asi que cualquier
      -- grupo que solo tenga background (CursorLine y compania) queda invisible.
      -- Se toma de Function para que siga al tema cuando omarchy lo recarga.
      local function set_cell_hl()
        local accent = vim.api.nvim_get_hl(0, { name = "Function", link = false })
        vim.api.nvim_set_hl(0, "NotebookCellSeparator", { fg = accent.fg, bold = true })
      end
      set_cell_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_cell_hl })

      local nn = require("notebook-navigator")
      nn.setup(opts)
      require("mini.hipatterns").setup({ highlighters = { cells = nn.minihipatterns_spec } })
    end,
    keys = {
      { "]h", function() require("notebook-navigator").move_cell("d") end, desc = "Celda siguiente" },
      { "[h", function() require("notebook-navigator").move_cell("u") end, desc = "Celda anterior" },
      { "<leader>jj", function() require("notebook-navigator").run_and_move() end, desc = "Ejecutar celda y avanzar" },
      { "<leader>jc", function() require("notebook-navigator").run_cell() end, desc = "Ejecutar celda" },
      { "<leader>jw", function() require("notebook-navigator").run_cells_below() end, desc = "Ejecutar de aqui hacia abajo" },
      { "<leader>jB", function() require("notebook-navigator").add_cell_below() end, desc = "Nueva celda abajo" },
      { "<leader>jA", function() require("notebook-navigator").add_cell_above() end, desc = "Nueva celda arriba" },
    },
  },

  -- Text object de celda: "ih" es la celda bajo el cursor. Sirve para
  -- <leader>jeih (evaluar celda), vih (seleccionarla), dah (borrarla).
  {
    "nvim-mini/mini.ai",
    opts = function(_, opts)
      opts.custom_textobjects = opts.custom_textobjects or {}
      opts.custom_textobjects.h = require("notebook-navigator").miniai_spec
      return opts
    end,
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- tiene que estar cargado antes de que se lea el .ipynb
    opts = {
      style = "hydrogen", -- celdas como "# %%", el mismo marcador que usa vscode
      output_extension = "auto",
      force_ft = nil,
    },
  },

  -- snacks.image dibujaria imagenes por su cuenta y se pelearia con image.nvim
  -- por el mismo protocolo kitty. Hoy viene apagado en LazyVim; esto lo fija.
  {
    "folke/snacks.nvim",
    opts = { image = { enabled = false } },
  },
}
