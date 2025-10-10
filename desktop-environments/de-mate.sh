#!/bin/bash

# ============================================================================
# MATE Desktop Environment Module
# Theme installation and application for MATE Desktop
# ============================================================================

# ============================================================================
# MATE DETECTION & VERIFICATION
# ============================================================================

verify_mate_environment() {
    log_info "MATE ortamı doğrulanıyor..."
    
    # Check if MATE session is running
    if ! pgrep -x "mate-session" > /dev/null 2>&1; then
        log_error "MATE çalışmıyor!"
        return 1
    fi
    
    # Check gsettings (MATE uses gsettings like GNOME)
    if ! command -v gsettings &> /dev/null; then
        log_error "gsettings bulunamadı!"
        return 1
    fi
    
    # Get MATE version
    if command -v mate-about &> /dev/null; then
        local mate_version=$(mate-about --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
        log_success "MATE $mate_version tespit edildi"
    fi
    
    return 0
}

check_mate_tools() {
    log_info "MATE tema araçları kontrol ediliyor..."
    
    local required_tools=("mate-appearance-properties" "mate-control-center")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "Eksik araçlar: ${missing_tools[*]}"
        echo
        echo -e "${YELLOW}Gerekli araçlar kurulsun mu? (e/h):${NC}"
        read -r install_tools
        if [[ "$install_tools" == "e" ]]; then
            sudo apt install -y mate-control-center > /dev/null 2>&1
            log_success "MATE araçları kuruldu"
        fi
    else
        log_success "Tüm MATE araçları mevcut"
    fi
}

# ============================================================================
# THEME INSTALLATION FOR MATE
# ============================================================================

apply_theme_for_de() {
    local theme_name="$1"
    
    log_step 1 5 "MATE için $theme_name teması uygulanıyor"
    
    # Verify MATE environment
    if ! verify_mate_environment; then
        return 1
    fi
    
    # Check MATE tools
    check_mate_tools
    
    # Install theme packages
    log_step 2 5 "Tema paketleri kuruluyor"
    if ! install_theme_packages_mate "$theme_name"; then
        log_error "Tema paketleri kurulamadı"
        return 1
    fi
    
    # Apply theme components
    log_step 3 5 "Tema bileşenleri uygulanıyor"
    if ! apply_theme_components_mate "$theme_name"; then
        log_error "Tema bileşenleri uygulanamadı"
        return 1
    fi
    
    # Apply wallpaper
    if [[ "$ENABLE_WALLPAPERS" == true ]]; then
        log_step 4 5 "Duvar kağıdı uygulanıyor"
        apply_wallpaper_mate "$theme_name"
    fi
    
    # Verify application
    log_step 5 5 "Tema uygulaması doğrulanıyor"
    if verify_theme_application_mate "$theme_name"; then
        log_success "MATE teması başarıyla uygulandı"
        
        # Suggest panel restart
        echo
        echo -e "${YELLOW}📝 Not: Panel'i yeniden başlatmak için:${NC}"
        echo -e "${CYAN}   mate-panel --replace &${NC}"
        echo
        
        return 0
    else
        log_warning "Tema uygulandı ama tam doğrulanamadı"
        return 0
    fi
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

install_theme_packages_mate() {
    local theme="$1"
    
    case "$theme" in
        "arc")
            install_arc_packages_mate
            ;;
        "yaru")
            install_yaru_packages_mate
            ;;
        "pop")
            install_pop_packages_mate
            ;;
        "dracula")
            install_dracula_packages_mate
            ;;
        "nord")
            install_nord_packages_mate
            ;;
        "catppuccin")
            install_catppuccin_packages_mate
            ;;
        "gruvbox")
            install_gruvbox_packages_mate
            ;;
        "tokyonight")
            install_tokyonight_packages_mate
            ;;
        "cyberpunk")
            install_cyberpunk_packages_mate
            ;;
        *)
            log_error "Bilinmeyen tema: $theme"
            return 1
            ;;
    esac
}

install_arc_packages_mate() {
    log_info "Arc Theme paketleri kuruluyor (MATE)..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y arc-theme papirus-icon-theme > /dev/null 2>&1; then
        log_success "Arc Theme kuruldu"
        
        # Install Papirus folders
        if sudo apt install -y papirus-folders > /dev/null 2>&1; then
            papirus-folders -C blue --theme Papirus-Dark > /dev/null 2>&1
            log_success "Papirus icon renkleri ayarlandı"
        fi
        
        return 0
    else
        log_error "Arc Theme kurulumu başarısız"
        return 1
    fi
}

install_yaru_packages_mate() {
    log_info "Yaru Theme paketleri kuruluyor (MATE)..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y yaru-theme-gtk yaru-theme-icon > /dev/null 2>&1; then
        log_success "Yaru Theme kuruldu"
        return 0
    else
        log_error "Yaru Theme kurulumu başarısız"
        return 1
    fi
}

