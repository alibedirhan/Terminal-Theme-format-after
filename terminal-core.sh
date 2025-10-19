#!/bin/bash

# ============================================================================
# Terminal Setup - Kurulum Fonksiyonları
# v3.2.8 - Core Module (Enhanced & Cross-Platform)
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
            
            if ! sudo apt install -y "${missing_required[@]}" &>/dev/null; then
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
    if ! retry_command 3 60 sudo apt update; then
        log_error "apt update başarısız!"
        return 1
    fi
    
    # Zsh kurulumu (retry ile)
    if ! retry_command 3 120 sudo apt install -y zsh; then
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
    if ! retry_command 3 120 sh -c "$(curl -fsSL $install_script_url)" "" --unattended; then
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
        sudo apt install -y fontconfig &>/dev/null || {
            log_warning "fontconfig kurulumu başarısız"
        }
    fi
    
    sudo apt install -y fonts-powerline &>/dev/null || {
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

install_fzf() {
    log_info "FZF kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v fzf &> /dev/null; then
        log_warning "FZF zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # İnternet kontrolü + recovery
    if ! check_internet; then
        if ! handle_network_error "FZF kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    # Clone repository (safe_git_clone ile)
    if [[ ! -d ~/.fzf ]]; then
        if ! safe_git_clone "https://github.com/junegunn/fzf.git" ~/.fzf 1; then
            log_error "FZF klonlama başarısız!"
            return 1
        fi
    fi
    
    # Install (retry ile)
    if ! retry_command 3 60 ~/.fzf/install --all --no-bash --no-fish; then
        log_error "FZF kurulumu başarısız!"
        return 1
    fi
    
    # PATH'e ekle
    export PATH="$HOME/.fzf/bin:$PATH"
    
    # Doğrulama
    if ! verify_command_installed "fzf" "FZF"; then
        log_error "FZF kuruldu ancak doğrulanamadı!"
        log_warning "~/.zshrc dosyasını yeniden yükleyin: source ~/.zshrc"
        return 1
    fi
    
    # Çalışma testi
    if ! fzf --version &>/dev/null; then
        log_error "FZF binary'si çalışmıyor!"
        return 1
    fi
    
    log_success "FZF kuruldu ve doğrulandı ($(fzf --version))"
    return 0
}

install_zoxide() {
    log_info "Zoxide kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v zoxide &> /dev/null; then
        log_warning "Zoxide zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # İnternet kontrolü + recovery
    if ! check_internet; then
        if ! handle_network_error "Zoxide kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    # Kurulum scripti (retry ile)
    local install_cmd='curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash'
    if ! retry_command 3 120 bash -c "$install_cmd"; then
        log_error "Zoxide kurulumu başarısız!"
        return 1
    fi
    
    # PATH'i .zshrc'ye ekle
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
            sed -i '/# Enable Powerlevel10k instant prompt/i export PATH="$HOME/.local/bin:$PATH"\n' ~/.zshrc
        fi
        
        if ! grep -q "zoxide init zsh" ~/.zshrc; then
            {
                echo ''
                echo '# Zoxide initialization'
                echo 'eval "$(zoxide init zsh)"'
            } >> ~/.zshrc
        fi
    fi
    
    # PATH'e ekle
    export PATH="$HOME/.local/bin:$PATH"
    
    # Doğrulama
    if ! verify_command_installed "zoxide" "Zoxide"; then
        log_error "Zoxide kuruldu ancak PATH'te bulunamıyor!"
        log_warning 'Manuel çözüm: export PATH="$HOME/.local/bin:$PATH"'
        return 1
    fi
    
    # Çalışma testi
    if ! zoxide --version &>/dev/null; then
        log_error "Zoxide kuruldu ancak çalıştırılamıyor!"
        return 1
    fi
    
    log_success "Zoxide kuruldu ve doğrulandı ($(zoxide --version))"
    return 0
}

install_exa() {
    log_info "Exa/Eza kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v eza &> /dev/null; then
        log_warning "Eza zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if command -v exa &> /dev/null; then
        log_warning "Exa zaten kurulu, atlanıyor..."
        return 0
    fi
    
    local cmd=""
    
    # Önce eza paketini dene (Ubuntu 24.04+)
    if retry_command 3 60 sudo apt install -y eza; then
        cmd="eza"
    else
        # Apt'den kurulamadı, GitHub'dan indir
        log_info "Apt'den kurulamadı, GitHub'dan indiriliyor..."
        
        # İnternet kontrolü
        if ! check_internet; then
            if ! handle_network_error "Eza kurulumu"; then
                return 1
            fi
        fi
        
        # Latest release version al (retry ile)
        local EZA_VERSION=$(retry_command 3 30 bash -c 'curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po "\"tag_name\": \"v\K[^\"]*"')
        
        if [[ -z "$EZA_VERSION" ]]; then
            log_error "Eza versiyonu alınamadı!"
            return 1
        fi
        
        # Binary indir (safe_download ile)
        if ! safe_download "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" "eza.tar.gz" "Eza binary indiriliyor"; then
            log_error "Eza indirilemedi!"
            return 1
        fi
        
        # Extract ve kur
        tar xf eza.tar.gz &>/dev/null
        sudo install -m 755 eza /usr/local/bin/ &>/dev/null
        rm -f eza eza.tar.gz &>/dev/null
        
        cmd="eza"
    fi
    
    # Alias'ları ekle
    if [[ -f ~/.zshrc ]] && ! grep -q "alias ls=" ~/.zshrc; then
        {
            echo ''
            echo '# Eza/Exa aliases'
            echo "alias ls=\"$cmd --icons\""
            echo "alias ll=\"$cmd -l --icons\""
            echo "alias la=\"$cmd -la --icons\""
            echo "alias lt=\"$cmd --tree --icons\""
        } >> ~/.zshrc
    fi
    
    # Doğrulama
    if ! verify_command_installed "$cmd" "Eza"; then
        log_error "Eza kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Eza kuruldu ve doğrulandı"
    return 0
}

install_bat() {
    log_info "Bat kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v batcat &> /dev/null || command -v bat &> /dev/null; then
        log_warning "Bat zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y bat; then
        log_error "Bat kurulumu başarısız!"
        return 1
    fi
    
    # Alias ekle
    if [[ -f ~/.zshrc ]] && ! grep -q "alias cat=" ~/.zshrc; then
        {
            echo ''
            echo '# Bat alias'
            echo 'alias cat="batcat"'
        } >> ~/.zshrc
    fi
    
    # Doğrulama
    if ! verify_command_installed "batcat" "Bat"; then
        log_error "Bat kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Bat kuruldu ve doğrulandı"
    return 0
}

# ============================================================================
# GELİŞMİŞ ARAMA ARAÇLARI
# ============================================================================

install_ripgrep() {
    log_info "Ripgrep kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v rg &> /dev/null; then
        log_warning "Ripgrep zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y ripgrep; then
        log_error "Ripgrep kurulumu başarısız!"
        return 1
    fi
    
    # Config ekle
    if [[ -f ~/.zshrc ]] && ! grep -q "RIPGREP_CONFIG_PATH" ~/.zshrc; then
        {
            echo ''
            echo '# Ripgrep configuration'
            echo 'export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"'
        } >> ~/.zshrc
        
        cat > ~/.ripgreprc << 'EOF'
--max-columns=150
--max-columns-preview
--smart-case
--colors=line:none
--colors=line:style:bold
EOF
    fi
    
    # Doğrulama
    if ! verify_command_installed "rg" "Ripgrep"; then
        log_error "Ripgrep kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Ripgrep kuruldu ve doğrulandı"
    return 0
}

install_fd() {
    log_info "Fd kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
        log_warning "Fd zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y fd-find; then
        log_error "Fd kurulumu başarısız!"
        return 1
    fi
    
    # Ubuntu alias
    if [[ -f ~/.zshrc ]] && ! grep -q "alias fd=" ~/.zshrc; then
        {
            echo ''
            echo '# Fd alias (Ubuntu compatibility)'
            echo 'alias fd="fdfind"'
        } >> ~/.zshrc
    fi
    
    # FZF integration
    if [[ -f ~/.zshrc ]] && ! grep -q "FZF_DEFAULT_COMMAND.*fd" ~/.zshrc; then
        {
            echo ''
            echo '# FZF + fd integration'
            echo 'export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git"'
            echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"'
        } >> ~/.zshrc
    fi
    
    # Doğrulama
    if ! verify_command_installed "fdfind" "Fd"; then
        log_error "Fd kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Fd kuruldu ve doğrulandı"
    return 0
}

# ============================================================================
# GIT ARAÇLARI
# ============================================================================

install_delta() {
    log_info "Delta (git diff) kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v delta &> /dev/null; then
        log_warning "Delta zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Önce apt'den dene (retry ile)
    if retry_command 3 60 sudo apt install -y git-delta; then
        log_success "Delta apt'den kuruldu"
    else
        # Apt başarısız, cargo ile dene
        log_info "Apt'den kurulamadı, Cargo ile deneniyor..."
        
        # Internet kontrolü
        if ! check_internet; then
            if ! handle_network_error "Delta kurulumu"; then
                return 1
            fi
        fi
        
        # Cargo kontrolü
        if ! command -v cargo &> /dev/null; then
            log_info "Cargo (Rust) kuruluyor (Delta için gerekli)..."
            echo -e "${YELLOW}Bu işlem 2-3 dakika sürebilir, lütfen bekleyin...${NC}"
            
            # Rustup kurulum (retry ile)
            if ! retry_command 2 180 bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'; then
                log_error "Cargo kurulumu başarısız!"
                return 1
            fi
            
            # Cargo env yükle
            if [[ -f "$HOME/.cargo/env" ]]; then
                source "$HOME/.cargo/env"
            else
                log_error "Cargo env dosyası bulunamadı!"
                return 1
            fi
        fi
        
        # Delta kurulum
        log_info "Delta cargo ile kuruluyor (2-3 dakika sürebilir)..."
        echo -e "${YELLOW}Lütfen bekleyin, derleme yapılıyor...${NC}"
        
        if ! retry_command 2 300 cargo install git-delta; then
            log_error "Delta kurulumu başarısız!"
            log_warning "Alternatif: 'cargo install git-delta' manuel çalıştırın"
            return 1
        fi
    fi
    
    # Doğrulama
    if ! verify_command_installed "delta" "Delta"; then
        log_error "Delta kuruldu ama doğrulanamadı!"
        return 1
    fi
    
    # Git config
    git config --global core.pager "delta" 2>/dev/null
    git config --global interactive.diffFilter "delta --color-only" 2>/dev/null
    git config --global delta.navigate true 2>/dev/null
    git config --global delta.side-by-side true 2>/dev/null
    git config --global merge.conflictstyle "diff3" 2>/dev/null
    git config --global diff.colorMoved "default" 2>/dev/null
    
    log_success "Delta kuruldu ve git ile entegre edildi"
    return 0
}

install_lazygit() {
    log_info "Lazygit kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v lazygit &> /dev/null; then
        log_warning "Lazygit zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Internet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Lazygit kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    # Version al (retry ile)
    local LAZYGIT_VERSION=$(retry_command 3 30 bash -c 'curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po "\"tag_name\": \"v\K[^\"]*"')
    
    if [[ -z "$LAZYGIT_VERSION" ]]; then
        log_error "Lazygit versiyonu alınamadı!"
        return 1
    fi
    
    # Binary indir (safe_download ile)
    if ! safe_download "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" "lazygit.tar.gz" "Lazygit indiriliyor"; then
        log_error "Lazygit indirilemedi!"
        return 1
    fi
    
    # Extract ve kur
    tar xf lazygit.tar.gz lazygit &>/dev/null
    sudo install lazygit /usr/local/bin &>/dev/null
    rm -f lazygit lazygit.tar.gz &>/dev/null
    
    # Doğrulama
    if ! verify_command_installed "lazygit" "Lazygit"; then
        log_error "Lazygit kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Lazygit kuruldu ve doğrulandı"
    return 0
}

# ============================================================================
# DÖKÜMANTASYON VE YARDIM ARAÇLARI
# ============================================================================

install_tldr() {
    log_info "TLDR kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v tldr &> /dev/null; then
        log_warning "TLDR zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y tldr; then
        log_error "TLDR kurulumu başarısız!"
        return 1
    fi
    
    # İlk cache update (retry ile)
    retry_command 2 30 tldr --update || true
    
    # Doğrulama
    if ! verify_command_installed "tldr" "TLDR"; then
        log_error "TLDR kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "TLDR kuruldu ve doğrulandı"
    return 0
}

# ============================================================================
# SİSTEM İZLEME ARAÇLARI  
# ============================================================================

install_btop() {
    log_info "Btop++ kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v btop &> /dev/null; then
        log_warning "Btop zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y btop; then
        log_error "Btop kurulumu başarısız!"
        return 1
    fi
    
    # Doğrulama
    if ! verify_command_installed "btop" "Btop"; then
        log_error "Btop kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Btop kuruldu ve doğrulandı"
    return 0
}

install_dust() {
    log_info "Dust kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v dust &> /dev/null; then
        log_warning "Dust zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Önce apt'den dene (retry ile)
    if retry_command 3 60 sudo apt install -y du-dust; then
        if verify_command_installed "dust" "Dust"; then
            log_success "Dust apt'den kuruldu ve doğrulandı"
            return 0
        fi
    fi
    
    # Apt başarısız, GitHub'dan indir
    log_info "Apt'den kurulamadı, GitHub'dan indiriliyor..."
    
    # Internet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Dust kurulumu"; then
            return 1
        fi
    fi
    
    # Version al (retry ile)
    local DUST_VERSION=$(retry_command 3 30 bash -c 'curl -s "https://api.github.com/repos/bootandy/dust/releases/latest" | grep -Po "\"tag_name\": \"v\K[^\"]*"')
    
    if [[ -z "$DUST_VERSION" ]]; then
        log_error "Dust versiyonu alınamadı!"
        return 1
    fi
    
    # Binary indir (safe_download ile)
    if ! safe_download "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz" "dust.tar.gz" "Dust indiriliyor"; then
        log_error "Dust indirilemedi!"
        return 1
    fi
    
    # Extract ve kur
    tar xf dust.tar.gz &>/dev/null
    local dust_bin=$(find . -name "dust" -type f 2>/dev/null | head -1)
    
    if [[ -n "$dust_bin" ]]; then
        sudo install -m 755 "$dust_bin" /usr/local/bin/dust &>/dev/null
        rm -rf dust.tar.gz dust-* &>/dev/null
        
        # Doğrulama
        if ! verify_command_installed "dust" "Dust"; then
            log_error "Dust kuruldu ancak doğrulanamadı!"
            return 1
        fi
        
        log_success "Dust kuruldu ve doğrulandı"
        return 0
    else
        log_error "Dust binary'si bulunamadı!"
        rm -f dust.tar.gz &>/dev/null
        return 1
    fi
}

install_duf() {
    log_info "Duf kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v duf &> /dev/null; then
        log_warning "Duf zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 60 sudo apt install -y duf; then
        log_error "Duf kurulumu başarısız!"
        return 1
    fi
    
    # Doğrulama
    if ! verify_command_installed "duf" "Duf"; then
        log_error "Duf kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Duf kuruldu ve doğrulandı"
    return 0
}

install_procs() {
    log_info "Procs kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v procs &> /dev/null; then
        log_warning "Procs zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Snap kontrolü
    if ! command -v snap &> /dev/null; then
        log_error "Snap bulunamadı, Procs kurulamadı"
        return 1
    fi
    
    # Kurulum (retry ile)
    if ! retry_command 3 120 sudo snap install procs; then
        log_error "Procs kurulumu başarısız!"
        return 1
    fi
    
    # Doğrulama
    if ! verify_command_installed "procs" "Procs"; then
        log_error "Procs kuruldu ancak doğrulanamadı!"
        return 1
    fi
    
    log_success "Procs kuruldu ve doğrulandı"
    return 0
}

# ============================================================================
# HISTORY VE KOMUT ARAMA
# ============================================================================

install_atuin() {
    log_info "Atuin kuruluyor..."
    
    # Zaten kurulu mu?
    if command -v atuin &> /dev/null; then
        log_warning "Atuin zaten kurulu, atlanıyor..."
        return 0
    fi
    
    # Internet kontrolü
    if ! check_internet; then
        if ! handle_network_error "Atuin kurulumu"; then
            return 1
        fi
        if ! check_internet; then
            return 1
        fi
    fi
    
    # Installer çalıştır (retry ile)
    if ! retry_command 3 120 bash -c 'bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)'; then
        log_error "Atuin kurulumu başarısız!"
        return 1
    fi
    
    # PATH ve init ekle
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q 'export PATH="$HOME/.atuin/bin:$PATH"' ~/.zshrc && [[ -d "$HOME/.atuin/bin" ]]; then
            sed -i '/# Enable Powerlevel10k instant prompt/i export PATH="$HOME/.atuin/bin:$PATH"\n' ~/.zshrc
        fi
        
        if ! grep -q "atuin init zsh" ~/.zshrc; then
            {
                echo ''
                echo '# Atuin shell history'
                echo 'eval "$(atuin init zsh)"'
            } >> ~/.zshrc
        fi
    fi
    
    # PATH'e ekle
    export PATH="$HOME/.atuin/bin:$PATH"
    
    # Doğrulama
    if ! verify_command_installed "atuin" "Atuin"; then
        log_error "Atuin kuruldu ancak PATH'te bulunamıyor!"
        log_warning 'Manuel çözüm: export PATH="$HOME/.atuin/bin:$PATH"'
        return 1
    fi
    
    # Çalışma testi
    if ! atuin --version &>/dev/null; then
        log_error "Atuin kuruldu ancak çalıştırılamıyor!"
        return 1
    fi
    
    log_success "Atuin kuruldu ve doğrulandı ($(atuin --version))"
    return 0
}

# ============================================================================
# TOPLU KURULUM FONKSİYONLARI
# ============================================================================

install_all_tools() {
    log_info "Terminal araçları kuruluyor..."
    
    local total_tools=4
    local current_tool=0
    local errors=0
    
    show_progress $((++current_tool)) $total_tools "FZF kuruluyor"
    install_fzf || ((errors++))
    
    show_progress $((++current_tool)) $total_tools "Zoxide kuruluyor"
    install_zoxide || ((errors++))
    
    show_progress $((++current_tool)) $total_tools "Exa kuruluyor"
    install_exa || ((errors++))
    
    show_progress $((++current_tool)) $total_tools "Bat kuruluyor"
    install_bat || ((errors++))
    
    if [ $errors -eq 0 ]; then
        log_success "Tüm araçlar kuruldu"
        return 0
    else
        log_warning "$errors araç kurulamadı"
        return 1
    fi
}

install_all_tools_complete() {
    log_info "TÜM terminal araçları kuruluyor (14 araç)..."
    echo
    
    local total_tools=14
    local current_tool=0
    local errors=0
    
    # Temel Araçlar (4)
    show_section $((++current_tool)) $total_tools "FZF kuruluyor"
    install_fzf || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Zoxide kuruluyor"
    install_zoxide || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Exa kuruluyor"
    install_exa || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Bat kuruluyor"
    install_bat || ((errors++))
    
    # Arama Araçları (2)
    show_section $((++current_tool)) $total_tools "Ripgrep kuruluyor"
    install_ripgrep || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Fd kuruluyor"
    install_fd || ((errors++))
    
    # Git Araçları (2)
    show_section $((++current_tool)) $total_tools "Delta kuruluyor"
    install_delta || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Lazygit kuruluyor"
    install_lazygit || ((errors++))
    
    # Sistem Araçları (4)
    show_section $((++current_tool)) $total_tools "Btop kuruluyor"
    install_btop || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Dust kuruluyor"
    install_dust || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Duf kuruluyor"
    install_duf || ((errors++))
    
    show_section $((++current_tool)) $total_tools "Procs kuruluyor"
    install_procs || ((errors++))
    
    # Ekstra Araçlar (2)
    show_section $((++current_tool)) $total_tools "Atuin kuruluyor"
    install_atuin || ((errors++))
    
    show_section $((++current_tool)) $total_tools "TLDR kuruluyor"
    install_tldr || ((errors++))
    
    echo
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    
    if [ $errors -eq 0 ]; then
        log_success "Tüm 14 araç başarıyla kuruldu! 🎉"
        echo
        echo -e "${GREEN}Kurulu Araçlar:${NC}"
        echo -e "  ${CYAN}Temel:${NC} fzf, zoxide, exa, bat"
        echo -e "  ${CYAN}Arama:${NC} ripgrep, fd"
        echo -e "  ${CYAN}Git:${NC} delta, lazygit"
        echo -e "  ${CYAN}Sistem:${NC} btop, dust, duf, procs"
        echo -e "  ${CYAN}Ekstra:${NC} atuin, tldr"
        return 0
    else
        log_warning "$errors araç kurulamadı, geri kalan $((14 - errors)) araç başarılı"
        return 1
    fi
}

install_search_tools() {
    log_info "Arama araçları kuruluyor..."
    
    local errors=0
    
    show_step_info "Ripgrep kuruluyor..."
    install_ripgrep || ((errors++))
    
    show_step_info "Fd kuruluyor..."
    install_fd || ((errors++))
    
    if [ $errors -eq 0 ]; then
        log_success "Arama araçları kuruldu"
        return 0
    else
        log_warning "$errors araç kurulamadı"
        return 1
    fi
}

install_git_tools() {
    log_info "Git araçları kuruluyor..."
    
    local errors=0
    
    show_step_info "Delta kuruluyor..."
    install_delta || ((errors++))
    
    show_step_info "Lazygit kuruluyor..."
    install_lazygit || ((errors++))
    
    if [ $errors -eq 0 ]; then
        log_success "Git araçları kuruldu"
        return 0
    else
        log_warning "$errors araç kurulamadı"
        return 1
    fi
}

install_system_tools() {
    log_info "Sistem araçları kuruluyor..."
    
    local errors=0
    
    show_step_info "Btop kuruluyor..."
    install_btop || ((errors++))
    
    show_step_info "Dust kuruluyor..."
    install_dust || ((errors++))
    
    show_step_info "Duf kuruluyor..."
    install_duf || ((errors++))
    
    show_step_info "Procs kuruluyor..."
    install_procs || ((errors++))
    
    if [ $errors -eq 0 ]; then
        log_success "Sistem araçları kuruldu"
        return 0
    else
        log_warning "$errors araç kurulamadı"
        return 1
    fi
}

install_extra_tools() {
    log_info "Ekstra araçlar kuruluyor..."
    
    local errors=0
    
    show_step_info "Atuin kuruluyor..."
    install_atuin || ((errors++))
    
    show_step_info "TLDR kuruluyor..."
    install_tldr || ((errors++))
    
    if [ $errors -eq 0 ]; then
        log_success "Ekstra araçlar kuruldu"
        return 0
    else
        log_warning "$errors araç kurulamadı"
        return 1
    fi
}

# ============================================================================
# TMUX
# ============================================================================

install_tmux() {
    log_info "Tmux kuruluyor..."
    
    if command -v tmux &> /dev/null; then
        log_warning "Tmux zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! sudo apt install -y tmux &>/dev/null; then
        log_error "Tmux kurulumu başarısız!"
        return 1
    fi
    
    log_success "Tmux kuruldu"
    return 0
}

configure_tmux_theme() {
    local theme=$1
    log_info "Tmux için $theme teması yapılandırılıyor..."
    
    local tmux_conf="$HOME/.tmux.conf"
    
    if [[ -f "$tmux_conf" ]]; then
        local backup_name="${tmux_conf}.backup_$(date +%Y%m%d_%H%M%S)"
        cp "$tmux_conf" "$backup_name"
        log_debug "Mevcut tmux.conf yedeklendi: $backup_name"
    fi
    
    cat > "$tmux_conf" << 'EOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix
set -g mouse on
set -g default-terminal "screen-256color"
set -g base-index 1
setw -g pane-base-index 1
set -sg escape-time 0
set -g history-limit 10000
set -g renumber-windows on

EOF
    
    case $theme in
        dracula) get_tmux_theme_dracula >> "$tmux_conf" ;;
        nord) get_tmux_theme_nord >> "$tmux_conf" ;;
        gruvbox) get_tmux_theme_gruvbox >> "$tmux_conf" ;;
        tokyo-night) get_tmux_theme_tokyo_night >> "$tmux_conf" ;;
        catppuccin) get_tmux_theme_catppuccin >> "$tmux_conf" ;;
        one-dark) get_tmux_theme_one_dark >> "$tmux_conf" ;;
        solarized) get_tmux_theme_solarized >> "$tmux_conf" ;;
    esac
    
    cat >> "$tmux_conf" << 'EOF'

