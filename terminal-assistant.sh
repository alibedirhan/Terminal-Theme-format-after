#!/bin/bash

# ============================================================================
# Terminal Setup - Otomatik Teşhis ve Çözüm Asistanı
# v3.2.8 - Assistant Module
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
# INSTANT PROMPT ANALİZ VE DÜZELTME
# ============================================================================

analyze_zshrc_structure() {
    local zshrc="$HOME/.zshrc"
    
    if [[ ! -f "$zshrc" ]]; then
        echo "error:nofile"
        return 1
    fi
    
    # Satır numaralarını bul
    local instant_prompt_start=$(grep -n "p10k-instant-prompt" "$zshrc" | head -1 | cut -d: -f1)
    local instant_prompt_end=$(awk '/p10k-instant-prompt/,/^fi$/' "$zshrc" | grep -n "^fi$" | head -1 | cut -d: -f1)
    
    # Tool initialization satırlarını bul
    local tools_found=()
    local problematic_tools=()
    
    # Kontrol edilecek tool'lar
    local -A tools=(
        ["zoxide"]='eval.*zoxide init'
        ["fzf"]='source.*\.fzf\.zsh'
        ["atuin"]='eval.*atuin init'
        ["nvm"]='export NVM_DIR.*nvm\.sh'
        ["cargo"]='source.*\.cargo/env'
    )
    
    # Her tool için kontrol yap
    for tool in "${!tools[@]}"; do
        local pattern="${tools[$tool]}"
        local line_num=$(grep -n "$pattern" "$zshrc" 2>/dev/null | head -1 | cut -d: -f1)
        
        if [[ -n "$line_num" ]]; then
            tools_found+=("$tool:$line_num")
            
            # Instant prompt öncesinde mi kontrol et
            if [[ -n "$instant_prompt_start" ]] && [[ "$line_num" -lt "$instant_prompt_start" ]]; then
                problematic_tools+=("$tool:$line_num:before")
            elif [[ -n "$instant_prompt_start" ]] && [[ -n "$instant_prompt_end" ]]; then
                local actual_end=$((instant_prompt_start + instant_prompt_end))
                if [[ "$line_num" -lt "$actual_end" ]]; then
                    problematic_tools+=("$tool:$line_num:inside")
                fi
            fi
        fi
    done
    
    # Sonuçları döndür
    if [[ ${#problematic_tools[@]} -gt 0 ]]; then
        echo "issues_found"
        printf '%s\n' "${problematic_tools[@]}"
        return 0
    else
        echo "no_issues"
        return 0
    fi
}

diagnose_instant_prompt_issues() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     POWERLEVEL10K INSTANT PROMPT TEŞHİS ASISTANI         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    log_info "~/.zshrc yapısı analiz ediliyor..."
    echo
    
    # Analiz yap
    local analysis_result=$(analyze_zshrc_structure)
    local result_status=$(echo "$analysis_result" | head -1)
    
    # Sonuçları göster
    case "$result_status" in
        "error:nofile")
            echo -e "${RED}✗ .zshrc dosyası bulunamadı!${NC}"
            echo
            echo -e "${YELLOW}ÇÖZÜM:${NC}"
            echo "  Zsh kurulumunu yeniden yapmanız gerekebilir."
            echo
            return 1
            ;;
            
        "no_issues")
            echo -e "${GREEN}✓ Herhangi bir sorun tespit edilmedi!${NC}"
            echo
            echo -e "${DIM}~/.zshrc yapısı doğru şekilde yapılandırılmış.${NC}"
            echo
            return 0
            ;;
            
        "issues_found")
            echo -e "${RED}⚠ Yapılandırma sorunları tespit edildi!${NC}"
            echo
            
            # Sorunları listele
            echo -e "${CYAN}═══ TESPİT EDİLEN SORUNLAR ═══${NC}"
            echo
            
            local issues=$(echo "$analysis_result" | tail -n +2)
            local issue_count=0
            
            while IFS=: read -r tool line position; do
                ((issue_count++))
                echo -e "${YELLOW}[$issue_count]${NC} ${BOLD}$tool${NC} (Satır: $line)"
                
                case "$position" in
                    "before")
                        echo -e "    ${RED}✗${NC} Instant prompt ${RED}öncesinde${NC} tanımlanmış"
                        echo -e "    ${DIM}Bu, terminal açılışında uyarı mesajlarına neden olur${NC}"
                        ;;
                    "inside")
                        echo -e "    ${RED}✗${NC} Instant prompt ${RED}bloğu içinde${NC} tanımlanmış"
                        echo -e "    ${DIM}Bu, prompt'un düzgün görünmemesine neden olur${NC}"
                        ;;
                esac
                echo
            done <<< "$issues"
            
            # Açıklama
            echo -e "${CYAN}═══ SORUN AÇIKLAMASI ═══${NC}"
            echo
            echo "Powerlevel10k'nın ${BOLD}instant prompt${NC} özelliği terminal açılışını hızlandırır."
            echo "Ancak bu özellik, bazı komutların ${UNDERLINE}instant prompt bloğundan SONRA${NC}"
            echo "çalıştırılmasını gerektirir."
            echo
            echo -e "${YELLOW}Mevcut durum:${NC}"
            echo "  • Tool initialization'lar yanlış yerde"
            echo "  • Terminal açılışta uyarı mesajı gösteriyor"
            echo "  • Prompt düzgün görünmüyor"
            echo
            
            # Önerilen düzeltme
            echo -e "${CYAN}═══ ÖNERİLEN DÜZELTME ═══${NC}"
            echo
            echo -e "${GREEN}[1] Otomatik Düzeltme${NC} ${BOLD}(Önerilen)${NC}"
            echo "    • Güvenli yedekleme yapılır"
            echo "    • Tool initialization'lar doğru yere taşınır"
            echo "    • .zshrc yeniden düzenlenir"
            echo "    • Rollback özelliği ile geri alınabilir"
            echo
            echo -e "${YELLOW}[2] Manuel Düzeltme${NC}"
            echo "    • Detaylı adım adım talimatlar gösterilir"
            echo "    • Kendiniz düzenlersiniz"
            echo
            echo -e "${DIM}[0] İptal${NC}"
            echo
            
            # Kullanıcı seçimi
            while true; do
                echo -ne "${CYAN}Seçiminiz (0/1/2): ${NC}"
                read -r choice
                
                case "$choice" in
                    1)
                        echo
                        fix_instant_prompt_order
                        return $?
                        ;;
                    2)
                        echo
                        show_manual_fix_instructions "$issues"
                        return 0
                        ;;
                    0)
                        echo
                        log_info "İşlem iptal edildi"
                        return 0
                        ;;
                    *)
                        echo -e "${RED}Geçersiz seçim! Lütfen 0, 1 veya 2 girin.${NC}"
                        ;;
                esac
            done
            ;;
    esac
}

