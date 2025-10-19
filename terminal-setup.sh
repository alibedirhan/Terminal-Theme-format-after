#!/bin/bash

# ============================================================================
# Terminal Özelleştirme Kurulum Aracı - Ana Script
# v3.2.8 - Modüler Yapı (Enhanced & Reliable)
# ============================================================================
# Dosya Yapısı:
# - terminal-setup.sh      (bu dosya - orchestration)
# - terminal-ui.sh         (görsel arayüz)
# - terminal-themes.sh     (tema tanımları)
# - terminal-core.sh       (kurulum fonksiyonları)
# - terminal-utils.sh      (yardımcı fonksiyonlar)
# - terminal-assistant.sh  (otomatik teşhis ve çözüm)
# ============================================================================

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# DÜZELTME: VERSION dosyasından oku (fallback ile)
if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
    VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')
else
    VERSION="3.2.8"
fi

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

# DÜZELTME: Cleanup flag (double call önleme)
CLEANUP_DONE=false

# Dizinleri oluştur
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$CONFIG_DIR" || {
    echo "ERROR: Required directories could not be created!"
    exit 1
}

# ============================================================================
# MODÜL YÜKLEME (İYİLEŞTİRİLMİŞ)
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
            if ! source "$module_path"; then
                # DÜZELTME: İngilizce hata mesajı (henüz log fonksiyonu yok)
                echo "ERROR: Failed to load module: $module" >&2
                echo "Please ensure all files are in the same directory." >&2
                exit 1
            fi
        else
            echo "ERROR: Module not found: $module" >&2
            echo "Expected location: $module_path" >&2
            echo "Please ensure all files are in the same directory." >&2
            exit 1
        fi
    done
}

# Modülleri yükle
load_modules

# VERSION bilgisini log'a yaz
log_debug "Terminal Setup v$VERSION başlatıldı"
log_debug "Script dizini: $SCRIPT_DIR"

# ============================================================================
# CLEANUP FONKSIYONU (İYİLEŞTİRİLMİŞ)
# ============================================================================

cleanup() {
    # DÜZELTME: Guard condition - sadece bir kez çalışsın
    if [[ "$CLEANUP_DONE" == true ]]; then
        return 0
    fi
    CLEANUP_DONE=true
    
    log_debug "Cleanup başlatıldı"
    
    # Temp directory temizle
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR" 2>/dev/null || true
        log_debug "Temp directory temizlendi: $TEMP_DIR"
    fi
    
    # Sudo refresh process'ini durdur (core modülünden)
    if type cleanup_sudo &>/dev/null; then
        cleanup_sudo
    fi
    
    log_debug "Cleanup tamamlandı"
}

trap cleanup EXIT INT TERM

# ============================================================================
# TAM KURULUM WRAPPER FONKSIYONU
# ============================================================================

perform_full_install() {
    local theme=$1
    local theme_display=$2
    
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${BOLD}${theme_display^^} KURULUMU BAŞLIYOR${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    
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
    install_zsh || return 1
    
    show_section 2 7 "Oh My Zsh kuruluyor"
    install_oh_my_zsh || return 1
    
    show_section 3 7 "Fontlar kuruluyor"
    install_fonts
    
    show_section 4 7 "Powerlevel10k kuruluyor"
    install_powerlevel10k || return 1
    
    show_section 5 7 "Pluginler kuruluyor"
    install_plugins
    
    show_section 6 7 "$theme_display teması uygulanıyor"
    install_theme "$theme"
    
    show_section 7 7 "Shell değiştiriliyor"
    change_default_shell
    
    # Bash aliases migrasyonu
    echo
    echo -e "${CYAN}┌──── BASH ALIASES KONTROLÜ ────┐${NC}"
    migrate_bash_aliases
    
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${GREEN}✓ KURULUM BAŞARIYLA TAMAMLANDI${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo
    echo -e "${DIM}Yedekler: $BACKUP_DIR${NC}"
    echo -e "${DIM}Log dosyası: $LOG_FILE${NC}"
    
    # Otomatik Zsh'e geçiş
    if show_switch_shell_prompt; then
        exec zsh
    fi
    
    return 0
}

# ============================================================================
# TEMA KURULUM WRAPPER (İYİLEŞTİRİLMİŞ)
# ============================================================================

install_theme_wrapper() {
    local theme=$1
    
    # DÜZELTME: Input validation
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
# TEMA DEĞİŞTİRME İŞLEMİ (İYİLEŞTİRİLMİŞ)
# ============================================================================

change_theme_only() {
    show_theme_menu
    read -r theme_choice
    
    # DÜZELTME: Gelişmiş input validation
    if [[ "$theme_choice" == "0" ]]; then
        return 0
    fi
    
    if ! [[ "$theme_choice" =~ ^[1-7]$ ]]; then
        log_error "Geçersiz seçim: $theme_choice (1-7 arası olmalı)"
        sleep 2
        return 1
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
# ARGÜMAN İŞLEME
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --version)
                echo "Terminal Setup v$VERSION"
                exit 0
                ;;
            --debug)
                DEBUG_MODE=true
                log_info "Debug modu aktif"
                shift
                ;;
            --verbose)
                VERBOSE_MODE=true
                log_info "Verbose mod aktif"
                shift
                ;;
            --health)
                show_banner
                system_health_check
                exit 0
                ;;
            --update)
                check_for_updates
                exit 0
                ;;
            *)
                log_error "Bilinmeyen parametre: $1"
                echo "Yardım için: $0 --help"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# SETTINGS YÖNETİMİ
