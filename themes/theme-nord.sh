#!/bin/bash

# ============================================================================
# NORD THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Nord theme installation and management
# Dependencies: wget, tar or git
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: MIT
# ============================================================================

# === GLOBAL VARIABLES ===
readonly NORD_THEME_NAME="Nord"
readonly NORD_GTK_REPO="https://github.com/EliverLara/Nordic"
readonly NORD_GTK_LATEST="https://github.com/EliverLara/Nordic/archive/refs/heads/master.tar.gz"

# Installation paths
readonly NORD_USER_PATH="$HOME/.themes"
readonly NORD_ICONS_PATH="$HOME/.icons"

# Variants (Nordic theme provides these)
readonly -a NORD_VARIANTS=(
    "Nordic"
    "Nordic-darker"
    "Nordic-Polar"
    "Nordic-bluish-accent"
)

# Official Nord color palette
readonly NORD_POLAR_NIGHT_0="#2e3440"
readonly NORD_POLAR_NIGHT_1="#3b4252"
readonly NORD_POLAR_NIGHT_2="#434c5e"
readonly NORD_POLAR_NIGHT_3="#4c566a"
readonly NORD_SNOW_STORM_0="#d8dee9"
readonly NORD_SNOW_STORM_1="#e5e9f0"
readonly NORD_SNOW_STORM_2="#eceff4"
readonly NORD_FROST_0="#8fbcbb"
readonly NORD_FROST_1="#88c0d0"
readonly NORD_FROST_2="#81a1c1"
readonly NORD_FROST_3="#5e81ac"
readonly NORD_AURORA_0="#bf616a"
readonly NORD_AURORA_1="#d08770"
readonly NORD_AURORA_2="#ebcb8b"
readonly NORD_AURORA_3="#a3be8c"
readonly NORD_AURORA_4="#b48ead"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_nord_theme() {
    log_info "Starting Nord (Nordic) theme installation..."
    
    if verify_nord_installation; then
        log_success "Nord theme is already installed!"
        return 0
    fi
    
    if ! check_nord_dependencies; then
        return 1
    fi
    
    mkdir -p "$NORD_USER_PATH" || {
        log_error "Failed to create themes directory"
        return 1
    }
    
    # Try git first, fallback to wget
    if command -v git &> /dev/null; then
        if install_nord_with_git; then
            return 0
        fi
    fi
    
    if command -v wget &> /dev/null && command -v tar &> /dev/null; then
        if install_nord_with_wget; then
            return 0
        fi
    fi
    
    log_error "All installation methods failed"
    log_info "Manual install: git clone $NORD_GTK_REPO ~/.themes/Nordic"
    return 1
}

install_nord_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Nordic theme repository..."
    
    if ! git clone --depth=1 "$NORD_GTK_REPO" "$temp_dir/Nordic" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    log_info "Installing Nordic variants..."
    
    # Nordic repo contains multiple variants
    local installed=0
    for variant in Nordic Nordic-darker Nordic-Polar Nordic-bluish-accent; do
        local src="$temp_dir/Nordic/$variant"
        local dst="$NORD_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    if [[ $installed -gt 0 ]]; then
        log_success "Installed $installed Nordic variant(s)"
        verify_nord_installation && return 0
    fi
    
    return 1
}

