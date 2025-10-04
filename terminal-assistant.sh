#!/bin/bash

# ============================================================================
# Terminal Assistant - Akıllı Sorun Giderme Asistanı
# v1.0.0 - İlk Sürüm
# ============================================================================
# Bu modül sistemin sağlığını kontrol eder, sorunları tespit eder ve
# otomatik çözümler sunar.
# ============================================================================

# ============================================================================
# KURULUM ÖNCESİ AKILLI TARAMA
# ============================================================================

pre_installation_scan() {
    clear
    show_banner
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   KURULUM ÖNCESİ AKILLI SISTEM TARAMASI               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo
    
    local warnings=()
    local blockers=()
    local suggestions=()
    
    log_info "Sistem analizi başlıyor..."
    echo
    
    # 1. Çakışan shell konfigürasyonları
    if [[ -f ~/.bashrc ]] && grep -q "export.*PATH.*zsh" ~/.bashrc 2>/dev/null; then
        warnings+=("~/.bashrc içinde zsh PATH tanımları var - çakışma olabilir")
        suggestions+=("fix_bashrc_conflict")
    fi
    
    # 2. Önceki başarısız kurulum kalıntıları
    if [[ -d ~/.oh-my-zsh ]] && ! command -v zsh &>/dev/null; then
        warnings+=("Oh My Zsh kurulu ama zsh yok - bozuk kurulum tespit edildi")
        blockers+=("broken_ohmyzsh")
    fi
    
    # 3. Terminal emulator uyumluluğu
    local terminal=$(detect_terminal)
    if [[ "$terminal" == "konsole" ]] || [[ "$terminal" == "xfce4-terminal" ]]; then
        warnings+=("$terminal tespit edildi - GNOME tema özellikleri çalışmayacak")
        suggestions+=("terminal_compatibility:$terminal")
    elif [[ "$terminal" == "unknown" ]]; then
        warnings+=("Terminal tipi tespit edilemedi - bazı özellikler çalışmayabilir")
    fi
    
    # 4. Locale sorunları
    if ! locale -a 2>/dev/null | grep -q "en_US.utf8\|tr_TR.utf8\|C.UTF-8"; then
        warnings+=("UTF-8 locale eksik - özel karakterlerde sorun olabilir")
        blockers+=("missing_locale")
    fi
    
    # 5. Python kontrolü (bazı pluginler için)
    if ! command -v python3 &>/dev/null; then
        suggestions+=("install_python3")
    fi
    
    # 6. Git konfigürasyonu
    if command -v git &>/dev/null; then
        if ! git config --global user.name &>/dev/null; then
            suggestions+=("configure_git")
        fi
    fi
    
    # 7. Disk alanı kritik kontrolü
    local available_mb=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
    if [ "$available_mb" -lt 200 ]; then
        blockers+=("critical_disk_space:$available_mb")
    elif [ "$available_mb" -lt 500 ]; then
        warnings+=("Düşük disk alanı: ${available_mb}MB (Önerilen: 500MB+)")
    fi
    
    # 8. Bellekte başka paket yöneticisi kontrolü
    if pgrep -x "apt" >/dev/null || pgrep -x "apt-get" >/dev/null; then
        blockers+=("apt_locked")
    fi
    
    # 9. Sudo timeout kontrolü
    if ! sudo -n true 2>/dev/null; then
        suggestions+=("sudo_setup_needed")
    fi
    
    # 10. Font dizini yazılabilirlik
    local font_dir=~/.local/share/fonts
    if [[ -d "$font_dir" ]] && [[ ! -w "$font_dir" ]]; then
        warnings+=("Font dizini yazılamaz: $font_dir")
        blockers+=("font_dir_permission")
    fi
    
    # Sonuçları göster
    local total_issues=$((${#warnings[@]} + ${#blockers[@]} + ${#suggestions[@]}))
    
    if [ ${#blockers[@]} -gt 0 ]; then
        echo -e "${RED}🛑 KRİTİK SORUNLAR (${#blockers[@]}):${NC}"
        for blocker in "${blockers[@]}"; do
            explain_blocker "$blocker"
        done
        echo
        
        echo -e "${YELLOW}Bu sorunlar kurulumu engelleyecek!${NC}"
        echo -n "Otomatik düzeltmeyi dene? (e/h): "
        read -r auto_fix_choice
        
        if [[ "$auto_fix_choice" == "e" ]]; then
            for blocker in "${blockers[@]}"; do
                auto_fix_blocker "$blocker"
            done
            echo
            echo "Sorunlar düzeltildi. Tekrar taranıyor..."
            sleep 2
            pre_installation_scan
            return $?
        else
            log_error "Kritik sorunlar düzeltilmeden kurulum yapılamaz"
            return 1
        fi
    fi
    
    if [ ${#warnings[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠  UYARILAR (${#warnings[@]}):${NC}"
        for warning in "${warnings[@]}"; do
            echo -e "  ${YELLOW}•${NC} $warning"
        done
        echo
    fi
    
    if [ ${#suggestions[@]} -gt 0 ]; then
        echo -e "${CYAN}💡 ÖNERİLER (${#suggestions[@]}):${NC}"
        for suggestion in "${suggestions[@]}"; do
            explain_suggestion "$suggestion"
        done
        echo
    fi
    
    if [ $total_issues -eq 0 ]; then
        echo -e "${GREEN}✓ Sistem mükemmel durumda - kurulum için hazır!${NC}"
        echo
        return 0
    else
        if [ ${#blockers[@]} -eq 0 ]; then
            echo -e "${GREEN}✓ Sistem kurulum için hazır${NC}"
            echo -e "${DIM}  (${#warnings[@]} uyarı, ${#suggestions[@]} öneri)${NC}"
            echo
            
            if [ ${#suggestions[@]} -gt 0 ]; then
                echo -n "Önerileri uygulamak ister misiniz? (e/h): "
                read -r apply_suggestions
                if [[ "$apply_suggestions" == "e" ]]; then
                    apply_all_suggestions "${suggestions[@]}"
                fi
            fi
            
            return 0
        fi
    fi
}

explain_blocker() {
    local blocker=$1
    local issue_type="${blocker%%:*}"
    local issue_data="${blocker#*:}"
    
    case "$issue_type" in
        broken_ohmyzsh)
            echo -e "  ${RED}✗${NC} Oh My Zsh mevcut ama Zsh kurulu değil"
            ;;
        missing_locale)
            echo -e "  ${RED}✗${NC} UTF-8 locale sisteminizde yok"
            ;;
        critical_disk_space)
            echo -e "  ${RED}✗${NC} Kritik disk alanı: ${issue_data}MB (Min: 200MB)"
            ;;
        apt_locked)
            echo -e "  ${RED}✗${NC} Başka bir paket yöneticisi çalışıyor (apt kilidi)"
            ;;
        font_dir_permission)
            echo -e "  ${RED}✗${NC} Font dizinine yazma yetkisi yok"
            ;;
    esac
}

explain_suggestion() {
    local suggestion=$1
    local sug_type="${suggestion%%:*}"
    local sug_data="${suggestion#*:}"
    
    case "$sug_type" in
        install_python3)
            echo -e "  ${CYAN}→${NC} Python3 kurulumu önerilir (bazı gelişmiş özellikler için)"
            ;;
        configure_git)
            echo -e "  ${CYAN}→${NC} Git kullanıcı adı ayarlanmamış"
            ;;
        sudo_setup_needed)
            echo -e "  ${CYAN}→${NC} Sudo yetkisi gerekecek"
            ;;
        terminal_compatibility)
            echo -e "  ${CYAN}→${NC} $sug_data terminali için sınırlı tema desteği"
            ;;
        fix_bashrc_conflict)
            echo -e "  ${CYAN}→${NC} .bashrc'de zsh ile çakışabilecek ayarlar var"
            ;;
    esac
}

auto_fix_blocker() {
    local blocker=$1
    local issue_type="${blocker%%:*}"
    local issue_data="${blocker#*:}"
    
    echo -e "${CYAN}Düzeltiliyor: $issue_type${NC}"
    
    case "$issue_type" in
        broken_ohmyzsh)
            echo "  Bozuk Oh My Zsh kaldırılıyor..."
            rm -rf ~/.oh-my-zsh
            echo -e "  ${GREEN}✓${NC} Temizlendi"
            ;;
            
        missing_locale)
            echo "  UTF-8 locale oluşturuluyor..."
            if sudo locale-gen en_US.UTF-8 &>/dev/null; then
                echo -e "  ${GREEN}✓${NC} Locale oluşturuldu"
            else
                echo -e "  ${YELLOW}⚠${NC}  Manuel düzeltme gerekebilir"
            fi
            ;;
            
        critical_disk_space)
            echo "  Disk alanı temizleme önerileri:"
            echo "    • sudo apt clean"
            echo "    • sudo apt autoremove"
            echo "    • ~/.cache dizinini temizle"
            echo
            echo -n "  Otomatik temizlik yapsın mı? (e/h): "
            read -r clean_choice
            if [[ "$clean_choice" == "e" ]]; then
                sudo apt clean &>/dev/null
                sudo apt autoremove -y &>/dev/null
                echo -e "  ${GREEN}✓${NC} Temizlendi"
            fi
            ;;
            
        apt_locked)
            echo "  APT kilidi kontrol ediliyor..."
            echo "  Lütfen bekleyin, diğer paket işlemleri tamamlanıyor..."
            local wait_count=0
            while pgrep -x "apt" >/dev/null || pgrep -x "apt-get" >/dev/null; do
                sleep 2
                ((wait_count++))
                if [ $wait_count -gt 30 ]; then
                    echo -e "  ${YELLOW}⚠${NC}  Timeout - Manuel müdahale gerekebilir"
                    break
                fi
            done
            if ! pgrep -x "apt" >/dev/null && ! pgrep -x "apt-get" >/dev/null; then
                echo -e "  ${GREEN}✓${NC} APT kilidi açıldı"
            fi
            ;;
            
        font_dir_permission)
            echo "  Font dizini izinleri düzeltiliyor..."
            mkdir -p ~/.local/share/fonts
            chmod 755 ~/.local/share/fonts
            echo -e "  ${GREEN}✓${NC} İzinler düzeltildi"
            ;;
    esac
}

