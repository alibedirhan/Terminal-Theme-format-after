#!/bin/bash

# ============================================================================
# Terminal Setup - Yardımcı Fonksiyonlar
# v3.1.0 - Utilities Module
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
# LOGGING SİSTEMİ
# ============================================================================

# Log dosyasını başlat
init_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi
    
    # Eski logları temizle (son 1000 satır)
    if [[ -f "$LOG_FILE" ]]; then
        local temp_log=$(mktemp)
        tail -n 1000 "$LOG_FILE" > "$temp_log"
        mv "$temp_log" "$LOG_FILE"
    fi
}

# Log fonksiyonu
log_message() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log dosyasına yaz
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Verbose modda konsola da yaz
    if [[ "$VERBOSE_MODE" == true ]]; then
        echo "[$level] $message"
    fi
}

log_info() {
    log_message "INFO" "$@"
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    log_message "SUCCESS" "$@"
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    log_message "WARNING" "$@"
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    log_message "ERROR" "$@"
    echo -e "${RED}✗${NC} $*"
}

log_debug() {
    if [[ "$DEBUG_MODE" == true ]]; then
        log_message "DEBUG" "$@"
        echo -e "${MAGENTA}[DEBUG]${NC} $*"
    fi
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

# ============================================================================
# TERMİNAL DETECTION
# ============================================================================

detect_terminal() {
    # GNOME Terminal
    if [ -n "$GNOME_TERMINAL_SERVICE" ]; then
        echo "gnome-terminal"
        return
    fi
    
    # Kitty
    if [ -n "$KITTY_WINDOW_ID" ]; then
        echo "kitty"
        return
    fi
    
    # Alacritty
    if [ -n "$ALACRITTY_SOCKET" ]; then
        echo "alacritty"
        return
    fi
    
    # Tilix
    if [ "$TILIX_ID" ]; then
        echo "tilix"
        return
    fi
    
    # Konsole
    if [ "$KONSOLE_VERSION" ]; then
        echo "konsole"
        return
    fi
    
    # iTerm2 (macOS)
    if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        echo "iterm2"
        return
    fi
    
    # Generic check
    if [ "$COLORTERM" = "truecolor" ]; then
        echo "generic-truecolor"
        return
    fi
    
    echo "unknown"
}

check_gnome_terminal() {
    if ! command -v gsettings &> /dev/null; then
        log_warning "GNOME Terminal bulunamadı"
        log_info "Renk teması sadece GNOME Terminal'de çalışır"
        return 1
    fi
    return 0
}

# Terminal bilgilerini göster
show_terminal_info() {
    local terminal=$(detect_terminal)
    echo -e "${CYAN}Terminal Bilgileri:${NC}"
    echo "  Tip: $terminal"
    echo "  TERM: $TERM"
    echo "  COLORTERM: ${COLORTERM:-Yok}"
    echo "  Shell: $SHELL"
}

# ============================================================================
# İNTERNET KONTROLÜ
# ============================================================================

check_internet() {
    log_debug "İnternet bağlantısı kontrol ediliyor..."
    
    if ! ping -c 1 -W 5 8.8.8.8 &> /dev/null; then
        log_error "İnternet bağlantısı yok!"
        echo "Kurulum için internet gerekli."
        return 1
    fi
    
    log_debug "İnternet bağlantısı OK"
    return 0
}

# İnternet hızı testi (opsiyonel)
test_internet_speed() {
    log_info "İnternet hızı test ediliyor..."
    
    local start_time=$(date +%s%N)
    if wget --timeout=5 -q -O /dev/null http://speedtest.tele2.net/1MB.zip 2>/dev/null; then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        if [ $duration -lt 2000 ]; then
            log_success "İnternet hızı: İyi"
        elif [ $duration -lt 5000 ]; then
            log_warning "İnternet hızı: Orta"
        else
            log_warning "İnternet hızı: Yavaş"
        fi
    else
        log_warning "İnternet hızı ölçülemedi"
    fi
}

# ============================================================================
# SAĞLIK KONTROLÜ (HEALTH CHECK)
# ============================================================================

system_health_check() {
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         SİSTEM SAĞLIK KONTROLÜ               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo
    
    local total_checks=0
    local passed_checks=0
    local warnings=0
    
    # 1. Disk alanı kontrolü
    ((total_checks++))
    echo -n "Disk alanı kontrolü... "
    local available_space=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
    if [ "$available_space" -gt 500 ]; then
        echo -e "${GREEN}✓${NC} Yeterli ($available_space MB)"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Yetersiz ($available_space MB < 500 MB)"
    fi
    
    # 2. İnternet bağlantısı
    ((total_checks++))
    echo -n "İnternet bağlantısı... "
    if timeout 5 ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}✓${NC} Aktif"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Yok"
    fi
    
    # 3. Gerekli komutlar
    ((total_checks++))
    echo -n "Gerekli paketler... "
    local missing_pkgs=()
    for cmd in git curl wget; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_pkgs+=("$cmd")
        fi
    done
    
    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Tamam"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Eksik: ${missing_pkgs[*]}"
    fi
    
    # 4. Terminal emulator
    ((total_checks++))
    echo -n "Terminal emulator... "
    local terminal=$(detect_terminal)
    if [ "$terminal" != "unknown" ]; then
        echo -e "${GREEN}✓${NC} $terminal"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Bilinmeyen"
        ((warnings++))
    fi
    
    # 5. Zsh kontrolü
    ((total_checks++))
    echo -n "Zsh... "
    if command -v zsh &> /dev/null; then
        local zsh_version=$(zsh --version | cut -d' ' -f2)
        echo -e "${GREEN}✓${NC} Kurulu ($zsh_version)"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 6. Oh My Zsh kontrolü
    ((total_checks++))
    echo -n "Oh My Zsh... "
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 7. Font kontrolü
    ((total_checks++))
    echo -n "MesloLGS NF Font... "
    if fc-list 2>/dev/null | grep -q "MesloLGS"; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 8. Powerlevel10k kontrolü
    ((total_checks++))
    echo -n "Powerlevel10k... "
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 9. Pluginler kontrolü
    ((total_checks++))
    echo -n "Zsh Pluginleri... "
    local plugin_count=0
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [[ -d "$CUSTOM/plugins/zsh-autosuggestions" ]] && ((plugin_count++))
    [[ -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]] && ((plugin_count++))
    
    if [ $plugin_count -eq 2 ]; then
        echo -e "${GREEN}✓${NC} Tamam (2/2)"
        ((passed_checks++))
    elif [ $plugin_count -eq 1 ]; then
        echo -e "${YELLOW}⚠${NC} Kısmi (1/2)"
        ((warnings++))
    else
        echo -e "${YELLOW}⚠${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 10. Yedek kontrolü
    ((total_checks++))
    echo -n "Yedekler... "
    if [[ -d "$BACKUP_DIR" ]] && [[ $(ls -A "$BACKUP_DIR" 2>/dev/null | wc -l) -gt 0 ]]; then
        local backup_count=$(ls "$BACKUP_DIR" | wc -l)
        echo -e "${GREEN}✓${NC} Var ($backup_count dosya)"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠${NC} Yok"
        ((warnings++))
    fi
    
    # Sonuç özeti
    echo
    echo "══════════════════════════════════════════════"
    echo -e "Toplam Kontrol: $total_checks"
    echo -e "${GREEN}✓ Başarılı: $passed_checks${NC}"
    echo -e "${YELLOW}⚠ Uyarı: $warnings${NC}"
    echo -e "${RED}✗ Hata: $((total_checks - passed_checks))${NC}"
    echo "══════════════════════════════════════════════"
    
    # Durum değerlendirmesi
    local success_rate=$((passed_checks * 100 / total_checks))
    
    if [ $success_rate -eq 100 ]; then
        echo -e "${GREEN}✓ Sistem mükemmel durumda!${NC}"
        return 0
    elif [ $success_rate -ge 80 ]; then
        echo -e "${GREEN}✓ Sistem kurulum için hazır${NC}"
        return 0
    elif [ $success_rate -ge 60 ]; then
        echo -e "${YELLOW}⚠ Sistem kurulabilir ama bazı özellikler çalışmayabilir${NC}"
        return 0
    else
        echo -e "${RED}✗ Sistem kurulum için hazır değil${NC}"
        echo "Lütfen önce eksik paketleri kurun"
        return 1
    fi
}

