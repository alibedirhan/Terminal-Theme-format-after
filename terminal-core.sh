#!/bin/bash

# ============================================================================
# Terminal Setup - Kurulum Fonksiyonları
# v3.1 - Core Module (Bug Fixes)
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
    
    # Zorunlu komutları kontrol et
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_required+=("$cmd")
            log_error "$cmd eksik (zorunlu)"
        else
            log_debug "$cmd mevcut"
        fi
    done
    
    # Opsiyonel komutları kontrol et
    for cmd in "${optional_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_optional+=("$cmd")
            log_debug "$cmd eksik (opsiyonel)"
        fi
    done
    
    # Eksik zorunlu paketler varsa kur
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
    
    # Opsiyonel paketler için bilgi ver
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
    
    # Arka planda sudo timeout'u yenile
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
    
    # Dosya yedekleri
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$BACKUP_DIR/bashrc_$TIMESTAMP"
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$BACKUP_DIR/zshrc_$TIMESTAMP"
    [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$BACKUP_DIR/p10k_$TIMESTAMP"
    
    # Mevcut shell'i kaydet
    echo "$SHELL" > "$BACKUP_DIR/original_shell_$TIMESTAMP"
    
    # GNOME Terminal profil ID'sini kaydet
    if command -v gsettings &> /dev/null; then
        gsettings get org.gnome.Terminal.ProfilesList default > "$BACKUP_DIR/gnome_profile_$TIMESTAMP" 2>/dev/null || true
    fi
    
    log_success "Yedek oluşturuldu: $BACKUP_DIR"
    
    # Eski yedekleri temizle
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
    
    # Fontconfig
    if ! command -v fc-cache &> /dev/null; then
        log_info "fontconfig paketi kuruluyor..."
        sudo apt install -y fontconfig 2>/dev/null || {
            log_warning "fontconfig kurulumu başarısız"
        }
    fi
    
    # Powerline fontları
    sudo apt install -y fonts-powerline 2>/dev/null || {
        log_warning "Powerline font kurulumu başarısız, devam ediliyor..."
    }
    
    # MesloLGS NF
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
                    # Platform bağımsız dosya boyutu kontrolü
                    local file_size=$(wc -c < "$file_name" 2>/dev/null)
                    if [[ -n "$file_size" ]] && [[ "$file_size" -gt 10000 ]]; then
                        log_debug "$file_name indirildi"
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
    
    # .zshrc'de temayı ayarla
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
    
    # zsh-autosuggestions
    if [[ ! -d "$CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions" || {
            log_warning "zsh-autosuggestions kurulumu başarısız"
        }
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting" || {
            log_warning "zsh-syntax-highlighting kurulumu başarısız"
        }
    fi
    
    # .zshrc'de pluginleri aktif et
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
# TERMINAL ARAÇLARI
# ============================================================================

# Terminal araçlarını göster
show_terminal_tools_info() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           MODERN TERMINAL ARAÇLARI                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${YELLOW}1) FZF - Fuzzy Finder${NC}"
    echo "   Dosya, komut, history'de hızlı arama"
    echo "   https://github.com/junegunn/fzf"
    echo
    
    echo -e "${YELLOW}2) Zoxide - Akıllı cd${NC}"
    echo "   En çok kullandığınız dizinlere hızlıca atlama"
    echo "   https://github.com/ajeetdsouza/zoxide"
    echo
    
    echo -e "${YELLOW}3) Exa - Modern ls${NC}"
    echo "   Renkli ve icon'lu dosya listeleme"
    echo "   https://github.com/ogham/exa"
    echo
    
    echo -e "${YELLOW}4) Bat - cat with syntax${NC}"
    echo "   Syntax highlighting ile dosya görüntüleme"
    echo "   https://github.com/sharkdp/bat"
    echo
    
    echo -e "${CYAN}Tümünü kurmak ister misiniz? (e/h): ${NC}"
    read -r install_all
    
    if [[ "$install_all" == "e" ]]; then
        return 0
    else
        return 1
    fi
}

