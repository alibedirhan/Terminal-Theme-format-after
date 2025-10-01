# Theme After Format

Terminal özelleştirmelerini format sonrası tek komutla geri yükleyin.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-orange.svg)](https://www.linux.org/)

## Hakkında

Format attıktan sonra terminal özelleştirmelerini tek tek kurmaktan sıkıldınız mı? Bu script size yardımcı olacak!

**Theme After Format** ile:
- Zsh + Oh My Zsh
- Powerlevel10k teması
- Dracula veya Nord renk teması
- Syntax highlighting & Auto-suggestions

Tek komutla kurun, tek komutla kaldırın.

## Özellikler

- **İnteraktif Menü**: Kolay kullanım için menü sistemi
- **İki Tema Seçeneği**: Dracula (mor/pembe) veya Nord (mavi/gri)
- **Otomatik Yedekleme**: Mevcut ayarlarınızı yedekler
- **Modüler Kurulum**: İstediğiniz bileşenleri seçin
- **Güvenli Kaldırma**: Tek tıkla eski haline döndürün
- **Hata Yönetimi**: İnternet, GNOME Terminal kontrolleri

## Kurulum

### Hızlı Başlangıç

```bash
# Script'i indir
wget https://raw.githubusercontent.com/alibedirhan/Theme-after-format/main/terminal-setup.sh

# Çalıştırma yetkisi ver
chmod +x terminal-setup.sh

# Çalıştır
./terminal-setup.sh
```

### Git ile

```bash
git clone https://github.com/alibedirhan/Theme-after-format.git
cd Theme-after-format
chmod +x terminal-setup.sh
./terminal-setup.sh
```

## Kullanım

Script'i çalıştırdığınızda interaktif menü açılır:

```
╔══════════════════════════════════════════════════════════╗
║         TERMİNAL ÖZELLEŞTİRME KURULUM ARACI             ║
╚══════════════════════════════════════════════════════════╝

1) Tam Kurulum (Dracula teması)
2) Tam Kurulum (Nord teması)
3) Sadece Zsh + Oh My Zsh
4) Sadece Powerlevel10k Teması
5) Sadece Dracula Renk Teması
6) Sadece Nord Renk Teması
7) Sadece Pluginler
8) Tümünü Kaldır (Yedekten Geri Yükle)
9) Yedekleri Göster
0) Çıkış
```

### Önerilen Kurulum

İlk kez kullanıyorsanız:
- **Seçenek 1** veya **2**: Tam kurulum (Dracula veya Nord)

Sadece temayı değiştirmek istiyorsanız:
- **Seçenek 5** veya **6**: Renk teması değişikliği

### Kurulum Sonrası

1. Terminal'i kapatıp yeniden açın
2. Powerlevel10k yapılandırma wizard'ı otomatik başlayacak
3. Sorulara cevap vererek görünümü özelleştirin
4. Daha sonra `p10k configure` ile yeniden yapılandırabilirsiniz

## Temalar

### Dracula Theme

Mor ve pembe tonları, yüksek kontrast.

**Renk Paleti:**
- Background: `#282A36`
- Foreground: `#F8F8F2`
- Vurgular: Mor, pembe, cyan

**Kimler İçin:**
- Yüksek kontrast seviyorsanız
- Canlı renkler hoşunuza gidiyorsa
- Gece çalışması yapıyorsanız

### Nord Theme

Mavi ve gri tonları, düşük kontrast.

**Renk Paleti:**
- Background: `#2E3440`
- Foreground: `#D8DEE9`
- Vurgular: Mavi, cyan, yeşil

**Kimler İçin:**
- Göz yorgunluğunu azaltmak istiyorsanız
- Soğuk tonları seviyorsanız
- Minimalist tasarım tercih ediyorsanız

## Gereksinimler

### Sistem Gereksinimleri

- Ubuntu 20.04+ / Debian 10+ / Linux Mint 20+
- Bash 4.0+
- İnternet bağlantısı
- sudo yetkisi

### Desteklenen Terminal Emulatorler

- ✅ GNOME Terminal (tam destek)
- ⚠️ Tilix (kısmi destek - renk temaları çalışmayabilir)
- ⚠️ Konsole (kısmi destek - renk temaları çalışmayabilir)
- ❌ Diğerleri (test edilmedi)

**Not:** Renk temaları (Dracula/Nord) GNOME Terminal gerektirir. Zsh ve Powerlevel10k tüm terminal emulatorlerde çalışır.

## Yedekleme ve Geri Yükleme

### Otomatik Yedekleme

Script her kurulumda otomatik yedek oluşturur:
- `~/.bashrc`
- `~/.zshrc`
- `~/.p10k.zsh`
- Mevcut shell bilgisi
- GNOME Terminal profil ID'si

Yedekler: `~/.terminal-setup-backup/`

### Geri Yükleme

```bash
./terminal-setup.sh
# Menüden "8) Tümünü Kaldır" seçin
```

Bu işlem:
- Oh My Zsh'yi kaldırır
- Zsh konfigürasyonlarını siler
- Bash'e geri döner
- Yedekten .bashrc'yi geri yükler

## Sorun Giderme

### Renk temaları uygulanmıyor

**Sebep:** GNOME Terminal kullanmıyorsunuz.

**Çözüm:**
```bash
# Hangi terminal kullandığınızı kontrol edin
ps -o comm= -p $PPID

# GNOME Terminal kurulumu
sudo apt install gnome-terminal
```

### Powerlevel10k wizard açılmıyor

**Çözüm:**
```bash
# Manuel başlatma
p10k configure
```

### Karakterler bozuk görünüyor

**Sebep:** Font kurulmamış veya terminal font ayarları yanlış.

**Çözüm:**
```bash
# Terminal Preferences → Profile → Custom Font → MesloLGS NF Regular
```

### Zsh çok yavaş açılıyor

**Çözüm:**
```bash
# Performans analizi
p10k debug

# Instant prompt'u devre dışı bırak
nano ~/.zshrc
# Şu bloğu yoruma al (başına # ekle):
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt...
```

### "chsh: PAM: Authentication failure" hatası

**Çözüm:**
```bash
# sudo ile shell değiştir
sudo chsh -s $(which zsh) $USER
```

## Sık Sorulan Sorular

**S: Format sonrası kullanabilir miyim?**  
C: Evet, tam olarak bunun için tasarlandı. Sistemi kurduktan sonra tek komutla tüm özelleştirmeleri geri yükleyin.

**S: Mevcut ayarlarım kaybolur mu?**  
C: Hayır, script otomatik yedekleme yapar. İsterseniz geri dönebilirsiniz.

**S: Root olarak çalıştırmalı mıyım?**  
C: Hayır! Normal kullanıcı olarak çalıştırın. Gerektiğinde sudo isteyecektir.

**S: Her iki temayı da deneyebilir miyim?**  
C: Evet, istediğiniz zaman tema değiştirebilirsiniz (seçenek 5 veya 6).

**S: Pluginler ne işe yarar?**  
C: 
- `zsh-autosuggestions`: Komut önerileri
- `zsh-syntax-highlighting`: Sözdizimi renklendirme
- `colored-man-pages`: Renkli man sayfaları

**S: Disk alanı ne kadar?**  
C: Yaklaşık 50-100 MB (Oh My Zsh, tema, fontlar dahil)

## Güncelleme

```bash
cd Theme-after-format
git pull origin main
./terminal-setup.sh
```

## Kaldırma

### Script ile

```bash
./terminal-setup.sh
# Seçenek 8: Tümünü Kaldır
```

### Manuel

```bash
# Oh My Zsh kaldırma
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zsh_history ~/.p10k.zsh

# Bash'e geri dön
chsh -s $(which bash)

# Zsh paketini kaldır (opsiyonel)
sudo apt remove zsh
sudo apt autoremove
```

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

### Hızlı Katkı

1. Fork'layın
2. Feature branch: `git checkout -b feature/YeniOzellik`
3. Commit: `git commit -m 'Yeni özellik eklendi'`
4. Push: `git push origin feature/YeniOzellik`
5. Pull Request açın

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## Teşekkürler

Bu proje şu harika projeleri kullanır:

- [Oh My Zsh](https://ohmyz.sh/) - Zsh konfigürasyon framework'ü
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh teması
- [Dracula Theme](https://draculatheme.com/) - Renk teması
- [Nord Theme](https://www.nordtheme.com/) - Renk teması
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Komut önerileri
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Sözdizimi vurgulama

## İletişim

- GitHub: [@alibedirhan](https://github.com/alibedirhan)
- Issues: [Proje Issues](https://github.com/alibedirhan/Theme-after-format/issues)

## Ekran Görüntüleri

### Dracula Theme

![Dracula](screenshots/dracula.png)

### Nord Theme

![Nord](screenshots/nord.png)

---

⭐ Beğendiyseniz yıldız vermeyi unutmayın!

Made with ❤️ by [Ali Bedirhan](https://github.com/alibedirhan)
