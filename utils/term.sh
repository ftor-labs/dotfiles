#!/bin/bash

#=======================================================================
#  _____                   _             _   ____       _               
# |_   _|__ _ __ _ __ ___ (_)_ __   __ _| | / ___|  ___| |_ _   _ _ __  
#   | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | | \___ \ / _ \ __| | | | '_ \ 
#   | |  __/ |  | | | | | | | | | | (_| | |  ___) |  __/ |_| |_| | |_) |
#   |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_| |____/ \___|\__|\__,_| .__/ 
#                                                                |_|    
# Terminal setup module - Handles terminal-related installs and configs
#=======================================================================

# =======================================================================
# IMPORTS 
# =======================================================================

. utils/log.sh
. utils/brew.sh
. utils/arch.sh
. utils/const.sh


# =======================================================================
# INTERNAL USE ONLY
# =======================================================================

_setup_alacritty() {
    log_info "Setting up Alacritty..."

    # First, make sure Alacritty is installed
    if ! command -v alacritty &> /dev/null; then
        install_brew_cask "alacritty"
    else
        log_info "Alacritty is already installed"
    fi

    # Create config directory
    if [ ! -d "$ALACRITTY_THEMES_DIR" ]; then
        mkdir -p "$ALACRITTY_THEMES_DIR"
        log_info "Created Alacritty config directories"
    else
        log_info "Alacritty config directories already exist"
    fi

    # Download Nordic theme if it doesn't exist
    if [ ! -f "$ALACRITTY_THEME_FILE" ]; then
        curl -o "$ALACRITTY_THEME_FILE" \
            $ALACRITTY_THEME_URL || \
            log_error "Failed to download Nordic theme"
        log_info "Downloaded Nordic theme"
    else
        log_info "Nordic theme already exists"
    fi

    # Copy Alacritty config if it doesn't exist or differs from source
    if [ ! -f "$ALACRITTY_CONFIG_FILE" ] || ! cmp -s "$ALACRITTY_SOURCE_CONFIG" "$ALACRITTY_CONFIG_FILE"; then
        cp "$ALACRITTY_SOURCE_CONFIG" "$ALACRITTY_CONFIG_FILE" || log_error "Failed to copy Alacritty config"
        log_info "Updated Alacritty configuration"
    else
        log_info "Alacritty configuration already up to date"
    fi

    log_success "Alacritty configured successfully"
}

_install_zsh() {

    log_info "Installing and configuring Zsh..."

    # Install Zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        install_brew_formula "zsh"
    else
        log_info "Zsh is already installed"
    fi

    # Set Zsh as default shell if it's not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Setting Zsh as default shell..."
        chsh -s "$(which zsh)" || log_error "Failed to set Zsh as default shell"
    else
        log_info "Zsh is already the default shell"
    fi

    log_success "Zsh installed and configured successfully"
}

_install_oh_my_zsh() {
    log_info "Installing oh-my-zsh and plugins..."

    if [ -d "$ZSH_HOME" ]; then
        log_info "oh-my-zsh is already installed"
    else
        log_info "Installing oh-my-zsh..."
        # Install oh-my-zsh
        sh -c "$(curl -fsSL $OH_MY_ZSH_INSTALL_URL)" "" --unattended || log_error "Failed to install oh-my-zsh"
        log_info "oh-my-zsh installed successfully"
    fi

    # Install powerlevel10k theme if not already installed
    if [ ! -d "$P10K_THEME_DIR" ]; then
        log_info "Installing powerlevel10k theme..."
        git clone --depth=1 $POWERLEVEL10K_URL "$P10K_THEME_DIR" || log_error "Failed to install powerlevel10k"
        log_info "powerlevel10k theme installed successfully"
    else
        log_info "powerlevel10k theme is already installed"
    fi

    # Install plugins
    log_info "Checking oh-my-zsh plugins..."
    for plugin_url in "${ZSH_PLUGINS[@]}"; do
        plugin_name=$(basename $plugin_url | cut -d. -f1)
        plugin_path="$ZSH_PLUGINS_DIR/$plugin_name"
        
        if [ ! -d "$plugin_path" ]; then
            log_info "Installing plugin: $plugin_name..."
            git clone $plugin_url "$plugin_path" || log_error "Failed to install $plugin_name"
            log_info "Plugin $plugin_name installed successfully"
        else
            log_info "Plugin $plugin_name is already installed"
        fi
    done

    log_success "oh-my-zsh and plugins are properly configured"
}

_setup_terminal_config_files() {
    log_info "Setting up terminal configuration files..."
    ARCH=$(detect_arch)

    # Only backup existing .zshrc if we haven't already backed it up
    if [ -f "$ZSH_RC_FILE" ] && [ ! -f "$ZSH_RC_BACKUP" ]; then
        mv "$ZSH_RC_FILE" "$ZSH_RC_BACKUP"
        log_info "Backed up existing .zshrc to .zshrc.backup"
    elif [ -f "$ZSH_RC_BACKUP" ]; then
        log_info ".zshrc backup already exists, not overwriting"
    fi

    # Copy .zshrc if it doesn't exist or differs from source
    if [ ! -f "$ZSH_RC_FILE" ] || ! cmp -s "$ZSH_RC_SOURCE" "$ZSH_RC_FILE"; then
        cp "$ZSH_RC_SOURCE" "$ZSH_RC_FILE" || log_error "Failed to copy .zshrc"
        log_info "Updated .zshrc configuration"
    else
        log_info ".zshrc configuration already up to date"
    fi
     
    # todo -> add a way to backup this
    cp "$CREDS_SOURCE" "$CREDS_ZSH_FILE" || log_error "Failed to copy credentials file"

    log_success "Terminal configuration files set up successfully"
}

# =======================================================================
# TERMINAL UTILS
# =======================================================================

setup_term() {
    log_info "Setting up complete terminal environment..."
    
    # Install and configure shell
    _install_zsh
    _install_oh_my_zsh
    
    # Install and configure terminal emulator
    _setup_alacritty
    
    # Set up configuration files
    _setup_terminal_config_files
    
    log_success "Terminal environment setup completed successfully"
    log_info "Please restart your terminal and run 'p10k configure' to set up your terminal theme"
}