set -g status-left-length 40
set -g status-left "#[bold] Session: #S "
set -g status-right "#[bold] %d %b %Y | %H:%M "
set -g status-justify centre
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
EOF
    
    log_success "Tmux tema konfigürasyonu tamamlandı"
    return 0
}

install_tmux_with_theme() {
    local theme=$1
    install_tmux || return 1
    configure_tmux_theme "$theme" || return 1
    log_info "Tmux'u test etmek için: tmux"
    return 0
}

# ============================================================================
# TEMA KURULUMU
# ============================================================================

install_theme() {
    local theme_name=$1
    log_info "Tema kuruluyor: $theme_name"
    
    local terminal=$(detect_terminal)
    log_debug "Tespit edilen terminal: $terminal"
    
    case $terminal in
        gnome-terminal) install_theme_gnome "$theme_name" ;;
        kitty) install_theme_kitty "$theme_name" ;;
        alacritty) install_theme_alacritty "$theme_name" ;;
        *)
            log_warning "Terminal tipi desteklenmiyor: $terminal"
            return 1
            ;;
    esac
}

install_theme_gnome() {
    local theme=$1
    
    if ! check_gnome_terminal; then
        return 1
    fi
    
    local PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE" ]]; then
        log_error "Terminal profili bulunamadı"
        return 1
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
    
    case $theme in
        dracula) apply_dracula_gnome "$PROFILE_PATH" ;;
        nord) apply_nord_gnome "$PROFILE_PATH" ;;
        gruvbox) apply_gruvbox_gnome "$PROFILE_PATH" ;;
        tokyo-night) apply_tokyo_night_gnome "$PROFILE_PATH" ;;
        catppuccin) apply_catppuccin_gnome "$PROFILE_PATH" ;;
        one-dark) apply_one_dark_gnome "$PROFILE_PATH" ;;
        solarized) apply_solarized_gnome "$PROFILE_PATH" ;;
        *) log_error "Bilinmeyen tema: $theme"; return 1 ;;
    esac
    
    return 0
}

