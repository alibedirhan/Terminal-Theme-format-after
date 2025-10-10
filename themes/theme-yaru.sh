#!/bin/bash

# ============================================================================
# YARU THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Yaru theme (Ubuntu's official theme) management
# Dependencies: apt
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: GPL-3.0
# ============================================================================

# === GLOBAL VARIABLES ===
readonly YARU_THEME_NAME="Yaru"
readonly YARU_BASE_PACKAGE="yaru-theme-gnome-shell"
readonly YARU_FULL_PACKAGE="yaru-theme-gtk"
readonly YARU_ICONS_PACKAGE="yaru-theme-icon"
readonly YARU_SOUND_PACKAGE="yaru-theme-sound"

# Theme paths
readonly YARU_SYSTEM_PATH="/usr/share/themes"
readonly YARU_ICONS_PATH="/usr/share/icons"

# Yaru variants (Ubuntu 22.04+)
readonly -a YARU_VARIANTS=(
    "Yaru"
    "Yaru-dark"
    "Yaru-light"
    "Yaru-blue"
    "Yaru-blue-dark"
    "Yaru-blue-light"
    "Yaru-red"
    "Yaru-red-dark"
    "Yaru-red-light"
    "Yaru-green"
    "Yaru-green-dark"
    "Yaru-green-light"
    "Yaru-purple"
    "Yaru-purple-dark"
    "Yaru-purple-light"
)

