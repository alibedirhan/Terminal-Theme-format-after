#!/bin/bash

# ============================================================================
# Terminal Customization Suite - One-Line Installer
# v3.2.4 - Quick Installation Script
# ============================================================================
# Usage:
#   wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh
#   chmod +x install.sh
#   ./install.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
readonly REPO_URL="https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main"
readonly INSTALL_DIR="$HOME/.terminal-setup-installer"
readonly REQUIRED_FILES=(
    "terminal-setup.sh"
    "terminal-core.sh"
    "terminal-utils.sh"
    "terminal-ui.sh"
    "terminal-themes.sh"
    "terminal-assistant.sh"
)

# ============================================================================
# BANNER
# ============================================================================

show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║    ████████╗███████╗██╗                                   ║
║   ╚══██╔══╝██╔════╝██║     Terminal Customization        ║
║      ██║   █████╗  ██║     Suite v3.2.4                  ║
║      ██║   ██╔══╝  ██║                                    ║
║      ╚████████╔╝██║  ██║███████╗                          ║
║       ╚═════╝ ╚═╝  ╚═╝╚══════╝                          ║
║                                                           ║
║                One-Line Installer                         ║
║            github.com/alibedirhan                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ============================================================================
# LOGGING
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# ============================================================================
# CHECKS
# ============================================================================

check_requirements() {
    log_info "Gereksinimler kontrol ediliyor..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "Bu scripti root olarak çalıştırmayın!"
        exit 1
    fi
    
    # Check for required commands
    local missing_commands=()
    
    for cmd in wget curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_error "Eksik komutlar: ${missing_commands[*]}"
        echo "Lütfen kurun: sudo apt install ${missing_commands[*]}"
        exit 1
    fi
    
    # Check internet
    if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        log_error "İnternet bağlantısı yok!"
        exit 1
    fi
    
    log_success "Gereksinimler tamam"
}

# ============================================================================
# DOWNLOAD
# ============================================================================

download_files() {
    log_info "Dosyalar indiriliyor..."
    
    # Create temp directory
    if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
        log_error "Geçici dizin oluşturulamadı: $INSTALL_DIR"
        exit 1
    fi
    
    cd "$INSTALL_DIR" || exit 1
    
    local success_count=0
    local total_files=${#REQUIRED_FILES[@]}
    
    for file in "${REQUIRED_FILES[@]}"; do
        echo -ne "${CYAN}↓${NC} İndiriliyor: $file... "
        
        if timeout 30 wget --timeout=15 --tries=2 -q "$REPO_URL/$file" -O "$file" 2>/dev/null; then
            # Verify file size (should be > 1KB)
            local file_size
            file_size=$(wc -c < "$file" 2>/dev/null | tr -d '[:space:]')
            
            if [[ -n "$file_size" ]] && [[ "$file_size" -gt 1000 ]]; then
                echo -e "${GREEN}✓${NC}"
                ((success_count++))
                chmod +x "$file" 2>/dev/null
            else
                echo -e "${RED}✗${NC} (Dosya çok küçük)"
                rm -f "$file"
            fi
        else
            echo -e "${RED}✗${NC} (İndirilemedi)"
        fi
    done
    
    if [ $success_count -eq $total_files ]; then
        log_success "Tüm dosyalar indirildi ($success_count/$total_files)"
        return 0
    else
        log_error "Bazı dosyalar indirilemedi ($success_count/$total_files)"
        return 1
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_files() {
    log_info "Dosyalar doğrulanıyor..."
    
    cd "$INSTALL_DIR" || exit 1
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Eksik dosya: $file"
            return 1
        fi
        
        if [[ ! -r "$file" ]]; then
            log_error "Okunamayan dosya: $file"
            return 1
        fi
        
        # Basic shell syntax check
        if ! bash -n "$file" 2>/dev/null; then
            log_error "Sözdizimi hatası: $file"
            return 1
        fi
    done
    
    log_success "Tüm dosyalar doğrulandı"
    return 0
}

# ============================================================================
# LAUNCH
# ============================================================================

launch_installer() {
    log_info "Kurulum başlatılıyor..."
    echo
    sleep 1
    
    cd "$INSTALL_DIR" || exit 1
    
    if [[ -f "terminal-setup.sh" ]] && [[ -x "terminal-setup.sh" ]]; then
        exec ./terminal-setup.sh
    else
        log_error "terminal-setup.sh çalıştırılamadı"
        exit 1
    fi
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    if [[ "$1" != "success" ]] && [[ -d "$INSTALL_DIR" ]]; then
        log_info "Temizleniyor..."
        rm -rf "$INSTALL_DIR" 2>/dev/null || true
    fi
}

trap 'cleanup fail' EXIT INT TERM

# ============================================================================
# MAIN
# ============================================================================

main() {
    show_banner
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Terminal Customization Suite kuruluma hazırlanıyor    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Step 1: Check requirements
    if ! check_requirements; then
        exit 1
    fi
    
    # Step 2: Download files
    echo
    if ! download_files; then
        log_error "Dosya indirme başarısız!"
        exit 1
    fi
    
    # Step 3: Verify files
    echo
    if ! verify_files; then
        log_error "Dosya doğrulama başarısız!"
        exit 1
    fi
    
    # Step 4: Launch
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ✓ Hazır! Ana kurulum başlatılıyor...                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    sleep 2
    
    # Don't cleanup on success
    trap - EXIT
    
    launch_installer
}

# Run main
main "$@"
