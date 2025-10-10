#!/bin/bash

# ============================================================================
# Detection System - Desktop Environment & System Detection
# ============================================================================

# Detect Desktop Environment
detect_desktop_environment() {
    local de=""
    
    # Method 1: Check XDG_CURRENT_DESKTOP
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        case "$XDG_CURRENT_DESKTOP" in
            *"GNOME"*|*"gnome"*|*"ubuntu:GNOME"*)
                de="GNOME"
                ;;
            *"KDE"*|*"kde"*)
                de="KDE"
                ;;
            *"XFCE"*|*"xfce"*)
                de="XFCE"
                ;;
            *"MATE"*|*"mate"*)
                de="MATE"
                ;;
            *"Cinnamon"*|*"cinnamon"*|*"X-Cinnamon"*)
                de="Cinnamon"
                ;;
            *"Budgie"*|*"budgie"*)
                de="Budgie"
                ;;
        esac
    fi
    
    # Method 2: Check XDG_SESSION_DESKTOP
    if [[ -z "$de" && -n "$XDG_SESSION_DESKTOP" ]]; then
        case "$XDG_SESSION_DESKTOP" in
            *"gnome"*|*"ubuntu"*)
                de="GNOME"
                ;;
            *"kde"*|*"plasma"*)
                de="KDE"
                ;;
            *"xfce"*)
                de="XFCE"
                ;;
            *"mate"*)
                de="MATE"
                ;;
            *"cinnamon"*)
                de="Cinnamon"
                ;;
            *"budgie"*)
                de="Budgie"
                ;;
        esac
    fi
    
    # Method 3: Process-based detection (fallback)
    if [[ -z "$de" ]]; then
        if pgrep -x "gnome-shell" > /dev/null 2>&1; then
            de="GNOME"
        elif pgrep -x "plasmashell" > /dev/null 2>&1; then
            de="KDE"
        elif pgrep -x "xfce4-session" > /dev/null 2>&1; then
            de="XFCE"
        elif pgrep -x "mate-session" > /dev/null 2>&1; then
            de="MATE"
        elif pgrep -x "cinnamon-session" > /dev/null 2>&1; then
            de="Cinnamon"
        elif pgrep -x "budgie-wm" > /dev/null 2>&1; then
            de="Budgie"
        fi
    fi
    
    # Method 4: Check desktop files
    if [[ -z "$de" ]]; then
        if [[ -f "/usr/share/gnome/gnome-version.xml" ]]; then
            de="GNOME"
        elif [[ -f "/usr/share/xsessions/plasma.desktop" ]]; then
            de="KDE"
        elif [[ -f "/usr/share/xsessions/xfce.desktop" ]]; then
            de="XFCE"
        fi
    fi
    
    # Default to Unknown if nothing detected
    if [[ -z "$de" ]]; then
        de="Unknown"
    fi
    
    echo "$de"
}

# Detect GNOME version
detect_gnome_version() {
    if command -v gnome-shell &> /dev/null; then
        gnome-shell --version 2>/dev/null | cut -d' ' -f3
    else
        echo "N/A"
    fi
}

# Detect KDE version
detect_kde_version() {
    if command -v plasmashell &> /dev/null; then
        plasmashell --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1
    else
        echo "N/A"
    fi
}

# Detect Ubuntu version with LTS status
detect_ubuntu_version() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local version="$VERSION_ID"
        local codename="$VERSION_CODENAME"
        
        # Check if LTS
        if [[ "$VERSION" == *"LTS"* ]]; then
            echo "${version} LTS (${codename})"
        else
            echo "${version} (${codename})"
        fi
    else
        echo "Unknown"
    fi
}

# Get Ubuntu version number only
get_ubuntu_version_number() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$VERSION_ID"
    else
        echo "0.00"
    fi
}

