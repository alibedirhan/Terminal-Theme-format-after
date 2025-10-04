#!/bin/bash

# ============================================================================
# Terminal Setup - Kurulum Fonksiyonları
# v3.1.0 - Core Module
# ============================================================================

# Sudo refresh PID - Global değişken
SUDO_REFRESH_PID=""

# Sudo cleanup fonksiyonu
cleanup_sudo() {
    if [[ -n "$SUDO_REFRESH_PID" ]] && kill -0 "$SUDO_REFRESH_PID" 2>/dev/null; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null
        log_debug "Sudo refresh process durduruldu (PID: $SUDO_REFRESH_PID)"
        SUDO_REFRESH_PID=""
    fi
}

# Trap ekle
trap cleanup_sudo EXIT ERR

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
        echo
        log_warning "Eksik zorunlu paketler: ${missing_required[*]}"
        echo -n "Otomatik kurmak ister misiniz? (e/h): "
        read -r install_choice
        
        if [[ "$install_choice" == "e" ]]; then
            log_info "Paketler kuruluyor..."
            
            if ! sudo apt update; then
                log_error "apt update başarısız"
                diagnose_and_fix "internet_connection"
                return 1
            fi
            
            if ! sudo apt install -y "${missing_required[@]}"; then
                log_error "Paket kurulumu başarısız"
                for pkg in "${missing_required[@]}"; do
                    diagnose_and_fix "package_missing" "$pkg"
                done
                return 1
            fi
            
            log_success "Eksik paketler kuruldu"
        else
            log_error "Zorunlu paketler olmadan devam edilemez!"
            return 1
        fi
    fi
    
    if [ ${#missing_optional[@]} -ne 0 ]; then
        echo
        log_warning "Opsiyonel paketler eksik: ${missing_optional[*]}"
        if [[ " ${missing_optional[*]} " =~ " gsettings " ]]; then
            echo "  • gsettings: Renk temaları için gerekli (GNOME Terminal)"
        fi
        if [[ " ${missing_optional[*]} " =~ " fc-cache " ]]; then
            echo "  • fc-cache: Font cache güncellemesi için gerekli"
        fi
        sleep 2
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
    
    (
        while true; do
            sleep 50
            sudo -n true
            kill -0 "$" 2>/dev/null || exit
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
    mkdir -p "$BACKUP_DIR"
    
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
}

# ============================================================================
# ZSH KURULUMU
# ============================================================================

install_zsh() {
    log_info "Zsh kuruluyor..."
    
    if command -v zsh &> /dev/null; then
        log_warning "Zsh zaten kurulu, atlanıyor..."
        return 0
    fi
    
    sudo apt update || {
        log_error "apt update başarısız!"
        return 1
    }
    
    sudo apt install -y zsh || {
        log_error "Zsh kurulumu başarısız!"
        return 1
    }
    
    log_success "Zsh kuruldu"
}

# ============================================================================
# OH MY ZSH KURULUMU
# ============================================================================

install_oh_my_zsh() {
    log_info "Oh My Zsh kuruluyor..."
    
    if [[ -d ~/.oh-my-zsh ]]; then
        log_warning "Oh My Zsh zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        log_error "Oh My Zsh kurulumu başarısız!"
        return 1
    }
    
    log_success "Oh My Zsh kuruldu"
}

# ============================================================================
# FONT KURULUMU
# ============================================================================

install_fonts() {
    log_info "Fontlar kuruluyor..."
    
    if ! command -v fc-cache &> /dev/null; then
        log_info "fontconfig paketi kuruluyor..."
        sudo apt install -y fontconfig 2>/dev/null || {
            log_warning "fontconfig kurulumu başarısız"
        }
    fi
    
    sudo apt install -y fonts-powerline 2>/dev/null || {
        log_warning "Powerline font kurulumu başarısız, devam ediliyor..."
    }
    
    local FONT_DIR=~/.local/share/fonts
    mkdir -p "$FONT_DIR"
    
    if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
        log_info "MesloLGS NF fontları indiriliyor..."
        
        cd "$FONT_DIR" || return 1
        
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
                if wget --timeout=15 --tries=2 -q "$base_url/$url_name" -O "$file_name" 2>/dev/null; then
                    local file_size=$(wc -c < "$file_name" 2>/dev/null | tr -d '[:space:]')
                    if [[ -n "$file_size" ]] && [[ "$file_size" -gt 400000 ]]; then
                        log_debug "$file_name indirildi (${file_size} bytes)"
                        ((success_count++))
                        break
                    else
                        log_debug "$file_name çok küçük, tekrar deneniyor..."
                        rm -f "$file_name"
                        ((retry++))
                    fi
                else
                    ((retry++))
                fi
                
                if [ $retry -lt $max_retry ]; then
                    log_debug "$file_name tekrar deneniyor ($((retry + 1))/$max_retry)..."
                    sleep 2
                fi
            done
            
            if [ $retry -eq $max_retry ]; then
                log_warning "$file_name indirilemedi"
            fi
        done
        
        cd - > /dev/null
        
        if [ $success_count -gt 0 ]; then
            if command -v fc-cache &> /dev/null; then
                log_debug "Font cache güncelleniyor..."
                fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            fi
            log_success "$success_count font kuruldu"
        else
            log_error "Hiçbir font indirilemedi!"
            log_warning "Manuel kurulum için: https://github.com/romkatv/powerlevel10k#fonts"
            echo -n "Font olmadan devam etmek ister misiniz? (e/h): "
            read -r continue_choice
            if [[ "$continue_choice" != "e" ]]; then
                return 1
            fi
        fi
    else
        log_warning "Fontlar zaten kurulu, atlanıyor..."
    fi
}

# ============================================================================
# POWERLEVEL10K KURULUMU
# ============================================================================

install_powerlevel10k() {
    log_info "Powerlevel10k kuruluyor..."
    
    if ! check_internet; then
        return 1
    fi
    
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$P10K_DIR" ]]; then
        log_warning "Powerlevel10k zaten kurulu, güncelleniyor..."
        cd "$P10K_DIR" && git pull > /dev/null 2>&1
        cd - > /dev/null
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" || {
            log_error "Powerlevel10k klonlama başarısız!"
            return 1
        }
    fi
    
    if [[ -f ~/.zshrc ]]; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    fi
    
    log_success "Powerlevel10k kuruldu"
}

