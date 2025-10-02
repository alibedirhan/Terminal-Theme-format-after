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
            sudo apt update || return 1
            sudo apt install -y "${missing_required[@]}" || {
                log_error "Paket kurulumu başarısız"
                return 1
            }
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
        return 1
    fi
    
    log_success "Sudo yetkisi alındı"
    
    (
        while true; do
            sleep 50
            sudo -n true
            kill -0 "$$" 2>/dev/null || exit
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

show_terminal_tools_info() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           MODERN TERMİNAL ARAÇLARI                   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
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
    
    case $theme in
        dracula)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#282a36',fg='#f8f8f2'
set -g window-status-current-style bg='#bd93f9',fg='#282a36'
set -g pane-border-style fg='#6272a4'
set -g pane-active-border-style fg='#ff79c6'
set -g message-style bg='#44475a',fg='#f8f8f2'
EOF
            ;;
        nord)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#2e3440',fg='#d8dee9'
set -g window-status-current-style bg='#88c0d0',fg='#2e3440'
set -g pane-border-style fg='#4c566a'
set -g pane-active-border-style fg='#88c0d0'
set -g message-style bg='#3b4252',fg='#d8dee9'
EOF
            ;;
        gruvbox)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#282828',fg='#ebdbb2'
set -g window-status-current-style bg='#fabd2f',fg='#282828'
set -g pane-border-style fg='#504945'
set -g pane-active-border-style fg='#fabd2f'
set -g message-style bg='#504945',fg='#ebdbb2'
EOF
            ;;
        tokyo-night)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#1a1b26',fg='#c0caf5'
set -g window-status-current-style bg='#7aa2f7',fg='#1a1b26'
set -g pane-border-style fg='#414868'
set -g pane-active-border-style fg='#7aa2f7'
set -g message-style bg='#414868',fg='#c0caf5'
EOF
            ;;
        catppuccin)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#1e1e2e',fg='#cdd6f4'
set -g window-status-current-style bg='#89b4fa',fg='#1e1e2e'
set -g pane-border-style fg='#45475a'
set -g pane-active-border-style fg='#89b4fa'
set -g message-style bg='#45475a',fg='#cdd6f4'
EOF
            ;;
        one-dark)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#282c34',fg='#abb2bf'
set -g window-status-current-style bg='#61afef',fg='#282c34'
set -g pane-border-style fg='#5c6370'
set -g pane-active-border-style fg='#61afef'
set -g message-style bg='#3e4451',fg='#abb2bf'
EOF
            ;;
        solarized)
            cat >> "$tmux_conf" << 'EOF'
set -g status-style bg='#002b36',fg='#839496'
set -g window-status-current-style bg='#268bd2',fg='#fdf6e3'
set -g pane-border-style fg='#073642'
set -g pane-active-border-style fg='#268bd2'
set -g message-style bg='#073642',fg='#839496'
EOF
            ;;
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

apply_dracula_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Dracula" 2>/dev/null
    gsettings set "$path" background-color '#282A36' 2>/dev/null
    gsettings set "$path" foreground-color '#F8F8F2' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#000000', '#FF5555', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF79C6', '#8BE9FD', '#BFBFBF', '#4D4D4D', '#FF6E67', '#5AF78E', '#F4F99D', '#CAA9FA', '#FF92D0', '#9AEDFE', '#E6E6E6']" 2>/dev/null
    log_success "Dracula teması uygulandı"
}

apply_nord_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Nord" 2>/dev/null
    gsettings set "$path" background-color '#2E3440' 2>/dev/null
    gsettings set "$path" foreground-color '#D8DEE9' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#3B4252', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#E5E9F0', '#4C566A', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#8FBCBB', '#ECEFF4']" 2>/dev/null
    log_success "Nord teması uygulandı"
}

apply_gruvbox_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Gruvbox Dark" 2>/dev/null
    gsettings set "$path" background-color '#282828' 2>/dev/null
    gsettings set "$path" foreground-color '#EBDBB2' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#282828', '#CC241D', '#98971A', '#D79921', '#458588', '#B16286', '#689D6A', '#A89984', '#928374', '#FB4934', '#B8BB26', '#FABD2F', '#83A598', '#D3869B', '#8EC07C', '#EBDBB2']" 2>/dev/null
    log_success "Gruvbox teması uygulandı"
}

