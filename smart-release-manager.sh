#!/bin/bash

# ============================================================================
# Smart Release Manager - Interactive Release Update Tool
# v1.0.0 - AI Assistant Mode
# ============================================================================
# GitHub release'lerini akıllıca günceller
# Token yönetimi, interaktif menü, güzel UI!
# ============================================================================

set -euo pipefail

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Emojiler
ROBOT="🤖"
ROCKET="🚀"
SPARKLES="✨"
KEY="🔑"
MAGNIFY="🔍"
WRENCH="🔧"
CHECKMARK="✓"
CROSSMARK="✗"
WARNING="⚠"
INFO="ℹ"

# Config
REPO="alibedirhan/Theme-after-format"

# ============================================================================
# BANNER
# ============================================================================

show_banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════╗
    ║                                                          ║
    ║    ██████╗ ███████╗██╗     ███████╗ █████╗ ███████╗     ║
    ║    ██╔══██╗██╔════╝██║     ██╔════╝██╔══██╗██╔════╝     ║
    ║    ██████╔╝█████╗  ██║     █████╗  ███████║███████╗     ║
    ║    ██╔══██╗██╔══╝  ██║     ██╔══╝  ██╔══██║╚════██║     ║
    ║    ██║  ██║███████╗███████╗███████╗██║  ██║███████║     ║
    ║    ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝     ║
    ║                                                          ║
    ║           Smart Release Manager v1.0.0                   ║
    ║              AI-Powered Assistant                        ║
    ║                                                          ║
    ╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 0.5
}

# ============================================================================
# GITHUB CLI KONTROL VE KURULUM
# ============================================================================

check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}${WARNING} GitHub CLI (gh) kurulu değil!${NC}"
        echo
        echo -e "${CYAN}GitHub CLI, release'leri yönetmek için gerekli.${NC}"
        echo
        echo -e "${BOLD}Kurulum seçenekleri:${NC}"
        echo -e "  ${GREEN}1)${NC} Otomatik kur (önerilen)"
        echo -e "  ${GREEN}2)${NC} Manuel kurulum talimatları"
        echo -e "  ${GREEN}3)${NC} İptal"
        echo
        echo -ne "${BOLD}Seçiminiz (1-3):${NC} "
        read -r install_choice
        
        case $install_choice in
            1)
                echo
                echo -e "${CYAN}GitHub CLI kuruluyor...${NC}"
                
                if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    sudo apt update > /dev/null 2>&1
                    sudo apt install -y gh > /dev/null 2>&1
                    echo -e "${GREEN}${CHECKMARK} Kurulum başarılı!${NC}"
                elif [[ "$OSTYPE" == "darwin"* ]]; then
                    brew install gh > /dev/null 2>&1
                    echo -e "${GREEN}${CHECKMARK} Kurulum başarılı!${NC}"
                else
                    echo -e "${RED}${CROSSMARK} Otomatik kurulum desteklenmiyor${NC}"
                    echo -e "${CYAN}Manuel kurulum: https://cli.github.com/${NC}"
                    exit 1
                fi
                ;;
            2)
                echo
                echo -e "${CYAN}Manuel Kurulum:${NC}"
                echo
                echo -e "  ${BOLD}Ubuntu/Debian:${NC}"
                echo -e "    ${DIM}sudo apt update${NC}"
                echo -e "    ${DIM}sudo apt install gh${NC}"
                echo
                echo -e "  ${BOLD}macOS:${NC}"
                echo -e "    ${DIM}brew install gh${NC}"
                echo
                echo -e "  ${BOLD}Diğer:${NC}"
                echo -e "    ${DIM}https://cli.github.com/${NC}"
                echo
                exit 0
                ;;
            3)
                echo -e "${YELLOW}İptal edildi.${NC}"
                exit 0
                ;;
        esac
    else
        echo -e "${GREEN}${CHECKMARK} GitHub CLI kurulu${NC}"
    fi
}

# ============================================================================
# AUTHENTİCATİON KONTROL
# ============================================================================

check_authentication() {
    echo -ne "${CYAN}${MAGNIFY}${NC} Authentication kontrol ediliyor... "
    
    if gh auth status &> /dev/null; then
        echo -e "${GREEN}${CHECKMARK}${NC}"
        
        # Kullanıcı bilgisi
        local username=$(gh api user --jq .login 2>/dev/null)
        echo -e "${DIM}  Giriş yapılan kullanıcı: ${BOLD}${username}${NC}"
        return 0
    else
        echo -e "${YELLOW}${WARNING}${NC}"
        echo
        echo -e "${YELLOW}GitHub'a giriş yapmanız gerekiyor.${NC}"
        echo
        echo -e "${CYAN}GitHub CLI iki şekilde giriş yapmanızı sağlar:${NC}"
        echo -e "  ${GREEN}•${NC} Browser üzerinden (kolay, güvenli)"
        echo -e "  ${GREEN}•${NC} Token ile (gelişmiş kullanıcılar)"
        echo
        echo -ne "${BOLD}Giriş yapmak ister misiniz? (e/h):${NC} "
        read -r login_choice
        
        if [[ "$login_choice" =~ ^[eE]$ ]]; then
            echo
            echo -e "${CYAN}Giriş başlatılıyor...${NC}"
            echo -e "${DIM}(Browser açılacak, orada GitHub'a giriş yapın)${NC}"
            echo
            
            if gh auth login; then
                echo
                echo -e "${GREEN}${CHECKMARK} Giriş başarılı!${NC}"
                return 0
            else
                echo -e "${RED}${CROSSMARK} Giriş başarısız${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Giriş yapılmadan devam edilemez.${NC}"
            return 1
        fi
    fi
}

