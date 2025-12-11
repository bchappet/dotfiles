# dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot) for multi-environment Unix setups (WSL, Ubuntu 22.04).

## Features

- **Automated setup** with a single command
- **Neovim** installation and configuration with LSP, Treesitter, and Telescope
- **Tmux** configuration with vim-style bindings and plugin manager (tpm)
- **Python tools** (pyright, ruff) installed globally via `uv tool install`
- **Environment-agnostic** - no virtual environments needed

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
- sudo access (for Neovim installation to `/opt`)

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
1. Download and install Neovim to `/opt/nvim-linux64`
2. Create symlinks for dotfiles (bashrc, tmux.conf, nvim config)
3. Install vim-plug and Neovim plugins
4. Install tmux plugin manager (tpm) and plugins
5. Install uv and Python tools (pyright, ruff) globally

### After installation

Restart your shell or source the bashrc:

```bash
source ~/.bashrc
```

## What gets installed

### Tools
- **Neovim** - Latest stable release from GitHub
- **uv** - Modern Python package manager
- **pyright** - Python LSP server for Neovim
- **ruff** - Python linter and formatter
- **vim-plug** - Neovim plugin manager
- **tpm** - Tmux plugin manager

### Configurations
- Bash configuration with custom prompt and PATH setup
- Tmux configuration with vim-style bindings
- Neovim configuration with LSP, Treesitter, Telescope

## Python Tools

Python tools are installed globally using `uv tool install`, making them available system-wide without needing to activate a virtual environment. Tools are installed in `~/.local/bin` which is added to your PATH.

To update Python tools:

```bash
uv tool upgrade pyright
uv tool upgrade ruff
```

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

The dotfiles installation can be tested in a clean Ubuntu 22.04 environment using Apptainer containers.

### Prerequisites

- [Apptainer](https://apptainer.org/docs/admin/main/installation.html) installed on your system

### Running Tests

Run all tests with a single command:

```bash
./tests/run-tests.sh
```

This will:
1. Build an Ubuntu 22.04 Apptainer container (if not already built)
2. Run the dotfiles installation inside the container
3. Verify the installation completed successfully
4. Clean up the container image (on success)

### Test Options

```bash
./tests/run-tests.sh --help        # Show help
./tests/run-tests.sh --verbose     # Enable verbose output
./tests/run-tests.sh --keep        # Keep container after tests
./tests/run-tests.sh --rebuild     # Force rebuild of container
```

### Debugging Failed Tests

If tests fail, the container image is kept for debugging:

```bash
# Inspect the container interactively
apptainer shell tests/ubuntu-22.04.sif

# Run the container manually
apptainer run tests/ubuntu-22.04.sif
```

### What Gets Tested

- Installation script runs without errors
- Symlinks are created correctly
- Required directories are created
- Tools (nvim, uv) are available in PATH

### Benefits of Container Testing

- **Clean environment** - Each test starts from a fresh Ubuntu 22.04 system
- **No root required** - Apptainer runs without sudo (unlike Docker)
- **Reproducible** - Same results on any system with Apptainer installed
- **Fast** - Container images are cached for quick re-runs
- **Safe** - Tests run in isolation, won't affect your system

## Structure

```
dotfiles/
├── install                     # Main installation script
├── install.conf.yaml          # Dotbot configuration
├── dotbot/                    # Dotbot submodule
├── scripts/
│   ├── install_neovim.sh     # Neovim installation
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