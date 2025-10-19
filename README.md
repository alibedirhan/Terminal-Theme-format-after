# 🎨 Terminal Customization Suite v3.2.9

> Format sonrası terminal özelleştirmelerini tek komutla geri yükleyin - Artık **7 tema** ve **akıllı asistan** ile!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.2.1-blue.svg)](https://github.com/alibedirhan/Theme-after-format/releases)
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
- ✅ **Terminal Araçları** - FZF, Zoxide, Exa, Bat
- ✅ **Tmux Desteği** - Multiplexer ile tema entegrasyonu
- 🤖 **Akıllı Sorun Giderme Asistanı** - Otomatik teşhis ve çözüm
- 🏥 **Sistem Sağlık Kontrolü** - Kurulum öncesi tarama
- 💾 **Otomatik Yedekleme** - Güvenli geri dönüş
- 🔄 **Otomatik Güncelleme** - Her zaman en son versiyon
- 🔒 **Lock Mekanizması** - Çakışma önleme

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

## 📋 Ana Menü

Script'i çalıştırdığınızda interaktif menü açılır:

```
╔═══════════════════════════════════════════════════════════╗
║    Terminal Customization Suite v3.2.9                   ║
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
│  9 │ 🛠️  Terminal Araçları (FZF, Zoxide, Exa, Bat)      │
│ 10 │ 📺 Tmux Kurulumu                                    │
└──────────────────────────────────────────────────────────┘

┌───────────────────── YÖNETİM ───────────────────────────┐
│ 11 │ 🏥 Sistem Sağlık Kontrolü                           │
│ 12 │ 🤖 Akıllı Sorun Giderme Asistanı                    │
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
# Menüden 1-4 arası tema seçin (Tam kurulum)
# Terminal'i kapatıp yeniden açın
# Powerlevel10k wizard otomatik başlar
```

### Sadece Tema Değiştir
```bash
./terminal-setup.sh
# Menüden 7'yi seçin
# İstediğiniz temayı seçin
# source ~/.zshrc
```

### Terminal Araçları Ekle
```bash
./terminal-setup.sh
# Menüden 9'u seçin
# FZF, Zoxide, Exa, Bat kurulur
```

### Sorun Giderme
```bash
./terminal-setup.sh
# Menüden 12'yi seçin (Akıllı Asistan)
# Veya 11'i seçin (Sistem Sağlık Kontrolü)
```

## 🎨 Tema Detayları

### Dracula
- **Palet**: Mor, Pembe, Cyan
- **Arka Plan**: `#282A36`
- **Ön Plan**: `#F8F8F2`
- **Kimler İçin**: Yüksek kontrast sevenler, gece çalışması

### Nord
- **Palet**: Mavi, Gri, Cyan
- **Arka Plan**: `#2E3440`
- **Ön Plan**: `#D8DEE9`
- **Kimler İçin**: Göz yorgunluğunu azaltmak, minimalist tasarım

### Gruvbox
- **Palet**: Turuncu, Sarı, Yeşil
- **Arka Plan**: `#282828`
- **Ön Plan**: `#EBDBB2`
- **Kimler İçin**: Retro sevenler, sıcak tonları tercih edenler

### Tokyo Night
- **Palet**: Mavi, Mor, Cyan
- **Arka Plan**: `#1A1B26`
- **Ön Plan**: `#C0CAF5`
- **Kimler İçin**: Modern tasarım sevenler

### Catppuccin
- **Palet**: Pastel tonlar
- **Arka Plan**: `#1E1E2E`
- **Ön Plan**: `#CDD6F4`
- **Kimler İçin**: Soft renkler sevenler

### One Dark
- **Palet**: Atom editor renkleri
- **Arka Plan**: `#282C34`
- **Ön Plan**: `#ABB2BF`
- **Kimler İçin**: VS Code/Atom kullanıcıları

### Solarized
- **Palet**: Klasik düşük kontrast
- **Arka Plan**: `#002B36`
- **Ön Plan**: `#839496`
- **Kimler İçin**: Göz sağlığı önceliği olanlar

## 🛠️ Terminal Araçları

### FZF - Fuzzy Finder
```bash
# Dosya ara
Ctrl+T

# Komut geçmişinde ara
Ctrl+R

# Dizin değiştir
Alt+C
```

### Zoxide - Akıllı cd
```bash
# En çok kullanılan dizine git
z projects

# Etkileşimli seçim
zi
```

### Exa - Modern ls
```bash
# Renkli listeleme
ls

# Detaylı + icons
ll

# Tüm dosyalar
la

# Tree görünümü
lt
```

### Bat - cat with syntax
```bash
# Syntax highlighting ile göster
cat dosya.sh
```

## 📦 Kurulum Detayları

### Gereksinimler
- Ubuntu 20.04+ / Debian 10+ / Linux Mint 20+
- Bash 4.0+
- İnternet bağlantısı
- sudo yetkisi

### Kurulum Adımları
1. **Bağımlılık Kontrolü**: git, curl, wget
2. **Zsh Kurulumu**: En güncel versiyon
3. **Oh My Zsh**: Framework kurulumu
4. **Powerlevel10k**: Tema motoru
5. **Fontlar**: MesloLGS NF font ailesi
6. **Pluginler**: Auto-suggestions, Syntax highlighting
7. **Tema Uygulama**: Seçilen renk teması
8. **Shell Değiştirme**: Zsh'i varsayılan yap

### Yedekleme
Script otomatik yedekler:
- `~/.bashrc`
- `~/.zshrc`
- `~/.p10k.zsh`
- `~/.tmux.conf`
- GNOME Terminal profil ayarları
- Aktif shell bilgisi

**Yedek Konumu**: `~/.terminal-setup/backups/`

## 🤖 Akıllı Asistan Özellikleri

### Kurulum Öncesi Tarama
- Çakışan shell konfigürasyonları
- Önceki başarısız kurulum kalıntıları
- Terminal emulator uyumluluğu
- Locale sorunları
- Disk alanı kontrolü
- APT kilit kontrolü

### Sorun Giderme Sihirbazı
1. **Başlangıç Hatası** - Sudo, internet, dosya kontrolleri
2. **Yarım Kalmış Kurulum** - Hangi adımda kaldığını tespit
3. **Görsel Değişiklik Yok** - Shell, tema, font kontrolleri
4. **Renkler/Fontlar Bozuk** - Terminal uyumluluk analizi
5. **Shell Değişmedi** - Kapsamlı shell kontrolü
6. **Geri Alma** - Güvenli rollback işlemleri
7. **Otomatik Teşhis** - 7 adımlı tam sistem analizi

## ⚙️ Gelişmiş Özellikler

### Komut Satırı Parametreleri
```bash
./terminal-setup.sh --health     # Sistem sağlık kontrolü
./terminal-setup.sh --scan       # Kurulum öncesi tarama
./terminal-setup.sh --update     # Güncellemeleri kontrol et
./terminal-setup.sh --debug      # Debug modu
./terminal-setup.sh --verbose    # Detaylı çıktı
./terminal-setup.sh --version    # Versiyon bilgisi
./terminal-setup.sh --help       # Yardım
```

### Yapılandırma Dosyası
Konum: `~/.terminal-setup/config/settings.conf`

```bash
DEFAULT_THEME="dracula"
AUTO_UPDATE="true"
BACKUP_COUNT="5"
```

### Log Sistemi
Konum: `~/.terminal-setup/logs/terminal-setup.log`

- Thread-safe yazma
- Otomatik rotasyon (son 1000 satır)
- Debug, Info, Warning, Error seviyeleri

## 🔧 Sorun Giderme

### Font Simgeleri Görünmüyor
**Çözüm:**
```bash
# Terminal Preferences → Profile → Custom Font
# "MesloLGS NF Regular" seçin
```

### Tema Uygulanmadı
**Çözüm:**
```bash
source ~/.zshrc
# veya
exec zsh
```

### Shell Değişmedi
**Çözüm:**
```bash
# Manuel shell değiştir
sudo chsh -s $(which zsh) $USER

# Oturumu kapat ve tekrar gir
gnome-session-quit --logout
```

### Powerlevel10k Yavaş
**Çözüm:**
```bash
# Performans analizi
p10k debug

# Instant prompt devre dışı
nano ~/.zshrc
# Instant prompt bloğunu yoruma al
```

## 📚 SSS

**S: Format sonrası kullanabilir miyim?**  
C: Evet, tam olarak bunun için tasarlandı. Tek komutla tüm özelleştirmeleri geri yükleyin.

**S: Mevcut ayarlarım kaybolur mu?**  
C: Hayır, script otomatik yedekleme yapar. İsterseniz geri dönebilirsiniz.

**S: Root olarak çalıştırmalı mıyım?**  
C: Hayır! Normal kullanıcı olarak çalıştırın. Gerektiğinde sudo isteyecektir.

**S: Temaları karıştırabilir miyim?**  
C: Evet, istediğiniz zaman tema değiştirebilirsiniz (Menü → 7).

**S: Tmux ile tema nasıl çalışır?**  
C: Menü → 10 ile Tmux kurun, tema otomatik entegre edilir.

**S: Disk alanı ne kadar?**  
C: ~100-150 MB (Oh My Zsh, tema, fontlar, araçlar dahil)

**S: Hangi Linux dağıtımları destekleniyor?**  
C: Ubuntu 20.04+, Debian 10+, Linux Mint 20+, Pop!_OS 20.04+

**S: Terminal araçları opsiyonel mi?**  
C: Evet, Menü → 9 ile isteğe bağlı kurabilirsiniz.

## 🔄 Güncelleme

### Otomatik
```bash
# Ayarlar → Otomatik Güncelleme: Açık
# Her çalıştırmada kontrol edilir
```

### Manuel
```bash
cd Theme-after-format
git pull origin main
./terminal-setup.sh
```

## 🗑️ Kaldırma

### Tam Kaldırma
```bash
./terminal-setup.sh
# Menü → 14: Tümünü Kaldır

# Veya zorunlu mod:
./terminal-setup.sh
# Sorun Giderme → Geri Alma
```

### Manuel Kaldırma
```bash
# Oh My Zsh kaldır
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zsh_history ~/.p10k.zsh

# Bash'e dön
chsh -s $(which bash)

# Zsh paketi (opsiyonel)
sudo apt remove zsh
sudo apt autoremove
```

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

### Katkı Süreci
1. Fork'layın
2. Feature branch: `git checkout -b feature/YeniOzellik`
3. Commit: `git commit -m 'Yeni özellik eklendi'`
4. Push: `git push origin feature/YeniOzellik`
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🙏 Teşekkürler

Bu proje şu harika projeleri kullanır:

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh teması
- [Dracula Theme](https://draculatheme.com/)
- [Nord Theme](https://www.nordtheme.com/)
- [Gruvbox Theme](https://github.com/morhetz/gruvbox)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [One Dark Theme](https://github.com/atom/atom/tree/master/packages/one-dark-ui)
- [Solarized](https://ethanschoonover.com/solarized/)
- [FZF](https://github.com/junegunn/fzf)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [Exa](https://github.com/ogham/exa)
- [Bat](https://github.com/sharkdp/bat)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

## 📞 İletişim

- **GitHub**: [@alibedirhan](https://github.com/alibedirhan)
- **Issues**: [Proje Issues](https://github.com/alibedirhan/Theme-after-format/issues)

---

⭐ **Beğendiyseniz yıldız vermeyi unutmayın!**

Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)