#!/bin/bash

# ============================================================================
# Terminal Setup - Kurulum Fonksiyonları
# v3.2.9 - Core Module (Enhanced & Cross-Platform)
# ============================================================================

# Sudo refresh PID - Global değişken
SUDO_REFRESH_PID=""
MAIN_SHELL_PID=$$  # Ana process PID'yi kaydet (subshell öncesi)

# Sudo cleanup fonksiyonu
cleanup_sudo() {
    if [[ -n "$SUDO_REFRESH_PID" ]] && kill -0 "$SUDO_REFRESH_PID" 2>/dev/null; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null
        wait "$SUDO_REFRESH_PID" 2>/dev/null || true
        log_debug "Sudo refresh process durduruldu (PID: $SUDO_REFRESH_PID)"
        SUDO_REFRESH_PID=""
    fi
}

# Trap ekle
trap cleanup_sudo EXIT ERR INT TERM

# ============================================================================
# CLEAN OUTPUT HELPERS
# ============================================================================

show_section() {
    local step=$1
    local total=$2
    local title=$3
    echo
    echo -e "${CYAN}┌─── KURULUM [${step}/${total}] ────┐${NC}"
    echo -e "${YELLOW}⟳${NC} ${title}..."
}

show_step_success() {
    local message=$1
    echo -e "  ${GREEN}✓${NC} ${message}"
}

show_step_info() {
    local message=$1
    echo -e "  ${CYAN}→${NC} ${message}"
}

show_step_skip() {
    local message=$1
    echo -e "  ${YELLOW}↷${NC} ${message}"
}

# ============================================================================
# VERIFICATION FRAMEWORK
# ============================================================================

verify_command_exists() {
    local cmd=$1
    local tool_name=${2:-$cmd}
    
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        log_error "$tool_name kuruldu ancak komut bulunamıyor: $cmd"
        return 1
    fi
}

verify_command_runs() {
    local cmd=$1
    local tool_name=${2:-$cmd}
    
    if "$cmd" --version &>/dev/null || "$cmd" --help &>/dev/null; then
        return 0
    else
        log_error "$tool_name komutu çalıştırılamıyor!"
        return 1
    fi
}

verify_path_accessible() {
    local path=$1
    local tool_name=$2
    
    if [[ -d "$path" ]] || [[ -f "$path" ]]; then
        return 0
    else
        log_error "$tool_name yolu erişilemiyor: $path"
        return 1
    fi
}

post_install_verify() {
    local tool_name=$1
    local command=$2
    local expected_path=${3:-""}
    
    log_info "Doğrulanıyor: $tool_name..."
    
    # 1. Komut var mı?
    if ! verify_command_exists "$command" "$tool_name"; then
        log_error "❌ $tool_name kurulumu doğrulanamadı (komut bulunamadı)"
        return 1
    fi
    
    # 2. Komut çalışıyor mu?
    if ! verify_command_runs "$command" "$tool_name"; then
        log_error "❌ $tool_name kurulumu doğrulanamadı (komut çalışmıyor)"
        return 1
    fi
    
    # 3. Path kontrolü (opsiyonel)
    if [[ -n "$expected_path" ]]; then
        if ! verify_path_accessible "$expected_path" "$tool_name"; then
            log_warning "⚠ $tool_name kuruldu ancak beklenen yolda değil"
        fi
    fi
    
    # Başarılı - versiyon bilgisini göster
    local version=$("$command" --version 2>/dev/null | head -1 || echo "unknown")
    log_success "✓ $tool_name doğrulandı ($version)"
    return 0
}

show_user_prompt() {
    local title="$1"
    shift
    local messages=("$@")
    
    echo
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}${title}${NC}"
    for msg in "${messages[@]}"; do
        echo -e "${YELLOW}│${NC} ${msg}"
    done
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────┘${NC}"
}

# ============================================================================
# BAĞIMLILIK KONTROLÜ
# ============================================================================