# Color accent packages
readonly -a YARU_COLOR_PACKAGES=(
    "yaru-theme-gtk"
    "yaru-theme-gnome-shell"
    "yaru-theme-icon"
)

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# install_yaru_theme
# Installs Yaru theme (Ubuntu's default modern theme)
#
# Installation strategy:
#   - Ubuntu 22.04+: Full Yaru with all color variants
#   - Older versions: Basic Yaru package
#
# Returns:
#   0 - Installation successful
#   1 - Installation failed
# ----------------------------------------------------------------------------
install_yaru_theme() {
    log_info "Starting Yaru theme installation..."
    
    # Check if already installed
    if verify_yaru_installation; then
        log_success "Yaru theme is already installed!"
        return 0
    fi
    
    # Yaru is Ubuntu's official theme, should always be available
    if ! command -v apt &> /dev/null; then
        log_error "APT not found. Yaru theme requires Ubuntu/Debian"
        return 1
    fi
    
    log_info "Installing Yaru theme from Ubuntu repository..."
    
    # Update package list
    if ! sudo apt update &> /dev/null; then
        log_error "Failed to update package list"
        return 1
    fi
    
    # Detect Ubuntu version for appropriate packages
    local ubuntu_version
    ubuntu_version=$(lsb_release -rs 2>/dev/null | cut -d'.' -f1)
    
    local packages_to_install=()
    
    # Ubuntu 22.04+ has full Yaru color variants
    if [[ -n "$ubuntu_version" ]] && [[ "$ubuntu_version" -ge 22 ]]; then
        log_info "Detected Ubuntu ${ubuntu_version}.04 - Installing full Yaru suite..."
        packages_to_install+=(
            "${YARU_FULL_PACKAGE}"
            "${YARU_ICONS_PACKAGE}"
            "${YARU_SOUND_PACKAGE}"
        )
    else
        # Older Ubuntu versions or unknown
        log_info "Installing base Yaru theme..."
        packages_to_install+=(
            "${YARU_BASE_PACKAGE}"
            "${YARU_ICONS_PACKAGE}"
        )
    fi
    
    # Install packages
    log_info "Installing: ${packages_to_install[*]}"
    
    if sudo apt install -y "${packages_to_install[@]}" &> /dev/null 2>&1; then
        # Verify installation
        if verify_yaru_installation; then
            log_success "Yaru theme installed successfully!"
            
            # Show installed variants
            local installed_variants
            installed_variants=$(get_installed_yaru_variants)
            if [[ -n "$installed_variants" ]]; then
                log_info "Available variants: $installed_variants"
            fi
            
            return 0
        else
            log_error "Installation completed but verification failed"
            return 1
        fi
    else
        log_error "Failed to install Yaru theme packages"
        log_info "Try manually: sudo apt install ${packages_to_install[*]}"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# install_yaru_color_variant
# Installs a specific Yaru color variant
#
# Args:
#   $1 - Color name (blue, red, green, purple)
#
# Returns:
#   0 - Success
#   1 - Failure
# ----------------------------------------------------------------------------
install_yaru_color_variant() {
    local color="${1,,}"  # Convert to lowercase
    
    if [[ -z "$color" ]]; then
        log_error "Color variant not specified"
        return 1
    fi
    
    # Validate color
    local valid_colors=("blue" "red" "green" "purple")
    if [[ ! " ${valid_colors[*]} " =~ " ${color} " ]]; then
        log_error "Invalid color: $color (valid: ${valid_colors[*]})"
        return 1
    fi
    
    log_info "Installing Yaru-${color} color variant..."
    
    # Ensure base Yaru is installed first
    if ! verify_yaru_installation; then
        log_info "Base Yaru theme not found, installing..."
        if ! install_yaru_theme; then
            return 1
        fi
    fi
    
    # On Ubuntu 22.04+, color variants are included
    # Just verify they exist
    local variants=("Yaru-${color}" "Yaru-${color}-dark" "Yaru-${color}-light")
    local found_count=0
    
    for variant in "${variants[@]}"; do
        if [[ -d "$YARU_SYSTEM_PATH/$variant" ]]; then
            ((found_count++))
        fi
    done
    
    if [[ $found_count -gt 0 ]]; then
        log_success "Yaru-${color} variants are available ($found_count found)"
        return 0
    else
        log_warning "Yaru-${color} variants not found"
        log_info "You may need Ubuntu 22.04+ for color variants"
        return 1
    fi
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# verify_yaru_installation
# Verifies that Yaru theme is properly installed
#
# Returns:
#   0 - Theme is installed
#   1 - Theme is not installed
# ----------------------------------------------------------------------------
verify_yaru_installation() {
    # Check if any Yaru variant exists
    [[ ! -d "$YARU_SYSTEM_PATH" ]] && return 1
    
    # Look for at least one Yaru theme
    local found=false
    for variant in "${YARU_VARIANTS[@]}"; do
        if [[ -d "$YARU_SYSTEM_PATH/$variant" ]]; then
            # Verify it's a valid theme
            if [[ -f "$YARU_SYSTEM_PATH/$variant/index.theme" ]] || \
               [[ -d "$YARU_SYSTEM_PATH/$variant/gtk-3.0" ]]; then
                found=true
                break
            fi
        fi
    done
    
    [[ "$found" == true ]] && return 0 || return 1
}

# ----------------------------------------------------------------------------
# get_installed_yaru_variants
# Returns list of installed Yaru variants
#
# Output: Space-separated list of variants
# Returns: 0 always
# ----------------------------------------------------------------------------
get_installed_yaru_variants() {
    local variants=()
    
    [[ ! -d "$YARU_SYSTEM_PATH" ]] && return 0
    
    for variant in "${YARU_VARIANTS[@]}"; do
        if [[ -d "$YARU_SYSTEM_PATH/$variant" ]]; then
            variants+=("$variant")
        fi
    done
    
    echo "${variants[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# is_yaru_color_available
# Check if a specific Yaru color variant is available
#
# Args:
#   $1 - Color name (blue, red, green, purple)
#
# Returns:
#   0 - Color variant available
#   1 - Color variant not available
# ----------------------------------------------------------------------------
is_yaru_color_available() {
    local color="${1,,}"
    
    [[ -z "$color" ]] && return 1
    
    # Check if at least one variant of this color exists
    local variants=("Yaru-${color}" "Yaru-${color}-dark" "Yaru-${color}-light")
    
    for variant in "${variants[@]}"; do
        if [[ -d "$YARU_SYSTEM_PATH/$variant" ]]; then
            return 0
        fi
    done
    
    return 1
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# get_yaru_metadata
# Returns Yaru theme metadata
#
# Output: Metadata in key=value format
# Returns: 0 always
# ----------------------------------------------------------------------------
get_yaru_metadata() {
    cat <<EOF
name=Yaru
display_name=Yaru (Ubuntu)
description=Ubuntu's official modern theme with accent color variants
variants=${YARU_VARIANTS[*]}
icons=Yaru
cursor=Yaru
sound=Yaru
source_primary=apt:yaru-theme-gtk
source_icons=apt:yaru-theme-icon
source_sound=apt:yaru-theme-sound
compatibility=GNOME,Budgie,Unity
popularity=98
maintenance=active
license=GPL-3.0 / CC-BY-SA-4.0
author=Ubuntu Design Team
year=2018
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=yes
gnome_shell=yes
color_variants=yes
colors=blue,red,green,purple
default_in=Ubuntu 22.04+
ubuntu_official=yes
EOF
    return 0
}

# ----------------------------------------------------------------------------
# get_yaru_variants
# Returns available Yaru variants
#
# Output: Array of variant names (one per line)
# Returns: 0 always
# ----------------------------------------------------------------------------
get_yaru_variants() {
    printf '%s\n' "${YARU_VARIANTS[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# get_yaru_recommended_variant
# Returns recommended Yaru variant for user preference
#
# Args:
#   $1 - Preference: light/dark/auto (default: dark)
#   $2 - Color accent: blue/red/green/purple (default: none)
#
# Output: Recommended variant name
# Returns: 0 always
# ----------------------------------------------------------------------------
get_yaru_recommended_variant() {
    local preference="${1:-dark}"
    local color="${2:-}"
    
    # If color specified, use color variant
    if [[ -n "$color" ]]; then
        case "$preference" in
            light)
                echo "Yaru-${color}-light"
                ;;
            dark)
                echo "Yaru-${color}-dark"
                ;;
            *)
                echo "Yaru-${color}"
                ;;
        esac
    else
        # Use base Yaru variants
        case "$preference" in
            light)
                echo "Yaru-light"
                ;;
            dark)
                echo "Yaru-dark"
                ;;
            *)
                echo "Yaru"
                ;;
        esac
    fi
    
    return 0
}