install_theme_kitty() {
    local theme=$1
    
    if ! command -v kitty &> /dev/null; then
        log_warning "Kitty terminal bulunamadı"
        return 1
    fi
    
    local kitty_conf="$HOME/.config/kitty/kitty.conf"
    local theme_dir="$HOME/.config/kitty/themes"
    
    if ! mkdir -p "$theme_dir"; then
        log_error "Tema dizini oluşturulamadı"
        return 1
    fi
    
    # DÜZELTME: macOS uyumluluğu
    if [[ -f "$kitty_conf" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/^include themes\//d' "$kitty_conf"
        else
            sed -i '/^include themes\//d' "$kitty_conf"
        fi
    else
        touch "$kitty_conf"
    fi
    
    case $theme in
        dracula)
            get_kitty_theme_dracula > "$theme_dir/dracula.conf"
            echo "include themes/dracula.conf" >> "$kitty_conf"
            ;;
        nord)
            get_kitty_theme_nord > "$theme_dir/nord.conf"
            echo "include themes/nord.conf" >> "$kitty_conf"
            ;;
        gruvbox)
            get_kitty_theme_gruvbox > "$theme_dir/gruvbox.conf"
            echo "include themes/gruvbox.conf" >> "$kitty_conf"
            ;;
        tokyo-night)
            get_kitty_theme_tokyo_night > "$theme_dir/tokyo-night.conf"
            echo "include themes/tokyo-night.conf" >> "$kitty_conf"
            ;;
        catppuccin)
            get_kitty_theme_catppuccin > "$theme_dir/catppuccin.conf"
            echo "include themes/catppuccin.conf" >> "$kitty_conf"
            ;;
        one-dark)
            get_kitty_theme_one_dark > "$theme_dir/one-dark.conf"
            echo "include themes/one-dark.conf" >> "$kitty_conf"
            ;;
        solarized)
            get_kitty_theme_solarized > "$theme_dir/solarized.conf"
            echo "include themes/solarized.conf" >> "$kitty_conf"
            ;;
    esac
    
    log_success "Kitty için $theme teması kuruldu"
    return 0
}