# ============================================================================
# PLUGİNLER
# ============================================================================

install_plugins() {
    log_info "Pluginler kuruluyor..."
    
    if ! check_internet; then
        return 1
    fi
    
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [[ ! -d "$CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions" || {
            log_warning "zsh-autosuggestions kurulumu başarısız"
        }
    fi
    
    if [[ ! -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting" || {
            log_warning "zsh-syntax-highlighting kurulumu başarısız"
        }
    fi
    
    if [[ -f ~/.zshrc ]]; then
        if grep -q "^plugins=(" ~/.zshrc; then
            sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)/' ~/.zshrc
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)' >> ~/.zshrc
        fi
    fi
    
    log_success "Pluginler kuruldu"
}

# ============================================================================
# TERMİNAL ARAÇLARI
# ============================================================================

install_fzf() {
    log_info "FZF kuruluyor..."
    
    if command -v fzf &> /dev/null; then
        log_warning "FZF zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    if [[ ! -d ~/.fzf ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || {
            log_error "FZF klonlama başarısız!"
            return 1
        }
    fi
    
    ~/.fzf/install --all --no-bash --no-fish || {
        log_error "FZF kurulumu başarısız!"
        return 1
    }
    
    log_success "FZF kuruldu"
}

install_zoxide() {
    log_info "Zoxide kuruluyor..."
    
    if command -v zoxide &> /dev/null; then
        log_warning "Zoxide zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash || {
        log_error "Zoxide kurulumu başarısız!"
        return 1
    }
    
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "zoxide init zsh" ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Zoxide initialization' >> ~/.zshrc
            echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
        fi
    fi
    
    log_success "Zoxide kuruldu"
}

install_exa() {
    log_info "Exa kuruluyor..."
    
    if command -v exa &> /dev/null; then
        log_warning "Exa zaten kurulu, atlanıyor..."
        return 0
    fi
    
    sudo apt install -y exa || {
        log_error "Exa kurulumu başarısız!"
        return 1
    }
    
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "alias ls=" ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Exa aliases' >> ~/.zshrc
            echo 'alias ls="exa --icons"' >> ~/.zshrc
            echo 'alias ll="exa -l --icons"' >> ~/.zshrc
            echo 'alias la="exa -la --icons"' >> ~/.zshrc
            echo 'alias lt="exa --tree --icons"' >> ~/.zshrc
        fi
    fi
    
    log_success "Exa kuruldu"
}