install_nord_with_wget() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    local tar_file="$temp_dir/nordic.tar.gz"
    
    log_info "Downloading Nordic theme..."
    
    if ! wget -q --show-progress --timeout=30 -O "$tar_file" "$NORD_GTK_LATEST" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    if [[ ! -s "$tar_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Nordic theme..."
    
    if ! tar -xzf "$tar_file" -C "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Nordic*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted directory"
        return 1
    fi
    
    log_info "Installing Nordic variants..."
    
    local installed=0
    for variant in Nordic Nordic-darker Nordic-Polar Nordic-bluish-accent; do
        local src="$extracted_dir/$variant"
        local dst="$NORD_USER_PATH/$variant"
        
        if [[ -d "$src" ]]; then
            if cp -r "$src" "$dst" 2>&1; then
                log_success "  Installed: $variant"
                ((installed++))
            fi
        fi
    done
    
    [[ $installed -gt 0 ]] && verify_nord_installation && return 0
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

verify_nord_installation() {
    for variant in "${NORD_VARIANTS[@]}"; do
        if [[ -d "$NORD_USER_PATH/$variant" ]]; then
            if [[ -d "$NORD_USER_PATH/$variant/gtk-3.0" ]] || \
               [[ -f "$NORD_USER_PATH/$variant/index.theme" ]]; then
                return 0
            fi
        fi
    done
    return 1
}

get_installed_nord_variants() {
    local variants=()
    for variant in "${NORD_VARIANTS[@]}"; do
        [[ -d "$NORD_USER_PATH/$variant" ]] && variants+=("$variant")
    done
    echo "${variants[@]}"
    return 0
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

get_nord_metadata() {
    cat <<EOF
name=Nord
display_name=Nord (Nordic)
description=Arctic, north-bluish color palette theme
variants=${NORD_VARIANTS[*]}
icons=Papirus-Dark,Zafiro-Nord
cursor=Adwaita
source_primary=github:EliverLara/Nordic
source_type=git
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=94
maintenance=active
license=MIT
author=EliverLara
year=2019
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=partial
color_scheme=dark
accent_color=blue,frost
target_audience=minimalists,designers,nordic_fans
palette_name=Nord by Arctic Ice Studio
color_harmony=excellent
contrast=medium
readability=high
best_for=long_sessions,design_work,photography
mood=calm,professional,cold
season=winter,autumn
complementary_icons=Papirus-Dark,Numix-Circle
EOF
    return 0
}

get_nord_variants() {
    printf '%s\n' "${NORD_VARIANTS[@]}"
    return 0
}

get_nord_color_palette() {
    cat <<EOF
polar_night_0=$NORD_POLAR_NIGHT_0
polar_night_1=$NORD_POLAR_NIGHT_1
polar_night_2=$NORD_POLAR_NIGHT_2
polar_night_3=$NORD_POLAR_NIGHT_3
snow_storm_0=$NORD_SNOW_STORM_0
snow_storm_1=$NORD_SNOW_STORM_1
snow_storm_2=$NORD_SNOW_STORM_2
frost_0=$NORD_FROST_0
frost_1=$NORD_FROST_1
frost_2=$NORD_FROST_2
frost_3=$NORD_FROST_3
aurora_0=$NORD_AURORA_0
aurora_1=$NORD_AURORA_1
aurora_2=$NORD_AURORA_2
aurora_3=$NORD_AURORA_3
aurora_4=$NORD_AURORA_4
primary_bg=$NORD_POLAR_NIGHT_0
primary_fg=$NORD_SNOW_STORM_2
accent=$NORD_FROST_2
inspiration=Arctic landscapes and aurora borealis
EOF
    return 0
}

get_nord_recommended_variant() {
    local preference="${1:-standard}"
    
    case "$preference" in
        darker|darkest)
            echo "Nordic-darker"
            ;;
        lighter|polar)
            echo "Nordic-Polar"
            ;;
        blue|bluish)
            echo "Nordic-bluish-accent"
            ;;
        *)
            echo "Nordic"
            ;;
    esac
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup_nord_theme() {
    log_info "Cleaning up Nord theme..."
    
    local removed=0
    for variant in "${NORD_VARIANTS[@]}"; do
        local path="$NORD_USER_PATH/$variant"
        if [[ -d "$path" ]]; then
            if rm -rf "$path" 2>&1; then
                log_success "Removed: $variant"
                ((removed++))
            fi
        fi
    done
    
    [[ $removed -gt 0 ]] && log_success "Nord cleanup completed ($removed variants)"
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

check_nord_dependencies() {
    if ! command -v git &> /dev/null && \
       { ! command -v wget &> /dev/null || ! command -v tar &> /dev/null; }; then
        log_error "No suitable download method"
        log_info "Install: sudo apt install git OR sudo apt install wget tar"
        return 1
    fi
    return 0
}

update_nord_theme() {
    log_info "Updating Nord theme..."
    
    local any_updated=false
    for variant in "${NORD_VARIANTS[@]}"; do
        local path="$NORD_USER_PATH/$variant"
        if [[ -d "$path/.git" ]] && command -v git &> /dev/null; then
            if (cd "$path" && git pull &> /dev/null); then
                log_success "Updated: $variant"
                any_updated=true
            fi
        fi
    done
    
    if [[ "$any_updated" == false ]]; then
        log_info "Reinstalling to get latest version..."
        cleanup_nord_theme
        install_nord_theme
    else
        log_success "Nord theme updated"
    fi
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Nord Theme Module Test ==="
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
    check_nord_dependencies
    
    echo
    echo "2. Installation status:"
    if verify_nord_installation; then
        echo "✓ Installed variants: $(get_installed_nord_variants)"
    else
        echo "✗ Not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_nord_metadata
    
    echo
    echo "4. Color Palette:"
    get_nord_color_palette
    
    echo
    echo "=== Test Complete ==="
fi
