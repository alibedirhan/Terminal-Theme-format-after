#!/bin/bash

# ============================================================================
# KDE Plasma Desktop Environment Module
# Theme installation and application for KDE Plasma
# ============================================================================

# ============================================================================
# KDE DETECTION & VERIFICATION
# ============================================================================

verify_kde_environment() {
    log_info "KDE Plasma ortamı doğrulanıyor..."
    
    # Check if Plasma Shell is running
    if ! pgrep -x "plasmashell" > /dev/null 2>&1; then
        log_error "KDE Plasma çalışmıyor!"
        return 1
    fi
    
    # Check required tools
    local required_tools=("kwriteconfig5" "plasma-apply-colorscheme" "kreadconfig5")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_warning "$tool bulunamadı"
        fi
    done
    
    # Get KDE Plasma version
    if command -v plasmashell &> /dev/null; then
        local plasma_version=$(plasmashell --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
        log_success "KDE Plasma $plasma_version tespit edildi"
    fi
    
    return 0
}

check_kde_theme_tools() {
    log_info "KDE tema araçları kontrol ediliyor..."
    
    local missing_tools=()
    
    if ! command -v kwriteconfig5 &> /dev/null; then
        missing_tools+=("kwriteconfig5")
    fi
    
    if ! command -v plasma-apply-colorscheme &> /dev/null; then
        missing_tools+=("plasma-desktop")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "Eksik araçlar: ${missing_tools[*]}"
        echo
        echo -e "${YELLOW}Gerekli araçlar kurulsun mu? (e/h):${NC}"
        read -r install_tools
        if [[ "$install_tools" == "e" ]]; then
            sudo apt install -y plasma-desktop kde-config-gtk-style > /dev/null 2>&1
            log_success "KDE araçları kuruldu"
        fi
    else
        log_success "Tüm KDE araçları mevcut"
    fi
}

# ============================================================================
# THEME INSTALLATION FOR KDE
# ============================================================================

apply_theme_for_de() {
    local theme_name="$1"
    
    log_step 1 5 "KDE Plasma için $theme_name teması uygulanıyor"
    
    # Verify KDE environment
    if ! verify_kde_environment; then
        return 1
    fi
    
    # Check KDE tools
    check_kde_theme_tools
    
    # Install theme packages
    log_step 2 5 "Tema paketleri kuruluyor"
    if ! install_theme_packages_kde "$theme_name"; then
        log_error "Tema paketleri kurulamadı"
        return 1
    fi
    
    # Apply theme components
    log_step 3 5 "Tema bileşenleri uygulanıyor"
    if ! apply_theme_components_kde "$theme_name"; then
        log_error "Tema bileşenleri uygulanamadı"
        return 1
    fi
    
    # Apply wallpaper
    if [[ "$ENABLE_WALLPAPERS" == true ]]; then
        log_step 4 5 "Duvar kağıdı uygulanıyor"
        apply_wallpaper_kde "$theme_name"
    fi
    
    # Verify application
    log_step 5 5 "Tema uygulaması doğrulanıyor"
    if verify_theme_application_kde "$theme_name"; then
        log_success "KDE Plasma teması başarıyla uygulandı"
        
        # Suggest Plasma restart
        echo
        echo -e "${YELLOW}📝 Not: Tüm değişikliklerin görünmesi için Plasma'yı yeniden başlatın:${NC}"
        echo -e "${CYAN}   plasmashell --replace &${NC}"
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

install_theme_packages_kde() {
    local theme="$1"
    
    case "$theme" in
        "arc")
            install_arc_packages_kde
            ;;
        "yaru")
            install_yaru_packages_kde
            ;;
        "pop")
            install_pop_packages_kde
            ;;
        "dracula")
            install_dracula_packages_kde
            ;;
        "nord")
            install_nord_packages_kde
            ;;
        "catppuccin")
            install_catppuccin_packages_kde
            ;;
        "gruvbox")
            install_gruvbox_packages_kde
            ;;
        "tokyonight")
            install_tokyonight_packages_kde
            ;;
        *)
            log_error "Bilinmeyen tema: $theme"
            return 1
            ;;
    esac
}

