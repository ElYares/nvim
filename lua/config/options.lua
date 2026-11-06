-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- Host de python de nvim: venv propio con pynvim y jupyter_client, que molten
-- necesita como remote plugin. Apuntar explicitamente evita que caiga en los
-- shims de mise, donde pynvim no esta instalado.
vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/molten-venv/bin/python")