# ============================================================================
# TOKEN YÖNETİMİ
# ============================================================================

manage_token() {
    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${KEY} ${BOLD}TOKEN YÖNETİMİ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    
    # Mevcut durumu göster
    if gh auth status &> /dev/null; then
        local username=$(gh api user --jq .login 2>/dev/null)
        echo -e "${GREEN}${CHECKMARK} Aktif oturum: ${BOLD}${username}${NC}"
    else
        echo -e "${YELLOW}${WARNING} Aktif oturum yok${NC}"
    fi
    
    echo
    echo -e "${BOLD}Ne yapmak istersiniz?${NC}"
    echo
    echo -e "  ${GREEN}1)${NC} Token'ı yenile (logout + login)"
    echo -e "  ${GREEN}2)${NC} Farklı hesap ile giriş yap"
    echo -e "  ${GREEN}3)${NC} Token durumunu göster"
    echo -e "  ${GREEN}4)${NC} Logout yap"
    echo -e "  ${GREEN}5)${NC} Geri dön"
    echo
    echo -ne "${BOLD}Seçiminiz (1-5):${NC} "
    read -r token_choice
    
    case $token_choice in
        1)
            echo
            echo -e "${CYAN}Token yenileniyor...${NC}"
            gh auth logout > /dev/null 2>&1
            echo -e "${YELLOW}${INFO} Logout yapıldı${NC}"
            echo
            echo -e "${CYAN}Yeni token ile giriş yapılıyor...${NC}"
            if gh auth login; then
                echo -e "${GREEN}${CHECKMARK} Token yenilendi!${NC}"
            fi
            ;;
        2)
            echo
            echo -e "${CYAN}Farklı hesap ile giriş...${NC}"
            gh auth logout > /dev/null 2>&1
            if gh auth login; then
                local new_user=$(gh api user --jq .login 2>/dev/null)
                echo -e "${GREEN}${CHECKMARK} Giriş yapıldı: ${BOLD}${new_user}${NC}"
            fi
            ;;
        3)
            echo
            gh auth status
            ;;
        4)
            echo
            echo -ne "${YELLOW}Logout yapmak istediğinizden emin misiniz? (e/h):${NC} "
            read -r logout_confirm
            if [[ "$logout_confirm" =~ ^[eE]$ ]]; then
                gh auth logout
                echo -e "${GREEN}${CHECKMARK} Logout yapıldı${NC}"
            fi
            ;;
        5)
            return 0
            ;;
    esac
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# ============================================================================
# RELEASE LİSTELE
# ============================================================================

list_releases() {
    echo
    echo -e "${CYAN}${MAGNIFY} Release'ler listeleniyor...${NC}"
    echo
    
    local releases=$(gh release list --repo "$REPO" --limit 10 2>/dev/null)
    
    if [[ -z "$releases" ]]; then
        echo -e "${YELLOW}${WARNING} Release bulunamadı${NC}"
        return 1
    fi
    
    echo -e "${DIM}┌─────────────┬──────────────────────────────┬────────────┐${NC}"
    echo -e "${DIM}│   Version   │            Title             │   Status   │${NC}"
    echo -e "${DIM}├─────────────┼──────────────────────────────┼────────────┤${NC}"
    
    echo "$releases" | while IFS=$'\t' read -r tag title status _; do
        local status_color="${GREEN}"
        [[ "$status" == "Draft" ]] && status_color="${YELLOW}"
        [[ "$status" == "Pre-release" ]] && status_color="${CYAN}"
        
        printf "${DIM}│${NC} %-11s ${DIM}│${NC} %-28s ${DIM}│${NC} ${status_color}%-10s${NC} ${DIM}│${NC}\n" \
            "$tag" "${title:0:28}" "$status"
    done
    
    echo -e "${DIM}└─────────────┴──────────────────────────────┴────────────┘${NC}"
    echo
    
    return 0
}

# ============================================================================
# RELEASE GÜNCELLE
# ============================================================================

