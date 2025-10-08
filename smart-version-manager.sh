#!/bin/bash

# ============================================================================
# Smart Version Manager - Interactive Version Sync Tool
# v1.0.0 - Intelligent Assistant Mode
# ============================================================================
# Tüm dosyalardaki versiyonları otomatik senkronize eder
# Interaktif, akıllı, ve kullanıcı dostu!
# ============================================================================

set -euo pipefail

# Renkler - Daha zengin palet
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'
NC='\033[0m'

# Animasyon karakterleri
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
CHECKMARK="✓"
CROSSMARK="✗"
ROCKET="🚀"
SPARKLES="✨"
ROBOT="🤖"
MAGNIFY="🔍"
WRENCH="🔧"
PACKAGE="📦"

# ============================================================================
# ANIMASYON FONKSİYONLARI
# ============================================================================

show_spinner() {
    local pid=$1
    local message=$2
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}${SPINNER[$i]}${NC} ${message}"
        i=$(( (i + 1) % ${#SPINNER[@]} ))
        sleep 0.1
    done
    printf "\r${GREEN}${CHECKMARK}${NC} ${message}\n"
}

type_text() {
    local text=$1
    local delay=${2:-0.03}
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════╗
    ║                                                          ║
    ║     ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗        ║
    ║     ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝        ║
    ║     ███████╗██╔████╔██║███████║██████╔╝   ██║           ║
    ║     ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║           ║
    ║     ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║           ║
    ║     ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝           ║
    ║                                                          ║
    ║            Version Manager - AI Assistant                ║
    ║                  v1.0.0 | 2024                           ║
    ║                                                          ║
    ╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.5
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
# VERSİYON TESPİTİ
# ============================================================================

detect_current_version() {
    local version=""
    
    # VERSION dosyasından oku
    if [[ -f VERSION ]]; then
        version=$(cat VERSION 2>/dev/null || echo "")
    fi
    
    # Yoksa terminal-setup.sh'ten al
    if [[ -z "$version" ]] && [[ -f terminal-setup.sh ]]; then
        version=$(grep '^VERSION=' terminal-setup.sh 2>/dev/null | cut -d'"' -f2 || echo "")
    fi
    
    # Yoksa git tag'den al
    if [[ -z "$version" ]]; then
        version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")
    fi
    
    echo "$version"
}

# ============================================================================
# AKILLI VERSİYON ÖNERİSİ
# ============================================================================

suggest_next_version() {
    local current=$1
    
    if [[ -z "$current" ]]; then
        echo "1.0.0"
        return
    fi
    
    # Semantic versioning parse et
    IFS='.' read -r major minor patch <<< "$current"
    
    # Önerileri hesapla
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
    declare -A versions
    
    for file_cmd in "${files[@]}"; do
        local file="${file_cmd%%:*}"
        local cmd="${file_cmd##*:}"
        
        if [[ -f "$file" ]]; then
            local ver=$(eval "$cmd" 2>/dev/null || echo "N/A")
            versions["$file"]="$ver"
            
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
# VERSİYON GÜNCELLEME
# ============================================================================

update_versions() {
    local target_version=$1
    local total_files=9
    local current=0
    
    echo -e "${WRENCH} ${CYAN}Versiyonlar güncelleniyor...${NC}"
    echo
    
    # VERSION dosyası
    ((current++))
    show_progress_bar $current $total_files
    echo "$target_version" > VERSION
    sleep 0.2
    
    # install.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" install.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-setup.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/^VERSION=\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/VERSION=\"${target_version}\"/g" terminal-setup.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-ui.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-ui.sh 2>/dev/null || true
    sed -i "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version ${target_version}/g" terminal-ui.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-core.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-core.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-utils.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-utils.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-assistant.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-assistant.sh 2>/dev/null || true
    sleep 0.2
    
    # terminal-themes.sh
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" terminal-themes.sh 2>/dev/null || true
    sleep 0.2
    
    # README.md
    ((current++))
    show_progress_bar $current $total_files
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${target_version}/g" README.md 2>/dev/null || true
    sleep 0.2
    
    echo
    echo -e "${GREEN}${CHECKMARK} Tüm dosyalar güncellendi!${NC}"
}

# ============================================================================
# GIT İŞLEMLERİ
# ============================================================================

git_operations() {
    local version=$1
    local auto_push=${2:-false}
    
    echo
    echo -e "${PACKAGE} ${CYAN}Git işlemleri...${NC}"
    echo
    
    # Değişiklikleri göster
    echo -e "${DIM}Değişen dosyalar:${NC}"
    git status --short | while read line; do
        echo -e "  ${GREEN}•${NC} $line"
    done
    echo
    
    # Commit
    echo -ne "${CYAN}${SPINNER[0]}${NC} Commit yapılıyor..."
    git add . > /dev/null 2>&1
    git commit -m "chore: Update all versions to v${version}

- Sync VERSION file with v${version}
- Update all script versions
- Update documentation references

Auto-generated by Smart Version Manager" > /dev/null 2>&1
    echo -e "\r${GREEN}${CHECKMARK}${NC} Commit yapıldı!        "
    
    # Push
    if [[ "$auto_push" == "true" ]]; then
        echo -ne "${CYAN}${SPINNER[0]}${NC} GitHub'a gönderiliyor..."
        git push origin main > /dev/null 2>&1
        echo -e "\r${GREEN}${CHECKMARK}${NC} GitHub'a gönderildi!    "
    fi
}

# ============================================================================
# ANA MENÜ
# ============================================================================

main() {
    show_banner
    
    # Hoş geldin mesajı
    echo -e "${ROBOT} ${BOLD}Merhaba! Ben akıllı versiyon asistanınızım.${NC}"
    echo
    sleep 0.5
    
    # Mevcut durum analizi
    echo -e "${MAGNIFY} ${CYAN}Sistem analiz ediliyor...${NC}"
    echo
    sleep 1
    
    local current_version=$(detect_current_version)
    
    if [[ -n "$current_version" ]]; then
        echo -e "${GREEN}${CHECKMARK} Mevcut versiyon tespit edildi: ${BOLD}v${current_version}${NC}"
    else
        echo -e "${YELLOW}⚠ Versiyon tespit edilemedi (yeni proje?)${NC}"
        current_version="0.0.0"
    fi
    echo
    sleep 0.5
    
    # Dosyaları tara
    scan_version_files
    local scan_result=$?
    
    if [[ $scan_result -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Bazı dosyalarda versiyon tutarsızlığı var!${NC}"
        echo
    fi
    
    # Versiyon seçimi
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Hangi versiyonu kullanmak istersiniz?${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    
    # Akıllı öneriler
    IFS='|' read -r patch_bump minor_bump major_bump <<< "$(suggest_next_version "$current_version")"
    
    echo -e "${GREEN}1)${NC} ${BOLD}Patch${NC} bump (hata düzeltmeleri)      → ${CYAN}v${patch_bump}${NC}"
    echo -e "${GREEN}2)${NC} ${BOLD}Minor${NC} bump (yeni özellikler)        → ${CYAN}v${minor_bump}${NC}"
    echo -e "${GREEN}3)${NC} ${BOLD}Major${NC} bump (büyük değişiklikler)    → ${CYAN}v${major_bump}${NC}"
    echo -e "${GREEN}4)${NC} ${BOLD}Özel${NC} versiyon (manuel giriş)        → ${DIM}örn: 3.2.7${NC}"
    echo -e "${GREEN}5)${NC} ${BOLD}Mevcut${NC} versiyon (senkronize et)     → ${CYAN}v${current_version}${NC}"
    echo
    echo -e "${DIM}Semantic Versioning: MAJOR.MINOR.PATCH${NC}"
    echo
    
    echo -ne "${BOLD}Seçiminiz (1-5):${NC} "
    read -r choice
    
    local target_version=""
    
    case $choice in
        1)
            target_version="$patch_bump"
            echo -e "${GREEN}${CHECKMARK} Patch bump seçildi: v${target_version}${NC}"
            ;;
        2)
            target_version="$minor_bump"
            echo -e "${GREEN}${CHECKMARK} Minor bump seçildi: v${target_version}${NC}"
            ;;
        3)
            target_version="$major_bump"
            echo -e "${GREEN}${CHECKMARK} Major bump seçildi: v${target_version}${NC}"
            ;;
        4)
            echo -ne "${BOLD}Versiyon numarası (örn: 3.2.7):${NC} "
            read -r custom_version
            target_version="$custom_version"
            echo -e "${GREEN}${CHECKMARK} Özel versiyon: v${target_version}${NC}"
            ;;
        5)
            target_version="$current_version"
            echo -e "${GREEN}${CHECKMARK} Mevcut versiyon senkronize edilecek: v${target_version}${NC}"
            ;;
        *)
            echo -e "${RED}${CROSSMARK} Geçersiz seçim!${NC}"
            exit 1
            ;;
    esac
    
    echo
    sleep 0.5
    
    # Onay
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}TÜM DOSYALAR v${target_version} OLARAK GÜNCELLENECEK${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -ne "${BOLD}Devam etmek istiyor musunuz? (e/h):${NC} "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[eE]$ ]]; then
        echo -e "${YELLOW}İptal edildi.${NC}"
        exit 0
    fi
    
    echo
    echo -e "${SPARKLES} ${CYAN}Harika! Başlıyoruz...${NC}"
    echo
    sleep 0.5
    
    # Versiyonları güncelle
    update_versions "$target_version"
    
    echo
    sleep 0.5
    
    # Git işlemleri
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
            echo -e "${YELLOW}ℹ Push manuel yapılacak:${NC} ${DIM}git push origin main${NC}"
        fi
    else
        echo
        echo -e "${YELLOW}ℹ Git işlemleri manuel yapılacak:${NC}"
        echo -e "  ${DIM}git add .${NC}"
        echo -e "  ${DIM}git commit -m \"chore: Update to v${target_version}\"${NC}"
        echo -e "  ${DIM}git push origin main${NC}"
    fi
    
    # Final
    echo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${ROCKET} ${BOLD}${GREEN}BAŞARIYLA TAMAMLANDI!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BOLD}Yeni versiyon:${NC} ${CYAN}v${target_version}${NC}"
    echo
    echo -e "${DIM}Sonraki adımlar:${NC}"
    echo -e "  ${GREEN}•${NC} Tag oluşturun: ${DIM}git tag v${target_version}${NC}"
    echo -e "  ${GREEN}•${NC} Tag push: ${DIM}git push origin v${target_version}${NC}"
    echo -e "  ${GREEN}•${NC} GitHub'da release otomatik oluşacak! 🎉${NC}"
    echo
}

# Run
main "$@"