# FZF kurulumu
install_fzf() {
    log_info "FZF kuruluyor..."
    
    if command -v fzf &> /dev/null; then
        log_warning "FZF zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    # FZF'yi klonla ve kur
    if [[ ! -d ~/.fzf ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || {
            log_error "FZF klonlama başarısız!"
            return 1
        }
    fi
    
    # Otomatik kurulum
    ~/.fzf/install --all --no-bash --no-fish || {
        log_error "FZF kurulumu başarısız!"
        return 1
    }
    
    log_success "FZF kuruldu"
}

# Zoxide kurulumu
install_zoxide() {
    log_info "Zoxide kuruluyor..."
    
    if command -v zoxide &> /dev/null; then
        log_warning "Zoxide zaten kurulu, atlanıyor..."
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    # Zoxide kurulum scripti
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash || {
        log_error "Zoxide kurulumu başarısız!"
        return 1
    }
    
    # Zshrc'ye ekle
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "zoxide init zsh" ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Zoxide initialization' >> ~/.zshrc
            echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
        fi
    fi
    
    log_success "Zoxide kuruldu"
}

# Exa kurulumu
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
    
    # Aliases ekle
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

# Bat kurulumu
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
    
    # Ubuntu'da 'batcat' olarak kurulur, alias ekle
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "alias cat=" ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Bat alias' >> ~/.zshrc
            echo 'alias cat="batcat"' >> ~/.zshrc
        fi
    fi
    
    log_success "Bat kuruldu"
}

# Tüm araçları kur
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
# TMUX KURULUMU VE TEMA ENTEGRASYONU
# ============================================================================

# Tmux kurulumu
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

# Tmux tema konfigürasyonu
configure_tmux_theme() {
    local theme=$1
    
    log_info "Tmux için $theme teması yapılandırılıyor..."
    
    # Tmux konfigürasyon dosyası
    local tmux_conf="$HOME/.tmux.conf"
    
    # Temel konfigürasyon
    cat > "$tmux_conf" << 'EOF'
# Prefix değiştir (Ctrl+b yerine Ctrl+a)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Mouse desteği
set -g mouse on

# 256 renk desteği
set -g default-terminal "screen-256color"

# Pencere numaraları 1'den başlasın
set -g base-index 1
setw -g pane-base-index 1

# Escape time azalt
set -sg escape-time 0

# History limit
set -g history-limit 10000

# Otomatik pencere yeniden numaralandırma
set -g renumber-windows on

EOF
    
    # Temaya özel renkler
    case $theme in
        dracula)
            cat >> "$tmux_conf" << 'EOF'
# Dracula Theme
set -g status-style bg='#282a36',fg='#f8f8f2'
set -g window-status-current-style bg='#bd93f9',fg='#282a36'
set -g pane-border-style fg='#6272a4'
set -g pane-active-border-style fg='#ff79c6'
set -g message-style bg='#44475a',fg='#f8f8f2'
EOF
            ;;
        nord)
            cat >> "$tmux_conf" << 'EOF'
# Nord Theme
set -g status-style bg='#2e3440',fg='#d8dee9'
set -g window-status-current-style bg='#88c0d0',fg='#2e3440'
set -g pane-border-style fg='#4c566a'
set -g pane-active-border-style fg='#88c0d0'
set -g message-style bg='#3b4252',fg='#d8dee9'
EOF
            ;;
        gruvbox)
            cat >> "$tmux_conf" << 'EOF'
# Gruvbox Theme
set -g status-style bg='#282828',fg='#ebdbb2'
set -g window-status-current-style bg='#fabd2f',fg='#282828'
set -g pane-border-style fg='#504945'
set -g pane-active-border-style fg='#fabd2f'
set -g message-style bg='#504945',fg='#ebdbb2'
EOF
            ;;
        tokyo-night)
            cat >> "$tmux_conf" << 'EOF'