apply_all_suggestions() {
    local suggestions=("$@")
    
    for suggestion in "${suggestions[@]}"; do
        local sug_type="${suggestion%%:*}"
        
        case "$sug_type" in
            install_python3)
                echo -n "Python3 kuruluyor... "
                if sudo apt install -y python3 &>/dev/null; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${YELLOW}⚠${NC}"
                fi
                ;;
                
            configure_git)
                echo "Git konfigürasyonu:"
                read -p "  İsim: " git_name
                read -p "  E-posta: " git_email
                git config --global user.name "$git_name"
                git config --global user.email "$git_email"
                echo -e "${GREEN}✓${NC} Git yapılandırıldı"
                ;;
        esac
    done
}

# ============================================================================
# KURULUM SONRASI DOĞRULAMA
# ============================================================================

post_installation_verification() {
    local component=$1
    
    log_debug "Post-installation verification: $component"
    
    case "$component" in
        zsh)
            verify_zsh_installation
            ;;
        ohmyzsh)
            verify_ohmyzsh_installation
            ;;
        powerlevel10k)
            verify_powerlevel10k_installation
            ;;
        plugins)
            verify_plugins_installation
            ;;
        fonts)
            verify_fonts_installation
            ;;
        *)
            log_debug "Bilinmeyen component: $component"
            return 0
            ;;
    esac
}

