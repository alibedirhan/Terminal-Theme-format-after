#!/bin/bash

# ============================================================================
# GRUVBOX THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Gruvbox theme installation and management
# Dependencies: wget, tar or git
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: MIT
# ============================================================================

# === GLOBAL VARIABLES ===
readonly GRUVBOX_THEME_NAME="Gruvbox"
readonly GRUVBOX_GTK_REPO="https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
readonly GRUVBOX_GTK_LATEST="https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme/archive/refs/heads/main.zip"

# Installation paths
readonly GRUVBOX_USER_PATH="$HOME/.themes"
readonly GRUVBOX_ICONS_PATH="$HOME/.icons"

# Gruvbox variants
readonly -a GRUVBOX_VARIANTS=(
    "Gruvbox-Dark"
    "Gruvbox-Dark-BL"
    "Gruvbox-Dark-B"
    "Gruvbox-Dark-BL-LB"
    "Gruvbox-Light"
)

# Official Gruvbox color palette (dark)
readonly GRUVBOX_DARK_BG0_HARD="#1d2021"
readonly GRUVBOX_DARK_BG0="#282828"
readonly GRUVBOX_DARK_BG0_SOFT="#32302f"
readonly GRUVBOX_DARK_BG1="#3c3836"
readonly GRUVBOX_DARK_BG2="#504945"
readonly GRUVBOX_DARK_BG3="#665c54"
readonly GRUVBOX_DARK_BG4="#7c6f64"
readonly GRUVBOX_DARK_FG0="#fbf1c7"
readonly GRUVBOX_DARK_FG1="#ebdbb2"
readonly GRUVBOX_DARK_FG2="#d5c4a1"
readonly GRUVBOX_DARK_FG3="#bdae93"
readonly GRUVBOX_DARK_FG4="#a89984"
readonly GRUVBOX_RED="#cc241d"
readonly GRUVBOX_GREEN="#98971a"
readonly GRUVBOX_YELLOW="#d79921"
readonly GRUVBOX_BLUE="#458588"
readonly GRUVBOX_PURPLE="#b16286"
readonly GRUVBOX_AQUA="#689d6a"
readonly GRUVBOX_ORANGE="#d65d0e"
readonly GRUVBOX_GRAY="#928374"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_gruvbox_theme() {
    log_info "Starting Gruvbox theme installation..."
    
    if verify_gruvbox_installation; then
        log_success "Gruvbox theme is already installed!"
        return 0
    fi
    
    if ! check_gruvbox_dependencies; then
        return 1
    fi
    
    mkdir -p "$GRUVBOX_USER_PATH" || {
        log_error "Failed to create themes directory"
        return 1
    }
    
    # Try wget+unzip (GitHub release)
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        if install_gruvbox_with_wget; then
            return 0
        fi
    fi
    
    # Fallback: git clone
    if command -v git &> /dev/null; then
        if install_gruvbox_with_git; then
            return 0
        fi
    fi
    
    log_error "All installation methods failed"
    log_info "Manual install: git clone $GRUVBOX_GTK_REPO ~/.themes/"
    return 1
}

