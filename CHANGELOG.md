# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına dayanır ve bu proje [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kullanır.

## [3.2.1] - 2025-01-15

### Eklenen
- **Akıllı Sorun Giderme Asistanı (terminal-assistant.sh)**
  - Kurulum öncesi akıllı tarama sistemi
  - 7 farklı sorun senaryosu için otomatik teşhis
  - İnteraktif sorun giderme sihirbazı
  - Kapsamlı shell kontrolü ve çözüm önerileri

- **5 Yeni Tema**
  - Gruvbox Dark - Retro sıcak tonlar
  - Tokyo Night - Modern mavi/mor
  - Catppuccin Mocha - Pastel renkler
  - One Dark - Atom editor benzeri
  - Solarized Dark - Klasik düşük kontrast

- **Terminal Araçları Desteği**
  - FZF - Fuzzy finder
  - Zoxide - Akıllı cd komutu
  - Exa - Modern ls alternatifi
  - Bat - Syntax highlighting cat

- **Tmux Entegrasyonu**
  - 7 tema için Tmux konfigürasyonu
  - Otomatik tema uygulama
  - Özelleştirilebilir status bar

- **Çoklu Terminal Desteği**
  - Kitty terminal tam desteği
  - Alacritty terminal tam desteği
  - İyileştirilmiş terminal tespiti

- **Gelişmiş Özellikler**
  - Lock mekanizması (tek instance)
  - Signal handling (INT, TERM, HUP)
  - Timeout koruması (tüm ağ işlemleri)
  - Input validation (tüm kullanıcı girdileri)
  - Thread-safe logging
  - Otomatik güncelleme sistemi

- **Modüler Yapı**
  - terminal-setup.sh - Ana script
  - terminal-core.sh - Kurulum fonksiyonları
  - terminal-utils.sh - Yardımcı fonksiyonlar
  - terminal-ui.sh - UI/Görsel katman
  - terminal-themes.sh - Tema tanımları
  - terminal-assistant.sh - Akıllı asistan

- **Komut Satırı Parametreleri**
  - `--health` - Sistem sağlık kontrolü
  - `--scan` - Kurulum öncesi tarama
  - `--update` - Güncelleme kontrolü
  - `--debug` - Debug modu
  - `--verbose` - Detaylı çıktı
  - `--version` - Versiyon bilgisi

### Değiştirilen
- **Tam yeniden yapılandırma (Refactoring)**
  - Monolitik yapıdan modüler yapıya geçiş
  - 6 ayrı modül dosyası
  - İyileştirilmiş hata yönetimi
  - Gelişmiş logging sistemi

- **Menü Sistemi**
  - 9 seçenekten 15 seçeneğe çıkarıldı
  - Modern box-style tasarım
  - Akıllı öneriler sistemi
  - Durum çubuğu (status bar)
  - Renk önizlemeleri

- **Yedekleme Sistemi**
  - Otomatik eski yedek temizleme
  - Yapılandırılabilir yedek sayısı
  - Orijinal sistem durumu kaydetme
  - Güvenli rollback mekanizması

- **Kurulum Süreci**
  - Her adımda doğrulama (verification)
  - Timeout koruması (max 300s)
  - Retry mekanizması (fontlar için)
  - İlerlik göstergesi (progress bar)

- **Hata Yönetimi**
  - 10 kategorili hata kod sistemi
  - Detaylı hata mesajları
  - Otomatik teşhis önerileri
  - Log dosyası referansları

### Düzeltilen
- Zsh kurulumunda timeout sorunu (120s -> 300s)
- Font indirmede retry mekanizması eksikliği
- APT kilit çakışması kontrolü
- Locale sorunları için otomatik düzeltme
- Yarım kalmış kurulum temizleme
- Sudo refresh background process yönetimi
- GNOME Terminal login-shell ayarı
- Shell değişiminde doğrulama kontrolü

### Güvenlik
- Input validation (tüm kullanıcı girdileri)
- Path traversal koruması
- Command injection önleme
- Safe temp directory kullanımı
- Lock file ile race condition önleme

### Performans
- Paralel font indirme (4 dosya)
- Lazy loading (modüller)
- Optimized log rotation
- Efficient backup cleanup

## [2.0.0] - 2024-12-01

### Eklenen
- Nord teması desteği
- Modüler kurulum seçenekleri
- Otomatik yedekleme sistemi
- GNOME Terminal profil yönetimi
- Plugin kurulum desteği
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - colored-man-pages

### Değiştirilen
- İnteraktif menü sistemi eklendi
- Hata yönetimi iyileştirildi
- Dokümantasyon genişletildi

### Düzeltilen
- Font kurulumu hataları
- Shell değiştirme sorunları
- Internet kontrolü iyileştirildi

## [1.0.0] - 2024-10-15

### Eklenen
- İlk sürüm
- Dracula teması
- Zsh + Oh My Zsh kurulumu
- Powerlevel10k teması
- MesloLGS NF fontları
- Temel yedekleme
- Kaldırma fonksiyonu

---

## Versiyon Notasyonu

- **MAJOR** - Breaking changes (geriye uyumsuz)
- **MINOR** - Yeni özellikler (geriye uyumlu)
- **PATCH** - Bug fixes (geriye uyumlu)

## Gelecek Sürümler (Roadmap)

### [3.3.0] - Planlanıyor
- [ ] Fish shell desteği
- [ ] macOS desteği
- [ ] Windows WSL desteği
- [ ] Zellij terminal multiplexer desteği
- [ ] Tema önizleme sistemi
- [ ] Özel tema oluşturma wizard'ı

### [3.4.0] - Planlanıyor
- [ ] Otomatik test suite
- [ ] CI/CD pipeline
- [ ] Docker container desteği
- [ ] Ansible playbook
- [ ] NixOS konfigürasyonu

### [4.0.0] - Gelecek
- [ ] Web-based yapılandırma arayüzü
- [ ] Bulut senkronizasyon
- [ ] Topluluk tema deposu
- [ ] Plugin ekosistemi