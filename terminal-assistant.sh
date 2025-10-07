#!/bin/bash

# ============================================================================
# Terminal Setup - Otomatik Teşhis ve Çözüm Asistanı
# v3.2.4 - Assistant Module
# ============================================================================
# Bu modül sistem sorunlarını tespit eder ve otomatik çözümler önerir.
# Bağımlılıklar: terminal-utils.sh (logging), terminal-ui.sh (renkler)
# ============================================================================

# ============================================================================
# BAĞIMLILIK KONTROLLERI
# ============================================================================

# Bu modül için gerekli değişkenler ve fonksiyonlar
# Eğer yüklü değilse hata ver
check_assistant_dependencies() {
    local missing_deps=()
    
    # Renk değişkenleri kontrolü
    [[ -z "${RED:-}" ]] && missing_deps+=("Renk tanımları (terminal-ui.sh)")
    
    # Logging fonksiyonları kontrolü
    ! type log_error &>/dev/null && missing_deps+=("log_error fonksiyonu")
    ! type log_info &>/dev/null && missing_deps+=("log_info fonksiyonu")
    ! type log_success &>/dev/null && missing_deps+=("log_success fonksiyonu")
    ! type log_warning &>/dev/null && missing_deps+=("log_warning fonksiyonu")
    
    # Global değişkenler kontrolü
    [[ -z "${LOG_FILE:-}" ]] && missing_deps+=("LOG_FILE değişkeni")
    [[ -z "${BACKUP_DIR:-}" ]] && missing_deps+=("BACKUP_DIR değişkeni")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "HATA: terminal-assistant.sh bağımlılıkları eksik:"
        printf '  - %s\n' "${missing_deps[@]}"
        return 1
    fi
    
    return 0
}

# ============================================================================
# SİSTEM SAĞLIK KONTROLÜ
# ============================================================================

system_health_check() {
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         SİSTEM SAĞLIK KONTROLÜ               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
    echo
    
    local total_checks=0
    local passed_checks=0
    local warnings=0
    
    # 1. Disk alanı kontrolü
    ((total_checks++))
    echo -n "Disk alanı kontrolü... "
    local available_space=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
    if [ "$available_space" -gt 500 ]; then
        echo -e "${GREEN}✓${NC} Yeterli ($available_space MB)"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Yetersiz ($available_space MB < 500 MB)"
    fi
    
    # 2. İnternet bağlantısı
    ((total_checks++))
    echo -n "İnternet bağlantısı... "
    if timeout 5 ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}✓${NC} Aktif"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Yok"
    fi
    
    # 3. Gerekli komutlar
    ((total_checks++))
    echo -n "Gerekli paketler... "
    local missing_pkgs=()
    for cmd in git curl wget; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_pkgs+=("$cmd")
        fi
    done
    
    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Tamam"
        ((passed_checks++))
    else
        echo -e "${RED}✗${NC} Eksik: ${missing_pkgs[*]}"
    fi
    
    # 4. Terminal emulator
    ((total_checks++))
    echo -n "Terminal emulator... "
    local terminal=$(detect_terminal)
    if [ "$terminal" != "unknown" ]; then
        echo -e "${GREEN}✓${NC} $terminal"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Bilinmeyen"
        ((warnings++))
    fi
    
    # 5. Zsh kontrolü
    ((total_checks++))
    echo -n "Zsh... "
    if command -v zsh &> /dev/null; then
        local zsh_version=$(zsh --version | cut -d' ' -f2)
        echo -e "${GREEN}✓${NC} Kurulu ($zsh_version)"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 6. Oh My Zsh kontrolü
    ((total_checks++))
    echo -n "Oh My Zsh... "
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 7. Font kontrolü
    ((total_checks++))
    echo -n "MesloLGS NF Font... "
    if fc-list 2>/dev/null | grep -q "MesloLGS"; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 8. Powerlevel10k kontrolü
    ((total_checks++))
    echo -n "Powerlevel10k... "
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        echo -e "${GREEN}✓${NC} Kurulu"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 9. Pluginler kontrolü
    ((total_checks++))
    echo -n "Zsh Pluginleri... "
    local plugin_count=0
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [[ -d "$CUSTOM/plugins/zsh-autosuggestions" ]] && ((plugin_count++))
    [[ -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]] && ((plugin_count++))
    
    if [ $plugin_count -eq 2 ]; then
        echo -e "${GREEN}✓${NC} Tamam (2/2)"
        ((passed_checks++))
    elif [ $plugin_count -eq 1 ]; then
        echo -e "${YELLOW}⚠ ${NC} Kısmi (1/2)"
        ((warnings++))
    else
        echo -e "${YELLOW}⚠ ${NC} Kurulu değil"
        ((warnings++))
    fi
    
    # 10. Yedek kontrolü
    ((total_checks++))
    echo -n "Yedekler... "
    if [[ -d "$BACKUP_DIR" ]] && [[ $(ls -A "$BACKUP_DIR" 2>/dev/null | wc -l) -gt 0 ]]; then
        local backup_count=$(ls "$BACKUP_DIR" | wc -l)
        echo -e "${GREEN}✓${NC} Var ($backup_count dosya)"
        ((passed_checks++))
    else
        echo -e "${YELLOW}⚠ ${NC} Yok"
        ((warnings++))
    fi
    
    # Sonuç özeti
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Toplam Kontrol: $total_checks"
    echo -e "${GREEN}✓ Başarılı: $passed_checks${NC}"
    echo -e "${YELLOW}⚠  Uyarı: $warnings${NC}"
    echo -e "${RED}✗ Hata: $((total_checks - passed_checks))${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Durum değerlendirmesi
    local success_rate=$((passed_checks * 100 / total_checks))
    
    if [ $success_rate -eq 100 ]; then
        echo -e "${GREEN}✓ Sistem mükemmel durumda!${NC}"
        return 0
    elif [ $success_rate -ge 80 ]; then
        echo -e "${GREEN}✓ Sistem kurulum için hazır${NC}"
        return 0
    elif [ $success_rate -ge 60 ]; then
        echo -e "${YELLOW}⚠  Sistem kurulabilir ama bazı özellikler çalışmayabilir${NC}"
        return 0
    else
        echo -e "${RED}✗ Sistem kurulum için hazır değil${NC}"
        echo "Lütfen önce eksik paketleri kurun"
        return 1
    fi
}