verify_zsh_installation() {
    local issues=()
    
    # Komut var mı?
    if ! command -v zsh &>/dev/null; then
        issues+=("Zsh komutu bulunamadı")
    fi
    
    # Versiyon alınabiliyor mu?
    if ! zsh --version &>/dev/null; then
        issues+=("Zsh çalıştırılamıyor")
    fi
    
    # /etc/shells'de var mı?
    if ! grep -q "$(which zsh 2>/dev/null)" /etc/shells 2>/dev/null; then
        issues+=("Zsh /etc/shells'de yok")
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        log_warning "Zsh kurulumunda sorunlar tespit edildi:"
        for issue in "${issues[@]}"; do
            log_warning "  • $issue"
        done
        
        echo -n "Zsh'i yeniden kurmayı dene? (e/h): "
        read -r reinstall
        if [[ "$reinstall" == "e" ]]; then
            sudo apt install --reinstall -y zsh &>/dev/null
            verify_zsh_installation
        fi
        return 1
    fi
    
    log_success "Zsh kurulumu doğrulandı"
    return 0
}

verify_ohmyzsh_installation() {
    local issues=()
    
    if [[ ! -d ~/.oh-my-zsh ]]; then
        issues+=("Oh My Zsh dizini bulunamadı")
    fi
    
    if [[ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]]; then
        issues+=("oh-my-zsh.sh dosyası eksik")
    fi
    
    if [[ ! -f ~/.zshrc ]]; then
        issues+=(".zshrc dosyası bulunamadı")
    elif ! grep -q "oh-my-zsh" ~/.zshrc 2>/dev/null; then
        issues+=(".zshrc'de Oh My Zsh referansı yok")
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        log_warning "Oh My Zsh kurulumunda sorunlar:"
        for issue in "${issues[@]}"; do
            log_warning "  • $issue"
        done
        return 1
    fi
    
    log_success "Oh My Zsh kurulumu doğrulandı"
    return 0
}

