#!/bin/bash

# ============================================================================
# GNOME Desktop Environment Module
# Theme installation and application for GNOME Shell
# ============================================================================

# ============================================================================
# GNOME DETECTION & VERIFICATION
# ============================================================================

verify_gnome_environment() {
    log_info "GNOME ortamı doğrulanıyor..."
    
    # Check if GNOME Shell is running
    if ! pgrep -x "gnome-shell" > /dev/null 2>&1; then
        log_error "GNOME Shell çalışmıyor!"
        return 1
    fi
    
    # Check gsettings
    if ! command -v gsettings &> /dev/null; then
        log_error "gsettings bulunamadı!"
        return 1
    fi
    
    # Get GNOME version
    local gnome_version=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.\d+')
    log_success "GNOME $gnome_version tespit edildi"
    
    return 0
}

check_gnome_extensions() {
    log_info "GNOME extensions kontrol ediliyor..."
    
    if ! command -v gnome-extensions &> /dev/null; then
        log_warning "gnome-extensions-app kurulu değil"
        return 1
    fi
    
    # Check if User Themes extension is installed
    if gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
        if gnome-extensions info user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null | grep -q "State: ENABLED"; then
            log_success "User Themes extension aktif"
            return 0
        else
            log_warning "User Themes extension kurulu ama aktif değil"
            return 2
        fi
    else
        log_warning "User Themes extension kurulu değil"
        return 3
    fi
}

install_user_themes_extension() {
    log_info "User Themes extension kuruluyor..."
    
    # Try to install from package
    if sudo apt install -y gnome-shell-extension-user-theme > /dev/null 2>&1; then
        log_success "User Themes extension kuruldu"
        
        # Enable extension
        gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null
        
        log_info "GNOME Shell yeniden başlatılmalı (Alt+F2 → 'r' → Enter)"
        return 0
    else
        log_error "User Themes extension kurulamadı"
        log_info "Manuel kurulum: https://extensions.gnome.org/extension/19/user-themes/"
        return 1
    fi
}

# ============================================================================
# THEME INSTALLATION FOR GNOME
# ============================================================================

apply_theme_for_de() {
    local theme_name="$1"
    
    log_step 1 5 "GNOME için $theme_name teması uygulanıyor"
    
    # Verify GNOME environment
    if ! verify_gnome_environment; then
        return 1
    fi
    
    # Check and install User Themes extension if needed
    local ext_status=$(check_gnome_extensions)
    if [[ $? -eq 3 ]]; then
        echo
        echo -e "${YELLOW}User Themes extension gerekli. Kurulsun mu? (e/h):${NC}"
        read -r install_ext
        if [[ "$install_ext" == "e" ]]; then
            install_user_themes_extension
        fi
    fi
    
    # Install theme packages
    log_step 2 5 "Tema paketleri kuruluyor"
    if ! install_theme_packages_gnome "$theme_name"; then
        log_error "Tema paketleri kurulamadı"
        return 1
    fi
    
    # Apply theme components
    log_step 3 5 "Tema bileşenleri uygulanıyor"
    if ! apply_theme_components_gnome "$theme_name"; then
        log_error "Tema bileşenleri uygulanamadı"
        return 1
    fi
    
    # Apply wallpaper
    if [[ "$ENABLE_WALLPAPERS" == true ]]; then
        log_step 4 5 "Duvar kağıdı uygulanıyor"
        apply_wallpaper_gnome "$theme_name"
    fi
    
    # Verify application
    log_step 5 5 "Tema uygulaması doğrulanıyor"
    if verify_theme_application_gnome "$theme_name"; then
        log_success "GNOME teması başarıyla uygulandı"
        return 0
    else
        log_warning "Tema uygulandı ama tam doğrulanamadı"
        return 0
    fi
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

install_theme_packages_gnome() {
    local theme="$1"
    
    case "$theme" in
        "arc")
            install_arc_packages_gnome
            ;;
        "yaru")
            install_yaru_packages_gnome
            ;;
        "pop")
            install_pop_packages_gnome
            ;;
        "dracula")
            install_dracula_packages_gnome
            ;;
        "nord")
            install_nord_packages_gnome
            ;;
        "catppuccin")
            install_catppuccin_packages_gnome
            ;;
        "gruvbox")
            install_gruvbox_packages_gnome
            ;;
        "tokyonight")
            install_tokyonight_packages_gnome
            ;;
        "cyberpunk")
            install_cyberpunk_packages_gnome
            ;;
        *)
            log_error "Bilinmeyen tema: $theme"
            return 1
            ;;
    esac
}

