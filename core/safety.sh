#!/bin/bash

# ============================================================================
# Safety System - ZSH Protection & Backup Management
# ============================================================================

# ============================================================================
# ZSH PROTECTION
# ============================================================================

# Protect ZSH configuration
protect_zsh_config() {
    if [[ "$PROTECT_ZSH_CONFIG" != true ]]; then
        log_info "ZSH koruması devre dışı"
        return 0
    fi
    
    if ! is_zsh_active; then
        log_info "ZSH aktif değil, koruma gerekmiyor"
        return 0
    fi
    
    log_info "ZSH konfigürasyonu korunuyor..."
    
    # Create ZSH backup directory
    mkdir -p "$BACKUP_DIR/zsh_protected" 2>/dev/null || {
        log_error "ZSH backup dizini oluşturulamadı"
        return 1
    }
    
    local protected_count=0
    
    for file in "${ZSH_PROTECTED_FILES[@]}"; do
        local filepath="$HOME/$file"
        
        # Check if file or directory exists
        if [[ -f "$filepath" ]] || [[ -d "$filepath" ]]; then
            local backup_path="$BACKUP_DIR/zsh_protected/$(basename "$file").backup"
            
            # Copy with error handling
            if cp -r "$filepath" "$backup_path" 2>/dev/null; then
                ((protected_count++))
                log_debug "Korundu: $file"
            else
                log_warning "Kopyalanamadı: $file (permission sorunu olabilir)"
            fi
        else
            log_debug "Mevcut değil, atlanıyor: $file"
        fi
    done
    
    if [[ $protected_count -gt 0 ]]; then
        log_success "ZSH konfigürasyonu korundu ($protected_count dosya)"
        return 0
    else
        log_warning "ZSH dosyası korunamadı ama devam ediliyor"
        return 0  # Don't fail, just warn
    fi
}

# Restore ZSH configuration
restore_zsh_config() {
    if ! is_zsh_active; then
        return 0
    fi
    
    log_info "ZSH konfigürasyonu geri yükleniyor..."
    
    local restored_count=0
    
    for file in "${ZSH_PROTECTED_FILES[@]}"; do
        local backup_path="$BACKUP_DIR/zsh_protected/$(basename "$file").backup"
        local filepath="$HOME/$file"
        
        if [[ -f "$backup_path" ]] || [[ -d "$backup_path" ]]; then
            cp -r "$backup_path" "$filepath" 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                ((restored_count++))
                log_debug "Geri yüklendi: $file"
            fi
        fi
    done
    
    log_success "ZSH konfigürasyonu geri yüklendi ($restored_count dosya)"
}

# Check ZSH integrity
check_zsh_integrity() {
    if ! is_zsh_active; then
        return 0
    fi
    
    log_info "ZSH bütünlük kontrolü..."
    
    local issues=0
    
    # Check .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "^#" "$HOME/.zshrc" 2>/dev/null; then
            log_warning ".zshrc dosyası boş veya bozuk görünüyor"
            ((issues++))
        fi
    else
        log_warning ".zshrc dosyası bulunamadı"
        ((issues++))
    fi
    
    # Check Oh My Zsh installation
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            log_warning "Oh My Zsh kurulumu bozuk görünüyor"
            ((issues++))
        fi
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "ZSH bütünlük kontrolü başarılı"
        return 0
    else
        log_warning "ZSH bütünlük kontrolünde $issues sorun bulundu"
        return 1
    fi
}

# ============================================================================
# TERMINAL PROTECTION
# ============================================================================

# Protect terminal font settings
protect_terminal_font() {
    if [[ "$PROTECT_TERMINAL_FONT" != true ]]; then
        return 0
    fi
    
    log_info "Terminal font ayarları korunuyor..."
    
    case "$DETECTED_DE" in
        "GNOME"|"Budgie")
            # Get current profile
            local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
            
            if [[ -n "$profile_id" ]]; then
                local profile_path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_id}/"
                
                # Backup current font
                local current_font=$(gsettings get "$profile_path" font 2>/dev/null)
                echo "TERMINAL_FONT='$current_font'" > "$BACKUP_DIR/terminal_font.backup"
                
                log_success "Terminal font korundu: $current_font"
            fi
            ;;
        *)
            log_debug "Terminal font koruması bu DE için desteklenmiyor"
            ;;
    esac
    
    return 0  # Always return success
}

