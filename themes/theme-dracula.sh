#!/bin/bash

# ============================================================================
# DRACULA THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Dracula theme installation and management
# Dependencies: wget, tar, git (optional)
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: MIT
# ============================================================================

# === GLOBAL VARIABLES ===
readonly DRACULA_THEME_NAME="Dracula"
readonly DRACULA_GTK_REPO="https://github.com/dracula/gtk"
readonly DRACULA_ICONS_REPO="https://github.com/dracula/gtk"
readonly DRACULA_GTK_RELEASE="https://github.com/dracula/gtk/archive/refs/heads/master.zip"

# Installation paths
readonly DRACULA_SYSTEM_PATH="/usr/share/themes"
readonly DRACULA_USER_PATH="$HOME/.themes"
readonly DRACULA_ICONS_PATH="$HOME/.icons"

# Theme variants
readonly -a DRACULA_VARIANTS=(
    "Dracula"
)

# Color palette (official Dracula colors)
readonly DRACULA_BACKGROUND="#282a36"
readonly DRACULA_CURRENT_LINE="#44475a"
readonly DRACULA_FOREGROUND="#f8f8f2"
readonly DRACULA_COMMENT="#6272a4"
readonly DRACULA_CYAN="#8be9fd"
readonly DRACULA_GREEN="#50fa7b"
readonly DRACULA_ORANGE="#ffb86c"
readonly DRACULA_PINK="#ff79c6"
readonly DRACULA_PURPLE="#bd93f9"
readonly DRACULA_RED="#ff5555"
readonly DRACULA_YELLOW="#f1fa8c"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# install_dracula_theme
# Installs Dracula theme from GitHub
#
# Installation strategy:
#   1. Try git clone (fast, gets latest)
#   2. Fallback to wget + unzip (if git not available)
#   3. Install to user directory (~/.themes)
#
# Returns:
#   0 - Installation successful
#   1 - Installation failed
# ----------------------------------------------------------------------------
install_dracula_theme() {
    log_info "Starting Dracula theme installation..."
    
    # Check if already installed
    if verify_dracula_installation; then
        log_success "Dracula theme is already installed!"
        return 0
    fi
    
    # Check dependencies
    if ! check_dracula_dependencies; then
        return 1
    fi
    
    # Create directories
    mkdir -p "$DRACULA_USER_PATH" "$DRACULA_ICONS_PATH" || {
        log_error "Failed to create theme directories"
        return 1
    }
    
    # Try Method 1: Git clone (preferred)
    if command -v git &> /dev/null; then
        log_info "Installing Dracula theme using git..."
        if install_dracula_with_git; then
            return 0
        else
            log_warning "Git installation failed, trying alternative method..."
        fi
    fi
    
    # Try Method 2: Wget + unzip
    if command -v wget &> /dev/null && command -v unzip &> /dev/null; then
        log_info "Installing Dracula theme using wget..."
        if install_dracula_with_wget; then
            return 0
        else
            log_error "Wget installation also failed"
        fi
    fi
    
    log_error "All installation methods failed"
    log_info "Manual installation:"
    log_info "  git clone $DRACULA_GTK_REPO ~/.themes/Dracula"
    
    return 1
}

# ----------------------------------------------------------------------------
# install_dracula_with_git
# Installs Dracula using git clone
#
# Returns:
#   0 - Success
#   1 - Failure
# ----------------------------------------------------------------------------
install_dracula_with_git() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    
    # Ensure cleanup
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Cloning Dracula GTK repository..."
    
    # Clone with depth=1 for faster download
    if ! git clone --depth=1 "$DRACULA_GTK_REPO" "$temp_dir/dracula-gtk" &> /dev/null; then
        log_error "Git clone failed"
        return 1
    fi
    
    # Install GTK theme
    log_info "Installing Dracula GTK theme..."
    
    if [[ ! -d "$temp_dir/dracula-gtk/gtk-4.0" ]]; then
        log_error "Downloaded theme structure is invalid"
        return 1
    fi
    
    # Copy theme to user directory
    local theme_dest="$DRACULA_USER_PATH/Dracula"
    
    if cp -r "$temp_dir/dracula-gtk" "$theme_dest" 2>&1; then
        log_success "Dracula GTK theme installed"
    else
        log_error "Failed to copy theme files"
        return 1
    fi
    
    # Verify installation
    if verify_dracula_installation; then
        log_success "Dracula theme installed successfully!"
        return 0
    else
        log_error "Installation verification failed"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# install_dracula_with_wget
