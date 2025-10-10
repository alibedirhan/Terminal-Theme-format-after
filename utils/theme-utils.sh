#!/bin/bash

# ============================================================================
# Theme Utilities - Common theme functions across all DEs
# ============================================================================

# ============================================================================
# PREVIEW & INFORMATION
# ============================================================================

show_theme_previews() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    TEMA ÖNİZLEMELERİ                         ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    show_theme_preview "arc" "Arc Dark + Papirus"
    show_theme_preview "yaru" "Yaru Dark"
    show_theme_preview "pop" "Pop Dark"
    show_theme_preview "dracula" "Dracula"
    show_theme_preview "nord" "Nord"
    show_theme_preview "catppuccin" "Catppuccin Mocha"
    show_theme_preview "gruvbox" "Gruvbox Dark"
    show_theme_preview "tokyonight" "Tokyo Night"
    show_theme_preview "cyberpunk" "Cyberpunk Neon"
    
    echo
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    read -p "Devam etmek için Enter'a basın..."
}

show_theme_preview() {
    local theme_id="$1"
    local theme_name="$2"
    
    echo -e "${BOLD}${MAGENTA}● $theme_name${NC}"
    
    case "$theme_id" in
        "arc")
            echo "   🎨 Stil: Modern, minimalist, flat design"
            echo "   🎯 Renkler: Mavi tonları, yuvarlak köşeler"
            echo "   ⚡ Performans: Hafif (RAM: Düşük)"
            echo "   ✨ Özellik: En popüler, Ubuntu 24.04 native"
            ;;
        "yaru")
            echo "   🎨 Stil: Ubuntu resmi tema"
            echo "   🎯 Renkler: Turuncu/mor Ubuntu renkleri"
            echo "   ⚡ Performans: Çok hafif (Native)"
            echo "   ✨ Özellik: %100 stabil, bağımlılık yok"
            ;;
        "pop")
            echo "   🎨 Stil: System76 optimize, modern flat"
            echo "   🎯 Renkler: Turuncu vurgular, temiz"
            echo "   ⚡ Performans: Hafif-orta"
            echo "   ✨ Özellik: NVIDIA driver uyumlu, tiling desteği"
            ;;
        "dracula")
            echo "   🎨 Stil: Developer favorisi, yüksek kontrast"
            echo "   🎯 Renkler: Mor/pembe/mavi dark palette"
            echo "   ⚡ Performans: Hafif"
            echo "   ✨ Özellik: Kod okunabilirliği yüksek, 200+ app desteği"
            ;;
        "nord")
            echo "   🎨 Stil: Arctic/Nordic tema, soğuk tonlar"
            echo "   🎯 Renkler: Mavi-gri arctic palette"
            echo "   ⚡ Performans: Hafif"
            echo "   ✨ Özellik: Göz yormayan, uzun süreli kullanım için ideal"
            ;;
        "catppuccin")
            echo "   🎨 Stil: Modern pastel, yeni trend"
            echo "   🎯 Renkler: Mocha palette (soft dark)"
            echo "   ⚡ Performans: Hafif"
            echo "   ✨ Özellik: 2024'ün en popüler teması"
            ;;
        "gruvbox")
            echo "   🎨 Stil: Retro warm dark, vintage"
            echo "   🎯 Renkler: Kahverengi/turuncu retro"
            echo "   ⚡ Performans: Hafif"
            echo "   ✨ Özellik: Developer'ların klasik tercihi"
            ;;
        "tokyonight")
            echo "   🎨 Stil: Neon Tokyo gece teması"
            echo "   🎯 Renkler: Mor/mavi neon tonları"
            echo "   ⚡ Performans: Hafif"
            echo "   ✨ Özellik: VS Code'un en popüler teması"
            ;;
        "cyberpunk")
            echo "   🎨 Stil: Futuristik neon, cyberpunk aesthetic"
            echo "   🎯 Renkler: Cyan/magenta/neon pink"
            echo "   ⚡ Performans: Orta"
            echo "   ✨ Özellik: Tam immersive deneyim + wallpaper"
            ;;
    esac
    echo
}