# Restore terminal font settings
restore_terminal_font() {
    if [[ "$PROTECT_TERMINAL_FONT" != true ]]; then
        return 0
    fi
    
    local backup_file="$BACKUP_DIR/terminal_font.backup"
    
    if [[ ! -f "$backup_file" ]]; then
        return 0
    fi
    
    log_info "Terminal font ayarları geri yükleniyor..."
    
    source "$backup_file"
    
    case "$DETECTED_DE" in
        "GNOME"|"Budgie")
            local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
            
            if [[ -n "$profile_id" ]]; then
                local profile_path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_id}/"
                gsettings set "$profile_path" font "$TERMINAL_FONT" 2>/dev/null
                log_success "Terminal font geri yüklendi"
            fi
            ;;
    esac
}

# ============================================================================
# BACKUP MANAGEMENT
# ============================================================================

# Create system backup
create_system_backup() {
    log_info "Sistem yedekleniyor..."
    
    local backup_name="system_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p "$backup_path" 2>/dev/null || {
        log_error "Backup dizini oluşturulamadı"
        return 1
    }
    
    # Create backup manifest
    cat > "$backup_path/manifest.txt" << MANIFEST
System Theme Setup Backup
Created: $(date)
User: $(whoami)
Desktop Environment: $DETECTED_DE
Ubuntu Version: $DETECTED_VERSION
ZSH Framework: $DETECTED_ZSH
MANIFEST
    
    # Backup theme settings
    create_theme_backup "$backup_path"
    
    # Backup ZSH if active
    if is_zsh_active; then
        protect_zsh_config
    fi
    
    # Backup terminal settings
    protect_terminal_font
    
    log_success "Sistem yedeği oluşturuldu: $backup_name"
    echo "$backup_name" > "$BACKUP_DIR/latest_backup.txt"
    
    # Cleanup old backups
    cleanup_old_backups
    
    return 0
}

# Create theme backup
create_theme_backup() {
    local backup_path="${1:-$BACKUP_DIR/theme_backup_$(date +%Y%m%d_%H%M%S)}"
    
    mkdir -p "$backup_path" 2>/dev/null
    
    log_info "Tema ayarları yedekleniyor..."
    
    case "$DETECTED_DE" in
        "GNOME"|"Budgie")
            {
                echo "# GNOME Theme Backup"
                echo "GTK_THEME='$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")'"
                echo "ICON_THEME='$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo "")'"
                echo "CURSOR_THEME='$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || echo "")'"
                echo "SHELL_THEME='$(gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null || echo "")'"
                echo "FONT_NAME='$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null || echo "")'"
                echo "COLOR_SCHEME='$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "")'"
            } > "$backup_path/gnome_theme.backup"
            ;;
        "KDE")
            {
                echo "# KDE Theme Backup"
                echo "COLOR_SCHEME='$(kreadconfig5 --group General --key ColorScheme 2>/dev/null || echo "")'"
                echo "ICON_THEME='$(kreadconfig5 --group Icons --key Theme 2>/dev/null || echo "")'"
                echo "CURSOR_THEME='$(kreadconfig5 --group General --key cursorTheme 2>/dev/null || echo "")'"
            } > "$backup_path/kde_theme.backup"
            ;;
        "XFCE")
            {
                echo "# XFCE Theme Backup"
                echo "GTK_THEME='$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo "")'"
                echo "ICON_THEME='$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null || echo "")'"
                echo "WM_THEME='$(xfconf-query -c xfwm4 -p /general/theme 2>/dev/null || echo "")'"
            } > "$backup_path/xfce_theme.backup"
            ;;
    esac
    
    log_success "Tema ayarları yedeklendi"
    return 0
}

