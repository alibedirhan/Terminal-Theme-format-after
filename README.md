# 🎨 Theme After Format

Terminal özelleştirmelerini format sonrası tek komutla geri yükleyin.

Format attıktan sonra terminal özelleştirmelerini tek tek kurmaktan sıkıldınız mı? Bu script size yardımcı olacak!

## ✨ Özellikler

**Theme After Format** ile:

- ✅ **Zsh + Oh My Zsh** - Güçlü shell ortamı
- 🎨 **Powerlevel10k** - Modern ve özelleştirilebilir tema
- 🌈 **7 Farklı Renk Teması** - Her zevke uygun seçenekler
- 🖥️ **Çoklu Terminal Desteği** - GNOME Terminal, Kitty, Alacritty
- 🚀 **Terminal Araçları** - FZF, Zoxide, Exa, Bat
- 🔧 **Tmux Entegrasyonu** - Temayla uyumlu tmux konfigürasyonu
- 🎯 **Syntax Highlighting** - Renkli komut vurgulama
- 💡 **Auto-suggestions** - Akıllı komut önerileri

### 🎯 Kurulum Özellikleri

- **İnteraktif Menü** - Kolay kullanım için menü sistemi
- **7 Tema Seçeneği** - Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized
- **Otomatik Yedekleme** - Mevcut ayarlarınızı güvenle yedekler
- **Modüler Kurulum** - İstediğiniz bileşenleri seçin
- **Güvenli Kaldırma** - Tek tıkla eski haline dönün
- **Hata Yönetimi** - İnternet, terminal türü ve bağımlılık kontrolleri
- **Progress Bar** - Görsel kurulum ilerlemesi
- **Health Check** - Sistem sağlık kontrolü

---

## 🚀 Hızlı Kurulum

### Yöntem 1: Doğrudan İndirme

```bash
# Script'i indir
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-core.sh
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-utils.sh

# Çalıştırma yetkisi ver
chmod +x terminal-setup.sh terminal-core.sh terminal-utils.sh

# Çalıştır
./terminal-setup.sh
```

### Yöntem 2: Git Clone

```bash
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
chmod +x terminal-setup.sh terminal-core.sh terminal-utils.sh
./terminal-setup.sh
```

---

## 📋 Kullanım

Script'i çalıştırdığınızda interaktif menü açılır:

```
╔══════════════════════════════════════════════════════════╗
║       TERMİNAL ÖZELLEŞTİRME KURULUM ARACI v3.1.0         ║
╚══════════════════════════════════════════════════════════╝

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
  0) Çıkış
```

### İlk Kez Kullanım

İlk kez kullanıyorsanız:
- **Seçenek 1-4**: Tam kurulum (istediğiniz tema ile)

Sadece temayı değiştirmek istiyorsanız:
- **Seçenek 7**: Renk teması değişikliği

### Kurulum Sonrası

1. Terminal'i kapatıp yeniden açın
2. Powerlevel10k yapılandırma wizard'ı otomatik başlayacak
3. Sorulara cevap vererek görünümü özelleştirin
4. Daha sonra `p10k configure` ile yeniden yapılandırabilirsiniz

---

## 🎨 Mevcut Temalar

### 1. 🧛 Dracula

Mor ve pembe tonları, yüksek kontrast.

**Renk Paleti:**
- Background: `#282A36`
- Foreground: `#F8F8F2`
- Vurgular: Mor, pembe, cyan

**Kimler İçin:**
- Yüksek kontrast seviyorsanız
- Canlı renkler hoşunuza gidiyorsa
- Gece çalışması yapıyorsanız

### 2. 🏔️ Nord

Mavi ve gri tonları, düşük kontrast.

**Renk Paleti:**
- Background: `#2E3440`
- Foreground: `#D8DEE9`
- Vurgular: Mavi, cyan, yeşil

**Kimler İçin:**
- Göz yorgunluğunu azaltmak istiyorsanız
- Soğuk tonları seviyorsanız
- Minimalist tasarım tercih ediyorsanız

### 3. 🌲 Gruvbox Dark

Retro görünüm, sıcak tonlar.

**Renk Paleti:**
- Background: `#282828`
- Foreground: `#EBDBB2`
- Vurgular: Turuncu, sarı, yeşil