install_pop_packages_mate() {
    log_info "Pop Theme paketleri kuruluyor (MATE)..."
    
    # Add Pop OS PPA
    if ! grep -q "system76/pop" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Pop OS PPA ekleniyor..."
        sudo add-apt-repository -y ppa:system76/pop > /dev/null 2>&1
    fi
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y pop-theme pop-icon-theme > /dev/null 2>&1; then
        log_success "Pop Theme kuruldu"
        return 0
    else
        log_error "Pop Theme kurulumu başarısız"
        return 1
    fi
}

install_dracula_packages_mate() {
    log_info "Dracula Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Dracula GTK theme
    if [[ ! -d ~/.themes/Dracula ]]; then
        log_info "Dracula GTK teması indiriliyor..."
        
        local temp_file="/tmp/dracula-gtk.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/dracula/gtk/archive/master.tar.gz"; then
            if tar -xzf "$temp_file" -C /tmp/ > /dev/null 2>&1; then
                mv /tmp/gtk-master ~/.themes/Dracula
                rm -f "$temp_file"
                log_success "Dracula GTK teması kuruldu"
            else
                log_error "Dracula teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Dracula teması indirilemedi"
            return 1
        fi
    else
        log_success "Dracula GTK teması zaten kurulu"
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme > /dev/null 2>&1
    log_success "Icon teması kuruldu"
    
    return 0
}

install_nord_packages_mate() {
    log_info "Nord Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Nordic GTK theme
    if [[ ! -d ~/.themes/Nordic ]]; then
        log_info "Nordic GTK teması indiriliyor..."
        
        local temp_file="/tmp/nordic-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz"; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Nordic GTK teması kuruldu"
            else
                log_error "Nordic teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Nordic teması indirilemedi"
            return 1
        fi
    else
        log_success "Nordic GTK teması zaten kurulu"
    fi
    
    # Install Nordic icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C nordic --theme Papirus-Dark > /dev/null 2>&1
    log_success "Nordic icon teması kuruldu"
    
    return 0
}

install_catppuccin_packages_mate() {
    log_info "Catppuccin Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes
    
    # Install Catppuccin GTK theme
    if [[ ! -d ~/.themes/Catppuccin-Mocha-Standard-Blue-Dark ]]; then
        log_info "Catppuccin GTK teması indiriliyor..."
        
        local temp_file="/tmp/catppuccin-gtk.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Blue-Dark.zip"; then
            if unzip -q "$temp_file" -d ~/.themes/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Catppuccin GTK teması kuruldu"
            else
                log_error "Catppuccin teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Catppuccin teması indirilemedi"
            return 1
        fi
    else
        log_success "Catppuccin GTK teması zaten kurulu"
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C cat-mocha-blue --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

install_gruvbox_packages_mate() {
    log_info "Gruvbox Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes
    
    # Install Gruvbox GTK theme
    if [[ ! -d ~/.themes/Gruvbox-Dark ]]; then
        log_info "Gruvbox GTK teması indiriliyor..."
        
        local temp_file="/tmp/gruvbox-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme/releases/latest/download/Gruvbox-Dark-BL.tar.xz"; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                mv ~/.themes/Gruvbox-Dark-BL ~/.themes/Gruvbox-Dark
                rm -f "$temp_file"
                log_success "Gruvbox GTK teması kuruldu"
            else
                log_error "Gruvbox teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Gruvbox teması indirilemedi"
            return 1
        fi
    else
        log_success "Gruvbox GTK teması zaten kurulu"
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C brown --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

install_tokyonight_packages_mate() {
    log_info "Tokyo Night Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes
    
    # Install Tokyo Night GTK theme
    if [[ ! -d ~/.themes/Tokyonight-Dark ]]; then
        log_info "Tokyo Night GTK teması indiriliyor..."
        
        local temp_file="/tmp/tokyonight-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/releases/latest/download/Tokyonight-Dark-BL.tar.xz"; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                mv ~/.themes/Tokyonight-Dark-BL ~/.themes/Tokyonight-Dark
                rm -f "$temp_file"
                log_success "Tokyo Night GTK teması kuruldu"
            else
                log_error "Tokyo Night teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Tokyo Night teması indirilemedi"
            return 1
        fi
    else
        log_success "Tokyo Night GTK teması zaten kurulu"
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C violet --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

install_cyberpunk_packages_mate() {
    log_info "Cyberpunk Theme paketleri kuruluyor (MATE)..."
    
    mkdir -p ~/.themes ~/.backgrounds
    
    # Install Cyberpunk GTK theme
    if [[ ! -d ~/.themes/Cyberpunk-Neon ]]; then
        log_info "Cyberpunk GTK teması indiriliyor..."
        
        local temp_file="/tmp/cyberpunk-gtk.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Roboron3042/Cyberpunk-Neon/archive/master.zip"; then
            if unzip -q "$temp_file" -d /tmp/ > /dev/null 2>&1; then
                cp -r /tmp/Cyberpunk-Neon-master/gtk/Cyberpunk-Neon ~/.themes/ 2>/dev/null
                rm -rf /tmp/Cyberpunk-Neon-master
                rm -f "$temp_file"
                log_success "Cyberpunk GTK teması kuruldu"
            else
                log_error "Cyberpunk teması çıkarılamadı"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Cyberpunk teması indirilemedi"
            return 1
        fi
    else
        log_success "Cyberpunk GTK teması zaten kurulu"
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C cyan --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

# ============================================================================
# THEME APPLICATION
# ============================================================================

apply_theme_components_mate() {
    local theme="$1"
    
    log_info "MATE tema bileşenleri uygulanıyor..."
    
    # Get theme names
    local gtk_theme=$(get_gtk_theme_name_mate "$theme")
    local icon_theme=$(get_icon_theme_name_mate "$theme")
    local wm_theme=$(get_wm_theme_name_mate "$theme")
    
    # Apply GTK theme (MATE uses org.mate.interface)
    gsettings set org.mate.interface gtk-theme "$gtk_theme"
    log_debug "GTK theme: $gtk_theme"
    
    # Apply icon theme
    gsettings set org.mate.interface icon-theme "$icon_theme"
    log_debug "Icon theme: $icon_theme"
    
    # Apply window manager theme (Marco)
    gsettings set org.mate.Marco.general theme "$wm_theme"
    log_debug "WM theme: $wm_theme"
    
    # Apply cursor theme
    gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    
    # Preserve font settings (don't change fonts)
    log_info "Font ayarları korunuyor..."
    
    log_success "MATE tema bileşenleri uygulandı"
    
    return 0
}

get_gtk_theme_name_mate() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "Arc-Dark" ;;
        "yaru") echo "Yaru-dark" ;;
        "pop") echo "Pop-dark" ;;
        "dracula") echo "Dracula" ;;
        "nord") echo "Nordic" ;;
        "catppuccin") echo "Catppuccin-Mocha-Standard-Blue-Dark" ;;
        "gruvbox") echo "Gruvbox-Dark" ;;
        "tokyonight") echo "Tokyonight-Dark" ;;
        "cyberpunk") echo "Cyberpunk-Neon" ;;
        *) echo "Menta" ;;
    esac
}

