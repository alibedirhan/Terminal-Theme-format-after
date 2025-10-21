# Changelog

Bu dosya projedeki önemli değişiklikleri takip eder.

## [3.3.0] - 2025-10-21

### Değişiklikler

#### Modüler Mimari
Kod tabanı tamamen yeniden düzenlendi. 3 büyük dosya (4000+ satır) yerine artık 13 küçük modüle bölündü:

**Core modülü** (3 dosya):
- `core/terminal-base.sh` - Zsh, Oh My Zsh, Powerlevel10k kurulumu
- `core/terminal-tools.sh` - CLI araçları (fzf, bat, exa vs.)
- `core/terminal-config.sh` - Tmux ve tema konfigürasyonu

**Utils modülü** (3 dosya):
- `utils/helpers.sh` - Logging, error handling, retry sistemi
- `utils/system.sh` - Terminal detection, internet check
- `utils/config.sh` - Config yönetimi, backup, snapshot

**Themes** (7 dosya):
Her tema artık ayrı dosyada, fonksiyon isimleri çakışmayacak şekilde düzenlendi.

#### Düzeltilen Hatalar
- install.sh artık modüler yapıyı destekliyor (16 dosya indirir)
- Tema fonksiyonlarında isim çakışması giderildi
- macOS disk space kontrolü düzeltildi
- Internet check birden fazla host deniyor (8.8.8.8 bazen bloklanıyor)

#### Neden?
- Her dosya 1000 satırın altında, daha kolay okunuyor
- Bir şey değiştirirken sadece ilgili modüle bakıyorsun
- Git diff'leri daha anlamlı
- Yeni özellik eklemek çok daha basit

#### Breaking Changes
Eğer eski terminal-core.sh, terminal-utils.sh veya terminal-themes.sh'yi doğrudan import ediyordunuz, artık çalışmayacak. Yeni modül yapısını kullanın.

---

## [3.2.9] - 2025-10-15

### Eklenenler
- Smart version manager scripti
- Smart release manager scripti
- Otomatik versiyon senkronizasyonu

### Düzeltmeler
- Bazı terminallerde renk temaları düzgün uygulanmıyordu, düzeltildi

---

## [3.2.7] - 2025-10-10

### Eklenenler
- 7 farklı tema desteği (Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized)
- Kitty ve Alacritty terminal desteği
- Terminal otomatik detection

### Düzeltmeler
- GNOME Terminal'de bazı renkler yanlış görünüyordu
- Oh My Zsh kurulumu bazen fail ediyordu

---

## [3.2.0] - 2025-09-25

### Eklenenler
- Tmux kurulumu ve konfigürasyonu
- 14 CLI aracı kurulum seçeneği
- Diagnostic (sağlık kontrolü) sistemi

---

## [3.1.0] - 2025-09-10

### Eklenenler
- Powerlevel10k teması
- Font kurulumu (Nerd Fonts)
- Plugin sistemi (zsh-autosuggestions, zsh-syntax-highlighting)

---

## [3.0.0] - 2025-08-20

### Değişiklikler
İlk majör release. Terminal setup'ı tamamen yeniden yazıldı.

- Zsh + Oh My Zsh kurulumu
- İnteraktif menü sistemi
- Backup/restore mekanizması
- Uninstall desteği

---

## [2.x] - Eski Versiyonlar

2.x serisindeki değişiklikler için git geçmişine bakın.

---

## Format

Bu changelog [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) formatını takip eder ve proje [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kullanır.

- **Added** - Yeni özellikler
- **Changed** - Mevcut özelliklerdeki değişiklikler
- **Deprecated** - Yakında kaldırılacak özellikler
- **Removed** - Kaldırılan özellikler
- **Fixed** - Hata düzeltmeleri
- **Security** - Güvenlik ile ilgili değişiklikler