# ============================================================================
# KONFİGÜRASYON YÖNETİMİ
# ============================================================================

# Varsayılan ayarlar
DEFAULT_THEME="dracula"
AUTO_UPDATE="false"
BACKUP_COUNT="5"

# Config dosyasını yükle
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_debug "Config dosyası yükleniyor: $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log_debug "Config dosyası bulunamadı, varsayılanlar kullanılıyor"
    fi
}

# Config dosyasını kaydet
save_config() {
    log_debug "Config dosyası kaydediliyor: $CONFIG_FILE"
    
    cat > "$CONFIG_FILE" << EOF
# Terminal Setup Configuration
# Auto-generated on $(date)

DEFAULT_THEME="$DEFAULT_THEME"
AUTO_UPDATE="$AUTO_UPDATE"
BACKUP_COUNT="$BACKUP_COUNT"
EOF
    
    log_success "Ayarlar kaydedildi"
}

# ============================================================================
# OTOMATİK GÜNCELLEME
# ============================================================================

check_for_updates() {
    local silent_mode=false
    if [[ "$1" == "--silent" ]]; then
        silent_mode=true
    fi
    
    if ! check_internet; then
        [[ "$silent_mode" == false ]] && log_warning "Güncelleme kontrolü için internet gerekli"
        return 1
    fi
    
    [[ "$silent_mode" == false ]] && log_info "Güncellemeler kontrol ediliyor..."
    
    # GitHub'dan en son versiyon bilgisini al
    local REPO_URL="https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main"
    local REMOTE_VERSION=$(curl -s --connect-timeout 5 "$REPO_URL/VERSION" 2>/dev/null)
    
    if [[ -z "$REMOTE_VERSION" ]]; then
        [[ "$silent_mode" == false ]] && log_warning "Versiyon bilgisi alınamadı"
        return 1
    fi
    
    log_debug "Mevcut versiyon: $VERSION"
    log_debug "Uzak versiyon: $REMOTE_VERSION"
    
    # Versiyon karşılaştırması
    if [[ "$REMOTE_VERSION" != "$VERSION" ]]; then
        [[ "$silent_mode" == false ]] && echo
        log_info "Yeni versiyon mevcut: $REMOTE_VERSION (Mevcut: $VERSION)"
        
        if [[ "$silent_mode" == false ]]; then
            echo -n "Güncellemek ister misiniz? (e/h): "
            read -r update_choice
            
            if [[ "$update_choice" == "e" ]]; then
                update_script
            fi
        fi
    else
        [[ "$silent_mode" == false ]] && log_success "En güncel versiyonu kullanıyorsunuz"
    fi
}