**Kimler İçin:**
- Retro tasarım seviyorsanız
- Sıcak renk tonlarını tercih ediyorsanız
- Vim/Neovim kullanıcılarıysanız

### 4. 🌃 Tokyo Night

Modern, mavi/mor tonlar.

**Renk Paleti:**
- Background: `#1A1B26`
- Foreground: `#C0CAF5`
- Vurgular: Mavi, mor, cyan

**Kimler İçin:**
- Modern tasarım seviyorsanız
- VS Code kullanıcılarıysanız
- Mavi tonları tercih ediyorsanız

### 5. 🐱 Catppuccin

Pastel renkler, yumuşak tonlar.

**Renk Paleti:**
- Background: `#1E1E2E`
- Foreground: `#CDD6F4`
- Vurgular: Pastel mavi, pembe, yeşil

**Kimler İçin:**
- Pastel renkleri seviyorsanız
- Yumuşak bir görünüm istiyorsanız
- Estetik görünüm arıyorsanız

### 6. ⚛️ One Dark

Atom editor benzeri, dengeli renkler.

**Renk Paleti:**
- Background: `#282C34`
- Foreground: `#ABB2BF`
- Vurgular: Mavi, yeşil, kırmızı

**Kimler İçin:**
- Atom/VS Code kullanıcılarıysanız
- Dengeli kontrast istiyorsanız
- Genel amaçlı kullanım için

### 7. ☀️ Solarized Dark

Klasik, bilimsel olarak tasarlanmış renkler.

**Renk Paleti:**
- Background: `#002B36`
- Foreground: `#839496`
- Vurgular: Mavi, cyan, yeşil

**Kimler İçin:**
- Klasik tasarım seviyorsanız
- Göz sağlığını ön planda tutuyorsanız
- Düşük kontrast tercih ediyorsanız

---

## 💻 Terminal Desteği

| Terminal | Durum | Notlar |
|----------|-------|--------|
| GNOME Terminal | ✅ Tam Destek | Tüm özellikler |
| Kitty | ✅ Tam Destek | 7 tema destekleniyor |
| Alacritty | ✅ Tam Destek | 7 tema destekleniyor |
| Tilix | ⚠️ Kısmi Destek | Renk temaları çalışmayabilir |
| Konsole | ⚠️ Kısmi Destek | Renk temaları çalışmayabilir |
| Diğerleri | ❌ Test Edilmedi | Zsh ve P10k çalışır |

**Not:** Renk temaları (7 tema) GNOME Terminal, Kitty ve Alacritty'de tam desteklenir. Zsh ve Powerlevel10k tüm terminal emulatorlerde çalışır.

---

## 🔧 Sistem Gereksinimleri

### İşletim Sistemi
- Ubuntu 20.04+ / Debian 10+ / Linux Mint 20+
- Bash 4.0+

### Zorunlu Paketler
- `git` - Versiyon kontrol sistemi
- `curl` - Dosya indirme
- `wget` - Dosya indirme
- İnternet bağlantısı
- `sudo` yetkisi

### Opsiyonel Paketler
- `gsettings` - GNOME Terminal için renk temaları
- `fc-cache` - Font cache güncellemesi

---

## 💾 Yedekleme Sistemi

Script her kurulumda otomatik yedek oluşturur:

**Yedeklenen Dosyalar:**
- `~/.bashrc`
- `~/.zshrc`
- `~/.p10k.zsh`
- `~/.tmux.conf`
- Mevcut shell bilgisi
- GNOME Terminal profil ID'si

**Yedek Konumu:** `~/.terminal-setup-backup/`

**Yedek Formatı:** `dosya_20240102_153045`

---

## 🗑️ Kaldırma

```bash
./terminal-setup.sh
# Menüden "13) Tümünü Kaldır" seçin
```

Bu işlem:
- ✅ Oh My Zsh'yi kaldırır
- ✅ Zsh konfigürasyonlarını siler
- ✅ Bash'e geri döner
- ✅ Yedekten dosyaları geri yükler
- ✅ İnteraktif olarak araçları kaldırır (FZF, Zoxide, vs.)

---

## 🛠️ Terminal Araçları

Script aşağıdaki modern terminal araçlarını kurabilir:

