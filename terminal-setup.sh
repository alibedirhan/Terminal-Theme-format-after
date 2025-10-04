#!/bin/bash

# ============================================================================
# Terminal Özelleştirme Kurulum Aracı - Ana Script
# v3.2.0 - Modüler Yapı + Akıllı Asistan
# ============================================================================
# Dosya Yapısı:
# - terminal-setup.sh      (bu dosya - orchestration)
# - terminal-ui.sh         (görsel arayüz)
# - terminal-themes.sh     (tema tanımları)
# - terminal-core.sh       (kurulum fonksiyonları)
# - terminal-utils.sh      (yardımcı fonksiyonlar)
# - terminal-assistant.sh  (akıllı sorun giderme asistanı)
# ============================================================================

# Script versiyonu
VERSION="3.2.0"
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
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR" || {
    echo "HATA: Gerekli dizinler oluşturulamadı!"
    exit 1
}

# ============================================================================
# MODÜL YÜKLEME
# ============================================================================

load_modules() {
    local modules=(
        "terminal-utils.sh"
        "terminal-ui.sh"
        "terminal-themes.sh"
        "terminal-core.sh"
        "terminal-assistant.sh"
    )
    
    for module in "${modules[@]}"; do
        local module_path="$SCRIPT_DIR/$module"
        if [[ -f "$module_path" ]]; then
            # shellcheck source=/dev/null
            source "$module_path" || {
                echo "HATA: $module yüklenemedi!"
                exit 1
            }
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
    if [[ -n "${SUDO_REFRESH_PID:-}" ]]; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null || true
    fi
    
    # Core modülündeki cleanup'ı da çağır
    if type cleanup_sudo &>/dev/null; then
        cleanup_sudo
    fi
}

trap cleanup EXIT INT TERM

# ============================================================================
# TAM KURULUM WRAPPER FONKSİYONU
# ============================================================================

perform_full_install() {
    local theme=$1
    local theme_display=$2
    
    # Kurulum öncesi akıllı tarama
    if ! pre_installation_scan; then
        log_error "Sistem kurulum için hazır değil"
        return 1
    fi
    
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${BOLD}${theme_display^^} KURULUMU BAŞLIYOR${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    
    # Ön kontroller
    echo
    echo -e "${CYAN}┌──── HAZIRLIK ────┐${NC}"
    
    if ! check_dependencies; then
        log_error "Bağımlılık kontrolü başarısız"
        return 1
    fi
    show_step_success "Bağımlılıklar kontrol edildi"
    
    if ! setup_sudo; then
        log_error "Sudo yetkisi alınamadı"
        return 1
    fi
    show_step_success "Sudo yetkisi alındı"
    
    if ! create_backup; then
        log_error "Yedekleme başarısız"
        return 1
    fi
    show_step_success "Yedek oluşturuldu"
    
    # Kurulum adımları
    show_section 1 7 "Zsh kuruluyor"
    if install_zsh; then
        post_installation_verification "zsh"
    else
        return 1
    fi
    
    show_section 2 7 "Oh My Zsh kuruluyor"
    if install_oh_my_zsh; then
        post_installation_verification "ohmyzsh"
    else
        return 1
    fi
    
    show_section 3 7 "Fontlar kuruluyor"
    if install_fonts; then
        post_installation_verification "fonts"
    fi
    
    show_section 4 7 "Powerlevel10k kuruluyor"
    if install_powerlevel10k; then
        post_installation_verification "powerlevel10k"
    else
        return 1
    fi
    
    show_section 5 7 "Pluginler kuruluyor"
    if install_plugins; then
        post_installation_verification "plugins"
    fi
    
    show_section 6 7 "$theme_display teması uygulanıyor"
    install_theme "$theme"
    
    show_section 7 7 "Shell değiştiriliyor"
    change_default_shell
    
    # Bash aliases migrasyonu
    echo
    echo -e "${CYAN}┌──── BASH ALIASES KONTROLÜ ────┐${NC}"
    migrate_bash_aliases
    
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${GREEN}✓ KURULUM BAŞARIYLA TAMAMLANDI${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${DIM}Yedekler: $BACKUP_DIR${NC}"
    echo -e "${DIM}Log dosyası: $LOG_FILE${NC}"
    
    # Kurulum sonrası yardım
    show_contextual_help "post_install"
    
    # Otomatik Zsh'e geçiş
    if show_switch_shell_prompt; then
        exec zsh
    fi
    
    return 0
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
        return 0
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
# TEŞHİS YÖNETİMİ (Assistant'a yönlendirir)
# ============================================================================

manage_diagnostics() {
    # Artık troubleshooting_wizard kullanıyoruz
    troubleshooting_wizard
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
                show_animated_banner
                system_health_check
                exit 0
                ;;
            --update)
                show_animated_banner
                check_for_updates
                exit 0
                ;;
            --scan)
                show_animated_banner
                pre_installation_scan
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
TEMP_DIR=$(mktemp -d -t terminal-setup.XXXXXXXXXX) || {
    echo "HATA: Geçici dizin oluşturulamadı!"
    exit 1
}

# Argümanları parse et
parse_arguments "$@"

# Config yükle
load_config

# Otomatik güncelleme kontrolü
if [[ "${AUTO_UPDATE:-false}" == "true" ]]; then
    check_for_updates --silent
fi

# ============================================================================
# ANA PROGRAM DÖNGÜSÜ
# ============================================================================

# İLK AÇILIŞ - ANİMASYONLU BANNER
show_animated_banner
sleep 1

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
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}ZSH + OH MY ZSH KURULUMU${NC}             ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            
            show_section 1 3 "Zsh kuruluyor"
            if install_zsh; then
                post_installation_verification "zsh"
            fi
            
            show_section 2 3 "Oh My Zsh kuruluyor"
            if install_oh_my_zsh; then
                post_installation_verification "ohmyzsh"
            fi
            
            show_section 3 3 "Shell değiştiriliyor"
            change_default_shell
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
            show_contextual_help "post_zsh"
            
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
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}POWERLEVEL10K KURULUMU${NC}               ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            
            show_section 1 2 "Fontlar kuruluyor"
            if install_fonts; then
                post_installation_verification "fonts"
            fi
            
            show_section 2 2 "Powerlevel10k kuruluyor"
            if install_powerlevel10k; then
                post_installation_verification "powerlevel10k"
            fi
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
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
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}PLUGİN KURULUMU${NC}                      ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            echo
            
            if install_plugins; then
                post_installation_verification "plugins"
            fi
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
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
                
                clear
                echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║   ${BOLD}TERMİNAL ARAÇLARI KURULUMU${NC}          ${CYAN}║${NC}"
                echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
                
                show_section 1 4 "FZF kuruluyor"
                install_fzf
                
                show_section 2 4 "Zoxide kuruluyor"
                install_zoxide
                
                show_section 3 4 "Exa kuruluyor"
                install_exa
                
                show_section 4 4 "Bat kuruluyor"
                install_bat
                
                echo
                echo -e "${GREEN}✓ Tamamlandı${NC}"
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
            read -p "Devam etmek için Enter'a basın..."
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