# ============================================================================
# SHELL KONTROL FONKSİYONLARI
# ============================================================================

run_comprehensive_shell_check() {
    echo "  Kapsamlı shell kontrolü:"
    echo
    
    # 1. /etc/passwd
    local passwd_shell=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
    echo -n "  1. /etc/passwd: $passwd_shell "
    if [[ "$passwd_shell" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 2. $SHELL değişkeni
    echo -n "  2. \$SHELL: $SHELL "
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 3. Aktif shell
    local active_shell=$(ps -p $$ -o comm=)
    echo -n "  3. Aktif shell: $active_shell "
    if [[ "$active_shell" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # 4. GNOME Terminal
    if command -v gsettings &> /dev/null; then
        local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        local login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
        echo -n "  4. GNOME Terminal login-shell: $login_shell "
        if [[ "$login_shell" == "true" ]]; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    fi
}

provide_shell_fix_commands() {
    echo "Adım adım çözüm:"
    echo
    
    local passwd_shell=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
    
    if [[ "$passwd_shell" != *"zsh"* ]]; then
        echo "1. Sistem shell'ini değiştir:"
        echo -e "   ${CYAN}sudo chsh -s \$(which zsh) $USER${NC}"
        echo
    fi
    
    if command -v gsettings &> /dev/null; then
        local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        local login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
        
        if [[ "$login_shell" != "true" ]]; then
            echo "2. GNOME Terminal ayarla:"
            echo -e "   ${CYAN}PROFILE=\$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \\')${NC}"
            echo -e "   ${CYAN}gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\$PROFILE/ login-shell true${NC}"
            echo
        fi
    fi
    
    echo "3. Değişiklikleri uygula:"
    echo -e "   ${CYAN}gnome-session-quit --logout${NC}"
    echo "   (veya tüm terminalleri kapatıp yeniden aç)"
    echo
}

# ============================================================================
# OTOMATİK TEŞHİS VE ÇÖZÜM SİSTEMİ
# ============================================================================

diagnose_and_fix() {
    local error_type="$1"
    local context="${2:-}"
    
    echo
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}      HATA TESPİT EDİLDİ - OTOMATİK TEŞHİS${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    
    case "$error_type" in
        "shell_not_changed")
            echo -e "${YELLOW}PROBLEM:${NC} Yeni terminalde hala Bash görünüyor"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            # 1. /etc/passwd kontrolü
            local passwd_shell=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
            echo "  1. Sistem ayarı: $passwd_shell"
            
            if [[ "$passwd_shell" == *"zsh"* ]]; then
                echo -e "     ${GREEN}✓${NC} Sistem Zsh olarak ayarlı"
            else
                echo -e "     ${RED}✗${NC} Sistem hala Bash"
            fi
            
            # 2. GNOME Terminal kontrolü
            if command -v gsettings &> /dev/null; then
                local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
                local login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
                echo "  2. GNOME Terminal login shell: $login_shell"
                
                if [[ "$login_shell" == "true" ]]; then
                    echo -e "     ${GREEN}✓${NC} Login shell aktif"
                else
                    echo -e "     ${RED}✗${NC} Login shell pasif"
                fi
            fi
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            
            # Otomatik düzelt
            if [[ "$passwd_shell" != *"zsh"* ]]; then
                echo "1. Shell'i Zsh olarak ayarla:"
                echo -e "   ${CYAN}sudo chsh -s \$(which zsh) $USER${NC}"
                echo
                echo -n "   Şimdi çalıştırayım mı? (e/h): "
                read -r fix_choice
                if [[ "$fix_choice" == "e" ]]; then
                    sudo chsh -s $(which zsh) $USER
                    echo -e "   ${GREEN}✓ Düzeltildi${NC}"
                fi
                echo
            fi
            
            if command -v gsettings &> /dev/null; then
                local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
                local login_shell=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell 2>/dev/null)
                
                if [[ "$login_shell" != "true" ]]; then
                    echo "2. GNOME Terminal login shell aktif et:"
                    echo -e "   ${CYAN}gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell true${NC}"
                    echo
                    echo -n "   Şimdi çalıştırayım mı? (e/h): "
                    read -r fix_choice
                    if [[ "$fix_choice" == "e" ]]; then
                        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ login-shell true
                        echo -e "   ${GREEN}✓ Düzeltildi${NC}"
                    fi
                    echo
                fi
            fi
            
            echo "3. Son adım: Logout/login yap"
            echo -e "   ${CYAN}gnome-session-quit --logout${NC}"
            echo
            ;;
            
        "internet_connection")
            echo -e "${YELLOW}PROBLEM:${NC} İnternet bağlantısı yok"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            # 1. Ping testi
            echo -n "  1. DNS sunucu erişimi (8.8.8.8): "
            if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
                echo -e "${GREEN}✓ Erişilebilir${NC}"
            else
                echo -e "${RED}✗ Erişilemiyor${NC}"
            fi
            
            # 2. DNS çözümleme
            echo -n "  2. DNS çözümleme (google.com): "
            if ping -c 1 -W 2 google.com &> /dev/null; then
                echo -e "${GREEN}✓ Çalışıyor${NC}"
            else
                echo -e "${RED}✗ Çalışmıyor${NC}"
            fi
            
            # 3. Ağ arayüzü
            echo "  3. Ağ arayüzleri:"
            ip -br addr | grep -v "lo" | while read line; do
                echo "     $line"
            done
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            echo "1. Ağ bağlantısını kontrol edin"
            echo "2. WiFi/Ethernet bağlantısını yeniden başlatın"
            echo "3. Veya offline kurulum için gerekli paketleri önceden indirin"
            echo
            ;;
            
        "permission_denied")
            echo -e "${YELLOW}PROBLEM:${NC} Yetki hatası - $context"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            # Sudo kontrolü
            echo -n "  1. Sudo yetkisi: "
            if sudo -n true 2>/dev/null; then
                echo -e "${GREEN}✓ Var${NC}"
            else
                echo -e "${RED}✗ Yok${NC}"
            fi
            
            # Kullanıcı grubu
            echo "  2. Kullanıcı grupları:"
            groups | tr ' ' '\n' | while read group; do
                if [[ "$group" == "sudo" ]] || [[ "$group" == "wheel" ]]; then
                    echo -e "     ${GREEN}✓${NC} $group"
                else
                    echo "     $group"
                fi
            done
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            echo "1. Sudo şifresi gerekiyor:"
            echo -e "   ${CYAN}sudo -v${NC}"
            echo
            echo "2. Veya kullanıcıyı sudo grubuna ekle:"
            echo -e "   ${CYAN}sudo usermod -aG sudo $USER${NC}"
            echo
            ;;
            
        "package_missing")
            echo -e "${YELLOW}PROBLEM:${NC} Eksik paket - $context"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            local missing_pkg="$context"
            echo "  1. Paket durumu: $missing_pkg"
            
            if dpkg -l | grep -q "^ii.*$missing_pkg"; then
                echo -e "     ${GREEN}✓ Kurulu${NC}"
            else
                echo -e "     ${RED}✗ Kurulu değil${NC}"
            fi
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            echo "Paketi kur:"
            echo -e "   ${CYAN}sudo apt update && sudo apt install -y $missing_pkg${NC}"
            echo
            echo -n "Şimdi kurayım mı? (e/h): "
            read -r fix_choice
            if [[ "$fix_choice" == "e" ]]; then
                sudo apt update && sudo apt install -y "$missing_pkg"
                echo -e "   ${GREEN}✓ Kuruldu${NC}"
            fi
            echo
            ;;
            
        "font_not_visible")
            echo -e "${YELLOW}PROBLEM:${NC} Fontlar düzgün görünmüyor"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            # Font kontrolü
            echo "  1. Font durumu:"
            if fc-list | grep -q "MesloLGS"; then
                echo -e "     ${GREEN}✓ MesloLGS NF kurulu${NC}"
                fc-list | grep "MesloLGS" | head -3 | while read font; do
                    echo "     $font"
                done
            else
                echo -e "     ${RED}✗ MesloLGS NF kurulu değil${NC}"
            fi
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            echo "1. Terminal font ayarı:"
            echo "   Preferences → Text → Font: MesloLGS NF Regular 12"
            echo
            echo "2. Veya fontları yeniden kur:"
            echo -e "   ${CYAN}./terminal-setup.sh${NC}"
            echo "   Seçenek: 6 (Sadece Fontlar)"
            echo
            ;;
            
        "theme_not_applied")
            echo -e "${YELLOW}PROBLEM:${NC} Tema uygulanmadı"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            
            # Powerlevel10k kontrolü
            echo "  1. Powerlevel10k durumu:"
            if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
                echo -e "     ${GREEN}✓ Kurulu${NC}"
            else
                echo -e "     ${RED}✗ Kurulu değil${NC}"
            fi
            
            # .zshrc kontrolü
            echo "  2. .zshrc ZSH_THEME ayarı:"
            if [[ -f ~/.zshrc ]]; then
                local theme=$(grep "^ZSH_THEME=" ~/.zshrc | cut -d'"' -f2)
                echo "     Mevcut: $theme"
                if [[ "$theme" == "powerlevel10k/powerlevel10k" ]]; then
                    echo -e "     ${GREEN}✓ Doğru${NC}"
                else
                    echo -e "     ${RED}✗ Yanlış${NC}"
                fi
            fi
            
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            echo "1. Powerlevel10k'ı yeniden yapılandır:"
            echo -e "   ${CYAN}p10k configure${NC}"
            echo
            echo "2. Veya .zshrc'yi yenile:"
            echo -e "   ${CYAN}source ~/.zshrc${NC}"
            echo
            echo "3. Tema değiştir:"
            echo -e "   ${CYAN}./terminal-setup.sh${NC}"
            echo "   Seçenek: 7"
            echo
            ;;
            
        "zsh_not_default")
            echo -e "${YELLOW}PROBLEM:${NC} Zsh varsayılan shell değil"
            echo
            echo -e "${CYAN}TEŞHİS:${NC}"
            run_comprehensive_shell_check
            echo
            echo -e "${GREEN}ÇÖZÜM:${NC}"
            echo
            provide_shell_fix_commands
            ;;
            
        *)
            echo -e "${YELLOW}PROBLEM:${NC} Bilinmeyen hata - $error_type"
            echo
            echo -e "${CYAN}Genel kontrol yapılıyor...${NC}"
            system_health_check
            ;;
    esac
    
    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# ============================================================================
# MODÜL İNİT
# ============================================================================

# Bağımlılıkları kontrol et
if ! check_assistant_dependencies; then
    echo "HATA: terminal-assistant.sh yüklenemedi - bağımlılıklar eksik"
    return 1 2>/dev/null || exit 1
fi

# Modül başarıyla yüklendi
log_debug "terminal-assistant.sh modülü yüklendi (v3.2.4)"