# Tokyo Night Theme
set -g status-style bg='#1a1b26',fg='#c0caf5'
set -g window-status-current-style bg='#7aa2f7',fg='#1a1b26'
set -g pane-border-style fg='#414868'
set -g pane-active-border-style fg='#7aa2f7'
set -g message-style bg='#414868',fg='#c0caf5'
EOF
            ;;
        catppuccin)
            cat >> "$tmux_conf" << 'EOF'
# Catppuccin Theme
set -g status-style bg='#1e1e2e',fg='#cdd6f4'
set -g window-status-current-style bg='#89b4fa',fg='#1e1e2e'
set -g pane-border-style fg='#45475a'
set -g pane-active-border-style fg='#89b4fa'
set -g message-style bg='#45475a',fg='#cdd6f4'
EOF
            ;;
        one-dark)
            cat >> "$tmux_conf" << 'EOF'
# One Dark Theme
set -g status-style bg='#282c34',fg='#abb2bf'
set -g window-status-current-style bg='#61afef',fg='#282c34'
set -g pane-border-style fg='#5c6370'
set -g pane-active-border-style fg='#61afef'
set -g message-style bg='#3e4451',fg='#abb2bf'
EOF
            ;;
        solarized)
            cat >> "$tmux_conf" << 'EOF'
# Solarized Dark Theme
set -g status-style bg='#002b36',fg='#839496'
set -g window-status-current-style bg='#268bd2',fg='#fdf6e3'
set -g pane-border-style fg='#073642'
set -g pane-active-border-style fg='#268bd2'
set -g message-style bg='#073642',fg='#839496'
EOF
            ;;
        *)
            log_warning "Bilinmeyen tema, varsayılan renkler kullanılıyor"
            ;;
    esac
    
    # Status bar konfigürasyonu
    cat >> "$tmux_conf" << 'EOF'

# Status bar
set -g status-left-length 40
set -g status-left "#[bold] Session: #S "
set -g status-right "#[bold] %d %b %Y | %H:%M "
set -g status-justify centre

# Pencere listesi
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
EOF
    
    log_success "Tmux tema konfigürasyonu tamamlandı"
}

# Tmux tam kurulum
install_tmux_with_theme() {
    local theme=$1
    
    install_tmux || return 1
    configure_tmux_theme "$theme"
    
    log_info "Tmux'u test etmek için: tmux"
    log_info "Çıkmak için: Ctrl+a, sonra 'd'"
}

# ============================================================================
# TEMA KURULUMU - ANA FONKSİYON
# ============================================================================

install_theme() {
    local theme_name=$1
    
    log_info "Tema kuruluyor: $theme_name"
    
    local terminal=$(detect_terminal)
    log_debug "Tespit edilen terminal: $terminal"
    
    case $terminal in
        gnome-terminal)
            install_theme_gnome "$theme_name"
            ;;
        kitty)
            install_theme_kitty "$theme_name"
            ;;
        alacritty)
            install_theme_alacritty "$theme_name"
            ;;
        *)
            log_warning "Terminal tipi desteklenmiyor: $terminal"
            log_info "Sadece GNOME Terminal, Kitty ve Alacritty destekleniyor"
            return 1
            ;;
    esac
}

# ============================================================================
# GNOME TERMINAL TEMA KURULUMU
# ============================================================================

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
        dracula)
            apply_dracula_gnome "$PROFILE_PATH"
            ;;
        nord)
            apply_nord_gnome "$PROFILE_PATH"
            ;;
        gruvbox)
            apply_gruvbox_gnome "$PROFILE_PATH"
            ;;
        tokyo-night)
            apply_tokyo_night_gnome "$PROFILE_PATH"
            ;;
        catppuccin)
            apply_catppuccin_gnome "$PROFILE_PATH"
            ;;
        one-dark)
            apply_one_dark_gnome "$PROFILE_PATH"
            ;;
        solarized)
            apply_solarized_gnome "$PROFILE_PATH"
            ;;
        *)
            log_error "Bilinmeyen tema: $theme"
            return 1
            ;;
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

# ============================================================================
# KİTTY TEMA KURULUMU
# ============================================================================

