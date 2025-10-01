# Kurulum Rehberi

Theme After Format için detaylı kurulum talimatları.

## İçindekiler

- [Sistem Gereksinimleri](#sistem-gereksinimleri)
- [Kurulum Yöntemleri](#kurulum-yöntemleri)
- [İlk Çalıştırma](#ilk-çalıştırma)
- [Yapılandırma](#yapılandırma)
- [Sorun Giderme](#sorun-giderme)

## Sistem Gereksinimleri

### Desteklenen İşletim Sistemleri

- Ubuntu 20.04 LTS veya üstü
- Ubuntu 22.04 LTS (önerilir)
- Debian 10 (Buster) veya üstü
- Linux Mint 20 veya üstü
- Pop!_OS 20.04 veya üstü

### Gerekli Yazılımlar

Kurulum sırasında otomatik yüklenecekler:
- `zsh` (Z Shell)
- `git` (versiyon kontrol)
- `curl` veya `wget` (indirme)
- `fonts-powerline` (font desteği)

### Donanım Gereksinimleri

- RAM: En az 512 MB (1 GB önerilir)
- Disk: 100 MB boş alan
- İnternet: Kurulum için gerekli

## Kurulum Yöntemleri

### Yöntem 1: Wget ile (Önerilen)

```bash
# Script'i indir
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh

# Çalıştırma yetkisi ver
chmod +x terminal-setup.sh

# Çalıştır
./terminal-setup.sh
```

### Yöntem 2: Curl ile

```bash
# Script'i indir ve çalıştırma yetkisi ver
curl -fsSL https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh -o terminal-setup.sh && chmod +x terminal-setup.sh

# Çalıştır
./terminal-setup.sh
```

### Yöntem 3: Git Clone (Geliştirici)

```bash
# Repo'yu klonla
git clone https://github.com/alibedirhan/Theme-after-format.git

# Dizine gir
cd Theme-after-format

# Çalıştırma yetkisi ver
chmod +x terminal-setup.sh

# Çalıştır
./terminal-setup.sh
```

### Yöntem 4: Manuel İndirme

1. [Releases](https://github.com/alibedirhan/Theme-after-format/releases) sayfasından son sürümü indirin
2. ZIP dosyasını açın
3. Terminal'de dizine gidin
4. `chmod +x terminal-setup.sh`
5. `./terminal-setup.sh`

## İlk Çalıştırma

### 1. Script'i Başlatın

```bash
./terminal-setup.sh
```

### 2. Menüden Seçim Yapın

İlk kez kullanıyorsanız **Tam Kurulum** önerilir:

```
1) Tam Kurulum (Dracula teması) ← Mor/pembe renkler
2) Tam Kurulum (Nord teması)    ← Mavi/gri renkler
```

### 3. Kurulum İlerlemesi

Script şunları yapacak:

1. ✅ Mevcut ayarlarınızı yedekler
2. ✅ Zsh'yi kurar
3. ✅ Oh My Zsh'yi kurar
4. ✅ Fontları kurar
5. ✅ Powerlevel10k'yi kurar
6. ✅ Pluginleri kurar
7. ✅ Renk temasını uygular
8. ✅ Varsayılan shell'i değiştirir

### 4. Terminal'i Yeniden Başlatın

```bash
# Terminal'i kapat ve tekrar aç
# VEYA
exec zsh
```

### 5. Powerlevel10k Yapılandırması

Terminal yeniden başladığında otomatik olarak yapılandırma wizard'ı başlar:

**Önerilen Cevaplar:**
- Diamond, Lock, Debian logo → **y** (evet)
- Prompt Style → **3** (Rainbow)
- Character Set → **1** (Unicode)
- Show current time? → **3** (12-hour) veya **2** (24-hour)
- Prompt Separators → **1** (Angled)
- Prompt Heads → **1** (Sharp)
- Prompt Height → **2** (Two lines)
- Prompt Spacing → **2** (Sparse)
- Icons → **2** (Many icons)
- Prompt Flow → **1** (Concise)
- Enable Transient Prompt? → **y**
- Instant Prompt Mode → **1** (Verbose)

## Yapılandırma

### Powerlevel10k'yi Yeniden Yapılandırma

```bash
p10k configure
```

### Tema Değiştirme

**Dracula'dan Nord'a:**
```bash
./terminal-setup.sh
# Seçenek 6: Sadece Nord Renk Teması
```

**Nord'dan Dracula'ya:**
```bash
./terminal-setup.sh
# Seçenek 5: Sadece Dracula Renk Teması
```

### Plugin Yönetimi

Pluginler `~/.zshrc` dosyasında tanımlı:

```bash
nano ~/.zshrc

# plugins satırını bulun:
plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)

# Yeni plugin eklemek için virgülle ayırın
plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages docker)

# Kaydet ve yükle
source ~/.zshrc
```

### Terminal Font Ayarları

GNOME Terminal'de font değiştirme:

1. Terminal → Preferences
2. Profile seç
3. Text → Custom Font
4. **MesloLGS NF Regular** seç
5. Boyut: 11 veya 12

## Sorun Giderme

### "Permission denied" Hatası

```bash
chmod +x terminal-setup.sh
```

### "chsh: PAM: Authentication failure"

```bash
# sudo ile deneyin
sudo chsh -s $(which zsh) $USER
```

### Karakterler Bozuk Görünüyor

**Sebep:** Font eksik veya yanlış font seçili

**Çözüm:**
```bash
# Fontları tekrar kur
./terminal-setup.sh
# Seçenek 4: Sadece Powerlevel10k Teması

# Terminal font ayarlarını kontrol et
# MesloLGS NF Regular seçili mi?
```

### Renk Teması Uygulanmadı

**Sebep:** GNOME Terminal kullanmıyorsunuz

**Çözüm:**
```bash
# Terminal tipini kontrol et
ps -o comm= -p $PPID

# GNOME Terminal kur
sudo apt install gnome-terminal
```

### Oh My Zsh Zaten Kurulu

Script mevcut kurulumu tespit eder ve üzerine yazmaz. Temiz kurulum için:

```bash
# Önce kaldır
./terminal-setup.sh
# Seçenek 8: Tümünü Kaldır

# Sonra tekrar kur
./terminal-setup.sh
# Seçenek 1 veya 2
```

### Git Clone Hatası

**Hata:** `fatal: unable to access...`

**Sebep:** İnternet bağlantısı yok veya GitHub'a erişim yok

**Çözüm:**
```bash
# İnterneti kontrol et
ping -c 3 github.com

# Proxy ayarları varsa
git config --global http.proxy http://proxy:port
```

### Zsh Çok Yavaş

**Sebep:** Çok fazla plugin veya instant prompt sorunu

**Çözüm:**
```bash
# Performans analizi
p10k debug

# Instant prompt'u devre dışı bırak
nano ~/.zshrc
# En üstteki instant-prompt bloğunu yoruma al
```

## Güncelleme

```bash
# Repo'yu güncelle
cd Theme-after-format
git pull origin main

# Script'i tekrar çalıştır
./terminal-setup.sh
```

## Kaldırma

### Script ile Kaldırma

```bash
./terminal-setup.sh
# Seçenek 8: Tümünü Kaldır
```

### Manuel Kaldırma

```bash
# Oh My Zsh'yi kaldır
rm -rf ~/.oh-my-zsh

# Zsh config dosyalarını sil
rm ~/.zshrc ~/.zsh_history ~/.p10k.zsh

# Bash'e geri dön
chsh -s $(which bash)

# Yedekten .bashrc'yi geri yükle
cp ~/.terminal-setup-backup/bashrc_* ~/.bashrc

# Çıkış yap ve tekrar gir
exit
```

## Sistem PATH'e Ekleme (Opsiyonel)

Script'i her yerden çalıştırmak için:

```bash
# Script'i /usr/local/bin'e kopyala
sudo cp terminal-setup.sh /usr/local/bin/theme-setup

# Artık her yerden çalıştırabilirsiniz
theme-setup
```

## Format Sonrası Hızlı Kurulum

```bash
# Tek satırda kurulum
wget -qO- https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh | bash -s -- --auto-dracula

# Veya Nord ile
wget -qO- https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh | bash -s -- --auto-nord
```

**Not:** Otomatik kurulum gelecek sürümde eklenecek.

## İleri Seviye

### Özel Tema Oluşturma

```bash
# Kendi renk paletinizi tanımlayın
nano ~/.config/gnome-terminal-colors.sh

# Renkleri gsettings ile uygulayın
```

### Tmux Entegrasyonu

```bash
# Tmux ile kullanım
nano ~/.tmux.conf

# Ekleyin:
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
```

## Destek

Sorun yaşıyorsanız:

1. [Issues](https://github.com/alibedirhan/Theme-after-format/issues) sayfasını kontrol edin
2. Yeni issue açın ve:
   - Hata mesajını ekleyin
   - Sistem bilgilerinizi yazın (OS, terminal tipi)
   - Adım adım ne yaptığınızı açıklayın

---

Kurulum hakkında sorularınız için [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions) kullanabilirsiniz.
