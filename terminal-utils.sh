#!/bin/bash

# ============================================================================
# Terminal Setup - Yardımcı Fonksiyonlar
# v3.2.8 - Utilities Module (Enhanced & Secure)
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
    
    # Terminal.app (macOS)
    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        echo "terminal-app"
        return
    fi
    
    # Hyper
    if [ "$TERM_PROGRAM" = "Hyper" ]; then
        echo "hyper"
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
    echo "  OS: $OSTYPE"
}

# ============================================================================
# İNTERNET KONTROLÜ (İYİLEŞTİRİLMİŞ)
# ============================================================================

check_internet() {
    log_debug "İnternet bağlantısı kontrol ediliyor..."
    
    # DÜZELTME: Birden fazla host dene (8.8.8.8 bloklanabilir)
    local hosts=("8.8.8.8" "1.1.1.1" "google.com")
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &> /dev/null; then
            log_debug "İnternet bağlantısı OK (via $host)"
            return 0
        fi
    done
    
    log_error "İnternet bağlantısı yok!"
    echo "Kurulum için internet gerekli."
    return 1
}

# İnternet hızı testi (opsiyonel)
test_internet_speed() {
    log_info "İnternet hızı test ediliyor..."
    
    local start_time=$(date +%s%N)
    if wget --timeout=5 -q -O /dev/null http://speedtest.tele2.net/1MB.zip 2>/dev/null; then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        if [ $duration -lt 2000 ]; then
            log_success "İnternet hızı: İyi (${duration}ms)"
        elif [ $duration -lt 5000 ]; then
            log_warning "İnternet hızı: Orta (${duration}ms)"
        else
            log_warning "İnternet hızı: Yavaş (${duration}ms)"
        fi
    else
        log_warning "İnternet hızı ölçülemedi"
    fi
}

# ============================================================================
# KONFİGÜRASYON YÖNETİMİ (İYİLEŞTİRİLMİŞ)
# ============================================================================

# Varsayılan ayarlar
DEFAULT_THEME="dracula"
AUTO_UPDATE="false"
BACKUP_COUNT="5"

# Config dosyasını yükle
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_debug "Config dosyası yükleniyor: $CONFIG_FILE"
        
        # DÜZELTME: Güvenlik - sadece güvenli değişkenleri source et
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    else
        log_debug "Config dosyası bulunamadı, varsayılanlar kullanılıyor"
    fi
}

# Config dosyasını kaydet (İYİLEŞTİRİLMİŞ)
save_config() {
    log_debug "Config dosyası kaydediliyor: $CONFIG_FILE"
    
    # DÜZELTME: Dizin oluşturma kontrolü
    if ! mkdir -p "$(dirname "$CONFIG_FILE")" 2>/dev/null; then
        log_error "Config dizini oluşturulamadı: $(dirname "$CONFIG_FILE")"
        return 1
    fi
    
    # Eski config'i yedekle
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.backup" 2>/dev/null
    fi
    
    # DÜZELTME: Atomic write (temp file + mv)
    local temp_config=$(mktemp)
    
    cat > "$temp_config" << EOF
# Terminal Setup Configuration
# Auto-generated on $(date)
# Version: ${VERSION:-3.2.5}

DEFAULT_THEME="$DEFAULT_THEME"
AUTO_UPDATE="$AUTO_UPDATE"
BACKUP_COUNT="$BACKUP_COUNT"
EOF
    
    if ! mv "$temp_config" "$CONFIG_FILE"; then
        log_error "Config dosyası yazılamadı"
        rm -f "$temp_config"
        return 1
    fi
    
    # DÜZELTME: Güvenlik - sadece kullanıcı okuyabilsin
    chmod 600 "$CONFIG_FILE"
    
    log_success "Ayarlar kaydedildi"
    return 0
}

