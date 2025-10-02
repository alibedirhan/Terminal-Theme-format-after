# Changelog - v3.1.0

## Kritik Düzeltmeler

### 1. Sudo Process Cleanup Düzeltildi
**Sorun:** Sudo refresh process her zaman düzgün durdurulmuyordu.

**Çözüm:**
- `cleanup_sudo()` fonksiyonu eklendi (terminal-core.sh)
- Global trap ile EXIT ve ERR sinyallerinde otomatik cleanup
- Process ID kontrolü ile güvenli kill işlemi

```bash
cleanup_sudo() {
    if [[ -n "$SUDO_REFRESH_PID" ]] && kill -0 "$SUDO_REFRESH_PID" 2>/dev/null; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null
        SUDO_REFRESH_PID=""
    fi
}
trap cleanup_sudo EXIT ERR
```

### 2. Platform Bağımsız stat Komutu
**Sorun:** `stat -f%z` macOS için, `-c%s` Linux için farklı çalışıyordu.

**Çözüm:**
- Platform bağımsız `wc -c` komutu kullanılıyor
- Her iki sistemde de sorunsuz çalışır

```bash
# Eski (hatalı):
local file_size=$(stat -f%z "$file_name" 2>/dev/null || stat -c%s "$file_name" 2>/dev/null)

# Yeni (düzeltilmiş):
local file_size=$(wc -c < "$file_name" 2>/dev/null)
```

### 3. Health Check Mantık Hatası Düzeltildi
**Sorun:** Terminal emulator bilinmeyen olsa bile passed_checks artıyordu.

**Çözüm:**
- Bilinmeyen terminal warnings++ yapar ama passed_checks artmaz
- Success rate artık doğru hesaplanıyor

```bash
# Düzeltme:
if [ "$terminal" != "unknown" ]; then
    ((passed_checks++))
else
    ((warnings++))
    # passed_checks artırılmıyor
fi
```

### 4. Font İndirme Hata Kontrolü
**Sorun:** Hiçbir font indirilemediyse script sessizce devam ediyordu.

**Çözüm:**
- Font indirme başarısız olursa kullanıcıya soruyor
- Manuel kurulum linki gösteriliyor
- Kullanıcı tercihine göre devam ediyor veya duruyor

```bash
if [ $success_count -gt 0 ]; then
    log_success "$success_count font kuruldu"
else
    log_error "Hiçbir font indirilemedi!"
    log_warning "Manuel kurulum için: https://github.com/romkatv/powerlevel10k#fonts"
    echo -n "Font olmadan devam etmek ister misiniz? (e/h): "
    read -r continue_choice
    if [[ "$continue_choice" != "e" ]]; then
        return 1
    fi
fi
```

---

## Yeni Özellikler

### 1. Terminal Araçları Kurulumu

Modern ve güçlü terminal araçları tek menüden kurulabilir:

**FZF (Fuzzy Finder)**
- Dosya, komut, history'de hızlı arama
- Ctrl+R ile history aramada devrim
- https://github.com/junegunn/fzf

**Zoxide (Akıllı cd)**
- En çok kullanılan dizinlere hızlı geçiş
- `z projem` komutuyla proje dizinine atlama
- https://github.com/ajeetdsouza/zoxide

**Exa (Modern ls)**
- Renkli ve icon'lu dosya listeleme
- Tree görünümü desteği
- https://github.com/ogham/exa

**Bat (cat with syntax)**
- Syntax highlighting ile dosya görüntüleme
- Git integration
- https://github.com/sharkdp/bat

**Kullanım:**
```bash
./terminal-setup.sh
# Menüden 9 seçin (Terminal Araçları)
# Bilgileri okuyun ve tümünü kurabilirsiniz
```

### 2. Tmux Desteği

Tmux artık kurulu tema ile uyumlu olarak yapılandırılıyor:

**Özellikler:**
- Mouse desteği aktif
- Prefix: Ctrl+a (Ctrl+b yerine)
- 256 renk desteği
- Temaya özel renkler
- Pencere numaraları 1'den başlar
- Otomatik yeniden numaralandırma

**Desteklenen Temalar:**
- Dracula
- Nord
- Gruvbox
- Tokyo Night
- Catppuccin
- One Dark
- Solarized

**Kullanım:**
```bash
./terminal-setup.sh
# Menüden 10 seçin (Tmux Kurulumu)
# İstediğiniz temayı seçin
# Tmux otomatik yapılandırılacak
```

**Tmux Kısayolları:**
- `Ctrl+a c` - Yeni pencere
- `Ctrl+a n` - Sonraki pencere
- `Ctrl+a p` - Önceki pencere
- `Ctrl+a d` - Detach (çıkış)
- `Ctrl+a %` - Dikey bölme
- `Ctrl+a "` - Yatay bölme

---

## Menü Değişiklikleri

Menü numaraları güncellendi:

```
1-4)  Tam Kurulum (temalar)
5-8)  Modüler Kurulum
9)    Terminal Araçları (YENİ)
10)   Tmux Kurulumu (YENİ)
11)   Sistem Sağlık Kontrolü
12)   Yedekleri Göster
13)   Tümünü Kaldır
14)   Ayarlar
0)    Çıkış
```

---

## Dosya Değişiklikleri

### terminal-setup.sh
- Version: 3.1.0
- Menü yapısı güncellendi
- Cleanup fonksiyonu iyileştirildi
- Yeni case blokları eklendi

### terminal-core.sh
- cleanup_sudo() fonksiyonu eklendi
- stat komutu düzeltildi
- Font hata kontrolü eklendi
- install_fzf() fonksiyonu eklendi
- install_zoxide() fonksiyonu eklendi
- install_exa() fonksiyonu eklendi
- install_bat() fonksiyonu eklendi
- install_all_tools() fonksiyonu eklendi
- install_tmux() fonksiyonu eklendi
- configure_tmux_theme() fonksiyonu eklendi
- install_tmux_with_theme() fonksiyonu eklendi
- show_terminal_tools_info() fonksiyonu eklendi

### terminal-utils.sh
- Health check mantık hatası düzeltildi

---

## Test Edildi

Tüm değişiklikler şu ortamlarda test edildi:
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Debian 11
- GNOME Terminal
- Tmux 3.2a

---

## Kurulum

```bash
# Mevcut kurulumu güncelle
cd ~/terminal-setup
git pull origin main
chmod +x *.sh

# Veya yeni kurulum
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
chmod +x *.sh
./terminal-setup.sh
```

---

## Bilinen Sorunlar

Yok. Tüm kritik bug'lar düzeltildi.

---

## Gelecek Planları (v3.2)

- Neovim/Vim konfigürasyonu
- Git gelişmiş ayarları
- Docker/Kubernetes araçları
- Desktop environment temaları
- Profil sistemi (dev, minimal, power-user)

---

## Katkıda Bulunanlar

Bu versiyonda yapılan iyileştirmeler kullanıcı geri bildirimleri sayesinde gerçekleştirilmiştir.

---

**Teşekkürler!**

Made with ❤️ by Ali Bedirhan