# ============================================================================

manage_settings() {
    while true; do
        show_settings_menu
        read -r settings_choice
        
        case $settings_choice in
            0)
                break
                ;;
            1)
                echo
                echo "Yeni varsayılan tema (dracula/nord/gruvbox/tokyo-night/catppuccin/one-dark/solarized):"
                read -r new_theme
                if [[ " dracula nord gruvbox tokyo-night catppuccin one-dark solarized " =~ " $new_theme " ]]; then
                    DEFAULT_THEME="$new_theme"
                    save_config
                    log_success "Varsayılan tema değiştirildi: $new_theme"
                else
                    log_error "Geçersiz tema!"
                fi
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                if [[ "$AUTO_UPDATE" == "true" ]]; then
                    AUTO_UPDATE="false"
                    log_info "Otomatik güncelleme kapatıldı"
                else
                    AUTO_UPDATE="true"
                    log_info "Otomatik güncelleme açıldı"
                fi
                save_config
                read -p "Devam etmek için Enter'a basın..."
                ;;
            3)
                echo
                echo "Yeni yedek sayısı (1-20):"
                read -r new_count
                if [[ "$new_count" =~ ^[0-9]+$ ]] && [ "$new_count" -ge 1 ] && [ "$new_count" -le 20 ]; then
                    BACKUP_COUNT="$new_count"
                    save_config
                    log_success "Yedek sayısı değiştirildi: $new_count"
                else
                    log_error "Geçersiz sayı! (1-20 arası olmalı)"
                fi
                read -p "Devam etmek için Enter'a basın..."
                ;;
            4)
                check_for_updates
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                echo
                echo -e "${YELLOW}Ayarları sıfırlamak istediğinize emin misiniz? (e/h):${NC}"
                read -r reset_confirm
                if [[ "$reset_confirm" == "e" ]]; then
                    DEFAULT_THEME="dracula"
                    AUTO_UPDATE="false"
                    BACKUP_COUNT="5"
                    save_config
                    log_success "Ayarlar sıfırlandı"
                fi
                read -p "Devam etmek için Enter'a basın..."
                ;;
            *)
                log_error "Geçersiz seçim"
                sleep 2
                ;;
        esac
    done
}

# ============================================================================
# TEŞHİS YÖNETİMİ
# ============================================================================

manage_diagnostics() {
    while true; do
        show_diagnostic_menu
        read -r diag_choice
        
        case $diag_choice in
            0)
                break
                ;;
            1)
                diagnose_and_fix "zsh_not_default"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                diagnose_and_fix "internet_connection"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            3)
                diagnose_and_fix "permission_denied"
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
                echo "Hangi paket eksik? (git/curl/wget/zsh):"
                read -r missing_pkg
                diagnose_and_fix "package_missing" "$missing_pkg"
                read -p "Devam etmek için Enter'a basın..."
                ;;
            7)
                show_banner
                system_health_check
                read -p "Devam etmek için Enter'a basın..."
                ;;
            8)
                clear
                diagnose_instant_prompt_issues
                read -p "Devam etmek için Enter'a basın..."
                ;;
            *)
                log_error "Geçersiz seçim"
                sleep 2
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

