#!/bin/bash

# ============================================================================
# CATPPUCCIN THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Catppuccin theme installation and management
# Dependencies: wget, tar, unzip or git
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: MIT
# ============================================================================

# === GLOBAL VARIABLES ===
readonly CATPPUCCIN_THEME_NAME="Catppuccin"
readonly CATPPUCCIN_GTK_REPO="https://github.com/catppuccin/gtk"
readonly CATPPUCCIN_GTK_RELEASE_API="https://api.github.com/repos/catppuccin/gtk/releases/latest"

# Installation paths
readonly CATPPUCCIN_USER_PATH="$HOME/.themes"
readonly CATPPUCCIN_ICONS_PATH="$HOME/.icons"

# Catppuccin flavors
readonly -a CATPPUCCIN_FLAVORS=(
    "latte"
    "frappe"
    "macchiato"
    "mocha"
)

# Catppuccin accents
readonly -a CATPPUCCIN_ACCENTS=(
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
)

# Mocha colors (most popular flavor)
readonly CATPPUCCIN_MOCHA_BASE="#1e1e2e"
readonly CATPPUCCIN_MOCHA_MANTLE="#181825"
readonly CATPPUCCIN_MOCHA_CRUST="#11111b"
readonly CATPPUCCIN_MOCHA_TEXT="#cdd6f4"
readonly CATPPUCCIN_MOCHA_SUBTEXT1="#bac2de"
readonly CATPPUCCIN_MOCHA_SUBTEXT0="#a6adc8"
readonly CATPPUCCIN_MOCHA_OVERLAY2="#9399b2"
readonly CATPPUCCIN_MOCHA_OVERLAY1="#7f849c"
readonly CATPPUCCIN_MOCHA_OVERLAY0="#6c7086"
readonly CATPPUCCIN_MOCHA_SURFACE2="#585b70"
readonly CATPPUCCIN_MOCHA_SURFACE1="#45475a"
readonly CATPPUCCIN_MOCHA_SURFACE0="#313244"
readonly CATPPUCCIN_MOCHA_BLUE="#89b4fa"
readonly CATPPUCCIN_MOCHA_LAVENDER="#b4befe"
readonly CATPPUCCIN_MOCHA_SAPPHIRE="#74c7ec"
readonly CATPPUCCIN_MOCHA_SKY="#89dceb"
readonly CATPPUCCIN_MOCHA_TEAL="#94e2d5"
readonly CATPPUCCIN_MOCHA_GREEN="#a6e3a1"
readonly CATPPUCCIN_MOCHA_YELLOW="#f9e2af"
readonly CATPPUCCIN_MOCHA_PEACH="#fab387"
readonly CATPPUCCIN_MOCHA_MAROON="#eba0ac"
readonly CATPPUCCIN_MOCHA_RED="#f38ba8"
readonly CATPPUCCIN_MOCHA_MAUVE="#cba6f7"
readonly CATPPUCCIN_MOCHA_PINK="#f5c2e7"
readonly CATPPUCCIN_MOCHA_FLAMINGO="#f2cdcd"
readonly CATPPUCCIN_MOCHA_ROSEWATER="#f5e0dc"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_catppuccin_theme() {
    log_info "Starting Catppuccin theme installation..."
    
    if verify_catppuccin_installation; then
        log_success "Catppuccin theme is already installed!"
        return 0
    fi
    
    if ! check_catppuccin_dependencies; then
        return 1
    fi
    
    mkdir -p "$CATPPUCCIN_USER_PATH" || {
        log_error "Failed to create themes directory"
        return 1
    }
    
    # Try GitHub releases (best method for Catppuccin)
    if install_catppuccin_from_release; then
        return 0
    fi
    
    # Fallback: git clone
    if command -v git &> /dev/null; then
        if install_catppuccin_with_git; then
            return 0
        fi
    fi
    
    log_error "All installation methods failed"
    return 1
}

