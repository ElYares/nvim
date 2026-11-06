-- LaTeX encima del extra lang.tex de LazyVim (ver lazyvim.json).
--
-- El extra ya trae vimtex, texlab y los parsers de treesitter. Aqui va lo que
-- el extra deja en blanco:
--   vimtex       compila con latexmk en continuo y abre zathura con SyncTeX
--                (<localleader>ll compila, <localleader>lv salta al PDF,
--                ctrl+click en zathura vuelve al codigo)
--   texlab       completado de comandos, \ref, \cite contra el .bib y diagnosticos;
--                la compilacion la lleva vimtex, texlab no compila al guardar
--   latexindent  formateo al guardar via conform; usa el .latexindent.yaml
--                del proyecto si existe
--   ltex_plus    ortografia y gramatica (LanguageTool) en espanol, solo en
--                tex/bib para no meterse en las notas markdown del vault
--
-- latexmk, latexindent, biber y zathura vienen de pacman (texlive-*), no de
-- mason: texlab y ltex-ls-plus si los instala mason.
return {
  {
    "lervag/vimtex",
    init = function()
      -- variante simple: la normal usa xdotool para reusar ventana y en Wayland no va
      vim.g.vimtex_view_method = "zathura_simple"
      vim.g.vimtex_compiler_method = "latexmk"
      -- el quickfix no salta solo en cada recompilacion con warnings
      vim.g.vimtex_quickfix_open_on_warning = 0
      -- el formateo lo hace latexindent via conform; vimtex solo indenta al escribir
      vim.g.vimtex_format_enabled = 0
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = { onSave = false },
              chktex = { onOpenAndSave = false, onEdit = false },
            },
          },
        },
        ltex_plus = {
          filetypes = { "tex", "plaintex", "bib" },
          settings = {
            ltex = {
              language = "es",
              additionalRules = { enablePickyRules = false },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "texlab", "ltex-ls-plus" } },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        tex = { "latexindent" },
        plaintex = { "latexindent" },
      },
      formatters = {
        latexindent = {
          -- -l lee .latexindent.yaml del proyecto; -g /dev/null evita el indent.log
          prepend_args = { "-l", "-g", "/dev/null" },
          cwd = function(...)
            return require("conform.util").root_file({ ".latexindent.yaml", "latexmkrc", ".latexmkrc", ".git" })(...)
          end,
        },
      },
    },
  },
}
