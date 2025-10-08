#!/bin/bash

# ============================================================================
# Update GitHub Release Script
# Mevcut release'i günceller (v3.2.5 için)
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION="v3.2.5"
REPO="alibedirhan/Theme-after-format"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  GitHub Release Updater - ${VERSION}${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# GitHub CLI kontrolü
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) kurulu değil!${NC}"
    echo
    echo -e "${YELLOW}Kurulum:${NC}"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  macOS: brew install gh"
    echo
    echo "veya: https://cli.github.com/"
    exit 1
fi

# Auth kontrolü
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠ GitHub'a giriş yapmanız gerekiyor${NC}"
    echo
    gh auth login
    echo
fi

echo -e "${GREEN}✓ GitHub CLI hazır${NC}"
echo

# Release notes dosyası oluştur
echo -e "${CYAN}[1/3] Release notes oluşturuluyor...${NC}"

cat > release-notes.md << 'EOF'
# 🎉 Theme After Format v3.2.5

## 🌟 Major Feature Release

Bu sürüm, Terminal Customization Suite'in tamamen yeniden yazılmış ve geliştirilmiş versiyonudur.

---

## ✨ Yenilikler

### 🎨 7 Tema Desteği
- **Dracula** - Mor/pembe tonları, yüksek kontrast
- **Nord** - Mavi/gri tonları, göze yumuşak  
- **Gruvbox** - Retro, sıcak tonlar
- **Tokyo Night** - Modern mavi/mor
- **Catppuccin** - Pastel renkler
- **One Dark** - Atom editor benzeri
- **Solarized Dark** - Klasik, düşük kontrast

### 🔧 Otomatik Teşhis Sistemi
- Sistem sağlık kontrolü
- Akıllı sorun tespiti
- Otomatik düzeltme önerileri

### 📦 Modern Terminal Araçları
- **FZF** - Fuzzy finder
- **Zoxide** - Akıllı cd
- **Exa** - Modern ls
- **Bat** - Syntax highlighting

### 🖥️ Tmux Tema Desteği
7 farklı tema ile terminal multiplexer desteği

### ⚙️ Modüler Yapı
6 ayrı modül ile kolay bakım:
- terminal-setup.sh
- terminal-core.sh
- terminal-utils.sh
- terminal-ui.sh
- terminal-themes.sh
- terminal-assistant.sh

---

## 🔄 İyileştirmeler

- ✨ Tamamen yeniden tasarlanmış UI/UX
- 📊 Durum çubuğu
- 🎯 Akıllı öneriler
- 🌈 Renk önizleme
- 🚀 Performans optimizasyonları
- 💾 Akıllı yedekleme sistemi
- 🔐 Geliştirilmiş güvenlik

---

## 🐛 Düzeltilen Hatalar

- ✅ Shell değiştirme sorunları
- ✅ GNOME Terminal login shell sorunu
- ✅ Font kurulum hataları
- ✅ İnternet bağlantı kontrolleri
- ✅ Tema uygulama hataları

---

## 📥 Kurulum

### Hızlı Kurulum
```bash
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh && chmod +x install.sh && ./install.sh
```

### Manuel Kurulum
```bash
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
chmod +x terminal-setup.sh
./terminal-setup.sh
```

---

## 🔄 Güncelleme

```bash
cd Theme-after-format
git pull origin main
./terminal-setup.sh
```

---

## 📊 Sistem Gereksinimleri

- Ubuntu 20.04+ / Debian 10+ / Linux Mint 20+
- Bash 4.0+
- GNOME Terminal (tam tema desteği için)
- 500 MB boş disk alanı

---

## 📚 Dokümantasyon

- [README](https://github.com/alibedirhan/Theme-after-format#readme)
- [CHANGELOG](https://github.com/alibedirhan/Theme-after-format/blob/main/CHANGELOG.md)
- [SECURITY](https://github.com/alibedirhan/Theme-after-format/blob/main/SECURITY.md)
- [CONTRIBUTING](https://github.com/alibedirhan/Theme-after-format/blob/main/CONTRIBUTING.md)

---

## 🤝 Katkıda Bulunun

- 🐛 [Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- 💡 [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions)

---

## ⭐ Destek

Projeyi beğendiyseniz star vererek destek olun!

---

**Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)**
EOF

echo -e "${GREEN}✓ Release notes hazır${NC}"
echo

# Release'i güncelle
echo -e "${CYAN}[2/3] GitHub release güncelleniyor...${NC}"

if gh release view "$VERSION" --repo "$REPO" &> /dev/null; then
    gh release edit "$VERSION" \
        --repo "$REPO" \
        --title "Release v3.2.5 - Complete Feature Overhaul" \
        --notes-file release-notes.md \
        --verify-tag
    
    echo -e "${GREEN}✓ Release güncellendi!${NC}"
else
    echo -e "${RED}❌ Release bulunamadı: $VERSION${NC}"
    exit 1
fi

# Temizlik
echo -e "${CYAN}[3/3] Temizleniyor...${NC}"
rm -f release-notes.md
echo -e "${GREEN}✓ Temizlendi${NC}"

echo
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Release başarıyla güncellendi!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${CYAN}Kontrol et:${NC}"
echo "  https://github.com/$REPO/releases/tag/$VERSION"
echo
