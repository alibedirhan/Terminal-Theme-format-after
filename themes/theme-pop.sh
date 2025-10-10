#!/bin/bash

# ============================================================================
# POP THEME MODULE - System Theme Setup v2.0
# ============================================================================
# Purpose: Pop!_OS theme by System76 management
# Dependencies: apt, add-apt-repository
# Tested on: Ubuntu 22.04 LTS, 24.04 LTS
# License: GPL-3.0
# ============================================================================

# === GLOBAL VARIABLES ===
readonly POP_THEME_NAME="Pop"
readonly POP_GTK_PACKAGE="pop-gtk-theme"
readonly POP_ICON_PACKAGE="pop-icon-theme"
readonly POP_PPA="ppa:system76/pop"

# Theme paths
readonly POP_SYSTEM_PATH="/usr/share/themes"
readonly POP_ICONS_PATH="/usr/share/icons"

# Pop variants
readonly -a POP_VARIANTS=(
    "Pop"
    "Pop-dark"
    "Pop-light"
)

# Icon themes
readonly -a POP_ICON_VARIANTS=(
    "Pop"
)

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# install_pop_theme
# Installs Pop!_OS theme from System76's PPA
#
# Installation strategy:
#   1. Add System76 PPA
#   2. Install pop-gtk-theme and pop-icon-theme
#   3. Verify installation
#
# Returns:
#   0 - Installation successful
#   1 - Installation failed
# ----------------------------------------------------------------------------
install_pop_theme() {
    log_info "Starting Pop!_OS theme installation..."
    
    # Check if already installed
    if verify_pop_installation; then
        log_success "Pop theme is already installed!"
        return 0
    fi
    
    # Check dependencies
    if ! check_pop_dependencies; then
        log_error "Missing required dependencies"
        return 1
    fi
    
    # Check if PPA is already added
    if ! is_pop_ppa_added; then
        log_info "Adding System76 PPA..."
        
        # Add PPA with proper error handling
        if ! sudo add-apt-repository -y "$POP_PPA" &> /dev/null; then
            log_error "Failed to add System76 PPA"
            log_info "Try manually: sudo add-apt-repository $POP_PPA"
            return 1
        fi
        
        log_success "System76 PPA added successfully"
    else
        log_info "System76 PPA is already configured"
    fi
    
    # Update package list
    log_info "Updating package list..."
    if ! sudo apt update &> /dev/null; then
        log_warning "Failed to update package list, trying anyway..."
    fi
    
    # Install Pop theme packages
    log_info "Installing Pop theme packages..."
    
    local packages=(
        "$POP_GTK_PACKAGE"
        "$POP_ICON_PACKAGE"
    )
    
    if sudo apt install -y "${packages[@]}" 2>&1 | grep -v "^Selecting\|^Unpacking\|^Setting up"; then
        # Verify installation
        if verify_pop_installation; then
            log_success "Pop theme installed successfully!"
            
            # Show installed components
            local variants
            variants=$(get_installed_pop_variants)
            if [[ -n "$variants" ]]; then
                log_info "Available variants: $variants"
            fi
            
            return 0
        else
            log_error "Installation completed but verification failed"
            return 1
        fi
    else
        log_error "Failed to install Pop theme packages"
        log_info "Try manually:"
        log_info "  sudo add-apt-repository $POP_PPA"
        log_info "  sudo apt update"
        log_info "  sudo apt install ${packages[*]}"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# is_pop_ppa_added
# Checks if System76 PPA is already added
#
# Returns:
#   0 - PPA is added
#   1 - PPA is not added
# ----------------------------------------------------------------------------
is_pop_ppa_added() {
    # Check in sources.list.d
    if [[ -d /etc/apt/sources.list.d ]]; then
        if grep -r "system76.*pop" /etc/apt/sources.list.d/ &> /dev/null; then
            return 0
        fi
    fi
    
    # Check in main sources.list
    if [[ -f /etc/apt/sources.list ]]; then
        if grep "system76.*pop" /etc/apt/sources.list &> /dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# ----------------------------------------------------------------------------
# remove_pop_ppa
# Removes System76 PPA (cleanup helper)
#
# Returns:
#   0 - Success
#   1 - Failure
# ----------------------------------------------------------------------------
remove_pop_ppa() {
    if is_pop_ppa_added; then
        log_info "Removing System76 PPA..."
        if sudo add-apt-repository --remove -y "$POP_PPA" &> /dev/null; then
            log_success "System76 PPA removed"
            return 0
        else
            log_warning "Failed to remove PPA automatically"
            return 1
        fi
    else
        log_info "System76 PPA is not configured"
        return 0
    fi
}

# ============================================================================
# VERIFICATION FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# verify_pop_installation
# Verifies that Pop theme is properly installed
#
# Returns:
#   0 - Theme is installed
#   1 - Theme is not installed
# ----------------------------------------------------------------------------
verify_pop_installation() {
    local found_gtk=false
    local found_icons=false
    
    # Check GTK theme
    for variant in "${POP_VARIANTS[@]}"; do
        if [[ -d "$POP_SYSTEM_PATH/$variant" ]]; then
            # Verify it's a valid theme
            if [[ -f "$POP_SYSTEM_PATH/$variant/index.theme" ]] || \
               [[ -d "$POP_SYSTEM_PATH/$variant/gtk-3.0" ]]; then
                found_gtk=true
                break
            fi
        fi
    done
    
    # Check icon theme
    if [[ -d "$POP_ICONS_PATH/Pop" ]]; then
        if [[ -f "$POP_ICONS_PATH/Pop/index.theme" ]]; then
            found_icons=true
        fi
    fi
    
    # Both components should be present
    [[ "$found_gtk" == true && "$found_icons" == true ]] && return 0 || return 1
}

# ----------------------------------------------------------------------------
# get_installed_pop_variants
# Returns list of installed Pop theme variants
#
# Output: Space-separated list of variants
# Returns: 0 always
# ----------------------------------------------------------------------------
get_installed_pop_variants() {
    local variants=()
    
    [[ ! -d "$POP_SYSTEM_PATH" ]] && return 0
    
    for variant in "${POP_VARIANTS[@]}"; do
        if [[ -d "$POP_SYSTEM_PATH/$variant" ]]; then
            variants+=("$variant")
        fi
    done
    
    echo "${variants[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# is_pop_os
# Checks if running on Pop!_OS
#
# Returns:
#   0 - Running on Pop!_OS
#   1 - Not running on Pop!_OS
# ----------------------------------------------------------------------------
is_pop_os() {
    if [[ -f /etc/os-release ]]; then
        local os_id
        os_id=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
        
        [[ "$os_id" == "pop" ]] && return 0
    fi
    
    return 1
}

# ============================================================================
# METADATA FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# get_pop_metadata
# Returns Pop theme metadata
#
# Output: Metadata in key=value format
# Returns: 0 always
# ----------------------------------------------------------------------------
get_pop_metadata() {
    cat <<EOF
name=Pop
display_name=Pop!_OS
description=System76's professional theme with orange accents
variants=${POP_VARIANTS[*]}
icons=Pop
cursor=Pop (fallback to system)
source_primary=ppa:system76/pop
source_gtk=apt:pop-gtk-theme
source_icons=apt:pop-icon-theme
compatibility=GNOME,Budgie,Unity,XFCE,MATE
popularity=92
maintenance=active
license=GPL-3.0 / CC-BY-SA-4.0
author=System76
year=2017
gtk2=no
gtk3=yes
gtk4=yes
shell_theme=yes
gnome_shell=yes
accent_color=orange
target_audience=developers,professionals
default_in=Pop!_OS
nvidia_optimized=yes
flatpak_theme=yes
EOF
    return 0
}

# ----------------------------------------------------------------------------
# get_pop_variants
# Returns available Pop variants
#
# Output: Array of variant names (one per line)
# Returns: 0 always
# ----------------------------------------------------------------------------
get_pop_variants() {
    printf '%s\n' "${POP_VARIANTS[@]}"
    return 0
}

# ----------------------------------------------------------------------------
# get_pop_recommended_variant
# Returns recommended Pop variant based on preference
#
# Args:
#   $1 - Preference: light/dark/auto (default: dark)
#
# Output: Recommended variant name
# Returns: 0 always
# ----------------------------------------------------------------------------
get_pop_recommended_variant() {
    local preference="${1:-dark}"
    
    case "$preference" in
        light)
            echo "Pop-light"
            ;;
        dark)
            echo "Pop-dark"
            ;;
        auto|standard|*)
            echo "Pop"
            ;;
    esac
    
    return 0
}

