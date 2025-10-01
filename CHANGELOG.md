# Değişiklik Geçmişi

Theme After Format projesindeki tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardını takip eder.

## [Yayınlanmamış]

### Planlanıyor
- Otomatik kurulum parametresi (`--auto-dracula`, `--auto-nord`)
- Dil desteği (İngilizce)
- Özel tema desteği
- Tmux otomatik yapılandırması
- Tilix renk teması desteği

## [2.0.0] - 2025-01-XX

### Eklenen
- Nord renk teması desteği
- İnternet bağlantısı kontrolü
- GNOME Terminal kontrolü
- Gelişmiş hata yönetimi
- Geçici dizin temizliği (trap)
- Modüler kurulum seçenekleri
- İnteraktif menü sistemi

### Değiştirilen
- `set -e` kaldırıldı (daha iyi hata kontrolü için)
- Her fonksiyon kendi hata kontrolünü yapıyor
- Git işlemlerinde hata yakalama iyileştirildi
- Font kurulumu daha güvenilir

### Düzeltilen
- Dracula teması GNOME Terminal profil hatası
- Nord repository klonlama hatası
- Dizin değiştirme sorunları (cd işlemleri)
- gsettings komutlarında hata yakalama
- Yedekleme dizini oluşturma

## [1.0.0] - 2025-01-XX

### Eklenen
- İlk stabil sürüm
- Zsh + Oh My Zsh kurulumu
- Powerlevel10k teması
- Dracula renk teması
- Otomatik yedekleme sistemi
- Pluginler:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - colored-man-pages
- Font kurulumu (MesloLGS NF, Powerline)
- Varsayılan shell değiştirme
- Kaldırma özelliği
- Yedek görüntüleme

### Teknik Özellikler
- Bash script
- İnteraktif menü
- Renkli çıktı
- Hata yönetimi
- Yedekleme sistemi

## [0.5.0] - 2025-01-XX (Beta)

### Eklenen
- Temel script yapısı
- Zsh kurulumu
- Oh My Zsh entegrasyonu
- Basit menü sistemi

### Bilinen Sorunlar
- Hata yönetimi yetersiz
- Nord teması yok
- Font kurulumu eksik

## Değişiklik Türleri

- `Eklenen`: Yeni özellikler
- `Değiştirilen`: Mevcut özelliklerde değişiklikler
- `Kullanımdan Kaldırılan`: Yakında kaldırılacak özellikler
- `Kaldırılan`: Kaldırılan özellikler
- `Düzeltilen`: Hata düzeltmeleri
- `Güvenlik`: Güvenlik yamalarıpreferencias

## Yol Haritası

### v2.1.0 (Yakında)
- [ ] Otomatik kurulum parametreleri
- [ ] Performans iyileştirmeleri
- [ ] Daha fazla renk teması
- [ ] Tilix desteği

### v2.5.0 (Gelecek)
- [ ] İngilizce dil desteği
- [ ] Özel tema oluşturma aracı
- [ ] Tmux otomatik yapılandırması
- [ ] Web tabanlı tema önizleme

### v3.0.0 (Uzun Vadeli)
- [ ] GUI arayüz
- [ ] Tema paylaşma platformu
- [ ] Bulut yedekleme
- [ ] Çoklu dağıtım desteği (Fedora, Arch)

## Versiyon Numaralandırma

Proje [Semantic Versioning](https://semver.org/lang/tr/) kullanır:

- **MAJOR** (2.x.x): Geriye uyumsuz değişiklikler
- **MINOR** (x.1.x): Geriye uyumlu yeni özellikler
- **PATCH** (x.x.1): Geriye uyumlu hata düzeltmeleri

## Katkıda Bulunanlar

Projeye katkıda bulunan herkese teşekkürler!

- [@alibedirhan](https://github.com/alibedirhan) - Proje sahibi ve ana geliştirici

---

[Yayınlanmamış]: https://github.com/alibedirhan/Theme-after-format/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/alibedirhan/Theme-after-format/releases/tag/v2.0.0
[1.0.0]: https://github.com/alibedirhan/Theme-after-format/releases/tag/v1.0.0
[0.5.0]: https://github.com/alibedirhan/Theme-after-format/releases/tag/v0.5.0
