#!/bin/bash

# ============================================================================
# CYBERPUNK THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Cyberpunk Neon theme installation and management
# Dependencies: wget, tar or git
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: GPL-3.0
# ============================================================================

# === GLOBAL VARIABLES ===
readonly CYBERPUNK_THEME_NAME="Cyberpunk"
readonly CYBERPUNK_GTK_REPO="https://github.com/Roboron3042/Cyberpunk-Neon"
readonly CYBERPUNK_GTK_LATEST="https://github.com/Roboron3042/Cyberpunk-Neon/archive/refs/heads/master.zip"

# Installation paths
readonly CYBERPUNK_USER_PATH="$HOME/.themes"
readonly CYBERPUNK_ICONS_PATH="$HOME/.icons"

# Cyberpunk variants
readonly -a CYBERPUNK_VARIANTS=(
    "Cyberpunk-Neon"
)

# Cyberpunk Neon color palette
readonly CYBERPUNK_BG="#000b1e"
readonly CYBERPUNK_BG_ALT="#001229"
readonly CYBERPUNK_FG="#0abdc6"
readonly CYBERPUNK_FG_ALT="#00d9ff"
readonly CYBERPUNK_ACCENT="#ea00d9"
readonly CYBERPUNK_ACCENT_ALT="#711c91"
readonly CYBERPUNK_PINK="#ff006d"
readonly CYBERPUNK_CYAN="#0abdc6"
readonly CYBERPUNK_BLUE="#133e7c"
readonly CYBERPUNK_PURPLE="#ea00d9"
readonly CYBERPUNK_YELLOW="#f3e600"
readonly CYBERPUNK_ORANGE="#ff6c11"
readonly CYBERPUNK_GREEN="#00ff9f"
readonly CYBERPUNK_RED="#ff0055"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_cyberpunk_theme() {
    log_info "Starting Cyberpunk Neon theme installation..."
    
    if verify_cyberpunk_installation; then
        log_success "Cyberpunk Neon theme is already installed!"
        return 0
    fi
    
    if ! check_cyberpunk_dependencies; then
        return 1
    fi
    
    mkdir -p "$CYBERPUNK_USER_PATH" "$CYBERPUNK_ICONS_PATH" || {
        log_error "Failed to create theme directories"
        return 1
    }
    
    # Try git clone (recommended)
    if command -v git &> /dev/null; then
        if install_cyberpunk_with_git; then
            return 0
        fi
    fi
    
    # Fallback: wget
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        if install_cyberpunk_with_wget; then
            return 0
        fi
    fi
    
    log_error "All installation methods failed"
    log_info "Manual: git clone $CYBERPUNK_GTK_REPO ~/.themes/"
    return 1
}

install_cyberpunk_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Cyberpunk Neon repository..."
    
    if ! git clone --depth=1 "$CYBERPUNK_GTK_REPO" "$temp_dir/cyberpunk-neon" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    log_info "Installing Cyberpunk Neon theme..."
    
    # Look for installation script
    local repo_dir="$temp_dir/cyberpunk-neon"
    
    if [[ -x "$repo_dir/install.sh" ]]; then
        log_info "Running installation script..."
        
        # Run installer to user directory
        cd "$repo_dir" || return 1
        
        if ./install.sh -d "$CYBERPUNK_USER_PATH" &> /dev/null; then
            log_success "Theme installed via installer script"
            
            if verify_cyberpunk_installation; then
                return 0
            fi
        fi
    fi
    
    # Manual installation fallback
    log_info "Trying manual installation..."
    
    # Look for theme directories
    local theme_found=false
    
    # Try common locations
    for possible_theme in "$repo_dir" "$repo_dir/themes" "$repo_dir/Cyberpunk-Neon"; do
        if [[ -d "$possible_theme" ]]; then
            # Check if it's a valid theme directory
            if [[ -d "$possible_theme/gtk-3.0" ]] || [[ -f "$possible_theme/index.theme" ]]; then
                if cp -r "$possible_theme" "$CYBERPUNK_USER_PATH/Cyberpunk-Neon" 2>&1; then
                    log_success "Theme installed manually"
                    theme_found=true
                    break
                fi
            fi
        fi
    done
    
    # Try to find and install icons
    if [[ -d "$repo_dir/icons" ]]; then
        if cp -r "$repo_dir/icons" "$CYBERPUNK_ICONS_PATH/Cyberpunk-Neon" 2>&1; then
            log_success "Icons installed"
        fi
    fi
    
    if [[ "$theme_found" == true ]]; then
        verify_cyberpunk_installation && return 0
    fi
    
    return 1
}