fix_instant_prompt_order() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           OTOMATİK DÜZELTME BAŞLATILIYOR                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    local zshrc="$HOME/.zshrc"
    
    # Güvenlik kontrolü
    if [[ ! -f "$zshrc" ]]; then
        log_error ".zshrc dosyası bulunamadı!"
        return 1
    fi
    
    # Yedekleme
    local backup_file="${BACKUP_DIR}/zshrc_instant_prompt_fix_$(date +%Y%m%d_%H%M%S).backup"
    
    echo -ne "📦 Yedek oluşturuluyor... "
    if cp "$zshrc" "$backup_file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        log_info "Yedek oluşturuldu: $backup_file"
    else
        echo -e "${RED}✗${NC}"
        log_error "Yedekleme başarısız!"
        return 1
    fi
    
    # Geçici dosya oluştur
    local temp_file=$(mktemp)
    
    echo -ne "🔍 .zshrc analiz ediliyor... "
    
    # Instant prompt bloğunun konumunu bul
    local instant_prompt_start=$(grep -n "# Enable Powerlevel10k instant prompt" "$zshrc" | head -1 | cut -d: -f1)
    local instant_prompt_end_relative=$(awk '/# Enable Powerlevel10k instant prompt/,/^fi$/' "$zshrc" | grep -n "^fi$" | head -1 | cut -d: -f1)
    
    if [[ -z "$instant_prompt_start" ]] || [[ -z "$instant_prompt_end_relative" ]]; then
        echo -e "${RED}✗${NC}"
        log_error "Instant prompt bloğu bulunamadı!"
        rm -f "$temp_file"
        return 1
    fi
    
    local instant_prompt_end=$((instant_prompt_start + instant_prompt_end_relative - 1))
    echo -e "${GREEN}✓${NC}"
    
    echo -ne "✂️  Problematic satırlar çıkarılıyor... "
    
    # Tool initialization pattern'leri
    local patterns=(
        'eval.*zoxide init'
        'source.*\.fzf\.zsh'
        'eval.*atuin init'
        'export NVM_DIR.*nvm\.sh'
        'source.*\.cargo/env'
    )
    
    # Çıkarılacak satırları topla
    local extracted_lines=""
    local line_count=0
    
    for pattern in "${patterns[@]}"; do
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                extracted_lines+="$line"$'\n'
                ((line_count++))
            fi
        done < <(grep "$pattern" "$zshrc" 2>/dev/null)
    done
    
    if [[ $line_count -eq 0 ]]; then
        echo -e "${YELLOW}⊘${NC} (Hiçbir şey bulunamadı)"
        rm -f "$temp_file"
        return 0
    fi
    
    echo -e "${GREEN}✓${NC} ($line_count satır)"
    
    echo -ne "📝 Yeni .zshrc oluşturuluyor... "
    
    # Yeni .zshrc'yi oluştur
    {
        # 1. Instant prompt bloğuna kadar her şeyi kopyala
        sed -n "1,${instant_prompt_end}p" "$zshrc"
        
        # 2. Boş satır ekle
        echo ""
        
        # 3. Tool initialization başlığı ekle
        echo "# ============================================================================"
        echo "# TOOL INITIALIZATIONS (Instant prompt sonrası)"
        echo "# ============================================================================"
        echo ""
        
        # 4. Çıkarılan satırları ekle
        echo "$extracted_lines"
        
        # 5. Geri kalan her şeyi kopyala (pattern'leri atla)
        local skip_next=false
        local current_line=$((instant_prompt_end + 1))
        
        tail -n +$current_line "$zshrc" | while IFS= read -r line; do
            local should_skip=false
            
            for pattern in "${patterns[@]}"; do
                if [[ "$line" =~ $pattern ]]; then
                    should_skip=true
                    break
                fi
            done
            
            if [[ "$should_skip" == "false" ]]; then
                echo "$line"
            fi
        done
        
    } > "$temp_file"
    
    echo -e "${GREEN}✓${NC}"
    
    # Yeni dosyayı yerleştir
    echo -ne "💾 Değişiklikler kaydediliyor... "
    if mv "$temp_file" "$zshrc" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        chmod 644 "$zshrc"
    else
        echo -e "${RED}✗${NC}"
        log_error "Dosya kaydedilemedi!"
        rm -f "$temp_file"
        return 1
    fi
    
    # Özet
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✓ DÜZELTME BAŞARIYLA TAMAMLANDI              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Yapılan değişiklikler:${NC}"
    echo "  • $line_count tool initialization taşındı"
    echo "  • Yedek dosyası oluşturuldu"
    echo "  • .zshrc yeniden düzenlendi"
    echo
    echo -e "${CYAN}Yedek konumu:${NC}"
    echo "  $backup_file"
    echo
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BOLD}Değişikliklerin uygulanması için:${NC}"
    echo
    echo -e "  ${CYAN}1.${NC} Terminal'i yeniden başlatın, ${BOLD}VEYA${NC}"
    echo -e "  ${CYAN}2.${NC} Şu komutu çalıştırın: ${CYAN}source ~/.zshrc${NC}"
    echo
    echo -e "${DIM}Artık terminal açılışında uyarı mesajı görmeyeceksiniz.${NC}"
    echo
    
    # Rollback bilgisi
    echo -e "${CYAN}═══ GERİ ALMA (ROLLBACK) ═══${NC}"
    echo
    echo "Eğer bir sorun olursa, şu komutla eski haline döndürebilirsiniz:"
    echo
    echo -e "  ${CYAN}cp $backup_file ~/.zshrc${NC}"
    echo -e "  ${CYAN}source ~/.zshrc${NC}"
    echo
    
    log_success "Instant prompt düzeltmesi tamamlandı"
    return 0
}