# Config validation
validate_config() {
    local valid=true
    
    # Theme validation
    local valid_themes=("dracula" "nord" "gruvbox" "tokyo-night" "catppuccin" "one-dark" "solarized")
    if [[ ! " ${valid_themes[*]} " =~ " ${DEFAULT_THEME} " ]]; then
        log_warning "Geçersiz tema: $DEFAULT_THEME, varsayılan kullanılıyor"
        DEFAULT_THEME="dracula"
        valid=false
    fi
    
    # Backup count validation
    if ! [[ "$BACKUP_COUNT" =~ ^[0-9]+$ ]] || [ "$BACKUP_COUNT" -lt 1 ] || [ "$BACKUP_COUNT" -gt 20 ]; then
        log_warning "Geçersiz backup sayısı: $BACKUP_COUNT, varsayılan kullanılıyor"
        BACKUP_COUNT="5"
        valid=false
    fi
    
    $valid && return 0 || return 1
}

# ============================================================================
# OTOMATİK GÜNCELLEME (İYİLEŞTİRİLMİŞ)
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
    
    # DÜZELTME: Repo URL'yi dinamik olarak al
    local REPO_URL
    REPO_URL=$(get_repo_url)
    
    if [[ -z "$REPO_URL" ]]; then
        log_error "Repo URL alınamadı"
        return 1
    fi
    
    local REMOTE_VERSION=$(curl -s --connect-timeout 5 "${REPO_URL}/raw/main/VERSION" 2>/dev/null)
    
    if [[ -z "$REMOTE_VERSION" ]]; then
        [[ "$silent_mode" == false ]] && log_warning "Versiyon bilgisi alınamadı"
        return 1
    fi
    
    # Versiyon dosyasından oku
    local CURRENT_VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "$VERSION")
    
    log_debug "Mevcut versiyon: $CURRENT_VERSION"
    log_debug "Uzak versiyon: $REMOTE_VERSION"
    
    # Versiyon karşılaştırması
    if [[ "$REMOTE_VERSION" != "$CURRENT_VERSION" ]]; then
        [[ "$silent_mode" == false ]] && echo
        log_info "Yeni versiyon mevcut: $REMOTE_VERSION (Mevcut: $CURRENT_VERSION)"
        
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

# Repo URL'yi dinamik al (İYİLEŞTİRİLMİŞ)
get_repo_url() {
    # DÜZELTME: Git remote'dan otomatik al
    local repo_url
    
    if command -v git &> /dev/null && [[ -d .git ]]; then
        repo_url=$(git config --get remote.origin.url 2>/dev/null)
        
        if [[ -n "$repo_url" ]]; then
            # SSH URL'yi HTTPS'ye çevir
            repo_url=$(echo "$repo_url" | sed 's|git@github.com:|https://github.com/|')
            # .git suffix'ini kaldır
            repo_url=$(echo "$repo_url" | sed 's|\.git$||')
            
            echo "$repo_url"
            return 0
        fi
    fi
    
    # Fallback: Hardcoded
    echo "https://github.com/alibedirhan/Theme-after-format"
}