# ----------------------------------------------------------------------------
# get_pop_color_info
# Returns Pop theme color palette information
#
# Output: Color information
# Returns: 0 always
# ----------------------------------------------------------------------------
get_pop_color_info() {
    cat <<EOF
primary=#48B9C7
secondary=#FFA500
accent=#FF6B00
highlight=#73C48F
warning=#F6D32D
error=#CC575D
background_light=#F2F2F2
background_dark=#333333
text_light=#FFFFFF
text_dark=#333333
description=Teal and orange professional palette
inspiration=System76 brand colors
EOF
    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# cleanup_pop_theme
# Removes Pop theme from the system
#
# Options:
#   - Remove packages only
#   - Remove packages + PPA
#
# Returns:
#   0 - Cleanup successful
#   1 - Cleanup failed
# ----------------------------------------------------------------------------
cleanup_pop_theme() {
    log_info "Cleaning up Pop theme..."
    
    local remove_ppa=false
    
    # Ask if user wants to remove PPA too
    if is_pop_ppa_added; then
        read -rp "Remove System76 PPA as well? (y/N): " answer
        [[ "${answer,,}" == "y" ]] && remove_ppa=true
    fi
    
    # Remove packages
    log_info "Removing Pop theme packages..."
    
    local packages=(
        "$POP_GTK_PACKAGE"
        "$POP_ICON_PACKAGE"
    )
    
    if sudo apt remove -y "${packages[@]}" &> /dev/null 2>&1; then
        log_success "Pop theme packages removed"
    else
        log_warning "Failed to remove some packages"
    fi
    
    # Remove PPA if requested
    if [[ "$remove_ppa" == true ]]; then
        remove_pop_ppa
    fi
    
    # Verify cleanup
    if ! verify_pop_installation; then
        log_success "Pop theme cleanup completed"
        return 0
    else
        log_warning "Some Pop theme components may still be present"
        return 1
    fi
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# ----------------------------------------------------------------------------
# check_pop_dependencies
# Checks if required tools are available
#
# Returns:
#   0 - All dependencies available
#   1 - Missing dependencies
# ----------------------------------------------------------------------------
check_pop_dependencies() {
    local missing_deps=()
    
    # Check for add-apt-repository
    if ! command -v add-apt-repository &> /dev/null; then
        missing_deps+=("software-properties-common")
    fi
    
    # Check for apt
    if ! command -v apt &> /dev/null; then
        log_error "APT not found. Pop theme requires Ubuntu/Debian"
        return 1
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt install ${missing_deps[*]}"
        
        # Try to auto-install
        log_info "Attempting to install dependencies..."
        if sudo apt install -y "${missing_deps[@]}" &> /dev/null; then
            log_success "Dependencies installed"
            return 0
        else
            log_error "Failed to install dependencies"
            return 1
        fi
    fi
    
    return 0
}

# ----------------------------------------------------------------------------
# get_pop_system_info
# Returns information about Pop theme on current system
#
# Output: System info relevant to Pop theme
# Returns: 0 always
# ----------------------------------------------------------------------------
get_pop_system_info() {
    local is_pop
    is_pop=$(is_pop_os && echo "yes" || echo "no")
    
    local ppa_added
    ppa_added=$(is_pop_ppa_added && echo "yes" || echo "no")
    
    local installed
    installed=$(verify_pop_installation && echo "yes" || echo "no")
    
    cat <<EOF
running_on_pop_os=$is_pop
system76_ppa_added=$ppa_added
pop_theme_installed=$installed
recommended=$([[ "$is_pop" == "yes" ]] && echo "highly" || echo "moderate")
nvidia_laptop=$([[ -d /proc/driver/nvidia ]] && echo "yes" || echo "no")
EOF
    
    return 0
}

# ----------------------------------------------------------------------------
# is_nvidia_system
# Checks if system has NVIDIA GPU (Pop is optimized for NVIDIA)
#
# Returns:
#   0 - NVIDIA GPU detected
#   1 - No NVIDIA GPU
# ----------------------------------------------------------------------------
is_nvidia_system() {
    # Check for NVIDIA driver
    if [[ -d /proc/driver/nvidia ]] || lspci | grep -i nvidia &> /dev/null; then
        return 0
    fi
    
    return 1
}

# ============================================================================
# MAIN EXECUTION (for standalone testing)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Pop Theme Module Test ==="
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
    check_pop_dependencies
    
    echo
    echo "2. System information:"
    get_pop_system_info
    
    echo
    echo "3. Checking current installation..."
    if verify_pop_installation; then
        echo "✓ Pop theme is installed"
        echo "  Installed variants: $(get_installed_pop_variants)"
    else
        echo "✗ Pop theme is not installed"
    fi
    
    echo
    echo "4. Metadata:"
    get_pop_metadata
    
    echo
    echo "5. Color palette:"
    get_pop_color_info
    
    echo
    echo "6. Recommended variant (dark):"
    get_pop_recommended_variant "dark"
    
    echo
    echo "=== Test Complete ==="
fi