apply_tokyo_night_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Tokyo Night" 2>/dev/null
    gsettings set "$path" background-color '#1A1B26' 2>/dev/null
    gsettings set "$path" foreground-color '#C0CAF5' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#15161E', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#A9B1D6', '#414868', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#C0CAF5']" 2>/dev/null
    log_success "Tokyo Night teması uygulandı"
}

apply_catppuccin_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Catppuccin Mocha" 2>/dev/null
    gsettings set "$path" background-color '#1E1E2E' 2>/dev/null
    gsettings set "$path" foreground-color '#CDD6F4' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#45475A', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#BAC2DE', '#585B70', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#A6ADC8']" 2>/dev/null
    log_success "Catppuccin teması uygulandı"
}

apply_one_dark_gnome() {
    local path=$1
    gsettings set "$path" visible-name "One Dark" 2>/dev/null
    gsettings set "$path" background-color '#282C34' 2>/dev/null
    gsettings set "$path" foreground-color '#ABB2BF' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#282C34', '#E06C75', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#E06C75', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#FFFFFF']" 2>/dev/null
    log_success "One Dark teması uygulandı"
}

apply_solarized_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Solarized Dark" 2>/dev/null
    gsettings set "$path" background-color '#002B36' 2>/dev/null
    gsettings set "$path" foreground-color '#839496' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#073642', '#DC322F', '#859900', '#B58900', '#268BD2', '#D33682', '#2AA198', '#EEE8D5', '#002B36', '#CB4B16', '#586E75', '#657B83', '#839496', '#6C71C4', '#93A1A1', '#FDF6E3']" 2>/dev/null
    log_success "Solarized Dark teması uygulandı"
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
    
    case $theme in
        dracula)
            cat > "$theme_dir/dracula.conf" << 'EOF'
foreground #f8f8f2
background #282a36
selection_foreground #ffffff
selection_background #44475a
color0  #21222c
color1  #ff5555
color2  #50fa7b
color3  #f1fa8c
color4  #bd93f9
color5  #ff79c6
color6  #8be9fd
color7  #f8f8f2
color8  #6272a4
color9  #ff6e6e
color10 #69ff94
color11 #ffffa5
color12 #d6acff
color13 #ff92df
color14 #a4ffff
color15 #ffffff
EOF
            echo "include themes/dracula.conf" >> "$kitty_conf"
            ;;
        nord)
            cat > "$theme_dir/nord.conf" << 'EOF'
foreground #d8dee9
background #2e3440
selection_foreground #000000
selection_background #fffacd
color0  #3b4252
color1  #bf616a
color2  #a3be8c
color3  #ebcb8b
color4  #81a1c1
color5  #b48ead
color6  #88c0d0
color7  #e5e9f0
color8  #4c566a
color9  #bf616a
color10 #a3be8c
color11 #ebcb8b
color12 #81a1c1
color13 #b48ead
color14 #8fbcbb
color15 #eceff4
EOF
            echo "include themes/nord.conf" >> "$kitty_conf"
            ;;
        gruvbox)
            cat > "$theme_dir/gruvbox.conf" << 'EOF'
foreground #ebdbb2
background #282828
selection_foreground #928374
selection_background #ebdbb2
color0  #282828
color1  #cc241d
color2  #98971a
color3  #d79921
color4  #458588
color5  #b16286
color6  #689d6a
color7  #a89984
color8  #928374
color9  #fb4934
color10 #b8bb26
color11 #fabd2f
color12 #83a598
color13 #d3869b
color14 #8ec07c
color15 #ebdbb2
EOF
            echo "include themes/gruvbox.conf" >> "$kitty_conf"
            ;;
        tokyo-night)
            cat > "$theme_dir/tokyo-night.conf" << 'EOF'
