#!/bin/bash

#=======================================================================
#     _             _     _                 _                    
#    / \   _ __ ___| |__ (_)_   _ ___  ____| |_ _   _ _ __ ___  
#   / _ \ | '__/ __| '_ \| | | | / __|/ __| __| | | | '__/ _ \ 
#  / ___ \| | | (__| | | | | |_| \__ \ (__| |_| |_| | | |  __/ 
# /_/   \_\_|  \___|_| |_|_|\__,_|___/\___|\__|\__,_|_|  \___| 
#                                                              
# Architecture detection module for system compatibility checks
#=======================================================================

# =======================================================================
# IMPORTS 
# =======================================================================

. utils/log.sh


# =======================================================================
# ARCH UTILS
# =======================================================================

detect_arch() {
    arch_name="$(uname -m)"\
    
    if [ "${arch_name}" = "x86_64" ]; then

        if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
            log_info "Running on Apple Silicon Mac using Rosetta 2"
            echo "arm64"
        else
            log_info "Running on Intel Mac"
            echo "x86_64"
        fi
    elif [ "${arch_name}" = "arm64" ]; then
        log_info "Running on Apple Silicon Mac natively"
        echo "arm64"
    else
        log_error "Unknown architecture: ${arch_name}"
        echo "unknown"
    fi
}