install_gruvbox_with_wget() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    local zip_file="$temp_dir/gruvbox.zip"
    
    log_info "Downloading Gruvbox theme..."
    
    if ! wget -q --show-progress --timeout=30 -O "$zip_file" "$GRUVBOX_GTK_LATEST" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    if [[ ! -s "$zip_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Gruvbox theme..."
    
    if ! unzip -q "$zip_file" -d "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Gruvbox-GTK-Theme*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted directory"
        return 1
    fi
    
    log_info "Installing Gruvbox variants..."
    
    # Look for themes directory in the repo
    local themes_dir="$extracted_dir/themes"
    if [[ ! -d "$themes_dir" ]]; then
        # Try alternative structure
        themes_dir="$extracted_dir"
    fi
    
    local installed=0
    for variant in "${GRUVBOX_VARIANTS[@]}"; do
        local src="$themes_dir/$variant"
        local dst="$GRUVBOX_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    if [[ $installed -eq 0 ]]; then
        # Try to install any Gruvbox-* directories found
        while IFS= read -r gruvbox_dir; do
            if [[ -d "$gruvbox_dir" ]]; then
                local name
                name=$(basename "$gruvbox_dir")
                local dst="$GRUVBOX_USER_PATH/$name"
                
                if cp -r "$gruvbox_dir" "$dst" 2>&1; then
                    log_success "  Installed: $name"
                    ((installed++))
                fi
            fi
        done < <(find "$extracted_dir" -type d -name "Gruvbox-*" | head -n 5)
    fi
    
    if [[ $installed -gt 0 ]]; then
        log_success "Installed $installed Gruvbox variant(s)"
        verify_gruvbox_installation && return 0
    fi
    
    return 1
}

install_gruvbox_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Gruvbox GTK repository..."
    
    if ! git clone --depth=1 "$GRUVBOX_GTK_REPO" "$temp_dir/gruvbox-gtk" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    log_info "Installing Gruvbox themes..."
    
    local themes_dir="$temp_dir/gruvbox-gtk/themes"
    if [[ ! -d "$themes_dir" ]]; then
        themes_dir="$temp_dir/gruvbox-gtk"
    fi
    
    local installed=0
    for variant in "${GRUVBOX_VARIANTS[@]}"; do
        local src="$themes_dir/$variant"
        local dst="$GRUVBOX_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    if [[ $installed -eq 0 ]]; then
        # Install any Gruvbox theme found
        while IFS= read -r gruvbox_dir; do
            if [[ -d "$gruvbox_dir" ]]; then
                local name
                name=$(basename "$gruvbox_dir")
                local dst="$GRUVBOX_USER_PATH/$name"
                
                if cp -r "$gruvbox_dir" "$dst" 2>&1; then
                    log_success "  Installed: $name"
                    ((installed++))
                fi
            fi
        done < <(find "$temp_dir/gruvbox-gtk" -type d -name "Gruvbox-*" | head -n 5)
    fi
    
    [[ $installed -gt 0 ]] && verify_gruvbox_installation && return 0
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

verify_gruvbox_installation() {
    [[ ! -d "$GRUVBOX_USER_PATH" ]] && return 1
    
    # Look for any Gruvbox theme
    for theme in "$GRUVBOX_USER_PATH"/Gruvbox*; do
        if [[ -d "$theme" ]]; then
            if [[ -f "$theme/index.theme" ]] || [[ -d "$theme/gtk-3.0" ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

get_installed_gruvbox_variants() {
    local variants=()
    
    [[ ! -d "$GRUVBOX_USER_PATH" ]] && return 0
    
    for theme in "$GRUVBOX_USER_PATH"/Gruvbox*; do
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

get_gruvbox_metadata() {
    cat <<EOF
name=Gruvbox
display_name=Gruvbox
description=Retro groove color scheme with warm, earthy tones
variants=${GRUVBOX_VARIANTS[*]}
icons=Papirus-Dark,Numix-Circle
cursor=Adwaita
source_primary=github:Fausto-Korpsvart/Gruvbox-GTK-Theme
source_type=git
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=93
maintenance=active
license=MIT
author=Fausto Korpsvart (original by morhetz)
year=2022
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=partial
color_scheme=dark+light
accent_color=orange,yellow
target_audience=vim_users,retro_lovers,developers
original_for=Vim editor
vim_heritage=yes
mood=warm,nostalgic,comfortable
contrast=medium-high
readability=excellent
best_for=coding,terminal_work,long_sessions
eye_strain=very_low
color_temperature=warm
complementary_fonts=JetBrains Mono,Fira Code,Ubuntu Mono
popular_in=developer_community
EOF
    return 0
}

get_gruvbox_variants() {
    printf '%s\n' "${GRUVBOX_VARIANTS[@]}"
    return 0
}

get_gruvbox_color_palette() {
    cat <<EOF
dark_bg0_hard=$GRUVBOX_DARK_BG0_HARD
dark_bg0=$GRUVBOX_DARK_BG0
dark_bg0_soft=$GRUVBOX_DARK_BG0_SOFT
dark_bg1=$GRUVBOX_DARK_BG1
dark_bg2=$GRUVBOX_DARK_BG2
dark_bg3=$GRUVBOX_DARK_BG3
dark_bg4=$GRUVBOX_DARK_BG4
dark_fg0=$GRUVBOX_DARK_FG0
dark_fg1=$GRUVBOX_DARK_FG1
dark_fg2=$GRUVBOX_DARK_FG2
dark_fg3=$GRUVBOX_DARK_FG3
dark_fg4=$GRUVBOX_DARK_FG4
red=$GRUVBOX_RED
green=$GRUVBOX_GREEN
yellow=$GRUVBOX_YELLOW
blue=$GRUVBOX_BLUE
purple=$GRUVBOX_PURPLE
aqua=$GRUVBOX_AQUA
orange=$GRUVBOX_ORANGE
gray=$GRUVBOX_GRAY
primary_bg=$GRUVBOX_DARK_BG0
primary_fg=$GRUVBOX_DARK_FG1
accent=$GRUVBOX_ORANGE
temperature=warm
inspiration=Retro computers and vintage terminals
EOF
    return 0
}

get_gruvbox_recommended_variant() {
    local preference="${1:-dark}"
    
    case "$preference" in
        light)
            echo "Gruvbox-Light"
            ;;
        dark|standard)
            echo "Gruvbox-Dark"
            ;;
        darkest|hard)
            echo "Gruvbox-Dark-BL"
            ;;
        borderless)
            echo "Gruvbox-Dark-B"
            ;;
        *)
            echo "Gruvbox-Dark"
            ;;
    esac
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup_gruvbox_theme() {
    log_info "Cleaning up Gruvbox theme..."
    
    local removed=0
    for theme in "$GRUVBOX_USER_PATH"/Gruvbox*; do
        if [[ -d "$theme" ]]; then
            local name
            name=$(basename "$theme")
            if rm -rf "$theme" 2>&1; then
                log_success "Removed: $name"
                ((removed++))
            fi
        fi
    done
    
    [[ $removed -gt 0 ]] && log_success "Gruvbox cleanup completed ($removed variants)"
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

check_gruvbox_dependencies() {
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

get_gruvbox_vim_config() {
    cat <<EOF
" Gruvbox Vim Configuration
" Add to ~/.vimrc or ~/.config/nvim/init.vim

" Install gruvbox color scheme first:
" vim-plug: Plug 'morhetz/gruvbox'
" Then add:

set background=dark
colorscheme gruvbox
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_italic = 1
EOF
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Gruvbox Theme Module Test ==="
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
    check_gruvbox_dependencies
    
    echo
    echo "2. Installation status:"
    if verify_gruvbox_installation; then
        echo "✓ Installed: $(get_installed_gruvbox_variants)"
    else
        echo "✗ Not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_gruvbox_metadata
    
    echo
    echo "4. Color Palette:"
    get_gruvbox_color_palette
    
    echo
    echo "=== Test Complete ==="
fi
