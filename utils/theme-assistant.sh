#!/bin/bash

# ============================================================================
# Theme Assistant - Smart theme recommendation system
# ============================================================================

# ============================================================================
# SMART RECOMMENDATIONS
# ============================================================================

get_theme_recommendation() {
    local system_memory=$(free -g | awk 'NR==2{print $2}')
    local gpu_vendor=$(detect_gpu_vendor)
    local de=$DETECTED_DE
    
    # Low memory systems
    if [[ $system_memory -lt 4 ]]; then
        echo "Arc Dark (Hafif, düşük RAM için optimize)"
        return
    fi
    
    # GPU-based recommendations
    case "$gpu_vendor" in
        "NVIDIA")
            echo "Pop Dark (NVIDIA driver'ları ile mükemmel uyum)"
            ;;
        "AMD")
            echo "Yaru Dark (AMD ile optimize)"
            ;;
        *)
            # Default recommendation based on DE
            case "$de" in
                "GNOME")
                    echo "Arc Dark (GNOME için en popüler)"
                    ;;
                "KDE")
                    echo "Dracula (KDE Plasma ile harika)"
                    ;;
                "XFCE")
                    echo "Arc Dark (XFCE için hafif ve modern)"
                    ;;
                "MATE")
                    echo "Yaru Dark (MATE uyumlu)"
                    ;;
                "Cinnamon")
                    echo "Nord (Mint kullanıcıları seviyor)"
                    ;;
                *)
                    echo "Arc Dark (Genel kullanım için ideal)"
                    ;;
            esac
            ;;
    esac
}

show_theme_assistant_recommendation() {
    local recommendation=$(get_theme_recommendation)
    local system_status=$(check_system_compatibility)
    
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                   AKILLI ASİSTAN                             ║${NC}"
    echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} 💡 ${BOLD}Öneri:${NC} $recommendation"
    echo -e "${WHITE}║${NC} 🔍 ${BOLD}Sistem:${NC} $system_status"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

check_system_compatibility() {
    local mem=$(detect_system_memory)
    local gpu=$(detect_gpu_vendor)
    local de=$DETECTED_DE
    
    echo "$de | RAM: $mem | GPU: $gpu"
}

# ============================================================================
# USAGE PATTERN ANALYSIS
# ============================================================================

analyze_user_pattern() {
    # Check if user is a developer
    local is_dev=false
    if [[ -d "$HOME/.vscode" ]] || [[ -d "$HOME/.config/Code" ]] || \
       command -v code &> /dev/null || command -v vim &> /dev/null; then
        is_dev=true
    fi
    
    # Check if user prefers performance
    local prefers_performance=false
    local mem=$(free -g | awk 'NR==2{print $2}')
    if [[ $mem -lt 8 ]]; then
        prefers_performance=true
    fi
    
    # Recommend based on pattern
    if [[ "$is_dev" == true ]]; then
        if [[ "$prefers_performance" == true ]]; then
            echo "developer|performance"
        else
            echo "developer|aesthetic"
        fi
    else
        if [[ "$prefers_performance" == true ]]; then
            echo "casual|performance"
        else
            echo "casual|aesthetic"
        fi
    fi
}

get_pattern_based_recommendation() {
    local pattern=$(analyze_user_pattern)
    
    case "$pattern" in
        "developer|performance")
            echo "Dracula veya Gruvbox (Developer favorisi, hafif)"
            ;;
        "developer|aesthetic")
            echo "Tokyo Night veya Catppuccin (Modern developer themes)"
            ;;
        "casual|performance")
            echo "Arc Dark veya Yaru (Hafif, günlük kullanım)"
            ;;
        "casual|aesthetic")
            echo "Nord veya Catppuccin (Göz alıcı, rahat)"
            ;;
        *)
            echo "Arc Dark (Genel kullanım)"
            ;;
    esac
}

# ============================================================================
# INTERACTIVE GUIDE
# ============================================================================

interactive_theme_guide() {
    clear
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║              İNTERAKTİF TEMA REHBERİ                         ║${NC}"
    echo -e "${MAGENTA}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    echo "Birkaç soru ile size en uygun temayı bulalım!"
    echo
    
    # Question 1: Usage type
    echo "1. Bilgisayarı ne için kullanıyorsunuz?"
    echo "   a) Yazılım geliştirme"
    echo "   b) Günlük kullanım (web, ofis)"
    echo "   c) Tasarım/Yaratıcı işler"
    echo
    read -p "Seçiminiz (a/b/c): " usage_type
    
    # Question 2: Color preference
    echo
    echo "2. Renk tercihiniz?"
    echo "   a) Soğuk tonlar (Mavi, Mor)"
    echo "   b) Sıcak tonlar (Turuncu, Kahverengi)"
    echo "   c) Neon/Parlak renkler"
    echo "   d) Minimalist/Sade"
    echo
    read -p "Seçiminiz (a/b/c/d): " color_pref
    
    # Question 3: Performance
    echo
    echo "3. Performans önceliğiniz?"
    echo "   a) Maksimum performans (hafif)"
    echo "   b) Denge (orta)"
    echo "   c) Görsellik önce (performans ikinci planda)"
    echo
    read -p "Seçiminiz (a/b/c): " perf_pref
    
    # Analyze answers
    local recommended_theme=""
    
    if [[ "$usage_type" == "a" ]]; then
        # Developer
        case "$color_pref" in
            "a") recommended_theme="dracula" ;;
            "b") recommended_theme="gruvbox" ;;
            "c") recommended_theme="tokyonight" ;;
            "d") recommended_theme="arc" ;;
        esac
    elif [[ "$usage_type" == "c" ]]; then
        # Designer
        case "$color_pref" in
            "a") recommended_theme="nord" ;;
            "b") recommended_theme="gruvbox" ;;
            "c") recommended_theme="cyberpunk" ;;
            "d") recommended_theme="catppuccin" ;;
        esac
    else
        # Casual user
        if [[ "$perf_pref" == "a" ]]; then
            recommended_theme="yaru"
        else
            case "$color_pref" in
                "a") recommended_theme="nord" ;;
                "b") recommended_theme="arc" ;;
                "c") recommended_theme="cyberpunk" ;;
                "d") recommended_theme="catppuccin" ;;
            esac
        fi
    fi
    
    # Show recommendation
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ÖNERİLEN TEMA                             ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    local theme_name=""
    case "$recommended_theme" in
        "arc") theme_name="Arc Dark" ;;
        "yaru") theme_name="Yaru Dark" ;;
        "dracula") theme_name="Dracula" ;;
        "nord") theme_name="Nord" ;;
        "gruvbox") theme_name="Gruvbox" ;;
        "tokyonight") theme_name="Tokyo Night" ;;
        "catppuccin") theme_name="Catppuccin Mocha" ;;
        "cyberpunk") theme_name="Cyberpunk Neon" ;;
    esac
    
    echo -e "   ${BOLD}${MAGENTA}🎨 $theme_name${NC}"
    echo
    show_theme_preview "$recommended_theme" "$theme_name"
    echo
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    read -p "Bu temayı şimdi kurmak ister misiniz? (e/h): " install_now
    
    if [[ "$install_now" == "e" ]]; then
        apply_theme_package "$recommended_theme"
    fi
}

