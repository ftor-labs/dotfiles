# macOS Development CLI Utilities & Bootstrap 🛠️

A suite of command-line utilities and bootstrap scripts for macOS development environments.

## ✨ Overview

This repository contains a collection of well-crafted command-line utilities and a bootstrap system for setting up and managing development environments on macOS. These tools are designed to be modular, secure, and user-friendly, with consistent interfaces and error handling.

## 🧰 Core Utilities

### 🚀 Bootstrap System (`bootstrap.sh`)

The central script that orchestrates the setup of a complete development environment:

- ✅ Checks OS compatibility
- 📦 Installs development tools, applications, fonts, and languages via Homebrew
- 🔒 Sets up security with a custom keychain
- 🔑 Configures Git and SSH keys
- 💻 Sets up terminal environment (Alacritty, Zsh, Oh My Zsh)
- 🔄 Supports idempotent execution (safe to run multiple times)

```bash
./bootstrap.sh
```

### 🔐 Keychain CLI (`kc`)

A comprehensive keychain management utility for secure credential storage:

```bash
kc create            # Create the custom keychain
kc unlock            # Unlock the keychain
kc lock              # Lock the keychain
kc status            # Check keychain status
kc add <svc> <acc>   # Add or update a credential
kc rm <svc> <acc>    # Remove a credential
kc get <svc> <acc>   # Get a credential value
kc list              # List all services in the keychain
kc delete            # Delete the entire keychain (with confirmation)
kc help              # Show help message
```

### 📋 Configuration Updater (`cu`)

Manages and synchronizes dotfiles across your system:

```bash
./cu list            # List available config types
./cu update [--all]  # Update configuration(s)
./cu backup [--all]  # Backup configuration(s)
./cu help            # Show help message
```

Supported configurations:
- 📝 nvim
- 🐚 zsh
- 🌱 git
- 📊 tmux
- 🖥️ alacritty

## 💾 Installation

```bash
git clone https://github.com/facundotorraca/dotfiles.git
cd dotfiles
./bootstrap.sh
```

## ⚙️ Customization

You can customize the installation by modifying the constants in `utils/const.sh`:

- 🔑 `DEFAULT_CUSTOM_KEYCHAIN_NAME`: Default keychain name
- 📂 `CUSTOM_SCRIPTS_FOLDER`: Location for custom scripts
- 🛠️ `TOOLS`: Array of CLI tools to install
- 📱 `CASKS`: Array of applications to install
- 🔤 `FONTS`: Array of fonts to install
- 👨‍💻 `LANGS`: Array of language managers to install

## 👤 Maintainer

Facundo Torraca

## ⚖️ License

This project is licensed under the MIT License.