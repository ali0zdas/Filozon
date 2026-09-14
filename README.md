# 🛒 Filozon - E-Ticaret & Bulut Depolama Uygulaması

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-8A2BE2?style=for-the-badge)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen?style=for-the-badge)]()

**Filozon**, modern e-ticaret deneyimi ile bulut dosya depolama/görüntüleme servislerini tek bir çatıda buluşturan, Flutter ve Firebase altyapısıyla geliştirilmiş kapsamlı ve hibrit (Android & Web) bir mobil/web uygulamasıdır.

---

## 🚀 Öne Çıkan Özellikler

### 🛍️ 1. E-Ticaret & Alışveriş Deneyimi
- **Kategori & Ürün Yönetimi:** Firebase Cloud Firestore ve FakeStore API entegrasyonu ile zengin ürün kataloğu.
- **Detaylı Ürün Sayfası:** Ürün fotoğrafları, açıklamalar, fiyatlandırma ve stok bilgisi.
- **Sepet & Favoriler:** Anlık durum yönetimi (GetX) ile sepete ekleme, adet güncelleme, sepet tutarı hesaplama ve favorilere kaydetme.
- **Sipariş & Adres Yönetimi:** Birden fazla teslimat adresi tanımlama, sipariş oluşturma ve geçmiş siparişlerin durumlarını listeleme.
- **Ödeme Adımları:** Kredi kartı arayüzü, form doğrulama ve güvenli ödeme simülasyonu.

### ☁️ 2. Filozon Cloud (Kişisel Bulut Depolama)
- **Çoklu Dosya Formatı:** Fotoğraf, video ve PDF belgelerini Firebase Storage'a yükleme ve yönetme.
- **Dahili Önizleyiciler:**
  - 📄 PDF Görüntüleyici
  - 🖼️ Fotoğraf Görüntüleyici
  - 🎥 Video Oynatıcı
- **Hibrit Yükleme Desteği:** Android üzerinde yerel dosya yolu (`putFile`), Web üzerinde ise bellek tamponu (`putData` / `Uint8List`) ile yüksek performanslı dosya transferi.

### 🛡️ 3. Yönetici (Admin) Kontrol Paneli
- **Dashboard & İstatistikler:** Toplam satışlar, aktif kullanıcılar ve sipariş istatistikleri.
- **Ürün & Kategori Yönetimi:** Yeni ürün/kategori oluşturma, düzenleme, stok ve resim güncelleme.
- **Sipariş Takibi:** Gelen siparişlerin durumlarını onaylama, kargolama ve tamamlama.
- **Kullanıcı Yönetimi:** Kayıtlı kullanıcıları inceleme ve rol bazlı erişim denetimi.
- **Middleware Koruması:** Yetkisiz erişimleri engelleyen GetX tabanlı `AdminMiddleware`.

### 👤 4. Kullanıcı & Güvenlik
- Firebase Authentication ile E-Posta / Şifre kayıt ve giriş akışı.
- Misafir Kullanıcı (Guest Mode) modu ile üye olmadan ürünleri inceleme imkânı.
- Profil bilgileri ve avatar güncelleme desteği.

---

## 🏗️ Mimari ve Teknolojiler

- **Çatı (Framework):** Flutter (3.x) & Dart (3.x)
- **Durum Yönetimi (State Management) & Rotalar:** [GetX](https://pub.dev/packages/get)
- **Veritabanı & Backend Servisleri:**
  - **Firebase Authentication:** Kimlik doğrulama
  - **Cloud Firestore:** NoSQL veri saklama ve gerçek zamanlı senkronizasyon
  - **Firebase Storage:** Dosya ve medya saklama alanı
- **Ağ & API:** `http` paketi ile RESTful FakeStore API entegrasyonu
- **Tasarım & UI:** Material 3, Custom Drawer, Onboarding ekranları, Google Fonts (Kanit)

---

## 📁 Proje Dizin Yapısı

```text
lib/
├── app/
│   ├── bindings/             # GetX Dependency Injection bağımlılık tanımları
│   ├── controllers/          # İş mantığı ve reaktif GetX Controller sınıfları
│   ├── middlewares/          # Rota ve rol güvenlik kontrolleri (Admin vb.)
│   ├── models/               # Firestore ve API veri modelleri (JSON serialization)
│   ├── routes/               # Sayfa rotaları ve navigasyon haritası (AppPages, AppRoutes)
│   ├── services/             # Firebase, Auth, Firestore ve harici API servisleri
│   └── ui/
│       ├── pages/            # Ekranlar (Home, Admin, Cloud, Payment, Login, vb.)
│       └── widgets/          # Yeniden kullanılabilir arayüz bileşenleri
├── firebase_options.dart     # Firebase platform yapılandırması
└── main.dart                 # Uygulama başlangıç noktası (Initialization & Theme)
```

---

## ⚙️ Kurulum ve Başlangıç

### Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code & Flutter Eklentileri
- Geçerli bir Firebase Projesi

### Adımlar

1. **Depoyu Klonlayın:**
   ```bash
   git clone <REPO_URL>
   cd filozon_kodfu
   ```

2. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Firebase Yapılandırması:**
   - Kendi Firebase projenizi yapılandırmak için FlutterFire CLI kullanabilir veya `android/app/google-services.json` dosyasını kendi projenizle eşleştirebilirsiniz:
     ```bash
     flutterfire configure
     ```

4. **Uygulamayı Başlatın:**
   - **Android:**
     ```bash
     flutter run -d android
     ```
   - **Web (Chrome):**
     ```bash
     flutter run -d chrome
     ```

---

## 📄 Lisans

Bu proje eğitim ve portfolyo amaçlı geliştirilmiştir. Tüm hakları saklıdır.
