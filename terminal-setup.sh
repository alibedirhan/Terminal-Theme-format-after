#!/bin/bash

# ============================================================================
# Terminal Özelleştirme Kurulum Aracı - Ana Script
# v3.1.0 - Modüler Yapı
# ============================================================================
# Dosya Yapısı:
# - terminal-setup.sh      (bu dosya - orchestration)
# - terminal-ui.sh         (görsel arayüz)
# - terminal-themes.sh     (tema tanımları)
# - terminal-core.sh       (kurulum fonksiyonları)
# - terminal-utils.sh      (yardımcı fonksiyonlar)
# ============================================================================

# Script versiyonu
VERSION="3.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global değişkenler - Organize edilmiş yapı
BASE_DIR="$HOME/.terminal-setup"
BACKUP_DIR="$BASE_DIR/backups"
LOG_DIR="$BASE_DIR/logs"
CONFIG_DIR="$BASE_DIR/config"
TEMP_DIR=""
CONFIG_FILE="$CONFIG_DIR/settings.conf"
LOG_FILE="$LOG_DIR/terminal-setup.log"

# Flags
DEBUG_MODE=false
VERBOSE_MODE=false

# Dizinleri oluştur
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR"

# ============================================================================
# MODÜL YÜKLEME
# ============================================================================

# Modülleri yükle
load_modules() {
    local modules=(
        "terminal-utils.sh"
        "terminal-ui.sh"
        "terminal-themes.sh"
        "terminal-core.sh"
    )
    
    for module in "${modules[@]}"; do
        local module_path="$SCRIPT_DIR/$module"
        if [[ -f "$module_path" ]]; then
            source "$module_path"
        else
            echo "HATA: $module bulunamadı!"
            echo "Lütfen tüm dosyaların aynı dizinde olduğundan emin olun."
            exit 1
        fi
    done
}

# Modülleri yükle
load_modules

# ============================================================================
# CLEANUP FONKSİYONU
# ============================================================================

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

# ============================================================================
# TAM KURULUM WRAPPER FONKSİYONU
# ============================================================================

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
    
    # Bash aliases migrasyonu
    migrate_bash_aliases
    
    show_completion_message
    
    # Otomatik Zsh'e geçiş
    if show_switch_shell_prompt; then
        exec zsh
    fi
}

# ============================================================================
# TEMA KURULUM WRAPPER
# ============================================================================

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

# ============================================================================
# TEMA DEĞİŞTİRME İŞLEMİ
# ============================================================================

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
        
        # Zsh aktif mi kontrol et
        if [[ "$SHELL" == *"zsh"* ]]; then
            echo
            echo -e "${YELLOW}Değişiklikleri görmek için terminali yenileyin:${NC} ${CYAN}source ~/.zshrc${NC}"
        fi
    else
        log_error "Tema değiştirme başarısız"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# ============================================================================
# TEŞHİS YÖNETİMİ
# ============================================================================

manage_diagnostics() {
    while true; do
        show_diagnostic_menu
        read -r diag_choice
        
        case $diag_choice in
            1)
                diagnose_and_fix "zsh_not_default"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                diagnose_and_fix "internet_connection"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            3)
                diagnose_and_fix "permission_denied" "genel"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            4)
                diagnose_and_fix "font_not_visible"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                diagnose_and_fix "theme_not_applied"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            6)
                echo
                echo "Eksik paket kontrolü..."
                check_dependencies
                read -p "Devam etmek için Enter'a basın..."
                ;;
            7)
                echo
                log_info "Kapsamlı sistem kontrolü başlatılıyor..."
                echo
                
                # Tüm kontroller
                diagnose_and_fix "zsh_not_default"
                echo
                echo "─────────────────────────────────────"
                echo
                
                diagnose_and_fix "internet_connection"
                echo
                echo "─────────────────────────────────────"
                echo
                
                diagnose_and_fix "font_not_visible"
                echo
                echo "─────────────────────────────────────"
                echo
                
                diagnose_and_fix "theme_not_applied"
                echo
                
                read -p "Devam etmek için Enter'a basın..."
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

# ============================================================================
# AYARLAR YÖNETİMİ
# ============================================================================

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

# ============================================================================
# KOMUT SATIRI ARGÜMANLARI
# ============================================================================

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

# ============================================================================
# ROOT KONTROLÜ
# ============================================================================

if [[ $EUID -eq 0 ]]; then
    log_error "Bu scripti root olarak çalıştırmayın!"
    exit 1
fi

# ============================================================================
# BAŞLATMA
# ============================================================================

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

# ============================================================================
# ANA PROGRAM DÖNGÜSÜ
# ============================================================================

while true; do
    show_banner
    show_menu
    read -r choice
    
    case $choice in
        1)
            perform_full_install "dracula" "Dracula"
            ;;
        2)
            perform_full_install "nord" "Nord"
            ;;
        3)
            perform_full_install "gruvbox" "Gruvbox"
            ;;
        4)
            perform_full_install "tokyo-night" "Tokyo Night"
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
            
            # Zsh'e geçiş öner
            if show_switch_shell_prompt; then
                exec zsh
            else
                read -p "Devam etmek için Enter'a basın..."
            fi
            ;;
        6)
            check_dependencies || { read -p "Devam etmek için Enter'a basın..."; continue; }
            create_backup
            show_progress 1 2 "Fontlar kuruluyor"
            install_fonts
            show_progress 2 2 "Powerlevel10k kuruluyor"
            install_powerlevel10k
            log_success "Tamamlandı"
            
            # Eğer zsh aktifse source et
            if [[ "$SHELL" == *"zsh"* ]]; then
                echo
                echo -e "${YELLOW}Değişiklikleri uygulamak için:${NC} ${CYAN}source ~/.zshrc${NC}"
            fi
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
            
            # Eğer zsh aktifse source et
            if [[ "$SHELL" == *"zsh"* ]]; then
                echo
                echo -e "${YELLOW}Değişiklikleri uygulamak için:${NC} ${CYAN}source ~/.zshrc${NC}"
            fi
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
            manage_diagnostics
            ;;
        13)
            show_backups
            ;;
        14)
            uninstall_all
            read -p "Devam etmek için Enter'a basın..."
            ;;
        15)
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