install_theme_kitty() {
    local theme=$1
    
    if ! command -v kitty &> /dev/null; then
        log_warning "Kitty terminal bulunamadı"
        return 1
    fi
    
    local kitty_conf="$HOME/.config/kitty/kitty.conf"
    local theme_dir="$HOME/.config/kitty/themes"
    
    mkdir -p "$theme_dir"
    
    # Mevcut tema include'unu kaldır
    if [[ -f "$kitty_conf" ]]; then
        sed -i '/^include themes\//d' "$kitty_conf"
    fi
    
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
        # Diğer temalar için benzer şekilde...
    esac
    
    log_success "Kitty için $theme teması kuruldu"
    log_info "Değişiklikleri görmek için Kitty'yi yeniden başlatın"
}

# ============================================================================
# ALACRITTY TEMA KURULUMU
# ============================================================================

install_theme_alacritty() {
    local theme=$1
    
    if ! command -v alacritty &> /dev/null; then
        log_warning "Alacritty terminal bulunamadı"
        return 1
    fi
    
    local alacritty_conf="$HOME/.config/alacritty/alacritty.yml"
    
    mkdir -p "$(dirname "$alacritty_conf")"
    
    # Tema bölümünü hazırla
    local theme_config=""
    
    case $theme in
        dracula)
            theme_config="colors:
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
    white:   '#bfbfbf'"
            ;;
        nord)
            theme_config="colors:
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
    white:   '#e5e9f0'"
            ;;
    esac
    
    # Config dosyasını güncelle (basit yöntem)
    if [[ -f "$alacritty_conf" ]]; then
        # Mevcut colors bölümünü kaldır
        sed -i '/^colors:/,/^[^ ]/{ /^colors:/d; /^[^ ]/!d }' "$alacritty_conf"
    fi
    
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
# KALDIRMA
# ============================================================================

uninstall_all() {
    log_warning "Tüm özelleştirmeler kaldırılacak!"
    echo -n "Emin misiniz? (e/h): "
    read -r confirm
    
    if [[ "$confirm" != "e" ]]; then
        log_info "İptal edildi"
        return
    fi
    
    log_info "Kaldırma işlemi başlıyor..."
    
    # Bash'e geri dön
    if command -v bash &> /dev/null; then
        chsh -s $(which bash) 2>/dev/null && log_success "Varsayılan shell Bash'e döndürüldü" || log_warning "Shell değiştirilemedi"
    fi
    
    # Oh My Zsh'yi kaldır
    if [[ -d ~/.oh-my-zsh ]]; then
        rm -rf ~/.oh-my-zsh
        log_success "Oh My Zsh kaldırıldı"
    fi
    
    # Zsh config dosyalarını sil
    [[ -f ~/.zshrc ]] && rm ~/.zshrc && log_success ".zshrc silindi"
    [[ -f ~/.zsh_history ]] && rm ~/.zsh_history
    [[ -f ~/.p10k.zsh ]] && rm ~/.p10k.zsh && log_success ".p10k.zsh silindi"
    
    # Yedekten geri yükle
    if [[ -d "$BACKUP_DIR" ]]; then
        local latest_bashrc=$(ls -t "$BACKUP_DIR"/bashrc_* 2>/dev/null | head -1)
        if [[ -f "$latest_bashrc" ]]; then
            cp "$latest_bashrc" ~/.bashrc
            log_success ".bashrc yedekten geri yüklendi"
        fi
    fi
    
    # Zsh'yi kaldır (opsiyonel)
    echo -n "Zsh paketini de kaldırmak ister misiniz? (e/h): "
    read -r remove_zsh
    
    if [[ "$remove_zsh" == "e" ]]; then
        sudo apt remove -y zsh 2>/dev/null && log_success "Zsh paketi kaldırıldı"
        sudo apt autoremove -y 2>/dev/null
    fi
    
    echo
    log_success "Kaldırma tamamlandı!"
    log_info "Çıkış yapıp tekrar giriş yapın"
}