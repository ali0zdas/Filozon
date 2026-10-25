# 🛒 Filozon - E-Ticaret & Bulut Depolama Uygulaması

<p align="center">
  <a href="README.md">🇬🇧 English</a> • 
  <a href="README.tr.md">🇹🇷 Türkçe</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/GetX-8A2BE2?style=for-the-badge" alt="GetX" />
  <img src="https://img.shields.io/badge/UI-Glassmorphism-00C4B4?style=for-the-badge" alt="Glassmorphism" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen?style=for-the-badge" alt="Platform" />
</p>

---

> ℹ️ **Not:** Bu proje staj sürecinde portfolyo ve eğitim amaçlı geliştirilmiş hibrit bir Flutter projesidir.

**Filozon**, modern e-ticaret deneyimi ile kişisel bulut dosya depolama/görüntüleme servislerini tek bir çatı altında buluşturan, **Flutter** ve **Firebase** altyapısıyla geliştirilmiş hibrit (Android & Web) bir mobil ve web uygulamasıdır. Proje genelinde **Glassmorphism (buzlu cam efekti)** tasarım dili ve akıcı animasyonlar kullanılmıştır.

---

## 📸 Ekran Görüntüleri

| Giriş Yap (Glassmorphism) | Kayıt Ol (Glassmorphism) |
| :---: | :---: |
| <img src="screenshots/signinfilozon.png" width="380" alt="Giriş Ekranı"/> | <img src="screenshots/signupfilozon.png" width="380" alt="Kayıt Ekranı"/> |

| Yönetici Paneli | Ödeme / Kart Tasarımı |
| :---: | :---: |
| <img src="screenshots/adminfilozon.png" width="380" alt="Yönetici Paneli"/> | <img src="screenshots/filozoncard.png" width="380" alt="Ödeme ve Kredi Kartı"/> |

---

## ✨ Tasarım: Glassmorphism Estetiği

Uygulamanın görsel kimliğinde modern **Glassmorphism** (buzlu cam efekti) mimarisi ön plandadır:
- Dinamik degrade (gradient) arka planlar üzerinde yarı saydam buzlu cam paneller (`GlassmorphicContainer`).
- Gerçek zamanlı arka plan bulanıklaştırma (`BackdropFilter` & Gaussian blur).
- Yumuşak ışık kırılmaları, sınır çizgileri (borders) ve gölge derinliği ile zenginleştirilmiş modern kartlar ve butonlar.
- Google Fonts **Kanit** tipografisi ile uyumlu, Material 3 standartlarında kullanıcı arayüzü.

---

## 🚀 Öne Çıkan Özellikler

### 🛍️ 1. E-Ticaret & Alışveriş Deneyimi
- **Kategori & Ürün Yönetimi:** Firebase Cloud Firestore ve FakeStore API entegrasyonu ile zengin ürün kataloğu.
- **Detaylı Ürün Sayfası:** Ürün fotoğrafları, açıklamalar, dinamik fiyatlandırma ve stok bilgisi.
- **Sepet & Favoriler:** Anlık durum yönetimi (GetX) ile sepete ekleme, adet güncelleme, sepet tutarı hesaplama ve favorilere kaydetme.
- **Sipariş & Adres Yönetimi:** Birden fazla teslimat adresi tanımlama, sipariş oluşturma ve geçmiş siparişlerin durumlarını listeleme.
- **Ödeme Adımları:** İnteraktif kredi kartı arayüzü, form doğrulama ve güvenli ödeme simülasyonu.

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

- **Çatı (Framework):** Flutter & Dart
- **Durum Yönetimi (State Management) & Rotalar:** [GetX](https://pub.dev/packages/get)
- **Arayüz & Tasarım:** Glassmorphism (`glassmorphism`), Material 3, Google Fonts (Kanit)
- **Veritabanı & Backend Servisleri:**
  - **Firebase Authentication:** Güvenli kullanıcı kimlik doğrulama
  - **Cloud Firestore:** NoSQL veri saklama ve anlık senkronizasyon
  - **Firebase Storage:** Medya ve bulut dosya saklama alanı
- **Ağ & API:** `http` paketi ile RESTful FakeStore API entegrasyonu

---

## 📁 Proje Dizin Yapısı

```text
lib/
├── app/
│   ├── bindings/             # GetX Dependency Injection bağımlılık tanımları
│   ├── controllers/          # İş mantığı ve reaktif GetX Controller sınıfları
│   ├── middlewares/          # Rota ve rol güvenlik kontrolleri (AdminMiddleware vb.)
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

## 📄 Lisans & Bilgilendirme

Bu proje staj sürecinde eğitim, araştırma ve portfolyo gösterimi amacıyla geliştirilmiştir. Tüm hakları saklıdır.