update_script() {
    log_info "Script güncelleniyor..."
    
    local REPO_URL="https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main"
    local TEMP_UPDATE_DIR=$(mktemp -d -t terminal-setup-update.XXXXXXXXXX)
    
    cd "$TEMP_UPDATE_DIR" || return 1
    
    # Dosyaları indir
    log_info "Dosyalar indiriliyor..."
    
    local files=("terminal-setup.sh" "terminal-core.sh" "terminal-utils.sh")
    local success_count=0
    
    for file in "${files[@]}"; do
        if wget --timeout=15 -q "$REPO_URL/$file" -O "$file" 2>/dev/null; then
            ((success_count++))
            log_debug "$file indirildi"
        else
            log_error "$file indirilemedi"
        fi
    done
    
    if [ $success_count -eq ${#files[@]} ]; then
        # Yedek oluştur
        log_info "Mevcut sürüm yedekleniyor..."
        local backup_update_dir="$BACKUP_DIR/update_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_update_dir"
        
        for file in "${files[@]}"; do
            if [[ -f "$SCRIPT_DIR/$file" ]]; then
                cp "$SCRIPT_DIR/$file" "$backup_update_dir/"
            fi
        done
        
        # Yeni dosyaları kopyala
        log_info "Yeni versiyon kuruluyor..."
        for file in "${files[@]}"; do
            cp "$file" "$SCRIPT_DIR/"
            chmod +x "$SCRIPT_DIR/$file"
        done
        
        cd - > /dev/null
        rm -rf "$TEMP_UPDATE_DIR"
        
        log_success "Güncelleme tamamlandı!"
        echo "Script yeniden başlatılıyor..."
        sleep 2
        exec "$SCRIPT_DIR/terminal-setup.sh"
    else
        log_error "Güncelleme başarısız ($success_count/${#files[@]} dosya indirildi)"
        cd - > /dev/null
        rm -rf "$TEMP_UPDATE_DIR"
        return 1
    fi
}

# ============================================================================
# YEDEK YÖNETİMİ
# ============================================================================

show_backups() {
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              MEVCUT YEDEKLER                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo
    
    if [[ -d "$BACKUP_DIR" && $(ls -A "$BACKUP_DIR" 2>/dev/null) ]]; then
        echo -e "${YELLOW}Yedek Dizini: $BACKUP_DIR${NC}"
        echo
        ls -lh "$BACKUP_DIR" | tail -n +2
        echo
        
        # Toplam boyut
        local total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        echo -e "Toplam boyut: ${CYAN}$total_size${NC}"
    else
        log_info "Henüz yedek yok"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# Eski yedekleri temizle
cleanup_old_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return
    fi
    
    load_config
    local count=$(ls -1 "$BACKUP_DIR" | wc -l)
    
    if [ "$count" -gt "$BACKUP_COUNT" ]; then
        log_info "Eski yedekler temizleniyor... (Son $BACKUP_COUNT tutulacak)"
        
        cd "$BACKUP_DIR" || return
        ls -t | tail -n +$((BACKUP_COUNT + 1)) | xargs rm -rf
        cd - > /dev/null
        
        log_success "Eski yedekler temizlendi"
    fi
}

# ============================================================================
# İNİT
# ============================================================================

# Log sistemini başlat
init_log