check_dependencies() {
    log_info "Sistem bağımlılıkları kontrol ediliyor..."
    
    local required_commands=("git" "curl" "wget")
    local optional_commands=("gsettings" "fc-cache")
    local missing_required=()
    local missing_optional=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_required+=("$cmd")
            log_error "$cmd eksik (zorunlu)"
        else
            log_debug "$cmd mevcut"
        fi
    done
    
    for cmd in "${optional_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_optional+=("$cmd")
            log_debug "$cmd eksik (opsiyonel)"
        fi
    done
    
    if [ ${#missing_required[@]} -ne 0 ]; then
        show_user_prompt "EKSİK PAKETLER TESPİT EDİLDİ" \
            "Zorunlu: ${missing_required[*]}" \
            ""
        echo -n "Otomatik kurmak ister misiniz? (e/h): "
        read -r install_choice
        
        if [[ "$install_choice" == "e" ]]; then
            echo -e "${CYAN}→${NC} Paketler kuruluyor..."
            
            if ! sudo apt update &>/dev/null; then
                log_error "apt update başarısız"
                diagnose_and_fix "internet_connection"
                return 1
            fi
            
            if ! sudo -E apt install -y -qq "${missing_required[@]}" &>/dev/null; then
                log_error "Paket kurulumu başarısız"
                for pkg in "${missing_required[@]}"; do
                    diagnose_and_fix "package_missing" "$pkg"
                done
                return 1
            fi
            
            echo -e "${GREEN}✓${NC} Eksik paketler kuruldu"
        else
            log_error "Zorunlu paketler olmadan devam edilemez!"
            return 1
        fi
    fi
    
    if [ ${#missing_optional[@]} -ne 0 ]; then
        log_debug "Opsiyonel paketler eksik: ${missing_optional[*]}"
    fi
    
    log_success "Bağımlılık kontrolü tamamlandı"
    return 0
}

# ============================================================================
# SUDO YÖNETİMİ
# ============================================================================

setup_sudo() {
    log_info "Sudo yetkisi kontrol ediliyor..."
    
    if ! sudo -v; then
        log_error "Sudo yetkisi alınamadı"
        diagnose_and_fix "permission_denied" "sudo -v"
        return 1
    fi
    
    log_success "Sudo yetkisi alındı"
    
    # Background sudo refresh process
    # DÜZELTME: Ana process PID'yi kullan
    (
        while true; do
            sleep 50
            sudo -n true 2>/dev/null || exit 1
            kill -0 "$MAIN_SHELL_PID" 2>/dev/null || exit 0
        done
    ) &
    
    SUDO_REFRESH_PID=$!
    log_debug "Sudo refresh başlatıldı (PID: $SUDO_REFRESH_PID)"
    
    return 0
}

# ============================================================================
# YEDEKLEME
# ============================================================================

create_backup() {
    log_info "Mevcut ayarlar yedekleniyor..."
    
    if ! mkdir -p "$BACKUP_DIR"; then
        log_error "Yedek dizini oluşturulamadı: $BACKUP_DIR"
        return 1
    fi
    
    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$BACKUP_DIR/bashrc_$TIMESTAMP"
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$BACKUP_DIR/zshrc_$TIMESTAMP"
    [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$BACKUP_DIR/p10k_$TIMESTAMP"
    [[ -f ~/.tmux.conf ]] && cp ~/.tmux.conf "$BACKUP_DIR/tmux_$TIMESTAMP"
    
    echo "$SHELL" > "$BACKUP_DIR/original_shell_$TIMESTAMP"
    
    if command -v gsettings &> /dev/null; then
        gsettings get org.gnome.Terminal.ProfilesList default > "$BACKUP_DIR/gnome_profile_$TIMESTAMP" 2>/dev/null || true
    fi
    
    log_success "Yedek oluşturuldu: $BACKUP_DIR"
    cleanup_old_backups
    return 0
}

# ============================================================================
# ZSH KURULUMU
# ============================================================================

# Zsh kurulum implementation (reliability wrapper ile)
_install_zsh_impl() {
    log_info "Zsh kuruluyor..."
    
    # Zaten kurulu mu kontrol et
    if command -v zsh &> /dev/null; then
        log_warning "Zsh zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # apt update (retry ile)
    if ! retry_command 3 30 sudo apt update; then
        log_error "apt update başarısız!"
        return 1
    fi
    
    # Zsh kurulumu (retry ile)
    if ! retry_command 3 30 sudo -E apt install -y -qq zsh; then
        log_error "Zsh kurulumu başarısız!"
        return 1
    fi
    
    # Kurulumu doğrula
    if ! verify_command_installed "zsh" "Zsh"; then
        log_error "Zsh kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Zsh kuruldu ve doğrulandı"
    return 0
}

# Zsh kurulum wrapper (transaction ile)
install_zsh() {
    with_transaction "Zsh Kurulumu" _install_zsh_impl
}

# ============================================================================
# OH MY ZSH KURULUMU
# ============================================================================

# Oh My Zsh kurulum implementation (reliability wrapper ile)
_install_oh_my_zsh_impl() {
    log_info "Oh My Zsh kuruluyor..."
    
    # Zaten kurulu mu kontrol et
    if [[ -d ~/.oh-my-zsh ]]; then
        log_warning "Oh My Zsh zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # İnternet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Oh My Zsh kurulumu"; then
            return 1
        fi
        # Retry after network recovery
        if ! check_internet; then
            return 1
        fi
    fi
    
    # Oh My Zsh install script'ini indir ve çalıştır (retry ile)
    local install_script_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    
    # 3 deneme, 120 saniye timeout
    if ! retry_command 3 30 sh -c "$(curl -fsSL $install_script_url)" "" --unattended; then
        log_error "Oh My Zsh kurulumu başarısız!"
        
        # Network hatası olabilir
        if ! check_internet; then
            handle_network_error "Oh My Zsh kurulumu"
        fi
        
        return 1
    fi
    
    # Kurulumu doğrula
    if ! verify_file_exists "$HOME/.oh-my-zsh/oh-my-zsh.sh" "Oh My Zsh"; then
        log_error "Oh My Zsh kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Oh My Zsh kuruldu ve doğrulandı"
    return 0
}

# Oh My Zsh kurulum wrapper (transaction ile)
install_oh_my_zsh() {
    with_transaction "Oh My Zsh Kurulumu" _install_oh_my_zsh_impl
}

# ============================================================================
# FONT KURULUMU
# ============================================================================

install_fonts() {
    log_info "Fontlar kuruluyor..."
    
    if ! command -v fc-cache &> /dev/null; then
        show_step_info "fontconfig paketi kuruluyor..."
        sudo -E apt install -y -qq fontconfig &>/dev/null || {
            log_warning "fontconfig kurulumu başarısız"
        }
    fi
    
    sudo -E apt install -y -qq fonts-powerline &>/dev/null || {
        log_warning "Powerline font kurulumu başarısız, devam ediliyor..."
    }
    
    local FONT_DIR=~/.local/share/fonts
    
    if ! mkdir -p "$FONT_DIR"; then
        log_error "Font dizini oluşturulamadı"
        return 1
    fi
    
    if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
        show_step_info "MesloLGS NF fontları indiriliyor..."
        
        local current_dir=$(pwd)
        if ! cd "$FONT_DIR"; then
            log_error "Font dizinine geçilemedi"
            return 1
        fi
        
        local fonts=(
            "MesloLGS%20NF%20Regular.ttf:MesloLGS NF Regular.ttf"
            "MesloLGS%20NF%20Bold.ttf:MesloLGS NF Bold.ttf"
            "MesloLGS%20NF%20Italic.ttf:MesloLGS NF Italic.ttf"
            "MesloLGS%20NF%20Bold%20Italic.ttf:MesloLGS NF Bold Italic.ttf"
        )
        
        local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
        local success_count=0
        
        for font_pair in "${fonts[@]}"; do
            local url_name="${font_pair%%:*}"
            local file_name="${font_pair##*:}"
            local max_retry=3
            local retry=0
            
            while [ $retry -lt $max_retry ]; do
                # DÜZELTME: HTTPS doğrulama eklendi
                if wget --timeout=15 --tries=2 --https-only -q "$base_url/$url_name" -O "$file_name" 2>/dev/null; then
                    local file_size=$(wc -c < "$file_name" 2>/dev/null | tr -d '[:space:]')
                    if [[ -n "$file_size" ]] && [[ "$file_size" -gt 400000 ]]; then
                        log_debug "$file_name indirildi (${file_size} bytes)"
                        ((success_count++))
                        break
                    else
                        rm -f "$file_name"
                        ((retry++))
                    fi
                else
                    ((retry++))
                fi
                
                if [ $retry -lt $max_retry ]; then
                    sleep 2
                fi
            done
        done
        
        cd "$current_dir" || {
            log_warning "Orijinal dizine geri dönülemedi"
        }
        
        if [ $success_count -gt 0 ]; then
            if command -v fc-cache &> /dev/null; then
                fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            fi
            show_step_success "$success_count font kuruldu"
        else
            log_error "Hiçbir font indirilemedi!"
            show_user_prompt "FONT KURULUMU BAŞARISIZ" \
                "Manuel kurulum: https://github.com/romkatv/powerlevel10k#fonts" \
                ""
            echo -n "Font olmadan devam etmek ister misiniz? (e/h): "
            read -r continue_choice
            if [[ "$continue_choice" != "e" ]]; then
                return 1
            fi
        fi
    else
        show_step_skip "Zaten kurulu, atlandı"
    fi
    
    return 0
}

# ============================================================================
# POWERLEVEL10K KURULUMU
# ============================================================================

# Powerlevel10k kurulum implementation (reliability wrapper ile)
_install_powerlevel10k_impl() {
    log_info "Powerlevel10k kuruluyor..."
    
    # İnternet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Powerlevel10k kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$P10K_DIR" ]]; then
        # Zaten kurulu, güncelle
        show_step_info "Güncelleniyor..."
        local current_dir=$(pwd)
        if cd "$P10K_DIR"; then
            # Git pull ile güncelle (retry ile)
            retry_command 2 60 git pull || log_warning "Güncelleme başarısız"
            cd "$current_dir" || true
        fi
        show_step_success "Tema motoru hazır"
    else
        # Yeni kurulum (safe_git_clone ile)
        if ! safe_git_clone "https://github.com/romkatv/powerlevel10k.git" "$P10K_DIR" 1; then
            log_error "Powerlevel10k klonlama başarısız!"
            
            # Network hatası kontrolü
            if ! check_internet; then
                handle_network_error "Powerlevel10k kurulumu"
            fi
            
            return 1
        fi
        show_step_success "Tema motoru kuruldu"
    fi
    
    # .zshrc dosyasını güncelle
    if [[ -f ~/.zshrc ]]; then
        # DÜZELTME: macOS uyumluluğu
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
        else
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
        fi
    fi
    
    # Kurulumu doğrula
    if ! verify_file_exists "$P10K_DIR/powerlevel10k.zsh-theme" "Powerlevel10k tema dosyası"; then
        log_error "Powerlevel10k kuruldu ancak tema dosyası bulunamadı!"
        return 1
    fi
    
    log_success "Powerlevel10k kuruldu ve doğrulandı"
    return 0
}

# Powerlevel10k kurulum wrapper (transaction ile)
install_powerlevel10k() {
    with_transaction "Powerlevel10k Kurulumu" _install_powerlevel10k_impl
}

# ============================================================================
# PLUGİNLER
# ============================================================================

# Plugin kurulum implementation (reliability wrapper ile)
_install_plugins_impl() {
    log_info "Pluginler kuruluyor..."
    
    # İnternet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Plugin kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local install_errors=0
    
    # Plugin 1: zsh-autosuggestions
    if [[ ! -d "$CUSTOM/plugins/zsh-autosuggestions" ]]; then
        if safe_git_clone "https://github.com/zsh-users/zsh-autosuggestions" "$CUSTOM/plugins/zsh-autosuggestions" 1; then
            show_step_success "zsh-autosuggestions"
        else
            log_warning "zsh-autosuggestions kurulumu başarısız"
            ((install_errors++))
        fi
    else
        show_step_skip "zsh-autosuggestions zaten kurulu"
    fi
    
    # Plugin 2: zsh-syntax-highlighting
    if [[ ! -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        if safe_git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$CUSTOM/plugins/zsh-syntax-highlighting" 1; then
            show_step_success "zsh-syntax-highlighting"
        else
            log_warning "zsh-syntax-highlighting kurulumu başarısız"
            ((install_errors++))
        fi
    else
        show_step_skip "zsh-syntax-highlighting zaten kurulu"
    fi
    
    # .zshrc dosyasını güncelle
    if [[ -f ~/.zshrc ]]; then
        # DÜZELTME: macOS uyumluluğu
        if grep -q "^plugins=(" ~/.zshrc; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)/' ~/.zshrc
            else
                sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)/' ~/.zshrc
            fi
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)' >> ~/.zshrc
        fi
    fi
    
    # Sonuç kontrolü
    if [ $install_errors -eq 0 ]; then
        log_success "Tüm pluginler kuruldu ve doğrulandı"
        return 0
    elif [ $install_errors -lt 2 ]; then
        log_warning "Bazı pluginler kurulamadı ($install_errors hata), ancak devam ediliyor"
        return 0  # Partial success - devam et
    else
        log_error "Hiçbir plugin kurulamadı!"
        return 1
    fi
}

# Plugin kurulum wrapper (transaction YOK - çünkü partial success kabul edilebilir)
install_plugins() {
    _install_plugins_impl
}

# ============================================================================
# TERMİNAL ARAÇLARI
# ============================================================================

