#!/bin/bash

# ============================================================================
# System Theme Setup v2.0 - Multi-DE Support
# Ubuntu LTS Theme Manager with Desktop Environment Detection
# ============================================================================

# DON'T use set -e - we want manual error handling
# set -euo pipefail

# ============================================================================
# SCRIPT INITIALIZATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load core modules
source "$SCRIPT_DIR/core/config.sh" || exit 1
source "$SCRIPT_DIR/core/logger.sh" || exit 1
source "$SCRIPT_DIR/core/detection.sh" || exit 1
source "$SCRIPT_DIR/core/safety.sh" || exit 1

# Load utilities
source "$SCRIPT_DIR/utils/theme-utils.sh" || exit 1
source "$SCRIPT_DIR/utils/theme-assistant.sh" || exit 1

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

initialize_system() {
    clear
    print_banner
    
    log_info "System Theme Setup v2.0 başlatılıyor..."
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$LOG_DIR"
    
    # Initialize logger
    init_logger
    
    # Detect system
    detect_system_info
    
    # Check dependencies
    check_dependencies
    
    # Create initial backup
    create_system_backup || {
        log_warning "Yedek oluşturulamadı ama devam ediliyor..."
    }
    
    log_success "Sistem başarıyla başlatıldı"
}

detect_system_info() {
    log_info "Sistem bilgileri tespit ediliyor..."
    
    # Detect Desktop Environment
    DETECTED_DE=$(detect_desktop_environment)
    export DETECTED_DE
    
    # Detect Ubuntu version
    DETECTED_VERSION=$(detect_ubuntu_version)
    export DETECTED_VERSION
    
    # Detect ZSH
    DETECTED_ZSH=$(detect_zsh_framework)
    export DETECTED_ZSH
    
    # Display detection results
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        SİSTEM TESPİT SONUÇLARI               ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} 🖥️  Desktop Environment: ${BOLD}$DETECTED_DE${NC}"
    echo -e "${CYAN}║${NC} 🐧 Ubuntu Version: ${BOLD}$DETECTED_VERSION${NC}"
    echo -e "${CYAN}║${NC} 💻 Terminal Shell: ${BOLD}$DETECTED_ZSH${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo
    
    # Check if DE is supported
    if ! is_de_supported "$DETECTED_DE"; then
        log_error "Desktop Environment '$DETECTED_DE' henüz desteklenmiyor!"
        echo
        echo -e "${YELLOW}Desteklenen DE'ler:${NC}"
        echo "  • GNOME"
        echo "  • KDE Plasma"
        echo "  • XFCE"
        echo "  • MATE"
        echo "  • Cinnamon"
        echo
        exit 1
    fi
    
    log_success "Sistem başarıyla tespit edildi"
}

print_banner() {
    echo -e "${BOLD}${CYAN}"
    cat << 'BANNER'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗         ║
║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║         ║
║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║         ║
║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║         ║
║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║         ║
║    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝         ║
║                                                                   ║
║               THEME SETUP v2.0 - Multi-DE Edition                ║
║                   Ubuntu LTS Theme Manager                       ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

show_main_menu() {
    clear
    print_banner
    
    # Show current theme status
    show_current_status
    
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ANA MENÜ                                   ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC}  1. 🎨 Tema Seç ve Uygula                                  ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  2. 👁️  Tema Önizlemeleri                                   ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  3. 🔍 Sistem Uyumluluk Kontrolü                           ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  4. 💾 Varsayılana Dön                                     ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  5. 🗑️  Temaları Temizle                                    ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  6. ⚙️  Ayarlar                                             ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  7. ❓ Yardım ve Sorun Giderme                             ${GREEN}║${NC}"
    echo -e "${WHITE}║${NC}  0. 🚪 Çıkış                                               ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -ne "${BOLD}${CYAN}Seçiminiz (0-7): ${NC}"
}

show_current_status() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  MEVCUT DURUM                                 ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} 🖥️  Desktop Environment: ${BOLD}$DETECTED_DE${NC}"
    echo -e "${WHITE}║${NC} 🐧 Ubuntu: ${BOLD}$DETECTED_VERSION${NC}"
    echo -e "${WHITE}║${NC} 💻 Shell: ${BOLD}$DETECTED_ZSH${NC} ${GREEN}(Korunuyor ✓)${NC}"
    
    # Get current theme info based on DE
    local current_theme=$(get_current_theme_name)
    echo -e "${WHITE}║${NC} 🎨 Aktif Tema: ${BOLD}$current_theme${NC}"
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

