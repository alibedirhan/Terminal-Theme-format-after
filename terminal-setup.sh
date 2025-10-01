#!/bin/bash

# Terminal Özelleştirme Kurulum/Kaldırma Scripti
# Zsh + Oh My Zsh + Powerlevel10k + Dracula/Nord Teması
# v2.0 - Hata düzeltmeleri ve Nord teması eklendi

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Yedek dizini
BACKUP_DIR="$HOME/.terminal-setup-backup"
TEMP_DIR="/tmp/terminal-setup-$$"

# Temizlik fonksiyonu
cleanup() {
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║         TERMİNAL ÖZELLEŞTİRME KURULUM ARACI             ║"
    echo "║                                                          ║"
    echo "║  • Zsh + Oh My Zsh                                      ║"
    echo "║  • Powerlevel10k Teması                                 ║"
    echo "║  • Dracula / Nord Renk Teması                           ║"
    echo "║  • Syntax Highlighting & Auto-suggestions               ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Ana menü
show_menu() {
    echo -e "${YELLOW}Ne yapmak istersiniz?${NC}"
    echo
    echo "1) Tam Kurulum (Dracula teması)"
    echo "2) Tam Kurulum (Nord teması)"
    echo "3) Sadece Zsh + Oh My Zsh"
    echo "4) Sadece Powerlevel10k Teması"
    echo "5) Sadece Dracula Renk Teması"
    echo "6) Sadece Nord Renk Teması"
    echo "7) Sadece Pluginler"
    echo "8) Tümünü Kaldır (Yedekten Geri Yükle)"
    echo "9) Yedekleri Göster"
    echo "0) Çıkış"
    echo
    echo -n "Seçiminiz (0-9): "
}

# İnternet kontrolü
check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${RED}✗ İnternet bağlantısı yok!${NC}"
        echo "Kurulum için internet gerekli."
        return 1
    fi
    return 0
}

# GNOME Terminal kontrolü
check_gnome_terminal() {
    if ! command -v gsettings &> /dev/null; then
        echo -e "${YELLOW}⚠ GNOME Terminal bulunamadı${NC}"
        echo "Renk teması sadece GNOME Terminal'de çalışır"
        return 1
    fi
    return 0
}

