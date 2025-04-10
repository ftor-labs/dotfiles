#!/bin/bash

# =================================================================================================
#
#            ██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗ 
#            ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗
#            ██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝
#            ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝ 
#            ██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║     
#            ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     
#                                                                               
#                        ✦ ✦ ✦   Maintained by Facundo Torraca   ✦ ✦ ✦
#
#                      🚀 macOS Development Environment Bootstrap Script 🚀
#
# =================================================================================================

# =================================================================================================
# IMPORTS 
# =================================================================================================

. utils/kc.sh
. utils/os.sh
. utils/log.sh
. utils/git.sh
. utils/term.sh
. utils/arch.sh
. utils/brew.sh
. utils/const.sh

# =================================================================================================
# INSTALLATION
# =================================================================================================

install_tools() {
    local tools=("$@")
    
    if [ ${#tools[@]} -eq 0 ]; then
        log_error "No tools specified"
        return 1
    fi
    
    log_info "Installing ${#tools[@]} brew formulas..."

    for tool in "${tools[@]}"; do
        install_brew_formula "$tool"
    done

    log_success "All brew formulas installed successfully"
}

install_casks() {
    local casks=("$@")
    
    if [ ${#casks[@]} -eq 0 ]; then
        log_error "No casks specified"
        return 1
    fi
    
    log_info "Installing ${#casks[@]} cask applications..."

    for cask in "${casks[@]}"; do
        install_brew_cask "$cask"
    done
    
    log_success "All cask applications installed successfully"
}

install_fonts() {
    local fonts=("$@")
    
    if [ ${#fonts[@]} -eq 0 ]; then
        log_error "No fonts specified"
        return 1
    fi
    
    log_info "Installing ${#fonts[@]} fonts..."
    
    for font in "${fonts[@]}"; do
        install_brew_cask "$font"
    done
    
    log_success "All fonts installed successfully"
}

install_langs() {
    local langs=("$@")

    if [ ${#langs[@]} -eq 0 ]; then
        log_error "No tools specified"
        return 1
    fi

    log_info "Installing ${#langs[@]} language and managers..."

    for lang in "${langs[@]}"; do
        install_brew_formula "$lang"
    done
    
    log_success "Language managers installed successfully"
}

install_scpts() {
    local scpts=("$@")

    if [ ${#scpts[@]} -eq 0 ]; then
        log_error "No scripts specified"
        return 1
    fi

    log_info "Installing ${#scpts[@]} scripts..."

    # Create the custom scripts directory if it doesn't exist
    if [ ! -d "$CUSTOM_SCRIPTS_FOLDER" ]; then
        mkdir -p "$CUSTOM_SCRIPTS_FOLDER"
        log_info "Created custom scripts folder: $CUSTOM_SCRIPTS_FOLDER"
    fi

    # Copy each script and make executable
    for scpt in "${scpts[@]}"; do
        if [ -f "$scpt" ]; then
            script_name=$(basename "$scpt")
            cp "$scpt" "$CUSTOM_SCRIPTS_FOLDER/$script_name" || log_error "Failed to copy $script_name"
            chmod +x "$CUSTOM_SCRIPTS_FOLDER/$script_name" || log_error "Failed to make $script_name executable"
            log_info "Installed script: $script_name"
        else
            log_warning "Script not found: $scpt"
        fi
    done
    
    log_success "Scripts installed successfully in $CUSTOM_SCRIPTS_FOLDER"
}


# =================================================================================================
# MAIN
# =================================================================================================

main() {
    log_info "Starting installation..."

    # Check OS compatibility
    check_os || exit 1
    
    # Ensure Homebrew is installed and ready
    check_homebrew
    
    # Install software using the API-like interface
    install_tools "${TOOLS[@]}"
    install_casks "${CASKS[@]}"
    install_fonts "${FONTS[@]}"
    install_langs "${LANGS[@]}"
    install_scpts "${SCRTS[@]}"

    setup_kc
    setup_git
    setup_term
    
    log_success "Installation completed successfully!"
    log_info "Please restart your terminal and run 'p10k configure' to set up your terminal theme"
}

main