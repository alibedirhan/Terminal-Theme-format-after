# 🎨 Terminal Özelleştirme Kurulum Aracı

[![Version](https://img.shields.io/badge/version-3.1.0-blue.svg)](https://github.com/alibedirhan/Theme-after-format)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Modern, güçlü ve kullanıcı dostu terminal özelleştirme scripti. Ubuntu/Debian tabanlı sistemler için Zsh, Oh My Zsh, Powerlevel10k ve 7 farklı renk teması ile terminal deneyiminizi bir üst seviyeye taşıyın.

## ✨ Özellikler

### Temel Özellikler
- 🎨 **7 Modern Tema**: Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized
- 🚀 **Powerlevel10k**: Hızlı ve özelleştirilebilir prompt
- 🔌 **Auto-suggestions & Syntax Highlighting**: Akıllı komut önerileri
- 🛠️ **Modern Terminal Araçları**: FZF, Zoxide, Exa, Bat desteği
- 📦 **Tmux Entegrasyonu**: Tema destekli tmux konfigürasyonu
- 💾 **Otomatik Yedekleme**: Mevcut ayarlarınız güvenli şekilde yedeklenir

### Gelişmiş Özellikler (v3.1.0)
- ✅ **Tam Kaldırma**: Terminal profil ayarlarını da sıfırlama
- 🔄 **Orijinal Durum Geri Yükleme**: Kurulum öncesi snapshot
- ⚡ **Force Mode**: Otomatik onaysız kaldırma (`--force`)
- 📊 **Detaylı Progress Bar**: Her adımda görsel feedback
- ⏱️ **Timeout Sistemi**: Takılma problemi yok (30 saniye)
- 🐛 **Debug Modu**: Detaylı hata ayıklama (`--debug`)
- 📝 **Hata Kodları**: Standardize edilmiş hata yönetimi
- 🎯 **Sistem Sağlık Kontrolü**: Kurulum öncesi hazırlık testi

### Desteklenen Terminal Emülatörleri
- ✅ GNOME Terminal (tam destek)
- ✅ Kitty (tam destek)
- ✅ Alacritty (tam destek)
- ⚠️ Diğerleri (sınırlı destek)

## 📋 Gereksinimler

### Zorunlu
- Ubuntu 20.04+ veya Debian tabanlı dağıtım
- `git`, `curl`, `wget` (otomatik kurulur)
- Sudo yetkisi

### Opsiyonel
- `gsettings` (GNOME Terminal renk temaları için)
- `fc-cache` (font yönetimi için)

## 🚀 Hızlı Başlangıç

### Tek Komutla Kurulum

```bash
# Repoyu klonla
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format

# Çalıştırma izni ver
chmod +x *.sh

# Script'i başlat
./terminal-setup.sh
```

### Direkt İndirme (Git olmadan)

```bash
wget https://github.com/alibedirhan/Theme-after-format/archive/refs/heads/main.zip
unzip main.zip
cd Theme-after-format-main
chmod +x *.sh
./terminal-setup.sh
```

## 📖 Kullanım

### İnteraktif Mod (Önerilen)

```bash
./terminal-setup.sh
```

Ana menüden seçim yapın:
```
═══ ANA MENÜ ═══

Tam Kurulum:
  1) Dracula Teması ile Tam Kurulum
  2) Nord Teması ile Tam Kurulum
  3) Gruvbox Teması ile Tam Kurulum
  4) Tokyo Night Teması ile Tam Kurulum

Modüler Kurulum:
  5) Sadece Zsh + Oh My Zsh
  6) Sadece Powerlevel10k Teması
  7) Sadece Renk Teması Değiştir
  8) Sadece Pluginler
  9) Terminal Araçları (FZF, Zoxide, Exa, Bat)
 10) Tmux Kurulumu

Yönetim:
 11) Sistem Sağlık Kontrolü
 12) Yedekleri Göster
 13) Tümünü Kaldır
 14) Ayarlar
```

### Komut Satırı Parametreleri

```bash
# Sistem sağlık kontrolü
./terminal-setup.sh --health

# Güncellemeleri kontrol et
./terminal-setup.sh --update

# Debug modu
./terminal-setup.sh --debug

# Verbose çıktı
./terminal-setup.sh --verbose

# Zorlamalı kaldırma (dikkatli kullanın!)
./terminal-setup.sh --force
# Sonra menüden 13. seçeneği seçin

# Versiyon bilgisi
./terminal-setup.sh --version

# Yardım
./terminal-setup.sh --help
```

## 🎨 Tema Önizlemeleri

### Dracula
Mor/pembe tonları, yüksek kontrast. Modern ve canlı.

### Nord
Mavi/gri tonları, göze yumuşak. Skandinav minimalizmi.

### Gruvbox Dark
Retro, sıcak tonlar. Uzun süreli kullanım için ideal.

### Tokyo Night
Modern, mavi/mor tonlar. Popüler VS Code teması.

### Catppuccin
Pastel renkler, yumuşak geçişler. Şık ve zarif.

### One Dark
Atom editor benzeri. Dengeli ve profesyonel.

### Solarized Dark
Klasik, düşük kontrast. Bilimsel olarak optimize edilmiş.

## 🛠️ Kurulum Adımları (Tam Kurulum)

Script otomatik olarak şunları yapar:

1. ✅ Sistem bağımlılıklarını kontrol eder
2. ✅ Mevcut ayarları yedekler
3. ✅ Orijinal sistem durumunu kaydeder
4. ✅ Zsh'i kurar
5. ✅ Oh My Zsh'i kurar
6. ✅ Powerlevel10k fontlarını indirir
7. ✅ Powerlevel10k temasını kurar
8. ✅ Pluginleri kurar (auto-suggestions, syntax-highlighting)
9. ✅ Seçilen renk temasını uygular
10. ✅ Varsayılan shell'i Zsh yapar

**Süre:** ~5-10 dakika (internet hızınıza bağlı)

## 🗑️ Kaldırma

### İnteraktif Kaldırma (Güvenli)

```bash
./terminal-setup.sh
# Menüden 13. seçeneği seçin
# Her adım için onay ister
```

Kaldırılan öğeler:
- ✅ Zsh konfigürasyon dosyaları
- ✅ Oh My Zsh
- ✅ Powerlevel10k
- ✅ Terminal profil ayarları (renkler)
- ✅ Pluginler
- ⚠️ Opsiyonel: FZF, Zoxide, Fontlar, Tmux, sistem paketleri

### Zorlamalı Kaldırma (Tehlikeli)

```bash
./terminal-setup.sh --force
# Menüden 13. seçeneği seçin
# 5 saniye sonra HER ŞEYİ siler
```

⚠️ **UYARI**: Bu mod tüm opsiyonel paketleri de kaldırır. Dikkatli kullanın!

### Kaldırma Sonrası

```bash
# Terminal'i kapatıp tekrar açın
exit

# Veya shell'i yeniden yükleyin
exec bash
```

## 📁 Dosya Yapısı

```
Theme-after-format/
├── terminal-setup.sh      # Ana orchestrator script
├── terminal-core.sh        # Kurulum fonksiyonları
├── terminal-utils.sh       # Yardımcı fonksiyonlar
├── VERSION                 # Versiyon bilgisi
├── README.md               # Bu dosya
├── LICENSE                 # MIT Lisansı
└── .gitignore              # Git ignore kuralları
```

## 🔧 Konfigürasyon

### Ayarlar Dosyası

Script ayarları `~/.terminal-setup.conf` dosyasında saklanır:

```bash
# Varsayılan tema
DEFAULT_THEME="dracula"

# Otomatik güncelleme
AUTO_UPDATE="false"

# Saklanacak yedek sayısı
BACKUP_COUNT="5"
```

### Yedek Dizini

Tüm yedekler `~/.terminal-setup-backup/` dizininde saklanır:

```
~/.terminal-setup-backup/
├── bashrc_20250102_143022
├── zshrc_20250102_143022
├── original_state.txt
└── ...
```

### Log Dosyası

Tüm işlemler `~/.terminal-setup.log` dosyasına kaydedilir:

```bash
# Canlı log takibi
tail -f ~/.terminal-setup.log

# Son 50 satır
tail -50 ~/.terminal-setup.log
```

## 🐛 Sorun Giderme

### Terminal Rengi Değişmedi

```bash
# Terminal profilini manuel sıfırla
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
gsettings set "$PATH" use-theme-colors true

# Terminal'i kapat-aç
```

### Shell Değişmedi

```bash
# Manuel shell değiştirme
sudo chsh -s /usr/bin/zsh $USER

# Çıkış yapıp tekrar girin
exit
```

### Fontlar Görünmüyor

```bash
# Font cache'i güncelle
fc-cache -f ~/.local/share/fonts

# Terminal'de font ayarlarını kontrol edin
# Tercihler → Profiller → Metin → "MesloLGS NF Regular" seçin
```

### Powerlevel10k Konfigürasyonu

```bash
# Wizard'ı yeniden çalıştır
p10k configure

# Manuel konfigürasyon
nano ~/.p10k.zsh
```

### Script Takılı Kalıyor

```bash
# Debug modu ile çalıştır
./terminal-setup.sh --debug

# Log dosyasını kontrol et
tail -100 ~/.terminal-setup.log

# Timeout kontrolü - 30 saniye bekliyor
# Eğer cevap vermezseniz varsayılan değer kullanılır
```

## 🔐 Güvenlik

- ✅ Script sudo yetkisi ister (güvenlik için)
- ✅ Tüm dosyalar kullanıcı dizininde (~/)
- ✅ Sistem dosyaları değiştirilmez
- ✅ Yedekler otomatik oluşturulur
- ✅ Orijinal durum kaydedilir

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! İşte nasıl:

1. Repo'yu fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

### Geliştirme Rehberi

```bash
# Test ortamı (VM önerilir)
# Debug modu ile test edin
./terminal-setup.sh --debug

# Kod standardı: ShellCheck
shellcheck terminal-*.sh
```

## 📝 Değişiklik Geçmişi

### v3.1.0 (2025-01-02)
- ✨ Tam kaldırma sistemi: Terminal profil sıfırlama
- ✨ Orijinal durum kaydetme ve geri yükleme
- ✨ Force mode: Otomatik kaldırma
- ✨ Hata kodları sistemi
- ✨ Timeout ile input alma (30 saniye)
- ✨ Detaylı progress bar ve spinner
- 🐛 Shell değiştirme hataları düzeltildi
- 🐛 Terminal renk kalıcılığı sorunu çözüldü
- 📝 Kapsamlı logging sistemi

### v3.0.0
- İlk stabil sürüm
- 7 tema desteği
- Modüler yapı

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 💡 İlham Kaynakları

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Dracula Theme](https://draculatheme.com/)
- [Nord Theme](https://www.nordtheme.com/)

## 📧 İletişim

Ali Bedirhan - [@alibedirhan](https://github.com/alibedirhan)

Proje Linki: [https://github.com/alibedirhan/Theme-after-format](https://github.com/alibedirhan/Theme-after-format)

## 🙏 Teşekkürler

- Oh My Zsh ekibine
- Powerlevel10k geliştiricilerine
- Tema tasarımcılarına
- Tüm katkıda bulunanlara

---

**⭐ Beğendiyseniz yıldız vermeyi unutmayın!**