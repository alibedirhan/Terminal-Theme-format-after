# Katkıda Bulunma Rehberi

Terminal Setup projesine katkıda bulunmak istediğin için teşekkürler! Bu rehber sana yardımcı olacak.

## Başlamadan Önce

Projeyi fork'la ve lokal'e clone'la:

```bash
git clone https://github.com/SENIN-KULLANICI-ADIN/Terminal-Theme-format-after.git
cd Terminal-Theme-format-after
```

## Proje Yapısı

v3.3.0'dan itibaren modüler bir mimari kullanıyoruz:

```
terminal-setup/
├── terminal-setup.sh          # Ana giriş noktası
├── terminal-ui.sh             # Menü ve UI
├── terminal-assistant.sh      # Diagnostic sistem
│
├── core/
│   ├── terminal-base.sh       # Zsh, Oh My Zsh, P10k
│   ├── terminal-tools.sh      # CLI araçları
│   └── terminal-config.sh     # Tmux, tema uygulama
│
├── utils/
│   ├── helpers.sh             # Logging, error handling
│   ├── system.sh              # Terminal detection, internet
│   └── config.sh              # Config yönetimi, backup
│
└── themes/
    ├── dracula.sh
    ├── nord.sh
    ├── gruvbox.sh
    ├── tokyo-night.sh
    ├── catppuccin.sh
    ├── one-dark.sh
    └── solarized.sh
```

Her modül 1000 satırdan az. Bir şey değiştirirken sadece ilgili dosyayı açman yeterli.

## Yeni Özellik Eklemek

### CLI Aracı Eklemek

`core/terminal-tools.sh` dosyasına yeni fonksiyon ekle:

```bash
install_ARACIN_ADI() {
    log_info "ARACIN_ADI kuruluyor..."
    
    if command -v ARACIN_ADI &> /dev/null; then
        log_success "ARACIN_ADI zaten kurulu"
        return 0
    fi
    
    # Kurulum kodu buraya
    
    log_success "ARACIN_ADI kuruldu"
}
```

Sonra `terminal-ui.sh`'de menüye ekle.

### Yeni Tema Eklemek

1. `themes/` klasörüne yeni dosya oluştur (örn: `monokai.sh`)
2. Şu fonksiyonları ekle:

```bash
#!/bin/bash

# GNOME Terminal
apply_monokai_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Monokai" 2>/dev/null
    # ... renk ayarları
}

# Kitty
get_kitty_theme_monokai() {
    cat << 'EOF'
foreground #f8f8f2
background #272822
# ... renkler
EOF
}

# Alacritty
get_alacritty_theme_monokai() {
    cat << 'EOF'
colors:
  primary:
    background: '#272822'
    foreground: '#f8f8f2'
  # ... renkler
EOF
}

# Tmux
get_tmux_theme_monokai() {
    cat << 'EOF'
set -g status-style bg='#272822',fg='#f8f8f2'
# ... tmux config
EOF
}
```

**Önemli**: Her tema kendi benzersiz fonksiyon isimlerine sahip olmalı. `apply_gnome_terminal()` değil, `apply_monokai_gnome()` kullan. Yoksa diğer temalarla çakışır.

3. `install.sh`'ye temayı ekle (REQUIRED_FILES listesi)
4. `core/terminal-config.sh`'deki `install_theme()` fonksiyonuna case ekle

### Utils Fonksiyonu Eklemek

Genel amaçlı fonksiyonlar `utils/` klasöründe:

- **helpers.sh** - Logging, error handling, retry gibi yardımcı fonksiyonlar
- **system.sh** - Sistem kontrolleri (terminal detection, internet vb.)
- **config.sh** - Konfigürasyon yönetimi

Hangi dosyaya ekleneceği belli değilse, helpers.sh'ye ekle.

## Kod Standartları

### Bash Best Practices

```bash
# İyi:
if command -v git &> /dev/null; then
    log_success "Git kurulu"
fi

# Kötü:
if [ -x "$(command -v git)" ]; then
    echo "Git kurulu"
fi
```

Shellcheck kullan:
```bash
shellcheck terminal-setup.sh
```

### Logging

Hep utils/helpers.sh'deki logging fonksiyonlarını kullan:

```bash
log_info "Bilgi mesajı"
log_success "Başarılı işlem"
log_warning "Uyarı"
log_error "Hata mesajı"
log_debug "Debug bilgisi"
```

Manuel echo yerine bunları kullan.

### Error Handling

```bash
# Her fonksiyonun return code'u olmalı
install_something() {
    if ! some_command; then
        log_error "İşlem başarısız"
        return 1
    fi
    return 0
}

# Kullanımı:
if install_something; then
    log_success "Tamam"
else
    log_error "Hata var"
fi
```

## Test Etme

Değişiklik yaptıktan sonra:

```bash
# 1. Syntax kontrolü
bash -n terminal-setup.sh
bash -n core/terminal-base.sh
# ... değiştirdiğin dosyalar için

# 2. Script'i çalıştır
./terminal-setup.sh

# 3. Değişikliğini test et
# (menüden ilgili seçeneği seç)
```

## Commit Mesajları

Conventional Commits formatı kullan:

```
feat: yeni CLI aracı eklendi (ripgrep)
fix: GNOME Terminal tema sorunu düzeltildi
docs: README'ye kurulum adımı eklendi
refactor: helpers.sh'deki log fonksiyonları iyileştirildi
test: terminal detection testleri eklendi
chore: versiyon 3.3.1'e güncellendi
```

Detaylı açıklama gerekirse:

```
fix: macOS'ta disk kontrolü çalışmıyordu

df komutu Linux ve macOS'ta farklı çıktı veriyor.
macOS için ayrı kontrol eklendi.

Fixes #42
```

## Pull Request Gönderme

1. Kendi branch'inde çalış:
```bash
git checkout -b feat/yeni-ozellik
```

2. Commit'le:
```bash
git add .
git commit -m "feat: yeni özellik eklendi"
```

3. Push'la:
```bash
git push origin feat/yeni-ozellik
```

4. GitHub'da Pull Request oluştur

### PR'da Neler Olmalı

- Başlık: "feat: X özelliği eklendi" formatında
- Açıklama: Ne değişti, neden değişti
- Test edildi mi: Hangi platformda test edildi (Ubuntu 22.04, macOS Sonoma vb.)
- Screenshot (eğer UI değişikliği varsa)

## Sorular?

Issue aç veya Discord'da sor (eğer varsa).

## Lisans

Katkıda bulunarak kodunun MIT lisansı altında dağıtılmasını kabul etmiş olursun.
