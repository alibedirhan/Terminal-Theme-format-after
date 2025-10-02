# 🎨 Terminal Setup v3.0 - Theme After Format

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/alibedirhan/Theme-after-format)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Format attıktan sonra terminal özelleştirmelerini tek komutla geri yükleyin! Modüler, hızlı ve güçlü terminal kurulum aracı.

## ✨ v3.0 Yenilikleri

- 🎨 **7 Farklı Tema** - Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized
- 🖥️ **3 Terminal Desteği** - GNOME Terminal, Kitty, Alacritty
- 📝 **Logging Sistemi** - Tüm işlemler loglanır
- 📊 **Progress Bar** - Görsel ilerleme göstergesi
- 🏥 **Health Check** - Sistem sağlık kontrolü
- ⚙️ **Konfigürasyon** - Ayarlarınızı kaydedin
- 🔄 **Otomatik Güncelleme** - Yeni versiyonları otomatik kontrol
- 🐛 **Bug Fixes** - Kritik hatalar düzeltildi
- 🧩 **Modüler Yapı** - 3 dosyalı temiz mimari

## 🚀 Hızlı Başlangıç

```bash
# Repository'yi klonlayın
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format

# Çalıştırma izni verin
chmod +x *.sh

# Çalıştırın
./terminal-setup.sh
```

### Tek Komut Kurulum

```bash
# Tüm dosyaları indir ve çalıştır
wget -qO- https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh | bash
```

## 📦 İçindekiler