install_arc_packages_gnome() {
    log_info "Arc Theme paketleri kuruluyor..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y arc-theme papirus-icon-theme > /dev/null 2>&1; then
        log_success "Arc Theme kuruldu"
        
        # Install Papirus folders for color customization
        if sudo apt install -y papirus-folders > /dev/null 2>&1; then
            # Set blue folders for Arc
            papirus-folders -C blue --theme Papirus-Dark > /dev/null 2>&1
            log_success "Papirus icon renkleri ayarlandı"
        fi
        
        return 0
    else
        log_error "Arc Theme kurulumu başarısız"
        return 1
    fi
}

install_yaru_packages_gnome() {
    log_info "Yaru Theme paketleri kuruluyor..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y yaru-theme-gtk yaru-theme-icon yaru-theme-gnome-shell > /dev/null 2>&1; then
        log_success "Yaru Theme kuruldu"
        return 0
    else
        log_error "Yaru Theme kurulumu başarısız"
        return 1
    fi
}

install_pop_packages_gnome() {
    log_info "Pop Theme paketleri kuruluyor..."
    
    # Add Pop OS PPA if not exists
    if ! grep -q "system76/pop" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Pop OS PPA ekleniyor..."
        sudo add-apt-repository -y ppa:system76/pop > /dev/null 2>&1
    fi
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y pop-theme pop-icon-theme pop-gnome-shell-theme > /dev/null 2>&1; then
        log_success "Pop Theme kuruldu"
        return 0
    else
        log_error "Pop Theme kurulumu başarısız"
        return 1
    fi
}

install_dracula_packages_gnome() {
    log_info "Dracula Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install GTK theme
    if [[ ! -d ~/.themes/Dracula ]]; then
        log_info "Dracula GTK teması indiriliyor..."
        
        local temp_file="/tmp/dracula-gtk.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/dracula/gtk/archive/master.tar.gz"\; then
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
    
    # Install icon theme
    if [[ ! -d ~/.icons/Dracula ]]; then
        log_info "Dracula icon teması indiriliyor..."
        
        local temp_file="/tmp/dracula-icons.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/dracula/gtk/files/5214870/Dracula.zip"\; then
            if unzip -q "$temp_file" -d ~/.icons/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Dracula icon teması kuruldu"
            else
                rm -f "$temp_file"
                # Fallback to Papirus
                sudo apt install -y papirus-icon-theme > /dev/null 2>&1
                log_info "Alternatif: Papirus icon teması kullanılacak"
            fi
        else
            # Fallback to Papirus
            sudo apt install -y papirus-icon-theme > /dev/null 2>&1
            log_info "Alternatif: Papirus icon teması kullanılacak"
        fi
    else
        log_success "Dracula icon teması zaten kurulu"
    fi
    
    return 0
}

