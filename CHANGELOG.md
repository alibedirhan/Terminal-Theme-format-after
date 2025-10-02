# Changelog

Bu dosya projedeki tüm önemli değişiklikleri içerir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardını takip eder,
ve bu proje [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kullanır.

## [3.1.0] - 2025-01-02

### Eklenenler
- Terminal profil ayarlarını tam sıfırlama özelliği (`reset_terminal_profile`)
- Orijinal sistem durumunu kaydetme sistemi (`save_original_state`)
- Orijinal duruma geri yükleme özelliği (`restore_original_state`)
- Zorlamalı kaldırma modu (`--force` parametresi)
- Standardize edilmiş hata kodları sistemi (ERR_SUCCESS, ERR_NETWORK, vb.)
- Timeout'lu input alma fonksiyonu (`read_with_timeout`)
- Spinner animasyonu (`start_spinner`, `stop_spinner`)
- Gelişmiş progress bar (`show_advanced_progress`)
- Hata yönetimi fonksiyonu (`run_with_error_handling`)
- Sistem kaynak kontrolü (`check_system_resources`)
- Snapshot sistemi (`create_snapshot`, `restore_snapshot`)
- Function entry/exit tracking (`log_function_enter`, `log_function_exit`)
- Performans ölçümü (`measure_time`)
- Detaylı kaldırma özeti (hata sayacı ile)

### Değiştirilenler
- `uninstall_all()` fonksiyonu tamamen yeniden yazıldı
- Tüm kaldırma işlemleri artık adım adım numaralandırılıyor [1/10]
- Tüm sudo komutları önceden uyarı veriyor
- Tüm komut çıktıları log dosyasına yazılıyor
- Opsiyonel kaldırmalar için timeout 30 saniye olarak ayarlandı
- Progress bar daha detaylı ve renkli
- Log sistemi geliştirildi (son 1000 satır tutuluyor)
- Hata mesajları daha açıklayıcı

### Düzeltilenler
- Shell değiştirme işlemi artık güvenilir çalışıyor
- Terminal renk ayarları artık tamamen temizleniyor
- Kaldırma işleminde takılma problemi çözüldü
- Zsh config wizard'ının gereksiz çıkması önlendi
- Font cache güncelleme hataları düzeltildi
- Yedek dizini oluşturma hataları giderildi
- Sudo timeout problemi çözüldü

### Güvenlik
- Sudo refresh process artık cleanup ile düzgün sonlanıyor
- Trap sinyalleri eklendi (EXIT, ERR)
- Geçici dosyalar güvenli dizinde oluşturuluyor
- Root olarak çalıştırma engellendi

## [3.0.0] - 2024-12-15

### Eklenenler
- İlk stabil sürüm
- 7 tema desteği (Dracula, Nord, Gruvbox, Tokyo Night, Catppuccin, One Dark, Solarized)
- Modüler yapı (terminal-setup.sh, terminal-core.sh, terminal-utils.sh)
- Oh My Zsh kurulumu
- Powerlevel10k desteği
- Zsh pluginleri (auto-suggestions, syntax-highlighting)
- Terminal araçları (FZF, Zoxide, Exa, Bat)
- Tmux desteği ve tema konfigürasyonu
- Otomatik yedekleme sistemi
- Sistem sağlık kontrolü
- Konfigürasyon yönetimi
- Otomatik güncelleme kontrolü
- Debug ve verbose modları

### Desteklenen Platformlar
- Ubuntu 20.04+
- Debian 10+
- Pop!_OS
- Linux Mint
- Diğer Debian tabanlı dağıtımlar

### Desteklenen Terminal Emülatörleri
- GNOME Terminal (tam destek)
- Kitty (tam destek)
- Alacritty (tam destek)
- Diğerleri (sınırlı destek)

## [2.x.x] - 2024-11-xx

### Beta Sürümleri
- Temel işlevsellik testleri
- Tema sistemi denemeleri
- Yedekleme mekanizması geliştirme

## [1.x.x] - 2024-10-xx

### Alpha Sürümleri
- İlk prototip
- Temel Zsh kurulumu
- Basit tema desteği

---

## Gelecek Sürümler

### [3.2.0] - Planlanıyor
- [ ] iTerm2 desteği (macOS)
- [ ] Konsole desteği (KDE)
- [ ] Özel tema yükleme
- [ ] Plugin yöneticisi
- [ ] Web tabanlı konfigürasyon aracı
- [ ] Arch Linux desteği

### [4.0.0] - Planlanıyor
- [ ] GUI arayüz
- [ ] Tema önizleme
- [ ] Canlı tema değiştirme
- [ ] Bulut senkronizasyonu
- [ ] Çoklu profil yönetimi

---

## Katkıda Bulunanlar

Tüm katkıda bulunanlara teşekkürler!

- [@alibedirhan](https://github.com/alibedirhan) - Proje sahibi ve ana geliştirici

## Notlar

- Semantic Versioning kullanılıyor: MAJOR.MINOR.PATCH
- MAJOR: Uyumsuz API değişiklikleri
- MINOR: Geriye dönük uyumlu yeni özellikler
- PATCH: Geriye dönük uyumlu hata düzeltmeleri