- [Özellikler](#-özellikler)
- [Desteklenen Temalar](#-desteklenen-temalar)
- [Kurulum](#-kurulum)
- [Kullanım](#-kullanım)
- [Komut Satırı Parametreleri](#-komut-satırı-parametreleri)
- [Konfigürasyon](#️-konfigürasyon)
- [Terminal Desteği](#-terminal-desteği)
- [Sorun Giderme](#-sorun-giderme)
- [Katkıda Bulunma](#-katkıda-bulunma)

## 🎯 Özellikler

### Kurulum Özellikleri

- ✅ Zsh + Oh My Zsh
- ✅ Powerlevel10k teması
- ✅ 7 farklı renk teması
- ✅ zsh-autosuggestions plugin
- ✅ zsh-syntax-highlighting plugin
- ✅ Otomatik font kurulumu (MesloLGS NF)
- ✅ Otomatik yedekleme
- ✅ Tek tıkla kaldırma

### Yönetim Özellikleri

- 📝 Detaylı logging (`~/.terminal-setup.log`)
- 📊 Progress bar ile görsel geri bildirim
- 🏥 Sistem sağlık kontrolü
- ⚙️ Konfigürasyon dosyası desteği
- 🔄 Otomatik güncelleme kontrolü
- 🐛 Debug modu
- 📦 Modüler yapı (kolay genişletilebilir)

## 🎨 Desteklenen Temalar

| Tema | Önizleme | Stil | Kontrast | Kullanım |
|------|----------|------|----------|----------|
| **Dracula** | ![#282A36](https://via.placeholder.com/20/282A36/000000?text=+) ![#F8F8F2](https://via.placeholder.com/20/F8F8F2/000000?text=+) | Mor/Pembe | Yüksek | Gece |
| **Nord** | ![#2E3440](https://via.placeholder.com/20/2E3440/000000?text=+) ![#D8DEE9](https://via.placeholder.com/20/D8DEE9/000000?text=+) | Mavi/Gri | Orta | Gündüz |
| **Gruvbox** | ![#282828](https://via.placeholder.com/20/282828/000000?text=+) ![#EBDBB2](https://via.placeholder.com/20/EBDBB2/000000?text=+) | Kahve/Turuncu | Orta | Retro |
| **Tokyo Night** | ![#1A1B26](https://via.placeholder.com/20/1A1B26/000000?text=+) ![#C0CAF5](https://via.placeholder.com/20/C0CAF5/000000?text=+) | Mavi/Mor | Yüksek | Modern |
| **Catppuccin** | ![#1E1E2E](https://via.placeholder.com/20/1E1E2E/000000?text=+) ![#CDD6F4](https://via.placeholder.com/20/CDD6F4/000000?text=+) | Pastel | Orta-Yüksek | Yumuşak |
| **One Dark** | ![#282C34](https://via.placeholder.com/20/282C34/000000?text=+) ![#ABB2BF](https://via.placeholder.com/20/ABB2BF/000000?text=+) | Atom-like | Orta | Kod |
| **Solarized** | ![#002B36](https://via.placeholder.com/20/002B36/000000?text=+) ![#839496](https://via.placeholder.com/20/839496/000000?text=+) | Klasik | Düşük | Klasik |

## 💻 Kurulum

### Gereksinimler

- Ubuntu 20.04+ / Debian 10+ / Linux Mint 20+
- Bash 4.0+
- İnternet bağlantısı
- sudo yetkisi

### Desteklenen Terminaller

- ✅ **GNOME Terminal** (tam destek)
- ✅ **Kitty** (tam destek)
- ✅ **Alacritty** (tam destek)
- ⚠️ **Tilix** (kısmi destek)
- ⚠️ **Konsole** (kısmi destek)
- ❌ **Diğerleri** (test edilmedi)

### Kurulum Adımları

1. **Repository'yi Klonlayın**
```bash
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
```

2. **Dosya İzinlerini Ayarlayın**
```bash
chmod +x terminal-setup.sh terminal-core.sh terminal-utils.sh
```

3. **Çalıştırın**
```bash
./terminal-setup.sh
```

### Alternatif: Manuel İndirme

```bash
# Dosyaları indirin
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-core.sh
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-utils.sh

# Çalıştırma izni verin
chmod +x *.sh

# Çalıştırın
./terminal-setup.sh
```

## 🎮 Kullanım

### İnteraktif Menü

Script'i çalıştırdığınızda karşınıza menü gelir:

```
╔══════════════════════════════════════════════════════════════╗
║       TERMİNAL ÖZELLEŞTİRME KURULUM ARACI v3.0.0           ║
╚══════════════════════════════════════════════════════════════╝

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

Yönetim:
  9) Sistem Sağlık Kontrolü
 10) Yedekleri Göster
 11) Tümünü Kaldır
 12) Ayarlar
  0) Çıkış
```

### 🎯 Komut Satırı Parametreleri

```bash
# Sistem sağlık kontrolü
./terminal-setup.sh --health

# Güncelleme kontrolü
./terminal-setup.sh --update

# Debug modu (sorun giderme için)
./terminal-setup.sh --debug

# Verbose modu (detaylı çıktı)
./terminal-setup.sh --verbose

# Versiyon bilgisi
./terminal-setup.sh --version

# Yardım
./terminal-setup.sh --help
```

## ⚙️ Konfigürasyon

### Ayarlar Dosyası

Ayarlarınız `~/.terminal-setup.conf` dosyasında saklanır:

```bash
# Terminal Setup Configuration
DEFAULT_THEME="dracula"      # Varsayılan tema
AUTO_UPDATE="false"          # Otomatik güncelleme
BACKUP_COUNT="5"             # Tutulacak yedek sayısı
```

### Ayarları Değiştirme

```bash
./terminal-setup.sh
# Menüden: 12 (Ayarlar)
```

Veya manuel olarak:

```bash
nano ~/.terminal-setup.conf
```

## 📂 Dosya Yapısı

### Script Dosyaları

```
Theme-after-format/
├── terminal-setup.sh       # Ana script (391 satır)
├── terminal-core.sh        # Kurulum fonksiyonları (523 satır)
├── terminal-utils.sh       # Yardımcı fonksiyonlar (487 satır)
├── VERSION                 # Versiyon numarası
├── README.md              # Bu dosya
└── KURULUM_REHBERI.md     # Detaylı rehber
```

### Oluşturulan Dosyalar

```
~/
├── .terminal-setup-backup/    # Yedekler
├── .terminal-setup.conf       # Ayarlar
├── .terminal-setup.log        # Log dosyası
├── .zshrc                     # Zsh konfigürasyonu
├── .p10k.zsh                  # Powerlevel10k ayarları
└── .oh-my-zsh/                # Oh My Zsh dizini
```

## 🏥 Sistem Sağlık Kontrolü

```bash
./terminal-setup.sh --health
```

Kontrol edilen öğeler:
- ✅ Disk alanı (>500MB)
- ✅ İnternet bağlantısı
- ✅ Gerekli paketler (git, curl, wget)
- ✅ Terminal emulator
- ✅ Zsh kurulumu
- ✅ Oh My Zsh kurulumu
- ✅ Font kurulumu
- ✅ Powerlevel10k kurulumu
- ✅ Pluginler
- ✅ Yedekler

Örnek çıktı:
```
╔════════════════════════════════════════════════╗
║         SİSTEM SAĞLIK KONTROLÜ                ║
╚════════════════════════════════════════════════╝

Disk alanı kontrolü... ✓ Yeterli (15432 MB)
İnternet bağlantısı... ✓ Aktif
Gerekli paketler... ✓ Tamam
Terminal emulator... ✓ gnome-terminal
Zsh... ✓ Kurulu (5.8.1)
Oh My Zsh... ✓ Kurulu
MesloLGS NF Font... ✓ Kurulu
Powerlevel10k... ✓ Kurulu
Zsh Pluginleri... ✓ Tamam (2/2)
Yedekler... ✓ Var (8 dosya)

═══════════════════════════════════════════════════
Toplam Kontrol: 10
✓ Başarılı: 10
⚠ Uyarı: 0
✗ Hata: 0
═══════════════════════════════════════════════════
✓ Sistem mükemmel durumda!
```

## 🔍 Sorun Giderme

### Yaygın Sorunlar

<details>
<summary><b>1. "Bağımlılık eksik" hatası</b></summary>

```bash
# Script otomatik kurulum önerecek
# Manuel kurulum:
sudo apt update
sudo apt install git curl wget
```
</details>

<details>
<summary><b>2. Fontlar gösterilmiyor</b></summary>

Terminal ayarlarından fontu değiştirin:
- GNOME Terminal: `Preferences → Profile → Custom Font → MesloLGS NF Regular`
- Kitty: `kitty.conf` dosyasına `font_family MesloLGS NF` ekleyin
- Alacritty: `alacritty.yml` dosyasına font ayarı ekleyin
</details>

<details>
<summary><b>3. Tema uygulanmıyor</b></summary>

```bash
# Terminal tipinizi kontrol edin
./terminal-setup.sh --health

# Log dosyasını inceleyin
tail -n 50 ~/.terminal-setup.log
```
</details>

<details>
<summary><b>4. Powerlevel10k wizard başlamıyor</b></summary>

```bash
# Manuel başlatma
p10k configure

# Veya
source ~/.zshrc
```
</details>

<details>
<summary><b>5. Güncelleme sorunu</b></summary>

```bash
# Manuel güncelleme
cd Theme-after-format
git pull origin main
chmod +x *.sh
```
</details>

### Log Dosyası İnceleme

```bash
# Son 50 satır
tail -n 50 ~/.terminal-setup.log

# Sadece hataları göster
grep ERROR ~/.terminal-setup.log

# Canlı izleme
tail -f ~/.terminal-setup.log
```

## 🎓 Kullanım Örnekleri

### Örnek 1: İlk Kurulum

```bash
# Format sonrası ilk kurulum
./terminal-setup.sh
# Menüden 1 seçin (Dracula ile tam kurulum)
# İşlem ~3 dakika sürer
# Terminal'i yeniden başlatın
```

### Örnek 2: Tema Değiştirme

```bash
# Mevcut kurulumdayken tema değiştir
./terminal-setup.sh
# Menüden 7 seçin
# Yeni tema seçin (ör: Nord)
# source ~/.zshrc
```

### Örnek 3: Sistem Kontrolü

```bash
# Kurulum öncesi kontrol
./terminal-setup.sh --health

# Her şey OK ise kuruluma başla
./terminal-setup.sh
```

### Örnek 4: Debug Modu

```bash
# Sorun yaşıyorsanız
./terminal-setup.sh --debug
# Detaylı çıktı göreceksiniz
# Log dosyasına da yazılır
```

## 📊 Performans

- **Kurulum Süresi**: 2-5 dakika (internet hızına bağlı)
- **Disk Kullanımı**: ~100 MB
- **RAM Kullanımı**: Minimal
- **Script Boyutu**: ~1400 satır (3 dosya)

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz!

1. Fork'layın
2. Feature branch oluşturun: `git checkout -b feature/yeni-ozellik`
3. Commit: `git commit -m 'Yeni özellik: Xyz'`
4. Push: `git push origin feature/yeni-ozellik`
5. Pull Request açın

### Geliştirme Rehberi

```bash
# Test için
./terminal-setup.sh --debug

# Shellcheck ile kontrol
shellcheck terminal-setup.sh terminal-core.sh terminal-utils.sh
```

## 📝 Değişiklik Günlüğü

### v3.0.0 (2024-10-02)
- ✨ Modüler yapı (3 dosya)
- ✨ 7 tema desteği
- ✨ Kitty ve Alacritty desteği
- ✨ Logging sistemi
- ✨ Progress bar
- ✨ Health check
- ✨ Konfigürasyon dosyası
- ✨ Otomatik güncelleme
- 🐛 Kritik bug'lar düzeltildi

### v2.1 (2024-09-30)
- 🐛 Sudo şifre sorunu düzeltildi
- 🐛 Font indirme iyileştirildi
- ✨ Bağımlılık kontrolü eklendi

### v2.0 (2024-09-28)
- ✨ Nord teması eklendi
- ✨ Yedekleme sistemi

### v1.0 (2024-09-25)
- 🎉 İlk sürüm

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🙏 Teşekkürler

Bu proje aşağıdaki harika projeleri kullanır:

- [Oh My Zsh](https://ohmyz.sh/) - Zsh konfigürasyon framework'ü
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh teması
- [Dracula Theme](https://draculatheme.com/) - Renk teması
- [Nord Theme](https://www.nordtheme.com/) - Renk teması
- [Gruvbox](https://github.com/morhetz/gruvbox) - Renk teması
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Renk teması
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Renk teması
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Komut önerileri
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Sözdizimi vurgulama

## 📞 İletişim

- **GitHub**: [@alibedirhan](https://github.com/alibedirhan)
- **Issues**: [Proje Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- **Discussions**: [GitHub Discussions](https://github.com/alibedirhan/Theme-after-format/discussions)

---

⭐ Beğendiyseniz yıldız vermeyi unutmayın!

Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)