# Yedekleme
create_backup() {
    echo -e "${CYAN}Mevcut ayarlar yedekleniyor...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    # Dosya yedekleri
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$BACKUP_DIR/bashrc_$TIMESTAMP"
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$BACKUP_DIR/zshrc_$TIMESTAMP"
    [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$BACKUP_DIR/p10k_$TIMESTAMP"
    
    # Mevcut shell'i kaydet
    echo "$SHELL" > "$BACKUP_DIR/original_shell_$TIMESTAMP"
    
    # GNOME Terminal profil ID'sini kaydet
    if command -v gsettings &> /dev/null; then
        gsettings get org.gnome.Terminal.ProfilesList default > "$BACKUP_DIR/gnome_profile_$TIMESTAMP" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Yedek oluşturuldu: $BACKUP_DIR${NC}"
}

# Zsh kurulumu
install_zsh() {
    echo -e "${CYAN}Zsh kuruluyor...${NC}"
    
    if command -v zsh &> /dev/null; then
        echo -e "${YELLOW}Zsh zaten kurulu, atlanıyor...${NC}"
        return 0
    fi
    
    sudo apt update || {
        echo -e "${RED}✗ apt update başarısız!${NC}"
        return 1
    }
    
    sudo apt install -y zsh || {
        echo -e "${RED}✗ Zsh kurulumu başarısız!${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Zsh kuruldu${NC}"
}

# Oh My Zsh kurulumu
install_oh_my_zsh() {
    echo -e "${CYAN}Oh My Zsh kuruluyor...${NC}"
    
    if [[ -d ~/.oh-my-zsh ]]; then
        echo -e "${YELLOW}Oh My Zsh zaten kurulu, atlanıyor...${NC}"
        return 0
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    # Oh My Zsh'yi sessiz modda kur
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        echo -e "${RED}✗ Oh My Zsh kurulumu başarısız!${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Oh My Zsh kuruldu${NC}"
}

# Font kurulumu
install_fonts() {
    echo -e "${CYAN}Gerekli fontlar kuruluyor...${NC}"
    
    sudo apt install -y fonts-powerline || {
        echo -e "${YELLOW}⚠ Powerline font kurulumu başarısız, devam ediliyor...${NC}"
    }
    
    # MesloLGS NF fontunu kur
    mkdir -p ~/.local/share/fonts
    local FONT_DIR=~/.local/share/fonts
    
    if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
        echo "MesloLGS NF fontları indiriliyor..."
        
        cd "$FONT_DIR" || return 1
        
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf 2>/dev/null || true
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf 2>/dev/null || true
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf 2>/dev/null || true
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf 2>/dev/null || true
        
        cd - > /dev/null
        
        fc-cache -f -v > /dev/null 2>&1
        echo -e "${GREEN}✓ Fontlar kuruldu${NC}"
    else
        echo -e "${YELLOW}Fontlar zaten kurulu, atlanıyor...${NC}"
    fi
}

# Powerlevel10k kurulumu
install_powerlevel10k() {
    echo -e "${CYAN}Powerlevel10k teması kuruluyor...${NC}"
    
    if ! check_internet; then
        return 1
    fi
    
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$P10K_DIR" ]]; then
        echo -e "${YELLOW}Powerlevel10k zaten kurulu, güncelleniyor...${NC}"
        cd "$P10K_DIR" && git pull > /dev/null 2>&1
        cd - > /dev/null
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" || {
            echo -e "${RED}✗ Powerlevel10k klonlama başarısız!${NC}"
            return 1
        }
    fi
    
    # .zshrc'de temayı ayarla
    if [[ -f ~/.zshrc ]]; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    fi
    
    echo -e "${GREEN}✓ Powerlevel10k kuruldu${NC}"
}

# Pluginler
install_plugins() {
    echo -e "${CYAN}Pluginler kuruluyor...${NC}"
    
    if ! check_internet; then
        return 1
    fi
    
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ ! -d "$CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions" || {
            echo -e "${YELLOW}⚠ zsh-autosuggestions kurulumu başarısız${NC}"
        }
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting" || {
            echo -e "${YELLOW}⚠ zsh-syntax-highlighting kurulumu başarısız${NC}"
        }
    fi
    
    # .zshrc'de pluginleri aktif et
    if [[ -f ~/.zshrc ]]; then
        if grep -q "^plugins=(" ~/.zshrc; then
            sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)/' ~/.zshrc
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)' >> ~/.zshrc
        fi
    fi
    
    echo -e "${GREEN}✓ Pluginler kuruldu${NC}"
}

# Dracula renk teması
install_dracula() {
    echo -e "${CYAN}Dracula renk teması kuruluyor...${NC}"
    
    if ! check_gnome_terminal; then
        return 1
    fi
    
    # Profil UUID'sini al
    local PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
    
    if [[ -z "$PROFILE" ]]; then
        echo -e "${RED}✗ Terminal profili bulunamadı${NC}"
        return 1
    fi
    
    local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
    
    # Dracula renklerini uygula
    gsettings set "$PROFILE_PATH" background-color '#282A36' 2>/dev/null || return 1
    gsettings set "$PROFILE_PATH" foreground-color '#F8F8F2' 2>/dev/null || return 1
    gsettings set "$PROFILE_PATH" use-theme-colors false 2>/dev/null || return 1
    gsettings set "$PROFILE_PATH" palette "['#000000', '#FF5555', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF79C6', '#8BE9FD', '#BFBFBF', '#4D4D4D', '#FF6E67', '#5AF78E', '#F4F99D', '#CAA9FA', '#FF92D0', '#9AEDFE', '#E6E6E6']" 2>/dev/null || return 1
    
    echo -e "${GREEN}✓ Dracula teması uygulandı${NC}"
}