install_theme_alacritty() {
    local theme=$1
    
    if ! command -v alacritty &> /dev/null; then
        log_warning "Alacritty terminal bulunamadı"
        return 1
    fi
    
    local alacritty_conf="$HOME/.config/alacritty/alacritty.yml"
    
    if ! mkdir -p "$(dirname "$alacritty_conf")"; then
        log_error "Alacritty config dizini oluşturulamadı"
        return 1
    fi
    
    # DÜZELTME: macOS uyumluluğu
    if [[ -f "$alacritty_conf" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/^colors:/,/^[^ ]/{ /^colors:/d; /^[^ ]/!d }' "$alacritty_conf"
        else
            sed -i '/^colors:/,/^[^ ]/{ /^colors:/d; /^[^ ]/!d }' "$alacritty_conf"
        fi
    fi
    
    case $theme in
        dracula) get_alacritty_theme_dracula >> "$alacritty_conf" ;;
        nord) get_alacritty_theme_nord >> "$alacritty_conf" ;;
        gruvbox) get_alacritty_theme_gruvbox >> "$alacritty_conf" ;;
        tokyo-night) get_alacritty_theme_tokyo_night >> "$alacritty_conf" ;;
        catppuccin) get_alacritty_theme_catppuccin >> "$alacritty_conf" ;;
        one-dark) get_alacritty_theme_one_dark >> "$alacritty_conf" ;;
        solarized) get_alacritty_theme_solarized >> "$alacritty_conf" ;;
    esac
    
    log_success "Alacritty için $theme teması kuruldu"
    return 0
}

