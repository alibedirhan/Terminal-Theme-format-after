# Katkıda Bulunma Rehberi

Theme After Format projesine katkıda bulunmak istediğiniz için teşekkür ederiz! 🎉

## 📋 İçindekiler

- [Davranış Kuralları](#davranış-kuralları)
- [Nasıl Katkıda Bulunabilirim?](#nasıl-katkıda-bulunabilirim)
- [Geliştirme Ortamı](#geliştirme-ortamı)
- [Kod Standartları](#kod-standartları)
- [Commit Mesajları](#commit-mesajları)
- [Pull Request Süreci](#pull-request-süreci)
- [Test Etme](#test-etme)

## Davranış Kuralları

### Topluluk Standartlarımız

Bu projede:
- ✅ Saygılı ve yapıcı iletişim
- ✅ Farklı bakış açılarına açık olmak
- ✅ Yapıcı eleştiri vermek ve kabul etmek
- ✅ Topluluk çıkarlarını ön planda tutmak

Kabul edilemez davranışlar:
- ❌ Hakaret veya aşağılama
- ❌ Trolleme veya spam
- ❌ Kişisel bilgileri paylaşmak
- ❌ Profesyonel olmayan davranışlar

## Nasıl Katkıda Bulunabilirim?

### 🐛 Hata Bildirme

Hata bulduysanız:

1. **Önce kontrol edin**: [Issues](https://github.com/alibedirhan/Theme-after-format/issues) sayfasında aynı hata bildirilmiş mi?
2. **Yeni issue açın**: Detaylı bilgi verin
   - Hangi versiyon kullanıyorsunuz?
   - Sisteminiz: Ubuntu version, terminal emulator
   - Hatayı yeniden üretme adımları
   - Beklenen davranış vs gerçek davranış
   - Log dosyası çıktısı
   - Ekran görüntüleri (varsa)

**Issue Template:**
```markdown
## Hata Açıklaması
[Hatayı kısaca açıklayın]

## Yeniden Üretme Adımları
1. Git '...'
2. Tıkla '....'
3. Scroll down to '....'
4. Hatayı gör

## Beklenen Davranış
[Ne olmasını bekliyordunuz?]

## Ekran Görüntüleri
[Varsa ekleyin]

## Sistem Bilgileri
- OS: [örn. Ubuntu 22.04]
- Terminal: [örn. GNOME Terminal]
- Script Version: [örn. 3.2.4]
- Shell: [örn. Zsh 5.8]

## Log Çıktısı
```bash
cat ~/.terminal-setup/logs/terminal-setup.log
```
```

### ✨ Özellik Önerme

Yeni özellik öneriniz varsa:

1. **Feature Request issue açın**
2. Şunları açıklayın:
   - Özellik ne yapacak?
   - Neden gerekli?
   - Kullanım senaryoları
   - Örnek implementasyon (varsa)

### 🔧 Kod Katkısı

#### Küçük Değişiklikler
- Typo düzeltmeleri
- Dokümantasyon iyileştirmeleri
- Küçük bug fix'ler

➡️ Direkt Pull Request açabilirsiniz.

#### Büyük Değişiklikler
- Yeni özellikler
- Büyük refactoring'ler
- Mimari değişiklikler

➡️ Önce bir issue açıp tartışın.

## Geliştirme Ortamı

### Gereksinimler

```bash
# Minimum
- Ubuntu 20.04+ / Debian 10+
- Bash 4.0+
- Git
- sudo yetkisi

# Geliştirme için önerilen
- ShellCheck (static analysis)
- bats (Bash testing)
```

### Kurulum

```bash
# 1. Repo'yu fork'layın
# 2. Clone edin
git clone https://github.com/KULLANICI-ADINIZ/Theme-after-format.git
cd Theme-after-format

# 3. Upstream'i ekleyin
git remote add upstream https://github.com/alibedirhan/Theme-after-format.git

# 4. Test edin
chmod +x test.sh
./test.sh
```

### Branch Stratejisi

```bash
# main branch'ten yeni bir branch oluşturun
git checkout -b feature/yeni-ozellik

# veya
git checkout -b fix/bug-aciklamasi

# veya
git checkout -b docs/dokumantasyon-guncelleme
```

## Kod Standartları

### Bash Script Standartları

```bash
# 1. Shebang kullanın
#!/bin/bash

# 2. Strict mode
set -euo pipefail

# 3. Fonksiyon isimlendirme: snake_case
install_package() {
    local package_name="$1"
    # ...
}

# 4. Değişkenler: UPPERCASE (global), lowercase (local)
readonly GLOBAL_CONFIG="/etc/config"
local temp_file="/tmp/file"

# 5. Hata kontrolü
if ! command -v git &> /dev/null; then
    log_error "Git bulunamadı"
    return 1
fi

# 6. String comparison
if [[ "$var" == "value" ]]; then
    # ...
fi

# 7. Exit codes kullanın
readonly ERR_NETWORK=1
readonly ERR_PERMISSION=2
```

### Linting

```bash
# ShellCheck kullanın
shellcheck terminal-setup.sh
shellcheck terminal-core.sh
shellcheck terminal-utils.sh

# Tüm scriptleri kontrol et
find . -name "*.sh" -exec shellcheck {} \;
```

### Kod Organizasyonu

```bash
# Dosya yapısı
# ============================================================================
# Script Başlığı
# v3.2.4 - Modül Açıklaması
# ============================================================================

# Sabitler
readonly CONFIG_DIR="$HOME/.config"

# Global değişkenler
THEME_NAME=""

# Fonksiyonlar (alfabetik sıra)
function_a() { }
function_b() { }

# Main execution
main() { }

# Script başlat
main "$@"
```

## Commit Mesajları

### Format

```
<tip>(<kapsam>): <kısa açıklama>

<detaylı açıklama>

<footer>
```

### Tipler

- `feat`: Yeni özellik
- `fix`: Bug düzeltme
- `docs`: Dokümantasyon
- `style`: Kod formatı (mantık değişikliği yok)
- `refactor`: Refactoring
- `test`: Test ekleme/düzeltme
- `chore`: Diğer (dependency güncellemeleri, vb.)

### Örnekler

```bash
# İyi commit mesajları ✅
feat(themes): Tokyo Night teması eklendi
fix(core): Font kurulum hatası düzeltildi
docs(readme): Kurulum adımları güncellendi
refactor(utils): Logging sistemi iyileştirildi

# Kötü commit mesajları ❌
Update
Fixed stuff
asdasd
WIP
```

### Commit Best Practices

```bash
# Küçük, atomik commitler
git add terminal-themes.sh
git commit -m "feat(themes): Add Gruvbox theme"

# İlgisiz değişiklikleri ayırın
git add file1.sh
git commit -m "feat: Feature 1"
git add file2.sh  
git commit -m "fix: Fix for feature 2"

# Commit'ten önce test edin
./test.sh
git commit -m "..."
```

## Pull Request Süreci

### 1. Kodu Hazırlayın

```bash
# Upstream'den güncel çekin
git fetch upstream
git rebase upstream/main

# Testleri çalıştırın
./test.sh

# ShellCheck kontrolü
shellcheck *.sh

# Değişikliklerinizi commit edin
git add .
git commit -m "feat: Yeni özellik"
```

### 2. Pull Request Açın

**PR Template:**

```markdown
## Değişiklik Tipi
- [ ] Bug fix
- [ ] Yeni özellik
- [ ] Refactoring
- [ ] Dokümantasyon

## Açıklama
[Değişikliklerinizi detaylı açıklayın]

## Motivasyon
[Neden bu değişiklik gerekli?]

## Test Edildi mi?
- [ ] Lokal olarak test edildi
- [ ] test.sh başarıyla geçti
- [ ] ShellCheck kontrolünden geçti
- [ ] Ubuntu 22.04'te test edildi
- [ ] Ubuntu 20.04'te test edildi

## İlgili Issue
Fixes #123

## Ekran Görüntüleri
[Varsa ekleyin]

## Checklist
- [ ] Kod standartlarına uygun
- [ ] Dokümantasyon güncellendi
- [ ] CHANGELOG.md güncellendi
- [ ] Geriye dönük uyumluluk korundu
```

### 3. Code Review

- Sabırlı olun - review zaman alabilir
- Geri bildirimlere açık olun
- Gerekli değişiklikleri yapın
- Tartışmalara katılın

### 4. Merge

Merge şartları:
- ✅ En az 1 onay
- ✅ Tüm testler geçmeli
- ✅ Conflict yok
- ✅ CI/CD başarılı

## Test Etme

### Manuel Test

```bash
# Test scriptini çalıştırın
./test.sh

# Belirli bir senaryoyu test edin
./terminal-setup.sh
# Menüden ilgili seçeneği test edin
```

### Otomatik Test

```bash
# test.sh içerikler:
# - Dosya varlık kontrolleri
# - Sözdizimi kontrolleri
# - Bağımlılık kontrolleri
# - Fonksiyon kontrolleri
# - Versiyon kontrolleri
# - ShellCheck analizi
```

### Test Senaryoları

1. **Temiz kurulum** (format sonrası)
2. **Upgrade** (mevcut kurulum üzerine)
3. **Tema değiştirme**
4. **Kaldırma ve rollback**
5. **Farklı Ubuntu versiyonları**
6. **Farklı terminal emulatorler**

## Sürüm Yönetimi

Semantic Versioning kullanıyoruz: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: Yeni özellikler (geriye uyumlu)
- **PATCH**: Bug fixes

## İletişim

- 💬 [Discussions](https://github.com/alibedirhan/Theme-after-format/discussions) - Soru sormak için
- 🐛 [Issues](https://github.com/alibedirhan/Theme-after-format/issues) - Bug raporu için
- 📧 E-posta: [e-postanız]

## Lisans

Katkıda bulunarak, katkılarınızın MIT lisansı altında lisanslanmasını kabul edersiniz.

---

**Teşekkürler! 🙏 Her katkı değerlidir.**