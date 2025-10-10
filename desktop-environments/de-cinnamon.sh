#!/bin/bash

# ============================================================================
# Cinnamon Desktop Environment Module
# Theme installation and application for Cinnamon Desktop (Linux Mint)
# ============================================================================

# ============================================================================
# CINNAMON DETECTION & VERIFICATION
# ============================================================================

verify_cinnamon_environment() {
    log_info "Cinnamon ortamı doğrulanıyor..."
    
    # Check if Cinnamon is running
    if ! pgrep -x "cinnamon" > /dev/null 2>&1; then
        log_error "Cinnamon çalışmıyor!"
        return 1
    fi
    
    # Check gsettings (Cinnamon uses gsettings like GNOME)
    if ! command -v gsettings &> /dev/null; then
        log_error "gsettings bulunamadı!"
        return 1
    fi
    
    # Get Cinnamon version
    if command -v cinnamon &> /dev/null; then
        local cinnamon_version=$(cinnamon --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
        log_success "Cinnamon $cinnamon_version tespit edildi"
    fi
    
    return 0
}

check_cinnamon_tools() {
    log_info "Cinnamon tema araçları kontrol ediliyor..."
    
    if ! command -v cinnamon-settings &> /dev/null; then
        log_warning "cinnamon-settings bulunamadı"
        echo
        echo -e "${YELLOW}Cinnamon settings kurulsun mu? (e/h):${NC}"
        read -r install_tools
        if [[ "$install_tools" == "e" ]]; then
            sudo apt install -y cinnamon-control-center > /dev/null 2>&1
            log_success "Cinnamon araçları kuruldu"
        fi
    else
        log_success "Tüm Cinnamon araçları mevcut"
    fi
}

# ============================================================================
# THEME INSTALLATION FOR CINNAMON
# ============================================================================

apply_theme_for_de() {
    local theme_name="$1"
    
    log_step 1 5 "Cinnamon için $theme_name teması uygulanıyor"
    
    # Verify Cinnamon environment
    if ! verify_cinnamon_environment; then
        return 1
    fi
    
    # Check Cinnamon tools
    check_cinnamon_tools
    
    # Install theme packages
    log_step 2 5 "Tema paketleri kuruluyor"
    if ! install_theme_packages_cinnamon "$theme_name"; then
        log_error "Tema paketleri kurulamadı"
        return 1
    fi
    
    # Apply theme components
    log_step 3 5 "Tema bileşenleri uygulanıyor"
    if ! apply_theme_components_cinnamon "$theme_name"; then
        log_error "Tema bileşenleri uygulanamadı"
        return 1
    fi
    
    # Apply wallpaper
    if [[ "$ENABLE_WALLPAPERS" == true ]]; then
        log_step 4 5 "Duvar kağıdı uygulanıyor"
        apply_wallpaper_cinnamon "$theme_name"
    fi
    
    # Verify application
    log_step 5 5 "Tema uygulaması doğrulanıyor"
    if verify_theme_application_cinnamon "$theme_name"; then
        log_success "Cinnamon teması başarıyla uygulandı"
        
        # Suggest Cinnamon restart
        echo
        echo -e "${YELLOW}📝 Not: Tüm değişikliklerin görünmesi için:${NC}"
        echo -e "${CYAN}   cinnamon --replace &${NC}"
        echo -e "${YELLOW}   veya logout/login yapın${NC}"
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

install_theme_packages_cinnamon() {
    local theme="$1"
    
    case "$theme" in
        "arc")
            install_arc_packages_cinnamon
            ;;
        "yaru")
            install_yaru_packages_cinnamon
            ;;
        "pop")
            install_pop_packages_cinnamon
            ;;
        "dracula")
            install_dracula_packages_cinnamon
            ;;
        "nord")
            install_nord_packages_cinnamon
            ;;
        "catppuccin")
            install_catppuccin_packages_cinnamon
            ;;
        "gruvbox")
            install_gruvbox_packages_cinnamon
            ;;
        "tokyonight")
            install_tokyonight_packages_cinnamon
            ;;
        "cyberpunk")
            install_cyberpunk_packages_cinnamon
            ;;
        *)
            log_error "Bilinmeyen tema: $theme"
            return 1
            ;;
    esac
}

install_arc_packages_cinnamon() {
    log_info "Arc Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_yaru_packages_cinnamon() {
    log_info "Yaru Theme paketleri kuruluyor (Cinnamon)..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y yaru-theme-gtk yaru-theme-icon > /dev/null 2>&1; then
        log_success "Yaru Theme kuruldu"
        return 0
    else
        log_error "Yaru Theme kurulumu başarısız"
        return 1
    fi
}

