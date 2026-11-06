# nvim de ElYares

Config de Neovim sobre [LazyVim](https://github.com/LazyVim/LazyVim) (lazy.nvim).
Extras activos: neo-tree, Python, DAP, Rust, LaTeX. Además: Flutter/Dart, Claude Code, Jupyter (molten), vim-tmux-navigator, preview de Markdown y tema moonfly.

Versiones probadas: Neovim **0.12+** (mínimo 0.10), git 2.19+.

## Requisitos comunes

- Neovim >= 0.10 (recomendado 0.12)
- git, un compilador C (para treesitter), `ripgrep`, `fd`, `lazygit` (opcional)
- Node.js (varios LSP de Mason) y Python 3
- Una [Nerd Font](https://www.nerdfonts.com/) puesta como fuente de tu terminal

> **Antes de instalar:** si ya tienes una config, respáldala (los comandos de cada sistema lo incluyen).

---

## Linux

```bash
# 1. Dependencias (Arch; en Debian/Ubuntu usa apt, en Fedora dnf)
sudo pacman -S --needed neovim git base-devel ripgrep fd lazygit nodejs npm python python-pip imagemagick

# 2. Respaldar config y datos previos
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null

# 3. Clonar
git clone https://github.com/ElYares/nvim.git ~/.config/nvim

# 4. Abrir: lazy.nvim se instala solo y baja los plugins
nvim
```

Debian/Ubuntu: el `neovim` de apt suele ser viejo; instala el binario oficial o Flatpak/snap/AppImage de la 0.10+.

## macOS

```bash
# 1. Dependencias (Homebrew: https://brew.sh)
brew install neovim git ripgrep fd lazygit node python imagemagick
brew install --cask font-jetbrains-mono-nerd-font

# 2. Respaldar
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null

# 3. Clonar
git clone https://github.com/ElYares/nvim.git ~/.config/nvim

# 4. Abrir
nvim
```

Compilador: `xcode-select --install` si no lo tienes.

## Windows

PowerShell (con [winget](https://learn.microsoft.com/windows/package-manager/winget/) o [scoop](https://scoop.sh)):

```powershell
# 1. Dependencias
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd JesseDuffield.lazygit OpenJS.NodeJS Python.Python.3.12
# Compilador para treesitter (elige uno)
scoop install mingw        # o: winget install zig.zig  /  instalar Visual Studio Build Tools
# Fuente: instala una Nerd Font y selecciónala en Windows Terminal

# 2. Respaldar
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak -ErrorAction SilentlyContinue
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak -ErrorAction SilentlyContinue

# 3. Clonar
git clone https://github.com/ElYares/nvim.git $env:LOCALAPPDATA\nvim

# 4. Abrir (reinicia la terminal antes para que lea el PATH)
nvim
```

En Windows la config vive en `%LOCALAPPDATA%\nvim`, no en `~/.config`. WSL2 también sirve: sigue la sección de Linux dentro de la distro.

---

## Primer arranque

1. `nvim` → lazy.nvim instala los plugins (espera a que termine).
2. `:Mason` → instala los LSP/formatters que falten (los extras los piden solos).
3. `:checkhealth` → revisa que no falte ningún binario.
4. `:Lazy restore` → deja los plugins en las versiones exactas de `lazy-lock.json`.

## Partes específicas de mi máquina (opcionales)

Cosas que no funcionan tal cual en otro equipo; ajústalas o bórralas:

| Archivo | Qué asume | Qué hacer |
|---|---|---|
| `lua/config/options.lua` | `python3_host_prog` = `~/.local/share/nvim/molten-venv` | Crea el venv: `python -m venv ~/.local/share/nvim/molten-venv && ~/.local/share/nvim/molten-venv/bin/pip install pynvim jupyter_client jupytext ipykernel` (Windows: `Scripts\python.exe`). Sin él, quita la línea y `jupyter.lua` |
| `lua/plugins/jupyter.lua` | Terminal con protocolo kitty (ghostty, kitty, wezterm) e ImageMagick | Sin eso, bórralo |
| `lua/plugins/claudecode.lua` | CLI `claude` instalada | Si no la usas, bórralo |
| `lua/plugins/omarchy-theme-hotreload.lua` | Tema recargado por Omarchy (Linux) | Inofensivo en otros sistemas |
| `lua/plugins/tex.lua` | TeX Live + zathura | Instala TeX o quita el extra `lang.tex` en `lazyvim.json` |
| `lua/plugins/flutter.lua` | Flutter SDK en el PATH | Solo actúa en archivos `.dart` |

## Actualizar

```bash
cd ~/.config/nvim && git pull   # luego, dentro de nvim: :Lazy restore
```