install_bat() {
    log_info "Bat kuruluyor..."
    
    if command -v batcat &> /dev/null || command -v bat &> /dev/null; then
        log_warning "Bat zaten kurulu, atlanıyor..."
        return 0
    fi
    
    sudo apt install -y bat || {
        log_error "Bat kurulumu başarısız!"
        return 1
    }
    
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "alias cat=" ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Bat alias' >> ~/.zshrc
            echo 'alias cat="batcat"' >> ~/.zshrc
        fi
    fi
    
    log_success "Bat kuruldu"
}

install_all_tools() {
    log_info "Terminal araçları kuruluyor..."
    
    local total_tools=4
    local current_tool=0
    
    show_progress $((++current_tool)) $total_tools "FZF kuruluyor"
    install_fzf
    
    show_progress $((++current_tool)) $total_tools "Zoxide kuruluyor"
    install_zoxide
    
    show_progress $((++current_tool)) $total_tools "Exa kuruluyor"
    install_exa
    
    show_progress $((++current_tool)) $total_tools "Bat kuruluyor"
    install_bat
    
    log_success "Tüm araçlar kuruldu"
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
    
    sudo apt install -y tmux || {
        log_error "Tmux kurulumu başarısız!"
        return 1
    }
    
    log_success "Tmux kuruldu"
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
    
    # Tema modülünden tema config'i al ve ekle
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
}

install_tmux_with_theme() {
    local theme=$1
    install_tmux || return 1
    configure_tmux_theme "$theme"
    log_info "Tmux'u test etmek için: tmux"
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
    
    # Tema modülündeki fonksiyonları kullan
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
}

install_theme_kitty() {
    local theme=$1
    
    if ! command -v kitty &> /dev/null; then
        log_warning "Kitty terminal bulunamadı"
        return 1
    fi
    
    local kitty_conf="$HOME/.config/kitty/kitty.conf"
    local theme_dir="$HOME/.config/kitty/themes"
    
    mkdir -p "$theme_dir"
    
    [[ -f "$kitty_conf" ]] && sed -i '/^include themes\//d' "$kitty_conf" || touch "$kitty_conf"
    
    # Tema modülünden tema config'i al ve kaydet
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
}

install_theme_alacritty() {
    local theme=$1
    
    if ! command -v alacritty &> /dev/null; then
        log_warning "Alacritty terminal bulunamadı"
        return 1
    fi
    
    local alacritty_conf="$HOME/.config/alacritty/alacritty.yml"
    mkdir -p "$(dirname "$alacritty_conf")"
    
    [[ -f "$alacritty_conf" ]] && sed -i '/^colors:/,/^[^ ]/{ /^colors:/d; /^[^ ]/!d }' "$alacritty_conf"
    
    # Tema modülünden tema config'i al ve ekle
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
            log_success "Bulundu: $alias_file"
            found_aliases=true
            
            # .zshrc'de zaten var mı kontrol et
            if grep -q "source.*$(basename $alias_file)" ~/.zshrc 2>/dev/null; then
                log_warning "$(basename $alias_file) zaten .zshrc içinde tanımlı"
            else
                echo
                echo -e "${YELLOW}$alias_file dosyanız bulundu.${NC}"
                echo -e "${CYAN}Bu dosyayı Zsh'de de kullanmak ister misiniz?${NC}"
                echo
                echo -n "Eklemek için (e/h): "
                read -r add_aliases
                
                if [[ "$add_aliases" == "e" ]]; then
                    echo "" >> ~/.zshrc
                    echo "# Bash aliases compatibility" >> ~/.zshrc
                    echo "if [[ -f $alias_file ]]; then" >> ~/.zshrc
                    echo "    source $alias_file" >> ~/.zshrc
                    echo "fi" >> ~/.zshrc
                    
                    log_success "$alias_file .zshrc'ye eklendi"
                else
                    log_info "Atlandı"
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
    
    local PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE_ID" ]]; then
        log_debug "GNOME Terminal profili bulunamadı"
        return 0
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"
    
    # Login shell ayarını kontrol et
    local current_setting=$(gsettings get "$PROFILE_PATH" login-shell 2>/dev/null)
    
    if [[ "$current_setting" == "true" ]]; then
        log_success "GNOME Terminal zaten login shell modunda"
    else
        gsettings set "$PROFILE_PATH" login-shell true 2>/dev/null
        log_success "GNOME Terminal login shell olarak ayarlandı"
    fi
    
    return 0
}

