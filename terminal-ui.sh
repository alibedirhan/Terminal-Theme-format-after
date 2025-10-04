#!/bin/bash

# ============================================================================
# Terminal Setup - UI/Görsel Katman
# v3.2.0 - UI Module (Assistant entegreli)
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
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ============================================================================
# ANİMASYONLU BANNER
# ============================================================================

show_animated_banner() {
    clear
    
    # Frame 1
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ████████╗███████╗██╗                                         ║
║   ╚══██╔══╝██╔════╝██║                                         ║
║      ██║   █████╗  ██║                                         ║
║      ██║   ██╔══╝  ██║                                         ║
║      ╚██████╔╝██║  ██║███████╗                                    ║
║       ╚═════╝ ╚═╝  ╚═╝╚══════╝                                    ║
║                                                               ║
║                Terminal Customization Suite v3.2.0            ║
║                    github.com/alibedirhan                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.3
    
    # Frame 2 - Glow effect
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ████████╗███████╗██╗     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓         ║
║   ╚══██╔══╝██╔════╝██║     ▓ Zsh • Oh My Zsh • P10k ▓         ║
║      ██║   █████╗  ██║     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓         ║
║      ██║   ██╔══╝  ██║                                         ║
║      ╚██████╔╝██║  ██║███████╗                                    ║
║       ╚═════╝ ╚═╝  ╚═╝╚══════╝                                    ║
║                                                               ║
║                Terminal Customization Suite v3.2.0            ║
║                    github.com/alibedirhan                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.3
    
    # Frame 3 - Final
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ████████╗███████╗██╗                                         ║
║   ╚══██╔══╝██╔════╝██║     Terminal Customization Suite       ║
║      ██║   █████╗  ██║     Zsh • Oh My Zsh • Powerlevel10k    ║
║      ██║   ██╔══╝  ██║     7 Themes • Multi-Terminal Support  ║
║      ╚██████╔╝██║  ██║███████╗                                    ║
║       ╚═════╝ ╚═╝  ╚═╝╚══════╝                                    ║
║                                                               ║
║                        Version 3.2.0                          ║
║                    github.com/alibedirhan                     ║
║                  🤖 Akıllı Asistan Destekli                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.2
}

# ============================================================================
# STATİK BANNER (Hızlı Geçişler İçin)
# ============================================================================

show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ████████╗███████╗██╗                                         ║
║   ╚══██╔══╝██╔════╝██║     Terminal Customization Suite       ║
║      ██║   █████╗  ██║     Zsh • Oh My Zsh • Powerlevel10k    ║
║      ██║   ██╔══╝  ██║     7 Themes • Multi-Terminal Support  ║
║      ╚██████╔╝██║  ██║███████╗                                    ║
║       ╚═════╝ ╚═╝  ╚═╝╚══════╝                                    ║
║                                                               ║
║                        Version 3.2.0                          ║
║                    github.com/alibedirhan                     ║
║                  🤖 Akıllı Asistan Destekli                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ============================================================================
# DURUM ÇUBUĞU (STATUS BAR)
# ============================================================================

show_status_bar() {
    local zsh_status="${RED}✗${NC}"
    local omz_status="${RED}✗${NC}"
    local p10k_status="${RED}✗${NC}"
    local internet_status="${RED}✗${NC}"
    
    # Zsh kontrolü
    if command -v zsh &>/dev/null; then
        if [[ "$SHELL" == *"zsh"* ]]; then
            zsh_status="${GREEN}✓${NC}"
        else
            zsh_status="${YELLOW}~${NC}"  # Kurulu ama aktif değil
        fi
    fi
    
    # Oh My Zsh kontrolü
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        omz_status="${GREEN}✓${NC}"
    fi
    
    # Powerlevel10k kontrolü
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        p10k_status="${GREEN}✓${NC}"
    fi
    
    # İnternet kontrolü (hızlı, timeout 2 saniye)
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        internet_status="${GREEN}✓${NC}"
    fi
    
    echo -e "${CYAN}┌──────────────────────── SİSTEM DURUMU ────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC} Zsh: $zsh_status ${DIM}|${NC} Oh My Zsh: $omz_status ${DIM}|${NC} P10k: $p10k_status ${DIM}|${NC} İnternet: $internet_status     ${CYAN}│${NC}"
    echo -e "${CYAN}└───────────────────────────────────────────────────────────────┘${NC}"
}

# ============================================================================
# SMART RECOMMENDATİONS (AKILLI ÖNERİLER)
# ============================================================================

