# 🤝 Katkıda Bulunma Rehberi

Terminal Customization Suite projesine katkıda bulunmayı düşündüğünüz için teşekkür ederiz! Bu belge, projeye nasıl katkıda bulunabileceğinizi açıklar.

## 📋 İçindekiler

- [Davranış Kuralları](#davranış-kuralları)
- [Nasıl Katkıda Bulunurum?](#nasıl-katkıda-bulunurum)
- [Geliştirme Ortamı](#geliştirme-ortamı)
- [Kod Standartları](#kod-standartları)
- [Commit Mesajları](#commit-mesajları)
- [Pull Request Süreci](#pull-request-süreci)
- [Sorun Bildirme](#sorun-bildirme)
- [Özellik Önerme](#özellik-önerme)

## 📜 Davranış Kuralları

Bu proje ve topluluğu aşağıdaki kurallara uyar:

- ✅ Saygılı ve yapıcı olun
- ✅ Farklı bakış açılarına açık olun
- ✅ Yapıcı eleştiri kabul edin
- ✅ Topluluk odaklı düşünün
- ❌ Kaba, aşağılayıcı veya taciz edici davranışlar yasaktır

## 🚀 Nasıl Katkıda Bulunurum?

### Katkı Türleri

1. **Hata Düzeltme (Bug Fix)**
   - Mevcut sorunları çözme
   - Test yazma
   - Dokümantasyon güncelleme

2. **Yeni Özellik (Feature)**
   - Yeni tema ekleme
   - Yeni terminal desteği
   - Yeni araç entegrasyonu

3. **Dokümantasyon**
   - README geliştirme
   - Kod yorumları ekleme
   - Wiki oluşturma

4. **Test**
   - Farklı dağıtımlarda test
   - Edge case'leri bulma
   - Performans testleri

## 🛠️ Geliştirme Ortamı

### Gereksinimler

- Ubuntu 20.04+ veya Debian tabanlı dağıtım
- Bash 4.0+
- Git
- shellcheck (kod kalitesi için)
- shfmt (kod formatlama için)

### Kurulum

```bash
# Repository'yi fork'layın ve klonlayın
git clone https://github.com/KULLANICI-ADINIZ/Theme-after-format.git
cd Theme-after-format

# Upstream ekleyin
git remote add upstream https://github.com/alibedirhan/Theme-after-format.git

# Geliştirme araçlarını kurun
sudo apt install shellcheck shfmt
```

### Branch Stratejisi

```bash
# Ana branch'ten yeni feature branch oluşturun
git checkout -b feature/yeni-ozellik

# Veya bug fix için
git checkout -b fix/hata-ismi

# Veya dokümantasyon için
git checkout -b docs/dokumantasyon-guncelleme
```

## 📝 Kod Standartları

### Bash Script Kuralları

#### 1. Dosya Yapısı

```bash
#!/bin/bash

# ============================================================================
# ModÜl İsmi - Kısa Açıklama
# vX.X.X - Versiyon Bilgisi
# ============================================================================

# ============================================================================
# BÖLÜM BAŞLIĞI
# ============================================================================

fonksiyon_ismi() {
    # Fonksiyon açıklaması
    local degisken=$1
    
    # İşlemler
    return 0
}
```

#### 2. İsimlendirme Kuralları

```bash
# Fonksiyonlar: snake_case
install_theme() { }
check_dependencies() { }

# Değişkenler: snake_case (local scope)
local theme_name="dracula"
local backup_dir="$HOME/.backups"

# Sabitler: UPPERCASE
readonly VERSION="3.2.1"
readonly SCRIPT_DIR="/path/to/script"

# Renkler: UPPERCASE
RED='\033[0;31m'
GREEN='\033[0;32m'
```

#### 3. Hata Yönetimi

```bash
# YANLIŞ
rm -rf ~/.oh-my-zsh

# DOĞRU - Hata kontrolü
if [[ -d ~/.oh-my-zsh ]]; then
    if ! rm -rf ~/.oh-my-zsh 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
        log_error "Oh My Zsh kaldırılamadı"
        return 1
    fi
fi
```

#### 4. Timeout ve Validation

```bash
# YANLIŞ
sudo apt install -y zsh

# DOĞRU - Timeout ve validation
if ! timeout 300 sudo apt install -y zsh &>/dev/null; then
    log_error "Zsh kurulumu başarısız veya timeout!"
    return 1
fi

# Kurulum doğrulama
if ! command -v zsh &> /dev/null; then
    log_error "Zsh kuruldu ama komut bulunamadı!"
    return 1
fi
```

#### 5. Input Validation

```bash
# YANLIŞ
case $choice in
    1) install_dracula ;;
esac

# DOĞRU
if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
    log_error "Geçersiz seçim: sayı giriniz"
    return 1
fi

if [[ $choice -lt 0 || $choice -gt 15 ]]; then
    log_error "Geçersiz seçim: 0-15 arası olmalı"
    return 1
fi
```

#### 6. Logging

```bash
# Her önemli işlem loglanmalı
log_info "Zsh kuruluyor..."
log_success "Zsh kuruldu"
log_warning "Font kurulumu başarısız, devam ediliyor..."
log_error "İnternet bağlantısı yok!"
log_debug "Tema dosyası: $theme_file"
```

### ShellCheck Kuralları

Tüm script'ler ShellCheck'ten geçmelidir:

```bash
# Script'leri kontrol et
shellcheck terminal-setup.sh
shellcheck terminal-core.sh
shellcheck terminal-utils.sh
shellcheck terminal-ui.sh
shellcheck terminal-themes.sh
shellcheck terminal-assistant.sh

# Veya hepsini birden
shellcheck *.sh
```

### Kod Formatlama

```bash
# shfmt ile formatla (2 space indentation)
shfmt -i 2 -w terminal-setup.sh
```

## 📊 Commit Mesajları

### Format

```
<tip>(<kapsam>): <kısa açıklama>

<detaylı açıklama (opsiyonel)>

<footer (opsiyonel)>
```

### Tipler

- `feat`: Yeni özellik
- `fix`: Hata düzeltme
- `docs`: Dokümantasyon değişikliği
- `style`: Kod formatı (mantık değişikliği yok)
- `refactor`: Kod yeniden yapılandırma
- `perf`: Performans iyileştirme
- `test`: Test ekleme/düzeltme
- `chore`: Build/config değişiklikleri

### Örnekler

```bash
# Yeni özellik
feat(themes): Tokyo Night teması eklendi

Tokyo Night teması için GNOME Terminal, Kitty ve Alacritty 
desteği eklendi. Renk paleti ve konfigürasyon dosyaları hazırlandı.

Closes #42

# Hata düzeltme
fix(core): Zsh kurulumunda timeout hatası düzeltildi

Timeout süresi 120'den 300 saniyeye çıkarıldı ve 
hata mesajları iyileştirildi.

Fixes #38

# Dokümantasyon
docs(readme): Terminal araçları bölümü eklendi

FZF, Zoxide, Exa ve Bat kullanım örnekleri README'ye eklendi.

# Refactoring
refactor(utils): Logging sistemi iyileştirildi

Thread-safe logging ve otomatik rotasyon eklendi.
```

## 🔄 Pull Request Süreci

### 1. Fork ve Clone

```bash
# Repository'yi fork edin (GitHub web arayüzünden)

# Fork'unuzu klonlayın
git clone https://github.com/KULLANICI-ADINIZ/Theme-after-format.git
cd Theme-after-format

# Upstream ekleyin
git remote add upstream https://github.com/alibedirhan/Theme-after-format.git
```

### 2. Feature Branch Oluştur

```bash
# Main'den güncel çekin
git checkout main
git pull upstream main

# Yeni branch oluşturun
git checkout -b feature/yeni-tema
```

### 3. Değişiklikleri Yap

```bash
# Kodunuzu yazın
# ShellCheck ve shfmt ile kontrol edin
shellcheck *.sh
shfmt -i 2 -w *.sh

# Test edin
./terminal-setup.sh --health
./terminal-setup.sh --scan
```

### 4. Commit

```bash
# Değişiklikleri stage'e ekleyin
git add .

# Commit edin (yukarıdaki commit kurallarına göre)
git commit -m "feat(themes): Gruvbox teması eklendi"
```

### 5. Push ve PR

```bash
# Branch'inizi push edin
git push origin feature/yeni-tema

# GitHub'da Pull Request açın
```

### PR Checklist

Pull Request açmadan önce:

- [ ] Kod ShellCheck'ten geçiyor
- [ ] Kod shfmt ile formatlanmış
- [ ] Tüm yeni fonksiyonlar test edildi
- [ ] README güncellenmiş (gerekiyorsa)
- [ ] CHANGELOG.md güncellenmiş
- [ ] Commit mesajları kurallara uygun
- [ ] Branch ismi açıklayıcı
- [ ] PR açıklaması detaylı

### PR Şablonu

```markdown
## Değişiklik Türü
- [ ] Bug fix
- [ ] Yeni özellik
- [ ] Dokümantasyon
- [ ] Refactoring

## Açıklama
Bu PR ne yapıyor? Neden gerekli?

## Test Edilen Ortamlar
- [ ] Ubuntu 22.04
- [ ] Ubuntu 20.04
- [ ] Debian 11
- [ ] Linux Mint 21

## Test Edilen Terminaller
- [ ] GNOME Terminal
- [ ] Kitty
- [ ] Alacritty

## İlgili Issue'lar
Closes #42
Fixes #38

## Ekran Görüntüleri (varsa)
```

## 🐛 Sorun Bildirme

### Nasıl İyi Bir Sorun Bildirimi Yapılır?

#### 1. Önce Arayın

Sorunun daha önce bildirilip bildirilmediğini kontrol edin:
- [Açık Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- [Kapalı Issues](https://github.com/alibedirhan/Theme-after-format/issues?q=is%3Aissue+is%3Aclosed)

#### 2. Bilgi Toplayın

```bash
# Sistem bilgisi
uname -a
lsb_release -a

# Terminal bilgisi
echo $TERM
echo $COLORTERM

# Script versiyonu
./terminal-setup.sh --version

# Log dosyası
cat ~/.terminal-setup/logs/terminal-setup.log
```

#### 3. Issue Şablonu

```markdown
### Sorun Açıklaması
Ne oldu? Ne olması bekleniyordu?

### Adımlar
1. Script'i çalıştırdım
2. Menüden 1'i seçtim
3. Hata aldım

### Ortam
- OS: Ubuntu 22.04 LTS
- Terminal: GNOME Terminal 3.44.0
- Shell: bash 5.1.16
- Script Version: v3.2.1

### Hata Mesajı
```
ERROR: Zsh kurulumu başarısız
```

### Log
```
[2025-01-15 10:30:45] [ERROR] Timeout - Zsh kurulumu
```

### Ekran Görüntüsü
(varsa)

### Ek Bilgi
- İnternet hızı: 50 Mbps
- Disk alanı: 20 GB
```

## 💡 Özellik Önerme

### Özellik İsteği Şablonu

```markdown
### Özellik Açıklaması
Ne istiyorsunuz?

### Motivasyon
Neden bu özellik gerekli?

### Önerilen Çözüm
Nasıl implemente edilebilir?

### Alternatifler
Başka ne yapılabilir?

### Ek Bilgi
İlgili linkler, örnekler, ekran görüntüleri
```

## 🎨 Yeni Tema Ekleme

### Tema Ekleme Adımları

1. **terminal-themes.sh'a tema fonksiyonları ekleyin**

```bash
# GNOME Terminal için
apply_yeni_tema_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Yeni Tema"
    gsettings set "$path" background-color '#XXXXXX'
    gsettings set "$path" foreground-color '#XXXXXX'
    # ... diğer renkler
}

# Kitty için
get_kitty_theme_yeni_tema() {
    cat << 'EOF'
foreground #XXXXXX
background #XXXXXX
# ... diğer renkler
EOF
}

# Alacritty için
get_alacritty_theme_yeni_tema() {
    cat << 'EOF'
colors:
  primary:
    background: '#XXXXXX'
    foreground: '#XXXXXX'
  # ... diğer renkler
EOF
}

# Tmux için
get_tmux_theme_yeni_tema() {
    cat << 'EOF'
set -g status-style bg='#XXXXXX',fg='#XXXXXX'
# ... diğer ayarlar
EOF
}
```

2. **terminal-core.sh'ta tema uygulama fonksiyonlarını güncelleyin**

```bash
install_theme() {
    # ...
    case $theme_name in
        # ... mevcut temalar
        yeni-tema) install_theme_gnome "$theme_name" ;;
    esac
}
```

3. **terminal-ui.sh'ta menüye ekleyin**

```bash
show_theme_menu() {
    # ...
    echo -ne "${WHITE}8)${NC} ${CYAN}Yeni Tema${NC}   - Açıklama"
    show_theme_colors "yeni-tema"
    echo
}
```

4. **README.md'yi güncelleyin**

### Tema Gereksinimleri

- ✅ 16 renk tanımlanmalı (normal + bright)
- ✅ GNOME Terminal desteği zorunlu
- ✅ Kitty ve Alacritty desteği önerilen
- ✅ Tmux desteği opsiyonel
- ✅ Renk paleti dokümante edilmeli
- ✅ Test edilmiş olmalı

## 🧪 Test

### Manuel Test

```bash
# Her menü seçeneğini test edin
./terminal-setup.sh

# Farklı dağıtımlarda test edin
# - Ubuntu 22.04, 20.04
# - Debian 11, 12
# - Linux Mint 21

# Farklı terminallerde test edin
# - GNOME Terminal
# - Kitty
# - Alacritty

# Edge case'leri test edin
# - İnternetsiz
# - Düşük disk alanı
# - Mevcut kurulum var
```

### Automated Test (Gelecek)

```bash
# Planlanıyor: Otomasyon testleri
./test/run-tests.sh
```

## 📦 Release Süreci

### Version Numaralama

Semantic Versioning (SemVer) kullanıyoruz: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: Yeni özellikler (geriye uyumlu)
- **PATCH**: Bug fixes (geriye uyumlu)

### Release Checklist

- [ ] CHANGELOG.md güncellendi
- [ ] VERSION dosyası güncellendi
- [ ] README.md güncellendi
- [ ] Tüm testler geçiyor
- [ ] Tag oluşturuldu: `git tag v3.2.1`
- [ ] GitHub Release oluşturuldu

## 🤔 Sorular?

Takıldığınız bir yer mi var? 

- 💬 [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions)
- 🐛 [Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- 📧 GitHub profilimden ulaşabilirsiniz

---

**Teşekkürler! Katkılarınız projeyi daha iyi hale getirir.** ❤️
