#!/bin/bash

# ============================================================================
# Smart Version Manager - Interactive Version Sync Tool
# v1.2.0 - Enhanced with Git Integration & Cross-Platform Support
# ============================================================================

set -euo pipefail

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Emojiler
ROBOT="🤖"
ROCKET="🚀"
SPARKLES="✨"
MAGNIFY="🔍"
WRENCH="🔧"
PACKAGE="📦"
CHECKMARK="✓"
BOOK="📖"
LIGHTBULB="💡"
TROPHY="🏆"

# ============================================================================
# BASİT YARDIM SİSTEMİ
# ============================================================================

show_simple_help() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║            SMART VERSION MANAGER - YARDIM                 ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    echo -e "${ROBOT} ${BOLD}BU SCRIPT NE İŞE YARAR?${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "Tüm dosyalardaki versiyon numaralarını (v3.2.5 gibi)"
    echo -e "tek seferde günceller. Manuel olarak 9 dosyayı"
    echo -e "tek tek düzenlemenize gerek kalmaz!"
    echo
    
    echo -e "${ROCKET} ${BOLD}NASIL KULLANILIR?${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}1.${NC} Scripti çalıştır:"
    echo -e "   ${CYAN}./smart-version-manager.sh${NC}"
    echo
    echo -e "${GREEN}2.${NC} Hangi versiyonu istediğini seç:"
    echo -e "   ${DIM}• Patch (3.2.5 → 3.2.6) Küçük düzeltmeler${NC}"
    echo -e "   ${DIM}• Minor (3.2.5 → 3.3.0) Yeni özellikler${NC}"
    echo -e "   ${DIM}• Major (3.2.5 → 4.0.0) Büyük değişiklikler${NC}"
    echo
    echo -e "${GREEN}3.${NC} Script otomatik olarak:"
    echo -e "   ${DIM}• Tüm dosyaları günceller${NC}"
    echo -e "   ${DIM}• Git commit yapar${NC}"
    echo -e "   ${DIM}• (İstersen) GitHub'a gönderir${NC}"
    echo
    
    echo -e "${SPARKLES} ${BOLD}ÖZELLİKLER${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "${CHECKMARK} Mevcut versiyonu otomatik bulur"
    echo -e "${CHECKMARK} Akıllı öneriler yapar (3.2.6, 3.3.0, 4.0.0)"
    echo -e "${CHECKMARK} 9 dosyayı aynı anda günceller"
    echo -e "${CHECKMARK} Git commit ve push yapar (opsiyonel)"
    echo -e "${CHECKMARK} Güzel progress bar gösterir"
    echo
    
    echo -e "${LIGHTBULB} ${BOLD}HIZLI ÖRNEK${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}./smart-version-manager.sh${NC}"
    echo -e "  ${DIM}↓${NC}"
    echo -e "  Mevcut: ${YELLOW}v3.2.5${NC}"
    echo -e "  Yeni: ${GREEN}v3.2.6${NC} seç"
    echo -e "  ${DIM}↓${NC}"
    echo -e "  ${GREEN}✓${NC} 9 dosya güncellendi"
    echo -e "  ${GREEN}✓${NC} Git'e gönderildi"
    echo -e "  ${GREEN}✓${NC} Tamamlandı!"
    echo
    
    echo -e "${BOOK} ${BOLD}HANGİ DOSYALARI GÜNCELLİYOR?${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "  • VERSION"
    echo -e "  • install.sh"
    echo -e "  • terminal-setup.sh"
    echo -e "  • terminal-ui.sh"
    echo -e "  • terminal-core.sh"
    echo -e "  • terminal-utils.sh"
    echo -e "  • terminal-assistant.sh"
    echo -e "  • terminal-themes.sh"
    echo -e "  • README.md"
    echo
    
    echo -e "${TROPHY} ${BOLD}İPUÇLARI${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────${NC}"
    echo -e "• ${YELLOW}Patch:${NC} Hata düzeltmeleri için (3.2.5 → 3.2.6)"
    echo -e "• ${YELLOW}Minor:${NC} Yeni özellikler için (3.2.5 → 3.3.0)"
    echo -e "• ${YELLOW}Major:${NC} Büyük değişiklikler için (3.2.5 → 4.0.0)"
    echo
    echo -e "${DIM}Semantic Versioning: MAJOR.MINOR.PATCH${NC}"
    echo
    
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}Devam etmek için Enter'a basın...${NC}"
    read -r
}

