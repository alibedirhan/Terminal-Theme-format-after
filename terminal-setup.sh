#!/bin/bash

# ============================================================================
# Terminal Özelleştirme Kurulum Aracı - Ana Script
# v3.1.0 - Modüler Yapı
# ============================================================================
# Dosya Yapısı:
# - terminal-setup.sh      (bu dosya - orchestration)
# - terminal-core.sh       (kurulum fonksiyonları)
# - terminal-utils.sh      (yardımcı fonksiyonlar)
# ============================================================================

# Script versiyonu
VERSION="3.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global değişkenler
BACKUP_DIR="$HOME/.terminal-setup-backup"
TEMP_DIR=""
CONFIG_FILE="$HOME/.terminal-setup.conf"
LOG_FILE="$HOME/.terminal-setup.log"

# Flags
DEBUG_MODE=false
VERBOSE_MODE=false

# Modülleri yükle
if [[ -f "$SCRIPT_DIR/terminal-utils.sh" ]]; then
    source "$SCRIPT_DIR/terminal-utils.sh"
else
    echo "HATA: terminal-utils.sh bulunamadı!"
    echo "Lütfen tüm dosyaların aynı dizinde olduğundan emin olun."
    exit 1
fi

if [[ -f "$SCRIPT_DIR/terminal-core.sh" ]]; then
    source "$SCRIPT_DIR/terminal-core.sh"
else
    log_error "terminal-core.sh bulunamadı!"
    exit 1
fi

# Temizlik fonksiyonu
cleanup() {
    [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    
    # Sudo refresh process'ini durdur
    if [[ -n "$SUDO_REFRESH_PID" ]]; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null
    fi
    
    # Core modülündeki cleanup'ı da çağır
    if type cleanup_sudo &>/dev/null; then
        cleanup_sudo
    fi
}

trap cleanup EXIT

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║       TERMİNAL ÖZELLEŞTİRME KURULUM ARACI v${VERSION}        ║"
    echo "║                                                          ║"
    echo "║  • Zsh + Oh My Zsh                                       ║"
    echo "║  • Powerlevel10k Teması                                  ║"
    echo "║  • 7 Farklı Renk Teması                                  ║"
    echo "║  • Çoklu Terminal Emulator Desteği                       ║"
    echo "║  • Syntax Highlighting & Auto-suggestions                ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Ana menü
show_menu() {
    echo -e "${YELLOW}═══ ANA MENÜ ═══${NC}"
    echo
    echo -e "${CYAN}Tam Kurulum:${NC}"
    echo "  1) Dracula Teması ile Tam Kurulum"
    echo "  2) Nord Teması ile Tam Kurulum"
    echo "  3) Gruvbox Teması ile Tam Kurulum"
    echo "  4) Tokyo Night Teması ile Tam Kurulum"
    echo
    echo -e "${CYAN}Modüler Kurulum:${NC}"
    echo "  5) Sadece Zsh + Oh My Zsh"
    echo "  6) Sadece Powerlevel10k Teması"
    echo "  7) Sadece Renk Teması Değiştir"
    echo "  8) Sadece Pluginler"
    echo "  9) Terminal Araçları (FZF, Zoxide, Exa, Bat)"
    echo " 10) Tmux Kurulumu"
    echo
    echo -e "${CYAN}Yönetim:${NC}"
    echo " 11) Sistem Sağlık Kontrolü"
    echo " 12) Yedekleri Göster"
    echo " 13) Tümünü Kaldır"
    echo " 14) Ayarlar"
    echo "  0) Çıkış"
    echo
    echo -n "Seçiminiz (0-14): "
}

# Tema seçim menüsü
show_theme_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           TEMA SEÇİMİ                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo
    
    local terminal_type=$(detect_terminal)
    echo -e "${YELLOW}Tespit edilen terminal: ${terminal_type}${NC}"
    echo
    
    echo "1) Dracula        - Mor/Pembe tonları, yüksek kontrast"
    echo "2) Nord           - Mavi/Gri tonları, göze yumuşak"
    echo "3) Gruvbox Dark   - Retro, sıcak tonlar"
    echo "4) Tokyo Night    - Modern, mavi/mor tonlar"
    echo "5) Catppuccin     - Pastel renkler"
    echo "6) One Dark       - Atom editor benzeri"
    echo "7) Solarized Dark - Klasik, düşük kontrast"
    echo "0) Geri"
    echo
    echo -n "Seçiminiz (0-7): "
}

# Ayarlar menüsü
show_settings_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              AYARLAR                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo
    
    load_config
    
    echo -e "${YELLOW}Mevcut Ayarlar:${NC}"
    echo "  Varsayılan Tema: ${DEFAULT_THEME:-Yok}"
    echo "  Otomatik Güncelleme: ${AUTO_UPDATE:-false}"
    echo "  Yedek Sayısı: ${BACKUP_COUNT:-5}"
    echo "  Debug Modu: ${DEBUG_MODE}"
    echo
    echo "1) Varsayılan Tema Değiştir"
    echo "2) Otomatik Güncelleme ($([ "$AUTO_UPDATE" = "true" ] && echo "Kapat" || echo "Aç"))"
    echo "3) Yedek Sayısını Ayarla"
    echo "4) Güncellemeleri Kontrol Et"
    echo "5) Ayarları Sıfırla"
    echo "0) Geri"
    echo
    echo -n "Seçiminiz (0-5): "
}