verify_powerlevel10k_installation() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    local issues=()
    
    if [[ ! -d "$p10k_dir" ]]; then
        issues+=("Powerlevel10k dizini bulunamadı")
    fi
    
    if [[ ! -f "$p10k_dir/powerlevel10k.zsh-theme" ]]; then
        issues+=("Tema dosyası eksik")
    fi
    
    if [[ -f ~/.zshrc ]]; then
        local theme=$(grep "^ZSH_THEME=" ~/.zshrc 2>/dev/null | cut -d'"' -f2)
        if [[ "$theme" != "powerlevel10k/powerlevel10k" ]]; then
            issues+=(".zshrc'de tema ayarı yanlış: $theme")
        fi
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        log_warning "Powerlevel10k kurulumunda sorunlar:"
        for issue in "${issues[@]}"; do
            log_warning "  • $issue"
        done
        return 1
    fi
    
    log_success "Powerlevel10k kurulumu doğrulandı"
    return 0
}

verify_plugins_installation() {
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local issues=()
    
    if [[ ! -d "$custom/plugins/zsh-autosuggestions" ]]; then
        issues+=("zsh-autosuggestions eksik")
    fi
    
    if [[ ! -d "$custom/plugins/zsh-syntax-highlighting" ]]; then
        issues+=("zsh-syntax-highlighting eksik")
    fi
    
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q "zsh-autosuggestions" ~/.zshrc 2>/dev/null; then
            issues+=(".zshrc'de autosuggestions aktif değil")
        fi
        if ! grep -q "zsh-syntax-highlighting" ~/.zshrc 2>/dev/null; then
            issues+=(".zshrc'de syntax-highlighting aktif değil")
        fi
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        log_warning "Plugin kurulumunda sorunlar:"
        for issue in "${issues[@]}"; do
            log_warning "  • $issue"
        done
        return 1
    fi
    
    log_success "Pluginler doğrulandı"
    return 0
}

verify_fonts_installation() {
    local font_dir=~/.local/share/fonts
    local issues=()
    
    if [[ ! -d "$font_dir" ]]; then
        issues+=("Font dizini yok")
    fi
    
    if ! fc-list 2>/dev/null | grep -q "MesloLGS"; then
        issues+=("MesloLGS NF fontları sistemde görünmüyor")
    fi
    
    local meslo_count=$(ls "$font_dir"/MesloLGS* 2>/dev/null | wc -l)
    if [ "$meslo_count" -lt 4 ]; then
        issues+=("Eksik font dosyaları (Bulundu: $meslo_count, Beklenen: 4)")
    fi
    
    if [ ${#issues[@]} -gt 0 ]; then
        log_warning "Font kurulumunda sorunlar:"
        for issue in "${issues[@]}"; do
            log_warning "  • $issue"
        done
        
        echo "Font sorunlarını düzeltmek için:"
        echo "  1. Terminal Preferences → Font → MesloLGS NF Regular"
        echo "  2. Veya fontları yeniden kur (Ana Menü → 6)"
        return 1
    fi
    
    log_success "Fontlar doğrulandı"
    return 0
}

# ============================================================================
# İNTERAKTİF SORUN GİDERME SIHIRBAZI
# ============================================================================

troubleshooting_wizard() {
    while true; do
        clear
        show_banner
        echo
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║   🔍 SORUN GİDERME SIHIRBAZI                          ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo
        echo "Ne tür bir sorun yaşıyorsunuz?"
        echo
        echo -e "${WHITE}1)${NC} Kurulum hiç başlamıyor"
        echo -e "${WHITE}2)${NC} Kurulum yarıda kaldı"
        echo -e "${WHITE}3)${NC} Kurulum bitti ama değişiklik görmüyorum"
        echo -e "${WHITE}4)${NC} Renkler/fontlar bozuk görünüyor"
        echo -e "${WHITE}5)${NC} Shell değişmedi (hala Bash)"
        echo -e "${WHITE}6)${NC} Eski haline dönmek istiyorum"
        echo -e "${WHITE}7)${NC} Emin değilim, sistem otomatik kontrol etsin"
        echo -e "${WHITE}0)${NC} Ana menüye dön"
        echo
        echo -ne "${CYAN}Seçiminiz (0-7): ${NC}"
        read -r issue_choice
        
        case $issue_choice in
            1) diagnose_startup_failure ;;
            2) diagnose_incomplete_install ;;
            3) diagnose_no_visual_changes ;;
            4) diagnose_visual_issues ;;
            5) diagnose_shell_not_changed ;;
            6) guided_rollback ;;
            7) automated_full_diagnosis ;;
            0) return 0 ;;
            *) 
                log_error "Geçersiz seçim"
                sleep 1
                ;;
        esac
        
        if [[ "$issue_choice" != "0" ]]; then
            echo
            read -p "Ana menüye dönmek için Enter'a basın..."
        fi
    done
}

