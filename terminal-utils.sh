#!/bin/bash

# ============================================================================
# Terminal Setup - Yardımcı Fonksiyonlar
# v3.2.2 - Production Ready (Error Handling + Validation) - FIXED
# ============================================================================

# ============================================================================
# LOGGING SİSTEMİ - THREAD SAFE (DÜZELTME #3 - Flock Düzeltmesi)
# ============================================================================

init_log() {
    if ! mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null; then
        return 1
    fi
    
    if [[ ! -f "$LOG_FILE" ]]; then
        if ! touch "$LOG_FILE" 2>/dev/null; then
            return 1
        fi
    fi
    
    # Eski logları temizle (son 1000 satır)
    if [[ -f "$LOG_FILE" ]]; then
        local temp_log
        temp_log=$(mktemp) || return 1
        tail -n 1000 "$LOG_FILE" > "$temp_log" 2>/dev/null
        mv "$temp_log" "$LOG_FILE" 2>/dev/null
    fi
    
    return 0
}

log_message() {
    local level=$1
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Thread-safe log yazma - DÜZELTME: FD'yi doğru kullan
    if [[ -w "$LOG_FILE" ]]; then
        local lockfile="${LOG_FILE}.lock"
        
        # File descriptor aç, kilitle, yaz, kapat
        exec 200>"$lockfile"
        if flock -x -w 5 200 2>/dev/null; then
            echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
            flock -u 200
        fi
        exec 200>&-
    fi
    
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
    echo -e "${YELLOW}⚠ ${NC} $*"
}

log_error() {
    log_message "ERROR" "$@"
    echo -e "${RED}✗${NC} $*" >&2
}

log_debug() {
    if [[ "$DEBUG_MODE" == true ]]; then
        log_message "DEBUG" "$@"
        echo -e "${MAGENTA}[DEBUG]${NC} $*"
    fi
}

# ============================================================================
# TERMİNAL DETECTION - VALİDASYON
# ============================================================================

detect_terminal() {
    # GNOME Terminal
    if [[ -n "${GNOME_TERMINAL_SERVICE:-}" ]]; then
        echo "gnome-terminal"
        return 0
    fi
    
    # Kitty
    if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
        echo "kitty"
        return 0
    fi
    
    # Alacritty
    if [[ -n "${ALACRITTY_SOCKET:-}" ]]; then
        echo "alacritty"
        return 0
    fi
    
    # Tilix
    if [[ -n "${TILIX_ID:-}" ]]; then
        echo "tilix"
        return 0
    fi
    
    # Konsole
    if [[ -n "${KONSOLE_VERSION:-}" ]]; then
        echo "konsole"
        return 0
    fi
    
    # iTerm2 (macOS)
    if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
        echo "iterm2"
        return 0
    fi
    
    # Generic check
    if [[ "${COLORTERM:-}" == "truecolor" ]]; then
        echo "generic-truecolor"
        return 0
    fi
    
    echo "unknown"
    return 0
}

check_gnome_terminal() {
    if ! command -v gsettings &> /dev/null; then
        log_warning "GNOME Terminal bulunamadı"
        log_info "Renk teması sadece GNOME Terminal'de çalışır"
        return 1
    fi
    return 0
}

show_terminal_info() {
    local terminal
    terminal=$(detect_terminal)
    echo -e "${CYAN}Terminal Bilgileri:${NC}"
    echo "  Tip: $terminal"
    echo "  TERM: ${TERM:-Bilinmiyor}"
    echo "  COLORTERM: ${COLORTERM:-Yok}"
    echo "  Shell: ${SHELL:-Bilinmiyor}"
}

# ============================================================================
# İNTERNET KONTROLÜ - TIMEOUT + RETRY
# ============================================================================

check_internet() {
    log_debug "İnternet bağlantısı kontrol ediliyor..."
    
    # Önce DNS ile dene (daha güvenilir)
    if timeout 5 curl -s --head --max-time 5 https://www.google.com > /dev/null 2>&1; then
        log_debug "İnternet bağlantısı OK (curl)"
        return 0
    fi
    
    # Fallback: ping
    if timeout 5 ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        log_debug "İnternet bağlantısı OK (ping)"
        return 0
    fi
    
    log_error "İnternet bağlantısı yok!"
    echo "Kurulum için internet gerekli."
    return 1
}