show_smart_recommendations() {
    local has_recommendations=false
    
    echo -e "${YELLOW}┌──────────────────── AKILLI ÖNERİLER ─────────────────────┐${NC}"
    
    # Zsh kurulu değilse
    if ! command -v zsh &>/dev/null; then
        echo -e "${WHITE}│${NC} ${CYAN}→${NC} Zsh kurulu değil. Başlamak için ${BOLD}Seçenek 5${NC} önerilir       ${YELLOW}│${NC}"
        has_recommendations=true
    # Zsh kurulu ama aktif değilse
    elif [[ "$SHELL" != *"zsh"* ]]; then
        echo -e "${WHITE}│${NC} ${CYAN}→${NC} Zsh kurulu ama aktif değil. ${BOLD}Seçenek 5${NC} ile aktifleştirin ${YELLOW}│${NC}"
        has_recommendations=true
    # Oh My Zsh yoksa
    elif [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${WHITE}│${NC} ${CYAN}→${NC} Oh My Zsh kurulu değil. ${BOLD}Seçenek 5${NC} ile kurun          ${YELLOW}│${NC}"
        has_recommendations=true
    # Powerlevel10k yoksa
    elif [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        echo -e "${WHITE}│${NC} ${CYAN}→${NC} Tema kurulu değil. ${BOLD}Seçenek 6${NC} veya ${BOLD}1-4${NC} arası tam kurulum ${YELLOW}│${NC}"
        has_recommendations=true
    # Herşey tamam
    else
        echo -e "${WHITE}│${NC} ${GREEN}✓${NC} Sistem hazır! ${BOLD}Seçenek 7${NC} ile tema değiştirebilirsiniz   ${YELLOW}│${NC}"
        has_recommendations=true
    fi
    
    # İnternet yoksa uyar
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo -e "${WHITE}│${NC} ${RED}⚠  ${NC}  İnternet bağlantısı yok. Kurulum için gerekli           ${YELLOW}│${NC}"
        has_recommendations=true
    fi
    
    echo -e "${YELLOW}└───────────────────────────────────────────────────────────┘${NC}"
    
    return 0
}

# ============================================================================
# RENK ÖNİZLEMESİ FONKSİYONLARI
# ============================================================================

# Renk kutuçuğu göster (ANSI true color kullanarak)
show_color_box() {
    local r=$1
    local g=$2
    local b=$3
    echo -ne "\033[48;2;${r};${g};${b}m  \033[0m"
}

# Tema renk paletini göster
show_theme_colors() {
    local theme=$1
    
    case $theme in
        dracula)
            echo -n "  "
            show_color_box 40 42 54      # background
            show_color_box 248 248 242   # foreground
            show_color_box 255 85 85     # red
            show_color_box 80 250 123    # green
            show_color_box 241 250 140   # yellow
            show_color_box 189 147 249   # blue
            show_color_box 255 121 198   # magenta
            show_color_box 139 233 253   # cyan
            ;;
        nord)
            echo -n "  "
            show_color_box 46 52 64      # background
            show_color_box 216 222 233   # foreground
            show_color_box 191 97 106    # red
            show_color_box 163 190 140   # green
            show_color_box 235 203 139   # yellow
            show_color_box 129 161 193   # blue
            show_color_box 180 142 173   # magenta
            show_color_box 136 192 208   # cyan
            ;;
        gruvbox)
            echo -n "  "
            show_color_box 40 40 40      # background
            show_color_box 235 219 178   # foreground
            show_color_box 204 36 29     # red
            show_color_box 152 151 26    # green
            show_color_box 215 153 33    # yellow
            show_color_box 69 133 136    # blue
            show_color_box 177 98 134    # magenta
            show_color_box 104 157 106   # cyan
            ;;
        tokyo-night)
            echo -n "  "
            show_color_box 26 27 38      # background
            show_color_box 192 202 245   # foreground
            show_color_box 247 118 142   # red
            show_color_box 158 206 106   # green
            show_color_box 224 175 104   # yellow
            show_color_box 122 162 247   # blue
            show_color_box 187 154 247   # magenta
            show_color_box 125 207 255   # cyan
            ;;
        catppuccin)
            echo -n "  "
            show_color_box 30 30 46      # background
            show_color_box 205 214 244   # foreground
            show_color_box 243 139 168   # red
            show_color_box 166 227 161   # green
            show_color_box 249 226 175   # yellow
            show_color_box 137 180 250   # blue
            show_color_box 245 194 231   # magenta
            show_color_box 148 226 213   # cyan
            ;;
        one-dark)
            echo -n "  "
            show_color_box 40 44 52      # background
            show_color_box 171 178 191   # foreground
            show_color_box 224 108 117   # red
            show_color_box 152 195 121   # green
            show_color_box 229 192 123   # yellow
            show_color_box 97 175 239    # blue
            show_color_box 198 120 221   # magenta
            show_color_box 86 182 194    # cyan
            ;;
        solarized)
            echo -n "  "
            show_color_box 0 43 54       # background
            show_color_box 131 148 150   # foreground
            show_color_box 220 50 47     # red
            show_color_box 133 153 0     # green
            show_color_box 181 137 0     # yellow
            show_color_box 38 139 210    # blue
            show_color_box 211 54 130    # magenta
            show_color_box 42 161 152    # cyan
            ;;
    esac
}