# ============================================================================
# BASH ALIASES MİGRASYONU
# ============================================================================

migrate_bash_aliases() {
    log_info "Bash aliases kontrolü yapılıyor..."
    
    local aliases_files=("$HOME/.aliases" "$HOME/.bash_aliases")
    local found_aliases=false
    
    for alias_file in "${aliases_files[@]}"; do
        if [[ -f "$alias_file" ]]; then
            show_step_success "Bulundu: $alias_file"
            found_aliases=true
            
            local alias_basename
            alias_basename=$(basename "$alias_file")
            
            # DÜZELTME: File check eklendi
            if [[ -f ~/.zshrc ]] && grep -q "source.*${alias_basename}" ~/.zshrc 2>/dev/null; then
                show_step_skip "${alias_basename} zaten .zshrc içinde tanımlı"
            else
                show_user_prompt "BASH ALIASES BULUNDU" \
                    "$alias_file dosyanız mevcut." \
                    "Zsh'de de kullanmak ister misiniz?" \
                    ""
                echo -n "Eklemek için (e/h): "
                read -r add_aliases
                
                if [[ "$add_aliases" == "e" ]]; then
                    {
                        echo ""
                        echo "# Bash aliases compatibility"
                        echo "if [[ -f $alias_file ]]; then"
                        echo "    source $alias_file"
                        echo "fi"
                    } >> ~/.zshrc
                    
                    show_step_success "$alias_file .zshrc'ye eklendi"
                else
                    show_step_skip "Atlandı"
                fi
            fi
        fi
    done
    
    if ! $found_aliases; then
        log_debug "Bash aliases dosyası bulunamadı"
    fi
    
    return 0
}