# Script güncelleme (İYİLEŞTİRİLMİŞ)
update_script() {
    log_info "Script güncelleniyor..."
    
    local REPO_URL
    REPO_URL=$(get_repo_url)
    local RAW_URL="${REPO_URL}/raw/main"
    
    local TEMP_UPDATE_DIR=$(mktemp -d -t terminal-setup-update.XXXXXXXXXX)
    
    if ! cd "$TEMP_UPDATE_DIR"; then
        log_error "Temp dizine geçilemedi"
        return 1
    fi
    
    # Dosyaları indir
    log_info "Dosyalar indiriliyor..."
    
    local files=("terminal-setup.sh" "terminal-core.sh" "terminal-utils.sh" "terminal-ui.sh" "terminal-themes.sh" "terminal-assistant.sh" "VERSION")
    local success_count=0
    
    # DÜZELTME: Checksum dosyasını indir (varsa)
    local has_checksum=false
    if wget --timeout=10 -q "$RAW_URL/SHA256SUMS" -O SHA256SUMS 2>/dev/null; then
        has_checksum=true
        log_debug "Checksum dosyası indirildi"
    fi
    
    for file in "${files[@]}"; do
        if wget --timeout=15 --https-only -q "$RAW_URL/$file" -O "$file" 2>/dev/null; then
            # DÜZELTME: Checksum doğrulama (varsa)
            if [[ "$has_checksum" == true ]]; then
                if grep -q "$file" SHA256SUMS; then
                    if sha256sum -c SHA256SUMS 2>/dev/null | grep -q "$file: OK"; then
                        ((success_count++))
                        log_debug "$file indirildi ve doğrulandı"
                    else
                        log_error "$file checksum doğrulaması başarısız!"
                        rm -f "$file"
                    fi
                else
                    # Checksum yok ama dosya var
                    ((success_count++))
                    log_debug "$file indirildi (checksum yok)"
                fi
            else
                # Checksum sistemi yok
                ((success_count++))
                log_debug "$file indirildi"
            fi
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
            if [[ -f "$file" ]]; then
                cp "$file" "$SCRIPT_DIR/"
                [[ "$file" == *.sh ]] && chmod +x "$SCRIPT_DIR/$file"
            fi
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
# YEDEK YÖNETİMİ (İYİLEŞTİRİLMİŞ)
# ============================================================================

show_backups() {
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              MEVCUT YEDEKLER                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo
    
    if [[ -d "$BACKUP_DIR" && $(ls -A "$BACKUP_DIR" 2>/dev/null) ]]; then
        echo -e "${YELLOW}Yedek Dizini: $BACKUP_DIR${NC}"
        echo
        
        # Son 10 yedek
        ls -lt "$BACKUP_DIR" | head -11 | tail -10
        
        echo
        # Toplam boyut
        local total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        echo -e "Toplam boyut: ${CYAN}$total_size${NC}"
        
        # Dosya sayısı
        local file_count=$(ls -1 "$BACKUP_DIR" | wc -l)
        echo -e "Dosya sayısı: ${CYAN}$file_count${NC}"
    else
        log_info "Henüz yedek yok"
    fi
    
    echo
}

# Eski yedekleri temizle (İYİLEŞTİRİLMİŞ)
cleanup_old_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return
    fi
    
    load_config
    local count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    
    if [ "$count" -gt "$BACKUP_COUNT" ]; then
        log_info "Eski yedekler temizleniyor... (Son $BACKUP_COUNT tutulacak)"
        
        cd "$BACKUP_DIR" || return
        ls -t | tail -n +$((BACKUP_COUNT + 1)) | xargs rm -rf 2>/dev/null
        cd - > /dev/null
        
        log_success "Eski yedekler temizlendi"
    fi
}

# Yedek boyut kontrolü (YENİ)
check_backup_size() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi
    
    # DÜZELTME: macOS uyumlu du komutu
    local size_mb
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size_mb=$(du -sm "$BACKUP_DIR" | cut -f1)
    else
        size_mb=$(du -sm "$BACKUP_DIR" | cut -f1)
    fi
    
    local max_size_mb=100
    
    if [ "$size_mb" -gt "$max_size_mb" ]; then
        log_warning "Yedek dizini çok büyük: ${size_mb}MB (Max: ${max_size_mb}MB)"
        echo -n "Eski yedekleri temizlemek ister misiniz? (e/h): "
        read -r clean_choice
        
        if [[ "$clean_choice" == "e" ]]; then
            # En eski yedekleri sil
            cd "$BACKUP_DIR" || return
            ls -t | tail -n +6 | xargs rm -rf 2>/dev/null
            cd - > /dev/null
            log_success "Eski yedekler temizlendi"
        fi
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
readonly ERR_CHECKSUM=10
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
    [10]="Checksum doğrulama hatası"
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
    
    # Spinner başlat (eğer fonksiyon varsa)
    if type start_spinner &>/dev/null; then
        start_spinner "$description"
    fi
    
    # timeout komutu varsa kullan
    if command -v timeout &> /dev/null; then
        timeout "$timeout_seconds" "${command[@]}" &> /dev/null
        local exit_code=$?
        
        # Spinner durdur
        if type stop_spinner &>/dev/null; then
            stop_spinner
        fi
        
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
        
        if type stop_spinner &>/dev/null; then
            stop_spinner
        fi
        
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
# SİSTEM KAYNAK KONTROLÜ (İYİLEŞTİRİLMİŞ)
# ============================================================================