install_catppuccin_from_release() {
    if ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null; then
        return 1
    fi
    
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Fetching latest Catppuccin release..."
    
    # Get latest release download URL
    local download_url
    download_url=$(curl -s "$CATPPUCCIN_GTK_RELEASE_API" | \
                   grep "browser_download_url.*zip" | \
                   grep -v "sha256sum" | \
                   head -n 1 | \
                   cut -d '"' -f 4)
    
    if [[ -z "$download_url" ]]; then
        log_warning "Could not find release download, trying git..."
        return 1
    fi
    
    log_info "Downloading Catppuccin theme..."
    
    local zip_file="$temp_dir/catppuccin.zip"
    if ! wget -q --show-progress --timeout=30 -O "$zip_file" "$download_url" 2>&1; then
        return 1
    fi
    
    if [[ ! -s "$zip_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Catppuccin theme..."
    
    if ! unzip -q "$zip_file" -d "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    log_info "Installing Catppuccin themes..."
    
    # Install all found theme variants
    local installed=0
    local theme_dirs
    theme_dirs=$(find "$temp_dir" -maxdepth 2 -type d -name "Catppuccin-*")
    
    if [[ -z "$theme_dirs" ]]; then
        log_error "No theme directories found"
        return 1
    fi
    
    while IFS= read -r theme_dir; do
        local theme_name
        theme_name=$(basename "$theme_dir")
        local dst="$CATPPUCCIN_USER_PATH/$theme_name"
        
        if cp -r "$theme_dir" "$dst" 2>&1; then
            log_success "  Installed: $theme_name"
            ((installed++))
        fi
    done <<< "$theme_dirs"
    
    if [[ $installed -gt 0 ]]; then
        log_success "Installed $installed Catppuccin variant(s)"
        verify_catppuccin_installation && return 0
    fi
    
    return 1
}

install_catppuccin_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Catppuccin GTK repository..."
    
    if ! git clone --depth=1 "$CATPPUCCIN_GTK_REPO" "$temp_dir/catppuccin-gtk" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    log_info "Building Catppuccin themes..."
    
    # Catppuccin provides build scripts
    cd "$temp_dir/catppuccin-gtk" || return 1
    
    # Build default (mocha) variant
    if [[ -x "./install.sh" ]]; then
        if ./install.sh -d "$CATPPUCCIN_USER_PATH" -a blue &> /dev/null; then
            log_success "Catppuccin theme installed"
            verify_catppuccin_installation && return 0
        fi
    fi
    
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

verify_catppuccin_installation() {
    [[ ! -d "$CATPPUCCIN_USER_PATH" ]] && return 1
    
    # Look for any Catppuccin theme
    local found=false
    for theme in "$CATPPUCCIN_USER_PATH"/Catppuccin-*; do
        if [[ -d "$theme" ]]; then
            if [[ -f "$theme/index.theme" ]] || [[ -d "$theme/gtk-3.0" ]]; then
                found=true
                break
            fi
        fi
    done
    
    [[ "$found" == true ]] && return 0 || return 1
}

get_installed_catppuccin_variants() {
    local variants=()
    
    [[ ! -d "$CATPPUCCIN_USER_PATH" ]] && return 0
    
    for theme in "$CATPPUCCIN_USER_PATH"/Catppuccin-*; do
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

get_catppuccin_metadata() {
    cat <<EOF
name=Catppuccin
display_name=Catppuccin
description=Soothing pastel theme for coders and designers
variants=Multiple (flavor × accent combinations)
flavors=${CATPPUCCIN_FLAVORS[*]}
accents=${CATPPUCCIN_ACCENTS[*]}
icons=Papirus,Tela
cursor=Catppuccin-Cursors (optional)
source_primary=github:catppuccin/gtk
source_type=git+releases
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=97
maintenance=active
license=MIT
author=Catppuccin Community
year=2021
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=yes
color_scheme=dark+light
accent_colors=14
flavors_count=4
total_combinations=56+
target_audience=developers,designers,artists
community_size=very_large
ports_available=200+
website=https://catppuccin.com
instagram_aesthetic=yes
trending=high
best_flavor=mocha
best_accent=blue,mauve,lavender
EOF
    return 0
}

get_catppuccin_variants() {
    # Generate list of possible variants
    for flavor in "${CATPPUCCIN_FLAVORS[@]}"; do
        echo "Catppuccin-${flavor^}"
    done
    return 0
}

get_catppuccin_color_palette() {
    local flavor="${1:-mocha}"
    
    case "$flavor" in
        mocha)
            cat <<EOF
base=$CATPPUCCIN_MOCHA_BASE
mantle=$CATPPUCCIN_MOCHA_MANTLE
crust=$CATPPUCCIN_MOCHA_CRUST
text=$CATPPUCCIN_MOCHA_TEXT
subtext1=$CATPPUCCIN_MOCHA_SUBTEXT1
subtext0=$CATPPUCCIN_MOCHA_SUBTEXT0
overlay2=$CATPPUCCIN_MOCHA_OVERLAY2
overlay1=$CATPPUCCIN_MOCHA_OVERLAY1
overlay0=$CATPPUCCIN_MOCHA_OVERLAY0
surface2=$CATPPUCCIN_MOCHA_SURFACE2
surface1=$CATPPUCCIN_MOCHA_SURFACE1
surface0=$CATPPUCCIN_MOCHA_SURFACE0
blue=$CATPPUCCIN_MOCHA_BLUE
lavender=$CATPPUCCIN_MOCHA_LAVENDER
sapphire=$CATPPUCCIN_MOCHA_SAPPHIRE
sky=$CATPPUCCIN_MOCHA_SKY
teal=$CATPPUCCIN_MOCHA_TEAL
green=$CATPPUCCIN_MOCHA_GREEN
yellow=$CATPPUCCIN_MOCHA_YELLOW
peach=$CATPPUCCIN_MOCHA_PEACH
maroon=$CATPPUCCIN_MOCHA_MAROON
red=$CATPPUCCIN_MOCHA_RED
mauve=$CATPPUCCIN_MOCHA_MAUVE
pink=$CATPPUCCIN_MOCHA_PINK
flamingo=$CATPPUCCIN_MOCHA_FLAMINGO
rosewater=$CATPPUCCIN_MOCHA_ROSEWATER
flavor=mocha (dark, most popular)
EOF
            ;;
        *)
            echo "flavor_not_loaded=true"
            echo "available_flavors=${CATPPUCCIN_FLAVORS[*]}"
            ;;
    esac
    return 0
}

get_catppuccin_recommended_variant() {
    local preference="${1:-dark}"
    local accent="${2:-blue}"
    
    case "$preference" in
        light)
            echo "Catppuccin-Latte-${accent^}"
            ;;
        dark|mocha)
            echo "Catppuccin-Mocha-${accent^}"
            ;;
        frappe)
            echo "Catppuccin-Frappe-${accent^}"
            ;;
        macchiato)
            echo "Catppuccin-Macchiato-${accent^}"
            ;;
        *)
            echo "Catppuccin-Mocha-Blue"
            ;;
    esac
    return 0
}

