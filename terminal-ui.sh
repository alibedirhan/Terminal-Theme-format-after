#!/bin/bash

# ============================================================================
# Terminal Setup - UI/Görsel Katman
# v3.1.0 - UI Module
# ============================================================================

# ============================================================================
# RENKLER
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ============================================================================
# BANNER
# ============================================================================

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

# ============================================================================
# MENÜLER
# ============================================================================

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
    echo " 12) Otomatik Teşhis (Sorun varsa bul ve çöz)"
    echo " 13) Yedekleri Göster"
    echo " 14) Tümünü Kaldır"
    echo " 15) Ayarlar"
    echo "  0) Çıkış"
    echo
    echo -n "Seçiminiz (0-15): "
}

show_diagnostic_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        OTOMATİK TEŞHİS MENÜSÜ                ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo
    echo "Hangi sorunu kontrol etmek istiyorsunuz?"
    echo
    echo "  1) Shell sorunları (Bash yerine Zsh gelmiyorsa)"
    echo "  2) İnternet bağlantısı"
    echo "  3) Yetki sorunları (sudo)"
    echo "  4) Font sorunları"
    echo "  5) Tema sorunları"
    echo "  6) Paket eksiklikleri"
    echo "  7) Tümünü kontrol et"
    echo "  0) Geri"
    echo
    echo -n "Seçiminiz (0-7): "
}

show_theme_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           TEMA SEÇİMİ                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
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

show_settings_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              AYARLAR                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
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

show_terminal_tools_info() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           MODERN TERMİNAL ARAÇLARI                   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${YELLOW}1) FZF - Fuzzy Finder${NC}"
    echo "   Dosya, komut, history'de hızlı arama"
    echo
    echo -e "${YELLOW}2) Zoxide - Akıllı cd${NC}"
    echo "   En çok kullandığınız dizinlere hızlıca atlama"
    echo
    echo -e "${YELLOW}3) Exa - Modern ls${NC}"
    echo "   Renkli ve icon'lu dosya listeleme"
    echo
    echo -e "${YELLOW}4) Bat - cat with syntax${NC}"
    echo "   Syntax highlighting ile dosya görüntüleme"
    echo
    
    echo -e "${CYAN}Tümünü kurmak ister misiniz? (e/h): ${NC}"
    read -r install_all
    
    [[ "$install_all" == "e" ]]
}

# ============================================================================
# PROGRESS BAR
# ============================================================================

show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    # Önceki satırı temizle
    printf "\r\033[K"
    
    # Progress bar'ı çiz
    printf "${CYAN}%s${NC} [" "$task"
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] %3d%%" "$percentage"
    
    # Son adımda yeni satır ekle
    if [ "$current" -eq "$total" ]; then
        printf " ${GREEN}✓${NC}\n"
    fi
}

show_advanced_progress() {
    local current=$1
    local total=$2
    local task=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    # Renk seçimi (ilerlemeye göre)
    local bar_color
    if [ $percentage -lt 33 ]; then
        bar_color=$RED
    elif [ $percentage -lt 66 ]; then
        bar_color=$YELLOW
    else
        bar_color=$GREEN
    fi
    
    # Önceki satırı temizle
    printf "\r\033[K"
    
    # Progress bar çiz
    printf "${CYAN}[%2d/%2d]${NC} " "$current" "$total"
    printf "["
    printf "${bar_color}%${completed}s${NC}" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] ${bar_color}%3d%%${NC} - %s" "$percentage" "$task"
    
    # Son adımda yeni satır
    if [ "$current" -eq "$total" ]; then
        printf " ${GREEN}✓${NC}\n"
    fi
}

# ============================================================================
# SPINNER
# ============================================================================

# Spinner karakterleri
SPINNER_CHARS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
SPINNER_PID=""

start_spinner() {
    local message="${1:-İşlem devam ediyor}"
    
    (
        local i=0
        while true; do
            printf "\r${CYAN}${SPINNER_CHARS[$i]}${NC} $message"
            i=$(( (i + 1) % ${#SPINNER_CHARS[@]} ))
            sleep 0.1
        done
    ) &
    
    SPINNER_PID=$!
    log_debug "Spinner başlatıldı (PID: $SPINNER_PID)"
}

stop_spinner() {
    local status="${1:-}"
    
    if [[ -n "$SPINNER_PID" ]] && kill -0 "$SPINNER_PID" 2>/dev/null; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        
        # Satırı temizle
        printf "\r\033[K"
        
        # Durum göster
        if [[ "$status" == "success" ]]; then
            echo -e "${GREEN}✓${NC} Tamamlandı"
        elif [[ "$status" == "error" ]]; then
            echo -e "${RED}✗${NC} Başarısız"
        elif [[ "$status" == "warning" ]]; then
            echo -e "${YELLOW}⚠ ${NC} Uyarı"
        fi
        
        SPINNER_PID=""
        log_debug "Spinner durduruldu"
    fi
}

# ============================================================================
# TAMAMLANMA MESAJI
# ============================================================================

show_completion_message() {
    echo
    echo -e "${GREEN}══════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Kurulum tamamlandı!${NC}"
    echo -e "${GREEN}══════════════════════════════════${NC}"
    echo
    echo -e "${CYAN}Yedekler: $BACKUP_DIR${NC}"
    echo -e "${CYAN}Log dosyası: $LOG_FILE${NC}"
}

show_switch_shell_prompt() {
    echo
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}DEĞİŞİKLİKLERİ GÖRMEK İÇİN ZSH'E GEÇİN${NC}"
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo
    echo -e "${GREEN}✓ Zsh sistem shell'i olarak ayarlandı${NC}"
    echo -e "${GREEN}✓ GNOME Terminal login shell moduna geçirildi${NC}"
    echo
    echo "Seçenekler:"
    echo -e "  ${CYAN}1)${NC} Şimdi Zsh'e geç (Powerlevel10k wizard başlar)"
    echo -e "  ${CYAN}2)${NC} Ana menüye dön (yeni terminaller otomatik Zsh açacak)"
    echo
    echo -e "${YELLOW}Not:${NC} Yeni terminal pencerelerinde Zsh otomatik başlayacak"
    echo
    echo -n "Seçiminiz (1/2) [1]: "
    read -r switch_choice
    
    if [[ -z "$switch_choice" ]] || [[ "$switch_choice" == "1" ]]; then
        echo
        echo -e "${GREEN}Zsh'e geçiliyor...${NC}"
        sleep 1
        return 0
    else
        echo
        echo -e "${GREEN}Ana menüye dönülüyor...${NC}"
        echo -e "${YELLOW}İpucu:${NC} Yeni terminal penceresi açın veya 'exec zsh' yazın"
        echo
        sleep 2
        return 1
    fi
}

# ============================================================================
# YARDIM MESAJI
# ============================================================================

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