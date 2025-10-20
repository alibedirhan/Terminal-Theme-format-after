#!/bin/bash

# ============================================================================
# Terminal Setup - Konfigürasyon Yönetimi
# v3.2.9 - Config Module
# ============================================================================
# Bu modül: Config, Update, Backup, Snapshot Yönetimi
# ============================================================================

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