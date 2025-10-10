#!/bin/bash

# ============================================================================
# TOKYO NIGHT THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Tokyo Night theme installation and management
# Dependencies: wget, tar or git
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: MIT
# ============================================================================

# === GLOBAL VARIABLES ===
readonly TOKYONIGHT_THEME_NAME="TokyoNight"
readonly TOKYONIGHT_GTK_REPO="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme"
readonly TOKYONIGHT_GTK_LATEST="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/main.zip"

# Installation paths
readonly TOKYONIGHT_USER_PATH="$HOME/.themes"
readonly TOKYONIGHT_ICONS_PATH="$HOME/.icons"

# Tokyo Night variants
readonly -a TOKYONIGHT_VARIANTS=(
    "Tokyonight-Dark"
    "Tokyonight-Dark-BL"
    "Tokyonight-Dark-B"
    "Tokyonight-Storm"
    "Tokyonight-Storm-BL"
    "Tokyonight-Storm-B"
    "Tokyonight-Light"
)

# Tokyo Night Storm color palette (most popular)
readonly TOKYONIGHT_BG="#24283b"
readonly TOKYONIGHT_BG_DARK="#1f2335"
readonly TOKYONIGHT_BG_HIGHLIGHT="#292e42"
readonly TOKYONIGHT_TERMINAL_BLACK="#414868"
readonly TOKYONIGHT_FG="#c0caf5"
readonly TOKYONIGHT_FG_DARK="#a9b1d6"
readonly TOKYONIGHT_FG_GUTTER="#3b4261"
readonly TOKYONIGHT_DARK3="#545c7e"
readonly TOKYONIGHT_COMMENT="#565f89"
readonly TOKYONIGHT_DARK5="#737aa2"
readonly TOKYONIGHT_BLUE0="#3d59a1"
readonly TOKYONIGHT_BLUE="#7aa2f7"
readonly TOKYONIGHT_CYAN="#7dcfff"
readonly TOKYONIGHT_BLUE1="#2ac3de"
readonly TOKYONIGHT_BLUE2="#0db9d7"
readonly TOKYONIGHT_BLUE5="#89ddff"
readonly TOKYONIGHT_BLUE6="#b4f9f8"
readonly TOKYONIGHT_BLUE7="#394b70"
readonly TOKYONIGHT_MAGENTA="#bb9af7"
readonly TOKYONIGHT_MAGENTA2="#ff007c"
readonly TOKYONIGHT_PURPLE="#9d7cd8"
readonly TOKYONIGHT_ORANGE="#ff9e64"
readonly TOKYONIGHT_YELLOW="#e0af68"
readonly TOKYONIGHT_GREEN="#9ece6a"
readonly TOKYONIGHT_GREEN1="#73daca"
readonly TOKYONIGHT_GREEN2="#41a6b5"
readonly TOKYONIGHT_TEAL="#1abc9c"
readonly TOKYONIGHT_RED="#f7768e"
readonly TOKYONIGHT_RED1="#db4b4b"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_tokyonight_theme() {
    log_info "Starting Tokyo Night theme installation..."
    
    if verify_tokyonight_installation; then
        log_success "Tokyo Night theme is already installed!"
        return 0
    fi
    
    if ! check_tokyonight_dependencies; then
        return 1
    fi
    
    mkdir -p "$TOKYONIGHT_USER_PATH" || {
        log_error "Failed to create themes directory"
        return 1
    }
    
    # Try wget+unzip
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        if install_tokyonight_with_wget; then
            return 0
        fi
    fi
    
    # Fallback: git
    if command -v git &> /dev/null; then
        if install_tokyonight_with_git; then
            return 0
        fi
    fi
    
    log_error "All installation methods failed"
    log_info "Manual: git clone $TOKYONIGHT_GTK_REPO ~/.themes/"
    return 1
}