get_catppuccin_flavor_info() {
    local flavor="${1:-mocha}"
    
    case "$flavor" in
        latte)
            echo "type=light"
            echo "description=Light and warm"
            echo "base_color=#eff1f5"
            echo "mood=energetic,cheerful"
            ;;
        frappe)
            echo "type=dark"
            echo "description=Dark with subtle contrast"
            echo "base_color=#303446"
            echo "mood=calm,elegant"
            ;;
        macchiato)
            echo "type=dark"
            echo "description=Mid-tone dark theme"
            echo "base_color=#24273a"
            echo "mood=balanced,professional"
            ;;
        mocha)
            echo "type=dark"
            echo "description=Darkest, high contrast"
            echo "base_color=#1e1e2e"
            echo "mood=focused,immersive"
            echo "most_popular=yes"
            ;;
    esac
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup_catppuccin_theme() {
    log_info "Cleaning up Catppuccin theme..."
    
    local removed=0
    for theme in "$CATPPUCCIN_USER_PATH"/Catppuccin-*; do
        if [[ -d "$theme" ]]; then
            local name
            name=$(basename "$theme")
            if rm -rf "$theme" 2>&1; then
                log_success "Removed: $name"
                ((removed++))
            fi
        fi
    done
    
    [[ $removed -gt 0 ]] && log_success "Catppuccin cleanup completed ($removed variants)"
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

check_catppuccin_dependencies() {
    local has_method=false
    
    if command -v curl &> /dev/null && command -v unzip &> /dev/null; then
        has_method=true
    fi
    
    if command -v git &> /dev/null; then
        has_method=true
    fi
    
    if [[ "$has_method" == false ]]; then
        log_error "No suitable installation method"
        log_info "Install: sudo apt install curl unzip git"
        return 1
    fi
    
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Catppuccin Theme Module Test ==="
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
    check_catppuccin_dependencies
    
    echo
    echo "2. Installation status:"
    if verify_catppuccin_installation; then
        echo "✓ Installed: $(get_installed_catppuccin_variants)"
    else
        echo "✗ Not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_catppuccin_metadata
    
    echo
    echo "4. Mocha Color Palette:"
    get_catppuccin_color_palette "mocha"
    
    echo
    echo "=== Test Complete ==="
fi
