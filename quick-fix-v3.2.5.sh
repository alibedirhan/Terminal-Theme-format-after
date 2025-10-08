#!/bin/bash

# ============================================================================
# Quick Fix Script - v3.2.5 Version Sync
# Tüm dosyaları v3.2.5'e güncelleyip commit/push eder
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Quick Fix - v3.2.5 Version Sync${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Onay al
echo -e "${YELLOW}Bu script şunları yapacak:${NC}"
echo "  1. VERSION dosyası oluşturacak"
echo "  2. Tüm scriptleri v3.2.5'e güncelleyecek"
echo "  3. Git commit yapacak"
echo "  4. Main branch'e push edecek"
echo
echo -ne "${YELLOW}Devam etmek istiyor musunuz? (e/h): ${NC}"
read -r response

if [[ ! "$response" =~ ^[eE]$ ]]; then
    echo -e "${RED}İptal edildi.${NC}"
    exit 0
fi

echo

# 1. VERSION dosyası oluştur
echo -e "${CYAN}[1/5] VERSION dosyası oluşturuluyor...${NC}"
echo "3.2.5" > VERSION
echo -e "${GREEN}✓ VERSION dosyası oluşturuldu${NC}"
echo

# 2. Versiyonları güncelle
echo -e "${CYAN}[2/5] Script versiyonları güncelleniyor...${NC}"

# install.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' install.sh
echo -e "${GREEN}  ✓ install.sh${NC}"

# terminal-setup.sh
sed -i 's/^VERSION="[0-9]\+\.[0-9]\+\.[0-9]\+"/VERSION="3.2.5"/' terminal-setup.sh
echo -e "${GREEN}  ✓ terminal-setup.sh${NC}"

# terminal-ui.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' terminal-ui.sh
sed -i 's/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version 3.2.5/g' terminal-ui.sh
echo -e "${GREEN}  ✓ terminal-ui.sh${NC}"

# terminal-core.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' terminal-core.sh
echo -e "${GREEN}  ✓ terminal-core.sh${NC}"

# terminal-utils.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' terminal-utils.sh
echo -e "${GREEN}  ✓ terminal-utils.sh${NC}"

# terminal-assistant.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' terminal-assistant.sh
echo -e "${GREEN}  ✓ terminal-assistant.sh${NC}"

# terminal-themes.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' terminal-themes.sh
echo -e "${GREEN}  ✓ terminal-themes.sh${NC}"

# test.sh
sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' test.sh
echo -e "${GREEN}  ✓ test.sh${NC}"

# README.md (varsa)
if [ -f README.md ]; then
    sed -i 's/v[0-9]\+\.[0-9]\+\.[0-9]\+/v3.2.5/g' README.md
    echo -e "${GREEN}  ✓ README.md${NC}"
fi

echo

# 3. Doğrulama
echo -e "${CYAN}[3/5] Doğrulama yapılıyor...${NC}"
echo "VERSION file: $(cat VERSION)"
echo "terminal-setup.sh: $(grep '^VERSION=' terminal-setup.sh | cut -d'"' -f2)"
echo "install.sh: $(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' install.sh | head -1)"
echo

# 4. Git kontrolü
echo -e "${CYAN}[4/5] Git durumu kontrol ediliyor...${NC}"

if ! git diff --quiet; then
    echo -e "${GREEN}✓ Değişiklikler tespit edildi${NC}"
    echo
    echo "Değiştirilen dosyalar:"
    git status --short
    echo
else
    echo -e "${YELLOW}⚠ Hiçbir değişiklik yok${NC}"
    exit 0
fi

# 5. Commit ve push
echo -e "${CYAN}[5/5] Git commit ve push yapılıyor...${NC}"

git add VERSION *.sh README.md 2>/dev/null || true

git commit -m "chore: Sync all versions to v3.2.5

- Add VERSION file with 3.2.5
- Update all script versions to v3.2.5
- Update README.md version references

This aligns the codebase with the existing GitHub release v3.2.5"

echo -e "${GREEN}✓ Commit oluşturuldu${NC}"

# Push
echo
echo -e "${YELLOW}Main branch'e push edilecek. Devam? (e/h): ${NC}"
read -r push_response

if [[ "$push_response" =~ ^[eE]$ ]]; then
    git push origin main
    echo -e "${GREEN}✓ Başarıyla push edildi!${NC}"
else
    echo -e "${YELLOW}Push atlandı. Manuel olarak yapmak için:${NC}"
    echo -e "  ${CYAN}git push origin main${NC}"
fi

echo
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Tüm versiyonlar v3.2.5'e güncellendi!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${CYAN}Sonraki adımlar:${NC}"
echo "  1. GitHub'da release'i kontrol et: https://github.com/alibedirhan/Theme-after-format/releases/tag/v3.2.5"
echo "  2. Gerekirse release notes'u güncelle"
echo "  3. Test et: ./terminal-setup.sh"
echo