show_theme_tips() {
    local theme="$1"
    
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               ${theme^^} TEMA İPUÇLARI                        ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    case "$theme" in
        "arc")
            echo -e "${WHITE}🎨 Arc Dark İpuçları:${NC}"
            echo "   • Papirus folder renklerini değiştir:"
            echo "     papirus-folders -C [renk] --theme Papirus-Dark"
            echo "   • Renkler: blue, red, green, orange, purple"
            echo "   • Arc-Darker variant daha koyu"
            ;;
        "yaru")
            echo -e "${WHITE}🎨 Yaru Dark İpuçları:${NC}"
            echo "   • Ubuntu'nun native teması - extra ayar gerekmez"
            echo "   • Yaru-colorise ile renk değiştir"
            echo "   • En stabil seçenek, LTS için ideal"
            ;;
        "pop")
            echo -e "${WHITE}🎨 Pop OS İpuçları:${NC}"
            echo "   • Otomatik tiling: Super + Y"
            echo "   • Workspace geçiş: Super + Arrow"
            echo "   • Launcher: Super + /"
            ;;
        "dracula")
            echo -e "${WHITE}🎨 Dracula İpuçları:${NC}"
            echo "   • VS Code/Terminal/Browser için Dracula kurun"
            echo "   • Tam ekosistem: draculatheme.com"
            echo "   • Terminal colors otomatik uygulanır"
            ;;
        "nord")
            echo -e "${WHITE}🎨 Nord İpuçları:${NC}"
            echo "   • Nordic wallpaper paketi indir (soğuk ton uyumu)"
            echo "   • Terminal Nord color scheme kullan"
            echo "   • Firefox/Chrome Nord theme"
            ;;
        "catppuccin")
            echo -e "${WHITE}🎨 Catppuccin İpuçları:${NC}"
            echo "   • VS Code Catppuccin Mocha extension"
            echo "   • Firefox Catppuccin theme"
            echo "   • Discord Catppuccin theme"
            ;;
        "gruvbox")
            echo -e "${WHITE}🎨 Gruvbox İpuçları:${NC}"
            echo "   • Vim/Neovim için Gruvbox colorscheme"
            echo "   • Terminal Gruvbox palette kullan"
            echo "   • Warm retro wallpaper seç"
            ;;
        "tokyonight")
            echo -e "${WHITE}🎨 Tokyo Night İpuçları:${NC}"
            echo "   • VS Code Tokyo Night extension (en popüler)"
            echo "   • Neon wallpaper kullan"
            echo "   • Terminal Tokyo Night colors"
            ;;
        "cyberpunk")
            echo -e "${WHITE}🎨 Cyberpunk İpuçları:${NC}"
            echo "   • Cyberpunk wallpaper otomatik uygulandı"
            echo "   • Firefox 'Dark Neon' theme"
            echo "   • Neon icons + cursors combo"
            ;;
    esac
    
    echo
    echo -e "${YELLOW}💡 Genel İpuçları:${NC}"
    echo "   • GNOME Tweaks: sudo apt install gnome-tweaks"
    echo "   • Extensions: extensions.gnome.org"
    echo "   • Logout/login ile tüm değişiklikler aktif olur"
    echo
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================================
# COMPATIBILITY CHECKS
# ============================================================================

