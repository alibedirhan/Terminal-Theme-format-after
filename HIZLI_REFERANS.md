# Terminal Setup v3.0 - Hızlı Referans Kılavuzu

## ⚡ Hızlı Başlangıç

```bash
# Kurulum
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
chmod +x *.sh
./terminal-setup.sh

# Tek satır kurulum
wget -qO- https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh | bash
```

## 🎯 Komut Referansı

### Ana Komutlar

| Komut | Açıklama |
|-------|----------|
| `./terminal-setup.sh` | Normal mod ile başlat |
| `./terminal-setup.sh --health` | Sistem kontrolü |
| `./terminal-setup.sh --update` | Güncelleme kontrolü |
| `./terminal-setup.sh --debug` | Debug modu |
| `./terminal-setup.sh --verbose` | Detaylı çıktı |
| `./terminal-setup.sh --version` | Versiyon bilgisi |
| `./terminal-setup.sh --help` | Yardım |

### Test ve Doğrulama

```bash
# Tüm testleri çalıştır
./test.sh

# Syntax kontrolü
bash -n terminal-setup.sh

# ShellCheck analizi
shellcheck *.sh
```

## 📋 Menü Referansı

### Ana Menü (0-12)

```
1  → Dracula ile tam kurulum
2  → Nord ile tam kurulum
3  → Gruvbox ile tam kurulum
4  → Tokyo Night ile tam kurulum
5  → Sadece Zsh + Oh My Zsh
6  → Sadece Powerlevel10k
7  → Sadece tema değiştir
8  → Sadece pluginler
9  → Sağlık kontrolü
10 → Yedekleri göster
11 → Tümünü kaldır
12 → Ayarlar
0  → Çıkış
```

### Tema Menüsü (0-7)

```
1 → Dracula      (Mor/Pembe, Yüksek kontrast)
2 → Nord         (Mavi/Gri, Orta kontrast)
3 → Gruvbox      (Kahve/Turuncu, Retro)
4 → Tokyo Night  (Mavi/Mor, Modern)
5 → Catppuccin   (Pastel, Yumuşak)
6 → One Dark     (Atom-like, Orta)
7 → Solarized    (Klasik, Düşük kontrast)
0 → Geri
```

## 📁 Dosya Konumları

### Script Dosyaları

```
~/terminal-setup/
├── terminal-setup.sh      # Ana script
├── terminal-core.sh       # Kurulum modülü
├── terminal-utils.sh      # Yardımcı modül
└── VERSION               # Versiyon dosyası
```

### Kullanıcı Dosyaları

```
~/
├── .terminal-setup-backup/    # Yedekler
├── .terminal-setup.conf       # Konfigürasyon
├── .terminal-setup.log        # Log dosyası
├── .zshrc                     # Zsh config
├── .p10k.zsh                  # Powerlevel10k config
└── .oh-my-zsh/                # Oh My Zsh
```

## ⚙️ Konfigürasyon

### Config Dosyası (~/.terminal-setup.conf)

```bash
DEFAULT_THEME="dracula"      # Varsayılan tema
AUTO_UPDATE="false"          # Otomatik güncelleme
BACKUP_COUNT="5"             # Yedek sayısı
```

### Manuel Düzenleme

```bash
# Config düzenle
nano ~/.terminal-setup.conf

# Log görüntüle
tail -f ~/.terminal-setup.log

# Yedekleri listele
ls -lh ~/.terminal-setup-backup/
```

## 🎨 Tema Renk Kodları

### Dracula
```
BG: #282A36  FG: #F8F8F2
Kırmızı: #FF5555  Yeşil: #50FA7B
Sarı: #F1FA8C    Mavi: #BD93F9
Mor: #FF79C6     Cyan: #8BE9FD
```

### Nord
```
BG: #2E3440  FG: #D8DEE9
Kırmızı: #BF616A  Yeşil: #A3BE8C
Sarı: #EBCB8B    Mavi: #81A1C1
Mor: #B48EAD     Cyan: #88C0D0
```

### Gruvbox
```
BG: #282828  FG: #EBDBB2
Kırmızı: #CC241D  Yeşil: #98971A
Sarı: #D79921    Mavi: #458588
Mor: #B16286     Cyan: #689D6A
```

## 🔧 Sorun Giderme

### Hızlı Çözümler

| Sorun | Çözüm |
|-------|-------|
| Bağımlılık eksik | `sudo apt install git curl wget` |
| Font gösterilmiyor | Terminal ayarlarından `MesloLGS NF` seçin |
| Tema uygulanmıyor | `./terminal-setup.sh --health` çalıştırın |
| P10k başlamıyor | `p10k configure` veya `source ~/.zshrc` |
| Sudo şifresi soruyor | Script'i güncelleyin: `./terminal-setup.sh --update` |