# ============================================================================
# SHELL DEĞİŞTİRME
# ============================================================================

configure_gnome_terminal_login_shell() {
    if ! command -v gsettings &> /dev/null; then
        log_debug "gsettings bulunamadı, GNOME Terminal ayarı atlanıyor"
        return 0
    fi
    
    log_info "GNOME Terminal login shell ayarı yapılıyor..."
    
    local PROFILE_ID
    PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE_ID" ]]; then
        log_debug "GNOME Terminal profili bulunamadı"
        return 0
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"
    
    local current_setting
    current_setting=$(gsettings get "$PROFILE_PATH" login-shell 2>/dev/null)
    
    if [[ "$current_setting" == "true" ]]; then
        log_success "GNOME Terminal zaten login shell modunda"
    else
        if gsettings set "$PROFILE_PATH" login-shell true 2>/dev/null; then
            log_success "GNOME Terminal login shell olarak ayarlandı"
        else
            log_warning "GNOME Terminal ayarı yapılamadı"
            return 1
        fi
    fi
    
    return 0
}

# Shell değiştirme implementation (reliability wrapper ile)
_change_default_shell_impl() {
    log_info "Varsayılan shell Zsh olarak ayarlanıyor..."
    
    # Zsh yolunu bul
    local ZSH_PATH
    ZSH_PATH=$(which zsh 2>/dev/null)
    
    if [[ -z "$ZSH_PATH" ]]; then
        log_error "Zsh bulunamadı!"
        return 1
    fi
    
    # Doğrula: Zsh gerçekten kurulu mu?
    if ! verify_command_installed "zsh" "Zsh"; then
        log_error "Zsh kurulu değil!"
        return 1
    fi
    
    # Mevcut shell'i kontrol et
    local CURRENT_SHELL
    CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
    
    if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
        show_step_skip "Zaten Zsh aktif"
        configure_gnome_terminal_login_shell
        return 0
    fi
    
    show_step_info "Shell değiştiriliyor: $CURRENT_SHELL → $ZSH_PATH"
    
    # chsh komutu ile shell değiştir
    if chsh -s "$ZSH_PATH" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
        show_step_success "Sistem shell'i Zsh olarak ayarlandı"
        
        # Doğrulama: Gerçekten değişti mi?
        local NEW_SHELL
        NEW_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
        
        if [[ "$NEW_SHELL" != "$ZSH_PATH" ]]; then
            # Başarısız, sudo ile dene
            show_step_info "sudo ile deneniyor..."
            
            if ! sudo chsh -s "$ZSH_PATH" "$USER" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                log_error "Shell değiştirilemedi"
                
                # Permission hatası olabilir
                if ! sudo -n true 2>/dev/null; then
                    handle_permission_error "Shell değiştirme"
                fi
                
                return 1
            fi
            
            # Tekrar doğrula
            NEW_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
            if [[ "$NEW_SHELL" != "$ZSH_PATH" ]]; then
                log_error "Shell değiştirilemedi (doğrulama başarısız)"
                return 1
            fi
        fi
    else
        log_error "Shell değiştirilemedi"
        
        # Permission hatası olabilir
        if ! sudo -n true 2>/dev/null; then
            handle_permission_error "Shell değiştirme"
        fi
        
        return 1
    fi
    
    # GNOME Terminal ayarlarını yapılandır
    configure_gnome_terminal_login_shell
    
    log_success "Shell başarıyla Zsh olarak ayarlandı ve doğrulandı"
    return 0
}