# ============================================================================
# MODERN BOX STYLE MENÜ
# ============================================================================

show_menu() {
    # Durum çubuğunu göster
    show_status_bar
    echo
    
    # Akıllı önerileri göster
    show_smart_recommendations
    echo
    
    echo -e "${YELLOW}┌─────────────────────── TAM KURULUM ───────────────────────┐${NC}"
    echo -e "${WHITE}│  1 │${NC} 🎨 ${MAGENTA}Dracula${NC}       ${CYAN}│${NC} Mor/Pembe - Yüksek Kontrast       ${YELLOW}│${NC}"
    echo -e "${WHITE}│  2 │${NC} 🌊 ${BLUE}Nord${NC}          ${CYAN}│${NC} Mavi/Gri - Göze Yumuşak           ${YELLOW}│${NC}"
    echo -e "${WHITE}│  3 │${NC} 🍂 ${YELLOW}Gruvbox${NC}       ${CYAN}│${NC} Retro Sıcak Tonlar                ${YELLOW}│${NC}"
    echo -e "${WHITE}│  4 │${NC} 🌃 ${BLUE}Tokyo Night${NC}   ${CYAN}│${NC} Modern Mavi/Mor                   ${YELLOW}│${NC}"
    echo -e "${YELLOW}└───────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${YELLOW}┌───────────────────── MODÜLER KURULUM ─────────────────────┐${NC}"
    echo -e "${WHITE}│  5 │${NC} ⚙️  ${GREEN}Zsh + Oh My Zsh${NC}                                   ${YELLOW}│${NC}"
    echo -e "${WHITE}│  6 │${NC} ✨ ${GREEN}Powerlevel10k Teması${NC}                              ${YELLOW}│${NC}"
    echo -e "${WHITE}│  7 │${NC} 🎨 ${GREEN}Renk Teması Değiştir${NC}                              ${YELLOW}│${NC}"
    echo -e "${WHITE}│  8 │${NC} 🔌 ${GREEN}Pluginler${NC}                                          ${YELLOW}│${NC}"
    echo -e "${WHITE}│  9 │${NC} 🛠️  ${GREEN}Terminal Araçları (FZF, Zoxide, Exa, Bat)${NC}       ${YELLOW}│${NC}"
    echo -e "${WHITE}│ 10 │${NC} 📺 ${GREEN}Tmux Kurulumu${NC}                                      ${YELLOW}│${NC}"
    echo -e "${YELLOW}└───────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${YELLOW}┌───────────────────────── YÖNETİM ─────────────────────────┐${NC}"
    echo -e "${WHITE}│ 11 │${NC} 🏥 ${CYAN}Sistem Sağlık Kontrolü${NC}                            ${YELLOW}│${NC}"
    echo -e "${WHITE}│ 12 │${NC} 🤖 ${CYAN}Akıllı Sorun Giderme Asistanı${NC}                     ${YELLOW}│${NC}"
    echo -e "${WHITE}│ 13 │${NC} 💾 ${CYAN}Yedekleri Göster${NC}                                   ${YELLOW}│${NC}"
    echo -e "${WHITE}│ 14 │${NC} 🗑️  ${RED}Tümünü Kaldır${NC}                                     ${YELLOW}│${NC}"
    echo -e "${WHITE}│ 15 │${NC} ⚙️  ${CYAN}Ayarlar${NC}                                           ${YELLOW}│${NC}"
    echo -e "${WHITE}│  0 │${NC} 🚪 ${WHITE}Çıkış${NC}                                              ${YELLOW}│${NC}"
    echo -e "${YELLOW}└───────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -ne "${BOLD}${CYAN}Seçiminiz (0-15): ${NC}"
}

# ============================================================================
# TEMA SEÇİM MENÜSÜ (RENK ÖNİZLEMELİ)
# ============================================================================