change_default_shell() {
    log_info "Varsayılan shell Zsh olarak ayarlanıyor..."
    
    local ZSH_PATH=$(which zsh)
    
    if [[ -z "$ZSH_PATH" ]]; then
        log_error "Zsh bulunamadı!"
        return 1
    fi
    
    # /etc/passwd kontrolü
    local CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
    
    if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
        log_success "Zsh zaten sistem varsayılan shell'i"
    else
        log_info "Shell değiştiriliyor: $CURRENT_SHELL → $ZSH_PATH"
        
        if chsh -s "$ZSH_PATH" 2>&1 | tee -a "$LOG_FILE"; then
            log_success "Sistem shell'i Zsh olarak ayarlandı"
            
            # Doğrulama
            local NEW_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
            if [[ "$NEW_SHELL" != "$ZSH_PATH" ]]; then
                log_warning "chsh başarısız, sudo ile deneniyor..."
                sudo chsh -s "$ZSH_PATH" "$USER" 2>&1 | tee -a "$LOG_FILE"
            fi
        else
            log_error "Shell değiştirilemedi"
            return 1
        fi
    fi
    
    # GNOME Terminal ayarı (kritik!)
    configure_gnome_terminal_login_shell
    
    echo
    log_warning "ÖNEMLİ: Yeni terminallerde Zsh görmek için:"
    echo -e "  ${CYAN}Seçenek 1:${NC} Tüm terminal pencerelerini kapatıp yeniden açın"
    echo -e "  ${CYAN}Seçenek 2:${NC} Logout/login yapın (en garantili)"
    echo -e "  ${CYAN}Seçenek 3:${NC} 'exec zsh' komutuyla mevcut terminalde geçin"
    
    return 0
}

# ============================================================================
# KALDIRMA - İYİLEŞTİRİLMİŞ VERSİYON
# ============================================================================

reset_terminal_profile() {
    log_info "Terminal profil ayarları sıfırlanıyor..."
    
    if ! command -v gsettings &> /dev/null; then
        log_warning "gsettings bulunamadı, terminal ayarları sıfırlanamadı"
        return 1
    fi
    
    local PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE" ]]; then
        log_warning "Terminal profili bulunamadı"
        return 1
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
    
    echo "  → Renk teması varsayılana döndürülüyor..."
    
    gsettings set "$PROFILE_PATH" use-theme-colors true 2>/dev/null
    gsettings reset "$PROFILE_PATH" background-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" foreground-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" palette 2>/dev/null
    gsettings reset "$PROFILE_PATH" visible-name 2>/dev/null
    
    log_success "  Terminal ayarları sıfırlandı"
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
        local PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        if [[ -n "$PROFILE" ]]; then
            local PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
            echo "PROFILE=$PROFILE" >> "$state_file"
            echo "USE_THEME_COLORS=$(gsettings get "$PATH" use-theme-colors 2>/dev/null)" >> "$state_file"
            echo "BG_COLOR=$(gsettings get "$PATH" background-color 2>/dev/null)" >> "$state_file"
            echo "FG_COLOR=$(gsettings get "$PATH" foreground-color 2>/dev/null)" >> "$state_file"
        fi
    fi
    
    log_success "Orijinal durum kaydedildi: $state_file"
}

