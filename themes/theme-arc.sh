#!/bin/bash

# ============================================================================
# ARC THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Arc theme installation, verification, and metadata management
# Dependencies: apt, wget, tar (for GitHub fallback)
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: GPL-3.0
# ============================================================================

# === GLOBAL VARIABLES ===
readonly ARC_THEME_NAME="Arc"
readonly ARC_PACKAGE_NAME="arc-theme"
readonly ARC_ICONS_PACKAGE="papirus-icon-theme"
readonly ARC_GITHUB_URL="https://github.com/jnsh/arc-theme"
readonly ARC_GITHUB_RELEASE="https://api.github.com/repos/jnsh/arc-theme/releases/latest"

# Theme installation paths
readonly ARC_SYSTEM_PATH="/usr/share/themes"
readonly ARC_USER_PATH="$HOME/.themes"
readonly ARC_ICONS_PATH="/usr/share/icons"

# Variants
readonly -a ARC_VARIANTS=("Arc" "Arc-Dark" "Arc-Darker" "Arc-Lighter")

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# install_arc_theme
# Installs Arc theme from the best available source
# 
# Installation priority:
#   1. Ubuntu/Debian repository (apt)
#   2. Official GitHub releases
#   3. User local installation (fallback)
#
# Returns:
#   0 - Installation successful
#   1 - Installation failed
# ----------------------------------------------------------------------------
install_arc_theme() {
    log_info "Starting Arc theme installation..."
    
    # Check if already installed
    if verify_arc_installation; then
        log_success "Arc theme is already installed!"
        return 0
    fi
    
    # Try Method 1: APT (Ubuntu repository)
    if command -v apt-cache &> /dev/null; then
        if apt-cache show "$ARC_PACKAGE_NAME" &> /dev/null 2>&1; then
            log_info "Installing Arc theme from Ubuntu repository..."
            
            if sudo apt update &> /dev/null; then
                if sudo apt install -y "$ARC_PACKAGE_NAME" "$ARC_ICONS_PACKAGE" &> /dev/null 2>&1; then
                    if verify_arc_installation; then
                        log_success "Arc theme installed successfully from repository!"
                        return 0
                    else
                        log_warning "Package installed but verification failed"
                    fi
                else
                    log_warning "APT installation failed, trying alternative method..."
                fi
            else
                log_warning "APT update failed, trying alternative method..."
            fi
        else
            log_info "Arc theme not available in repository, trying GitHub..."
        fi
    fi
    
    # Try Method 2: GitHub Release (Latest)
    if command -v wget &> /dev/null && command -v tar &> /dev/null; then
        log_info "Attempting to install from GitHub releases..."
        
        if install_arc_from_github; then
            if verify_arc_installation; then
                log_success "Arc theme installed successfully from GitHub!"
                return 0
            else
                log_warning "GitHub installation completed but verification failed"
            fi
        else
            log_warning "GitHub installation failed"
        fi
    fi
    
    # Method 3: User local installation (minimal fallback)
    log_warning "All installation methods failed"
    log_error "Could not install Arc theme. Please install manually:"
    log_error "  sudo apt install arc-theme papirus-icon-theme"
    
    return 1
}