# ============================================================================
# THEME COMPARISON
# ============================================================================

compare_themes() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    TEMA KARŞILAŞTIRMA                        ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo
    
    echo "Karşılaştırmak istediğiniz temaları seçin:"
    echo
    echo "1. Arc vs Yaru (Hafif temalar)"
    echo "2. Dracula vs Nord (Developer favorites)"
    echo "3. Catppuccin vs Tokyo Night (Modern themes)"
    echo "4. Gruvbox vs Cyberpunk (Aesthetic extremes)"
    echo "5. Özel karşılaştırma"
    echo "0. Geri dön"
    echo
    read -p "Seçiminiz (0-5): " choice
    
    case $choice in
        1) compare_two_themes "arc" "yaru" ;;
        2) compare_two_themes "dracula" "nord" ;;
        3) compare_two_themes "catppuccin" "tokyonight" ;;
        4) compare_two_themes "gruvbox" "cyberpunk" ;;
        5) custom_comparison ;;
        0) return ;;
    esac
}

compare_two_themes() {
    local theme1="$1"
    local theme2="$2"
    
    echo
    echo -e "${BOLD}═══ $theme1 vs $theme2 ═══${NC}"
    echo
    
    echo -e "${MAGENTA}Tema 1: ${theme1^^}${NC}"
    show_theme_preview "$theme1" "$theme1"
    
    echo
    echo -e "${MAGENTA}Tema 2: ${theme2^^}${NC}"
    show_theme_preview "$theme2" "$theme2"
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

custom_comparison() {
    echo
    echo "İlk tema adı (arc/yaru/pop/dracula/nord/catppuccin/gruvbox/tokyonight/cyberpunk):"
    read -r theme1
    echo "İkinci tema adı:"
    read -r theme2
    
    compare_two_themes "$theme1" "$theme2"
}

# ============================================================================
# QUICK TIPS
# ============================================================================

show_quick_tips() {
    local random_tip=$((RANDOM % 10 + 1))
    
    case $random_tip in
        1) echo "💡 İpucu: GNOME Tweaks ile ince ayarlar yapabilirsiniz" ;;
        2) echo "💡 İpucu: Papirus icon'larının rengini papirus-folders ile değiştirin" ;;
        3) echo "💡 İpucu: Logout/login ile tüm değişiklikler aktif olur" ;;
        4) echo "💡 İpucu: ZSH config'iniz otomatik korunuyor" ;;
        5) echo "💡 İpucu: Her tema için yedek otomatik oluşturuluyor" ;;
        6) echo "💡 İpucu: Sistem ayarlarından animasyonları kapatarak hız kazanın" ;;
        7) echo "💡 İpucu: Extensions.gnome.org'dan User Themes kurmayı unutmayın" ;;
        8) echo "💡 İpucu: Alt+F2 → 'r' ile GNOME Shell'i yeniden başlatın" ;;
        9) echo "💡 İpucu: Dracula temasının 200+ uygulama desteği var" ;;
        10) echo "💡 İpucu: Nord teması göz yormayan renklerle uzun çalışma için ideal" ;;
    esac
}

# ============================================================================
# THEME RATING SYSTEM
# ============================================================================

get_theme_rating() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "yaru") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "pop") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "dracula") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "nord") echo "⭐⭐⭐⭐☆ (4/5)" ;;
        "catppuccin") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "gruvbox") echo "⭐⭐⭐⭐☆ (4/5)" ;;
        "tokyonight") echo "⭐⭐⭐⭐⭐ (5/5)" ;;
        "cyberpunk") echo "⭐⭐⭐⭐☆ (4/5)" ;;
        *) echo "⭐⭐⭐☆☆ (3/5)" ;;
    esac
}

get_theme_popularity() {
    local theme="$1"
    
    case "$theme" in
        "arc") echo "En Popüler (#1)" ;;
        "yaru") echo "Ubuntu Native (#2)" ;;
        "dracula") echo "Developer Favorite (#1)" ;;
        "catppuccin") echo "Trending 2024 (#1)" ;;
        "tokyonight") echo "VS Code #1 Theme" ;;
        *) echo "Popüler" ;;
    esac
}

# ============================================================================
# MODULE INFO
# ============================================================================

log_info "theme-assistant.sh modülü yüklendi"
