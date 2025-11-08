# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına uygundur.

## [4.3.0] - 2024-11-08

### ✨ Yeni Özellikler (Added)

#### Aliases Şablon Sistemi
- `aliases/.aliases` örnek dosyası eklendi
- Navigation, Git, Exa, sistem aliasları içeriyor
- Kullanıcı dosyası yoksa şablon oluşturma seçeneği
- Otomatik `.zshrc` entegrasyonu
- **Etkilenen dosyalar:** `aliases/.aliases`, `core/terminal-config.sh`

#### Gelişmiş Hata Loglaması
- FZF kurulum hatalarını gösterme ve log'a kaydetme
- Zoxide kurulum hatalarını gösterme
- Manuel kurulum talimatları eklendi
- **Etkilenen dosya:** `core/terminal-tools.sh`

#### Otomatik Source (Opsiyonel)
- Terminal araçları kurulumundan sonra `.zshrc` otomatik yükleme seçeneği
- Kullanıcıya sorarak yapılıyor
- **Etkilenen dosya:** `terminal-setup.sh`

### ✅ Düzeltilen Hatalar (Fixed)

#### FZF Kurulum Hatası
- **Sorun:** `--all` ve `--no-bash` parametreleri çelişiyordu
- **Çözüm:** `--key-bindings --completion --no-update-rc --no-bash --no-fish` kullanıldı
- **Etkilenen dosya:** `core/terminal-tools.sh`

#### Zoxide Kurulum Hatası
- **Sorun:** `retry_command` ile `eval` pipe çalışmıyordu
- **Çözüm:** Direkt `bash -c` ile curl pipe kullanıldı
- Gerçek hata mesajı artık gösteriliyor
- **Etkilenen dosya:** `core/terminal-tools.sh`

#### Menü 5 Eksiklikleri
- **Sorun:** Menü 5 (Zsh + Oh My Zsh) fontlar, pluginler ve aliases kurmuyor
- **Çözüm:** Menü 1-4 ile aynı bileşenler eklendi
- Artık tam paket: Fontlar + Pluginler + Aliases
- **Etkilenen dosyalar:** `terminal-setup.sh`, `terminal-ui.sh`

### 🔄 Değişiklikler (Changed)

- Menü 5 açıklaması güncellendi: "Zsh + Oh My Zsh (Tema hariç, tam paket)"
- Kurulum adım sayısı 4'ten 6'ya çıktı (fontlar + pluginler eklendi)
- Terminal araçları kurulumunda daha detaylı ilerleme gösterimi

---

## [3.3.0] - 2024-10-21

### ✨ Yeni Özellikler

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

#### Powerlevel10k Wizard Entegrasyonu
- Tam kurulum sonrası otomatik P10k wizard
- Menü 5 sonrası otomatik P10k wizard
- Wizard tamamlandıktan sonra ana menüye dönüş
- **Etkilenen dosya:** `terminal-setup.sh`

#### Tam Kaldırma Sistemi (19 Adım)
- Plugin config dosyaları temizleme (`~/.fzf.zsh`, `~/.config/atuin`)
- Zsh plugin dizinleri silme
- Script kendi dizinlerini temizleme (`~/.terminal-setup`)
- Zsh paketi `--purge` ile kaldırılıyor
- **Etkilenen dosya:** `core/terminal-config.sh`

### ✅ Düzeltilen Hatalar

- install.sh artık modüler yapıyı destekliyor (16 dosya indirir)
- Tema fonksiyonlarında isim çakışması giderildi
- macOS disk space kontrolü düzeltildi
- Internet check birden fazla host deniyor (8.8.8.8 bazen bloklanıyor)

---

## [3.2.9] - 2024-10-15

### ✨ Yeni Özellikler
- Smart version manager scripti
- Smart release manager scripti
- Otomatik versiyon senkronizasyonu

### ✅ Düzeltmeler
- Bazı terminallerde renk temaları düzgün uygulanmıyordu, düzeltildi

---

## [3.2.7] - 2024-10-10

### ✨ Yeni Özellikler
- 7 farklı tema desteği (Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized)
- Kitty ve Alacritty terminal desteği
- Terminal otomatik detection

### ✅ Düzeltmeler
- GNOME Terminal'de bazı renkler yanlış görünüyordu
- Oh My Zsh kurulumu bazen fail ediyordu

---

## [3.2.0] - 2024-09-25

### ✨ Yeni Özellikler
- Tmux kurulumu ve konfigürasyonu
- 14 CLI aracı kurulum seçeneği
- Diagnostic (sağlık kontrolü) sistemi

---

## [3.1.0] - 2024-09-10

### ✨ Yeni Özellikler
- Powerlevel10k teması
- Font kurulumu (Nerd Fonts)
- Plugin sistemi (zsh-autosuggestions, zsh-syntax-highlighting)

---

## [3.0.0] - 2024-08-20

### 🎯 İlk Majör Release
Terminal setup'ı tamamen yeniden yazıldı.

- Zsh + Oh My Zsh kurulumu
- İnteraktif menü sistemi
- Backup/restore mekanizması
- Uninstall desteği

---

## Commit Formatı

Bu proje [Conventional Commits](https://www.conventionalcommits.org/) standardını kullanır:

- `feat:` Yeni özellik
- `fix:` Hata düzeltmesi
- `docs:` Dokümantasyon değişikliği
- `style:` Kod formatı (işlevselliği etkilemeyen)
- `refactor:` Yeniden yapılandırma
- `test:` Test ekleme/düzeltme
- `chore:` Bakım işleri

### Örnekler

```bash
feat: FZF kurulum sistemi ekle
fix: Zoxide pipe hatası düzelt
docs: README güncelle
refactor: Menü sistemi iyileştir
```