show_manual_fix_instructions() {
    local issues="$1"
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              MANUEL DÜZELTME TALİMATLARI                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${YELLOW}Adım 1: .zshrc dosyasını yedekleyin${NC}"
    echo
    echo "  Terminal'de çalıştırın:"
    echo -e "  ${CYAN}cp ~/.zshrc ~/.zshrc.backup_$(date +%Y%m%d)${NC}"
    echo
    
    echo -e "${YELLOW}Adım 2: .zshrc dosyasını açın${NC}"
    echo
    echo "  Nano ile:"
    echo -e "  ${CYAN}nano ~/.zshrc${NC}"
    echo
    echo "  Veya Vim ile:"
    echo -e "  ${CYAN}vim ~/.zshrc${NC}"
    echo
    
    echo -e "${YELLOW}Adım 3: Problematic satırları bulun ve taşıyın${NC}"
    echo
    echo "  Aşağıdaki satırları bulup KESİN (Ctrl+K veya dd):"
    echo
    
    while IFS=: read -r tool line position; do
        echo -e "    ${RED}→ Satır $line:${NC} $tool initialization"
    done <<< "$issues"
    
    echo
    echo -e "${YELLOW}Adım 4: Instant prompt bloğunu bulun${NC}"
    echo
    echo "  Şuna benzer bir blok arayın:"
    echo -e "  ${DIM}if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt...\" ]]; then${NC}"
    echo -e "  ${DIM}  source ...${NC}"
    echo -e "  ${DIM}fi${NC}"
    echo
    
    echo -e "${YELLOW}Adım 5: Kesilen satırları 'fi' satırından SONRA yapıştırın${NC}"
    echo
    echo "  Yapıştırma konumu:"
    echo -e "  ${DIM}if [[ -r ... ]]; then${NC}"
    echo -e "  ${DIM}  source ...${NC}"
    echo -e "  ${DIM}fi${NC}"
    echo -e "  ${GREEN}← BURAYA YAPIŞTIRIN (Ctrl+U veya p)${NC}"
    echo
    
    echo -e "${YELLOW}Adım 6: Kaydedin ve çıkın${NC}"
    echo
    echo "  Nano'da: Ctrl+O, Enter, Ctrl+X"
    echo "  Vim'de: Esc, :wq, Enter"
    echo
    
    echo -e "${YELLOW}Adım 7: Değişiklikleri uygulayın${NC}"
    echo
    echo -e "  ${CYAN}source ~/.zshrc${NC}"
    echo
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${DIM}Sorun devam ederse 'Otomatik Düzeltme' seçeneğini deneyin.${NC}"
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
log_debug "terminal-assistant.sh modülü yüklendi (v3.2.8)"