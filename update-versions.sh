#!/bin/bash

# ============================================================================
# Version Update Script
# Tüm dosyalardaki versiyonları 3.2.4'e günceller
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET_VERSION="3.2.4"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Version Update Script${NC}"
echo -e "${CYAN}  Target: v${TARGET_VERSION}${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# VERSION dosyası oluştur
echo -e "${YELLOW}1. VERSION dosyası oluşturuluyor...${NC}"
echo "$TARGET_VERSION" > VERSION
echo -e "${GREEN}✓ VERSION dosyası oluşturuldu${NC}"
echo

# install.sh güncelle
echo -e "${YELLOW}2. install.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" install.sh
echo -e "${GREEN}✓ install.sh güncellendi${NC}"
echo

# terminal-setup.sh güncelle
echo -e "${YELLOW}3. terminal-setup.sh güncelleniyor...${NC}"
sed -i "s/^VERSION=\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/VERSION=\"${TARGET_VERSION}\"/g" terminal-setup.sh
echo -e "${GREEN}✓ terminal-setup.sh güncellendi${NC}"
echo

# terminal-ui.sh güncelle (birden fazla yer)
echo -e "${YELLOW}4. terminal-ui.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" terminal-ui.sh
sed -i "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version ${TARGET_VERSION}/g" terminal-ui.sh
echo -e "${GREEN}✓ terminal-ui.sh güncellendi${NC}"
echo

# terminal-core.sh güncelle
echo -e "${YELLOW}5. terminal-core.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" terminal-core.sh
echo -e "${GREEN}✓ terminal-core.sh güncellendi${NC}"
echo

# terminal-utils.sh güncelle
echo -e "${YELLOW}6. terminal-utils.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" terminal-utils.sh
echo -e "${GREEN}✓ terminal-utils.sh güncellendi${NC}"
echo

# terminal-assistant.sh güncelle
echo -e "${YELLOW}7. terminal-assistant.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" terminal-assistant.sh
echo -e "${GREEN}✓ terminal-assistant.sh güncellendi${NC}"
echo

# terminal-themes.sh güncelle
echo -e "${YELLOW}8. terminal-themes.sh güncelleniyor...${NC}"
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" terminal-themes.sh
echo -e "${GREEN}✓ terminal-themes.sh güncellendi${NC}"
echo

# README.md güncelle
if [ -f README.md ]; then
    echo -e "${YELLOW}9. README.md güncelleniyor...${NC}"
    sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${TARGET_VERSION}/g" README.md
    echo -e "${GREEN}✓ README.md güncellendi${NC}"
    echo
fi

# Doğrulama
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Versiyon Doğrulama${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo "VERSION dosyası: $(cat VERSION)"
echo "install.sh: $(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' install.sh | head -1)"
echo "terminal-setup.sh: $(grep '^VERSION=' terminal-setup.sh | cut -d'"' -f2)"
echo "terminal-ui.sh: $(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' terminal-ui.sh | head -1)"

echo
echo -e "${GREEN}✓ Tüm versiyonlar güncellendi!${NC}"
echo -e "${YELLOW}Not: Git commit yapmayı unutmayın:${NC}"
echo -e "  ${CYAN}git add .${NC}"
echo -e "  ${CYAN}git commit -m \"chore: Update all versions to v${TARGET_VERSION}\"${NC}"
echo -e "  ${CYAN}git push${NC}"