# Restore from backup
restore_from_backup() {
    local backup_name="${1}"
    
    if [[ -z "$backup_name" ]]; then
        # Get latest backup
        if [[ -f "$BACKUP_DIR/latest_backup.txt" ]]; then
            backup_name=$(cat "$BACKUP_DIR/latest_backup.txt")
        else
            log_error "Yedek bulunamadı!"
            return 1
        fi
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "Yedek dizini bulunamadı: $backup_path"
        return 1
    fi
    
    log_info "Yedekten geri yükleniyor: $backup_name"
    
    # Restore theme settings based on DE
    case "$DETECTED_DE" in
        "GNOME"|"Budgie")
            if [[ -f "$backup_path/gnome_theme.backup" ]]; then
                source "$backup_path/gnome_theme.backup"
                [[ -n "$GTK_THEME" ]] && gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null
                [[ -n "$ICON_THEME" ]] && gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null
                [[ -n "$CURSOR_THEME" ]] && gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null
                [[ -n "$FONT_NAME" ]] && gsettings set org.gnome.desktop.interface font-name "$FONT_NAME" 2>/dev/null
                [[ -n "$SHELL_THEME" ]] && gsettings set org.gnome.shell.extensions.user-theme name "$SHELL_THEME" 2>/dev/null
            fi
            ;;
        "KDE")
            if [[ -f "$backup_path/kde_theme.backup" ]]; then
                source "$backup_path/kde_theme.backup"
                [[ -n "$COLOR_SCHEME" ]] && kwriteconfig5 --group General --key ColorScheme "$COLOR_SCHEME" 2>/dev/null
                [[ -n "$ICON_THEME" ]] && kwriteconfig5 --group Icons --key Theme "$ICON_THEME" 2>/dev/null
            fi
            ;;
        "XFCE")
            if [[ -f "$backup_path/xfce_theme.backup" ]]; then
                source "$backup_path/xfce_theme.backup"
                [[ -n "$GTK_THEME" ]] && xfconf-query -c xsettings -p /Net/ThemeName -s "$GTK_THEME" 2>/dev/null
                [[ -n "$ICON_THEME" ]] && xfconf-query -c xsettings -p /Net/IconThemeName -s "$ICON_THEME" 2>/dev/null
                [[ -n "$WM_THEME" ]] && xfconf-query -c xfwm4 -p /general/theme -s "$WM_THEME" 2>/dev/null
            fi
            ;;
    esac
    
    # Restore ZSH
    restore_zsh_config
    
    # Restore terminal font
    restore_terminal_font
    
    log_success "Yedekten geri yükleme tamamlandı"
}

# List available backups
list_backups() {
    echo
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                MEVCUT YEDEKLER${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Henüz yedek oluşturulmamış.${NC}"
        return
    fi
    
    local count=1
    for backup in "$BACKUP_DIR"/system_backup_*; do
        if [[ -d "$backup" ]]; then
            local backup_name=$(basename "$backup")
            local backup_date=$(echo "$backup_name" | sed 's/system_backup_//' | sed 's/_/ /')
            local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            
            echo -e "  ${BOLD}$count.${NC} $backup_name"
            echo -e "     Tarih: $backup_date | Boyut: $backup_size"
            echo
            
            ((count++))
        fi
    done
}

# Cleanup old backups
cleanup_old_backups() {
    local backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "system_backup_*" 2>/dev/null | wc -l)
    
    if [[ $backup_count -gt $MAX_BACKUPS ]]; then
        log_info "Eski yedekler temizleniyor..."
        
        # Keep only the most recent MAX_BACKUPS
        ls -dt "$BACKUP_DIR"/system_backup_* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -rf
        
        log_success "Eski yedekler temizlendi"
    fi
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

# Check dependencies
check_dependencies() {
    log_info "Bağımlılıklar kontrol ediliyor..."
    
    local missing_deps=()
    
    for dep in "${REQUIRED_DEPS[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Eksik bağımlılıklar: ${missing_deps[*]}"
        echo
        echo -e "${YELLOW}Eksik paketler kurulacak:${NC} ${missing_deps[*]}"
        echo -ne "Devam edilsin mi? (e/h): "
        read -r choice
        
        if [[ "$choice" == "e" ]]; then
            log_info "Eksik paketler kuruluyor..."
            sudo apt update > /dev/null 2>&1
            sudo apt install -y "${missing_deps[@]}" || {
                log_error "Paket kurulumu başarısız!"
                exit 1
            }
            log_success "Eksik paketler kuruldu"
        else
            log_error "Gerekli bağımlılıklar olmadan devam edilemez!"
            exit 1
        fi
    else
        log_success "Tüm bağımlılıklar mevcut"
    fi
}