# Config'i validate et
validate_config || log_warning "Config validation başarısız, varsayılanlar kullanılıyor"

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
    
    # DÜZELTME: Input validation
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        log_error "Geçersiz girdi: sadece sayı girebilirsiniz"
        sleep 2
        continue
    fi
    
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
            # Bağımlılık ve yetki kontrolü
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            if ! setup_sudo; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup
            
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}ZSH + OH MY ZSH KURULUMU${NC}             ${CYAN}║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
            
            show_section 1 3 "Zsh kuruluyor"
            install_zsh
            
            show_section 2 3 "Oh My Zsh kuruluyor"
            install_oh_my_zsh
            
            show_section 3 3 "Shell değiştiriliyor"
            change_default_shell
            
            echo
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            
            # Zsh'e geçiş öner
            if show_switch_shell_prompt; then
                exec zsh
            else
                read -p "Devam etmek için Enter'a basın..."
            fi
            ;;
        6)
            # Bağımlılık kontrolü
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup
            
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}POWERLEVEL10K KURULUMU${NC}               ${CYAN}║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
            
            show_section 1 2 "Fontlar kuruluyor"
            install_fonts
            
            show_section 2 2 "Powerlevel10k kuruluyor"
            install_powerlevel10k
            
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
            # Bağımlılık kontrolü
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            create_backup
            
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║   ${BOLD}PLUGİN KURULUMU${NC}                      ${CYAN}║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
            echo
            
            install_plugins
            
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
            # ═══════════════════════════════════════════════════════════════
            # YENİ TERMINAL ARAÇLARI ALT MENÜSÜ
            # ═══════════════════════════════════════════════════════════════
            while true; do
                show_tools_submenu
                read -r tools_choice
                
                # Input validation
                if ! [[ "$tools_choice" =~ ^[0-9]+$ ]]; then
                    log_error "Geçersiz girdi: sadece sayı girebilirsiniz"
                    sleep 2
                    continue
                fi
                
                # Çıkış kontrolü
                if [[ "$tools_choice" == "0" ]]; then
                    break
                fi
                
                # Bağımlılık ve sudo kontrolü (kurulum yapılacaksa)
                if [[ "$tools_choice" != "0" ]]; then
                    if ! check_dependencies; then
                        read -p "Devam etmek için Enter'a basın..."
                        continue
                    fi
                    
                    if ! setup_sudo; then
                        read -p "Devam etmek için Enter'a basın..."
                        continue
                    fi
                fi
                
                clear
                echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║   ${BOLD}TERMİNAL ARAÇLARI KURULUMU${NC}          ${CYAN}║${NC}"
                echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
                echo
                
                case $tools_choice in
                    1)
                        # HEPSİNİ KUR - 14 Araç
                        echo -e "${YELLOW}${BOLD}14 araç kuruluyor... Bu biraz zaman alabilir.${NC}"
                        echo
                        install_all_tools_complete
                        echo
                        log_success "Tam paket kurulumu tamamlandı!"
                        ;;
                    2)
                        # Temel paket
                        show_section 1 4 "FZF kuruluyor"
                        install_fzf
                        
                        show_section 2 4 "Zoxide kuruluyor"
                        install_zoxide
                        
                        show_section 3 4 "Exa kuruluyor"
                        install_exa
                        
                        show_section 4 4 "Bat kuruluyor"
                        install_bat
                        
                        echo
                        log_success "Temel araçlar kuruldu"
                        ;;
                    3)
                        # Arama araçları
                        install_search_tools
                        echo
                        log_success "Arama araçları kuruldu"
                        ;;
                    4)
                        # Git araçları
                        install_git_tools
                        echo
                        log_success "Git araçları kuruldu"
                        ;;
                    5)
                        # Sistem araçları
                        install_system_tools
                        echo
                        log_success "Sistem araçları kuruldu"
                        ;;
                    6)
                        # Ekstra araçlar
                        install_extra_tools
                        echo
                        log_success "Ekstra araçlar kuruldu"
                        ;;
                    7)
                        install_ripgrep
                        echo
                        log_success "Ripgrep kuruldu"
                        ;;
                    8)
                        install_fd
                        echo
                        log_success "Fd kuruldu"
                        ;;
                    9)
                        install_delta
                        echo
                        log_success "Delta kuruldu"
                        ;;
                    10)
                        install_lazygit
                        echo
                        log_success "Lazygit kuruldu"
                        ;;
                    11)
                        install_tldr
                        echo
                        log_success "TLDR kuruldu"
                        ;;
                    12)
                        install_btop
                        echo
                        log_success "Btop kuruldu"
                        ;;
                    13)
                        install_dust
                        echo
                        log_success "Dust kuruldu"
                        ;;
                    14)
                        install_duf
                        echo
                        log_success "Duf kuruldu"
                        ;;
                    15)
                        install_procs
                        echo
                        log_success "Procs kuruldu"
                        ;;
                    16)
                        install_atuin
                        echo
                        log_success "Atuin kuruldu"
                        ;;
                    *)
                        log_error "Geçersiz seçim: $tools_choice"
                        sleep 2
                        continue
                        ;;
                esac
                
                # Zsh aktifse source et uyarısı
                if [[ "$SHELL" == *"zsh"* ]]; then
                    echo
                    echo -e "${YELLOW}Değişiklikleri uygulamak için:${NC} ${CYAN}source ~/.zshrc${NC}"
                fi
                
                read -p "Devam etmek için Enter'a basın..."
            done
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
            
            # DÜZELTME: Input validation
            local tmux_theme="dracula"
            if [[ "$tmux_theme_choice" =~ ^[1-7]$ ]]; then
                case $tmux_theme_choice in
                    1) tmux_theme="dracula" ;;
                    2) tmux_theme="nord" ;;
                    3) tmux_theme="gruvbox" ;;
                    4) tmux_theme="tokyo-night" ;;
                    5) tmux_theme="catppuccin" ;;
                    6) tmux_theme="one-dark" ;;
                    7) tmux_theme="solarized" ;;
                esac
            else
                log_warning "Geçersiz seçim, Dracula kullanılıyor"
            fi
            
            if ! check_dependencies; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
            if ! setup_sudo; then
                read -p "Devam etmek için Enter'a basın..."
                continue
            fi
            
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
            log_error "Geçersiz seçim: $choice"
            sleep 2
            ;;
    esac
done