test_internet_speed() {
    log_info "İnternet hızı test ediliyor..."
    
    local start_time
    start_time=$(date +%s%N)
    
    if timeout 10 wget --timeout=5 -q -O /dev/null http://speedtest.tele2.net/1MB.zip 2>/dev/null; then
        local end_time
        end_time=$(date +%s%N)
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
# SAĞLIK KONTROLÜ - VALİDASYON
# ============================================================================

system_health_check() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         SİSTEM SAĞLIK KONTROLÜ                        ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo
    
    local total_checks=0
    local passed_checks=0
    local warnings=0
    
    # 1. Disk alanı kontrolü
    ((total_checks++))
    echo -n "Disk alanı kontrolü... "
    local available_space
    available_space=$(df -BM "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/M//')
    
    if [[ -n "$available_space" ]] && [ "$available_space" -gt 500 ]; then
        echo -e "${GREEN}✓${NC} Yeterli ($available_space MB)"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Yetersiz (${available_space:-0} MB < 500 MB)"
    fi
    
    # 2. İnternet bağlantısı
    ((total_checks++))
    echo -n "İnternet bağlantısı... "
    if timeout 5 ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
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
    local terminal
    terminal=$(detect_terminal)
    if [[ "$terminal" != "unknown" ]]; then
        echo -e "${GREEN}✓${NC} $terminal"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Bilinmeyen"
        ((warnings++))
    fi
    
    # 5. Zsh kontrolü
    ((total_checks++))
    echo -n "Zsh... "
    if command -v zsh &> /dev/null; then
        local zsh_version
        zsh_version=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        echo -e "${GREEN}✓${NC} Kurulu (${zsh_version:-bilinmiyor})"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 6. Oh My Zsh kontrolü
    ((total_checks++))
    echo -n "Oh My Zsh... "
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 7. Font kontrolü
    ((total_checks++))
    echo -n "MesloLGS NF Font... "
    if command -v fc-list &> /dev/null && fc-list 2>/dev/null | grep -q "MesloLGS"; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 8. Powerlevel10k kontrolü
    ((total_checks++))
    echo -n "Powerlevel10k... "
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
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
        echo -e "${YELLOW}⚠ ${NC} Kısmi (1/2)"
        ((warnings++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 10. Yedek kontrolü
    ((total_checks++))
    echo -n "Yedekler... "
    if [[ -d "$BACKUP_DIR" ]] && [[ $(ls -A "$BACKUP_DIR" 2>/dev/null | wc -l) -gt 0 ]]; then
        local backup_count
        backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} Var ($backup_count dosya)"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Yok"
        ((warnings++))
    fi
    
    # Sonuç özeti
    echo
    echo "═══════════════════════════════════════════════════════════"
    echo -e "Toplam Kontrol: $total_checks"
    echo -e "${GREEN}✓ Başarılı: $passed_checks${NC}"
    echo -e "${YELLOW}⚠   Uyarı: $warnings${NC}"
    echo -e "${RED}✗ Hata: $((total_checks - passed_checks))${NC}"
    echo "═══════════════════════════════════════════════════════════"
    
    # Durum değerlendirmesi
    local success_rate=0
    if [ $total_checks -gt 0 ]; then
        success_rate=$((passed_checks * 100 / total_checks))
    fi
    
    if [ $success_rate -eq 100 ]; then
        echo -e "${GREEN}✓ Sistem mükemmel durumda!${NC}"
        return 0
    elif [ $success_rate -ge 80 ]; then
        echo -e "${GREEN}✓ Sistem kurulum için hazır${NC}"
        return 0
    elif [ $success_rate -ge 60 ]; then
        echo -e "${YELLOW}⚠   Sistem kurulabilir ama bazı özellikler çalışmayabilir${NC}"
        return 0
    else
        echo -e "${RED}✗ Sistem kurulum için hazır değil${NC}"
        echo "Lütfen önce eksik paketleri kurun"
        return 1
    fi
}

# ============================================================================
# KONFİGÜRASYON YÖNETİMİ - SAFE
# ============================================================================

DEFAULT_THEME="dracula"
AUTO_UPDATE="false"
BACKUP_COUNT="5"

load_config() {
    if [[ -f "$CONFIG_FILE" ]] && [[ -r "$CONFIG_FILE" ]]; then
        log_debug "Config dosyası yükleniyor: $CONFIG_FILE"
        # shellcheck source=/dev/null
        source "$CONFIG_FILE" 2>/dev/null || log_warning "Config yüklenemedi"
    else
        log_debug "Config dosyası bulunamadı, varsayılanlar kullanılıyor"
    fi
}

save_config() {
    log_debug "Config dosyası kaydediliyor: $CONFIG_FILE"
    
    if ! mkdir -p "$(dirname "$CONFIG_FILE")" 2>/dev/null; then
        log_error "Config dizini oluşturulamadı"
        return 1
    fi
    
    cat > "$CONFIG_FILE" << EOF
# Terminal Setup Configuration
# Auto-generated on $(date)

DEFAULT_THEME="$DEFAULT_THEME"
AUTO_UPDATE="$AUTO_UPDATE"
BACKUP_COUNT="$BACKUP_COUNT"
EOF
    
    if [[ $? -eq 0 ]]; then
        log_success "Ayarlar kaydedildi"
        return 0
    else
        log_error "Ayarlar kaydedilemedi"
        return 1
    fi
}

# ============================================================================
# OTOMATİK GÜNCELLEME - TIMEOUT + VALİDASYON
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
    
    local REPO_URL="https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main"
    local REMOTE_VERSION
    REMOTE_VERSION=$(timeout 10 curl -s --connect-timeout 5 "$REPO_URL/VERSION" 2>/dev/null)
    
    if [[ -z "$REMOTE_VERSION" ]]; then
        [[ "$silent_mode" == false ]] && log_warning "Versiyon bilgisi alınamadı"
        return 1
    fi
    
    log_debug "Mevcut versiyon: $VERSION"
    log_debug "Uzak versiyon: $REMOTE_VERSION"
    
    if [[ "$REMOTE_VERSION" != "$VERSION" ]]; then
        [[ "$silent_mode" == false ]] && echo
        log_info "Yeni versiyon mevcut: $REMOTE_VERSION (Mevcut: $VERSION)"
        
        if [[ "$silent_mode" == false ]]; then
            echo -n "Güncellemek ister misiniz? (e/h): "
            read -r update_choice
            
            if [[ "$update_choice" =~ ^[eE]$ ]]; then
                update_script
            fi
        fi
    else
        [[ "$silent_mode" == false ]] && log_success "En güncel versiyonu kullanıyorsunuz"
    fi
    
    return 0
}

update_script() {
    log_info "Script güncelleniyor..."
    
    local REPO_URL="https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main"
    local TEMP_UPDATE_DIR
    TEMP_UPDATE_DIR=$(mktemp -d -t terminal-setup-update.XXXXXXXXXX) || {
        log_error "Temp dizin oluşturulamadı"
        return 1
    fi
    
    cd "$TEMP_UPDATE_DIR" || {
        log_error "Temp dizine geçilemedi"
        rm -rf "$TEMP_UPDATE_DIR"
        return 1
    fi
    
    log_info "Dosyalar indiriliyor..."
    
    local files=("terminal-setup.sh" "terminal-core.sh" "terminal-utils.sh" "terminal-ui.sh" "terminal-themes.sh" "terminal-assistant.sh")
    local success_count=0
    
    for file in "${files[@]}"; do
        if timeout 30 wget --timeout=15 -q "$REPO_URL/$file" -O "$file" 2>/dev/null; then
            ((success_count++))
            log_debug "$file indirildi"
        else
            log_error "$file indirilemedi"
        fi
    done
    
    if [ $success_count -eq ${#files[@]} ]; then
        log_info "Mevcut sürüm yedekleniyor..."
        local backup_update_dir="$BACKUP_DIR/update_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_update_dir" || {
            log_error "Backup dizini oluşturulamadı"
            cd - > /dev/null
            rm -rf "$TEMP_UPDATE_DIR"
            return 1
        }
        
        for file in "${files[@]}"; do
            if [[ -f "$SCRIPT_DIR/$file" ]]; then
                cp "$SCRIPT_DIR/$file" "$backup_update_dir/" 2>/dev/null
            fi
        done
        
        log_info "Yeni versiyon kuruluyor..."
        for file in "${files[@]}"; do
            cp "$file" "$SCRIPT_DIR/" || {
                log_error "$file kopyalanamadı"
                continue
            }
            chmod +x "$SCRIPT_DIR/$file" 2>/dev/null
        done
        
        cd - > /dev/null || true
        rm -rf "$TEMP_UPDATE_DIR"
        
        log_success "Güncelleme tamamlandı!"
        echo "Script yeniden başlatılıyor..."
        sleep 2
        exec "$SCRIPT_DIR/terminal-setup.sh"
    else
        log_error "Güncelleme başarısız ($success_count/${#files[@]} dosya indirildi)"
        cd - > /dev/null || true
        rm -rf "$TEMP_UPDATE_DIR"
        return 1
    fi
}

# ============================================================================
# YEDEK YÖNETİMİ - SAFE
# ============================================================================

show_backups() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              MEVCUT YEDEKLER                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo
    
    if [[ -d "$BACKUP_DIR" ]] && [[ $(ls -A "$BACKUP_DIR" 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "${YELLOW}Yedek Dizini: $BACKUP_DIR${NC}"
        echo
        ls -lh "$BACKUP_DIR" 2>/dev/null | tail -n +2 || echo "Listelenemedi"
        echo
        
        local total_size
        total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        echo -e "Toplam boyut: ${CYAN}${total_size:-Bilinmiyor}${NC}"
    else
        log_info "Henüz yedek yok"
    fi
}

cleanup_old_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi
    
    load_config
    
    local count
    count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    
    if [ "$count" -gt "${BACKUP_COUNT:-5}" ]; then
        log_info "Eski yedekler temizleniyor... (Son ${BACKUP_COUNT:-5} tutulacak)"
        
        cd "$BACKUP_DIR" || return 1
        ls -t 2>/dev/null | tail -n +$((BACKUP_COUNT + 1)) | xargs rm -rf 2>/dev/null
        cd - > /dev/null || true
        
        log_success "Eski yedekler temizlendi"
    fi
    
    return 0
}

# ============================================================================
# HATA KODLARI SİSTEMİ
# ============================================================================

readonly ERR_SUCCESS=0
readonly ERR_NETWORK=1
readonly ERR_PERMISSION=2
readonly ERR_DEPENDENCY=3
readonly ERR_FILE_NOT_FOUND=4
readonly ERR_COMMAND_FAILED=5
readonly ERR_USER_CANCELLED=6
readonly ERR_TIMEOUT=7
readonly ERR_INVALID_INPUT=8
readonly ERR_DISK_SPACE=9
readonly ERR_UNKNOWN=99

declare -A ERROR_MESSAGES=(
    [0]="Başarılı"
    [1]="İnternet bağlantısı hatası"
    [2]="Yetki hatası - sudo gerekli"
    [3]="Bağımlılık hatası - paket eksik"
    [4]="Dosya bulunamadı"
    [5]="Komut çalıştırma hatası"
    [6]="Kullanıcı tarafından iptal edildi"
    [7]="Zaman aşımı"
    [8]="Geçersiz girdi"
    [9]="Disk alanı yetersiz"
    [99]="Bilinmeyen hata"
)

show_error() {
    local error_code=$1
    local context="${2:-}"
    
    log_error "Hata [${error_code}]: ${ERROR_MESSAGES[$error_code]:-Bilinmeyen hata}"
    
    if [[ -n "$context" ]]; then
        log_error "Detay: $context"
    fi
    
    log_error "Log dosyası: $LOG_FILE"
    
    return "$error_code"
}

# ============================================================================
# SİSTEM KAYNAK KONTROLÜ - VALİDASYON
# ============================================================================

check_system_resources() {
    log_info "Sistem kaynakları kontrol ediliyor..."
    
    # Disk alanı
    local available_mb
    available_mb=$(df -BM "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/M//')
    
    if [[ -z "$available_mb" ]]; then
        log_error "Disk alanı ölçülemedi"
        return "$ERR_UNKNOWN"
    fi
    
    log_debug "Kullanılabilir disk alanı: ${available_mb}MB"
    
    if [ "$available_mb" -lt 500 ]; then
        show_error $ERR_DISK_SPACE "Yetersiz disk alanı: ${available_mb}MB (Min: 500MB)"
        return "$ERR_DISK_SPACE"
    fi
    
    # Bellek kontrolü
    if command -v free &> /dev/null; then
        local available_mem
        available_mem=$(free -m 2>/dev/null | awk 'NR==2 {print $7}')
        
        if [[ -n "$available_mem" ]]; then
            log_debug "Kullanılabilir bellek: ${available_mem}MB"
            
            if [ "$available_mem" -lt 100 ]; then
                log_warning "Düşük bellek: ${available_mem}MB"
            fi
        fi
    fi
    
    return "$ERR_SUCCESS"
}

# ============================================================================
# SHELL CHECK WRAPPER
# ============================================================================

run_comprehensive_shell_check() {
    echo "  Kapsamlı shell kontrolü:"
    echo
    
    # 1. /etc/passwd
    local passwd_shell
    passwd_shell=$(grep "^$USER:" /etc/passwd 2>/dev/null | cut -d: -f7)
    echo -n "  1. /etc/passwd: ${passwd_shell:-Bilinmiyor} "
    if [[ "$passwd_shell" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 2. $SHELL değişkeni
    echo -n "  2. \$SHELL: ${SHELL:-Bilinmiyor} "
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 3. Aktif shell
    local active_shell
    active_shell=$(ps -p $$ -o comm= 2>/dev/null)
    echo -n "  3. Aktif shell: ${active_shell:-Bilinmiyor} "
    if [[ "$active_shell" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 4. GNOME Terminal
    if command -v gsettings &> /dev/null; then
        local profile_id
        profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        
        if [[ -n "$profile_id" ]]; then
            local login_shell
            login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
            echo -n "  4. GNOME Terminal login-shell: ${login_shell:-false} "
            if [[ "$login_shell" == "true" ]]; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗${NC}"
            fi
        fi
    fi
}

provide_shell_fix_commands() {
    echo "Adım adım çözüm:"
    echo
    
    local passwd_shell
    passwd_shell=$(grep "^$USER:" /etc/passwd 2>/dev/null | cut -d: -f7)
    
    if [[ "$passwd_shell" != *"zsh"* ]]; then
        echo "1. Sistem shell'ini değiştir:"
        echo -e "   ${CYAN}sudo chsh -s \$(which zsh) $USER${NC}"
        echo
    fi
    
    if command -v gsettings &> /dev/null; then
        local profile_id
        profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        
        if [[ -n "$profile_id" ]]; then
            local login_shell
            login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
            
            if [[ "$login_shell" != "true" ]]; then
                echo "2. GNOME Terminal ayarla:"
                echo -e "   ${CYAN}PROFILE=\$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \\')${NC}"
                echo -e "   ${CYAN}gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\$PROFILE/ login-shell true${NC}"
                echo
            fi
        fi
    fi
    
    echo "3. Değişiklikleri uygula:"
    echo -e "   ${CYAN}gnome-session-quit --logout${NC}"
    echo "   (veya tüm terminalleri kapatıp yeniden aç)"
    echo
}

# ============================================================================
# İNİT
# ============================================================================

if [[ -n "${LOG_FILE:-}" ]]; then
    init_log || echo "UYARI: Log başlatılamadı" >&2
fi

log_debug "Terminal Utils modülü yüklendi (v3.2.2)"