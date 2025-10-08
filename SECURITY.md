# Güvenlik Politikası

## Desteklenen Versiyonlar

Şu anda güvenlik güncellemeleri alan versiyonlar:

| Versiyon | Destekleniyor          |
| -------- | ---------------------- |
| 3.2.x    | :white_check_mark:     |
| 3.1.x    | :white_check_mark:     |
| 3.0.x    | :x:                    |
| < 3.0    | :x:                    |

## Güvenlik Açığı Bildirme

Eğer bir güvenlik açığı keşfettiyseniz, lütfen **herkese açık issue açmayın**. Bunun yerine:

### 📧 Özel Bildirim

1. **E-posta ile bildirin:** [güvenlik e-postanızı ekleyin]
2. **GitHub Security Advisory** kullanın: [Security tab](https://github.com/alibedirhan/Theme-after-format/security)

### 📋 Bildirimde Bulunması Gerekenler

- Güvenlik açığının detaylı açıklaması
- Yeniden üretme adımları
- Etkilenen versiyon(lar)
- Olası etki analizi
- Varsa önerilen çözüm

### ⏱️ Yanıt Süresi

- **İlk yanıt:** 48 saat içinde
- **Durum güncellemesi:** 7 gün içinde
- **Yama/düzeltme:** Ciddiyete göre 30 gün içinde

## Güvenlik En İyi Uygulamaları

### 🔒 Script Kullanımı

1. **Root olarak çalıştırmayın**
   ```bash
   # ❌ YANLIŞ
   sudo ./terminal-setup.sh
   
   # ✅ DOĞRU
   ./terminal-setup.sh  # Gerektiğinde sudo isteyecektir
   ```

2. **Scripti doğrulayın**
   ```bash
   # Scripti indirmeden önce GitHub'da inceleyin
   cat terminal-setup.sh | less
   
   # SHA256 kontrolü (gelecekte eklenecek)
   sha256sum -c checksums.txt
   ```

3. **Güvenilir kaynaktan indirin**
   ```bash
   # ✅ Resmi repo
   wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/install.sh
   
   # ❌ Bilinmeyen kaynak
   wget http://example.com/random-script.sh
   ```

### 🛡️ Bizim Güvenlik Önlemlerimiz

- ✅ Root kontrolü (script root olarak çalışmaz)
- ✅ Input validation
- ✅ Otomatik yedekleme
- ✅ Güvenli cleanup (trap handlers)
- ✅ Network timeout'ları
- ✅ Dosya permission kontrolleri
- ✅ Sudo refresh ile güvenli yetki yönetimi

### 🔐 Depolanan Veriler

Script şunları depolar:
- ✅ Yerel config dosyaları (`~/.terminal-setup/`)
- ✅ Yedek dosyaları (`~/.terminal-setup-backup/`)
- ✅ Log dosyaları (`~/.terminal-setup/logs/`)

**Hiçbir veri harici sunuculara gönderilmez.**

### 🌐 Ağ İstekleri

Script sadece şu kaynaklardan veri çeker:
- `github.com` - Oh My Zsh, Powerlevel10k, plugins
- `raw.githubusercontent.com` - Tema dosyaları, güncellemeler
- `8.8.8.8` - İnternet bağlantı kontrolü (ping)

## Bilinen Kısıtlamalar

### ⚠️ Terminal Emulator Desteği

- **Tam Destek:** GNOME Terminal
- **Kısmi Destek:** Tilix, Konsole (renk temaları çalışmayabilir)
- **Desteklenmiyor:** Diğer terminal emulatorler

### ⚠️ Sudo Gereksinimleri

Script şu durumlarda sudo gerektirir:
- Paket kurulumu (`apt install`)
- Shell değiştirme (`chsh`)
- Font kurulumu (sistem fontlarına yazarken)

## Sorumluluk Reddi

- Script "OLDUĞU GİBİ" sağlanmaktadır
- Kullanım riski kullanıcıya aittir
- Üretim sistemlerinde kullanmadan önce test edin
- Önemli verileri yedekleyin

## Güvenlik Güncellemeleri

Güvenlik güncellemelerinden haberdar olmak için:
- ⭐ Repo'yu "Watch" edin
- 📢 [Releases](https://github.com/alibedirhan/Theme-after-format/releases) sayfasını takip edin
- 🔔 GitHub Security Advisories'i etkinleştirin

## Kabul Edilen Güvenlik Açıkları

Şu tür raporlar kabul edilir:
- ✅ Kod injection
- ✅ Privilege escalation
- ✅ Unauthorized file access
- ✅ Command injection
- ✅ Path traversal

Şu tür raporlar kabul **edilmez**:
- ❌ Sosyal mühendislik
- ❌ DoS (script zaten lokal çalışıyor)
- ❌ Rate limiting issues
- ❌ Kullanıcı hatası kaynaklı sorunlar

## İletişim

- 🐛 Genel hatalar: [Issues](https://github.com/alibedirhan/Theme-after-format/issues)
- 🔒 Güvenlik açıkları: [Security Advisory](https://github.com/alibedirhan/Theme-after-format/security)
- 💬 Tartışmalar: [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions)

---

**Güvenliğiniz bizim önceliğimiz. Sorumlu açıklama için teşekkür ederiz!** 🙏