install_cyberpunk_with_wget() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    trap "rm -rf '$temp_dir'" RETURN
    
    local zip_file="$temp_dir/cyberpunk.zip"
    
    log_info "Downloading Cyberpunk Neon theme..."
    
    if ! wget -q --show-progress --timeout=30 -O "$zip_file" "$CYBERPUNK_GTK_LATEST" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    if [[ ! -s "$zip_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Cyberpunk Neon theme..."
    
    if ! unzip -q "$zip_file" -d "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Cyberpunk-Neon*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted directory"
        return 1
    fi
    
    log_info "Installing Cyberpunk Neon theme..."
    
    # Try installation script
    if [[ -x "$extracted_dir/install.sh" ]]; then
        cd "$extracted_dir" || return 1
        
        if ./install.sh -d "$CYBERPUNK_USER_PATH" &> /dev/null; then
            log_success "Installed via script"
            verify_cyberpunk_installation && return 0
        fi
    fi
    
    # Manual fallback
    local theme_found=false
    for possible_theme in "$extracted_dir" "$extracted_dir/themes" "$extracted_dir/Cyberpunk-Neon"; do
        if [[ -d "$possible_theme" ]]; then
            if [[ -d "$possible_theme/gtk-3.0" ]] || [[ -f "$possible_theme/index.theme" ]]; then
                if cp -r "$possible_theme" "$CYBERPUNK_USER_PATH/Cyberpunk-Neon" 2>&1; then
                    log_success "Installed manually"
                    theme_found=true
                    break
                fi
            fi
        fi
    done
    
    [[ "$theme_found" == true ]] && verify_cyberpunk_installation && return 0
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

verify_cyberpunk_installation() {
    local check_paths=(
        "$CYBERPUNK_USER_PATH/Cyberpunk-Neon"
        "$CYBERPUNK_USER_PATH/Cyberpunk"
    )
    
    for theme_path in "${check_paths[@]}"; do
        if [[ -d "$theme_path" ]]; then
            if [[ -f "$theme_path/index.theme" ]] || [[ -d "$theme_path/gtk-3.0" ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

get_installed_cyberpunk_variants() {
    local components=()
    
    if [[ -d "$CYBERPUNK_USER_PATH/Cyberpunk-Neon" ]]; then
        components+=("GTK")
    fi
    
    if [[ -d "$CYBERPUNK_ICONS_PATH/Cyberpunk-Neon" ]]; then
        components+=("Icons")
    fi
    
    echo "${components[@]}"
    return 0
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

get_cyberpunk_metadata() {
    cat <<EOF
name=Cyberpunk
display_name=Cyberpunk Neon
description=Futuristic neon theme inspired by cyberpunk aesthetics
variants=Cyberpunk-Neon
icons=Cyberpunk-Neon (included)
cursor=System default
source_primary=github:Roboron3042/Cyberpunk-Neon
source_type=git
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=89
maintenance=active
license=GPL-3.0
author=Roboron3042
year=2020
gtk2=yes
gtk3=yes
gtk4=partial
shell_theme=yes
color_scheme=dark
accent_color=cyan,pink,purple
target_audience=gamers,cyberpunk_fans,streamers
mood=futuristic,energetic,neon
contrast=very_high
readability=high
best_for=gaming,entertainment,night_use
eye_strain=moderate
color_temperature=cool
aesthetic=cyberpunk,neon,blade_runner
complementary_fonts=Share Tech Mono,Orbitron,Rajdhani
popular_in=gaming_community,cyberpunk_fans
theme_of=Cyberpunk 2077 inspired
wallpaper_style=neon_cityscape,cyberpunk_art
rgb_friendly=yes
gaming_aesthetic=yes
EOF
    return 0
}

get_cyberpunk_variants() {
    printf '%s\n' "${CYBERPUNK_VARIANTS[@]}"
    return 0
}

get_cyberpunk_color_palette() {
    cat <<EOF
bg=$CYBERPUNK_BG
bg_alt=$CYBERPUNK_BG_ALT
fg=$CYBERPUNK_FG
fg_alt=$CYBERPUNK_FG_ALT
accent=$CYBERPUNK_ACCENT
accent_alt=$CYBERPUNK_ACCENT_ALT
pink=$CYBERPUNK_PINK
cyan=$CYBERPUNK_CYAN
blue=$CYBERPUNK_BLUE
purple=$CYBERPUNK_PURPLE
yellow=$CYBERPUNK_YELLOW
orange=$CYBERPUNK_ORANGE
green=$CYBERPUNK_GREEN
red=$CYBERPUNK_RED
primary_bg=$CYBERPUNK_BG
primary_fg=$CYBERPUNK_CYAN
accent_color=$CYBERPUNK_PURPLE
neon_glow=yes
inspiration=Blade Runner, Cyberpunk 2077, Night City
EOF
    return 0
}

get_cyberpunk_recommended_settings() {
    cat <<EOF
terminal_theme=Cyberpunk Neon (custom)
terminal_font=Share Tech Mono,Orbitron
terminal_font_size=11-12pt
icon_theme=Cyberpunk-Neon (included)
cursor_theme=Breeze (neon variant if available)
shell_theme=Cyberpunk-Neon
wallpaper_type=neon_cityscape,cyberpunk
window_decoration=dark,neon_accent
compositor_effects=blur,glow,transparency
rgb_lighting=sync_with_theme
best_time=night,evening
monitor_brightness=50-70%
blue_light_filter=optional
complementary_apps=Steam,Discord,Gaming apps
avoid_mixing_with=light themes,minimalist themes
enhance_with=Conky,Rainmeter-style widgets
EOF
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup_cyberpunk_theme() {
    log_info "Cleaning up Cyberpunk Neon theme..."
    
    local removed=0
    local paths=(
        "$CYBERPUNK_USER_PATH/Cyberpunk-Neon"
        "$CYBERPUNK_USER_PATH/Cyberpunk"
        "$CYBERPUNK_ICONS_PATH/Cyberpunk-Neon"
    )
    
    for path in "${paths[@]}"; do
        if [[ -d "$path" ]]; then
            if rm -rf "$path" 2>&1; then
                log_success "Removed: $(basename "$path")"
                ((removed++))
            fi
        fi
    done
    
    [[ $removed -gt 0 ]] && log_success "Cyberpunk cleanup completed ($removed items)"
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

check_cyberpunk_dependencies() {
    local has_method=false
    
    if command -v git &> /dev/null; then
        has_method=true
    fi
    
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        has_method=true
    fi
    
    if [[ "$has_method" == false ]]; then
        log_error "No suitable installation method"
        log_info "Install: sudo apt install git OR sudo apt install wget unzip"
        return 1
    fi
    
    return 0
}

get_cyberpunk_gaming_tips() {
    cat <<EOF
🎮 Cyberpunk Theme Gaming Optimization Tips:

1. RGB Synchronization:
   - Use OpenRGB to sync RGB devices
   - Match neon cyan/pink colors

2. Performance:
   - Disable compositor for games
   - Use Game Mode (gamemode package)

3. Streaming Setup:
   - OBS Studio with neon overlays
   - Match theme colors in alerts

4. Discord Integration:
   - Use BetterDiscord with cyberpunk theme
   - Custom CSS for neon effects

5. Terminal Setup:
   - Cool-retro-term for authentic CRT look
   - Share Tech Mono font recommended
EOF
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Cyberpunk Neon Theme Module Test ==="
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
    check_cyberpunk_dependencies
    
    echo
    echo "2. Installation status:"
    if verify_cyberpunk_installation; then
        echo "✓ Installed components: $(get_installed_cyberpunk_variants)"
    else
        echo "✗ Not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_cyberpunk_metadata
    
    echo
    echo "4. Color Palette:"
    get_cyberpunk_color_palette
    
    echo
    echo "5. Gaming Tips:"
    get_cyberpunk_gaming_tips
    
    echo
    echo "=== Test Complete ==="
fi
