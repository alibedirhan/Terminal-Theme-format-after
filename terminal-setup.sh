#!/bin/bash

# ============================================================================
# Terminal Özelleştirme Kurulum Aracı - Ana Script
# v3.2.1 - Production Ready (Lock + Signal Handling + Validation)
# ============================================================================

set -euo pipefail  # Strict mode: exit on error, undefined var, pipe fail

# Script versiyonu
readonly VERSION="3.2.1"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Global değişkenler
readonly BASE_DIR="$HOME/.terminal-setup"
readonly BACKUP_DIR="$BASE_DIR/backups"
readonly LOG_DIR="$BASE_DIR/logs"
readonly CONFIG_DIR="$BASE_DIR/config"
readonly LOCK_FILE="$BASE_DIR/.lock"
readonly PID_FILE="$BASE_DIR/.pid"

TEMP_DIR=""
readonly CONFIG_FILE="$CONFIG_DIR/settings.conf"
readonly LOG_FILE="$LOG_DIR/terminal-setup.log"

# Flags
DEBUG_MODE=false
VERBOSE_MODE=false

# Sudo refresh PID - tek global yönetim
SUDO_REFRESH_PID=""

# ============================================================================
# DİZİN OLUŞTURMA - HATA KONTROLÜ
# ============================================================================

create_directories() {
    local dirs=("$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR")
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            echo "HATA: $dir oluşturulamadı!" >&2
            return 1
        fi
    done
    return 0
}

if ! create_directories; then
    exit 1
fi

# ============================================================================
# LOCK MEKANİZMASI - TEK INSTANCE
# ============================================================================

acquire_lock() {
    local max_wait=30
    local waited=0
    
    # Eski kilit dosyası kontrolü
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
            echo "HATA: Başka bir instance çalışıyor (PID: $lock_pid)" >&2
            echo "Beklemek için Enter'a basın veya Ctrl+C ile çıkın..." >&2
            
            while [[ $waited -lt $max_wait ]] && kill -0 "$lock_pid" 2>/dev/null; do
                sleep 1
                ((waited++))
            done
            
            if kill -0 "$lock_pid" 2>/dev/null; then
                echo "HATA: Timeout - diğer instance hala çalışıyor" >&2
                return 1
            fi
        fi
        
        # Eski kilit temizle
        rm -f "$LOCK_FILE"
    fi
    
    # Yeni kilit oluştur
    echo $$ > "$LOCK_FILE" || {
        echo "HATA: Lock dosyası oluşturulamadı" >&2
        return 1
    }
    echo $$ > "$PID_FILE"
    
    return 0
}

release_lock() {
    rm -f "$LOCK_FILE" "$PID_FILE" 2>/dev/null || true
}

# ============================================================================
# CLEANUP FONKSİYONU - MERKEZİ YÖNETİM
# ============================================================================

cleanup() {
    local exit_code=$?
    
    # Sudo refresh durdur
    if [[ -n "$SUDO_REFRESH_PID" ]] && kill -0 "$SUDO_REFRESH_PID" 2>/dev/null; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null || true
        wait "$SUDO_REFRESH_PID" 2>/dev/null || true
    fi
    
    # Temp dizini temizle
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR" 2>/dev/null || true
    fi
    
    # Lock serbest bırak
    release_lock
    
    # Exit code koru
    exit $exit_code
}

# Signal handler
handle_signal() {
    local signal=$1
    echo ""
    echo "Signal alındı: $signal"
    echo "Temizleniyor..."
    cleanup
    exit 130
}

# Trap'leri ayarla
trap cleanup EXIT
trap 'handle_signal INT' INT
trap 'handle_signal TERM' TERM
trap 'handle_signal HUP' HUP