install_tokyonight_with_wget() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    local zip_file="$temp_dir/tokyonight.zip"
    
    log_info "Downloading Tokyo Night theme..."
    
    if ! wget -q --show-progress --timeout=30 -O "$zip_file" "$TOKYONIGHT_GTK_LATEST" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    if [[ ! -s "$zip_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Tokyo Night theme..."
    
    if ! unzip -q "$zip_file" -d "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Tokyo-Night-GTK-Theme*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted directory"
        return 1
    fi
    
    log_info "Installing Tokyo Night variants..."
    
    local themes_dir="$extracted_dir/themes"
    if [[ ! -d "$themes_dir" ]]; then
        themes_dir="$extracted_dir"
    fi
    
    local installed=0
    for variant in "${TOKYONIGHT_VARIANTS[@]}"; do
        local src="$themes_dir/$variant"
        local dst="$TOKYONIGHT_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    if [[ $installed -eq 0 ]]; then
        # Try alternative structure
        while IFS= read -r tokyonight_dir; do
            if [[ -d "$tokyonight_dir" ]]; then
                local name
                name=$(basename "$tokyonight_dir")
                local dst="$TOKYONIGHT_USER_PATH/$name"
                
                if cp -r "$tokyonight_dir" "$dst" 2>&1; then
                    log_success "  Installed: $name"
                    ((installed++))
                fi
            fi
        done < <(find "$extracted_dir" -type d -name "Tokyonight*" | head -n 7)
    fi
    
    if [[ $installed -gt 0 ]]; then
        log_success "Installed $installed Tokyo Night variant(s)"
        verify_tokyonight_installation && return 0
    fi
    
    return 1
}

install_tokyonight_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Tokyo Night GTK repository..."
    
    if ! git clone --depth=1 "$TOKYONIGHT_GTK_REPO" "$temp_dir/tokyonight-gtk" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    log_info "Installing Tokyo Night themes..."
    
    local themes_dir="$temp_dir/tokyonight-gtk/themes"
    if [[ ! -d "$themes_dir" ]]; then
        themes_dir="$temp_dir/tokyonight-gtk"
    fi
    
    local installed=0
    for variant in "${TOKYONIGHT_VARIANTS[@]}"; do
        local src="$themes_dir/$variant"
        local dst="$TOKYONIGHT_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    if [[ $installed -eq 0 ]]; then
        while IFS= read -r tokyonight_dir; do
            if [[ -d "$tokyonight_dir" ]]; then
                local name
                name=$(basename "$tokyonight_dir")
                local dst="$TOKYONIGHT_USER_PATH/$name"
                
                if cp -r "$tokyonight_dir" "$dst" 2>&1; then
                    log_success "  Installed: $name"
                    ((installed++))
                fi
            fi
        done < <(find "$temp_dir/tokyonight-gtk" -type d -name "Tokyonight*" | head -n 7)
    fi
    
    [[ $installed -gt 0 ]] && verify_tokyonight_installation && return 0
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

verify_tokyonight_installation() {
    [[ ! -d "$TOKYONIGHT_USER_PATH" ]] && return 1
    
    for theme in "$TOKYONIGHT_USER_PATH"/Tokyonight*; do
        if [[ -d "$theme" ]]; then
            if [[ -f "$theme/index.theme" ]] || [[ -d "$theme/gtk-3.0" ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

get_installed_tokyonight_variants() {
    local variants=()
    
    [[ ! -d "$TOKYONIGHT_USER_PATH" ]] && return 0
    
    for theme in "$TOKYONIGHT_USER_PATH"/Tokyonight*; do
        if [[ -d "$theme" ]]; then
            local name
            name=$(basename "$theme")
            variants+=("$name")
        fi
    done
    
    echo "${variants[@]}"
    return 0
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

get_tokyonight_metadata() {
    cat <<EOF
name=TokyoNight
display_name=Tokyo Night
description=Dark and vibrant theme inspired by Tokyo at night
variants=${TOKYONIGHT_VARIANTS[*]}
icons=Papirus-Dark,Tela-dark
cursor=Adwaita
source_primary=github:Fausto-Korpsvart/Tokyo-Night-GTK-Theme
source_type=git
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=95
maintenance=active
license=MIT
author=Fausto Korpsvart (original by enkia)
year=2022
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=partial
color_scheme=dark+light
accent_color=blue,purple
target_audience=developers,night_coders,anime_fans
original_for=VS Code
vscode_heritage=yes
mood=vibrant,energetic,neon
contrast=high
readability=excellent
best_for=night_coding,creative_work,streaming
eye_strain=low
color_temperature=cool
complementary_fonts=JetBrains Mono,Fira Code,Cascadia Code
popular_in=developer_community,twitch_streamers
aesthetic=cyberpunk,neon,japanese
time_of_use=night,evening
EOF
    return 0
}

get_tokyonight_variants() {
    printf '%s\n' "${TOKYONIGHT_VARIANTS[@]}"
    return 0
}

get_tokyonight_color_palette() {
    cat <<EOF
bg=$TOKYONIGHT_BG
bg_dark=$TOKYONIGHT_BG_DARK
bg_highlight=$TOKYONIGHT_BG_HIGHLIGHT
terminal_black=$TOKYONIGHT_TERMINAL_BLACK
fg=$TOKYONIGHT_FG
fg_dark=$TOKYONIGHT_FG_DARK
fg_gutter=$TOKYONIGHT_FG_GUTTER
dark3=$TOKYONIGHT_DARK3
comment=$TOKYONIGHT_COMMENT
dark5=$TOKYONIGHT_DARK5
blue0=$TOKYONIGHT_BLUE0
blue=$TOKYONIGHT_BLUE
cyan=$TOKYONIGHT_CYAN
blue1=$TOKYONIGHT_BLUE1
blue2=$TOKYONIGHT_BLUE2
blue5=$TOKYONIGHT_BLUE5
blue6=$TOKYONIGHT_BLUE6
blue7=$TOKYONIGHT_BLUE7
magenta=$TOKYONIGHT_MAGENTA
magenta2=$TOKYONIGHT_MAGENTA2
purple=$TOKYONIGHT_PURPLE
orange=$TOKYONIGHT_ORANGE
yellow=$TOKYONIGHT_YELLOW
green=$TOKYONIGHT_GREEN
green1=$TOKYONIGHT_GREEN1
green2=$TOKYONIGHT_GREEN2
teal=$TOKYONIGHT_TEAL
red=$TOKYONIGHT_RED
red1=$TOKYONIGHT_RED1
primary_bg=$TOKYONIGHT_BG
primary_fg=$TOKYONIGHT_FG
accent=$TOKYONIGHT_BLUE
variant=storm
inspiration=Tokyo cityscape at night
EOF
    return 0
}

get_tokyonight_recommended_variant() {
    local preference="${1:-storm}"
    
    case "$preference" in
        light)
            echo "Tokyonight-Light"
            ;;
        dark|standard)
            echo "Tokyonight-Dark"
            ;;
        storm|recommended)
            echo "Tokyonight-Storm"
            ;;
        borderless)
            echo "Tokyonight-Storm-B"
            ;;
        *)
            echo "Tokyonight-Storm"
            ;;
    esac
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup_tokyonight_theme() {
    log_info "Cleaning up Tokyo Night theme..."
    
    local removed=0
    for theme in "$TOKYONIGHT_USER_PATH"/Tokyonight*; do
        if [[ -d "$theme" ]]; then
            local name
            name=$(basename "$theme")
            if rm -rf "$theme" 2>&1; then
                log_success "Removed: $name"
                ((removed++))
            fi
        fi
    done
    
    [[ $removed -gt 0 ]] && log_success "Tokyo Night cleanup completed ($removed variants)"
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

check_tokyonight_dependencies() {
    local has_method=false
    
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        has_method=true
    fi
    
    if command -v git &> /dev/null; then
        has_method=true
    fi
    
    if [[ "$has_method" == false ]]; then
        log_error "No suitable installation method"
        log_info "Install: sudo apt install wget unzip git"
        return 1
    fi
    
    return 0
}

get_tokyonight_neovim_config() {
    cat <<EOF
-- Tokyo Night Neovim Configuration
-- Add to ~/.config/nvim/init.lua

-- Using packer.nvim:
use 'folke/tokyonight.nvim'

-- Configuration:
require('tokyonight').setup({
  style = 'storm',        -- storm, night, or day
  transparent = false,
  terminal_colors = true,
})

vim.cmd[[colorscheme tokyonight]]
EOF
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Tokyo Night Theme Module Test ==="
    echo
    
    if [[ -f "../core/logger.sh" ]]; then
        source "../core/logger.sh"
    else
        log_info() { echo "[INFO] $*"; }
        log_success() { echo "[SUCCESS] $*"; }
        log_warning() { echo "[WARNING] $*"; }
        log_error() { echo "[ERROR] $*"; }
    fi
    
    echo "1. Dependencies:"
    check_tokyonight_dependencies
    
    echo
    echo "2. Installation status:"
    if verify_tokyonight_installation; then
        echo "✓ Installed: $(get_installed_tokyonight_variants)"
    else
        echo "✗ Not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_tokyonight_metadata
    
    echo
    echo "4. Color Palette:"
    get_tokyonight_color_palette
    
    echo
    echo "=== Test Complete ==="
fi
