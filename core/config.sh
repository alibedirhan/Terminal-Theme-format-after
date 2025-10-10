#!/bin/bash

# ============================================================================
# Configuration - Global constants and variables
# ============================================================================

# Version
export THEME_SETUP_VERSION="2.0.0"
export THEME_SETUP_CODENAME="MultiDE"

# Directories
export CONFIG_DIR="$HOME/.config/system-theme-setup"
export BACKUP_DIR="$CONFIG_DIR/backups"
export LOG_DIR="$CONFIG_DIR/logs"
export CACHE_DIR="$CONFIG_DIR/cache"

# Files
export LOG_FILE="$LOG_DIR/theme-setup.log"
export CONFIG_FILE="$CONFIG_DIR/config.conf"
export LAST_THEME_FILE="$CONFIG_DIR/last_theme.conf"

# Themes directories
export USER_THEMES_DIR="$HOME/.themes"
export USER_ICONS_DIR="$HOME/.icons"
export USER_LOCAL_THEMES="$HOME/.local/share/themes"
export USER_LOCAL_ICONS="$HOME/.local/share/icons"
export USER_WALLPAPERS="$HOME/.backgrounds"

# System directories
export SYSTEM_THEMES_DIR="/usr/share/themes"
export SYSTEM_ICONS_DIR="/usr/share/icons"

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'
export BOLD='\033[1m'
export NC='\033[0m'  # No Color

# Supported Desktop Environments
export SUPPORTED_DES=("GNOME" "KDE" "XFCE" "MATE" "Cinnamon" "Budgie")

# Supported Ubuntu LTS versions
export SUPPORTED_UBUNTU_VERSIONS=("22.04" "24.04")

# Theme sources priority
export THEME_SOURCE_PRIORITY=("apt" "ppa" "github" "fallback")

# Dependencies
export REQUIRED_DEPS=("wget" "curl" "git" "unzip" "tar" "gsettings")
export OPTIONAL_DEPS=("feh" "imagemagick" "jq")

# ZSH protection files
export ZSH_PROTECTED_FILES=(
    ".zshrc"
    ".zsh_history"
    ".zsh_plugins.txt"
    ".p10k.zsh"
    ".oh-my-zsh"
    ".zprezto"
    ".zim"
)

# Terminal protection settings
export PROTECT_TERMINAL_FONT=true
export PROTECT_TERMINAL_SIZE=true
export PROTECT_ZSH_CONFIG=true

# Backup settings
export MAX_BACKUPS=5
export BACKUP_COMPRESSION=true

# Logging settings
export LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR
export LOG_MAX_SIZE="10M"
export LOG_ROTATION=true

# Network settings
export DOWNLOAD_TIMEOUT=30
export MAX_RETRIES=3

# Feature flags
export ENABLE_WALLPAPERS=true
export ENABLE_GDM_THEME=false  # Risky, disabled by default
export ENABLE_GRUB_THEME=false  # Risky, disabled by default
export ENABLE_PLYMOUTH=false  # Risky, disabled by default

# ASCII Art and Emojis
export USE_ASCII_ART=true
export USE_EMOJIS=true

# ============================================================================
# Runtime variables (will be set during execution)
# ============================================================================

export DETECTED_DE=""
export DETECTED_VERSION=""
export DETECTED_ZSH=""
export CURRENT_THEME=""

# ============================================================================
# Helper functions for config
# ============================================================================

load_user_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

save_user_config() {
    cat > "$CONFIG_FILE" << CONF_EOF
# System Theme Setup User Configuration
# Generated: $(date)

ENABLE_WALLPAPERS=$ENABLE_WALLPAPERS
ENABLE_GDM_THEME=$ENABLE_GDM_THEME
LOG_LEVEL=$LOG_LEVEL
PROTECT_ZSH_CONFIG=$PROTECT_ZSH_CONFIG
CONF_EOF
}

# Initialize configuration
init_config() {
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$LOG_DIR" "$CACHE_DIR"
    mkdir -p "$USER_THEMES_DIR" "$USER_ICONS_DIR" "$USER_LOCAL_THEMES" "$USER_LOCAL_ICONS"
    mkdir -p "$USER_WALLPAPERS"
    
    load_user_config
}