foreground #c0caf5
background #1a1b26
selection_foreground #c0caf5
selection_background #33467C
color0  #15161E
color1  #f7768e
color2  #9ece6a
color3  #e0af68
color4  #7aa2f7
color5  #bb9af7
color6  #7dcfff
color7  #a9b1d6
color8  #414868
color9  #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5
EOF
            echo "include themes/tokyo-night.conf" >> "$kitty_conf"
            ;;
        catppuccin)
            cat > "$theme_dir/catppuccin.conf" << 'EOF'
foreground #cdd6f4
background #1e1e2e
selection_foreground #1e1e2e
selection_background #f5e0dc
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #f5c2e7
color6  #94e2d5
color7  #bac2de
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8
EOF
            echo "include themes/catppuccin.conf" >> "$kitty_conf"
            ;;
        one-dark)
            cat > "$theme_dir/one-dark.conf" << 'EOF'
foreground #abb2bf
background #282c34
selection_foreground #282c34
selection_background #abb2bf
color0  #282c34
color1  #e06c75
color2  #98c379
color3  #e5c07b
color4  #61afef
color5  #c678dd
color6  #56b6c2
color7  #abb2bf
color8  #5c6370
color9  #e06c75
color10 #98c379
color11 #e5c07b
color12 #61afef
color13 #c678dd
color14 #56b6c2
color15 #ffffff
EOF
            echo "include themes/one-dark.conf" >> "$kitty_conf"
            ;;
        solarized)
            cat > "$theme_dir/solarized.conf" << 'EOF'
foreground #839496
background #002b36
selection_foreground #93a1a1
selection_background #073642
color0  #073642
color1  #dc322f
color2  #859900
color3  #b58900
color4  #268bd2
color5  #d33682
color6  #2aa198
color7  #eee8d5
color8  #002b36
color9  #cb4b16
color10 #586e75
color11 #657b83
color12 #839496
color13 #6c71c4
color14 #93a1a1
color15 #fdf6e3
EOF
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
    
    local theme_config=""
    
    case $theme in
        dracula) theme_config="colors:
  primary:
    background: '#282a36'
    foreground: '#f8f8f2'
  normal:
    black:   '#000000'
    red:     '#ff5555'
    green:   '#50fa7b'
    yellow:  '#f1fa8c'
    blue:    '#bd93f9'
    magenta: '#ff79c6'
    cyan:    '#8be9fd'
    white:   '#bfbfbf'
  bright:
    black:   '#4d4d4d'
    red:     '#ff6e67'
    green:   '#5af78e'
    yellow:  '#f4f99d'
    blue:    '#caa9fa'
    magenta: '#ff92d0'
    cyan:    '#9aedfe'
    white:   '#e6e6e6'" ;;
        nord) theme_config="colors:
  primary:
    background: '#2e3440'
    foreground: '#d8dee9'
  normal:
    black:   '#3b4252'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#88c0d0'
    white:   '#e5e9f0'
  bright:
    black:   '#4c566a'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#8fbcbb'
    white:   '#eceff4'" ;;
        gruvbox) theme_config="colors:
  primary:
    background: '#282828'
    foreground: '#ebdbb2'
  normal:
    black:   '#282828'
    red:     '#cc241d'
    green:   '#98971a'
    yellow:  '#d79921'
    blue:    '#458588'
    magenta: '#b16286'
    cyan:    '#689d6a'
    white:   '#a89984'
  bright:
    black:   '#928374'
    red:     '#fb4934'
    green:   '#b8bb26'
    yellow:  '#fabd2f'
    blue:    '#83a598'
    magenta: '#d3869b'
    cyan:    '#8ec07c'
    white:   '#ebdbb2'" ;;
        tokyo-night) theme_config="colors:
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'
  normal:
    black:   '#15161e'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#a9b1d6'
  bright:
    black:   '#414868'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#c0caf5'" ;;
        catppuccin) theme_config="colors:
  primary:
    background: '#1e1e2e'
    foreground: '#cdd6f4'
  normal:
    black:   '#45475a'
    red:     '#f38ba8'
    green:   '#a6e3a1'
    yellow:  '#f9e2af'
    blue:    '#89b4fa'
    magenta: '#f5c2e7'
    cyan:    '#94e2d5'
    white:   '#bac2de'
  bright:
    black:   '#585b70'
    red:     '#f38ba8'
    green:   '#a6e3a1'
    yellow:  '#f9e2af'
    blue:    '#89b4fa'
    magenta: '#f5c2e7'
    cyan:    '#94e2d5'
    white:   '#a6adc8'" ;;
        one-dark) theme_config="colors:
  primary:
    background: '#282c34'
    foreground: '#abb2bf'
  normal:
    black:   '#282c34'
    red:     '#e06c75'
    green:   '#98c379'
    yellow:  '#e5c07b'
    blue:    '#61afef'
    magenta: '#c678dd'
    cyan:    '#56b6c2'
    white:   '#abb2bf'
  bright:
    black:   '#5c6370'
    red:     '#e06c75'
    green:   '#98c379'
    yellow:  '#e5c07b'
    blue:    '#61afef'
    magenta: '#c678dd'
    cyan:    '#56b6c2'
    white:   '#ffffff'" ;;
        solarized) theme_config="colors:
  primary:
    background: '#002b36'
    foreground: '#839496'
  normal:
    black:   '#073642'
    red:     '#dc322f'
    green:   '#859900'
    yellow:  '#b58900'
    blue:    '#268bd2'
    magenta: '#d33682'
    cyan:    '#2aa198'
    white:   '#eee8d5'
  bright:
    black:   '#002b36'
    red:     '#cb4b16'
    green:   '#586e75'
    yellow:  '#657b83'
    blue:    '#839496'
    magenta: '#6c71c4'
    cyan:    '#93a1a1'
    white:   '#fdf6e3'" ;;
    esac
    
    [[ -f "$alacritty_conf" ]] && sed -i '/^colors:/,/^[^ ]/{ /^colors:/d; /^[^ ]/!d }' "$alacritty_conf"
    
    echo "$theme_config" >> "$alacritty_conf"
    log_success "Alacritty için $theme teması kuruldu"
}