show_theme_selection() {
    clear
    print_banner
    
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║          TEMA SEÇİMİ - $DETECTED_DE UYUMLU TEMALAR           ║${NC}"
    echo -e "${MAGENTA}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    echo -e "${WHITE}║${NC}  1. 🏆 Arc Dark + Papirus (En Popüler)                    ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  2. 🎯 Yaru Dark (Ubuntu Resmi)                           ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  3. 🚀 Pop Dark (Modern & Clean)                          ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  4. 🧛 Dracula (Developer Favorite)                       ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  5. ❄️  Nord (Eye-Comfort)                                 ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  6. 🐱 Catppuccin Mocha (Trending)                        ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  7. 🟤 Gruvbox Dark (Retro)                               ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  8. 🌃 Tokyo Night (Developer's Choice)                   ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  9. 🔮 Cyberpunk Neon (Futuristic)                        ${MAGENTA}║${NC}"
    echo -e "${WHITE}║${NC}  0. ⬅️  Geri Dön                                           ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -ne "${BOLD}${MAGENTA}Tema Seçimi (0-9): ${NC}"
}

apply_selected_theme() {
    local theme_id="$1"
    
    # Map selection to theme name
    local theme_name=""
    case $theme_id in
        1) theme_name="arc" ;;
        2) theme_name="yaru" ;;
        3) theme_name="pop" ;;
        4) theme_name="dracula" ;;
        5) theme_name="nord" ;;
        6) theme_name="catppuccin" ;;
        7) theme_name="gruvbox" ;;
        8) theme_name="tokyonight" ;;
        9) theme_name="cyberpunk" ;;
        *) log_error "Geçersiz tema seçimi"; return 1 ;;
    esac
    
    echo
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ${theme_name^^} TEMASI UYGULANIOR...${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Create backup before applying
    log_info "Yedek oluşturuluyor..."
    create_theme_backup || log_warning "Yedek oluşturulamadı"
    
    # Protect ZSH configuration
    log_info "ZSH konfigürasyonu korunuyor..."
    protect_zsh_config || log_warning "ZSH koruması başarısız oldu"
    
    # Load DE-specific module
    local de_module="$SCRIPT_DIR/desktop-environments/de-$(echo $DETECTED_DE | tr '[:upper:]' '[:lower:]').sh"
    
    if [[ -f "$de_module" ]]; then
        source "$de_module"
        
        # Apply theme using DE-specific function
        if apply_theme_for_de "$theme_name"; then
            echo
            echo -e "${GREEN}✅ ${theme_name^^} teması başarıyla uygulandı!${NC}"
            echo -e "${YELLOW}📝 Not: Tüm değişikliklerin görünmesi için logout/login yapın.${NC}"
            echo
            
            # Show post-install tips
            show_theme_tips "$theme_name"
        else
            log_error "${theme_name} teması uygulanamadı!"
            echo
            echo -e "${YELLOW}🔄 Yedekten geri yüklemek ister misiniz? (e/h): ${NC}"
            read -r restore_choice
            if [[ "$restore_choice" == "e" ]]; then
                restore_from_backup
            fi
        fi
    else
        log_error "Desktop Environment modülü bulunamadı: $de_module"
        return 1
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

main_loop() {
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                show_theme_selection
                read -r theme_choice
                if [[ "$theme_choice" != "0" ]]; then
                    apply_selected_theme "$theme_choice"
                fi
                ;;
            2)
                show_theme_previews
                ;;
            3)
                run_compatibility_check
                ;;
            4)
                reset_to_default
                ;;
            5)
                cleanup_themes
                ;;
            6)
                show_settings_menu
                ;;
            7)
                show_help_menu
                ;;
            0)
                log_success "System Theme Setup kapatılıyor..."
                echo
                echo -e "${GREEN}👋 Görüşmek üzere!${NC}"
                exit 0
                ;;
            *)
                log_error "Geçersiz seçim!"
                sleep 2
                ;;
        esac
    done
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main() {
    # Initialize system
    initialize_system
    
    # Check if running with proper permissions
    if [[ $EUID -eq 0 ]]; then
        log_error "Bu script root olarak çalıştırılmamalı!"
        echo "Lütfen normal kullanıcı olarak çalıştırın."
        exit 1
    fi
    
    # Start main loop
    main_loop
}

# Run main function
main "$@"