show_theme_menu() {
    clear
    show_banner
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           ${BOLD}TEMA SEÇİMİ${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    local terminal_type
    terminal_type=$(detect_terminal)
    echo -e "${YELLOW}Tespit edilen terminal: ${terminal_type}${NC}"
    echo
    
    echo -ne "${WHITE}1)${NC} ${MAGENTA}Dracula${NC}        - Mor/Pembe tonları, yüksek kontrast"
    show_theme_colors "dracula"
    echo
    
    echo -ne "${WHITE}2)${NC} ${BLUE}Nord${NC}           - Mavi/Gri tonları, göze yumuşak"
    show_theme_colors "nord"
    echo
    
    echo -ne "${WHITE}3)${NC} ${YELLOW}Gruvbox Dark${NC}   - Retro, sıcak tonlar"
    show_theme_colors "gruvbox"
    echo
    
    echo -ne "${WHITE}4)${NC} ${BLUE}Tokyo Night${NC}    - Modern, mavi/mor tonlar"
    show_theme_colors "tokyo-night"
    echo
    
    echo -ne "${WHITE}5)${NC} ${MAGENTA}Catppuccin${NC}     - Pastel renkler"
    show_theme_colors "catppuccin"
    echo
    
    echo -ne "${WHITE}6)${NC} ${CYAN}One Dark${NC}       - Atom editor benzeri"
    show_theme_colors "one-dark"
    echo
    
    echo -ne "${WHITE}7)${NC} ${CYAN}Solarized Dark${NC} - Klasik, düşük kontrast"
    show_theme_colors "solarized"
    echo
    
    echo -e "${WHITE}0)${NC} Geri"
    echo
    echo -ne "${CYAN}Seçiminiz (0-7): ${NC}"
}

# ============================================================================
# AYARLAR MENÜSÜ
# ============================================================================

show_settings_menu() {
    clear
    show_banner
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              ${BOLD}AYARLAR${NC}                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    load_config
    
    echo -e "${YELLOW}Mevcut Ayarlar:${NC}"
    echo -e "  ${CYAN}Varsayılan Tema:${NC} ${DEFAULT_THEME:-Yok}"
    echo -e "  ${CYAN}Otomatik Güncelleme:${NC} ${AUTO_UPDATE:-false}"
    echo -e "  ${CYAN}Yedek Sayısı:${NC} ${BACKUP_COUNT:-5}"
    echo -e "  ${CYAN}Debug Modu:${NC} ${DEBUG_MODE:-false}"
    echo
    echo -e "${WHITE}1)${NC} Varsayılan Tema Değiştir"
    echo -e "${WHITE}2)${NC} Otomatik Güncelleme ($([ "$AUTO_UPDATE" = "true" ] && echo "Kapat" || echo "Aç"))"
    echo -e "${WHITE}3)${NC} Yedek Sayısını Ayarla"
    echo -e "${WHITE}4)${NC} Güncellemeleri Kontrol Et"
    echo -e "${WHITE}5)${NC} Ayarları Sıfırla"
    echo -e "${WHITE}0)${NC} Geri"
    echo
    echo -ne "${CYAN}Seçiminiz (0-5): ${NC}"
}

# ============================================================================
# TERMİNAL ARAÇLARI BİLGİ
# ============================================================================

show_terminal_tools_info() {
    clear
    show_banner
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           ${BOLD}MODERN TERMİNAL ARAÇLARI${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
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
    
    echo -ne "${CYAN}Tümünü kurmak ister misiniz? (e/h): ${NC}"
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
        wait "$SPINNER_PID" 2>/dev/null || true
        
        # Satırı temizle
        printf "\r\033[K"
        
        # Durum göster
        case "$status" in
            success)
                echo -e "${GREEN}✓${NC} Tamamlandı"
                ;;
            error)
                echo -e "${RED}✗${NC} Başarısız"
                ;;
            warning)
                echo -e "${YELLOW}⚠  ${NC} Uyarı"
                ;;
        esac
        
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
    echo -e "${CYAN}═════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}DEĞİŞİKLİKLERİ GÖRMEK İÇİN ZSH'E GEÇİN${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════${NC}"
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
    echo -ne "${CYAN}Seçiminiz (1/2) [1]: ${NC}"
    read -r switch_choice
    
    # Boş veya 1 ise otomatik geç
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
    echo "  --scan            Kurulum öncesi akıllı tarama"
    echo "  --update          Güncellemeleri kontrol et"
    echo "  --debug           Debug modu"
    echo "  --verbose         Detaylı çıktı"
    echo "  --version         Versiyon bilgisi"
    echo "  --help, -h        Bu yardım mesajı"
    echo
    echo "Örnekler:"
    echo "  $0                # Normal mod"
    echo "  $0 --scan         # Kurulum öncesi tarama"
    echo "  $0 --health       # Sadece sağlık kontrolü"
    echo "  $0 --debug        # Debug modu ile çalıştır"
}

# ============================================================================
# YÜKLEME BİLGİSİ
# ============================================================================

log_debug "Terminal UI modülü yüklendi (v3.2.0)"