install_nord_packages_gnome() {
    log_info "Nord Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Nordic GTK theme
    if [[ ! -d ~/.themes/Nordic ]]; then
        log_info "Nordic GTK teması indiriliyor..."
        
        local temp_file="/tmp/nordic-gtk.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz"\; then
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
    if [[ ! -d ~/.icons/Nordic ]]; then
        log_info "Nordic icon teması indiriliyor..."
        
        # Try to install from latest release
        local temp_file="/tmp/nordic-icons.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic-Icons.tar.xz"\; then
            if tar -xf "$temp_file" -C ~/.icons/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Nordic icon teması kuruldu"
            else
                rm -f "$temp_file"
                # Fallback to Papirus with Nordic colors
                sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
                papirus-folders -C nordic --theme Papirus-Dark > /dev/null 2>&1
                log_info "Alternatif: Papirus (Nordic renkleri) kullanılacak"
            fi
        else
            # Fallback to Papirus
            sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
            papirus-folders -C nordic --theme Papirus-Dark > /dev/null 2>&1
            log_info "Alternatif: Papirus (Nordic renkleri) kullanılacak"
        fi
    else
        log_success "Nordic icon teması zaten kurulu"
    fi
    
    return 0
}

install_catppuccin_packages_gnome() {
    log_info "Catppuccin Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Catppuccin GTK theme (Mocha variant)
    if [[ ! -d ~/.themes/Catppuccin-Mocha-Standard-Blue-Dark ]]; then
        log_info "Catppuccin GTK teması indiriliyor..."
        
        local temp_file="/tmp/catppuccin-gtk.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Blue-Dark.zip"\; then
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
    
    # Install Papirus icons with Catppuccin colors
    if ! dpkg -l | grep -q papirus-icon-theme; then
        sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
        papirus-folders -C cat-mocha-blue --theme Papirus-Dark > /dev/null 2>&1
        log_success "Papirus icon teması (Catppuccin renkleri) kuruldu"
    fi
    
    return 0
}

install_gruvbox_packages_gnome() {
    log_info "Gruvbox Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Gruvbox GTK theme
    if [[ ! -d ~/.themes/Gruvbox-Dark ]]; then
        log_info "Gruvbox GTK teması indiriliyor..."
        
        local temp_file="/tmp/gruvbox-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme/releases/latest/download/Gruvbox-Dark-BL.tar.xz"\; then
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
    
    # Install Papirus icons with Gruvbox colors
    if ! dpkg -l | grep -q papirus-icon-theme; then
        sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
        papirus-folders -C brown --theme Papirus-Dark > /dev/null 2>&1
        log_success "Papirus icon teması (Gruvbox renkleri) kuruldu"
    fi
    
    return 0
}

install_tokyonight_packages_gnome() {
    log_info "Tokyo Night Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons
    
    # Install Tokyo Night GTK theme
    if [[ ! -d ~/.themes/Tokyonight-Dark ]]; then
        log_info "Tokyo Night GTK teması indiriliyor..."
        
        local temp_file="/tmp/tokyonight-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/releases/latest/download/Tokyonight-Dark-BL.tar.xz"\; then
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
    
    # Install Papirus icons with Tokyo Night colors
    if ! dpkg -l | grep -q papirus-icon-theme; then
        sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
        papirus-folders -C violet --theme Papirus-Dark > /dev/null 2>&1
        log_success "Papirus icon teması (Tokyo Night renkleri) kuruldu"
    fi
    
    return 0
}

install_cyberpunk_packages_gnome() {
    log_info "Cyberpunk Theme paketleri kuruluyor..."
    
    mkdir -p ~/.themes ~/.icons ~/.backgrounds
    
    # Install Cyberpunk GTK theme
    if [[ ! -d ~/.themes/Cyberpunk-Neon ]]; then
        log_info "Cyberpunk GTK teması indiriliyor..."
        
        local temp_file="/tmp/cyberpunk-gtk.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Roboron3042/Cyberpunk-Neon/archive/master.zip"\; then
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
    
    # Install Papirus icons with cyan colors
    if ! dpkg -l | grep -q papirus-icon-theme; then
        sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
        papirus-folders -C cyan --theme Papirus-Dark > /dev/null 2>&1
        log_success "Papirus icon teması (Cyberpunk renkleri) kuruldu"
    fi
    
    return 0
}

# ============================================================================
# THEME APPLICATION
# ============================================================================