# Shell değiştirme wrapper (transaction ile)
change_default_shell() {
    with_transaction "Shell Değiştirme" _change_default_shell_impl
}

# ============================================================================
# KALDIRMA
# ============================================================================

reset_terminal_profile() {
    log_info "Terminal profil ayarları sıfırlanıyor..."
    
    if ! command -v gsettings &> /dev/null; then
        log_warning "gsettings bulunamadı, terminal ayarları sıfırlanamadı"
        return 1
    fi
    
    local PROFILE
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE" ]]; then
        log_warning "Terminal profili bulunamadı"
        return 1
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
    
    show_step_info "Renk teması varsayılana döndürülüyor..."
    
    gsettings set "$PROFILE_PATH" use-theme-colors true 2>/dev/null
    gsettings reset "$PROFILE_PATH" background-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" foreground-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" palette 2>/dev/null
    gsettings reset "$PROFILE_PATH" visible-name 2>/dev/null
    
    show_step_success "Terminal ayarları sıfırlandı"
    return 0
}

save_original_state() {
    local state_file="$BACKUP_DIR/original_state.txt"
    
    log_info "Orijinal sistem durumu kaydediliyor..."
    
    cat > "$state_file" << EOF
# Kurulum öncesi sistem durumu
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
ORIGINAL_SHELL=$SHELL
USER=$USER

# Terminal profili
EOF
    
    if command -v gsettings &> /dev/null; then
        local PROFILE
        PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        if [[ -n "$PROFILE" ]]; then
            local PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
            {
                echo "PROFILE=$PROFILE"
                echo "USE_THEME_COLORS=$(gsettings get "$PATH" use-theme-colors 2>/dev/null)"
                echo "BG_COLOR=$(gsettings get "$PATH" background-color 2>/dev/null)"
                echo "FG_COLOR=$(gsettings get "$PATH" foreground-color 2>/dev/null)"
            } >> "$state_file"
        fi
    fi
    
    log_success "Orijinal durum kaydedildi: $state_file"
    return 0
}

restore_original_state() {
    local state_file="$BACKUP_DIR/original_state.txt"
    
    if [[ ! -f "$state_file" ]]; then
        log_warning "Orijinal durum dosyası bulunamadı"
        return 1
    fi
    
    log_info "Orijinal duruma geri dönülüyor..."
    
    # shellcheck source=/dev/null
    source "$state_file"
    
    if [[ -n "$ORIGINAL_SHELL" ]] && command -v "$ORIGINAL_SHELL" &> /dev/null; then
        show_step_info "Shell geri yükleniyor: $ORIGINAL_SHELL"
        sudo chsh -s "$ORIGINAL_SHELL" "$USER" 2>&1 | tee -a "$LOG_FILE" >/dev/null
    fi
    
    if [[ -n "$PROFILE" ]] && command -v gsettings &> /dev/null; then
        local PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
        
        show_step_info "Terminal renkleri geri yükleniyor..."
        
        if [[ "$USE_THEME_COLORS" == "true" ]]; then
            gsettings set "$PATH" use-theme-colors true 2>/dev/null
        else
            [[ -n "$BG_COLOR" ]] && gsettings set "$PATH" background-color "$BG_COLOR" 2>/dev/null
            [[ -n "$FG_COLOR" ]] && gsettings set "$PATH" foreground-color "$FG_COLOR" 2>/dev/null
        fi
    fi
    
    log_success "Orijinal durum geri yüklendi"
    return 0
}

