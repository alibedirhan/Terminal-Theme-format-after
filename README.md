# 🎨 Terminal Customization Suite v3.3.0

> Format sonrası terminal özelleştirmelerini tek komutla geri yükleyin - Artık **7 tema**, **modüler yapı** ve **akıllı asistan** ile!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.3.0-blue.svg)](https://github.com/alibedirhan/Theme-after-format/releases)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://github.com/alibedirhan/Theme-after-format)

Format attıktan sonra terminal özelleştirmelerini tek tek kurmaktan sıkıldınız mı? Bu suite tam size göre!

## ✨ Özellikler

### 🎨 7 Profesyonel Tema
- **Dracula** - Mor/Pembe tonları, yüksek kontrast
- **Nord** - Mavi/Gri tonları, göze yumuşak
- **Gruvbox** - Retro, sıcak tonlar
- **Tokyo Night** - Modern mavi/mor tonlar
- **Catppuccin** - Pastel renkler
- **One Dark** - Atom editor benzeri
- **Solarized** - Klasik, düşük kontrast

### 🚀 Gelişmiş Özellikler
- ✅ **Zsh + Oh My Zsh** - Güçlü shell deneyimi
- ✅ **Powerlevel10k** - Hızlı ve özelleştirilebilir tema
- ✅ **Akıllı Plugins** - Auto-suggestions, Syntax Highlighting
- ✅ **Terminal Araçları** - FZF, Zoxide, Exa, Bat (14 araç)
- ✅ **Tmux Desteği** - Multiplexer ile tema entegrasyonu
- 🤖 **Akıllı Sorun Giderme Asistanı** - Otomatik teşhis ve çözüm
- 🏥 **Sistem Sağlık Kontrolü** - Kurulum öncesi tarama
- 💾 **Otomatik Yedekleme** - Güvenli geri dönüş
- 🔄 **Otomatik Güncelleme** - Her zaman en son versiyon
- 🏗️ **Modüler Mimari** - Kolay bakım ve genişletme

### 🖥️ Çoklu Terminal Desteği
- ✅ **GNOME Terminal** (Tam Destek)
- ✅ **Kitty** (Tam Destek)
- ✅ **Alacritty** (Tam Destek)
- ⚠️ Tilix (Kısmi Destek)
- ⚠️ Konsole (Kısmi Destek)

## 🚀 Hızlı Başlangıç

### Tek Satır Kurulum
```bash
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh && chmod +x install.sh && ./install.sh
```

### Manuel Kurulum
```bash
# Repository'yi klonla
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format

# Çalıştırma yetkisi ver
chmod +x terminal-setup.sh

# Başlat
./terminal-setup.sh
```

## 📁 Proje Yapısı

v3.3.0'da **tamamen modüler** bir yapıya geçildi:

```
terminal-setup/
├── core/                          # Ana kurulum modülleri
│   ├── terminal-base.sh           # Zsh, Oh My Zsh, P10k, plugins (612 satır)
│   ├── terminal-tools.sh          # 14 CLI aracı (977 satır)
│   └── terminal-config.sh         # Tmux, tema uygulama (695 satır)
│
├── utils/                         # Yardımcı fonksiyonlar
│   ├── helpers.sh                 # Logging, error handling (594 satır)
│   ├── system.sh                  # Terminal detection, sistem kontrolleri (175 satır)
│   └── config.sh                  # Config, backup, snapshot (536 satır)
│
├── themes/                        # Her tema ayrı dosyada
│   ├── dracula.sh                 # Dracula tema tanımları
│   ├── nord.sh                    # Nord tema tanımları
│   ├── gruvbox.sh                 # Gruvbox tema tanımları
│   ├── tokyo-night.sh             # Tokyo Night tema tanımları
│   ├── catppuccin.sh              # Catppuccin tema tanımları
│   ├── one-dark.sh                # One Dark tema tanımları
│   └── solarized.sh               # Solarized tema tanımları
│
├── terminal-setup.sh              # Ana orkestrasyon (28K)
├── terminal-ui.sh                 # Kullanıcı arayüzü (34K)
├── terminal-assistant.sh          # Sorun giderme asistanı (37K)
│
└── docs/                          # Dokümantasyon
    ├── README.md                  # Bu dosya
    ├── INSTALL.md                 # Detaylı kurulum
    ├── CONTRIBUTING.md            # Katkı rehberi
    ├── CHANGELOG.md               # Değişiklik geçmişi
    └── ...
```

### 💡 Modüler Yapının Avantajları

- ✅ **Her dosya <1000 satır** - Kolay okunabilir ve bakımı yapılabilir
- ✅ **Açık sorumluluklar** - Her modül tek bir görevi yapar
- ✅ **Kolay genişletme** - Yeni tema/araç eklemek çok basit
- ✅ **Git diff'leri** - Değişiklikler daha görünür
- ✅ **Hata ayıklama** - Sorunları bulmak daha kolay

## 📋 Ana Menü

Script'i çalıştırdığınızda interaktif menü açılır:

```
╔═══════════════════════════════════════════════════════════╗
║    Terminal Customization Suite v3.3.0                   ║
╚═══════════════════════════════════════════════════════════╝

┌──────────────────── TAM KURULUM ────────────────────────┐
│  1 │ 🎨 Dracula       │ Mor/Pembe - Yüksek Kontrast      │
│  2 │ 🌊 Nord          │ Mavi/Gri - Göze Yumuşak          │
│  3 │ 🍂 Gruvbox       │ Retro Sıcak Tonlar               │
│  4 │ 🌃 Tokyo Night   │ Modern Mavi/Mor                  │
└──────────────────────────────────────────────────────────┘

┌────────────────── MODÜLER KURULUM ──────────────────────┐
│  5 │ ⚙️  Zsh + Oh My Zsh                                 │
│  6 │ ✨ Powerlevel10k Teması                             │
│  7 │ 🎨 Renk Teması Değiştir                             │
│  8 │ 🔌 Pluginler                                        │
│  9 │ 🛠️  Terminal Araçları (Gelişmiş Menü)              │
│ 10 │ 📺 Tmux Kurulumu                                    │
└──────────────────────────────────────────────────────────┘

┌───────────────────── YÖNETİM ───────────────────────────┐
│ 11 │ 🏥 Sistem Sağlık Kontrolü                           │
│ 12 │ 🔧 Otomatik Teşhis                                   │
│ 13 │ 💾 Yedekleri Göster                                 │
│ 14 │ 🗑️  Tümünü Kaldır                                   │
│ 15 │ ⚙️  Ayarlar                                         │
│  0 │ 🚪 Çıkış                                            │
└──────────────────────────────────────────────────────────┘
```

## 🎯 Kullanım Senaryoları

### İlk Kez Kullanım
```bash
./terminal-setup.sh
# Seçenek 1 veya 2: Tam kurulum (Dracula/Nord)
```

### Sadece Tema Değiştirme
```bash
./terminal-setup.sh
# Seçenek 7: Renk Teması Değiştir
# 7 tema arasından seçim yapın
```

### Terminal Araçları Kurulumu
```bash
./terminal-setup.sh
# Seçenek 9: Terminal Araçları
# 14 modern CLI aracı:
# - fzf (fuzzy finder)
# - zoxide (smart cd)
# - exa (modern ls)
# - bat (syntax highlighting cat)
# - ripgrep, fd, delta, ve daha fazlası!
```

### Sorun mu Var?
```bash
./terminal-setup.sh
# Seçenek 11: Sistem Sağlık Kontrolü
# Seçenek 12: Otomatik Teşhis
```

## 🛠️ CLI Araçları

Seçenek 9'dan erişilen **14 modern CLI aracı**:

| Araç | Açıklama | Alternatif |
|------|----------|-----------|
| **fzf** | Fuzzy finder | - |
| **zoxide** | Akıllı cd | cd, autojump |
| **exa** | Modern ls | ls, lsd |
| **bat** | Syntax highlighting cat | cat, less |
| **ripgrep** | Hızlı grep | grep, ag |
| **fd** | Modern find | find |
| **delta** | Git diff enhancer | diff |
| **dust** | Modern du | du, ncdu |
| **duf** | Modern df | df |
| **procs** | Modern ps | ps, htop |
| **sd** | Modern sed | sed |
| **bottom** | System monitor | top, htop |
| **tldr** | Simplified man | man |
| **httpie** | HTTP client | curl, wget |

## 🎨 Tema Önizlemeleri

### Dracula
![Dracula Theme](https://draculatheme.com/static/img/screenshots/terminal.png)
- **Renk Paleti**: Mor (#BD93F9), Pembe (#FF79C6), Yeşil (#50FA7B)
- **Kullanım**: Gece çalışması, yüksek kontrast severler

### Nord
![Nord Theme](https://www.nordtheme.com/assets/images/ports/terminals/xtermjs.png)
- **Renk Paleti**: Açık mavi (#88C0D0), Kar beyazı (#ECEFF4)
- **Kullanım**: Gündüz çalışması, göz dostu

### Gruvbox
- **Renk Paleti**: Kahve (#282828), Turuncu (#FE8019), Sarı (#FABD2F)
- **Kullanım**: Retro görünüm, sıcak tonlar

### Tokyo Night
- **Renk Paleti**: Lacivert (#1A1B26), Mavi (#7AA2F7), Mor (#BB9AF7)
- **Kullanım**: Modern, koyu tema

## 🔧 Yapılandırma

### Powerlevel10k'yi Yeniden Yapılandırma
```bash
p10k configure
```

### Tema Değiştirme (Hızlı)
```bash
./terminal-setup.sh
# Seçenek 7 → Tema seç → 5 saniye!
```

### Plugin Ekleme
```bash
# ~/.zshrc dosyasını düzenle
nano ~/.zshrc

# plugins satırına ekle:
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  # yeni plugin buraya
)

# Yükle
source ~/.zshrc
```

### Ayarlar
```bash
./terminal-setup.sh
# Seçenek 15: Ayarlar
# - Varsayılan tema
# - Otomatik güncelleme
# - Yedek sayısı
```

## 📊 Performans

### Kurulum Süreleri
- **Tam Kurulum**: ~2-3 dakika
- **Sadece Tema**: ~5 saniye
- **Terminal Araçları**: ~1-2 dakika

### Disk Kullanımı
- **Oh My Zsh**: ~50 MB
- **Fontlar**: ~20 MB
- **Toplam**: ~100 MB

## 🔒 Güvenlik

- ✅ **Root kontrolü** - Script root olarak çalışmaz
- ✅ **Otomatik yedekleme** - Her işlem öncesi
- ✅ **Güvenli cleanup** - Hata durumunda temizlik
- ✅ **HTTPS indirme** - Tüm kaynaklar güvenli
- ✅ **Input validation** - Tüm kullanıcı girdileri kontrol edilir

Detaylı güvenlik bilgisi için: [SECURITY.md](SECURITY.md)

## 🐛 Sorun Giderme

### Karakterler Bozuk Görünüyor
**Çözüm**: Terminal ayarlarından **MesloLGS NF** fontunu seçin.

### Tema Uygulanmadı
**Çözüm**: 
```bash
./terminal-setup.sh
# Seçenek 11: Sistem Sağlık Kontrolü
```

### Zsh Çok Yavaş
**Çözüm**:
```bash
p10k configure
# Instant prompt'u aktif tutun
```

Daha fazla çözüm için: [INSTALL.md](INSTALL.md)

## 📚 Dokümantasyon

- [📖 INSTALL.md](INSTALL.md) - Detaylı kurulum rehberi
- [🤝 CONTRIBUTING.md](CONTRIBUTING.md) - Katkı rehberi
- [📝 CHANGELOG.md](CHANGELOG.md) - Değişiklik geçmişi
- [⚡ HIZLI_REFERANS.md](HIZLI_REFERANS.md) - Hızlı komutlar
- [🏗️ PROJE_OZETI.md](PROJE_OZETI.md) - Teknik detaylar
- [🔒 SECURITY.md](SECURITY.md) - Güvenlik politikası

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

### Katkı Alanları
- 🐛 Bug raporları
- ✨ Yeni özellik önerileri
- 🎨 Yeni tema ekleme
- 📝 Dokümantasyon iyileştirmeleri
- 🌍 Çeviri

## 📈 Versiyon Geçmişi

- **v3.3.0** (2024-10-21) - Modüler mimari, 13 dosyaya bölünme
- **v3.2.7** (2024-10) - 7 tema desteği, akıllı asistan
- **v3.2.4** (2024-10) - Terminal araçları menüsü
- **v3.0.0** (2024-09) - İlk stabil sürüm

Detaylı geçmiş için: [CHANGELOG.md](CHANGELOG.md)

## 🎯 Yol Haritası

### v3.4 (Yakında)
- [ ] macOS desteği
- [ ] Daha fazla tema (Ayu, Material)
- [ ] Tema önizleme
- [ ] GUI arayüzü (whiptail)

### v4.0 (Uzun Vadeli)
- [ ] Cross-platform (macOS, WSL)
- [ ] Web UI
- [ ] Topluluk tema paylaşımı

## 📞 Destek

- 🐛 **Bug Raporları**: [Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- 💬 **Soru & Cevap**: [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions)
- 📧 **E-posta**: [Profilinizden]

## 📄 Lisans

Bu proje [MIT License](LICENSE) altında lisanslanmıştır.

## 🙏 Teşekkürler

Bu proje şu harika açık kaynak projelerden ilham almıştır:
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Dracula Theme](https://draculatheme.com/)
- [Nord Theme](https://www.nordtheme.com/)

## ⭐ Yıldız Geçmişi

[![Star History Chart](https://api.star-history.com/svg?repos=alibedirhan/Theme-after-format&type=Date)](https://star-history.com/#alibedirhan/Theme-after-format&Date)

---

**Beğendiyseniz ⭐ vermeyi unutmayın!**

Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)