### Log Komutları

```bash
# Son 50 satır
tail -n 50 ~/.terminal-setup.log

# Hataları filtrele
grep ERROR ~/.terminal-setup.log

# Canlı izle
tail -f ~/.terminal-setup.log

# Log temizle
> ~/.terminal-setup.log
```

### Debug Modu

```bash
# Debug ile çalıştır
./terminal-setup.sh --debug

# Verbose mod
./terminal-setup.sh --verbose

# İkisi birlikte
./terminal-setup.sh --debug --verbose
```

## 📦 Paket Yönetimi

### Kurulacak Paketler

```bash
# Sistem paketleri
sudo apt install zsh git curl wget fonts-powerline fontconfig

# Oh My Zsh (otomatik)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k (otomatik)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git

# Pluginler (otomatik)
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting
```

### Kaldırma

```bash
# Script ile
./terminal-setup.sh
# Menüden: 11 (Tümünü Kaldır)

# Manuel
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.p10k.zsh
chsh -s $(which bash)
sudo apt remove zsh
```

## 🚀 Powerlevel10k Kısayolları

### Yeniden Yapılandırma

```bash
p10k configure    # Wizard'ı başlat
```

### Segment Göster/Gizle

```bash
# .p10k.zsh dosyasını düzenle
nano ~/.p10k.zsh

# Segment listesi
# os_icon, dir, vcs, status, command_execution_time
# background_jobs, virtualenv, anaconda, pyenv, go, rust
```

### İpuçları

- Instant prompt'u aktif tutun (hız için)
- Gereksiz segmentleri kaldırın
- Font kurulumunu atlama
- `p10k display` ile test edin

## 💡 İpuçları & Tricks

### Hızlı Tema Değiştirme

```bash
# Sadece tema değiştir (5 saniye)
./terminal-setup.sh
# 7 → Tema seç
```

### Yedek Yönetimi

```bash
# Eski yedekleri temizle
# Ayarlardan BACKUP_COUNT değiştirin
./terminal-setup.sh
# 12 → 3 → Sayı girin
```

### Font Kontrolü

```bash
# Kurulu fontları listele
fc-list | grep -i meslo

# Font cache yenile
fc-cache -f -v
```

### Shell Değiştirme

```bash
# Zsh'e geç
chsh -s $(which zsh)

# Bash'e dön
chsh -s $(which bash)

# Mevcut shell
echo $SHELL
```

### Plugin Ekleme

```bash
# ~/.zshrc dosyasını düzenle
nano ~/.zshrc

# plugins satırına ekle
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  # yeni pluginler buraya
)
```

## 📊 Performans İyileştirme

### Hızlandırma İpuçları

```bash
# 1. Instant prompt'u aktif tut
# .zshrc başında olmalı

# 2. Gereksiz pluginleri kaldır
plugins=(git zsh-autosuggestions)  # Minimal

# 3. P10k segmentlerini azalt
p10k configure  # Minimal preset seç

# 4. Syntax highlighting'i gerekirse kapat
# .zshrc'den kaldır

# 5. Oh My Zsh güncellemesini manuel yap
# .zshrc içinde:
zstyle ':omz:update' mode disabled
```

## 🔗 Faydalı Linkler

### Resmi Dokümantasyon

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Zsh](https://zsh.sourceforge.io/Doc/)

### Tema Siteleri

- [Dracula](https://draculatheme.com/)
- [Nord](https://www.nordtheme.com/)
- [Gruvbox](https://github.com/morhetz/gruvbox)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)
- [Catppuccin](https://github.com/catppuccin/catppuccin)

### Plugin Repoları

- [zsh-users](https://github.com/zsh-users)
- [Oh My Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins)

## 📞 Destek

```bash
# Issue aç
https://github.com/alibedirhan/Theme-after-format/issues

# Katkıda bulun
https://github.com/alibedirhan/Theme-after-format/pulls

# Tartışma
https://github.com/alibedirhan/Theme-after-format/discussions
```

## 🎓 Öğrenme Kaynakları

### Bash Scripting

- [Bash Guide](https://guide.bash.academy/)
- [ShellCheck](https://www.shellcheck.net/)

### Zsh

- [Zsh Guide](https://zsh.sourceforge.io/Guide/)
- [Awesome Zsh](https://github.com/unixorn/awesome-zsh-plugins)

### Terminal

- [Terminal.sexy](https://terminal.sexy/) - Renk şema oluşturucu
- [iTerm2 Color Schemes](https://iterm2colorschemes.com/)

---

**v3.0.0** | [GitHub](https://github.com/alibedirhan/Theme-after-format) | [Issues](https://github.com/alibedirhan/Theme-after-format/issues)
