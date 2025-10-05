#!/bin/bash

# ============================================================================
# Terminal Setup - Test ve Doğrulama Scripti
# v3.0 - Automated Testing
# ============================================================================

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test sonuçları
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test fonksiyonu
test_case() {
    local test_name=$1
    local test_command=$2
    
    ((TOTAL_TESTS++))
    echo -n "Test $TOTAL_TESTS: $test_name... "
    
    if eval "$test_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         TERMINAL SETUP - TEST SÜİTİ v3.0                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

# ============================================================================
# DOSYA TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Dosya Testleri ═══${NC}"

test_case "terminal-setup.sh mevcut" "[[ -f terminal-setup.sh ]]"
test_case "terminal-core.sh mevcut" "[[ -f terminal-core.sh ]]"
test_case "terminal-utils.sh mevcut" "[[ -f terminal-utils.sh ]]"
test_case "VERSION dosyası mevcut" "[[ -f VERSION ]]"

test_case "terminal-setup.sh çalıştırılabilir" "[[ -x terminal-setup.sh ]]"
test_case "terminal-core.sh çalıştırılabilir" "[[ -x terminal-core.sh ]]"
test_case "terminal-utils.sh çalıştırılabilir" "[[ -x terminal-utils.sh ]]"

echo

# ============================================================================
# SÖZDİZİMİ TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Sözdizimi Testleri ═══${NC}"

test_case "terminal-setup.sh sözdizimi" "bash -n terminal-setup.sh"
test_case "terminal-core.sh sözdizimi" "bash -n terminal-core.sh"
test_case "terminal-utils.sh sözdizimi" "bash -n terminal-utils.sh"

echo

# ============================================================================
# BAĞIMLILIK TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Bağımlılık Testleri ═══${NC}"

test_case "git kurulu" "command -v git"
test_case "curl kurulu" "command -v curl"
test_case "wget kurulu" "command -v wget"
test_case "bash versiyonu >=4.0" "[[ ${BASH_VERSINFO[0]} -ge 4 ]]"

echo

# ============================================================================
# FONKSİYON TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Fonksiyon Testleri ═══${NC}"

# Utils modülünü yükle
if [[ -f terminal-utils.sh ]]; then
    source terminal-utils.sh
    
    test_case "log_info fonksiyonu" "type log_info"
    test_case "log_success fonksiyonu" "type log_success"
    test_case "log_error fonksiyonu" "type log_error"
    test_case "show_progress fonksiyonu" "type show_progress"
    test_case "detect_terminal fonksiyonu" "type detect_terminal"
    test_case "check_internet fonksiyonu" "type check_internet"
    test_case "system_health_check fonksiyonu" "type system_health_check"
else
    echo -e "${RED}terminal-utils.sh bulunamadı, fonksiyon testleri atlanıyor${NC}"
fi

# Core modülünü yükle
if [[ -f terminal-core.sh ]]; then
    source terminal-core.sh
    
    test_case "check_dependencies fonksiyonu" "type check_dependencies"
    test_case "install_zsh fonksiyonu" "type install_zsh"
    test_case "install_oh_my_zsh fonksiyonu" "type install_oh_my_zsh"
    test_case "install_fonts fonksiyonu" "type install_fonts"
    test_case "install_powerlevel10k fonksiyonu" "type install_powerlevel10k"
    test_case "install_theme fonksiyonu" "type install_theme"
else
    echo -e "${RED}terminal-core.sh bulunamadı, fonksiyon testleri atlanıyor${NC}"
fi

echo

# ============================================================================
# VERSİYON TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Versiyon Testleri ═══${NC}"

if [[ -f VERSION ]]; then
    version=$(cat VERSION)
    test_case "Versiyon formatı doğru (X.Y.Z)" "[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]"
    
    # Script içindeki versiyonla karşılaştır
    script_version=$(grep '^VERSION=' terminal-setup.sh | cut -d'"' -f2)
    test_case "Versiyon numaraları eşleşiyor" "[[ $version == $script_version ]]"
else
    echo -e "${RED}VERSION dosyası bulunamadı${NC}"
fi

echo

# ============================================================================
# İNTEGRASYON TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ İntegrasyon Testleri ═══${NC}"

# Modül yükleme testi
test_case "terminal-utils.sh başarıyla yükleniyor" "source terminal-utils.sh"
test_case "terminal-core.sh başarıyla yükleniyor" "source terminal-utils.sh && source terminal-core.sh"

# Global değişkenler
test_case "Renk değişkenleri tanımlı" "[[ -n \$RED && -n \$GREEN && -n \$YELLOW ]]"

echo

# ============================================================================
# GÜVENLİK TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Güvenlik Testleri ═══${NC}"

test_case "Root kontrolü mevcut" "grep -q 'EUID -eq 0' terminal-setup.sh"
test_case "Cleanup fonksiyonu mevcut" "grep -q 'cleanup()' terminal-setup.sh"
test_case "Trap tanımlı" "grep -q 'trap cleanup EXIT' terminal-setup.sh"

echo

# ============================================================================
# SHELLCHECK TESTLERİ (opsiyonel)
# ============================================================================

if command -v shellcheck &> /dev/null; then
    echo -e "${YELLOW}═══ ShellCheck Analizi ═══${NC}"
    
    test_case "terminal-setup.sh shellcheck" "shellcheck -S warning terminal-setup.sh"
    test_case "terminal-core.sh shellcheck" "shellcheck -S warning terminal-core.sh"
    test_case "terminal-utils.sh shellcheck" "shellcheck -S warning terminal-utils.sh"
    
    echo
else
    echo -e "${YELLOW}ShellCheck kurulu değil, atlanıyor...${NC}"
    echo "Kurmak için: sudo apt install shellcheck"
    echo
fi

# ============================================================================
# PERFORMANS TESTLERİ
# ============================================================================

echo -e "${YELLOW}═══ Performans Testleri ═══${NC}"

# Dosya boyutları
for file in terminal-setup.sh terminal-core.sh terminal-utils.sh; do
    if [[ -f "$file" ]]; then
        size=$(wc -c < "$file")
        kb_size=$((size / 1024))
        echo "  • $file: ${kb_size}KB"
    fi
done

# Satır sayıları
total_lines=0
for file in terminal-setup.sh terminal-core.sh terminal-utils.sh; do
    if [[ -f "$file" ]]; then
        lines=$(wc -l < "$file")
        total_lines=$((total_lines + lines))
        echo "  • $file: $lines satır"
    fi
done
echo "  • Toplam: $total_lines satır"

echo

# ============================================================================
# SONUÇ ÖZETİ
# ============================================================================

echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                  TEST SONUÇLARI                       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
echo
echo "Toplam Test: $TOTAL_TESTS"
echo -e "${GREEN}Başarılı: $PASSED_TESTS${NC}"
echo -e "${RED}Başarısız: $FAILED_TESTS${NC}"
echo

# Başarı oranı
success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo -n "Başarı Oranı: "

if [ $success_rate -eq 100 ]; then
    echo -e "${GREEN}%${success_rate} - Mükemmel!${NC}"
    exit 0
elif [ $success_rate -ge 90 ]; then
    echo -e "${GREEN}%${success_rate} - Çok İyi${NC}"
    exit 0
elif [ $success_rate -ge 75 ]; then
    echo -e "${YELLOW}%${success_rate} - İyi${NC}"
    exit 0
elif [ $success_rate -ge 50 ]; then
    echo -e "${YELLOW}%${success_rate} - Orta${NC}"
    exit 1
else
    echo -e "${RED}%${success_rate} - Zayıf${NC}"
    exit 1
fi