update_release() {
    local version=$1
    
    echo
    echo -e "${WRENCH} ${CYAN}Release güncelleniyor: ${BOLD}${version}${NC}"
    echo
    
    # Release notes hazırla
    cat > /tmp/release-notes.md << 'EOF'
# 🎉 Theme After Format

Terminal özelleştirme suite'inin yeni sürümü!

## ✨ Özellikler

- 🎨 7 farklı tema desteği
- 🔧 Otomatik teşhis sistemi
- 📦 Modern terminal araçları
- 🖥️ Tmux tema desteği
- ⚙️ Modüler yapı

## 📥 Kurulum

```bash
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh
chmod +x install.sh
./install.sh
```

## 📚 Dokümantasyon

- [README](https://github.com/alibedirhan/Theme-after-format#readme)
- [CHANGELOG](https://github.com/alibedirhan/Theme-after-format/blob/main/CHANGELOG.md)

**Made with ❤️ by Ali Bedirhan**
EOF
    
    # Güncelle
    if gh release edit "$version" \
        --repo "$REPO" \
        --title "Release ${version} - Terminal Customization Suite" \
        --notes-file /tmp/release-notes.md 2>/dev/null; then
        
        echo -e "${GREEN}${CHECKMARK} Release başarıyla güncellendi!${NC}"
        echo
        echo -e "${CYAN}Kontrol edin:${NC}"
        echo -e "  ${DIM}https://github.com/${REPO}/releases/tag/${version}${NC}"
        
        rm -f /tmp/release-notes.md
        return 0
    else
        echo -e "${RED}${CROSSMARK} Güncelleme başarısız${NC}"
        rm -f /tmp/release-notes.md
        return 1
    fi
}

# ============================================================================
# ANA MENÜ
# ============================================================================

main_menu() {
    while true; do
        clear
        show_banner
        
        echo -e "${ROBOT} ${BOLD}Merhaba! Release yönetim asistanınızım.${NC}"
        echo
        
        # Quick status
        if gh auth status &> /dev/null; then
            local username=$(gh api user --jq .login 2>/dev/null)
            echo -e "${GREEN}${CHECKMARK} Giriş yapıldı: ${BOLD}${username}${NC}"
        else
            echo -e "${YELLOW}${WARNING} Giriş yapılmadı${NC}"
        fi
        echo
        
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}ANA MENÜ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        echo -e "  ${GREEN}1)${NC} ${BOLD}Release'leri listele${NC}"
        echo -e "  ${GREEN}2)${NC} ${BOLD}Release güncelle${NC}"
        echo -e "  ${GREEN}3)${NC} ${BOLD}Token yönetimi${NC} ${DIM}(token değiştir/yenile)${NC}"
        echo -e "  ${GREEN}4)${NC} ${BOLD}GitHub'a giriş/çıkış${NC}"
        echo -e "  ${GREEN}5)${NC} ${BOLD}Yardım${NC}"
        echo -e "  ${GREEN}0)${NC} Çıkış"
        echo
        echo -ne "${BOLD}Seçiminiz (0-5):${NC} "
        read -r menu_choice
        
        case $menu_choice in
            1)
                list_releases
                read -p "Devam etmek için Enter'a basın..."
                ;;
            2)
                echo
                list_releases
                echo -ne "${BOLD}Güncellenecek versiyon (örn: v3.2.5):${NC} "
                read -r version
                
                if [[ -n "$version" ]]; then
                    update_release "$version"
                fi
                
                read -p "Devam etmek için Enter'a basın..."
                ;;
            3)
                manage_token
                ;;
            4)
                check_authentication
                read -p "Devam etmek için Enter'a basın..."
                ;;
            5)
                show_help
                read -p "Devam etmek için Enter'a basın..."
                ;;
            0)
                echo
                echo -e "${CYAN}Hoşça kalın! ${SPARKLES}${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}${CROSSMARK} Geçersiz seçim${NC}"
                sleep 1
                ;;
        esac
    done
}

show_help() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}YARDIM${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BOLD}Smart Release Manager Nedir?${NC}"
    echo -e "GitHub release'lerini interaktif bir şekilde yönetmenizi sağlar."
    echo
    echo -e "${BOLD}Token Nasıl Değiştirilir?${NC}"
    echo -e "  1. Ana menüden '3) Token yönetimi' seçin"
    echo -e "  2. '1) Token'ı yenile' seçin"
    echo -e "  3. Browser'da yeni token ile giriş yapın"
    echo
    echo -e "${BOLD}Güvenli mi?${NC}"
    echo -e "  ${GREEN}${CHECKMARK}${NC} Token şifreli tutuluyor"
    echo -e "  ${GREEN}${CHECKMARK}${NC} GitHub CLI resmi araç"
    echo -e "  ${GREEN}${CHECKMARK}${NC} Açık kaynak"
    echo
    echo -e "${BOLD}Daha Fazla Bilgi:${NC}"
    echo -e "  GitHub CLI: https://cli.github.com"
    echo -e "  Repository: https://github.com/${REPO}"
    echo
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    show_banner
    
    echo -e "${ROBOT} ${BOLD}Hoş geldiniz!${NC}"
    echo
    sleep 0.5
    
    # GitHub CLI kontrol
    check_gh_cli
    echo
    sleep 0.5
    
    # Authentication kontrol
    if ! check_authentication; then
        exit 1
    fi
    
    echo
    sleep 0.5
    
    # Ana menüye geç
    main_menu
}

# Run
main "$@"