# Tam kurulum wrapper fonksiyonu
perform_full_install() {
    local theme=$1
    local theme_display=$2
    
    show_banner
    echo -e "${CYAN}Tam kurulum başlıyor ($theme_display teması)...${NC}"
    echo
    
    # Ön kontroller
    if ! check_dependencies; then
        log_error "Bağımlılık kontrolü başarısız"
        return 1
    fi
    
    if ! setup_sudo; then
        log_error "Sudo yetkisi alınamadı"
        return 1
    fi
    
    # Progress tracking
    local total_steps=7
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Yedek oluşturuluyor"
    create_backup
    
    show_progress $((++current_step)) $total_steps "Zsh kuruluyor"
    install_zsh || return 1
    
    show_progress $((++current_step)) $total_steps "Oh My Zsh kuruluyor"
    install_oh_my_zsh || return 1
    
    show_progress $((++current_step)) $total_steps "Fontlar kuruluyor"
    install_fonts
    
    show_progress $((++current_step)) $total_steps "Powerlevel10k kuruluyor"
    install_powerlevel10k || return 1
    
    show_progress $((++current_step)) $total_steps "Pluginler kuruluyor"
    install_plugins
    
    show_progress $((++current_step)) $total_steps "Tema uygulanıyor"
    install_theme "$theme"
    
    show_progress $total_steps $total_steps "Shell değiştiriliyor"
    change_default_shell
    
    show_completion_message
}

# Tema kurulum wrapper
install_theme_wrapper() {
    local theme=$1
    
    case $theme in
        1|dracula)
            install_theme "dracula"
            ;;
        2|nord)
            install_theme "nord"
            ;;
        3|gruvbox)
            install_theme "gruvbox"
            ;;
        4|tokyo-night)
            install_theme "tokyo-night"
            ;;
        5|catppuccin)
            install_theme "catppuccin"
            ;;
        6|one-dark)
            install_theme "one-dark"
            ;;
        7|solarized)
            install_theme "solarized"
            ;;
        *)
            log_error "Geçersiz tema seçimi"
            return 1
            ;;
    esac
}

# Tema değiştirme işlemi
change_theme_only() {
    show_theme_menu
    read -r theme_choice
    
    if [[ "$theme_choice" == "0" ]]; then
        return
    fi
    
    echo
    log_info "Tema değiştiriliyor..."
    
    if install_theme_wrapper "$theme_choice"; then
        log_success "Tema başarıyla değiştirildi!"
        echo "Terminal'i yeniden başlatın veya 'source ~/.zshrc' çalıştırın"
    else
        log_error "Tema değiştirme başarısız"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# Ayarlar yönetimi
manage_settings() {
    while true; do
        show_settings_menu
        read -r setting_choice
        
        case $setting_choice in
            1)
                echo
                show_theme_menu
                read -r theme_num
                if [[ $theme_num -ge 1 && $theme_num -le 7 ]]; then
                    local theme_names=("dracula" "nord" "gruvbox" "tokyo-night" "catppuccin" "one-dark" "solarized")
                    DEFAULT_THEME="${theme_names[$((theme_num-1))]}"
                    save_config
                    log_success "Varsayılan tema ayarlandı: $DEFAULT_THEME"
                fi
                sleep 2
                ;;
            2)
                if [[ "$AUTO_UPDATE" == "true" ]]; then
                    AUTO_UPDATE="false"
                    log_info "Otomatik güncelleme kapatıldı"
                else
                    AUTO_UPDATE="true"
                    log_success "Otomatik güncelleme açıldı"
                fi
                save_config
                sleep 2
                ;;
            3)
                echo -n "Yeni yedek sayısı (1-20): "
                read -r new_count
                if [[ $new_count =~ ^[0-9]+$ ]] && [[ $new_count -ge 1 && $new_count -le 20 ]]; then
                    BACKUP_COUNT=$new_count
                    save_config
                    log_success "Yedek sayısı ayarlandı: $BACKUP_COUNT"
                fi
                sleep 2
                ;;
            4)
                echo
                check_for_updates
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                echo -n "Ayarları sıfırlamak istediğinizden emin misiniz? (e/h): "
                read -r confirm
                if [[ "$confirm" == "e" ]]; then
                    rm -f "$CONFIG_FILE"
                    log_success "Ayarlar sıfırlandı"
                    sleep 2
                fi
                ;;
            0)
                break
                ;;
            *)
                log_error "Geçersiz seçim"
                sleep 1
                ;;
        esac
    done
}