get_icon_theme_name_mate() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "Papirus-Dark" ;;
        "yaru") echo "Yaru" ;;
        "pop") echo "Pop" ;;
        "dracula") echo "Papirus-Dark" ;;
        "nord") echo "Papirus-Dark" ;;
        "catppuccin") echo "Papirus-Dark" ;;
        "gruvbox") echo "Papirus-Dark" ;;
        "tokyonight") echo "Papirus-Dark" ;;
        "cyberpunk") echo "Papirus-Dark" ;;
        *) echo "mate" ;;
    esac
}

get_wm_theme_name_mate() {
    local theme="$1"
    
    # MATE uses Marco window manager
    case "$theme" in
        "arc") echo "Arc-Dark" ;;
        "yaru") echo "Yaru-dark" ;;
        "pop") echo "Pop-dark" ;;
        "dracula") echo "Dracula" ;;
        "nord") echo "Nordic" ;;
        "catppuccin") echo "Catppuccin-Mocha-Standard-Blue-Dark" ;;
        "gruvbox") echo "Gruvbox-Dark" ;;
        "tokyonight") echo "Tokyonight-Dark" ;;
        "cyberpunk") echo "Cyberpunk-Neon" ;;
        *) echo "Menta" ;;
    esac
}

# ============================================================================
# WALLPAPER APPLICATION
# ============================================================================

apply_wallpaper_mate() {
    local theme="$1"
    local wallpaper_file="$USER_WALLPAPERS/$theme/default.jpg"
    
    if [[ -f "$wallpaper_file" ]]; then
        # Apply wallpaper using MATE's settings
        gsettings set org.mate.background picture-filename "$wallpaper_file"
        
        log_success "Duvar kağıdı uygulandı"
    else
        log_debug "Duvar kağıdı dosyası bulunamadı: $wallpaper_file"
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_theme_application_mate() {
    local theme="$1"
    
    local expected_gtk=$(get_gtk_theme_name_mate "$theme")
    local current_gtk=$(gsettings get org.mate.interface gtk-theme | tr -d "'")
    
    if [[ "$current_gtk" == "$expected_gtk" ]]; then
        log_success "MATE teması doğrulandı: $current_gtk"
        return 0
    else
        log_warning "MATE teması beklenenden farklı: $current_gtk (beklenen: $expected_gtk)"
        return 1
    fi
}

# ============================================================================
# RESET TO DEFAULT
# ============================================================================

reset_mate_theme() {
    log_info "MATE teması varsayılana döndürülüyor..."
    
    # Reset to MATE default (Menta theme)
    gsettings reset org.mate.interface gtk-theme
    gsettings reset org.mate.interface icon-theme
    gsettings reset org.mate.Marco.general theme
    
    log_success "MATE teması varsayılana döndürüldü"
    
    echo
    echo -e "${YELLOW}Panel'i yeniden başlatın: mate-panel --replace &${NC}"
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "MATE Desktop Environment modülü yüklendi"
