#!/bin/bash

#=======================================================================
#  ____                                   
# | __ ) _ __ _____      __
# |  _ \| '__/ _ \ \ /\ / / 
# | |_) | | |  __/\ V  V / 
# |____/|_|  \___| \_/\_/  
#                                                          
# Homebrew management module
#=======================================================================

. utils/log.sh
. utils/arch.sh
. utils/const.sh

# =======================================================================
# HOMEBREW INSTALLATION
# =======================================================================

check_homebrew() {
    # Get architecture using the extracted module
    ARCH=$(detect_arch)
    
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        
        if [ "$ARCH" = "arm64" ]; then
            # Apple Silicon - install to /opt/homebrew
            /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)" || log_error "Failed to install Homebrew"
            
            # Set up Homebrew in the current shell session
            eval "$($BREW_ARM64_PATH shellenv)"
            
            # Add Homebrew to path for Apple Silicon
            if ! grep -q 'eval "$($BREW_ARM64_PATH shellenv)"' ~/.zprofile; then
                echo 'eval "$($BREW_ARM64_PATH shellenv)"' >> ~/.zprofile
            fi
        else
            # Intel Mac - install to /usr/local
            /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)" || log_error "Failed to install Homebrew"
            
            # Set up Homebrew in the current shell session
            eval "$($BREW_X86_PATH shellenv)"
            
            # Add Homebrew to path for Intel
            if ! grep -q 'eval "$($BREW_X86_PATH shellenv)"' ~/.zprofile; then
                echo 'eval "$($BREW_X86_PATH shellenv)"' >> ~/.zprofile
            fi
        fi
    else
        log_info "Homebrew is already installed"
    fi
    
    # Verify Homebrew is in PATH after installation
    if ! command -v brew &> /dev/null; then
        if [ "$ARCH" = "arm64" ]; then
            eval "$($BREW_ARM64_PATH shellenv)"
        else
            eval "$($BREW_X86_PATH shellenv)"
        fi
    fi
    
    log_success "Homebrew is ready to use"
}

# =======================================================================
# PACKAGE INSTALLATION
# =======================================================================

install_brew_formula() {
    local formula=$1
    
    if [ -z "$formula" ]; then
        log_error "No formula specified"
        return 1
    fi
    
    # Check if formula is already installed
    if brew list "$formula" &>/dev/null; then
        log_info "Formula '$formula' is already installed"
        return 0
    fi
    
    log_info "Installing formula: $formula..."
    brew install "$formula" || log_error "Failed to install $formula"
    log_success "Formula '$formula' installed successfully"
}

install_brew_cask() {
    local cask=$1
    
    if [ -z "$cask" ]; then 
        log_error "No cask specified"
        return 1
    fi
    
    # Check if cask is already installed
    if brew list --cask "$cask" &>/dev/null; then
        log_info "Cask '$cask' is already installed"
        return 0
    fi
    
    log_info "Installing cask: $cask..."
    brew install --cask "$cask" || log_error "Failed to install $cask"
    log_success "Cask '$cask' installed successfully"
}

tap_brew_repository() {
    local repo=$1
    
    if [ -z "$repo" ]; then
        log_error "No repository specified"
        return 1
    fi
    
    # Check if tap is already tapped
    if brew tap | grep -q "^$repo\$"; then
        log_info "Repository '$repo' is already tapped"
        return 0
    fi
    
    log_info "Tapping repository: $repo..."
    brew tap "$repo" || log_error "Failed to tap $repo"
    log_success "Repository '$repo' tapped successfully"
}