# Tamamlanma mesajı
show_completion_message() {
    echo
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Kurulum tamamlandı!${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Sonraki adımlar:${NC}"
    echo "1. Terminal'i kapatıp yeniden açın (veya 'exec zsh' yazın)"
    echo "2. Powerlevel10k yapılandırma wizard'ı otomatik başlayacak"
    echo "3. İsterseniz daha sonra 'p10k configure' ile yeniden yapılandırabilirsiniz"
    echo
    echo -e "${CYAN}Yedekler: $BACKUP_DIR${NC}"
    echo -e "${CYAN}Log dosyası: $LOG_FILE${NC}"
}

# Komut satırı argümanları
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                DEBUG_MODE=true
                log_info "Debug modu aktif"
                shift
                ;;
            --verbose)
                VERBOSE_MODE=true
                log_info "Verbose modu aktif"
                shift
                ;;
            --health)
                show_banner
                system_health_check
                exit 0
                ;;
            --update)
                show_banner
                check_for_updates
                exit 0
                ;;
            --version)
                echo "Terminal Setup v$VERSION"
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Bilinmeyen parametre: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Yardım mesajı
show_help() {
    echo "Terminal Özelleştirme Kurulum Aracı v$VERSION"
    echo
    echo "Kullanım: $0 [SEÇENEKLER]"
    echo
    echo "Seçenekler:"
    echo "  --health          Sistem sağlık kontrolü"
    echo "  --update          Güncellemeleri kontrol et"
    echo "  --debug           Debug modu"
    echo "  --verbose         Detaylı çıktı"
    echo "  --version         Versiyon bilgisi"
    echo "  --help, -h        Bu yardım mesajı"
    echo
    echo "Örnekler:"
    echo "  $0                # Normal mod"
    echo "  $0 --health       # Sadece sağlık kontrolü"
    echo "  $0 --debug        # Debug modu ile çalıştır"
}

# Root kontrolü
if [[ $EUID -eq 0 ]]; then
    log_error "Bu scripti root olarak çalıştırmayın!"
    exit 1
fi

# Güvenli temp directory oluştur
TEMP_DIR=$(mktemp -d -t terminal-setup.XXXXXXXXXX)

# Argümanları parse et
parse_arguments "$@"

# Config yükle
load_config

# Otomatik güncelleme kontrolü
if [[ "$AUTO_UPDATE" == "true" ]]; then
    check_for_updates --silent
fi

# Ana program döngüsü
while true; do
    show_banner
    show_menu
    read -r choice
    
    case $choice in
        1)
            perform_full_install "dracula" "Dracula"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        2)
            perform_full_install "nord" "Nord"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        3)
            perform_full_install "gruvbox" "Gruvbox"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        4)
            perform_full_install "tokyo-night" "Tokyo Night"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        5)
            check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
            setup_sudo || { read -p "Devam etmek için Enter'a basın..."; continue; }
            create_backup
            show_progress 1 3 "Zsh kuruluyor"
            install_zsh
            show_progress 2 3 "Oh My Zsh kuruluyor"
            install_oh_my_zsh
            show_progress 3 3 "Shell değiştiriliyor"
            change_default_shell
            log_success "Tamamlandı"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        6)
            check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
            create_backup
            show_progress 1 2 "Fontlar kuruluyor"
            install_fonts
            show_progress 2 2 "Powerlevel10k kuruluyor"
            install_powerlevel10k
            log_success "Tamamlandı"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        7)
            change_theme_only
            ;;
        8)
            check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
            create_backup
            install_plugins
            log_success "Tamamlandı"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        9)
            if show_terminal_tools_info; then
                check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
                setup_sudo || { read -p "Devam etmek için Enter'a basın..."; continue; }
                install_all_tools
                log_success "Tamamlandı"
            fi
            read -p "Devam etmek için Enter'a basın..."
            ;;
        10)
            echo
            echo -e "${YELLOW}Hangi tema ile Tmux kurmak istersiniz?${NC}"
            echo "1) Dracula"
            echo "2) Nord"
            echo "3) Gruvbox"
            echo "4) Tokyo Night"
            echo "5) Catppuccin"
            echo "6) One Dark"
            echo "7) Solarized"
            echo -n "Seçiminiz (1-7): "
            read -r tmux_theme_choice
            
            local tmux_theme="dracula"
            case $tmux_theme_choice in
                1) tmux_theme="dracula" ;;
                2) tmux_theme="nord" ;;
                3) tmux_theme="gruvbox" ;;
                4) tmux_theme="tokyo-night" ;;
                5) tmux_theme="catppuccin" ;;
                6) tmux_theme="one-dark" ;;
                7) tmux_theme="solarized" ;;
                *) log_error "Geçersiz seçim, Dracula kullanılıyor"; tmux_theme="dracula" ;;
            esac
            
            check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
            setup_sudo || { read -p "Devam etmek için Enter'a basın..."; continue; }
            install_tmux_with_theme "$tmux_theme"
            log_success "Tamamlandı"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        11)
            show_banner
            system_health_check
            read -p "Devam etmek için Enter'a basın..."
            ;;
        12)
            show_backups
            ;;
        13)
            uninstall_all
            read -p "Devam etmek için Enter'a basın..."
            ;;
        14)
            manage_settings
            ;;
        0)
            log_info "Çıkılıyor..."
            exit 0
            ;;
        *)
            log_error "Geçersiz seçim!"
            sleep 2
            ;;
    esac
done