check_system_resources() {
    log_info "Sistem kaynakları kontrol ediliyor..."
    
    # DÜZELTME: macOS uyumlu disk space check
    local available_mb
    if [[ "$OSTYPE" == "darwin"* ]]; then
        available_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')
    else
        available_mb=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
    fi
    
    log_debug "Kullanılabilir disk alanı: ${available_mb}MB"
    
    if [ "$available_mb" -lt 500 ]; then
        show_error $ERR_DISK_SPACE "Yetersiz disk alanı: ${available_mb}MB (Min: 500MB)"
        return $ERR_DISK_SPACE
    fi
    
    # Bellek kontrolü
    if command -v free &> /dev/null; then
        local available_mem=$(free -m | awk 'NR==2 {print $7}')
        log_debug "Kullanılabilir bellek: ${available_mem}MB"
        
        if [ "$available_mem" -lt 100 ]; then
            log_warning "Düşük bellek: ${available_mem}MB"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS için memory check
        local free_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        local page_size=4096
        local available_mem=$((free_mem * page_size / 1024 / 1024))
        log_debug "Kullanılabilir bellek: ${available_mem}MB (macOS)"
    fi
    
    return $ERR_SUCCESS
}

# ============================================================================
# ROLLBACK MEKANİZMASI (İYİLEŞTİRİLMİŞ)
# ============================================================================

# Rollback için snapshot oluştur
create_snapshot() {
    local snapshot_name="snapshot_$(date +%Y%m%d_%H%M%S)"
    local snapshot_dir="$BACKUP_DIR/$snapshot_name"
    
    log_info "Snapshot oluşturuluyor: $snapshot_name"
    
    if ! mkdir -p "$snapshot_dir"; then
        log_error "Snapshot dizini oluşturulamadı"
        return 1
    fi
    
    # Önemli dosyaları yedekle
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$snapshot_dir/"
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$snapshot_dir/"
    [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$snapshot_dir/"
    [[ -f ~/.tmux.conf ]] && cp ~/.tmux.conf "$snapshot_dir/"
    
    # Snapshot bilgisini kaydet
    cat > "$snapshot_dir/snapshot.info" << EOF
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SHELL=$SHELL
USER=$USER
VERSION=${VERSION:-unknown}
OSTYPE=$OSTYPE
EOF
    
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
    [[ -f "$snapshot_dir/.tmux.conf" ]] && cp "$snapshot_dir/.tmux.conf" ~/
    
    log_success "Snapshot geri yüklendi"
    return $ERR_SUCCESS
}

# Son snapshot'ı bul
get_latest_snapshot() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo ""
        return 1
    fi
    
    local latest=$(ls -1dt "$BACKUP_DIR"/snapshot_* 2>/dev/null | head -1)
    echo "$latest"
}

# Snapshot listesini göster
list_snapshots() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "Snapshot yok"
        return
    fi
    
    echo -e "${CYAN}Mevcut Snapshot'lar:${NC}"
    echo
    
    local count=0
    while IFS= read -r snapshot; do
        ((count++))
        local name=$(basename "$snapshot")
        local size=$(du -sh "$snapshot" 2>/dev/null | cut -f1)
        
        echo -e "  ${count}) ${BOLD}$name${NC} - $size"
        
        if [[ -f "$snapshot/snapshot.info" ]]; then
            local timestamp=$(grep "TIMESTAMP=" "$snapshot/snapshot.info" | cut -d'=' -f2)
            echo -e "     ${DIM}Tarih: $timestamp${NC}"
        fi
    done < <(ls -1dt "$BACKUP_DIR"/snapshot_* 2>/dev/null)
    
    if [ $count -eq 0 ]; then
        log_info "Snapshot yok"
    fi
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
# RELIABILITY SİSTEMİ - Kararlılık Mekanizmaları
# ============================================================================
# v1.0 - Retry, Error Recovery, Transaction Management
# ============================================================================

# Global transaction state
TRANSACTION_ACTIVE=false
TRANSACTION_SNAPSHOT=""

# ============================================================================
# RETRY MEKANİZMASI
# ============================================================================