restore_original_state() {
    local state_file="$BACKUP_DIR/original_state.txt"
    
    if [[ ! -f "$state_file" ]]; then
        log_warning "Orijinal durum dosyası bulunamadı"
        return 1
    fi
    
    log_info "Orijinal duruma geri dönülüyor..."
    
    source "$state_file"
    
    if [[ -n "$ORIGINAL_SHELL" ]] && command -v "$ORIGINAL_SHELL" &> /dev/null; then
        echo "  → Shell geri yükleniyor: $ORIGINAL_SHELL"
        sudo chsh -s "$ORIGINAL_SHELL" "$USER" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    if [[ -n "$PROFILE" ]] && command -v gsettings &> /dev/null; then
        local PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
        
        echo "  → Terminal renkleri geri yükleniyor..."
        
        if [[ "$USE_THEME_COLORS" == "true" ]]; then
            gsettings set "$PATH" use-theme-colors true 2>/dev/null
        else
            [[ -n "$BG_COLOR" ]] && gsettings set "$PATH" background-color "$BG_COLOR" 2>/dev/null
            [[ -n "$FG_COLOR" ]] && gsettings set "$PATH" foreground-color "$FG_COLOR" 2>/dev/null
        fi
    fi
    
    log_success "Orijinal durum geri yüklendi"
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
        log_warning "Tüm özelleştirmeler kaldırılacak!"
        echo
        echo "Bu işlem şunları yapacak:"
        echo "  • Tüm Zsh ayarlarını silecek"
        echo "  • Oh My Zsh'i kaldıracak"
        echo "  • Terminal renklerini varsayılana döndürecek"
        echo "  • Fontları silecek"
        echo "  • Kurulu araçları kaldıracak (opsiyonel)"
        echo "  • Zsh paketini kaldıracak (opsiyonel)"
        echo
        echo -n "Emin misiniz? (e/h): "
        read -r confirm
        
        if [[ "$confirm" != "e" ]]; then
            log_info "İptal edildi"
            return
        fi
    fi
    
    echo
    log_info "═════════════════════════════════════════════"
    log_info "TAM KALDIRMA İŞLEMİ BAŞLIYOR"
    log_info "═════════════════════════════════════════════"
    
    local total_steps=11
    local current_step=0
    local errors=0
    
    echo
    log_info "[$((++current_step))/$total_steps] Terminal profil ayarları sıfırlanıyor..."
    if reset_terminal_profile; then
        log_success "  Terminal varsayılan renklerine döndü"
    else
        log_warning "  Terminal ayarları sıfırlanamadı"
        ((errors++))
    fi
    
    echo
    log_info "[$((++current_step))/$total_steps] Orijinal sistem durumuna dönülüyor..."
    if restore_original_state; then
        log_success "  Orijinal durum geri yüklendi"
    else
        log_warning "  Orijinal durum dosyası yok, manuel geri yükleme yapılacak"
        
        if command -v bash &> /dev/null; then
            local bash_path=$(which bash)
            echo "  → Bash yolu: $bash_path"
            
            if [[ "$SHELL" == "$bash_path" ]]; then
                log_success "  Zaten Bash kullanılıyor"
            else
                echo "  → sudo ile shell değiştiriliyor (şifre gerekebilir)..."
                if sudo chsh -s "$bash_path" "$USER" 2>&1 | tee -a "$LOG_FILE"; then
                    log_success "  Shell başarıyla değiştirildi"
                else
                    log_error "  Shell değiştirilemedi (Hata Kodu: $?)"
                    ((errors++))
                fi
            fi
        fi
    fi
    
    echo
    log_info "[$((++current_step))/$total_steps] Oh My Zsh kaldırılıyor..."
    if [[ -d ~/.oh-my-zsh ]]; then
        echo "  → ~/.oh-my-zsh siliniyor..."
        if rm -rf ~/.oh-my-zsh 2>&1 | tee -a "$LOG_FILE"; then
            log_success "  Oh My Zsh kaldırıldı"
        else
            log_error "  Silinemedi (Hata Kodu: $?)"
            ((errors++))
        fi
    else
        log_success "  Zaten yok"
    fi
    
    echo
    log_info "[$((++current_step))/$total_steps] Zsh konfigürasyon dosyaları siliniyor..."
    local zsh_files=("~/.zshrc" "~/.zsh_history" "~/.p10k.zsh" "~/.zshenv" "~/.zprofile" "~/.zlogin")
    for file in "${zsh_files[@]}"; do
        local expanded_file="${file/#\~/$HOME}"
        if [[ -f "$expanded_file" ]]; then
            echo "  → $file siliniyor..."
            if rm "$expanded_file" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "  Silindi: $file"
            else
                log_error "  Silinemedi: $file (Hata Kodu: $?)"
                ((errors++))
            fi
        fi
    done
    
    echo
    log_info "[$((++current_step))/$total_steps] Yedeklerden geri yükleniyor..."
    if [[ -d "$BACKUP_DIR" ]]; then
        local latest_bashrc=$(ls -t "$BACKUP_DIR"/bashrc_* 2>/dev/null | head -1)
        if [[ -f "$latest_bashrc" ]]; then
            echo "  → .bashrc geri yükleniyor..."
            if cp "$latest_bashrc" ~/.bashrc 2>&1 | tee -a "$LOG_FILE"; then
                log_success "  .bashrc geri yüklendi"
            else
                log_error "  .bashrc geri yüklenemedi (Hata Kodu: $?)"
                ((errors++))
            fi
        fi
        
        local latest_tmux=$(ls -t "$BACKUP_DIR"/tmux_* 2>/dev/null | head -1)
        if [[ -f "$latest_tmux" ]]; then
            echo "  → .tmux.conf geri yükleniyor..."
            if cp "$latest_tmux" ~/.tmux.conf 2>&1 | tee -a "$LOG_FILE"; then
                log_success "  .tmux.conf geri yüklendi"
            else
                log_error "  .tmux.conf geri yüklenemedi (Hata Kodu: $?)"
                ((errors++))
            fi
        fi
    else
        log_warning "  Yedek bulunamadı"
    fi
    
    echo
    echo "═════════════════════════════════════════════"
    
    if [[ "$force_mode" == true ]]; then
        log_info "Zorlamalı mod: Tüm paketler otomatik kaldırılıyor..."
        
        echo
        log_info "[$((++current_step))/$total_steps] FZF kaldırılıyor..."
        [[ -d ~/.fzf ]] && rm -rf ~/.fzf && log_success "  FZF kaldırıldı"
        
        echo
        log_info "[$((++current_step))/$total_steps] Zoxide kaldırılıyor..."
        if command -v zoxide &> /dev/null; then
            local zoxide_bin=$(which zoxide)
            [[ -f "$zoxide_bin" ]] && sudo rm -f "$zoxide_bin" && log_success "  Zoxide kaldırıldı"
        fi
        
        echo
        log_info "[$((++current_step))/$total_steps] Fontlar kaldırılıyor..."
        local FONT_DIR=~/.local/share/fonts
        if [[ -d "$FONT_DIR" ]]; then
            rm -f "$FONT_DIR"/MesloLGS*.ttf 2>/dev/null
            command -v fc-cache &> /dev/null && fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            log_success "  Fontlar kaldırıldı"
        fi
        
        echo
        log_info "[$((++current_step))/$total_steps] Tmux kaldırılıyor..."
        if command -v tmux &> /dev/null; then
            sudo apt remove -y tmux 2>&1 | tee -a "$LOG_FILE" && log_success "  Tmux kaldırıldı"
        fi
        
        echo
        log_info "[$((++current_step))/$total_steps] Zsh paketi kaldırılıyor..."
        sudo apt remove -y zsh 2>&1 | tee -a "$LOG_FILE" && log_success "  Zsh paketi kaldırıldı"
        sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
        
        echo
        log_info "[$((++current_step))/$total_steps] Sistem araçları kaldırılıyor..."
        sudo apt remove -y exa bat 2>&1 | tee -a "$LOG_FILE" && log_success "  Exa ve Bat kaldırıldı"
        sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
        
    else
        echo -e "${YELLOW}Opsiyonel Kaldırmalar:${NC}"
        echo
        
        echo
        log_info "[$((++current_step))/$total_steps] FZF kontrolü..."
        if command -v fzf &> /dev/null || [[ -d ~/.fzf ]]; then
            local remove_fzf=$(read_with_timeout "  FZF kaldırılsın mı? (e/h):" 30 "h")
            if [[ "$remove_fzf" == "e" ]]; then
                [[ -d ~/.fzf ]] && rm -rf ~/.fzf && log_success "  FZF kaldırıldı"
            else
                log_info "  FZF korundu"
            fi
        else
            log_success "  FZF yok"
        fi
    fi
    
    echo
    echo "═════════════════════════════════════════════"
    echo -e "${CYAN}KALDIRMA ÖZETİ:${NC}"
    echo "  Tamamlanan adımlar: $current_step/$total_steps"
    echo "  Hatalar: $errors"
    
    if [ $errors -eq 0 ]; then
        echo
        log_success "✓ Kaldırma başarıyla tamamlandı!"
        echo
        echo -e "${YELLOW}ÖNEMLİ:${NC}"
        echo "  1. Terminal'i KAPAT ve TEKRAR AÇ"
        echo "  2. Renklerin normal göründüğünü kontrol et"
        echo "  3. 'echo \$SHELL' ile shell'in bash olduğunu kontrol et"
    else
        echo
        log_warning "Kaldırma tamamlandı ama $errors hata oluştu"
        echo "  Detaylar için: cat $LOG_FILE"
    fi
}