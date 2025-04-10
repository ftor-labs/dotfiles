#!/bin/bash

#=======================================================================
#   ____ _ _   
#  / ___(_) |_ 
# | |  _| | __|
# | |_| | | |_ 
#  \____|_|\__|
# Git setup module - Handles Git and GitHub configuration
#=======================================================================

# =======================================================================
# IMPORTS 
# =======================================================================

. utils/kc.sh
. utils/log.sh
. utils/brew.sh
. utils/const.sh

# =======================================================================
# INTERNAL USE ONLY
# =======================================================================

_check_git_installed() {
    if ! command -v git &> /dev/null; then
        log_info "Git not found, installing..."
        install_brew_formula "git"
    else
        log_info "Git is already installed"
    fi
}

_check_expect_installed() {
    if ! command -v expect &> /dev/null; then
        log_info "Installing 'expect' for SSH passphrase automation..."
        install_brew_formula "expect"
    fi
}

_create_git_config_dir() {
    local git_config_dir="./config/git"
    if [ ! -d "$git_config_dir" ]; then
        mkdir -p "$git_config_dir"
        log_info "Created Git config directory"
    fi
}

_configure_git_user() {
    local current_name=$(git config --global user.name)
    local current_email=$(git config --global user.email)
    
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        log_info "Git user already configured:"
        log_info "Name: $current_name"
        log_info "Email: $current_email"
        
        read -p "Keep this details? (y/n): " update_user
        if [[ ! "$update_user" =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi
    
    read -p "Enter your full name for Git: " git_name
    read -p "Enter your email for Git: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    # Use keychain utility functions instead of direct security commands
    store_item_in_kc "git" "git-user-name"  "$git_name"
    store_item_in_kc "git" "git-user-email" "$git_email"
    
    log_success "Git user configured"
}

_configure_git_defaults() {
    log_info "Checking Git defaults..."
    
    local changes_made=0
    
    # Function to check and set a git config value
    check_and_set_git_config() {
        local key="$1"
        local expected_value="$2"
        local current_value=$(git config --global --get "$key" 2>/dev/null)
        
        if [ "$current_value" != "$expected_value" ]; then
            git config --global "$key" "$expected_value"
            log_info "Set $key = $expected_value"
            changes_made=1
        fi
    }
    
    # Core settings
    check_and_set_git_config "init.defaultBranch" "main"
    check_and_set_git_config "pull.rebase" "true"
    check_and_set_git_config "core.editor" "vim"
    check_and_set_git_config "core.excludesfile" "$HOME/.gitignore_global"
    
    # Aliases
    check_and_set_git_config "alias.co" "checkout"
    check_and_set_git_config "alias.br" "branch"
    check_and_set_git_config "alias.ci" "commit"
    check_and_set_git_config "alias.st" "status"
    check_and_set_git_config "alias.lg" "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    if [ $changes_made -eq 0 ]; then
        log_info "Git defaults already configured correctly"
    else
        log_success "Git defaults configured"
    fi
}

_setup_gitignore() {
    local source="./config/git/.gitignore_global"
    local dest="$HOME/.gitignore_global"
    
    # Only copy if files differ
    if [ ! -f "$dest" ] || ! cmp -s "$source" "$dest"; then
        log_info "Updating global gitignore"
        cp "$source" "$dest" 2>/dev/null || log_error "Failed to copy gitignore"
        log_success "Global gitignore configured"
    else
        log_info "Global gitignore already up to date"
    fi
}

_generate_ssh_key() {
    read -p "Enter your email for SSH key: " ssh_email
    read -p "Use passphrase? (recommended) (y/n): " use_passphrase
    
    local passphrase=""
    if [[ "$use_passphrase" =~ ^[Yy]$ ]]; then
        read -s -p "Enter passphrase: " passphrase
        echo
        read -s -p "Confirm passphrase: " passphrase_confirm
        echo
        
        if [ "$passphrase" != "$passphrase_confirm" ]; then
            log_error "Passphrases do not match. Using empty passphrase."
            passphrase=""
        else
            # Use keychain utility function
            store_item_in_kc "github-ssh" "$USER-ssh-key" "$passphrase"
            log_info "Passphrase stored in keychain"
        fi
    fi
    
    # Generate key
    if ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_rsa" -N "$passphrase" 2>/dev/null; then
        log_success "Ed25519 SSH key generated"
    else
        ssh-keygen -t rsa -b 4096 -C "$ssh_email" -f "$HOME/.ssh/id_rsa" -N "$passphrase"
        log_success "RSA SSH key generated"
    fi
    
    # Use existing SSH config template
    local ssh_config_template="./config/git/ssh_config"
    local ssh_config_dest="$HOME/.ssh/config"
    
    # Copy template to SSH directory if config doesn't exist or needs update
    if [ ! -f "$ssh_config_dest" ]; then
        cp "$ssh_config_template" "$ssh_config_dest"
        chmod 600 "$ssh_config_dest"
        log_success "SSH config created from template"
    elif ! grep -q "github.com" "$ssh_config_dest"; then
        # Append GitHub config if not present
        cat "$ssh_config_template" >> "$ssh_config_dest"
        log_success "GitHub SSH config appended to existing config"
    else
        log_info "SSH config already includes GitHub settings"
    fi
}

_setup_ssh_key() {
    local ssh_dir="$HOME/.ssh"
    local key="$ssh_dir/id_rsa"
    local pub_key="$ssh_dir/id_rsa.pub"
    
    # Create SSH directory
    if [ ! -d "$ssh_dir" ]; then
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
        log_info "Created SSH directory"
    fi
    
    # Check for existing key
    if [ -f "$key" ] && [ -f "$pub_key" ]; then
        log_info "SSH key already exists"
        read -p "Use existing key? (y/n): " use_existing
        if [[ ! "$use_existing" =~ ^[Yy]$ ]]; then
            _generate_ssh_key
        fi
    else
        _generate_ssh_key
    fi
    
    # Add key to agent if not already added
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    
    # Check if key is already added to agent
    if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')"; then
        log_info "Adding SSH key to agent"
        
        # Use keychain utility functions to retrieve passphrase
        if check_item_in_kc "github-ssh" "$USER-ssh-key"; then
            log_info "Using stored SSH key passphrase from keychain"
            local passphrase=$(get_item_from_kc "github-ssh" "$USER-ssh-key")
            
            if [ -n "$passphrase" ] && command -v expect &> /dev/null; then
                expect -c "
                    spawn ssh-add $key
                    expect \"Enter passphrase\"
                    send \"$passphrase\r\"
                    expect eof
                " >/dev/null 2>&1 || ssh-add "$key"
            else
                ssh-add -K "$key" 2>/dev/null || ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key"
            fi
        else
            ssh-add -K "$key" 2>/dev/null || ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key"
        fi
        
        log_success "SSH key added to agent"
    else
        log_info "SSH key already added to agent"
    fi
    
    # Display public key
    log_info "Your SSH public key:"
    cat "$pub_key"
    
    # Check GitHub connection without prompting if already successful before
    if ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_success "GitHub connection already verified"
    else
        # Prompt for GitHub setup
        log_info "Add this key to GitHub at: https://github.com/settings/keys"
        read -p "Added to GitHub? (y/n): " key_added
        
        if [[ "$key_added" =~ ^[Yy]$ ]]; then
            ssh -T git@github.com -o StrictHostKeyChecking=no >/dev/null 2>&1
            if [ $? -eq 1 ]; then
                log_success "GitHub connection successful"
            else
                log_warning "GitHub connection may not be working"
            fi
        fi
    fi
}

_setup_github_cli() {
    if command -v gh &> /dev/null; then
        # Only ask to authenticate if not already authenticated
        if ! gh auth status &>/dev/null; then
            read -p "Authenticate GitHub CLI? (y/n): " auth_cli
            if [[ "$auth_cli" =~ ^[Yy]$ ]]; then
                gh auth login
                log_success "GitHub CLI authenticated"
            else
                log_info "Skipping GitHub CLI authentication"
            fi
        else
            log_info "GitHub CLI already authenticated"
        fi
    else
        log_info "GitHub CLI not installed, skipping authentication step"
    fi
}

# =======================================================================
# GIT UTILS
# =======================================================================

setup_git() {
    log_info "Setting up Git environment..."
    
    # Check if keychain exists
    if [ -z "$CUSTOM_KEYCHAIN_NAME" ]; then
        log_warning "CUSTOM_KEYCHAIN_NAME not set - keychain setup may be needed"
        read -p "Would you like to set up the keychain first? (y/n): " setup_keychain
        if [[ "$setup_keychain" =~ ^[Yy]$ ]]; then
            setup_kc
        else
            log_info "Continuing with system keychain"
        fi
    else
        log_info "Using custom keychain: $CUSTOM_KEYCHAIN_NAME"
    fi
    
    # Ensure required tools
    _check_git_installed
    _check_expect_installed
    
    # Create config directory
    _create_git_config_dir
    
    # Setup SSH for GitHub
    _setup_ssh_key
    
    # Setup Git configuration
    _setup_gitignore
    _configure_git_user
    _configure_git_defaults
    
    # Setup GitHub CLI
    _setup_github_cli
    
    log_success "Git environment setup complete"
}