# ============================================================================
# MODÜL YÜKLEME - HATA KONTROLÜ
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
        
        if [[ ! -f "$module_path" ]]; then
            echo "HATA: $module bulunamadı!" >&2
            echo "Beklenen: $module_path" >&2
            return 1
        fi
        
        if [[ ! -r "$module_path" ]]; then
            echo "HATA: $module okunamıyor!" >&2
            return 1
        fi
        
        # shellcheck source=/dev/null
        if ! source "$module_path"; then
            echo "HATA: $module yüklenemedi!" >&2
            return 1
        fi
    done
    
    return 0
}

# Modülleri yükle
if ! load_modules; then
    echo "Lütfen tüm dosyaların aynı dizinde olduğundan emin olun." >&2
    exit 1
fi

# ============================================================================
# TAM KURULUM WRAPPER - HATA KONTROLÜ
# ============================================================================

perform_full_install() {
    local theme=$1
    local theme_display=$2
    
    # Input validation
    if [[ -z "$theme" ]] || [[ -z "$theme_display" ]]; then
        log_error "Geçersiz tema parametresi"
        return 1
    fi
    
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
    
    # Kurulum adımları - her adım kontrol ediliyor
    show_section 1 7 "Zsh kuruluyor"
    if ! install_zsh; then
        log_error "Zsh kurulumu başarısız"
        return 1
    fi
    if ! post_installation_verification "zsh"; then
        log_warning "Zsh doğrulaması başarısız - devam ediliyor"
    fi
    
    show_section 2 7 "Oh My Zsh kuruluyor"
    if ! install_oh_my_zsh; then
        log_error "Oh My Zsh kurulumu başarısız"
        return 1
    fi
    if ! post_installation_verification "ohmyzsh"; then
        log_warning "Oh My Zsh doğrulaması başarısız - devam ediliyor"
    fi
    
    show_section 3 7 "Fontlar kuruluyor"
    if install_fonts; then
        post_installation_verification "fonts" || true
    fi
    
    show_section 4 7 "Powerlevel10k kuruluyor"
    if ! install_powerlevel10k; then
        log_error "Powerlevel10k kurulumu başarısız"
        return 1
    fi
    if ! post_installation_verification "powerlevel10k"; then
        log_warning "Powerlevel10k doğrulaması başarısız - devam ediliyor"
    fi
    
    show_section 5 7 "Pluginler kuruluyor"
    if install_plugins; then
        post_installation_verification "plugins" || true
    fi
    
    show_section 6 7 "$theme_display teması uygulanıyor"
    install_theme "$theme" || log_warning "Tema uygulanamadı"
    
    show_section 7 7 "Shell değiştiriliyor"
    if ! change_default_shell; then
        log_warning "Shell değiştirilemedi"
    fi
    
    # Bash aliases migrasyonu
    echo
    echo -e "${CYAN}┌──── BASH ALIASES KONTROLÜ ────┐${NC}"
    migrate_bash_aliases || true
    
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
# TEMA KURULUM WRAPPER - VALİDASYON
# ============================================================================

install_theme_wrapper() {
    local theme=$1
    
    # Validation
    if [[ -z "$theme" ]]; then
        log_error "Tema parametresi boş"
        return 1
    fi
    
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
            log_error "Geçersiz tema seçimi: $theme"
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
    
    # Input validation
    if [[ ! "$theme_choice" =~ ^[0-7]$ ]]; then
        log_error "Geçersiz seçim: $theme_choice"
        return 1
    fi
    
    if [[ "$theme_choice" == "0" ]]; then
        return 0
    fi
    
    echo
    log_info "Tema değiştiriliyor..."
    
    if install_theme_wrapper "$theme_choice"; then
        log_success "Tema başarıyla değiştirildi!"
        
        if [[ "$SHELL" == *"zsh"* ]]; then
            echo
            echo -e "${YELLOW}Değişiklikleri görmek için terminali yenileyin:${NC} ${CYAN}source ~/.zshrc${NC}"
        fi
    else
        log_error "Tema değiştirme başarısız"
        return 1
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
    return 0
}

# ============================================================================
# TEŞHİS YÖNETİMİ
# ============================================================================

manage_diagnostics() {
    troubleshooting_wizard
}

# ============================================================================
# AYARLAR YÖNETİMİ - VALİDASYON
# ============================================================================

manage_settings() {
    while true; do
        show_settings_menu
        read -r setting_choice
        
        # Input validation
        if [[ ! "$setting_choice" =~ ^[0-5]$ ]]; then
            log_error "Geçersiz seçim"
            sleep 1
            continue
        fi
        
        case $setting_choice in
            1)
                echo
                show_theme_menu
                read -r theme_num
                
                if [[ "$theme_num" =~ ^[1-7]$ ]]; then
                    local theme_names=("dracula" "nord" "gruvbox" "tokyo-night" "catppuccin" "one-dark" "solarized")
                    DEFAULT_THEME="${theme_names[$((theme_num-1))]}"
                    save_config
                    log_success "Varsayılan tema ayarlandı: $DEFAULT_THEME"
                else
                    log_error "Geçersiz tema numarası"
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
                
                if [[ "$new_count" =~ ^[0-9]+$ ]] && [[ $new_count -ge 1 && $new_count -le 20 ]]; then
                    BACKUP_COUNT=$new_count
                    save_config
                    log_success "Yedek sayısı ayarlandı: $BACKUP_COUNT"
                else
                    log_error "Geçersiz sayı (1-20 arası olmalı)"
                fi
                sleep 2
                ;;
            4)
                echo
                check_for_updates
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                echo -n "Ayarları sıfırlamak istediğinizden emin misiniz? (evet/hayır): "
                read -r confirm
                
                if [[ "$confirm" == "evet" ]]; then
                    rm -f "$CONFIG_FILE"
                    log_success "Ayarlar sıfırlandı"
                else
                    log_info "İptal edildi"
                fi
                sleep 2
                ;;
            0)
                break
                ;;
        esac
    done
}