# ----------------------------------------------------------------------------
# get_yaru_color_palette
# Returns color information for Yaru variants
#
# Args:
#   $1 - Color variant (blue/red/green/purple)
#
# Output: Color information
# Returns: 0 always
# ----------------------------------------------------------------------------
get_yaru_color_palette() {
    local color="${1:-blue}"
    
    case "$color" in
        blue)
            cat <<EOF
primary=#0073e5
secondary=#004080
accent=#3584e4
description=Ubuntu's signature blue
EOF
            ;;
        red)
            cat <<EOF
primary=#e01b24
secondary=#a51d2d
accent=#c01c28
description=Warm red for energy
EOF
            ;;
        green)
            cat <<EOF
primary=#26a269
secondary=#1c7e4e
accent=#2ec27e
description=Fresh green for nature
EOF
            ;;
        purple)
            cat <<EOF
primary=#9141ac
secondary=#613583
accent=#a347ba
description=Royal purple for creativity
EOF
            ;;
        *)
            echo "unknown_color=true"
            ;;
    esac
    
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# cleanup_yaru_theme
# Removes Yaru theme (NOT RECOMMENDED on Ubuntu)
#
# Warning: Yaru is Ubuntu's default theme. Removing it may cause issues.
#
# Returns:
#   0 - Cleanup successful
#   1 - Cleanup failed or aborted
# ----------------------------------------------------------------------------
cleanup_yaru_theme() {
    log_warning "⚠️  WARNING: Yaru is Ubuntu's official theme!"
    log_warning "Removing it may cause system instability."
    
    read -rp "Are you sure you want to remove Yaru? (yes/NO): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Cleanup cancelled by user"
        return 1
    fi
    
    log_info "Removing Yaru theme packages..."
    
    local packages_to_remove=(
        "yaru-theme-gtk"
        "yaru-theme-gnome-shell"
        "yaru-theme-icon"
        "yaru-theme-sound"
    )
    
    # Note: Use apt remove, not purge, to keep configs
    if sudo apt remove -y "${packages_to_remove[@]}" &> /dev/null 2>&1; then
        log_success "Yaru theme removed"
        log_info "System will use fallback theme"
        return 0
    else
        log_error "Failed to remove Yaru theme"
        return 1
    fi
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# check_yaru_dependencies
# Checks if running on Ubuntu (Yaru's native platform)
#
# Returns:
#   0 - Running on Ubuntu
#   1 - Not running on Ubuntu
# ----------------------------------------------------------------------------
check_yaru_dependencies() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS"
        return 1
    fi
    
    local os_id
    os_id=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    
    if [[ "$os_id" != "ubuntu" ]]; then
        log_warning "Yaru theme is designed for Ubuntu"
        log_warning "Current OS: $os_id"
        log_info "Theme may not work optimally on non-Ubuntu systems"
    fi
    
    return 0
}

# ----------------------------------------------------------------------------
# get_ubuntu_version_for_yaru
# Returns Ubuntu version information relevant to Yaru
#
# Output: Version info
# Returns: 0 always
# ----------------------------------------------------------------------------
get_ubuntu_version_for_yaru() {
    local version
    version=$(lsb_release -rs 2>/dev/null || echo "unknown")
    
    local version_major
    version_major=$(echo "$version" | cut -d'.' -f1)
    
    cat <<EOF
version=$version
major=$version_major
color_variants_available=$([[ "$version_major" -ge 22 ]] && echo "yes" || echo "no")
yaru_version=$([[ "$version_major" -ge 22 ]] && echo "2.0+" || echo "1.0")
EOF
    
    return 0
}

# ============================================================================
# MAIN EXECUTION (for standalone testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Yaru Theme Module Test ==="
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
    
    echo "1. Checking Ubuntu compatibility..."
    check_yaru_dependencies
    
    echo
    echo "2. Ubuntu version info:"
    get_ubuntu_version_for_yaru
    
    echo
    echo "3. Checking current installation..."
    if verify_yaru_installation; then
        echo "✓ Yaru theme is installed"
        echo "  Installed variants: $(get_installed_yaru_variants)"
    else
        echo "✗ Yaru theme is not installed"
    fi
    
    echo
    echo "4. Metadata:"
    get_yaru_metadata
    
    echo
    echo "5. Recommended variant (dark):"
    get_yaru_recommended_variant "dark"
    
    echo
    echo "6. Recommended variant (dark, blue accent):"
    get_yaru_recommended_variant "dark" "blue"
    
    echo
    echo "=== Test Complete ==="
fi