diagnose_startup_failure() {
    echo
    echo -e "${YELLOW}═══ Başlangıç Hatası Teşhisi ═══${NC}"
    echo
    
    # Sudo kontrolü
    echo -n "1. Sudo yetkisi... "
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo
        echo -e "${CYAN}Çözüm:${NC}"
        echo "  Sudo şifreniz gerekiyor:"
        echo -e "  ${CYAN}sudo -v${NC}"
        echo
        echo -n "Şimdi dene? (e/h): "
        read -r try_sudo
        if [[ "$try_sudo" == "e" ]]; then
            sudo -v && echo -e "${GREEN}✓ Düzeltildi${NC}"
        fi
        return
    fi
    
    # İnternet bağlantısı
    echo -n "2. İnternet bağlantısı... "
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo
        echo -e "${CYAN}Çözüm:${NC}"
        echo "  İnternet bağlantınızı kontrol edin"
        echo "  • WiFi/Ethernet bağlı mı?"
        echo "  • Proxy ayarları doğru mu?"
        return
    fi
    
    # Script dosyaları
    echo -n "3. Script dosyaları... "
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local required_files=("terminal-core.sh" "terminal-ui.sh" "terminal-themes.sh" "terminal-utils.sh")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$script_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo
        echo -e "${CYAN}Eksik dosyalar:${NC}"
        for file in "${missing_files[@]}"; do
            echo "  • $file"
        done
        echo
        echo "Tüm script dosyalarını aynı dizine indirin"
        return
    fi
    
    echo
    echo -e "${GREEN}✓ Temel kontroller başarılı${NC}"
    echo "Kuruluma başlayabilirsiniz"
}