run_compatibility_check() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              SİSTEM UYUMLULUK KONTROLÜ                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    # Desktop Environment
    echo -e "${BOLD}🖥️  Desktop Environment:${NC}"
    echo "   $DETECTED_DE"
    echo
    
    # Ubuntu Version
    echo -e "${BOLD}🐧 Ubuntu Version:${NC}"
    echo "   $DETECTED_VERSION"
    if is_ubuntu_version_supported; then
        echo -e "   ${GREEN}✓ Destekleniyor${NC}"
    else
        echo -e "   ${YELLOW}⚠ LTS sürümü değil, bazı temalar çalışmayabilir${NC}"
    fi
    echo
    
    # GNOME Version (if GNOME)
    if [[ "$DETECTED_DE" == "GNOME" ]]; then
        local gnome_ver=$(detect_gnome_version)
        echo -e "${BOLD}🎨 GNOME Shell:${NC}"
        echo "   $gnome_ver"
        echo
    fi
    
    # Memory
    echo -e "${BOLD}💾 Sistem Belleği:${NC}"
    local mem=$(detect_system_memory)
    echo "   $mem"
    if [[ "${mem%GB}" -lt 4 ]]; then
        echo -e "   ${YELLOW}⚠ Düşük RAM - Hafif temalar önerilir (Arc, Yaru)${NC}"
    else
        echo -e "   ${GREEN}✓ Tüm temalar için yeterli${NC}"
    fi
    echo
    
    # GPU
    echo -e "${BOLD}🎮 GPU:${NC}"
    local gpu=$(detect_gpu)
    local gpu_vendor=$(detect_gpu_vendor)
    echo "   $gpu"
    echo "   Vendor: $gpu_vendor"
    case "$gpu_vendor" in
        "NVIDIA")
            echo -e "   ${GREEN}✓ Pop OS teması optimize${NC}"
            ;;
        "AMD")
            echo -e "   ${GREEN}✓ Yaru/Arc teması önerilir${NC}"
            ;;
        "Intel")
            echo -e "   ${GREEN}✓ Tüm temalar uyumlu${NC}"
            ;;
    esac
    echo
    
    # Screen Resolution
    echo -e "${BOLD}🖼️  Ekran Çözünürlüğü:${NC}"
    local resolution=$(detect_screen_resolution)
    echo "   $resolution"
    echo
    
    # ZSH Status
    echo -e "${BOLD}💻 Terminal Shell:${NC}"
    echo "   $DETECTED_ZSH"
    if is_zsh_active; then
        echo -e "   ${GREEN}✓ ZSH config korunacak${NC}"
    fi
    echo
    
    # GTK Version
    echo -e "${BOLD}🎨 GTK Version:${NC}"
    local gtk=$(detect_gtk_version)
    echo "   $gtk"
    echo
    
    # Available themes for DE
    echo -e "${BOLD}✨ Uyumlu Temalar ($DETECTED_DE):${NC}"
    local compatible=$(get_compatible_themes "$DETECTED_DE")
    for theme in $compatible; do
        echo "   • $theme"
    done
    echo
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}✅ Sistem kontrolü tamamlandı${NC}"
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# ============================================================================
# RESET & CLEANUP
# ============================================================================

reset_to_default() {
    echo
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║             VARSAYILAN TEMAYA DÖNÜLÜYOR                      ║${NC}"
    echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    echo -e "${RED}⚠️  DİKKAT: Bu işlem mevcut temayı sıfırlayacak!${NC}"
    echo
    read -p "Devam edilsin mi? (e/h): " confirm
    
    if [[ "$confirm" != "e" ]]; then
        log_info "İşlem iptal edildi"
        return
    fi
    
    log_info "Varsayılan temaya dönülüyor..."
    
    # Call DE-specific reset function
    case "$DETECTED_DE" in
        "GNOME")
            source "$SCRIPT_DIR/desktop-environments/de-gnome.sh"
            reset_gnome_theme
            ;;
        "KDE")
            source "$SCRIPT_DIR/desktop-environments/de-kde.sh"
            reset_kde_theme
            ;;
        "XFCE")
            source "$SCRIPT_DIR/desktop-environments/de-xfce.sh"
            reset_xfce_theme
            ;;
        "MATE")
            source "$SCRIPT_DIR/desktop-environments/de-mate.sh"
            reset_mate_theme
            ;;
        "Cinnamon")
            source "$SCRIPT_DIR/desktop-environments/de-cinnamon.sh"
            reset_cinnamon_theme
            ;;
        *)
            log_error "Desteklenmeyen DE: $DETECTED_DE"
            return 1
            ;;
    esac
    
    echo
    echo -e "${GREEN}✅ Varsayılan tema uygulandı${NC}"
    echo -e "${YELLOW}📝 Logout/login yapın${NC}"
    echo
    read -p "Devam etmek için Enter'a basın..."
}

