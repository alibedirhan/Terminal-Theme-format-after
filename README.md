# 🎨 Terminal Setup - Ubuntu Terminal Özelleştirme Aracı

Modern, güçlü ve kullanımı kolay Ubuntu terminal özelleştirme sistemi. Zsh, Oh My Zsh, Powerlevel10k ve 14 profesyonel CLI aracı ile terminalinizi güçlendirin.

![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu-orange.svg)

## ✨ Özellikler

### 🎯 Tema Kurulumları (Tek Tıkla)
- 🧛 **Dracula** - Gotik ve şık
- 🌊 **Nord** - Mavi/Gri göze yumuşak
- 🍂 **Gruvbox** - Retro sıcak tonlar
- 🌃 **Tokyo Night** - Modern mavi/mor
- 🎀 **Catppuccin** - Pastel renkler
- 🌙 **One Dark** - Atom editör teması
- ☀️ **Solarized** - Bilimsel renk paleti

### ⚙️ Modüler Kurulum
- Zsh + Oh My Zsh (Tam paket: fontlar, pluginler, aliases)
- Powerlevel10k teması
- Renk teması değiştirme
- Plugin yönetimi
- 14 terminal aracı (tek menüde)
- Tmux kurulumu

### 🛠️ Terminal Araçları (14 Araç)
- **FZF** - Fuzzy finder
- **Zoxide** - Akıllı cd komutu
- **Exa/Eza** - Modern ls
- **Bat** - Syntax highlighted cat
- **Ripgrep** - Hızlı arama
- **fd** - Modern find
- **Delta** - Git diff viewer
- **Lazygit** - Git TUI
- **btop** - Sistem monitörü
- **dust** - Disk kullanımı
- **duf** - Disk bilgisi
- **procs** - Modern ps
- **atuin** - Shell history
- **tldr** - Basitleştirilmiş man pages

### 🔧 Yönetim
- Sistem sağlık kontrolü
- Otomatik teşhis ve çözüm
- Yedek yönetimi
- Tam kaldırma (19 adım)
- Ayarlar

### 📁 Aliases Desteği
- Mevcut `.aliases` dosyanızı otomatik tespit
- Örnek şablon dosyası
- Zsh uyumluluğu kontrolü

---

## 🚀 Hızlı Başlangıç

### Kurulum

```bash
# 1. Repository'yi klonla
git clone https://github.com/alibedirhan/Terminal-Theme-format-after.git
cd Terminal-Theme-format-after

# 2. Scripti çalıştırılabilir yap
chmod +x terminal-setup.sh

# 3. Başlat
./terminal-setup.sh
```

### İlk Kullanım

```bash
# Menüden seçim yap:
# 1-4: Tema ile tam kurulum (önerilen)
# 5: Zsh + Oh My Zsh (tam paket, tema sonra seçilir)
# 9: Terminal araçları (14 araç tek menüde)
```

---

## 📖 Kullanım

### Tam Kurulum (Tema Dahil)
```bash
./terminal-setup.sh
# Menü 1: Dracula Teması seç
# Tüm bileşenler otomatik kurulur
# P10k wizard açılır, görsel tercihleri seç
```

### Sadece Zsh Kurulumu
```bash
./terminal-setup.sh
# Menü 5: Zsh + Oh My Zsh seç
# Fontlar + Pluginler + Aliases otomatik
# Menü 7'den istediğin temayı seç
```

### Terminal Araçlarını Kurma
```bash
./terminal-setup.sh
# Menü 9: Terminal Araçları
# Seçenek 1: Hepsini kur (14 araç)
# Veya tek tek araç seç
```

### Kaldırma
```bash
./terminal-setup.sh
# Menü 14: Tümünü Kaldır
# 19 adımda her şeyi temizler
# Script hiç çalıştırılmamış gibi olur
```

---

## 🎯 Gereksinimler

- **İşletim Sistemi:** Ubuntu 20.04 veya üzeri
- **Internet:** Paket indirmeleri için
- **Sudo Yetkisi:** Paket kurulumları için
- **Disk Alanı:** ~500MB (tüm araçlar dahil)

---

## 🏗️ Proje Yapısı

```
Terminal-Theme-format-after/
├── terminal-setup.sh           # Ana script
├── terminal-ui.sh              # Görsel arayüz
├── terminal-assistant.sh       # Otomatik teşhis
├── core/
│   ├── terminal-base.sh        # Zsh, Oh My Zsh, P10k
│   ├── terminal-tools.sh       # 14 CLI aracı
│   └── terminal-config.sh      # Tema, tmux, kaldırma
├── utils/
│   ├── helpers.sh              # Logging sistemi
│   ├── system.sh               # Terminal detection
│   └── config.sh               # Backup, snapshot
├── themes/
│   ├── dracula.sh
│   ├── nord.sh
│   └── ... (7 tema)
└── aliases/
    └── .aliases                # Örnek alias dosyası
```

---

## 🔥 v4.3.0 Yenilikler

### ✨ Yeni Özellikler
- **Aliases şablon sistemi:** Örnek `.aliases` dosyası eklendi
- **Otomatik source:** Terminal araçları kurulumundan sonra `.zshrc` otomatik yükleniyor (opsiyonel)
- **Gelişmiş hata mesajları:** FZF ve Zoxide kurulumlarında detaylı log

### ✅ Düzeltmeler
- **FZF kurulum hatası:** `--all` ve `--no-bash` çelişkisi giderildi
- **Zoxide kurulum hatası:** Pipe sorunu çözüldü
- **Menü 5 eksiklikleri:** Fontlar, pluginler, aliases eklendi

### 📖 Dokümantasyon
- **Yeni README:** Tam güncelleme
- **CHANGELOG:** v4.3.0 için detaylı değişiklik listesi
- **Örnek .aliases:** Navigation, Git, sistem aliasları

---

## 🐛 Sorun Giderme

### FZF çalışmıyor
```bash
# ~/.zshrc'de olmalı:
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Manuel test:
fzf --version
```

### Zoxide çalışmıyor
```bash
# ~/.zshrc'de olmalı:
eval "$(zoxide init zsh)"

# PATH kontrolü:
echo $PATH | grep ".local/bin"
```

### P10k ikonları bozuk
```bash
# Terminal fontunu değiştir:
# GNOME Terminal → Preferences → MesloLGS NF Regular
```

### Renkleri göremiyorum
```bash
# Terminal'i kapat ve tekrar aç
# Veya:
source ~/.zshrc
```

---

## 📚 Dokümantasyon

- [Kurulum Rehberi](INSTALL.md)
- [Değişiklik Günlüğü](CHANGELOG.md)
- [Katkıda Bulunma](CONTRIBUTING.md)

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz!

```bash
# 1. Fork et
# 2. Feature branch oluştur
git checkout -b feature/amazing-feature

# 3. Commit et
git commit -m 'feat: amazing feature ekle'

# 4. Push et
git push origin feature/amazing-feature

# 5. Pull Request aç
```

---

## 📄 Lisans

MIT License - detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 💬 İletişim

- **GitHub:** [@alibedirhan](https://github.com/alibedirhan)
- **Repository:** [Terminal-Theme-format-after](https://github.com/alibedirhan/Terminal-Theme-format-after)
- **Issues:** [Sorun bildir](https://github.com/alibedirhan/Terminal-Theme-format-after/issues)

---

## ⭐ Yıldız Ver

Bu projeyi beğendiysen yıldız vermeyi unutma! ⭐

---

## 🙏 Teşekkürler

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [FZF](https://github.com/junegunn/fzf)
- Tüm katkıda bulunanlara 💙