diagnose_incomplete_install() {
    echo
    echo -e "${YELLOW}═══ Yarım Kalmış Kurulum Teşhisi ═══${NC}"
    echo
    
    echo "Kurulumun hangi adımda kaldığını tespit ediyorum..."
    echo
    
    local completed_steps=()
    local failed_step=""
    
    # Adım kontrolü
    if command -v zsh &>/dev/null; then
        completed_steps+=("Zsh")
    else
        failed_step="Zsh kurulumu"
    fi
    
    if [[ -d ~/.oh-my-zsh ]] && [[ -z "$failed_step" ]]; then
        completed_steps+=("Oh My Zsh")
    elif [[ -z "$failed_step" ]]; then
        failed_step="Oh My Zsh kurulumu"
    fi
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]] && [[ -z "$failed_step" ]]; then
        completed_steps+=("Powerlevel10k")
    elif [[ -z "$failed_step" ]]; then
        failed_step="Powerlevel10k kurulumu"
    fi
    
    if fc-list 2>/dev/null | grep -q "MesloLGS"; then
        completed_steps+=("Fontlar")
    fi
    
    # Sonuç
    if [ ${#completed_steps[@]} -gt 0 ]; then
        echo -e "${GREEN}Tamamlanan adımlar:${NC}"
        for step in "${completed_steps[@]}"; do
            echo -e "  ${GREEN}✓${NC} $step"
        done
        echo
    fi
    
    if [[ -n "$failed_step" ]]; then
        echo -e "${RED}Kalan adım:${NC} $failed_step"
        echo
        echo -e "${CYAN}Önerilen çözüm:${NC}"
        echo "  Ana menüden sadece eksik adımı tekrar çalıştırın"
        echo "  Örneğin: Seçenek 5 (Sadece Zsh) veya 6 (Sadece Tema)"
    else
        echo -e "${GREEN}✓ Tüm adımlar tamamlanmış görünüyor${NC}"
        echo
        echo "Değişiklikleri görmek için:"
        echo -e "  ${CYAN}exec zsh${NC}"
        echo "  veya yeni terminal penceresi açın"
    fi
}

diagnose_no_visual_changes() {
    echo
    echo -e "${YELLOW}═══ Görsel Değişiklik Yok Teşhisi ═══${NC}"
    echo
    
    # En yaygın sebep: Terminal yenilenmemiş
    echo -e "${CYAN}1. Terminal yenileme kontrolü${NC}"
    echo "   Değişiklikleri görmek için terminali yenilemeniz gerekir"
    echo
    echo "   Seçenekler:"
    echo -e "   a) ${CYAN}exec zsh${NC} (önerilen)"
    echo "   b) Terminali tamamen kapat ve yeni açta aç"
    echo "   c) Oturumu kapat ve tekrar gir"
    echo
    
    # Shell kontrolü
    echo -e "${CYAN}2. Aktif shell kontrolü${NC}"
    local current_shell=$(ps -p $$ -o comm=)
    echo -n "   Şu an: $current_shell "
    
    if [[ "$current_shell" == *"zsh"* ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ (Hala Bash)${NC}"
        echo
        echo "   Shell değişmemiş. Çözüm:"
        echo -e "   ${CYAN}exec zsh${NC}"
        return
    fi
    
    # Tema kontrolü
    echo -e "${CYAN}3. Tema kontrolü${NC}"
    if [[ -f ~/.zshrc ]]; then
        local theme=$(grep "^ZSH_THEME=" ~/.zshrc 2>/dev/null | cut -d'"' -f2)
        echo "   .zshrc tema: $theme"
        
        if [[ "$theme" == "powerlevel10k/powerlevel10k" ]]; then
            echo -e "   ${GREEN}✓ Tema doğru ayarlanmış${NC}"
        else
            echo -e "   ${YELLOW}⚠ Tema ayarı beklenen değil${NC}"
        fi
    fi
    
    echo
    echo -e "${GREEN}Hızlı çözüm:${NC}"
    echo -e "  ${CYAN}source ~/.zshrc${NC}"
    echo
    echo -n "Şimdi çalıştır? (e/h): "
    read -r reload_choice
    if [[ "$reload_choice" == "e" ]]; then
        echo "Terminal yenileniyor..."
        if [[ -f ~/.zshrc ]]; then
            source ~/.zshrc 2>/dev/null && echo -e "${GREEN}✓ Yenilendi${NC}" || echo -e "${RED}Hata oluştu${NC}"
        fi
    fi
}

diagnose_visual_issues() {
    echo
    echo -e "${YELLOW}═══ Görsel Sorunlar Teşhisi ═══${NC}"
    echo
    
    # Font kontrolü
    echo -e "${CYAN}1. Font kontrolü${NC}"
    if fc-list 2>/dev/null | grep -q "MesloLGS"; then
        echo -e "   ${GREEN}✓${NC} MesloLGS NF fontları kurulu"
        
        # Hangi fontlar var?
        local font_count=$(fc-list | grep -c "MesloLGS")
        echo "   Bulunan font sayısı: $font_count"
        
        if [ "$font_count" -lt 4 ]; then
            echo -e "   ${YELLOW}⚠${NC} Eksik font varyantları olabilir"
        fi
    else
        echo -e "   ${RED}✗${NC} MesloLGS NF fontları bulunamadı"
        echo
        echo "   Çözüm: Ana menüden Seçenek 6 ile fontları kurun"
        return
    fi
    
    # Terminal font ayarı
    echo
    echo -e "${CYAN}2. Terminal font ayarı${NC}"
    echo "   Terminalinizde manuel olarak font ayarlamanız gerekir:"
    echo
    echo "   GNOME Terminal:"
    echo "   • Preferences → Profile → Text → Font"
    echo "   • 'MesloLGS NF Regular 12' seçin"
    echo
    echo "   Kitty:"
    echo "   • ~/.config/kitty/kitty.conf"
    echo "   • font_family MesloLGS NF Regular"
    echo
    
    # Terminal tip kontrolü
    echo -e "${CYAN}3. Terminal tipi${NC}"
    local terminal=$(detect_terminal)
    echo "   Tespit edilen: $terminal"
    
    if [[ "$terminal" == "gnome-terminal" ]]; then
        echo -e "   ${GREEN}✓${NC} Tam uyumlu"
    elif [[ "$terminal" == "kitty" ]] || [[ "$terminal" == "alacritty" ]]; then
        echo -e "   ${GREEN}✓${NC} Uyumlu (config gerekebilir)"
    else
        echo -e "   ${YELLOW}⚠${NC} Sınırlı destek"
    fi
    
    # Renk testi
    echo
    echo -e "${CYAN}4. Renk desteği testi${NC}"
    echo -n "   16M renk: "
    if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ $COLORTERM${NC}"
    fi
}

diagnose_shell_not_changed() {
    echo
    echo -e "${YELLOW}═══ Shell Değişmedi Sorunu ═══${NC}"
    echo
    
    run_comprehensive_shell_check
    echo
    provide_shell_fix_commands
}

guided_rollback() {
    echo
    echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   GERİ ALMA İŞLEMİ                                    ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo "Ne yapmak istiyorsunuz?"
    echo
    echo "1) Sadece renk temasını varsayılana döndür"
    echo "2) Powerlevel10k'yi kaldır, basit tema kullan"
    echo "3) Tamamen eski haline dön (tam kaldırma)"
    echo "0) İptal"
    echo
    read -p "Seçim: " rollback_choice
    
    case $rollback_choice in
        1)
            reset_terminal_profile
            echo -e "${GREEN}✓ Renk teması sıfırlandı${NC}"
            ;;
        2)
            if [[ -f ~/.zshrc ]]; then
                sed -i 's/^ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' ~/.zshrc
                echo -e "${GREEN}✓ Basit tema ayarlandı${NC}"
                echo "Değişiklik için: source ~/.zshrc"
            fi
            ;;
        3)
            echo
            echo -e "${RED}DİKKAT: Tam kaldırma yapılacak${NC}"
            echo -n "Emin misiniz? (evet/hayır): "
            read -r confirm
            if [[ "$confirm" == "evet" ]]; then
                uninstall_all
            else
                echo "İptal edildi"
            fi
            ;;
        0)
            echo "İptal edildi"
            ;;
    esac
}

