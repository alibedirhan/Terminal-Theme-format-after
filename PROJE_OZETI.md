# Proje Özeti - Terminal Setup v3.3.0

Son güncelleme: 21 Ekim 2025

## Genel Bakış

Terminal Setup, Linux/macOS terminalini tek komutla konfigüre eden bir script koleksiyonu. Zsh, Oh My Zsh, Powerlevel10k, CLI araçları ve temalar dahil.

**Ana özellikler:**
- Otomatik kurulum (bağımlılıklar, fontlar, temalar)
- 7 farklı renk teması
- 14 CLI aracı seçeneği
- GNOME Terminal, Kitty, Alacritty desteği
- Backup/restore mekanizması
- Uninstall özelliği

## Mimari

### v3.3.0 Değişiklikleri

Önceden 3 büyük dosya vardı (~4000 satır). Artık 13 modüle bölündü:

```
Önce:
- terminal-core.sh (2271 satır)
- terminal-utils.sh (1288 satır)  
- terminal-themes.sh (527 satır)

Sonra:
- core/ (3 dosya, ~2300 satır)
- utils/ (3 dosya, ~1300 satır)
- themes/ (7 dosya, her biri ~100 satır)
```

Her dosya artık 1000 satırın altında. Git diff'leri daha anlamlı, değişiklik yapmak daha kolay.

## Dosya Yapısı

### Ana Script'ler

**terminal-setup.sh** (~100 satır)
- Giriş noktası
- Modülleri yükler
- Ana menüyü başlatır

**terminal-ui.sh** (~200 satır)
- İnteraktif menü
- Kullanıcı seçimleri
- Progress göstergesi

**terminal-assistant.sh** (~300 satır)
- Diagnostic sistem
- Sağlık kontrolleri
- Sorun giderme önerileri

### Core Modülü

**core/terminal-base.sh** (612 satır)
Temel terminal kurulumu:
- `install_zsh()` - Zsh kurulumu
- `install_oh_my_zsh()` - Oh My Zsh
- `install_fonts()` - Nerd Fonts (MesloLGS NF)
- `install_powerlevel10k()` - P10k teması
- `install_plugins()` - zsh-autosuggestions, zsh-syntax-highlighting

**core/terminal-tools.sh** (977 satır)
CLI araçları:
- `install_fzf()` - Fuzzy finder
- `install_zoxide()` - Akıllı cd
- `install_exa()` - Modern ls
- `install_bat()` - Cat with syntax highlighting
- `install_ripgrep()` - Hızlı grep
- `install_fd()` - Hızlı find
- `install_delta()` - Git diff
- `install_lazygit()` - Git TUI
- `install_btop()` - System monitor
- `install_tldr()` - Man pages özeti
- `install_neovim()` - Vim alternatifi
- `install_tmux()` - Terminal multiplexer
- `install_starship()` - Cross-shell prompt
- `install_zellij()` - Modern tmux

**core/terminal-config.sh** (695 satır)
Konfigürasyon:
- `install_theme()` - Tema dispatcher (hangi tema hangi fonksiyon)
- `install_theme_gnome()` - GNOME Terminal renkleri
- `install_theme_kitty()` - Kitty config
- `install_theme_alacritty()` - Alacritty config
- `install_tmux()` - Tmux kurulum
- `configure_tmux()` - Tmux config yazma
- `uninstall_all()` - Her şeyi kaldır

### Utils Modülü

**utils/helpers.sh** (594 satır)
Yardımcı fonksiyonlar:
- Logging sistemi (log_info, log_success, log_error, vb.)
- `show_error()` - Hata mesajları
- `run_with_error_handling()` - Try-catch benzeri
- `retry_command()` - Başarısız komutları tekrar dene
- `safe_download()` - Güvenli wget/curl
- `ask_yes_no()` - Kullanıcıdan onay al
- Transaction sistemi (rollback için)

**utils/system.sh** (175 satır)
Sistem kontrolleri:
- `detect_terminal()` - Hangi terminal kullanılıyor (10+ terminal desteği)
- `check_gnome_terminal()` - GNOME var mı
- `check_internet()` - İnternet bağlantısı (birden fazla host dener)
- `test_internet_speed()` - Hız testi
- `check_system_resources()` - Disk ve RAM kontrolü

**utils/config.sh** (536 satır)
Konfigürasyon yönetimi:
- `load_config()` - Config dosyası oku
- `save_config()` - Config dosyası yaz
- `validate_config()` - Config doğrula
- `check_for_updates()` - GitHub'dan güncelleme kontrol et
- `update_script()` - Script'i güncelle
- `create_snapshot()` - Backup oluştur
- `restore_snapshot()` - Backup'tan geri yükle

### Themes Modülü

Her tema dosyası (~100 satır) 4 fonksiyon içerir:

```bash
# Örnek: themes/dracula.sh
apply_dracula_gnome()           # GNOME Terminal renkleri
get_kitty_theme_dracula()       # Kitty config
get_alacritty_theme_dracula()   # Alacritty config
get_tmux_theme_dracula()        # Tmux config
```