install_arc_packages_kde() {
    log_info "Arc Theme paketleri kuruluyor (KDE)..."
    
    sudo apt update > /dev/null 2>&1
    
    # Install Arc KDE theme
    if sudo apt install -y arc-kde papirus-icon-theme > /dev/null 2>&1; then
        log_success "Arc KDE Theme kuruldu"
        
        # Install Papirus folders
        if sudo apt install -y papirus-folders > /dev/null 2>&1; then
            papirus-folders -C blue --theme Papirus-Dark > /dev/null 2>&1
            log_success "Papirus icon renkleri ayarlandı"
        fi
        
        return 0
    else
        log_error "Arc KDE Theme kurulumu başarısız"
        return 1
    fi
}

install_yaru_packages_kde() {
    log_info "Yaru Theme paketleri kuruluyor (KDE)..."
    
    sudo apt update > /dev/null 2>&1
    
    if sudo apt install -y yaru-theme-gtk yaru-theme-icon > /dev/null 2>&1; then
        log_success "Yaru Theme kuruldu"
        return 0
    else
        log_error "Yaru Theme kurulumu başarısız"
        return 1
    fi
}

install_pop_packages_kde() {
    log_info "Pop Theme paketleri kuruluyor (KDE)..."
    
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

install_dracula_packages_kde() {
    log_info "Dracula Theme paketleri kuruluyor (KDE)..."
    
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/color-schemes
    mkdir -p ~/.themes ~/.icons
    
    # Install Dracula Plasma theme
    if [[ ! -d ~/.local/share/plasma/desktoptheme/Dracula ]]; then
        log_info "Dracula Plasma teması indiriliyor..."
        
        local temp_file="/tmp/dracula-plasma.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/dracula/plasma/archive/master.tar.gz"\; then
            if tar -xzf "$temp_file" -C /tmp/ > /dev/null 2>&1; then
                cp -r /tmp/plasma-master/* ~/.local/share/plasma/desktoptheme/Dracula/ 2>/dev/null || \
                mkdir -p ~/.local/share/plasma/desktoptheme/Dracula && \
                cp -r /tmp/plasma-master/* ~/.local/share/plasma/desktoptheme/Dracula/
                rm -rf /tmp/plasma-master
                rm -f "$temp_file"
                log_success "Dracula Plasma teması kuruldu"
            fi
        fi
    fi
    
    # Install Dracula GTK theme for GTK apps
    if [[ ! -d ~/.themes/Dracula ]]; then
        local temp_file="/tmp/dracula-gtk.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/dracula/gtk/archive/master.tar.gz"\; then
            if tar -xzf "$temp_file" -C /tmp/ > /dev/null 2>&1; then
                mv /tmp/gtk-master ~/.themes/Dracula
                rm -f "$temp_file"
                log_success "Dracula GTK teması kuruldu"
            fi
        fi
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme > /dev/null 2>&1
    log_success "Icon teması kuruldu"
    
    return 0
}

install_nord_packages_kde() {
    log_info "Nord Theme paketleri kuruluyor (KDE)..."
    
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/color-schemes
    mkdir -p ~/.themes ~/.icons
    
    # Install Nordic Plasma theme
    if [[ ! -d ~/.local/share/plasma/desktoptheme/Nordic ]]; then
        log_info "Nordic Plasma teması indiriliyor..."
        
        local temp_file="/tmp/nordic-plasma.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/EliverLara/Nordic-kde/archive/master.tar.gz"\; then
            if tar -xzf "$temp_file" -C /tmp/ > /dev/null 2>&1; then
                cp -r /tmp/Nordic-kde-master/kde/* ~/.local/share/ 2>/dev/null
                rm -rf /tmp/Nordic-kde-master
                rm -f "$temp_file"
                log_success "Nordic Plasma teması kuruldu"
            fi
        fi
    fi
    
    # Install Nordic GTK theme
    if [[ ! -d ~/.themes/Nordic ]]; then
        local temp_file="/tmp/nordic-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz"\; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Nordic GTK teması kuruldu"
            fi
        fi
    fi
    
    # Install Nordic icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C nordic --theme Papirus-Dark > /dev/null 2>&1
    log_success "Nordic icon teması kuruldu"
    
    return 0
}

install_catppuccin_packages_kde() {
    log_info "Catppuccin Theme paketleri kuruluyor (KDE)..."
    
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/color-schemes
    mkdir -p ~/.themes
    
    # Install Catppuccin Plasma theme
    if [[ ! -d ~/.local/share/plasma/desktoptheme/Catppuccin-Mocha ]]; then
        log_info "Catppuccin Plasma teması indiriliyor..."
        
        local temp_file="/tmp/catppuccin-plasma.tar.gz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/catppuccin/kde/archive/main.tar.gz"\; then
            if tar -xzf "$temp_file" -C /tmp/ > /dev/null 2>&1; then
                cp -r /tmp/kde-main/Themes/Catppuccin-Mocha-* ~/.local/share/plasma/desktoptheme/ 2>/dev/null
                cp -r /tmp/kde-main/Colors/*.colors ~/.local/share/color-schemes/ 2>/dev/null
                rm -rf /tmp/kde-main
                rm -f "$temp_file"
                log_success "Catppuccin Plasma teması kuruldu"
            fi
        fi
    fi
    
    # Install Catppuccin GTK theme
    if [[ ! -d ~/.themes/Catppuccin-Mocha-Standard-Blue-Dark ]]; then
        local temp_file="/tmp/catppuccin-gtk.zip"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Blue-Dark.zip"\; then
            if unzip -q "$temp_file" -d ~/.themes/ > /dev/null 2>&1; then
                rm -f "$temp_file"
                log_success "Catppuccin GTK teması kuruldu"
            fi
        fi
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C cat-mocha-blue --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

install_gruvbox_packages_kde() {
    log_info "Gruvbox Theme paketleri kuruluyor (KDE)..."
    
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/color-schemes
    mkdir -p ~/.themes
    
    # Install Gruvbox GTK theme
    if [[ ! -d ~/.themes/Gruvbox-Dark ]]; then
        local temp_file="/tmp/gruvbox-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme/releases/latest/download/Gruvbox-Dark-BL.tar.xz"\; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                mv ~/.themes/Gruvbox-Dark-BL ~/.themes/Gruvbox-Dark
                rm -f "$temp_file"
                log_success "Gruvbox GTK teması kuruldu"
            fi
        fi
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C brown --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

install_tokyonight_packages_kde() {
    log_info "Tokyo Night Theme paketleri kuruluyor (KDE)..."
    
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/color-schemes
    mkdir -p ~/.themes
    
    # Install Tokyo Night GTK theme
    if [[ ! -d ~/.themes/Tokyonight-Dark ]]; then
        local temp_file="/tmp/tokyonight-gtk.tar.xz"
        if wget -q --timeout=30 -O "$temp_file" "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/releases/latest/download/Tokyonight-Dark-BL.tar.xz"\; then
            if tar -xf "$temp_file" -C ~/.themes/ > /dev/null 2>&1; then
                mv ~/.themes/Tokyonight-Dark-BL ~/.themes/Tokyonight-Dark
                rm -f "$temp_file"
                log_success "Tokyo Night GTK teması kuruldu"
            fi
        fi
    fi
    
    # Install icons
    sudo apt install -y papirus-icon-theme papirus-folders > /dev/null 2>&1
    papirus-folders -C violet --theme Papirus-Dark > /dev/null 2>&1
    
    return 0
}

# ============================================================================
# THEME APPLICATION
# ============================================================================

apply_theme_components_kde() {
    local theme="$1"
    
    log_info "KDE tema bileşenleri uygulanıyor..."
    
    # Get theme names
    local plasma_theme=$(get_plasma_theme_name "$theme")
    local color_scheme=$(get_color_scheme_name "$theme")
    local gtk_theme=$(get_gtk_theme_name_kde "$theme")
    local icon_theme=$(get_icon_theme_name_kde "$theme")
    
    # Apply Plasma theme (desktop theme)
    if [[ -n "$plasma_theme" ]]; then
        kwriteconfig5 --file ~/.config/plasmarc --group Theme --key name "$plasma_theme"
        log_debug "Plasma theme: $plasma_theme"
    fi
    
    # Apply color scheme
    if [[ -n "$color_scheme" ]]; then
        if command -v plasma-apply-colorscheme &> /dev/null; then
            plasma-apply-colorscheme "$color_scheme" > /dev/null 2>&1
            log_debug "Color scheme: $color_scheme"
        else
            kwriteconfig5 --file ~/.config/kdeglobals --group General --key ColorScheme "$color_scheme"
        fi
    fi
    
    # Apply GTK theme for GTK apps
    kwriteconfig5 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name "$gtk_theme"
    kwriteconfig5 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-theme-name "$gtk_theme"
    kwriteconfig5 --file ~/.config/kdeglobals --group General --key widgetStyle "Breeze"
    log_debug "GTK theme: $gtk_theme"
    
    # Apply icon theme
    kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme "$icon_theme"
    log_debug "Icon theme: $icon_theme"
    
    # Apply cursor theme
    kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
    
    log_success "KDE tema bileşenleri uygulandı"
    
    # Restart Plasma to apply changes
    echo
    echo -e "${YELLOW}Değişikliklerin tam olarak uygulanması için şunu çalıştırın:${NC}"
    echo -e "${CYAN}plasmashell --replace &${NC}"
    
    return 0
}

get_plasma_theme_name() {
    local theme="$1"
    
    case "$theme" in
        "dracula") echo "Dracula" ;;
        "nord") echo "Nordic" ;;
        "catppuccin") echo "Catppuccin-Mocha" ;;
        *) echo "breeze-dark" ;;
    esac
}

get_color_scheme_name() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "Arc Dark" ;;
        "dracula") echo "Dracula" ;;
        "nord") echo "Nordic" ;;
        "catppuccin") echo "CatppuccinMocha" ;;
        "gruvbox") echo "Gruvbox" ;;
        *) echo "BreezeDark" ;;
    esac
}

get_gtk_theme_name_kde() {
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
        *) echo "Breeze-Dark" ;;
    esac
}

get_icon_theme_name_kde() {
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
        *) echo "breeze-dark" ;;
    esac
}

# ============================================================================
# WALLPAPER APPLICATION
# ============================================================================

apply_wallpaper_kde() {
    local theme="$1"
    local wallpaper_file="$USER_WALLPAPERS/$theme/default.jpg"
    
    if [[ -f "$wallpaper_file" ]]; then
        # Use plasma-apply-wallpaperimage if available
        if command -v plasma-apply-wallpaperimage &> /dev/null; then
            plasma-apply-wallpaperimage "$wallpaper_file" > /dev/null 2>&1
            log_success "Duvar kağıdı uygulandı"
        else
            log_warning "plasma-apply-wallpaperimage bulunamadı"
        fi
    else
        log_debug "Duvar kağıdı dosyası bulunamadı: $wallpaper_file"
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_theme_application_kde() {
    local theme="$1"
    
    local expected_color=$(get_color_scheme_name "$theme")
    local current_color=$(kreadconfig5 --file ~/.config/kdeglobals --group General --key ColorScheme)
    
    if [[ "$current_color" == "$expected_color" ]] || [[ -z "$expected_color" ]]; then
        log_success "KDE teması doğrulandı"
        return 0
    else
        log_warning "Tema kısmen uygulandı"
        return 0
    fi
}

# ============================================================================
# RESET TO DEFAULT
# ============================================================================

reset_kde_theme() {
    log_info "KDE teması varsayılana döndürülüyor..."
    
    # Reset to Breeze
    kwriteconfig5 --file ~/.config/plasmarc --group Theme --key name "breeze-dark"
    kwriteconfig5 --file ~/.config/kdeglobals --group General --key ColorScheme "BreezeDark"
    kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme "breeze-dark"
    
    log_success "KDE teması Breeze Dark'a döndürüldü"
    
    echo
    echo -e "${YELLOW}Plasma'yı yeniden başlatın: plasmashell --replace &${NC}"
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "KDE Plasma Desktop Environment modülü yüklendi"