automated_full_diagnosis() {
    echo
    echo -e "${CYAN}═══ Otomatik Tam Teşhis Başlıyor ═══${NC}"
    echo
    
    echo "1/7 - Sistem sağlığı kontrol ediliyor..."
    system_health_check
    
    echo
    echo "2/7 - Kurulum bileşenleri doğrulanıyor..."
    verify_zsh_installation
    verify_ohmyzsh_installation
    verify_powerlevel10k_installation
    verify_plugins_installation
    verify_fonts_installation
    
    echo
    echo "3/7 - Shell durumu analiz ediliyor..."
    run_comprehensive_shell_check
    
    echo
    echo "4/7 - Terminal uyumluluğu kontrol ediliyor..."
    show_terminal_info
    
    echo
    echo "5/7 - Disk ve izinler kontrol ediliyor..."
    check_system_resources
    
    echo
    echo "6/7 - Log dosyaları analiz ediliyor..."
    if [[ -f "$LOG_FILE" ]]; then
        local error_count=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
        local warning_count=$(grep -c "WARNING" "$LOG_FILE" 2>/dev/null || echo "0")
        echo "   Hatalar: $error_count"
        echo "   Uyarılar: $warning_count"
        
        if [ "$error_count" -gt 0 ]; then
            echo
            echo "   Son 5 hata:"
            grep "ERROR" "$LOG_FILE" | tail -5 | while read line; do
                echo "   $line"
            done
        fi
    fi
    
    echo
    echo "7/7 - Özet rapor hazırlanıyor..."
    echo
    echo -e "${GREEN}═══ TEŞHİS TAMAMLANDI ═══${NC}"
    echo
    echo "Sorun tespit edildiyse yukarıdaki çıktıları inceleyin"
    echo "Çözüm önerileri için ilgili menü seçeneklerini kullanın"
}

