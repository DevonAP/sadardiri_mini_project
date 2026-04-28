# 🎥 Video Demo
[![Video Demo SadarDiri](https://img.youtube.com/vi/zCiviXauPro/maxresdefault.jpg)](https://youtu.be/zCiviXauPro)

---

# SadarDiri: Psychological Screening Log 🧠

**SadarDiri** adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu pengguna melakukan skrining kesehatan mental secara mandiri dan berkala. Aplikasi ini menggunakan instrumen standar **DASS-42** (Depression Anxiety Stress Scales) untuk mengukur tingkat depresi, kecemasan, dan stres pengguna.

Aplikasi ini mengintegrasikan penyimpanan lokal untuk kecepatan akses dan penyimpanan *cloud* untuk keamanan *backup* data, serta dilengkapi dengan sistem verifikasi identitas berbasis foto (*selfie*) setiap kali tes dilakukan.

## ✨ Fitur Utama

* **Skrining Psikologi DASS-42**: Evaluasi kondisi mental dengan 42 pertanyaan yang diklasifikasikan ke dalam metrik Depresi, Kecemasan, dan Stres secara otomatis.
* **Verifikasi Identitas (Selfie)**: Mewajibkan pengguna untuk mengambil *selfie* melalui kamera depan sebelum memulai tes sebagai bukti validasi kehadiran.
* **Real-time Dashboard**: Menampilkan riwayat hasil tes sebelumnya lengkap dengan indikator warna sesuai tingkat keparahan (Normal hingga Sangat Parah).
* **Local & Cloud Sync**: 
  * Menyimpan riwayat tes secara lokal menggunakan **SQLite** untuk akses luring (*offline*).
  * Melakukan *backup* data secara *real-time* ke **Firebase Firestore**.
* **Sistem Autentikasi**: Login dan pendaftaran pengguna yang aman menggunakan **Firebase Authentication**.
* **Pengingat Berkala**: Sistem notifikasi lokal (menggunakan `awesome_notifications`) yang secara otomatis mengingatkan pengguna untuk melakukan evaluasi ulang setiap 2 minggu.

## 🛠️ Tech Stack

* **Framework**: Flutter (Dart)
* **Backend as a Service**: Firebase (Auth, Firestore)
* **Local Database**: `sqflite`
* **Image Hosting**: API ImgBB / Firebase Storage
* **State Management & Helpers**: `provider`, `image_picker`, `awesome_notifications`

## 📂 Struktur Proyek Terpenting

```text
lib/
├── main.dart                  # Titik masuk utama aplikasi & inisialisasi layanan
├── models/
│   ├── question_model.dart    # Model data pertanyaan DASS-42
│   └── test_result_model.dart # Model data riwayat skor & URL selfie
├── services/
│   ├── firebase_service.dart  # Logika integrasi Firestore & Storage/ImgBB
│   ├── local_db_service.dart  # Logika CRUD SQLite
│   └── notification_service.dart # Logika penjadwalan Awesome Notifications
└── screens/
    ├── login_screen.dart      # Antarmuka Autentikasi
    ├── register_screen.dart   # Antarmuka Pendaftaran
    ├── home_screen.dart       # Dashboard & StreamBuilder riwayat tes
    ├── selfie_screen.dart     # Antarmuka pengambilan foto verifikasi
    └── test_screen.dart       # Logika pergantian soal & kalkulasi skor DASS
```