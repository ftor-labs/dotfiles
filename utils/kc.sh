#!/bin/bash

#=======================================================================
#  _  __               _           _       
# | |/ /___ _   _  ___| |__    __ (_)_ __  
# | ' // _ \ | |  / __| '_ \ / _` | | '_ \ 
# | . \  __/ |_| | (__| | | | (_| | | | | |
# |_|\_\___|\__, |\___|_| |_|\__,_|_|_| |_|
#           |___/                          
# Keychain management utility for secure development credentials
#=======================================================================


# =======================================================================
# IMPORTS 
# =======================================================================

. utils/log.sh
. utils/const.sh

# =======================================================================
# KEYCHAIN UTILITIES
# =======================================================================

setup_kc() {
    log_info "Setting up keychain for secure development credentials..."
    
    # Ask for custom keychain name or use default
    read -p "Enter keychain name (press Enter for default '$DEFAULT_CUSTOM_KEYCHAIN_NAME'): " custom_keychain_name
    
    # Use default if empty
    keychain_name="${custom_keychain_name:-$DEFAULT_CUSTOM_KEYCHAIN_NAME}"

    # Check if keychain already exists
    if security list-keychains | grep -q "$keychain_name"; then
        log_info "Keychain '$keychain_name' already exists"
    else
        # Create new keychain
        log_info "Creating new keychain: $keychain_name"
        
        # Prompt for password
        read -sp "Enter password for new keychain (or press Enter for a secure generated password): " keychain_password
        echo ""
        
        if [ -z "$keychain_password" ]; then
            # Generate a secure random password if none provided
            keychain_password=$(openssl rand -base64 12)
            log_info "Generated a secure password for your keychain"
        fi
        
        # Create the keychain
        security create-keychain -p "$keychain_password" "$keychain_name"
        
        # Add to keychain list (but don't make it default)
        security list-keychains -d user -s "$keychain_name" $(security list-keychains -d user | tr -d '"')
        
        # Set settings - timeout in seconds (7200 = 2 hours)
        security set-keychain-settings -t 7200 -l "$keychain_name"
        
        log_success "Keychain '$keychain_name' created successfully"
        
        # Save password to a secure location if generated
        if [ "$keychain_password" != "$(echo -n)" ]; then
            echo "Your keychain password is: $keychain_password"
            log_warning "Please store this password securely and then clear your terminal history"
        fi
    fi
    
    # Unlock the keychain for this session
    log_info "Unlocking keychain for this session..."
    security unlock-keychain "$keychain_name"
    
    # export keychain name for use in other scripts
    export CUSTOM_KEYCHAIN_NAME="$keychain_name"

    log_success "Keychain setup completed successfully"
    log_info "Custom keychain '$keychain_name' will be used for development credentials"
    log_info "Your system default keychain remains unchanged"
}

store_item_in_kc() {
    local service="$1"
    local account="$2"
    local password="$3"
    
    if [ -z "$service" ] || [ -z "$account" ] || [ -z "$password" ]; then
        log_error "Missing parameters for store_item_in_kc"
        return 1
    fi
    
    if [ -z "$CUSTOM_KEYCHAIN_NAME" ]; then
        log_error "CUSTOM_KEYCHAIN_NAME is not set"
        return 1
    fi
    
    log_info "Storing credentials for $service in keychain..."
    security add-generic-password -a "$account" -s "$service" -w "$password" "$CUSTOM_KEYCHAIN_NAME"
    
    if [ $? -eq 0 ]; then
        log_success "Credentials stored successfully"
        return 0
    else
        log_error "Failed to store credentials"
        return 1
    fi
}

get_item_from_kc() {
    local service="$1"
    local account="$2"
    
    if [ -z "$service" ] || [ -z "$account" ]; then
        log_error "Missing parameters for get_item_from_kc"
        return 1
    fi
    
    if [ -z "$CUSTOM_KEYCHAIN_NAME" ]; then
        log_error "CUSTOM_KEYCHAIN_NAME is not set"
        return 1
    fi
    
    security find-generic-password -a "$account" -s "$service" -w "$CUSTOM_KEYCHAIN_NAME" 2>/dev/null
    return $?
}

delete_item_from_kc() {
    local service="$1"
    local account="$2"
    
    if [ -z "$service" ] || [ -z "$account" ]; then
        log_error "Missing parameters for delete_item_from_kc"
        return 1
    fi
    
    if [ -z "$CUSTOM_KEYCHAIN_NAME" ]; then
        log_error "CUSTOM_KEYCHAIN_NAME is not set"
        return 1
    fi
    
    log_info "Deleting credentials for $service from keychain..."
    security delete-generic-password -a "$account" -s "$service" "$CUSTOM_KEYCHAIN_NAME" &>/dev/null
    
    if [ $? -eq 0 ]; then
        log_success "Credentials deleted successfully"
        return 0
    else
        log_error "Failed to delete credentials"
        return 1
    fi
}

check_item_in_kc() {
    local service="$1"
    local account="$2"
    
    if [ -z "$service" ] || [ -z "$account" ]; then
        return 1
    fi
    
    if [ -z "$CUSTOM_KEYCHAIN_NAME" ]; then
        return 1
    fi
    
    if security find-generic-password -a "$account" -s "$service" "$CUSTOM_KEYCHAIN_NAME" &>/dev/null; then
        return 0
    else
        return 1
    fi
}