# Nord renk teması
install_nord() {
    echo -e "${CYAN}Nord renk teması kuruluyor...${NC}"
    
    if ! check_gnome_terminal; then
        return 1
    fi
    
    if ! check_internet; then
        return 1
    fi
    
    # Geçici dizin oluştur
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR" || return 1
    
    # Nord reposunu klonla
    git clone https://github.com/arcticicestudio/nord-gnome-terminal.git > /dev/null 2>&1 || {
        echo -e "${RED}✗ Nord repository klonlama başarısız!${NC}"
        cd - > /dev/null
        return 1
    }
    
    cd nord-gnome-terminal/src || {
        echo -e "${RED}✗ Nord dizinine girilemedi!${NC}"
        cd - > /dev/null
        return 1
    }
    
    # Nord'u kur (otomatik mod)
    echo -e "\n\n" | ./nord.sh > /dev/null 2>&1 || {
        echo -e "${YELLOW}⚠ Nord kurulumu tamamlanamadı, manuel renk ayarları uygulanıyor...${NC}"
        
        # Manuel Nord renkleri
        local PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        if [[ -n "$PROFILE" ]]; then
            local PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
            gsettings set "$PROFILE_PATH" background-color '#2E3440' 2>/dev/null
            gsettings set "$PROFILE_PATH" foreground-color '#D8DEE9' 2>/dev/null
            gsettings set "$PROFILE_PATH" use-theme-colors false 2>/dev/null
            gsettings set "$PROFILE_PATH" palette "['#3B4252', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#E5E9F0', '#4C566A', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#8FBCBB', '#ECEFF4']" 2>/dev/null
        fi
    }
    
    cd - > /dev/null
    
    echo -e "${GREEN}✓ Nord teması uygulandı${NC}"
}

# Varsayılan shell'i değiştir
change_default_shell() {
    echo -e "${CYAN}Varsayılan shell Zsh olarak ayarlanıyor...${NC}"
    
    local ZSH_PATH=$(which zsh)
    
    if [[ -z "$ZSH_PATH" ]]; then
        echo -e "${RED}✗ Zsh bulunamadı!${NC}"
        return 1
    fi
    
    if [[ "$SHELL" == "$ZSH_PATH" ]]; then
        echo -e "${YELLOW}Zsh zaten varsayılan shell${NC}"
        return 0
    fi
    
    chsh -s "$ZSH_PATH" || {
        echo -e "${YELLOW}⚠ Shell değiştirme başarısız, sudo ile deneyin:${NC}"
        echo "  sudo chsh -s $ZSH_PATH $USER"
        return 1
    }
    
    echo -e "${GREEN}✓ Varsayılan shell Zsh olarak ayarlandı${NC}"
    echo -e "${YELLOW}Not: Değişikliğin geçerli olması için çıkış yapıp tekrar giriş yapın${NC}"
}

# Tam kurulum (Dracula)
full_install_dracula() {
    show_banner
    echo -e "${CYAN}Tam kurulum başlıyor (Dracula teması)...${NC}"
    echo
    
    create_backup
    install_zsh || return 1
    install_oh_my_zsh || return 1
    install_fonts
    install_powerlevel10k || return 1
    install_plugins
    install_dracula
    change_default_shell
    
    show_completion_message
}

# Tam kurulum (Nord)
full_install_nord() {
    show_banner
    echo -e "${CYAN}Tam kurulum başlıyor (Nord teması)...${NC}"
    echo
    
    create_backup
    install_zsh || return 1
    install_oh_my_zsh || return 1
    install_fonts
    install_powerlevel10k || return 1
    install_plugins
    install_nord
    change_default_shell
    
    show_completion_message
}

# Tamamlanma mesajı
show_completion_message() {
    echo
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Kurulum tamamlandı!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${YELLOW}Sonraki adımlar:${NC}"
    echo "1. Terminal'i kapatıp yeniden açın (veya 'exec zsh' yazın)"
    echo "2. Powerlevel10k yapılandırma wizard'ı otomatik başlayacak"
    echo "3. İsterseniz daha sonra 'p10k configure' ile yeniden yapılandırabilirsiniz"
    echo
    echo -e "${CYAN}Yedekler: $BACKUP_DIR${NC}"
}