# Check if Ubuntu version is supported
is_ubuntu_version_supported() {
    local version=$(get_ubuntu_version_number)
    
    for supported in "${SUPPORTED_UBUNTU_VERSIONS[@]}"; do
        if [[ "$version" == "$supported" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Detect ZSH framework
detect_zsh_framework() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "Bash"
        return
    fi
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Oh My Zsh"
    elif [[ -d "$HOME/.zprezto" ]]; then
        echo "Prezto"
    elif [[ -d "$HOME/.zim" ]]; then
        echo "Zim"
    elif [[ -d "$HOME/.zinit" ]]; then
        echo "Zinit"
    elif [[ -d "$HOME/.antigen" ]]; then
        echo "Antigen"
    else
        echo "ZSH (Vanilla)"
    fi
}

# Check if ZSH is being used
is_zsh_active() {
    [[ "$SHELL" == *"zsh"* ]] && return 0 || return 1
}

# Detect system memory
detect_system_memory() {
    local mem_gb=$(free -g | awk 'NR==2{print $2}')
    echo "${mem_gb}GB"
}

# Detect GPU
detect_gpu() {
    if command -v lspci &> /dev/null; then
        local gpu=$(lspci | grep -i vga | head -1 | cut -d':' -f3 | sed 's/^[ \t]*//')
        echo "$gpu"
    else
        echo "Unknown"
    fi
}

# Detect GPU vendor
detect_gpu_vendor() {
    local gpu=$(detect_gpu)
    
    if [[ "$gpu" == *"NVIDIA"* || "$gpu" == *"nVidia"* ]]; then
        echo "NVIDIA"
    elif [[ "$gpu" == *"AMD"* || "$gpu" == *"Radeon"* ]]; then
        echo "AMD"
    elif [[ "$gpu" == *"Intel"* ]]; then
        echo "Intel"
    else
        echo "Unknown"
    fi
}

# Detect screen resolution
detect_screen_resolution() {
    if command -v xrandr &> /dev/null; then
        xrandr | grep '*' | awk '{print $1}' | head -1
    else
        echo "Unknown"
    fi
}

# Check if system is a laptop
is_laptop() {
    if [[ -d /sys/class/power_supply/BAT* ]] || [[ -d /sys/class/power_supply/battery ]]; then
        return 0
    else
        return 1
    fi
}

# Check if Desktop Environment is supported
is_de_supported() {
    local de="$1"
    
    for supported_de in "${SUPPORTED_DES[@]}"; do
        if [[ "$de" == "$supported_de" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Get DE configuration tool
get_de_config_tool() {
    local de="$1"
    
    case "$de" in
        "GNOME")
            echo "gnome-tweaks"
            ;;
        "KDE")
            echo "systemsettings5"
            ;;
        "XFCE")
            echo "xfce4-appearance-settings"
            ;;
        "MATE")
            echo "mate-appearance-properties"
            ;;
        "Cinnamon")
            echo "cinnamon-settings"
            ;;
        "Budgie")
            echo "budgie-desktop-settings"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if DE config tool is installed
is_de_config_tool_installed() {
    local tool=$(get_de_config_tool "$DETECTED_DE")
    command -v "$tool" &> /dev/null
}

# Detect GTK version
detect_gtk_version() {
    if command -v pkg-config &> /dev/null; then
        local gtk3=$(pkg-config --modversion gtk+-3.0 2>/dev/null)
        local gtk4=$(pkg-config --modversion gtk4 2>/dev/null)
        
        if [[ -n "$gtk4" ]]; then
            echo "GTK4: $gtk4, GTK3: $gtk3"
        elif [[ -n "$gtk3" ]]; then
            echo "GTK3: $gtk3"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# Get current theme name (DE-agnostic)
get_current_theme_name() {
    case "$DETECTED_DE" in
        "GNOME"|"Budgie")
            gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'"
            ;;
        "KDE")
            kreadconfig5 --group "General" --key "ColorScheme" 2>/dev/null
            ;;
        "XFCE")
            xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null
            ;;
        "MATE")
            gsettings get org.mate.interface gtk-theme 2>/dev/null | tr -d "'"
            ;;
        "Cinnamon")
            gsettings get org.cinnamon.desktop.interface gtk-theme 2>/dev/null | tr -d "'"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# Get compatible themes for current DE
get_compatible_themes() {
    local de="$1"
    
    # All themes work with GTK-based DEs
    case "$de" in
        "GNOME"|"XFCE"|"MATE"|"Cinnamon"|"Budgie")
            echo "arc yaru pop dracula nord catppuccin gruvbox tokyonight cyberpunk"
            ;;
        "KDE")
            # KDE has different theme structure, but GTK themes can still be used
            echo "arc yaru pop dracula nord catppuccin gruvbox tokyonight"
            ;;
        *)
            echo ""
            ;;
    esac
}

# System summary
print_system_summary() {
    log_info "Sistem Özeti:"
    echo
    echo "  Desktop Environment: $(detect_desktop_environment)"
    echo "  Ubuntu Version: $(detect_ubuntu_version)"
    echo "  Shell: $(detect_zsh_framework)"
    echo "  Memory: $(detect_system_memory)"
    echo "  GPU: $(detect_gpu_vendor)"
    echo "  Resolution: $(detect_screen_resolution)"
    echo "  GTK Version: $(detect_gtk_version)"
    echo "  Current Theme: $(get_current_theme_name)"
    echo
}