# Installs Dracula using wget and unzip
#
# Returns:
#   0 - Success
#   1 - Failure
# ----------------------------------------------------------------------------
install_dracula_with_wget() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    
    trap "rm -rf '$temp_dir'" RETURN
    
    local zip_file="$temp_dir/dracula.zip"
    
    log_info "Downloading Dracula theme..."
    
    # Download theme
    if ! wget -q --show-progress --timeout=30 -O "$zip_file" "$DRACULA_GTK_RELEASE" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    # Verify download
    if [[ ! -f "$zip_file" ]] || [[ ! -s "$zip_file" ]]; then
        log_error "Downloaded file is invalid"
        return 1
    fi
    
    log_info "Extracting Dracula theme..."
    
    # Extract
    if ! unzip -q "$zip_file" -d "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    # Find extracted directory (usually gtk-master or similar)
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "gtk-*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted theme directory"
        return 1
    fi
    
    log_info "Installing Dracula theme..."
    
    # Copy to user themes directory
    local theme_dest="$DRACULA_USER_PATH/Dracula"
    
    if cp -r "$extracted_dir" "$theme_dest" 2>&1; then
        log_success "Dracula theme installed"
        
        # Verify
        if verify_dracula_installation; then
            log_success "Installation verified successfully!"
            return 0
        fi
    fi
    
    log_error "Installation failed"
    return 1
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# verify_dracula_installation
# Verifies Dracula theme is properly installed
#
# Returns:
#   0 - Theme is installed
#   1 - Theme is not installed
# ----------------------------------------------------------------------------
verify_dracula_installation() {
    local check_paths=(
        "$DRACULA_SYSTEM_PATH/Dracula"
        "$DRACULA_USER_PATH/Dracula"
    )
    
    for theme_path in "${check_paths[@]}"; do
        if [[ -d "$theme_path" ]]; then
            # Verify it's a valid GTK theme
            if [[ -d "$theme_path/gtk-3.0" ]] || \
               [[ -d "$theme_path/gtk-4.0" ]] || \
               [[ -f "$theme_path/index.theme" ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

# ----------------------------------------------------------------------------
# get_installed_dracula_variants
# Returns installed Dracula components
#
# Output: List of installed components
# Returns: 0 always
# ----------------------------------------------------------------------------
get_installed_dracula_variants() {
    local components=()
    
    # Check GTK theme
    if [[ -d "$DRACULA_USER_PATH/Dracula" ]] || \
       [[ -d "$DRACULA_SYSTEM_PATH/Dracula" ]]; then
        components+=("GTK")
    fi
    
    # Check icons (if we add icon support later)
    if [[ -d "$DRACULA_ICONS_PATH/Dracula" ]]; then
        components+=("Icons")
    fi
    
    echo "${components[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# get_dracula_installation_path
# Returns the path where Dracula is installed
#
# Output: Installation path or empty string
# Returns: 0 always
# ----------------------------------------------------------------------------
get_dracula_installation_path() {
    if [[ -d "$DRACULA_USER_PATH/Dracula" ]]; then
        echo "$DRACULA_USER_PATH/Dracula"
    elif [[ -d "$DRACULA_SYSTEM_PATH/Dracula" ]]; then
        echo "$DRACULA_SYSTEM_PATH/Dracula"
    else
        echo ""
    fi
    return 0
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# get_dracula_metadata
# Returns Dracula theme metadata
#
# Output: Metadata in key=value format
# Returns: 0 always
# ----------------------------------------------------------------------------
get_dracula_metadata() {
    cat <<EOF
name=Dracula
display_name=Dracula
description=Dark theme using the Dracula color palette
variants=Dracula
icons=Papirus-Dark,Dracula (optional)
cursor=System default
source_primary=github:dracula/gtk
source_type=git
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=96
maintenance=active
license=MIT
author=Dracula Theme
year=2016
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=no
color_scheme=dark
accent_color=purple
target_audience=developers,designers,night_users
community_size=large
ports_available=700+
website=https://draculatheme.com
dark_only=yes
EOF
    return 0
}

# ----------------------------------------------------------------------------
# get_dracula_variants
# Returns Dracula variants (only one main variant)
#
# Output: Variant name
# Returns: 0 always
# ----------------------------------------------------------------------------
get_dracula_variants() {
    printf '%s\n' "${DRACULA_VARIANTS[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# get_dracula_color_palette
# Returns official Dracula color palette
#
# Output: Color information
# Returns: 0 always
# ----------------------------------------------------------------------------
get_dracula_color_palette() {
    cat <<EOF
background=$DRACULA_BACKGROUND
current_line=$DRACULA_CURRENT_LINE
foreground=$DRACULA_FOREGROUND
comment=$DRACULA_COMMENT
cyan=$DRACULA_CYAN
green=$DRACULA_GREEN
orange=$DRACULA_ORANGE
pink=$DRACULA_PINK
purple=$DRACULA_PURPLE
red=$DRACULA_RED
yellow=$DRACULA_YELLOW
scheme_type=dark
contrast=high
readability=excellent
eye_strain=low
best_for=coding,night_work,long_sessions
EOF
    return 0
}

# ----------------------------------------------------------------------------
# get_dracula_recommended_settings
# Returns recommended settings for Dracula theme
#
# Output: Recommended settings
# Returns: 0 always
# ----------------------------------------------------------------------------
get_dracula_recommended_settings() {
    cat <<EOF
terminal_theme=Dracula
terminal_font=JetBrains Mono, Fira Code, Cascadia Code
terminal_font_size=11-12pt
icon_theme=Papirus-Dark
cursor_theme=Adwaita (dark)
shell_theme=None (or Pro theme)
wallpaper_type=dark,minimal,purple_accent
window_decoration=dark
time_of_use=evening,night
monitor_brightness=40-60%
blue_light_filter=recommended
complementary_apps=VS Code, Terminal, Vim
avoid_mixing_with=light themes
EOF
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# cleanup_dracula_theme
# Removes Dracula theme from system
#
# Returns:
#   0 - Cleanup successful
#   1 - Cleanup failed
# ----------------------------------------------------------------------------
cleanup_dracula_theme() {
    log_info "Cleaning up Dracula theme..."
    
    local removed_count=0
    local paths=(
        "$DRACULA_USER_PATH/Dracula"
        "$DRACULA_ICONS_PATH/Dracula"
    )
    
    for path in "${paths[@]}"; do
        if [[ -d "$path" ]]; then
            if rm -rf "$path" 2>&1; then
                log_success "Removed: $path"
                ((removed_count++))
            else
                log_warning "Failed to remove: $path"
            fi
        fi
    done
    
    if [[ $removed_count -gt 0 ]]; then
        log_success "Dracula theme cleanup completed ($removed_count items removed)"
        return 0
    else
        log_info "No Dracula theme installations found"
        return 0
    fi
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# check_dracula_dependencies
# Checks required dependencies
#
# Returns:
#   0 - Dependencies available
#   1 - Missing dependencies
# ----------------------------------------------------------------------------
check_dracula_dependencies() {
    local missing_deps=()
    local recommended_deps=("git" "wget" "unzip")
    
    # At least one download method required
    local has_download_method=false
    
    for dep in "${recommended_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        else
            # If we have git OR (wget AND unzip), we're good
            if [[ "$dep" == "git" ]] || \
               { command -v wget &> /dev/null && command -v unzip &> /dev/null; }; then
                has_download_method=true
            fi
        fi
    done
    
    if [[ "$has_download_method" == false ]]; then
        log_error "No suitable download method available"
        log_info "Install one of:"
        log_info "  Option 1: sudo apt install git"
        log_info "  Option 2: sudo apt install wget unzip"
        return 1
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Optional dependencies missing: ${missing_deps[*]}"
        log_info "For best experience: sudo apt install ${missing_deps[*]}"
    fi
    
    return 0
}

# ----------------------------------------------------------------------------
# update_dracula_theme
# Updates Dracula theme to latest version
#
# Returns:
#   0 - Update successful
#   1 - Update failed
# ----------------------------------------------------------------------------
update_dracula_theme() {
    log_info "Updating Dracula theme..."
    
    local install_path
    install_path=$(get_dracula_installation_path)
    
    if [[ -z "$install_path" ]]; then
        log_error "Dracula theme is not installed"
        return 1
    fi
    
    # Check if it's a git repository
    if [[ -d "$install_path/.git" ]] && command -v git &> /dev/null; then
        log_info "Updating via git pull..."
        
        if (cd "$install_path" && git pull origin master &> /dev/null); then
            log_success "Dracula theme updated successfully!"
            return 0
        else
            log_warning "Git update failed, trying reinstall..."
        fi
    fi
    
    # Fallback: Remove and reinstall
    log_info "Reinstalling Dracula theme..."
    cleanup_dracula_theme
    install_dracula_theme
}

# ============================================================================
# MAIN EXECUTION (for standalone testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Dracula Theme Module Test ==="
    echo
    
    # Source logger if available
    if [[ -f "../core/logger.sh" ]]; then
        source "../core/logger.sh"
    else
        log_info() { echo "[INFO] $*"; }
        log_success() { echo "[SUCCESS] $*"; }
        log_warning() { echo "[WARNING] $*"; }
        log_error() { echo "[ERROR] $*"; }
    fi
    
    echo "1. Checking dependencies..."
    check_dracula_dependencies
    
    echo
    echo "2. Checking current installation..."
    if verify_dracula_installation; then
        echo "✓ Dracula theme is installed"
        echo "  Location: $(get_dracula_installation_path)"
        echo "  Components: $(get_installed_dracula_variants)"
    else
        echo "✗ Dracula theme is not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_dracula_metadata
    
    echo
    echo "4. Color Palette:"
    get_dracula_color_palette
    
    echo
    echo "5. Recommended Settings:"
    get_dracula_recommended_settings
    
    echo
    echo "=== Test Complete ==="
fi
