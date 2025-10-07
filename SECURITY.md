# Güvenlik Politikası

## Desteklenen Versiyonlar

Şu anda aşağıdaki versiyonlar güvenlik güncellemeleri alır:

| Versiyon | Destekleniyor          |
| -------- | ---------------------- |
| 3.2.x    | :white_check_mark:     |
| 3.1.x    | :white_check_mark:     |
| 3.0.x    | :x:                    |
| 2.x      | :x:                    |
| 1.x      | :x:                    |

## Güvenlik Açığı Bildirme

### Lütfen Güvenlik Açıklarını HERKESE AÇIK Bildirmeyin

Güvenlik açığı keşfettiyseniz, lütfen bunu genel issue tracker'da **AÇMAYIN**. Bunun yerine:

1. **GitHub Security Advisory** kullanın
   - Repository → Security → Advisories → New draft security advisory

2. **Veya bana doğrudan ulaşın**
   - GitHub profilim üzerinden

### Beklenen Süreç

1. **Rapor**: Güvenlik açığını detaylı bildirin
2. **Onay**: 48 saat içinde yanıt
3. **Değerlendirme**: 7 gün içinde risk analizi
4. **Düzeltme**: Kritik sorunlar için 30 gün, diğerleri için 90 gün
5. **Açıklama**: Düzeltme yayınlandıktan sonra koordineli açıklama

### Raporunuzda Bulunması Gerekenler

- Güvenlik açığının tipi (örn: code injection, privilege escalation)
- Etkilenen dosya(lar) ve satır numaraları
- Yeniden oluşturma adımları
- Potansiyel etki
- Önerilen düzeltme (varsa)

## Güvenlik Önlemleri

Bu proje aşağıdaki güvenlik önlemlerini içerir:

### Input Validation

```bash
# Tüm kullanıcı girdileri validate edilir
if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
    log_error "Geçersiz seçim"
    return 1
fi
```

### Path Traversal Koruması

```bash
# Güvenli dosya yolları
readonly BACKUP_DIR="$HOME/.terminal-setup/backups"
readonly LOG_DIR="$HOME/.terminal-setup/logs"

# Path traversal önleme
if [[ "$file_path" != "$BACKUP_DIR"/* ]]; then
    log_error "Geçersiz dosya yolu"
    return 1
fi
```

### Command Injection Önleme

```bash
# YANLIŞ (vulnerable)
eval "rm -rf $user_input"

# DOĞRU (safe)
if [[ -d "$validated_path" ]]; then
    rm -rf "$validated_path"
fi
```

### Timeout Koruması

```bash
# Tüm ağ işlemleri timeout ile
timeout 300 sudo apt install -y zsh
timeout 30 wget "$url" -O "$file"
timeout 60 git clone --depth=1 "$repo"
```

### Lock File Mekanizması

```bash
# Race condition önleme
if [[ -f "$LOCK_FILE" ]]; then
    local lock_pid=$(cat "$LOCK_FILE")
    if kill -0 "$lock_pid" 2>/dev/null; then
        echo "Başka instance çalışıyor"
        exit 1
    fi
fi
echo $$ > "$LOCK_FILE"
```

### Safe Temp Directory

```bash
# Güvenli geçici dizin
TEMP_DIR=$(mktemp -d -t terminal-setup.XXXXXXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT
```

## Bilinen Güvenlik Konuları

### Sudo Kullanımı

Script, aşağıdaki işlemler için sudo yetkisi gerektirir:

- Paket kurulumu (`apt install`)
- Shell değiştirme (`chsh`)
- Sistem genelinde konfigürasyon

**Risk Azaltma:**
- Sudo sadece gerektiğinde istenir
- Tüm sudo komutları loglanır
- Kullanıcı onayı alınır

### Ağ İndirmeleri

Script, GitHub ve diğer kaynaklardan dosya indirir.

**Risk Azaltma:**
- HTTPS kullanımı (MITM koruması)
- Dosya boyutu kontrolü
- Timeout koruması
- Hash doğrulama (gelecek sürümlerde)

### Shell Script Execution

Script, shell kodu çalıştırır.

**Risk Azaltma:**
- ShellCheck ile kod analizi
- Input validation
- Error handling
- Safe defaults

## Güvenlik En İyi Pratikleri (Kullanıcılar İçin)

### Script'i İndirirken

```bash
# GÜVENLI: Doğrudan GitHub'dan indir
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh

# GÜVENSIZ: Bilinmeyen kaynaklardan indirme
wget http://random-site.com/script.sh
```

### Çalıştırmadan Önce

```bash
# 1. Kodu incele
cat terminal-setup.sh

# 2. ShellCheck ile kontrol et
shellcheck terminal-setup.sh

# 3. Syntax check
bash -n terminal-setup.sh
```

### Çalıştırırken

```bash
# DOĞRU: Normal kullanıcı olarak çalıştır
./terminal-setup.sh

# YANLIŞ: Root olarak çalıştırma
sudo ./terminal-setup.sh  # YAPMAYIN!
```

### Kurulumdan Sonra

```bash
# Log dosyasını incele
cat ~/.terminal-setup/logs/terminal-setup.log

# Yedekleri kontrol et
ls -la ~/.terminal-setup/backups/

# Değişiklikleri gözden geçir
diff ~/.bashrc ~/.terminal-setup/backups/bashrc_*
```

## Güvenlik Güncellemeleri

Güvenlik güncellemeleri:

1. **Kritik**: 24-48 saat içinde
2. **Yüksek**: 7 gün içinde
3. **Orta**: 30 gün içinde
4. **Düşük**: Bir sonraki minor release'de

## Teşekkürler

Güvenlik araştırmacılarına ve sorumlu açıklama yapan herkese teşekkür ederiz.

### Hall of Fame (Gelecekte)

Güvenlik açığı bildiren kişiler buraya eklenecek.

## İletişim

Güvenlik soruları için:
- GitHub Security Advisory (tercih edilir)
- GitHub profilim üzerinden

---

**Not:** Bu bir açık kaynak projedir. Kodu inceleyebilir, test edebilir ve güvenlik iyileştirmeleri önerebilirsiniz.