uninstall_all() {
    local force_mode=false
    
    if [[ "$1" == "--force" ]]; then
        force_mode=true
        log_warning "ZORLAMALI KALDIRMA MODU - Otomatik onay aktif!"
        echo
        echo -e "${RED}UYARI: Kurduğunuz HER ŞEY silinecek!${NC}"
        echo "5 saniye içinde iptal etmek için CTRL+C basın..."
        sleep 5
    fi
    
    if [[ "$force_mode" == false ]]; then
        show_user_prompt "TÜM ÖZELLEŞTİRMELER KALDIRILACAK" \
            "• Tüm Zsh ayarlarını silecek" \
            "• Oh My Zsh'i kaldıracak" \
            "• Terminal renklerini varsayılana döndürecek" \
            "• Fontları silecek" \
            "• Kurulu araçları kaldıracak (opsiyonel)" \
            ""
        echo -n "Emin misiniz? (e/h): "
        read -r confirm
        
        if [[ "$confirm" != "e" ]]; then
            log_info "İptal edildi"
            return 0
        fi
    fi
    
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   TAM KALDIRMA İŞLEMİ BAŞLIYOR           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
    
    local total_steps=11
    local current_step=0
    local errors=0
    
    echo
    show_section $((++current_step)) $total_steps "Terminal profil ayarları sıfırlanıyor"
    if reset_terminal_profile; then
        show_step_success "Terminal varsayılan renklerine döndü"
    else
        show_step_skip "Terminal ayarları sıfırlanamadı"
        ((errors++))
    fi
    
    show_section $((++current_step)) $total_steps "Orijinal sistem durumuna dönülüyor"
    if restore_original_state; then
        show_step_success "Orijinal durum geri yüklendi"
    else
        show_step_info "Orijinal durum dosyası yok, manuel geri yükleme yapılacak"
        
        if command -v bash &> /dev/null; then
            local bash_path
            bash_path=$(which bash)
            
            if [[ "$SHELL" == "$bash_path" ]]; then
                show_step_skip "Zaten Bash kullanılıyor"
            else
                show_step_info "Bash'e geçiliyor..."
                if sudo chsh -s "$bash_path" "$USER" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                    show_step_success "Shell başarıyla değiştirildi"
                else
                    log_error "Shell değiştirilemedi"
                    ((errors++))
                fi
            fi
        fi
    fi
    
    show_section $((++current_step)) $total_steps "Oh My Zsh kaldırılıyor"
    if [[ -d ~/.oh-my-zsh ]]; then
        if rm -rf ~/.oh-my-zsh 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
            show_step_success "Oh My Zsh kaldırıldı"
        else
            log_error "Silinemedi"
            ((errors++))
        fi
    else
        show_step_skip "Zaten yok"
    fi
    
    show_section $((++current_step)) $total_steps "Zsh konfigürasyon dosyaları siliniyor"
    local zsh_files=("~/.zshrc" "~/.zsh_history" "~/.p10k.zsh" "~/.zshenv" "~/.zprofile" "~/.zlogin")
    for file in "${zsh_files[@]}"; do
        local expanded_file="${file/#\~/$HOME}"
        if [[ -f "$expanded_file" ]]; then
            if rm "$expanded_file" 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                show_step_success "Silindi: $file"
            else
                log_error "Silinemedi: $file"
                ((errors++))
            fi
        fi
    done
    
    show_section $((++current_step)) $total_steps "Yedeklerden geri yükleniyor"
    if [[ -d "$BACKUP_DIR" ]]; then
        local latest_bashrc
        latest_bashrc=$(ls -t "$BACKUP_DIR"/bashrc_* 2>/dev/null | head -1)
        if [[ -f "$latest_bashrc" ]]; then
            if cp "$latest_bashrc" ~/.bashrc 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                show_step_success ".bashrc geri yüklendi"
            else
                log_error ".bashrc geri yüklenemedi"
                ((errors++))
            fi
        fi
        
        local latest_tmux
        latest_tmux=$(ls -t "$BACKUP_DIR"/tmux_* 2>/dev/null | head -1)
        if [[ -f "$latest_tmux" ]]; then
            if cp "$latest_tmux" ~/.tmux.conf 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                show_step_success ".tmux.conf geri yüklendi"
            else
                log_error ".tmux.conf geri yüklenemedi"
                ((errors++))
            fi
        fi
    else
        show_step_skip "Yedek bulunamadı"
    fi
    
    echo
    echo -e "${CYAN}═════════════════════════════════════════${NC}"
    
    if [[ "$force_mode" == true ]]; then
        log_info "Zorlamalı mod: Tüm paketler otomatik kaldırılıyor..."
        
        show_section $((++current_step)) $total_steps "FZF kaldırılıyor"
        [[ -d ~/.fzf ]] && rm -rf ~/.fzf && show_step_success "FZF kaldırıldı"
        
        show_section $((++current_step)) $total_steps "Zoxide kaldırılıyor"
        if command -v zoxide &> /dev/null; then
            local zoxide_bin
            zoxide_bin=$(which zoxide)
            [[ -f "$zoxide_bin" ]] && sudo rm -f "$zoxide_bin" && show_step_success "Zoxide kaldırıldı"
        fi
        
        show_section $((++current_step)) $total_steps "Fontlar kaldırılıyor"
        local FONT_DIR=~/.local/share/fonts
        if [[ -d "$FONT_DIR" ]]; then
            rm -f "$FONT_DIR"/MesloLGS*.ttf 2>/dev/null
            command -v fc-cache &> /dev/null && fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            show_step_success "Fontlar kaldırıldı"
        fi
        
        show_section $((++current_step)) $total_steps "Tmux kaldırılıyor"
        if command -v tmux &> /dev/null; then
            sudo apt remove -y tmux &>/dev/null && show_step_success "Tmux kaldırıldı"
        fi
        
        show_section $((++current_step)) $total_steps "Zsh paketi kaldırılıyor"
        sudo apt remove -y zsh &>/dev/null && show_step_success "Zsh paketi kaldırıldı"
        sudo apt autoremove -y &>/dev/null
        
        show_section $((++current_step)) $total_steps "Sistem araçları kaldırılıyor"
        sudo apt remove -y exa bat &>/dev/null && show_step_success "Exa ve Bat kaldırıldı"
        sudo apt autoremove -y &>/dev/null
    fi
    
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   KALDIRMA ÖZETİ                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
    echo -e "  Tamamlanan adımlar: ${current_step}/${total_steps}"
    echo -e "  Hatalar: ${errors}"
    
    if [ $errors -eq 0 ]; then
        echo
        echo -e "${GREEN}✓ Kaldırma başarıyla tamamlandı!${NC}"
        echo
        echo -e "${YELLOW}ÖNEMLİ:${NC}"
        echo "  1. Terminal'i KAPAT ve TEKRAR AÇ"
        echo "  2. Renklerin normal göründüğünü kontrol et"
        echo "  3. 'echo \$SHELL' ile shell'in bash olduğunu kontrol et"
    else
        echo
        echo -e "${YELLOW}Kaldırma tamamlandı ama $errors hata oluştu${NC}"
        echo "  Detaylar için: cat $LOG_FILE"
    fi
    
    return 0
}