**Temalar:**
- dracula.sh - Mor/pembe vurgular
- nord.sh - Mavi/gri, göze yumuşak
- gruvbox.sh - Retro sıcak tonlar
- tokyo-night.sh - Modern mavi/mor
- catppuccin.sh - Pastel renkler (Mocha varyantı)
- one-dark.sh - Atom editörün teması
- solarized.sh - Klasik, hassas renkler

**Önemli**: Her tema benzersiz fonksiyon isimlerine sahip. `apply_gnome_terminal()` yerine `apply_dracula_gnome()` kullanıyoruz. Yoksa temalar birbiriyle çakışır.

## Modül Yükleme Sırası

terminal-setup.sh modülleri şu sırayla yükler:

1. utils/helpers.sh - Logging (diğerleri buna bağımlı)
2. utils/system.sh - Sistem kontrolleri
3. utils/config.sh - Config yönetimi
4. terminal-ui.sh - UI
5. core/terminal-base.sh - Zsh, Oh My Zsh
6. core/terminal-tools.sh - CLI araçları
7. core/terminal-config.sh - Tema, tmux
8. terminal-assistant.sh - Diagnostic

Tema dosyaları başta yüklenmiyor. Kullanıcı seçtiğinde dinamik olarak yüklenir (lazy loading).

## Kurulum Akışı

```
1. install.sh çalışır
   ├─> 16 dosyayı GitHub'dan indirir
   ├─> Dizinleri oluşturur (core/, utils/, themes/)
   └─> terminal-setup.sh'yi başlatır

2. terminal-setup.sh
   ├─> Modülleri yükler
   ├─> Config okur (~/.terminal-setup.conf)
   └─> Ana menüyü gösterir

3. Kullanıcı seçim yapar
   ├─> "1) Full Install" -> Her şeyi kur
   ├─> "2) Base Install" -> Sadece Zsh + Oh My Zsh
   ├─> "3) Temalar" -> Tema seç ve uygula
   ├─> "9) CLI Araçları" -> Araçları seç
   └─> "11) Sağlık Kontrolü" -> Diagnostic çalıştır
```

## Dosya Konumları

**Script'ler:**
```
~/.terminal-setup-installer/     # install.sh indirme dizini
  ├── terminal-setup.sh
  ├── terminal-ui.sh
  ├── terminal-assistant.sh
  ├── core/
  ├── utils/
  └── themes/
```

**Kullanıcı dosyaları:**
```
~/.terminal-setup.conf           # Config
~/.terminal-setup/               # Log, cache
~/.terminal-setup-backup/        # Backup'lar
```

**Zsh konfigürasyonu:**
```
~/.zshrc                         # Ana config
~/.p10k.zsh                      # Powerlevel10k config
~/.oh-my-zsh/                    # Oh My Zsh dizini
```

## Bağımlılıklar

**Minimum:**
- bash 4.0+
- curl veya wget
- git
- sudo yetkisi (paket kurulumu için)

**Desteklenen platformlar:**
- Ubuntu 20.04+
- Debian 10+
- Fedora 35+
- Arch Linux
- macOS 11.0+ (Big Sur ve üstü)

## Önemli Notlar

### Tema Fonksiyon İsimlendirmesi

❌ Yanlış:
```bash
# Her temada aynı isim - ÇAKIŞMA!
apply_gnome_terminal() { ... }
```

✅ Doğru:
```bash
# Her tema kendi ismi
apply_dracula_gnome() { ... }
apply_nord_gnome() { ... }
```

### Logging Kullanımı

Direkt echo yerine logging fonksiyonları kullan:

```bash
# Yanlış
echo "Kurulum başladı"

# Doğru
log_info "Kurulum başladı"
```

### Error Handling

Her fonksiyon return code döndürmeli:

```bash
install_something() {
    if ! command; then
        log_error "Hata"
        return 1
    fi
    return 0
}
```

## İstatistikler

**v3.3.0:**
- Toplam: 16 dosya
- Ana script'ler: 3 dosya (~600 satır)
- Core: 3 dosya (~2300 satır)
- Utils: 3 dosya (~1300 satır)
- Themes: 7 dosya (~700 satır)

**Karşılaştırma:**

| Metrik | v3.2.x | v3.3.0 |
|--------|--------|--------|
| Dosya sayısı | 6 (monolitik) | 16 (modüler) |
| En büyük dosya | 2271 satır | 977 satır |
| Bakım | Zor | Kolay |
| Yeni özellik | Karmaşık | Basit |

## Bilinen Sorunlar

1. **macOS Catalina ve öncesi:** Bazı Nerd Font'lar düzgün görünmeyebilir
2. **WSL1:** Terminal detection çalışmayabilir (WSL2 öneririz)
3. **ARM Linux:** Bazı CLI araçları binary'si olmayabilir

## Gelecek Planlar

- [ ] Fish shell desteği
- [ ] Windows Terminal desteği (WSL dışında)
- [ ] Tema önizleme sistemi
- [ ] Plugin ekleme/kaldırma UI'ı
- [ ] Remote kurulum (SSH üzerinden)

## Geliştirme

Katkıda bulunmak için CONTRIBUTING.md'ye bak.

Test etmek için:
```bash
./terminal-setup.sh
# veya
bash -x terminal-setup.sh  # Debug mode
```

## Lisans

MIT License - Detaylar için LICENSE dosyasına bak.