apply_theme_components_gnome() {
    local theme="$1"
    
    # Get theme details
    local gtk_theme=$(get_gtk_theme_name "$theme")
    local icon_theme=$(get_icon_theme_name "$theme")
    local shell_theme=$(get_shell_theme_name "$theme")
    local cursor_theme=$(get_cursor_theme_name "$theme")
    
    log_info "Tema bileşenleri uygulanıyor..."
    
    # Apply GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
    log_debug "GTK theme: $gtk_theme"
    
    # Apply icon theme
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
    log_debug "Icon theme: $icon_theme"
    
    # Apply cursor theme
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
    log_debug "Cursor theme: $cursor_theme"
    
    # Apply shell theme (if User Themes extension is enabled)
    if check_gnome_extensions &> /dev/null; then
        gsettings set org.gnome.shell.extensions.user-theme name "$shell_theme" 2>/dev/null
        log_debug "Shell theme: $shell_theme"
    else
        log_warning "User Themes extension aktif değil, shell teması uygulanamadı"
    fi
    
    # Set color scheme to dark
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    
    # Preserve font settings (don't change fonts)
    log_info "Font ayarları korunuyor..."
    
    log_success "Tema bileşenleri uygulandı"
    return 0
}

get_gtk_theme_name() {
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
        *) echo "Adwaita-dark" ;;
    esac
}

get_icon_theme_name() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "Papirus-Dark" ;;
        "yaru") echo "Yaru" ;;
        "pop") echo "Pop" ;;
        "dracula") echo "Dracula" ;;
        "nord") echo "Nordic" ;;
        "catppuccin") echo "Papirus-Dark" ;;
        "gruvbox") echo "Papirus-Dark" ;;
        "tokyonight") echo "Papirus-Dark" ;;
        "cyberpunk") echo "Papirus-Dark" ;;
        *) echo "Adwaita" ;;
    esac
}

get_shell_theme_name() {
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
        *) echo "" ;;
    esac
}

get_cursor_theme_name() {
    local theme="$1"
    
    case "$theme" in
        "yaru") echo "Yaru" ;;
        "pop") echo "Pop" ;;
        *) echo "Adwaita" ;;
    esac
}

# ============================================================================
# WALLPAPER APPLICATION
# ============================================================================

apply_wallpaper_gnome() {
    local theme="$1"
    local wallpaper_file="$USER_WALLPAPERS/$theme/default.jpg"
    
    if [[ -f "$wallpaper_file" ]]; then
        local wallpaper_uri="file://$wallpaper_file"
        
        gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"
        gsettings set org.gnome.desktop.background picture-uri-dark "$wallpaper_uri"
        
        log_success "Duvar kağıdı uygulandı"
    else
        log_debug "Duvar kağıdı dosyası bulunamadı: $wallpaper_file"
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_theme_application_gnome() {
    local theme="$1"
    
    local expected_gtk=$(get_gtk_theme_name "$theme")
    local current_gtk=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
    
    if [[ "$current_gtk" == "$expected_gtk" ]]; then
        log_success "GTK teması doğrulandı: $current_gtk"
        return 0
    else
        log_warning "GTK teması beklenenden farklı: $current_gtk (beklenen: $expected_gtk)"
        return 1
    fi
}

# ============================================================================
# RESET TO DEFAULT
# ============================================================================

reset_gnome_theme() {
    log_info "GNOME teması varsayılana döndürülüyor..."
    
    gsettings reset org.gnome.desktop.interface gtk-theme
    gsettings reset org.gnome.desktop.interface icon-theme
    gsettings reset org.gnome.desktop.interface cursor-theme
    gsettings reset org.gnome.desktop.interface color-scheme
    
    # Reset shell theme
    gsettings set org.gnome.shell.extensions.user-theme name "" 2>/dev/null
    
    log_success "GNOME teması varsayılana döndürüldü"
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "GNOME Desktop Environment modülü yüklendi"