# ============================================================================
# BANNER
# ============================================================================

show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║                                                          ║
    ║     █████╗ ███╗   ███╗ █████╗ ███████╗███████╗        ║
    ║    ██╔══██╗████╗ ████║██╔══██╗██╔════╝██╔════╝        ║
    ║    ███████║██╔████╔██║███████║█████╗  █████╗          ║
    ║    ██╔══██║██║╚██╔╝██║██╔══██║██╔══╝  ██╔══╝          ║
    ║    ██║  ██║██║ ╚═╝ ██║██║  ██║███████╗███████╗        ║
    ║    ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝        ║
    ║                                                          ║
    ║           Version Manager - AI Assistant                 ║
    ║                  v1.2.0 | 2024                           ║
    ║                                                          ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.3
}

# ============================================================================
# YARDIMCI FONKSİYONLAR
# ============================================================================

show_spinner() {
    local pid=$1
    local message=$2
    local SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}${SPINNER[$i]}${NC} ${message}"
        i=$(( (i + 1) % ${#SPINNER[@]} ))
        sleep 0.1
    done
    printf "\r${GREEN}${CHECKMARK}${NC} ${message}\n"
}

show_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '░'
    printf "]${NC} ${BOLD}%3d%%${NC}" "$percentage"
    
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

# ============================================================================
# GIT FONKSİYONLARI (YENİ - İYİLEŞTİRİLMİŞ)
# ============================================================================

# Git repo kontrolü
check_git_repo() {
    if ! git rev-parse --git-dir &> /dev/null; then
        echo -e "${RED}✗${NC} Bu bir git repository değil!"
        return 1
    fi
    return 0
}

# Git remote kontrolü
check_git_remote() {
    if ! git remote get-url origin &> /dev/null; then
        echo -e "${YELLOW}⚠ ${NC} Git remote (origin) bulunamadı"
        echo -e "${DIM}Push işlemi yapılamayacak${NC}"
        return 1
    fi
    return 0
}

# Working tree temiz mi kontrol et
check_working_tree() {
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        echo -e "${YELLOW}⚠ ${NC} Working tree temiz değil!"
        echo
        echo -e "${DIM}Uncommitted değişiklikler:${NC}"
        git status --short | head -10
        echo
        echo -n "Devam etmek ister misiniz? (e/h): "
        read -r continue_choice
        if [[ "$continue_choice" != "e" ]]; then
            return 1
        fi
    fi
    return 0
}

# Mevcut branch'i al
get_current_branch() {
    git branch --show-current 2>/dev/null || echo "main"
}

# ============================================================================
# VERSİYON FONKSİYONLARI
# ============================================================================

# Version validation (Semantic Versioning)
validate_version() {
    local version=$1
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}✗${NC} Geçersiz versiyon formatı: $version"
        echo -e "${DIM}Beklenen format: MAJOR.MINOR.PATCH (örn: 3.2.5)${NC}"
        return 1
    fi
    return 0
}

detect_current_version() {
    local version=""
    
    if [[ -f VERSION ]]; then
        version=$(cat VERSION 2>/dev/null | tr -d '[:space:]')
    fi
    
    if [[ -z "$version" ]] && [[ -f terminal-setup.sh ]]; then
        version=$(grep '^VERSION=' terminal-setup.sh 2>/dev/null | cut -d'"' -f2 || echo "")
    fi
    
    if [[ -z "$version" ]]; then
        version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")
    fi
    
    echo "$version"
}

suggest_next_version() {
    local current=$1
    
    if [[ -z "$current" ]]; then
        echo "1.0.0|1.0.0|1.0.0"
        return
    fi
    
    IFS='.' read -r major minor patch <<< "$current"
    
    local patch_bump="${major}.${minor}.$((patch + 1))"
    local minor_bump="${major}.$((minor + 1)).0"
    local major_bump="$((major + 1)).0.0"
    
    echo "$patch_bump|$minor_bump|$major_bump"
}

# ============================================================================
# DOSYA TARAMA
# ============================================================================

scan_version_files() {
    echo -e "${CYAN}${MAGNIFY} Dosyalar taranıyor...${NC}"
    echo
    
    local files=(
        "VERSION:cat VERSION"
        "terminal-setup.sh:grep '^VERSION=' terminal-setup.sh | cut -d'\"' -f2"
        "install.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' install.sh | head -1 | sed 's/v//'"
        "terminal-ui.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-ui.sh | head -1 | sed 's/v//'"
        "terminal-core.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-core.sh | head -1 | sed 's/v//'"
        "terminal-utils.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-utils.sh | head -1 | sed 's/v//'"
        "terminal-assistant.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-assistant.sh | head -1 | sed 's/v//'"
        "terminal-themes.sh:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-themes.sh | head -1 | sed 's/v//'"
        "README.md:grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' README.md | head -1 | sed 's/v//'"
    )
    
    local inconsistent=0
    
    for file_cmd in "${files[@]}"; do
        local file="${file_cmd%%:*}"
        local cmd="${file_cmd##*:}"
        
        if [[ -f "$file" ]]; then
            local ver=$(eval "$cmd" 2>/dev/null || echo "N/A")
            
            printf "  ${DIM}%-25s${NC} " "$file"
            if [[ "$ver" != "N/A" ]]; then
                echo -e "${GREEN}$ver${NC}"
            else
                echo -e "${YELLOW}Bulunamadı${NC}"
                ((inconsistent++))
            fi
        fi
    done
    
    echo
    return $inconsistent
}

# ============================================================================
# VERSİYON GÜNCELLEME (İYİLEŞTİRİLMİŞ)
# ============================================================================

# Sed wrapper - macOS ve Linux uyumlu
sed_inplace() {
    local pattern=$1
    local file=$2
    
    # DÜZELTME: macOS uyumluluğu
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$pattern" "$file" 2>/dev/null
    else
        sed -i "$pattern" "$file" 2>/dev/null
    fi
}

update_versions() {
    local target_version=$1
    local total_files=9
    local current=0
    
    # DÜZELTME: Version validation
    if ! validate_version "$target_version"; then
        return 1
    fi
    
    echo -e "${WRENCH} ${CYAN}Versiyonlar güncelleniyor...${NC}"
    echo
    
    ((current++))
    show_progress_bar $current $total_files
    echo "$target_version" > VERSION
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" install.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/^VERSION=\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/VERSION=\"${target_version}\"/g" terminal-setup.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-ui.sh
    sed_inplace "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version ${target_version}/g" terminal-ui.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-core.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-utils.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-assistant.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-themes.sh
    sleep 0.2
    
    ((current++))
    show_progress_bar $current $total_files
    sed_inplace "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" README.md
    sleep 0.2
    
    echo
    echo -e "${GREEN}${CHECKMARK} Tüm dosyalar güncellendi!${NC}"
    return 0
}

# ============================================================================
# GIT İŞLEMLERİ (İYİLEŞTİRİLMİŞ)
# ============================================================================

git_operations() {
    local version=$1
    local auto_push=${2:-false}
    
    echo
    echo -e "${PACKAGE} ${CYAN}Git işlemleri...${NC}"
    echo
    
    # DÜZELTME: Git repo kontrolü
    if ! check_git_repo; then
        echo -e "${YELLOW}Git repository değil, git işlemleri atlanıyor${NC}"
        return 0
    fi
    
    echo -e "${DIM}Değişen dosyalar:${NC}"
    git status --short | while read line; do
        echo -e "  ${GREEN}•${NC} $line"
    done
    echo
    
    # DÜZELTME: Git add error handling
    echo -ne "${CYAN}⠋${NC} Staging yapılıyor..."
    if ! git add . > /dev/null 2>&1; then
        echo -e "\r${RED}✗${NC} Git add başarısız!        "
        return 1
    fi
    echo -e "\r${GREEN}✓${NC} Staged!              "
    
    # DÜZELTME: Git commit error handling
    echo -ne "${CYAN}⠋${NC} Commit yapılıyor..."
    if ! git commit -m "chore: Update all versions to v${version}

Auto-generated by Smart Version Manager

- Updated VERSION file
- Updated all shell scripts
- Updated README.md" > /dev/null 2>&1; then
        echo -e "\r${RED}✗${NC} Git commit başarısız!    "
        return 1
    fi
    echo -e "\r${GREEN}✓${NC} Commit yapıldı!      "
    
    if [[ "$auto_push" == "true" ]]; then
        # DÜZELTME: Remote kontrolü
        if ! check_git_remote; then
            echo -e "${YELLOW}Remote bulunamadı, push atlanıyor${NC}"
            return 0
        fi
        
        # DÜZELTME: Dinamik branch detection
        local current_branch
        current_branch=$(get_current_branch)
        
        echo -ne "${CYAN}⠋${NC} GitHub'a gönderiliyor ($current_branch)..."
        if ! git push origin "$current_branch" > /dev/null 2>&1; then
            echo -e "\r${RED}✗${NC} Git push başarısız!      "
            echo -e "${YELLOW}Manuel push yapabilirsiniz:${NC} git push origin $current_branch"
            return 1
        fi
        echo -e "\r${GREEN}✓${NC} GitHub'a gönderildi!    "
    fi
    
    return 0
}

# ============================================================================
# ANA PROGRAM
# ============================================================================

main() {
    # --help parametresi kontrolü
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_simple_help
        exit 0
    fi
    
    show_banner
    
    # Yardım teklifi
    echo -e "${BOOK} ${BOLD}İlk kez mi kullanıyorsunuz?${NC}"
    echo -ne "${DIM}Yardım menüsünü görmek ister misiniz? (e/h):${NC} "
    read -r -t 5 help_choice || help_choice="h"
    
    if [[ "$help_choice" =~ ^[eE]$ ]]; then
        show_simple_help
    fi
    
    echo
    echo -e "${ROBOT} ${BOLD}Merhaba! Ben akıllı versiyon asistanınızım.${NC}"
    echo
    sleep 0.5
    
    # Git kontrolü
    if ! check_git_repo; then
        echo -e "${YELLOW}⚠ ${NC} Git repository değil, sadece dosyaları güncelleyeceğim"
        echo
    fi
    
    # Working tree kontrolü
    if check_git_repo; then
        if ! check_working_tree; then
            echo -e "${RED}İptal edildi.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${MAGNIFY} ${CYAN}Sistem analiz ediliyor...${NC}"
    echo
    sleep 1
    
    local current_version=$(detect_current_version)
    
    if [[ -n "$current_version" ]]; then
        echo -e "${GREEN}${CHECKMARK} Mevcut versiyon: ${BOLD}v${current_version}${NC}"
    else
        echo -e "${YELLOW}⚠  Versiyon tespit edilemedi${NC}"
        current_version="0.0.0"
    fi
    echo
    sleep 0.5
    
    scan_version_files
    local scan_result=$?
    
    if [[ $scan_result -gt 0 ]]; then
        echo -e "${YELLOW}⚠  Bazı dosyalarda versiyon tutarsızlığı var!${NC}"
        echo
    fi
    
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}Hangi versiyonu kullanmak istersiniz?${NC}"
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    echo
    
    IFS='|' read -r patch_bump minor_bump major_bump <<< "$(suggest_next_version "$current_version")"
    
    echo -e "${GREEN}1)${NC} ${BOLD}Patch${NC} (hata düzeltmeleri)          → ${CYAN}v${patch_bump}${NC}"
    echo -e "${GREEN}2)${NC} ${BOLD}Minor${NC} (yeni özellikler)            → ${CYAN}v${minor_bump}${NC}"
    echo -e "${GREEN}3)${NC} ${BOLD}Major${NC} (büyük değişiklikler)        → ${CYAN}v${major_bump}${NC}"
    echo -e "${GREEN}4)${NC} ${BOLD}Özel${NC} versiyon                      → ${DIM}örn: 3.2.7${NC}"
    echo -e "${GREEN}5)${NC} ${BOLD}Mevcut${NC} (senkronize et)             → ${CYAN}v${current_version}${NC}"
    echo
    echo -e "${DIM}İpucu: Patch = küçük, Minor = orta, Major = büyük değişiklik${NC}"
    echo
    
    echo -ne "${BOLD}Seçiminiz (1-5):${NC} "
    read -r choice
    
    local target_version=""
    
    case $choice in
        1)
            target_version="$patch_bump"
            echo -e "${GREEN}${CHECKMARK} Patch bump: v${target_version}${NC}"
            ;;
        2)
            target_version="$minor_bump"
            echo -e "${GREEN}${CHECKMARK} Minor bump: v${target_version}${NC}"
            ;;
        3)
            target_version="$major_bump"
            echo -e "${GREEN}${CHECKMARK} Major bump: v${target_version}${NC}"
            ;;
        4)
            echo -ne "${BOLD}Versiyon numarası:${NC} "
            read -r custom_version
            target_version="$custom_version"
            
            # Validation
            if ! validate_version "$target_version"; then
                echo -e "${RED}İptal edildi.${NC}"
                exit 1
            fi
            echo -e "${GREEN}${CHECKMARK} Özel versiyon: v${target_version}${NC}"
            ;;
        5)
            target_version="$current_version"
            echo -e "${GREEN}${CHECKMARK} Mevcut versiyon: v${target_version}${NC}"
            ;;
        *)
            echo -e "${RED}✗ Geçersiz seçim!${NC}"
            exit 1
            ;;
    esac
    
    echo
    sleep 0.5
    
    echo -e "${YELLOW}────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}TÜM DOSYALAR v${target_version} OLARAK GÜNCELLENECEK${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────${NC}"
    echo
    echo -ne "${BOLD}Devam? (e/h):${NC} "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[eE]$ ]]; then
        echo -e "${YELLOW}İptal edildi.${NC}"
        exit 0
    fi
    
    echo
    echo -e "${SPARKLES} ${CYAN}Başlıyoruz...${NC}"
    echo
    sleep 0.5
    
    if ! update_versions "$target_version"; then
        echo -e "${RED}Versiyon güncelleme başarısız!${NC}"
        exit 1
    fi
    
    echo
    sleep 0.5
    
    # Git işlemleri (sadece git repo ise)
    if check_git_repo; then
        echo -ne "${BOLD}Git commit ve push yapılsın mı? (e/h):${NC} "
        read -r git_choice
        
        if [[ "$git_choice" =~ ^[eE]$ ]]; then
            echo -ne "${BOLD}Otomatik push? (e/h):${NC} "
            read -r push_choice
            
            if [[ "$push_choice" =~ ^[eE]$ ]]; then
                git_operations "$target_version" true
            else
                git_operations "$target_version" false
                echo
                local current_branch=$(get_current_branch)
                echo -e "${YELLOW}ℹ Push manuel yapılacak:${NC} ${DIM}git push origin $current_branch${NC}"
            fi
        fi
    fi
    
    echo
    echo -e "${GREEN}────────────────────────────────────────────────${NC}"
    echo -e "${ROCKET} ${BOLD}${GREEN}TAMAMLANDI!${NC}"
    echo -e "${GREEN}────────────────────────────────────────────────${NC}"
    echo
    echo -e "${BOLD}Yeni versiyon:${NC} ${CYAN}v${target_version}${NC}"
    echo
    echo -e "${DIM}Sonraki adımlar:${NC}"
    if check_git_repo && check_git_remote &>/dev/null; then
        echo -e "  ${GREEN}•${NC} git tag v${target_version}"
        echo -e "  ${GREEN}•${NC} git push origin v${target_version}"
    else
        echo -e "  ${GREEN}•${NC} Dosyalar güncellendi!"
        echo -e "  ${GREEN}•${NC} Manuel git işlemlerini yapabilirsiniz"
    fi
    echo
}

main "$@"