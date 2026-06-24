
<!-- [![Video Demo SadarDiri](https://img.youtube.com/vi/zCiviXauPro/maxresdefault.jpg)](https://youtu.be/zCiviXauPro) -->

---

# 🚀 Future Development Plan

Berikut adalah rencana pengembangan lanjutan untuk aplikasi **SadarDiri** agar dapat berkembang menjadi platform *Mental Health Companion* yang lebih interaktif dan mendukung tujuan SDGs poin 3 (*Good Health and Well-being*).

## 📅 Planned Features

### 1. Mood Tracker System
Pengguna dapat melakukan pencatatan suasana hati harian (*daily mood check-in*) lengkap dengan catatan singkat dan visualisasi grafik perubahan mood dari waktu ke waktu.

**Planned Tech:**
- Firestore Collection: `mood_logs`
- Local notification reminder
- Weekly mood analytics chart

---

### 2. Digital Journal & Reflection
Menambahkan fitur jurnal pribadi untuk membantu pengguna menuliskan refleksi harian, pengalaman emosional, maupun target kesehatan mental.

**Planned Features:**
- CRUD journal entry
- Upload image attachment
- Favorite & tag system
- Local draft saving

---

### 3. Guided Meditation Integration
Pengguna dapat mengakses sesi meditasi singkat dan latihan pernapasan untuk membantu mengurangi stres dan kecemasan.

**Planned Integration:**
- YouTube API
- Meditation playlist
- Breathing timer
- Relaxation reminder notification

---

### 4. AI-Based Sentiment Analysis
Mengembangkan fitur analisis emosi berbasis AI sederhana untuk membaca kecenderungan emosi dari isi jurnal pengguna.

**Research Direction:**
- TensorFlow Lite
- Sentiment classification
- On-device processing for privacy

---

### 5. Counselor & Support Connection
Menambahkan sistem koneksi bantuan profesional dan kontak darurat untuk pengguna yang membutuhkan dukungan lebih lanjut.

**Planned Features:**
- Counselor directory
- Emergency contact
- Appointment request system
- Google Maps integration

---

### 6. Community Wellness Challenges
Sistem tantangan kesehatan mental berbasis komunitas untuk meningkatkan motivasi pengguna menjaga kesehatan mental secara rutin.

**Example Challenges:**
- 7-Day Gratitude Challenge
- Daily Reflection Challenge
- Digital Detox Challenge

<br>

# 🎯 Long-Term Vision

SadarDiri diharapkan tidak hanya menjadi aplikasi skrining psikologi, tetapi berkembang menjadi platform pendamping kesehatan mental yang:
- mudah diakses,
- menjaga privasi pengguna,
- mendukung self-awareness,
- dan membantu pengguna membangun kebiasaan hidup mental yang lebih sehat.

Pengembangan aplikasi akan tetap berfokus pada:
- privacy-first architecture,
- cloud synchronization,
- edge AI processing,
- serta pengalaman pengguna yang ringan dan mudah digunakan.

<br>

## Update Terbaru: Edge AI Face Verification
Sebagai bagian dari pemenuhan tugas tambahan, saya telah mengintegrasikan sistem **Edge AI** untuk verifikasi wajah. 

- **Teknologi**: TensorFlow Lite (TFLite) dengan model MobileFaceNet.
- **On-Device Processing**: Verifikasi dilakukan sepenuhnya di perangkat pengguna tanpa mengirim data wajah ke server (Privacy-focused).
- **Alur Kerja**:
  1. Pengguna mendaftarkan wajah saat registrasi (Feature Extraction).
  2. Vektor wajah disimpan di Firestore.
  3. Setiap kali ingin melakukan skrining, sistem melakukan pencocokan wajah secara *real-time* menggunakan *Euclidean Distance*.


<br>

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