# ============================================================================
# SHELL DEĞİŞTİRME
# ============================================================================

change_default_shell() {
    log_info "Varsayılan shell Zsh olarak ayarlanıyor..."
    
    local ZSH_PATH=$(which zsh)
    
    if [[ -z "$ZSH_PATH" ]]; then
        log_error "Zsh bulunamadı!"
        return 1
    fi
    
    if [[ "$SHELL" == "$ZSH_PATH" ]]; then
        log_warning "Zsh zaten varsayılan shell"
        return 0
    fi
    
    chsh -s "$ZSH_PATH" || {
        log_warning "Shell değiştirme başarısız, sudo ile deneyin:"
        echo "  sudo chsh -s $ZSH_PATH $USER"
        return 1
    }
    
    log_success "Varsayılan shell Zsh olarak ayarlandı"
    log_info "Değişikliğin geçerli olması için çıkış yapıp tekrar giriş yapın"
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
    
    # Tema kullanımını aç (sistem temasını kullan)
    gsettings set "$PROFILE_PATH" use-theme-colors true 2>/dev/null
    
    # Veya manuel olarak varsayılan renklere döndür
    gsettings reset "$PROFILE_PATH" background-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" foreground-color 2>/dev/null
    gsettings reset "$PROFILE_PATH" palette 2>/dev/null
    gsettings reset "$PROFILE_PATH" visible-name 2>/dev/null
    
    log_success "  Terminal ayarları sıfırlandı"
    return 0
}

# Kurulum öncesi durumu kaydet
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