# ============================================================================
# KOMUT SATIRI ARGÜMANLARI - VALİDASYON
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
                exit $?
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
                echo "HATA: Bilinmeyen parametre: $1" >&2
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
    echo "HATA: Bu scripti root olarak çalıştırmayın!" >&2
    exit 1
fi

# ============================================================================
# BAŞLATMA
# ============================================================================

# Lock al
if ! acquire_lock; then
    exit 1
fi

# Güvenli temp directory oluştur
TEMP_DIR=$(mktemp -d -t terminal-setup.XXXXXXXXXX) || {
    echo "HATA: Geçici dizin oluşturulamadı!" >&2
    exit 1
}

# Argümanları parse et
parse_arguments "$@"

# Config yükle
load_config

# Otomatik güncelleme kontrolü
if [[ "${AUTO_UPDATE:-false}" == "true" ]]; then
    check_for_updates --silent || true
fi

# ============================================================================
# ANA PROGRAM DÖNGÜSÜ - VALİDASYON
# ============================================================================

# İLK AÇILIŞ
show_animated_banner
sleep 1

while true; do
    show_banner
    show_menu
    read -r choice
    
    # Input validation
    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        log_error "Geçersiz seçim: sayı giriniz"
        sleep 2
        continue
    fi
    
    if [[ $choice -lt 0 || $choice -gt 15 ]]; then
        log_error "Geçersiz seçim: 0-15 arası olmalı"
        sleep 2
        continue
    fi
    
    case $choice in
        1)
            perform_full_install "dracula" "Dracula" || {
                read -p "Devam etmek için Enter'a basın..."
            }
            ;;
        2)
            perform_full_install "nord" "Nord" || {
                read -p "Devam etmek için Enter'a basın..."
            }
            ;;
        3)
            perform_full_install "gruvbox" "Gruvbox" || {
                read -p "Devam etmek için Enter'a basın..."
            }
            ;;
        4)
            perform_full_install "tokyo-night" "Tokyo Night" || {
                read -p "Devam etmek için Enter'a basın..."
            }
            ;;
        5)
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            if ! setup_sudo; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup || true
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}ZSH + OH MY ZSH KURULUMU${NC}             ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            
            show_section 1 3 "Zsh kuruluyor"
            if install_zsh; then
                post_installation_verification "zsh" || true
            fi
            
            show_section 2 3 "Oh My Zsh kuruluyor"
            if install_oh_my_zsh; then
                post_installation_verification "ohmyzsh" || true
            fi
            
            show_section 3 3 "Shell değiştiriliyor"
            change_default_shell || true
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
            show_contextual_help "post_zsh"
            
            if show_switch_shell_prompt; then
                exec zsh
            else
                read -p "Devam etmek için Enter'a basın..."
            fi
            ;;
        6)
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup || true
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}POWERLEVEL10K KURULUMU${NC}               ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            
            show_section 1 2 "Fontlar kuruluyor"
            if install_fonts; then
                post_installation_verification "fonts" || true
            fi
            
            show_section 2 2 "Powerlevel10k kuruluyor"
            if install_powerlevel10k; then
                post_installation_verification "powerlevel10k" || true
            fi
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
            if [[ "$SHELL" == *"zsh"* ]]; then
                echo
                echo -e "${YELLOW}Değişiklikleri uygulamak için:${NC} ${CYAN}source ~/.zshrc${NC}"
            fi
            read -p "Devam etmek için Enter'a basın..."
            ;;
        7)
            change_theme_only || true
            ;;
        8)
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup || true
            
            clear
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}PLUGİN KURULUMU${NC}                      ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
            echo
            
            if install_plugins; then
                post_installation_verification "plugins" || true
            fi
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
            if [[ "$SHELL" == *"zsh"* ]]; then
                echo
                echo -e "${YELLOW}Değişiklikleri uygulamak için:${NC} ${CYAN}source ~/.zshrc${NC}"
            fi
            read -p "Devam etmek için Enter'a basın..."
            ;;
        9)
            if show_terminal_tools_info; then
                if ! check_dependencies; then
                    read -p "Devam etmek için Enter'a basın..."
                    continue
                fi
                
                if ! setup_sudo; then
                    read -p "Devam etmek için Enter'a basın..."
                    continue
                fi
                
                clear
                echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║   ${BOLD}TERMİNAL ARAÇLARI KURULUMU${NC}          ${CYAN}║${NC}"
                echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
                
                show_section 1 4 "FZF kuruluyor"
                install_fzf || true
                
                show_section 2 4 "Zoxide kuruluyor"
                install_zoxide || true
                
                show_section 3 4 "Exa kuruluyor"
                install_exa || true
                
                show_section 4 4 "Bat kuruluyor"
                install_bat || true
                
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
            
            # Validation
            if [[ ! "$tmux_theme_choice" =~ ^[1-7]$ ]]; then
                log_error "Geçersiz seçim"
                sleep 2
                continue
            fi
            
            local tmux_theme="dracula"
            case $tmux_theme_choice in
                1) tmux_theme="dracula" ;;
                2) tmux_theme="nord" ;;
                3) tmux_theme="gruvbox" ;;
                4) tmux_theme="tokyo-night" ;;
                5) tmux_theme="catppuccin" ;;
                6) tmux_theme="one-dark" ;;
                7) tmux_theme="solarized" ;;
            esac
            
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            if ! setup_sudo; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            if install_tmux_with_theme "$tmux_theme"; then
                log_success "Tamamlandı"
            fi
            read -p "Devam etmek için Enter'a basın..."
            ;;
        11)
            show_banner
            system_health_check || true
            read -p "Devam etmek için Enter'a basın..."
            ;;
        12)
            manage_diagnostics || true
            ;;
        13)
            show_backups || true
            ;;
        14)
            uninstall_all || true
            read -p "Devam etmek için Enter'a basın..."
            ;;
        15)
            manage_settings || true
            ;;
        0)
            log_info "Çıkılıyor..."
            exit 0
            ;;
    esac
done