# Kaldırma
uninstall_all() {
    echo -e "${RED}Tüm özelleştirmeler kaldırılacak!${NC}"
    echo -n "Emin misiniz? (e/h): "
    read -r confirm
    
    if [[ "$confirm" != "e" ]]; then
        echo "İptal edildi"
        return
    fi
    
    echo -e "${CYAN}Kaldırma işlemi başlıyor...${NC}"
    
    # Bash'e geri dön
    if command -v bash &> /dev/null; then
        chsh -s $(which bash) 2>/dev/null && echo -e "${GREEN}✓ Varsayılan shell Bash'e döndürüldü${NC}" || echo -e "${YELLOW}⚠ Shell değiştirilemedi${NC}"
    fi
    
    # Oh My Zsh'yi kaldır
    if [[ -d ~/.oh-my-zsh ]]; then
        rm -rf ~/.oh-my-zsh
        echo -e "${GREEN}✓ Oh My Zsh kaldırıldı${NC}"
    fi
    
    # Zsh config dosyalarını sil
    [[ -f ~/.zshrc ]] && rm ~/.zshrc && echo -e "${GREEN}✓ .zshrc silindi${NC}"
    [[ -f ~/.zsh_history ]] && rm ~/.zsh_history
    [[ -f ~/.p10k.zsh ]] && rm ~/.p10k.zsh && echo -e "${GREEN}✓ .p10k.zsh silindi${NC}"
    
    # Yedekten geri yükle
    if [[ -d "$BACKUP_DIR" ]]; then
        local latest_bashrc=$(ls -t "$BACKUP_DIR"/bashrc_* 2>/dev/null | head -1)
        if [[ -f "$latest_bashrc" ]]; then
            cp "$latest_bashrc" ~/.bashrc
            echo -e "${GREEN}✓ .bashrc yedekten geri yüklendi${NC}"
        fi
    fi
    
    # Zsh'yi kaldır (opsiyonel)
    echo -n "Zsh paketini de kaldırmak ister misiniz? (e/h): "
    read -r remove_zsh
    
    if [[ "$remove_zsh" == "e" ]]; then
        sudo apt remove -y zsh 2>/dev/null && echo -e "${GREEN}✓ Zsh paketi kaldırıldı${NC}"
        sudo apt autoremove -y 2>/dev/null
    fi
    
    echo
    echo -e "${GREEN}Kaldırma tamamlandı!${NC}"
    echo -e "${YELLOW}Çıkış yapıp tekrar giriş yapın${NC}"
}

# Yedekleri göster
show_backups() {
    echo -e "${CYAN}Mevcut yedekler:${NC}"
    echo
    
    if [[ -d "$BACKUP_DIR" && $(ls -A "$BACKUP_DIR" 2>/dev/null) ]]; then
        ls -lh "$BACKUP_DIR"
    else
        echo "Henüz yedek yok"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# Root kontrolü
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Bu scripti root olarak çalıştırmayın!${NC}"
    exit 1
fi

# Ana program döngüsü
while true; do
    show_banner
    show_menu
    read -r choice
    
    case $choice in
        1)
            full_install_dracula
            read -p "Devam etmek için Enter'a basın..."
            ;;
        2)
            full_install_nord
            read -p "Devam etmek için Enter'a basın..."
            ;;
        3)
            create_backup
            install_zsh
            install_oh_my_zsh
            change_default_shell
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        4)
            create_backup
            install_fonts
            install_powerlevel10k
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        5)
            install_dracula
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        6)
            install_nord
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        7)
            create_backup
            install_plugins
            echo -e "${GREEN}✓ Tamamlandı${NC}"
            read -p "Devam etmek için Enter'a basın..."
            ;;
        8)
            uninstall_all
            read -p "Devam etmek için Enter'a basın..."
            ;;
        9)
            show_backups
            ;;
        0)
            echo -e "${CYAN}Çıkılıyor...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Geçersiz seçim!${NC}"
            sleep 2
            ;;
    esac
done