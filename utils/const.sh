#!/bin/bash

#=======================================================================
#   ____                _              _       
#  / ___|___  _ __  ___| |_ __ _ _ __ | |_ ___ 
# | |   / _ \| '_ \/ __| __/ _` | '_ \| __/ __|
# | |__| (_) | | | \__ \ || (_| | | | | |_\__ \
#  \____\___/|_| |_|___/\__\__,_|_| |_|\__|___/
#                                              
# Constants and configuration for the bootstrapper script
#=======================================================================

#=======================================================================
# DEVELOPMENT TOOLS
#=======================================================================

TOOLS=(
    # Version Control
    "gh"            # GitHub CLI
    "git"           # Version control system
    
    # Shell Utilities
    "zsh"           # Z shell, better than bash
    "eza"           # Modern replacement for ls
    "zoxide"        # Smarter cd command with learning
    "fzf"           # Fuzzy finder for command line
    "ripgrep"       # Fast text search tool
    "tmux"          # Terminal multiplexer
    
    # Core Dev Tools
    "neovim"        # Modern vim text editor
    "terraform"     # Infrastructure as code
    "jq"            # JSON processor
    "wget"          # File downloader
    "awscli"        # AWS command line interface
)


#=======================================================================
# APPLICATIONS
#=======================================================================

CASKS=(
    # Development Apps
    "alacritty"     # Fast GPU-accelerated terminal
    "datagrip"      # Database IDE
    "webstorm"      # JavaScript IDE,
    "goland"        # Go IDE
    "pycharm"       # Python IDE
    "docker"        # Containerization platform
    "postman"       # API development tool
    "ngrok"         # Expose local servers to internet
    
    # Productivity Apps
    "notion"        # All-in-one workspace
    "rectangle"     # Window management
    "chatgpt"       # OpenAI's official ChatGPT desktop app
    "claude"        # Anthropic's official Claude AI desktop app
    "obsidian"      # Note-taking and knowledge management
    "alfred"        # Productivity app for macOS


    # Communication Apps
    "slack"         # Team communication
    "discord"       # Voice and text chat
    "whatsapp"      # Messaging

    # Entertainment Apps
    "steam"         # Gaming platform
    "spotify"       # Music streaming
    
    # Browsers
    "brave-browser" # Privacy-focused browser
    
    # Security Apps
    "bitwarden"     # Password manager
)


#=======================================================================
# LANGUAJES / MANAGERS
#=======================================================================

LANGS=(
    "pyenv" # Python version manager
    "jenv"  # Java version manager
    "nvm"   # Node.js version manager
)

#=======================================================================
# FONTS
#=======================================================================

# Fonts to install
FONTS=(
    "font-meslo-lg-nerd-font"       # Meslo with icons, good for terminals
    "font-fira-code-nerd-font"       # Fira Code with icons, has ligatures
    "font-jetbrains-mono-nerd-font" # JetBrains Mono with icons, clear coding font
)

# Font repository
FONT_TAP="homebrew/cask-fonts"      # Homebrew tap for font casks


#=======================================================================
# CUSTOM SCRIPTS
#=======================================================================

SCRTS=(
    "./scripts/kc" # keychain tools
    "./scripts/cu" # config updater
)

# Custom scripts folder
CUSTOM_SCRIPTS_FOLDER="$HOME/.custom-scripts"


#=======================================================================
# KEYCHAIN
#=======================================================================

DEFAULT_CUSTOM_KEYCHAIN_NAME="ftor.keychain"


#=======================================================================
# PATHS
#=======================================================================

DOTFILES_DIR="$HOME/ftor/dotfiles"

GIT_CONFIG_DIR="$DOTFILES_DIR/config/git"
TERM_CONFIG_DIR="$DOTFILES_DIR/config/term"

CREDS_SOURCE="$TERM_CONFIG_DIR/.creds"
ZSH_RC_SOURCE="$TERM_CONFIG_DIR/.zshrc"
GITIGNORE_SOURCE="$GIT_CONFIG_DIR/.gitignore_global"
ALACRITTY_SOURCE_CONFIG="$TERM_CONFIG_DIR/.alacritty.toml"

# Alacritty config paths
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
ALACRITTY_THEMES_DIR="$ALACRITTY_CONFIG_DIR/themes/themes"
ALACRITTY_THEME_FILE="$ALACRITTY_THEMES_DIR/nordic.toml"
ALACRITTY_CONFIG_FILE="$ALACRITTY_CONFIG_DIR/alacritty.toml"

# ZSH config paths
ZSH_HOME="$HOME/.oh-my-zsh"
ZSH_RC_FILE="$HOME/.zshrc"
ZSH_RC_BACKUP="$HOME/.zshrc.backup"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_HOME/custom}"
ZSH_PLUGINS_DIR="$ZSH_CUSTOM_DIR/plugins"
ZSH_THEMES_DIR="$ZSH_CUSTOM_DIR/themes"
P10K_THEME_DIR="$ZSH_THEMES_DIR/powerlevel10k"
CREDS_ZSH_FILE="$HOME/.creds"

#=======================================================================
# SHELL CONFIGURATION
#=======================================================================

# ZSH plugins
ZSH_PLUGINS=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"  # Syntax highlighting in terminal
    "https://github.com/zsh-users/zsh-autosuggestions"          # Command suggestions based on history
)


#=======================================================================
# SYSTEM PATHS
#=======================================================================

# Homebrew paths
BREW_X86_PATH="/usr/local/bin/brew"       # Homebrew path on Intel Macs
BREW_ARM64_PATH="/opt/homebrew/bin/brew"  # Homebrew path on Apple Silicon


#=======================================================================
# EXTERNAL RESOURCES
#=======================================================================

# Theme URLs
POWERLEVEL10K_URL="https://github.com/romkatv/powerlevel10k.git"                                             # Fast and customizable zsh theme
ALACRITTY_THEME_URL="https://raw.githubusercontent.com/alacritty/alacritty-theme/master/themes/nordic.toml"  # Nordic theme for Alacritty

# Installation URLs
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"           # Homebrew package manager
OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"   # Oh My Zsh framework