# ----------------------------------------------------------------------------
# install_arc_from_github
# Downloads and installs Arc theme from official GitHub releases
#
# Returns:
#   0 - Success
#   1 - Failure
# ----------------------------------------------------------------------------
install_arc_from_github() {
    local temp_dir
    local download_url
    local tar_file
    
    # Create temporary directory
    temp_dir=$(mktemp -d) || {
        log_error "Failed to create temporary directory"
        return 1
    }
    
    # Ensure cleanup on exit
    trap "rm -rf '$temp_dir'" RETURN
    
    log_info "Fetching latest Arc theme release information..."
    
    # Get latest release download URL
    download_url=$(curl -s "$ARC_GITHUB_RELEASE" | \
                   grep "browser_download_url.*tar.xz" | \
                   head -n 1 | \
                   cut -d '"' -f 4)
    
    if [[ -z "$download_url" ]]; then
        log_error "Could not find Arc theme download URL"
        return 1
    fi
    
    log_info "Downloading Arc theme: $download_url"
    
    tar_file="$temp_dir/arc-theme.tar.xz"
    
    # Download with progress and error handling
    if ! wget -q --show-progress --timeout=30 -O "$tar_file" "$download_url" 2>&1; then
        log_error "Download failed"
        return 1
    fi
    
    # Verify download
    if [[ ! -f "$tar_file" ]] || [[ ! -s "$tar_file" ]]; then
        log_error "Downloaded file is invalid or empty"
        return 1
    fi
    
    log_info "Extracting Arc theme..."
    
    # Extract to temporary location
    if ! tar -xf "$tar_file" -C "$temp_dir" 2>&1; then
        log_error "Extraction failed"
        return 1
    fi
    
    # Find extracted theme directories
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Arc*" | head -n 1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted theme directory"
        return 1
    fi
    
    log_info "Installing Arc theme variants..."
    
    # Create user themes directory if it doesn't exist
    mkdir -p "$ARC_USER_PATH" || {
        log_error "Failed to create themes directory"
        return 1
    }
    
    # Install all Arc variants
    local installed_count=0
    for variant in "${ARC_VARIANTS[@]}"; do
        local variant_path="$extracted_dir/$variant"
        
        if [[ -d "$variant_path" ]]; then
            if cp -r "$variant_path" "$ARC_USER_PATH/" 2>&1; then
                ((installed_count++))
                log_success "  Installed: $variant"
            else
                log_warning "  Failed to install: $variant"
            fi
        fi
    done
    
    if [[ $installed_count -eq 0 ]]; then
        log_error "No theme variants were installed"
        return 1
    fi
    
    log_success "Installed $installed_count Arc theme variant(s)"
    
    # Try to install Papirus icons if available
    if command -v apt &> /dev/null; then
        log_info "Installing Papirus icons..."
        sudo apt install -y "$ARC_ICONS_PACKAGE" &> /dev/null 2>&1 || \
            log_warning "Could not install Papirus icons (optional)"
    fi
    
    return 0
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# verify_arc_installation
# Verifies that Arc theme is properly installed
#
# Checks:
#   - At least one Arc variant exists
#   - Theme files are valid
#   - Required files present
#
# Returns:
#   0 - Theme is installed and valid
#   1 - Theme is not installed or invalid
# ----------------------------------------------------------------------------
verify_arc_installation() {
    local found_variant=false
    local check_paths=("$ARC_SYSTEM_PATH" "$ARC_USER_PATH")
    
    # Check each possible installation path
    for base_path in "${check_paths[@]}"; do
        # Skip if path doesn't exist
        [[ -d "$base_path" ]] || continue
        
        # Check each variant
        for variant in "${ARC_VARIANTS[@]}"; do
            local theme_path="$base_path/$variant"
            
            if [[ -d "$theme_path" ]]; then
                # Verify it's a valid theme directory
                if [[ -f "$theme_path/index.theme" ]] || \
                   [[ -d "$theme_path/gtk-2.0" ]] || \
                   [[ -d "$theme_path/gtk-3.0" ]]; then
                    found_variant=true
                    break 2
                fi
            fi
        done
    done
    
    if [[ "$found_variant" == true ]]; then
        return 0
    else
        return 1
    fi
}

# ----------------------------------------------------------------------------
# get_installed_arc_variants
# Returns list of installed Arc theme variants
#
# Output: Space-separated list of installed variants
# Returns: 0 always
# ----------------------------------------------------------------------------
get_installed_arc_variants() {
    local variants=()
    local check_paths=("$ARC_SYSTEM_PATH" "$ARC_USER_PATH")
    
    for base_path in "${check_paths[@]}"; do
        [[ -d "$base_path" ]] || continue
        
        for variant in "${ARC_VARIANTS[@]}"; do
            if [[ -d "$base_path/$variant" ]]; then
                # Avoid duplicates
                if [[ ! " ${variants[*]} " =~ " ${variant} " ]]; then
                    variants+=("$variant")
                fi
            fi
        done
    done
    
    echo "${variants[@]}"
    return 0
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# get_arc_metadata
# Returns Arc theme metadata in key=value format
#
# Output: Metadata string (one per line)
# Returns: 0 always
# ----------------------------------------------------------------------------
get_arc_metadata() {
    cat <<EOF
name=Arc
display_name=Arc Dark
description=Flat theme with transparent elements and modern design
variants=${ARC_VARIANTS[*]}
icons=Papirus
cursor=Adwaita
source_primary=apt:arc-theme
source_secondary=github:jnsh/arc-theme
source_icons=apt:papirus-icon-theme
compatibility=GNOME,KDE,XFCE,MATE,Cinnamon,Budgie
popularity=95
maintenance=active
license=GPL-3.0
author=jnsh (horst3180 original)
year=2021
gtk2=yes
gtk3=yes
gtk4=yes
shell_theme=yes
cinnamon_theme=yes
metacity_theme=yes
xfwm4_theme=yes
EOF
    return 0
}

# ----------------------------------------------------------------------------
# get_arc_variants
# Returns available Arc theme variants
#
# Output: Array of variant names (one per line)
# Returns: 0 always
# ----------------------------------------------------------------------------
get_arc_variants() {
    printf '%s\n' "${ARC_VARIANTS[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# get_arc_recommended_variant
# Returns the recommended Arc variant for the current desktop environment
#
# Args:
#   $1 - Desktop environment name (GNOME, KDE, etc.)
#
# Output: Recommended variant name
# Returns: 0 always
# ----------------------------------------------------------------------------
get_arc_recommended_variant() {
    local de="${1:-GNOME}"
    
    # Most users prefer the dark variant
    case "$de" in
        GNOME|KDE|Cinnamon|Budgie)
            echo "Arc-Dark"
            ;;
        XFCE|MATE)
            echo "Arc-Darker"
            ;;
        *)
            echo "Arc-Dark"
            ;;
    esac
    
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# cleanup_arc_theme
# Removes Arc theme from the system
#
# Removes:
#   - APT package (if installed)
#   - User-installed themes (~/.themes)
#   - Associated icons (optional)
#
# Returns:
#   0 - Cleanup successful
#   1 - Cleanup failed
# ----------------------------------------------------------------------------
cleanup_arc_theme() {
    local removed_count=0
    
    log_info "Cleaning up Arc theme..."
    
    # Remove APT package if installed
    if dpkg -l | grep -q "^ii.*$ARC_PACKAGE_NAME"; then
        log_info "Removing Arc theme package..."
        if sudo apt remove -y "$ARC_PACKAGE_NAME" &> /dev/null 2>&1; then
            log_success "Package removed successfully"
            ((removed_count++))
        else
            log_warning "Failed to remove package"
        fi
    fi
    
    # Remove user-installed variants
    if [[ -d "$ARC_USER_PATH" ]]; then
        for variant in "${ARC_VARIANTS[@]}"; do
            local variant_path="$ARC_USER_PATH/$variant"
            
            if [[ -d "$variant_path" ]]; then
                if rm -rf "$variant_path" 2>&1; then
                    log_success "Removed: $variant"
                    ((removed_count++))
                else
                    log_warning "Failed to remove: $variant"
                fi
            fi
        done
    fi
    
    if [[ $removed_count -gt 0 ]]; then
        log_success "Arc theme cleanup completed ($removed_count items removed)"
        return 0
    else
        log_info "No Arc theme installations found to remove"
        return 0
    fi
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# check_arc_dependencies
# Checks if all required dependencies are available
#
# Returns:
#   0 - All dependencies available
#   1 - Missing dependencies
# ----------------------------------------------------------------------------
check_arc_dependencies() {
    local missing_deps=()
    local required_deps=("wget" "tar" "curl")
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt install ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# ============================================================================
# MAIN EXECUTION (for standalone testing)
# ============================================================================

# If script is run directly (not sourced), execute test
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Arc Theme Module Test ==="
    echo
    
    # Source required modules for testing
    if [[ -f "../core/logger.sh" ]]; then
        source "../core/logger.sh"
    else
        # Fallback logging functions
        log_info() { echo "[INFO] $*"; }
        log_success() { echo "[SUCCESS] $*"; }
        log_warning() { echo "[WARNING] $*"; }
        log_error() { echo "[ERROR] $*"; }
    fi
    
    echo "1. Checking dependencies..."
    check_arc_dependencies
    
    echo
    echo "2. Checking current installation..."
    if verify_arc_installation; then
        echo "✓ Arc theme is installed"
        echo "  Installed variants: $(get_installed_arc_variants)"
    else
        echo "✗ Arc theme is not installed"
    fi
    
    echo
    echo "3. Metadata:"
    get_arc_metadata
    
    echo
    echo "4. Available variants:"
    get_arc_variants
    
    echo
    echo "5. Recommended variant for GNOME:"
    get_arc_recommended_variant "GNOME"
    
    echo
    echo "=== Test Complete ==="
fi