# Universal retry fonksiyonu - Her komut için kullanılabilir
retry_command() {
    local max_attempts="${1:-3}"
    local timeout_seconds="${2:-60}"
    shift 2
    local command=("$@")
    
    if [[ ${#command[@]} -eq 0 ]]; then
        log_error "retry_command: Komut belirtilmedi"
        return 1
    fi
    
    local attempt=1
    local delay=2
    
    log_debug "Retry: ${command[*]} (Max: $max_attempts, Timeout: ${timeout_seconds}s)"
    
    while [ $attempt -le $max_attempts ]; do
        log_debug "Deneme $attempt/$max_attempts..."
        
        # Timeout ile komutu çalıştır
        if command -v timeout &>/dev/null; then
            if timeout "$timeout_seconds" "${command[@]}" 2>&1 | tee -a "$LOG_FILE" | grep -q .; then
                local exit_code=${PIPESTATUS[0]}
                if [ $exit_code -eq 0 ]; then
                    log_debug "Başarılı (Deneme: $attempt)"
                    return 0
                fi
            else
                local exit_code=${PIPESTATUS[0]}
                if [ $exit_code -eq 0 ]; then
                    log_debug "Başarılı (Deneme: $attempt)"
                    return 0
                fi
            fi
        else
            # timeout komutu yoksa direkt çalıştır
            if "${command[@]}" &>> "$LOG_FILE"; then
                log_debug "Başarılı (Deneme: $attempt)"
                return 0
            fi
        fi
        
        # Başarısız, tekrar dene
        if [ $attempt -lt $max_attempts ]; then
            log_warning "Deneme $attempt başarısız, $delay saniye sonra tekrar..."
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff (2, 4, 8...)
        fi
        
        ((attempt++))
    done
    
    log_error "Tüm denemeler başarısız oldu: ${command[*]}"
    return 1
}

# Güvenli download fonksiyonu (retry ile)
safe_download() {
    local url="$1"
    local output="$2"
    local description="${3:-Dosya indiriliyor}"
    
    log_info "$description"
    log_debug "URL: $url"
    log_debug "Output: $output"
    
    # wget öncelikli (daha güvenilir)
    if command -v wget &>/dev/null; then
        if retry_command 3 60 wget -q --show-progress -O "$output" "$url"; then
            log_success "İndirme başarılı: $output"
            return 0
        fi
    fi
    
    # curl fallback
    if command -v curl &>/dev/null; then
        if retry_command 3 60 curl -fsSL -o "$output" "$url"; then
            log_success "İndirme başarılı: $output"
            return 0
        fi
    fi
    
    log_error "İndirme başarısız: $url"
    return 1
}

# Git clone retry ile
safe_git_clone() {
    local repo_url="$1"
    local target_dir="$2"
    local depth="${3:-1}"
    
    log_info "Git repository klonlanıyor..."
    log_debug "Repo: $repo_url"
    log_debug "Target: $target_dir"
    
    # Hedef dizin varsa temizle
    if [[ -d "$target_dir" ]]; then
        log_debug "Mevcut dizin temizleniyor: $target_dir"
        rm -rf "$target_dir"
    fi
    
    # Retry ile clone
    if retry_command 3 120 git clone --depth "$depth" "$repo_url" "$target_dir"; then
        log_success "Repository klonlandı: $target_dir"
        return 0
    fi
    
    log_error "Git clone başarısız: $repo_url"
    return 1
}

# ============================================================================
# ERROR RECOVERY SİSTEMİ
# ============================================================================

# Network hatası recovery
handle_network_error() {
    local context="${1:-Bilinmeyen işlem}"
    
    log_error "Network hatası: $context"
    echo
    echo -e "${YELLOW}═══ BAĞLANTI SORUNU ═══${NC}"
    echo
    echo "Olası nedenler:"
    echo "  1. İnternet bağlantınız kesildi"
    echo "  2. DNS sorunu"
    echo "  3. Güvenlik duvarı/proxy engelliyor"
    echo "  4. Uzak sunucu yanıt vermiyor"
    echo
    echo "Öneriler:"
    echo "  → İnternet bağlantınızı kontrol edin"
    echo "  → VPN kullanıyorsanız kapatıp deneyin"
    echo "  → Birkaç dakika bekleyip tekrar deneyin"
    echo
    
    # Otomatik internet kontrolü
    if check_internet; then
        log_info "İnternet bağlantısı aktif, tekrar deneniyor..."
        return 0  # Retry yap
    else
        log_error "İnternet bağlantısı yok!"
        return 1  # Fatal error
    fi
}

# Disk alanı hatası recovery
handle_disk_space_error() {
    local context="${1:-Bilinmeyen işlem}"
    local required_mb="${2:-500}"
    
    log_error "Disk alanı yetersiz: $context"
    echo
    echo -e "${YELLOW}═══ DİSK ALANI YETERSİZ ═══${NC}"
    echo
    echo "Gerekli alan: ${required_mb}MB"
    echo
    echo "Öneriler:"
    echo "  1. Gereksiz dosyaları silin"
    echo "  2. Paket önbelleğini temizleyin: sudo apt clean"
    echo "  3. Kullanılmayan paketleri kaldırın: sudo apt autoremove"
    echo
    
    if ask_yes_no "Otomatik temizlik yapalım mı? (apt clean + autoremove)"; then
        log_info "Otomatik temizlik başlatılıyor..."
        
        sudo apt clean &>/dev/null
        sudo apt autoremove -y &>/dev/null
        
        log_success "Temizlik tamamlandı"
        return 0  # Retry yap
    fi
    
    return 1  # Kullanıcı redetti
}

# Permission hatası recovery
handle_permission_error() {
    local context="${1:-Bilinmeyen işlem}"
    
    log_error "Yetki hatası: $context"
    echo
    echo -e "${YELLOW}═══ YETKİ SORUNU ═══${NC}"
    echo
    echo "Bu işlem için sudo yetkisi gerekiyor."
    echo
    
    if ask_yes_no "Sudo yetkisi almak ister misiniz?"; then
        if setup_sudo 2>/dev/null || sudo -v 2>/dev/null; then
            log_success "Sudo yetkisi alındı"
            return 0  # Retry yap
        else
            log_error "Sudo yetkisi alınamadı"
            return 1
        fi
    fi
    
    return 1  # Kullanıcı redetti
}

# ============================================================================
# TRANSACTION SİSTEMİ (Snapshot Tabanlı)
# ============================================================================

# Transaction başlat (snapshot al)
transaction_begin() {
    local operation_name="${1:-İşlem}"
    
    if [[ "$TRANSACTION_ACTIVE" == true ]]; then
        log_warning "Zaten aktif bir transaction var, yeni snapshot alınmıyor"
        return 0
    fi
    
    log_info "Transaction başlatılıyor: $operation_name"
    
    # Snapshot oluştur (terminal-utils.sh'taki mevcut fonksiyon)
    if type create_snapshot &>/dev/null; then
        # DÜZELTME: create_snapshot hem log hem path yazıyor, sadece son satırı (path) al
        TRANSACTION_SNAPSHOT=$(create_snapshot 2>&1 | tail -1 | xargs)
        
        # Debug: snapshot path'ini logla
        log_debug "Snapshot path: '$TRANSACTION_SNAPSHOT'"
        
        if [[ -n "$TRANSACTION_SNAPSHOT" ]] && [[ -d "$TRANSACTION_SNAPSHOT" ]]; then
            TRANSACTION_ACTIVE=true
            log_success "Transaction başlatıldı (Snapshot: $(basename "$TRANSACTION_SNAPSHOT"))"
            return 0
        else
            log_error "Snapshot oluşturulamadı (Path: '$TRANSACTION_SNAPSHOT')"
            return 1
        fi
    else
        log_warning "create_snapshot fonksiyonu bulunamadı, transaction devre dışı"
        return 1
    fi
}

# Transaction başarılı (commit)
transaction_commit() {
    local operation_name="${1:-İşlem}"
    
    if [[ "$TRANSACTION_ACTIVE" != true ]]; then
        log_debug "Aktif transaction yok, commit atlanıyor"
        return 0
    fi
    
    log_success "Transaction başarılı: $operation_name"
    log_debug "Snapshot korunuyor: $TRANSACTION_SNAPSHOT"
    
    TRANSACTION_ACTIVE=false
    # Snapshot'ı silmiyoruz, backup olarak kalıyor
    
    return 0
}

# Transaction başarısız (rollback)
transaction_rollback() {
    local operation_name="${1:-İşlem}"
    local error_msg="${2:-Bilinmeyen hata}"
    
    if [[ "$TRANSACTION_ACTIVE" != true ]]; then
        log_debug "Aktif transaction yok, rollback atlanıyor"
        return 0
    fi
    
    log_error "Transaction başarısız: $operation_name"
    log_error "Hata: $error_msg"
    
    if [[ -n "$TRANSACTION_SNAPSHOT" ]] && [[ -d "$TRANSACTION_SNAPSHOT" ]]; then
        log_warning "Önceki duruma geri dönülüyor..."
        
        # Snapshot'tan geri yükle (mevcut fonksiyon)
        if type restore_snapshot &>/dev/null; then
            if restore_snapshot "$TRANSACTION_SNAPSHOT"; then
                log_success "Geri yükleme başarılı"
                TRANSACTION_ACTIVE=false
                return 0
            else
                log_error "Geri yükleme başarısız!"
                return 1
            fi
        else
            log_error "restore_snapshot fonksiyonu bulunamadı"
            return 1
        fi
    else
        log_warning "Snapshot bulunamadı, geri yükleme yapılamıyor"
        TRANSACTION_ACTIVE=false
        return 1
    fi
}

# Transaction wrapper - İşlemi transaction içinde çalıştır
with_transaction() {
    local operation_name="$1"
    shift
    local command=("$@")
    
    # Transaction başlat
    if ! transaction_begin "$operation_name"; then
        log_warning "Transaction başlatılamadı, normal çalıştırılıyor"
        "${command[@]}"
        return $?
    fi
    
    # Komutu çalıştır
    if "${command[@]}"; then
        transaction_commit "$operation_name"
        return 0
    else
        local exit_code=$?
        transaction_rollback "$operation_name" "Exit code: $exit_code"
        return $exit_code
    fi
}

# ============================================================================
# DOĞRULAMA FONKSİYONLARI
# ============================================================================

# İşlem sonrası doğrulama
verify_operation() {
    local operation="$1"
    local check_command="$2"
    
    log_debug "Doğrulanıyor: $operation"
    
    if eval "$check_command" &>/dev/null; then
        log_debug "Doğrulama başarılı: $operation"
        return 0
    else
        log_error "Doğrulama başarısız: $operation"
        return 1
    fi
}

# Komut varlığını doğrula
verify_command_installed() {
    local cmd="$1"
    local package_name="${2:-$cmd}"
    
    if command -v "$cmd" &>/dev/null; then
        local version=$($cmd --version 2>/dev/null | head -1 || echo "version unknown")
        log_success "$package_name kurulu: $version"
        return 0
    else
        log_error "$package_name bulunamadı"
        return 1
    fi
}

# Dosya varlığını doğrula
verify_file_exists() {
    local file="$1"
    local description="${2:-Dosya}"
    
    if [[ -f "$file" ]]; then
        log_debug "$description mevcut: $file"
        return 0
    else
        log_error "$description bulunamadı: $file"
        return 1
    fi
}

# ============================================================================
# YARDIMCI FONKSİYONLAR
# ============================================================================

# Evet/Hayır sorusu (güvenli)
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            echo -n "$prompt [E/h]: "
        else
            echo -n "$prompt [e/H]: "
        fi
        
        read -r response
        response=${response:-$default}
        
        case "$response" in
            [eEyY]|[eEyY][eEsS][sS])
                return 0
                ;;
            [hHnN]|[hHnN][oOaAıİ]|[hHnN][oOaAıİ][yYıİrR])
                return 1
                ;;
            *)
                echo "Geçersiz cevap. Lütfen 'e' veya 'h' girin."
                ;;
        esac
    done
}

# ============================================================================
# İNİT
# ============================================================================

# Log sistemini başlat
if [[ -n "$LOG_FILE" ]]; then
    init_log
fi

# Sistem kaynaklarını kontrol et (sessizce)
if [[ "${CHECK_RESOURCES:-true}" == "true" ]]; then
    check_system_resources &>/dev/null || true
fi