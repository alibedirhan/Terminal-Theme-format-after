#!/bin/bash

# ============================================================================
# Terminal Setup - Yardımcı Fonksiyonlar
# v3.2.5 - Utilities Module
# ============================================================================

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
    echo -e "${YELLOW}⚠ ${NC} $*"
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
    
    local files=("terminal-setup.sh" "terminal-core.sh" "terminal-utils.sh" "terminal-ui.sh" "terminal-themes.sh" "terminal-assistant.sh")
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
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              MEVCUT YEDEKLER                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
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
# HATA KODLARI SİSTEMİ
# ============================================================================

# Hata kodları
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

# Hata mesajlarını map et
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

# Hata mesajını göster
show_error() {
    local error_code=$1
    local context="${2:-}"
    
    log_error "Hata [${error_code}]: ${ERROR_MESSAGES[$error_code]}"
    
    if [[ -n "$context" ]]; then
        log_error "Detay: $context"
    fi
    
    log_error "Log dosyası: $LOG_FILE"
    
    return $error_code
}

# Komut çalıştır ve hata kodu döndür
run_with_error_handling() {
    local description="$1"
    shift
    local command=("$@")
    
    log_debug "Çalıştırılıyor: ${command[*]}"
    echo -n "  → $description... "
    
    local output
    local exit_code
    
    # Komutu çalıştır ve çıktıyı yakala
    output=$("${command[@]}" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓${NC}"
        log_debug "Başarılı: $description"
        return $ERR_SUCCESS
    else
        echo -e "${RED}✗${NC}"
        log_error "Başarısız: $description (Exit Code: $exit_code)"
        log_error "Çıktı: $output"
        return $exit_code
    fi
}

# ============================================================================
# TIMEOUT İŞLEMLERİ
# ============================================================================

# Timeout ile komut çalıştır
run_with_timeout() {
    local timeout_seconds=$1
    local description=$2
    shift 2
    local command=("$@")
    
    log_info "Çalıştırılıyor: $description (Timeout: ${timeout_seconds}s)"
    
    start_spinner "$description"
    
    # timeout komutu varsa kullan
    if command -v timeout &> /dev/null; then
        timeout "$timeout_seconds" "${command[@]}" &> /dev/null
        local exit_code=$?
        
        stop_spinner
        
        if [ $exit_code -eq 124 ]; then
            log_error "Zaman aşımı: $description"
            return $ERR_TIMEOUT
        elif [ $exit_code -ne 0 ]; then
            log_error "Komut başarısız: $description (Exit: $exit_code)"
            return $ERR_COMMAND_FAILED
        else
            log_success "$description tamamlandı"
            return $ERR_SUCCESS
        fi
    else
        # timeout komutu yoksa normal çalıştır
        "${command[@]}" &> /dev/null
        local exit_code=$?
        
        stop_spinner
        
        if [ $exit_code -ne 0 ]; then
            log_error "Komut başarısız: $description"
            return $ERR_COMMAND_FAILED
        else
            log_success "$description tamamlandı"
            return $ERR_SUCCESS
        fi
    fi
}

# ============================================================================
# İNTERAKTİF INPUT (TIMEOUT İLE)
# ============================================================================

# Timeout ile input al
read_with_timeout() {
    local prompt="$1"
    local timeout_seconds="${2:-30}"
    local default_value="${3:-h}"
    local response
    
    echo -n "$prompt "
    
    if read -r -t "$timeout_seconds" response; then
        echo "$response"
    else
        echo
        log_warning "Zaman aşımı - Varsayılan değer kullanılıyor: $default_value"
        echo "$default_value"
    fi
}

# ============================================================================
# SİSTEM KAYNAK KONTROLÜ
# ============================================================================

check_system_resources() {
    log_info "Sistem kaynakları kontrol ediliyor..."
    
    # Disk alanı
    local available_mb=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
    log_debug "Kullanılabilir disk alanı: ${available_mb}MB"
    
    if [ "$available_mb" -lt 500 ]; then
        show_error $ERR_DISK_SPACE "Yetersiz disk alanı: ${available_mb}MB (Min: 500MB)"
        return $ERR_DISK_SPACE
    fi
    
    # Bellek kontrolü
    local available_mem=$(free -m | awk 'NR==2 {print $7}')
    log_debug "Kullanılabilir bellek: ${available_mem}MB"
    
    if [ "$available_mem" -lt 100 ]; then
        log_warning "Düşük bellek: ${available_mem}MB"
    fi
    
    return $ERR_SUCCESS
}

# ============================================================================
# ROLLBACK MEKANİZMASI
# ============================================================================

# Rollback için snapshot oluştur
create_snapshot() {
    local snapshot_name="snapshot_$(date +%Y%m%d_%H%M%S)"
    local snapshot_dir="$BACKUP_DIR/$snapshot_name"
    
    log_info "Snapshot oluşturuluyor: $snapshot_name"
    mkdir -p "$snapshot_dir"
    
    # Önemli dosyaları yedekle
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$snapshot_dir/"
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$snapshot_dir/"
    [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$snapshot_dir/"
    
    # Snapshot bilgisini kaydet
    echo "TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')" > "$snapshot_dir/snapshot.info"
    echo "SHELL=$SHELL" >> "$snapshot_dir/snapshot.info"
    echo "USER=$USER" >> "$snapshot_dir/snapshot.info"
    
    log_success "Snapshot oluşturuldu: $snapshot_dir"
    echo "$snapshot_dir"
}

# Snapshot'tan geri yükle
restore_snapshot() {
    local snapshot_dir="$1"
    
    if [[ ! -d "$snapshot_dir" ]]; then
        log_error "Snapshot bulunamadı: $snapshot_dir"
        return $ERR_FILE_NOT_FOUND
    fi
    
    log_info "Snapshot'tan geri yükleniyor: $snapshot_dir"
    
    [[ -f "$snapshot_dir/.bashrc" ]] && cp "$snapshot_dir/.bashrc" ~/
    [[ -f "$snapshot_dir/.zshrc" ]] && cp "$snapshot_dir/.zshrc" ~/
    [[ -f "$snapshot_dir/.p10k.zsh" ]] && cp "$snapshot_dir/.p10k.zsh" ~/
    
    log_success "Snapshot geri yüklendi"
    return $ERR_SUCCESS
}

# ============================================================================
# DETAYLI LOGlama
# ============================================================================

# Function entry/exit tracking
log_function_enter() {
    local func_name="${FUNCNAME[1]}"
    log_debug ">>> ENTER: $func_name"
}

log_function_exit() {
    local func_name="${FUNCNAME[1]}"
    local exit_code=$1
    log_debug "<<< EXIT: $func_name (Exit Code: $exit_code)"
}

# Performans ölçümü
measure_time() {
    local description="$1"
    shift
    local command=("$@")
    
    local start_time=$(date +%s)
    log_info "Başlatılıyor: $description"
    
    "${command[@]}"
    local exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_info "$description tamamlandı (Süre: ${duration}s, Exit: $exit_code)"
    
    return $exit_code
}

# ============================================================================
# İNİT
# ============================================================================

# Log sistemini başlat
if [[ -n "$LOG_FILE" ]]; then
    init_log
fi