### 1. FZF - Fuzzy Finder
Dosya, komut ve history'de hızlı arama
```bash
# Kullanım
Ctrl+R   # Komut geçmişinde arama
Ctrl+T   # Dosya arama
Alt+C    # Dizin değiştirme
```

### 2. Zoxide - Akıllı cd
En çok kullandığınız dizinlere hızlıca atlama
```bash
z projects      # ~/Documents/projects'e git
z config        # ~/.config'e git
```

### 3. Exa - Modern ls
Renkli ve icon'lu dosya listeleme
```bash
ls      # İconlu listeleme
ll      # Detaylı listeleme
la      # Gizli dosyalarla
lt      # Tree görünümü
```

### 4. Bat - cat with syntax
Syntax highlighting ile dosya görüntüleme
```bash
cat file.js     # Renkli ve satır numaralı
```

---

## ❓ Sık Sorulan Sorular

### S: Format sonrası kullanabilir miyim?
**C:** Evet, tam olarak bunun için tasarlandı. Sistemi kurduktan sonra tek komutla tüm özelleştirmeleri geri yükleyin.

### S: Mevcut ayarlarım kaybolur mu?
**C:** Hayır, script otomatik yedekleme yapar. İsterseniz geri dönebilirsiniz.

### S: Root olarak çalıştırmalı mıyım?
**C:** Hayır! Normal kullanıcı olarak çalıştırın. Gerektiğinde sudo isteyecektir.

### S: Her iki temayı da deneyebilir miyim?
**C:** Evet, istediğiniz zaman tema değiştirebilirsiniz (Menü seçenek 7).

### S: Pluginler ne işe yarar?
**C:** 
- `zsh-autosuggestions`: Komut önerileri
- `zsh-syntax-highlighting`: Sözdizimi renklendirme
- `colored-man-pages`: Renkli man sayfaları

### S: Disk alanı ne kadar?
**C:** Yaklaşık 50-100 MB (Oh My Zsh, tema, fontlar dahil)

### S: Hangi terminal emulator kullanmalıyım?
**C:** En iyi deneyim için GNOME Terminal, Kitty veya Alacritty önerilir.

---

## 🔄 Güncelleme

```bash
cd Theme-after-format
git pull origin main
./terminal-setup.sh
# Veya menüden "14) Ayarlar" → "4) Güncellemeleri Kontrol Et"
```

---

## 🧹 Manuel Kaldırma

```bash
# Oh My Zsh kaldırma
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zsh_history ~/.p10k.zsh

# Bash'e geri dön
chsh -s $(which bash)

# Zsh paketini kaldır (opsiyonel)
sudo apt remove zsh
sudo apt autoremove
```

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

1. Fork'layın
2. Feature branch: `git checkout -b feature/YeniOzellik`
3. Commit: `git commit -m 'Yeni özellik eklendi'`
4. Push: `git push origin feature/YeniOzellik`
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 🙏 Teşekkürler

Bu proje şu harika projeleri kullanır:

- [Oh My Zsh](https://ohmyz.sh/) - Zsh konfigürasyon framework'ü
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh teması
- [Dracula Theme](https://draculatheme.com/) - Renk teması
- [Nord Theme](https://www.nordtheme.com/) - Renk teması
- [Gruvbox](https://github.com/morhetz/gruvbox) - Renk teması
- [Tokyo Night](https://github.com/tokyo-night/tokyo-night-vscode-theme) - Renk teması
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Renk teması
- [One Dark](https://github.com/atom/one-dark-syntax) - Renk teması
- [Solarized](https://ethanschoonover.com/solarized/) - Renk teması
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Komut önerileri
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Sözdizimi vurgulama
- [FZF](https://github.com/junegunn/fzf) - Fuzzy finder
- [Zoxide](https://github.com/ajeetdsouza/zoxide) - Akıllı cd
- [Exa](https://github.com/ogham/exa) - Modern ls
- [Bat](https://github.com/sharkdp/bat) - Modern cat

---

## 📞 İletişim

- GitHub: [@alibedirhan](https://github.com/alibedirhan)
- Issues: [Proje Issues](https://github.com/alibedirhan/Theme-after-format/issues)

---

## ⭐ Destek

Beğendiyseniz yıldız vermeyi unutmayın!

Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)