# ============================================================================
# BAĞLAMSAL YARDIM SİSTEMİ
# ============================================================================

show_contextual_help() {
    local context="${1:-general}"
    
    case "$context" in
        first_time)
            show_first_time_user_help
            ;;
        post_zsh)
            show_post_zsh_help
            ;;
        post_install)
            show_post_install_help
            ;;
        troubleshoot)
            show_troubleshoot_tips
            ;;
        *)
            show_general_help
            ;;
    esac
}

show_first_time_user_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════╗
║  YENİ KULLANICI REHBERİ                               ║
╚═══════════════════════════════════════════════════════╝

Terminal Komutları Hakkında:
  • sudo: Yönetici yetkisiyle komut çalıştırır
  • Tab tuşu: Komutları otomatik tamamlar  
  • Ctrl+C: Çalışan işlemi durdurur
  • Yukarı ok: Önceki komutları gösterir

Bu Kurulum Şunları Yapacak:
  1. Bash yerine Zsh kullanacaksınız (daha güçlü)
  2. Renkli ve bilgilendirici bir tema olacak
  3. Otomatik tamamlama aktif olacak
  4. Gelişmiş özellikler eklenecek

Sorun Yaşarsanız:
  • Ana menüden "Sistem Sağlık Kontrolü" (11)
  • Veya "Sorun Giderme Sihirbazı" kullanın

Önerilen İlk Kurulum:
  • Dracula teması (1) - Popüler ve göz yormaz
  • Veya sistem otomatik tarama yapsın (Seçenek 7)

EOF
}

show_post_zsh_help() {
    cat << 'EOF'
✓ Zsh Kuruldu! Şimdi Ne Yapmalı?

İki Seçeneğiniz Var:

1. TAM KURULUM (Önerilen - Yeni Kullanıcılar İçin)
   → Ana menüden 1-4 arası tema seçin
   → Her şey otomatik kurulur
   → 5 dakikada hazır

2. ADIM ADIM (İleri Seviye)
   → Seçenek 6: Powerlevel10k
   → Seçenek 8: Pluginler  
   → Seçenek 7: Renk teması değiştir

İpucu: İlk kez kullanıyorsanız "Dracula" (1) önerilir

EOF
}

show_post_install_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════╗
║  KURULUM TAMAMLANDI - SONRAKİ ADIMLAR                 ║
╚═══════════════════════════════════════════════════════╝

Değişiklikleri Görmek İçin:
  1. Bu terminali KAPATIN
  2. Yeni terminal penceresi açın
  3. Veya şunu çalıştırın: exec zsh

İlk Açılışta:
  • Powerlevel10k yapılandırma wizard'ı açılacak
  • Sorulara göre tema şekillenecek
  • İstediğiniz zaman "p10k configure" ile değiştirebilirsiniz

Kullanışlı Komutlar:
  • p10k configure: Tema ayarları
  • source ~/.zshrc: Ayarları yenile
  • echo $SHELL: Aktif shell'i göster

Sorun mu Var?
  • Seçenek 12: Otomatik Teşhis
  • Seçenek 11: Sistem Sağlık Kontrolü

EOF
}

show_general_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════╗
║  GENEL YARDIM                                         ║
╚═══════════════════════════════════════════════════════╝

Menü Seçenekleri:
  1-4   : Tam kurulum (tema ile birlikte)
  5-10  : Modüler kurulum (sadece istediğiniz)
  11-15 : Yönetim ve sorun giderme

Sık Sorulan Sorular:

S: Kurulum ne kadar sürer?
C: Tam kurulum 3-5 dakika (internet hızına bağlı)

S: Eski haline dönebilir miyim?
C: Evet, Seçenek 14 ile tamamen kaldırabilirsiniz

S: Hangi terminallerde çalışır?
C: GNOME Terminal (en iyi), Kitty, Alacritty

S: Değişiklikleri görmüyorum?
C: Terminal penceresini yenileyin veya "exec zsh"

Daha Fazla Yardım:
  GitHub: github.com/alibedirhan/Theme-after-format

EOF
}

# ============================================================================
# YÜKLENİYOR MESAJIç
# ============================================================================

log_info "Terminal Assistant modülü yüklendi (v1.0.0)"