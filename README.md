# dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot) for multi-environment Unix setups (WSL, Ubuntu 22.04).

## Features

- **Automated setup** with a single command
- **Neovim** installation and configuration with LSP, Treesitter, and Telescope
- **Tmux** configuration with vim-style bindings and plugin manager (tpm)
- **Python tools** (pyright, ruff) installed globally via `uv tool install`
- **CLI tools** (ripgrep, lazygit) installed locally to `~/.local/bin`
- **Environment-agnostic** - no virtual environments needed, no sudo required

## Contents

- `home/.bashrc` - Bash configuration with custom prompt
- `home/.tmux.conf` - Tmux configuration with vim bindings
- `home/.config/nvim/init.lua` - Neovim configuration
- `scripts/` - Installation helper scripts
- `install.conf.yaml` - Dotbot configuration

## Prerequisites

- Git
- curl
- bash

## Installation

### On a new system

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Run the installation script:

```bash
./install
```

This will:
1. Create symlinks for dotfiles (bashrc, tmux.conf, nvim config)
2. Install uv and Python tools (pyright, ruff) globally
3. Install Tmux and tmux plugin manager (tpm)
4. Download and install Neovim to `~/.local/nvim-linux64`
5. Download and install ripgrep to `~/.local/bin`
6. Download and install lazygit to `~/.local/bin`
7. Install vim-plug and Neovim plugins

### After installation

Restart your shell or source the bashrc:

```bash
source ~/.bashrc
```

## What gets installed

### Tools
- **Neovim** - Latest stable release from GitHub (installed to `~/.local/nvim-linux64`)
- **ripgrep (rg)** - Fast grep alternative for code search (installed to `~/.local/bin`)
- **lazygit** - Terminal UI for git commands (installed to `~/.local/bin`)
- **uv** - Modern Python package manager
- **pyright** - Python LSP server for Neovim
- **ruff** - Python linter and formatter
- **vim-plug** - Neovim plugin manager
- **tpm** - Tmux plugin manager

### Configurations
- Bash configuration with custom prompt and PATH setup
- Tmux configuration with vim-style bindings
- Neovim configuration with LSP, Treesitter, Telescope

## Updating Tools

### Python Tools

Python tools are installed globally using `uv tool install`, making them available system-wide without needing to activate a virtual environment. Tools are installed in `~/.local/bin` which is added to your PATH.

```bash
uv tool upgrade pyright
uv tool upgrade ruff
```

### CLI Tools (ripgrep, lazygit)

To update ripgrep or lazygit, simply delete the binary and re-run the install script:

```bash
rm ~/.local/bin/rg
rm ~/.local/bin/lazygit
./install
```

## Neovim Keybindings

### Python Formatting (Ruff)

- `<Space>f` - Format current line (or selection in visual mode)
- `<Space>F` - Format entire file
- `<Space>i` - Organize imports

### LSP

- `gd` - Go to definition
- `<Space>e` - Show diagnostic details in floating window
- `[d` - Go to previous diagnostic
- `]d` - Go to next diagnostic
- `gl` - Open diagnostics list

### Other

- `<F5>` - Toggle undotree
- `<Ctrl-p>` - Open recent files (Telescope)
- `<Ctrl-n>` - Find files (Telescope)
- `<Ctrl-\>` - Generate Python docstring

## Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull
./install
```

## Customization

Edit the files in the `home/` directory to customize your configurations. Changes will take effect after running `./install` again or creating the symlinks manually.

## Testing

The dotfiles installation can be tested in a clean Ubuntu 22.04 environment using Docker.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system

### Running Tests

Run all tests with a single command:

```bash
./tests/run-tests.sh
```

This will:
1. Build a Docker image with Ubuntu 22.04
2. Copy your local dotfiles into the container
3. Run the installation inside the container
4. Verify the installation completed successfully

### Test Options

```bash
./tests/run-tests.sh --help        # Show help
./tests/run-tests.sh --verbose     # Enable verbose output
./tests/run-tests.sh --no-cache    # Force rebuild without cache
```

### Debugging Failed Tests

If tests fail, you can debug interactively:

```bash
# Run the container with an interactive shell
docker run --rm -it dotfiles-test:ubuntu-22.04 bash

# Or run the installation manually
docker run --rm -it dotfiles-test:ubuntu-22.04 bash -c "./install"
```

### What Gets Tested

- Installation script runs without errors
- Symlinks are created correctly
- Required directories are created
- Tools (nvim, uv) are available in PATH

### Benefits of Container Testing

- **Clean environment** - Each test starts from a fresh Ubuntu 22.04 system
- **Tests local changes** - Uses your local dotfiles, not the GitHub version
- **Reproducible** - Same results on any system with Docker installed
- **Fast** - Docker caches layers for quick rebuilds
- **Safe** - Tests run in isolation, won't affect your system

## Structure

```
dotfiles/
├── install                     # Main installation script
├── install.conf.yaml          # Dotbot configuration
├── dotbot/                    # Dotbot submodule
├── scripts/
│   ├── install_neovim.sh     # Neovim installation
│   ├── install_ripgrep.sh    # ripgrep installation
│   ├── install_lazygit.sh    # lazygit installation
│   ├── setup_python.sh       # Python tools setup
│   ├── install_vim_plug.sh   # vim-plug setup
│   └── install_tmux.sh       # Tmux and plugin manager setup
├── tests/
│   ├── run-tests.sh          # Main test runner
│   ├── verify-install.sh     # Installation verification
│   └── apptainer/
│       └── ubuntu-22.04.def  # Ubuntu 22.04 container definition
└── home/
    ├── .bashrc
    ├── .tmux.conf
    └── .config/
        └── nvim/
            └── init.lua
```

## License

MIT