# Orijinal duruma tam geri dön
restore_original_state() {
    local state_file="$BACKUP_DIR/original_state.txt"
    
    if [[ ! -f "$state_file" ]]; then
        log_warning "Orijinal durum dosyası bulunamadı"
        return 1
    fi
    
    log_info "Orijinal duruma geri dönülüyor..."
    
    source "$state_file"
    
    # Shell'i geri yükle
    if [[ -n "$ORIGINAL_SHELL" ]] && command -v "$ORIGINAL_SHELL" &> /dev/null; then
        echo "  → Shell geri yükleniyor: $ORIGINAL_SHELL"
        sudo chsh -s "$ORIGINAL_SHELL" "$USER" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Terminal ayarlarını geri yükle
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

# ============================================================================
# YENİ VE GELİŞTİRİLMİŞ UNINSTALL_ALL
# ============================================================================

uninstall_all() {
    local force_mode=false
    
    # Force parametresi kontrolü
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
    log_info "═══════════════════════════════════════════════════"
    log_info "TAM KALDIRMA İŞLEMİ BAŞLIYOR"
    log_info "═══════════════════════════════════════════════════"
    
    local total_steps=11
    local current_step=0
    local errors=0
    
    # 0. TERMİNAL AYARLARINI SIFIRLA (YENİ!)
    echo
    log_info "[$((++current_step))/$total_steps] Terminal profil ayarları sıfırlanıyor..."
    if reset_terminal_profile; then
        log_success "  Terminal varsayılan renklerine döndü"
    else
        log_warning "  Terminal ayarları sıfırlanamadı"
        ((errors++))
    fi
    
    # 1. ORİJİNAL DURUMA GERİ DÖN
    echo
    log_info "[$((++current_step))/$total_steps] Orijinal sistem durumuna dönülüyor..."
    if restore_original_state; then
        log_success "  Orijinal durum geri yüklendi"
    else
        log_warning "  Orijinal durum dosyası yok, manuel geri yükleme yapılacak"
        
        # Manuel shell değiştirme
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
    
    # 2. Oh My Zsh kaldırma
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
    
    # 3. Zsh config dosyaları
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
    
    # 4. Yedeklerden geri yükleme
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
    
    # Opsiyonel kaldırmalar
    echo
    echo "═══════════════════════════════════════════════════"
    
    if [[ "$force_mode" == true ]]; then
        log_info "Zorlamalı mod: Tüm paketler otomatik kaldırılıyor..."
        
        # FZF
        echo
        log_info "[$((++current_step))/$total_steps] FZF kaldırılıyor..."
        [[ -d ~/.fzf ]] && rm -rf ~/.fzf && log_success "  FZF kaldırıldı"
        
        # Zoxide
        echo
        log_info "[$((++current_step))/$total_steps] Zoxide kaldırılıyor..."
        if command -v zoxide &> /dev/null; then
            local zoxide_bin=$(which zoxide)
            [[ -f "$zoxide_bin" ]] && sudo rm -f "$zoxide_bin" && log_success "  Zoxide kaldırıldı"
        fi
        
        # Fontlar
        echo
        log_info "[$((++current_step))/$total_steps] Fontlar kaldırılıyor..."
        local FONT_DIR=~/.local/share/fonts
        if [[ -d "$FONT_DIR" ]]; then
            rm -f "$FONT_DIR"/MesloLGS*.ttf 2>/dev/null
            command -v fc-cache &> /dev/null && fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            log_success "  Fontlar kaldırıldı"
        fi
        
        # Tmux
        echo
        log_info "[$((++current_step))/$total_steps] Tmux kaldırılıyor..."
        if command -v tmux &> /dev/null; then
            sudo apt remove -y tmux 2>&1 | tee -a "$LOG_FILE" && log_success "  Tmux kaldırıldı"
        fi
        
        # Zsh paketi
        echo
        log_info "[$((++current_step))/$total_steps] Zsh paketi kaldırılıyor..."
        sudo apt remove -y zsh 2>&1 | tee -a "$LOG_FILE" && log_success "  Zsh paketi kaldırıldı"
        sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
        
        # Sistem araçları
        echo
        log_info "[$((++current_step))/$total_steps] Sistem araçları kaldırılıyor..."
        sudo apt remove -y exa bat 2>&1 | tee -a "$LOG_FILE" && log_success "  Exa ve Bat kaldırıldı"
        sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
        
    else
        # İnteraktif mod - kullanıcıya sor
        echo -e "${YELLOW}Opsiyonel Kaldırmalar:${NC}"
        echo
        
        # FZF
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
        
        # (Diğer opsiyonel kaldırmalar aynı şekilde...)
    fi
    
    # Özet
    echo
    echo "═══════════════════════════════════════════════════"
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