cleanup_themes() {
    echo
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  TEMALARI TEMİZLE                            ║${NC}"
    echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    echo -e "${RED}⚠️  BU İŞLEM GERİ ALINAMAZ!${NC}"
    echo
    echo "Silinecek dizinler:"
    echo "  • ~/.themes/"
    echo "  • ~/.icons/"
    echo "  • ~/.local/share/themes/"
    echo "  • ~/.local/share/icons/"
    echo
    
    read -p "Tüm özel temalar silinsin mi? (e/h): " confirm
    
    if [[ "$confirm" != "e" ]]; then
        log_info "Temizleme iptal edildi"
        return
    fi
    
    log_info "Temalar temizleniyor..."
    
    # Remove custom themes
    rm -rf ~/.themes/* 2>/dev/null
    rm -rf ~/.icons/* 2>/dev/null
    rm -rf ~/.local/share/themes/* 2>/dev/null
    rm -rf ~/.local/share/icons/* 2>/dev/null
    
    # Reset to default theme
    reset_to_default
    
    log_success "Tüm özel temalar silindi"
    echo
    echo -e "${GREEN}✅ Temizlik tamamlandı${NC}"
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# ============================================================================
# SETTINGS MENU
# ============================================================================

show_settings_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                        AYARLAR                               ║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    # Current settings
    echo -e "${BOLD}Mevcut Ayarlar:${NC}"
    echo
    echo "  1. Wallpaper Desteği: $(if [[ "$ENABLE_WALLPAPERS" == true ]]; then echo "${GREEN}Aktif${NC}"; else echo "${RED}Kapalı${NC}"; fi)"
    echo "  2. ZSH Koruması: $(if [[ "$PROTECT_ZSH_CONFIG" == true ]]; then echo "${GREEN}Aktif${NC}"; else echo "${RED}Kapalı${NC}"; fi)"
    echo "  3. Terminal Font Koruması: $(if [[ "$PROTECT_TERMINAL_FONT" == true ]]; then echo "${GREEN}Aktif${NC}"; else echo "${RED}Kapalı${NC}"; fi)"
    echo "  4. Log Seviyesi: $LOG_LEVEL"
    echo "  5. Maksimum Yedek: $MAX_BACKUPS"
    echo
    echo "  6. 💾 Yedekleri Görüntüle"
    echo "  7. 🔄 Yedekten Geri Yükle"
    echo "  8. 🗑️  Eski Yedekleri Temizle"
    echo
    echo "  0. ⬅️  Geri Dön"
    echo
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -ne "${BOLD}${BLUE}Seçiminiz (0-8): ${NC}"
    
    read -r choice
    
    case $choice in
        1) toggle_wallpapers ;;
        2) toggle_zsh_protection ;;
        3) toggle_terminal_font_protection ;;
        4) change_log_level ;;
        5) change_max_backups ;;
        6) list_backups ;;
        7) restore_backup_menu ;;
        8) cleanup_old_backups ;;
        0) return ;;
        *) 
            log_error "Geçersiz seçim!"
            sleep 2
            show_settings_menu
            ;;
    esac
}

toggle_wallpapers() {
    if [[ "$ENABLE_WALLPAPERS" == true ]]; then
        ENABLE_WALLPAPERS=false
        log_info "Wallpaper desteği kapatıldı"
    else
        ENABLE_WALLPAPERS=true
        log_info "Wallpaper desteği açıldı"
    fi
    save_user_config
    sleep 1
    show_settings_menu
}

toggle_zsh_protection() {
    if [[ "$PROTECT_ZSH_CONFIG" == true ]]; then
        PROTECT_ZSH_CONFIG=false
        log_warning "ZSH koruması kapatıldı (önerilmez!)"
    else
        PROTECT_ZSH_CONFIG=true
        log_info "ZSH koruması açıldı"
    fi
    save_user_config
    sleep 1
    show_settings_menu
}

toggle_terminal_font_protection() {
    if [[ "$PROTECT_TERMINAL_FONT" == true ]]; then
        PROTECT_TERMINAL_FONT=false
        log_info "Terminal font koruması kapatıldı"
    else
        PROTECT_TERMINAL_FONT=true
        log_info "Terminal font koruması açıldı"
    fi
    save_user_config
    sleep 1
    show_settings_menu
}

change_log_level() {
    echo
    echo "Log Seviyesi Seçin:"
    echo "  1. DEBUG (En detaylı)"
    echo "  2. INFO (Normal)"
    echo "  3. WARNING (Sadece uyarılar)"
    echo "  4. ERROR (Sadece hatalar)"
    echo
    read -p "Seçim (1-4): " level_choice
    
    case $level_choice in
        1) LOG_LEVEL="DEBUG" ;;
        2) LOG_LEVEL="INFO" ;;
        3) LOG_LEVEL="WARNING" ;;
        4) LOG_LEVEL="ERROR" ;;
        *) log_error "Geçersiz seçim!"; sleep 2; show_settings_menu; return ;;
    esac
    
    save_user_config
    log_info "Log seviyesi: $LOG_LEVEL"
    sleep 1
    show_settings_menu
}

change_max_backups() {
    echo
    read -p "Maksimum yedek sayısı (1-10): " max
    
    if [[ "$max" =~ ^[0-9]+$ ]] && [[ $max -ge 1 ]] && [[ $max -le 10 ]]; then
        MAX_BACKUPS=$max
        save_user_config
        log_info "Maksimum yedek: $MAX_BACKUPS"
    else
        log_error "Geçersiz sayı!"
    fi
    
    sleep 1
    show_settings_menu
}

restore_backup_menu() {
    echo
    list_backups
    echo
    read -p "Geri yüklenecek yedek adı (veya 0 iptal): " backup_name
    
    if [[ "$backup_name" == "0" ]]; then
        show_settings_menu
        return
    fi
    
    restore_from_backup "$backup_name"
    
    read -p "Devam etmek için Enter'a basın..."
    show_settings_menu
}

# ============================================================================
# HELP MENU
# ============================================================================

show_help_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                YARDIM ve SORUN GİDERME                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    echo -e "${BOLD}📖 KULLANIM KILAVUZU:${NC}"
    echo "  1. Ana menüden tema seçin (1-9)"
    echo "  2. Script otomatik kurulum yapacak"
    echo "  3. Logout/Login yapın"
    echo "  4. İnce ayar için DE ayarlarını kullanın"
    echo
    
    echo -e "${BOLD}🔧 SIK KARŞILAŞILAN SORUNLAR:${NC}"
    echo "  • Tema uygulanmıyorsa:"
    echo "    → DE ayar aracını kullanın (GNOME Tweaks, vb.)"
    echo "  • Icon'lar görünmüyorsa:"
    echo "    → Icon temasını manuel seçin"
    echo "  • Shell çöktüyse:"
    echo "    → GNOME: Alt+F2 → 'r' → Enter"
    echo "    → KDE: plasmashell --replace &"
    echo "  • Performans düştüyse:"
    echo "    → Daha hafif tema seçin (Arc, Yaru)"
    echo
    
    echo -e "${BOLD}🛠️ GEREKLİ ARAÇLAR:${NC}"
    echo "  • GNOME Tweaks: sudo apt install gnome-tweaks"
    echo "  • User Themes Extension (GNOME)"
    echo "  • Chrome GNOME Shell: sudo apt install chrome-gnome-shell"
    echo
    
    echo -e "${BOLD}📞 DESTEK:${NC}"
    echo "  • Log dosyası: $LOG_FILE"
    echo "  • Yedek dizini: $BACKUP_DIR"
    echo "  • GitHub: https://github.com/[your-repo]"
    echo
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "theme-utils.sh modülü yüklendi"