install_pop_packages_cinnamon() {
    log_info "Pop Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_dracula_packages_cinnamon() {
    log_info "Dracula Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_nord_packages_cinnamon() {
    log_info "Nord Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_catppuccin_packages_cinnamon() {
    log_info "Catppuccin Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_gruvbox_packages_cinnamon() {
    log_info "Gruvbox Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_tokyonight_packages_cinnamon() {
    log_info "Tokyo Night Theme paketleri kuruluyor (Cinnamon)..."
    
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

install_cyberpunk_packages_cinnamon() {
    log_info "Cyberpunk Theme paketleri kuruluyor (Cinnamon)..."
    
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

apply_theme_components_cinnamon() {
    local theme="$1"
    
    log_info "Cinnamon tema bileşenleri uygulanıyor..."
    
    # Get theme names
    local gtk_theme=$(get_gtk_theme_name_cinnamon "$theme")
    local icon_theme=$(get_icon_theme_name_cinnamon "$theme")
    local cinnamon_theme=$(get_cinnamon_theme_name "$theme")
    
    # Apply GTK theme (Cinnamon uses org.cinnamon.desktop.interface)
    gsettings set org.cinnamon.desktop.interface gtk-theme "$gtk_theme"
    log_debug "GTK theme: $gtk_theme"
    
    # Apply icon theme
    gsettings set org.cinnamon.desktop.interface icon-theme "$icon_theme"
    log_debug "Icon theme: $icon_theme"
    
    # Apply Cinnamon shell theme
    gsettings set org.cinnamon.theme name "$cinnamon_theme" 2>/dev/null
    log_debug "Cinnamon theme: $cinnamon_theme"
    
    # Apply cursor theme
    gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
    
    # Preserve font settings (don't change fonts)
    log_info "Font ayarları korunuyor..."
    
    log_success "Cinnamon tema bileşenleri uygulandı"
    
    return 0
}

get_gtk_theme_name_cinnamon() {
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
        *) echo "Mint-Y-Dark" ;;
    esac
}

get_icon_theme_name_cinnamon() {
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
        *) echo "Mint-Y" ;;
    esac
}

get_cinnamon_theme_name() {
    local theme="$1"
    
    # Cinnamon shell themes (most themes use GTK theme name)
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
        *) echo "Mint-Y-Dark" ;;
    esac
}

# ============================================================================
# WALLPAPER APPLICATION
# ============================================================================

apply_wallpaper_cinnamon() {
    local theme="$1"
    local wallpaper_file="$USER_WALLPAPERS/$theme/default.jpg"
    
    if [[ -f "$wallpaper_file" ]]; then
        local wallpaper_uri="file://$wallpaper_file"
        
        # Apply wallpaper using Cinnamon's settings
        gsettings set org.cinnamon.desktop.background picture-uri "$wallpaper_uri"
        gsettings set org.cinnamon.desktop.background picture-options "zoom"
        
        log_success "Duvar kağıdı uygulandı"
    else
        log_debug "Duvar kağıdı dosyası bulunamadı: $wallpaper_file"
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_theme_application_cinnamon() {
    local theme="$1"
    
    local expected_gtk=$(get_gtk_theme_name_cinnamon "$theme")
    local current_gtk=$(gsettings get org.cinnamon.desktop.interface gtk-theme | tr -d "'")
    
    if [[ "$current_gtk" == "$expected_gtk" ]]; then
        log_success "Cinnamon teması doğrulandı: $current_gtk"
        return 0
    else
        log_warning "Cinnamon teması beklenenden farklı: $current_gtk (beklenen: $expected_gtk)"
        return 1
    fi
}

# ============================================================================
# RESET TO DEFAULT
# ============================================================================

reset_cinnamon_theme() {
    log_info "Cinnamon teması varsayılana döndürülüyor..."
    
    # Reset to Mint default (Mint-Y-Dark)
    gsettings reset org.cinnamon.desktop.interface gtk-theme
    gsettings reset org.cinnamon.desktop.interface icon-theme
    gsettings reset org.cinnamon.theme name
    
    log_success "Cinnamon teması Mint-Y-Dark'a döndürüldü"
    
    echo
    echo -e "${YELLOW}Cinnamon'u yeniden başlatın: cinnamon --replace &${NC}"
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "Cinnamon Desktop Environment modülü yüklendi"
