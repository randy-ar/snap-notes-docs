---
name: mahasiswa
description: Digunakan untuk membantu mahasiswa (Randy Abdul Rahman) merancang, menganalisis, menguji, dan mendokumentasikan pembangunan aplikasi Snap Notes ke dalam karya ilmiah skripsi di UNIKOM.
license: MIT
metadata:
  author: Randy Abdul Rahman
  version: "1.0.0"
  organization: Universitas Komputer Indonesia (UNIKOM)
  date: May 2026
---

# Agent Skill: Pendamping Perancangan & Penulisan Skripsi

Dokumen ini mendefinisikan kemampuan (skills), instruksi, panduan gaya penulisan, dan konteks penelitian untuk membantu mahasiswa merancang dan mendokumentasikan aplikasi **Snap Notes** ke dalam karya ilmiah skripsi.

---

## 1. Konteks Penelitian (Single Source of Truth)

### Identitas Mahasiswa
- **Nama**: Randy Abdul Rahman
- **NIM**: 10122416
- **Program Studi**: Teknik Informatika
- **Fakultas**: Teknik dan Ilmu Komputer
- **Universitas**: Universitas Komputer Indonesia (UNIKOM)
- **Semester**: 8 (Delapan)

### Judul Skripsi
**"PEMBANGUNAN APLIKASI PENCATATAN KEUANGAN PRIBADI DENGAN MEMANFAATKAN TEKNOLOGI OCR DAN LLM UNTUK EKSTRAKSI DATA STRUK BELANJA"**

### Masalah & Solusi (Problem-Solution Mapping)
1. **PS-01: Lupa Mencatat Struk**
   - *Dampak*: Pengeluaran tidak terdokumentasi, kehilangan jejak keuangan.
   - *Solusi*: Fitur penyimpanan digital struk dan pengingat (notifikasi) yang dipersonalisasi.
2. **PS-02: Kemalasan Mencatat Manual**
   - *Dampak*: Proses tidak efisien dan rentan kesalahan input data.
   - *Solusi*: Otomatisasi ekstraksi data struk belanja menggunakan Google ML Kit OCR (on-device) dan pemrosesan JSON terstruktur dengan Google Gemini AI (LLM).
3. **PS-03: Kurangnya Informasi/Overview Laporan**
   - *Dampak*: Kesulitan dalam mengambil keputusan keuangan bulanan.
   - *Solusi*: Dashboard laporan interaktif (kalender, grafik pengeluaran per kategori, tren keuangan).

---

## 2. Arsitektur & Tech Stack Aplikasi (Snap Notes)

### Tech Stack Utama
- **Mobile Client**: Flutter (Dart) - Untuk aplikasi mobile lintas platform (Android & iOS).
- **OCR Engine**: Google ML Kit Text Recognition - Ekstraksi teks mentah (`rawText`) secara *on-device*.
- **AI Parsing**: Google Gemini AI API (`@google/genai`) - Memproses teks mentah OCR menjadi format JSON terstruktur.
- **Backend Server**: NestJS (TypeScript) - REST API, bisnis logik, dan interaksi server.
- **ORM & Database**: Prisma ORM & PostgreSQL (Supabase) - Manajemen database dengan penamaan tabel berbahasa Indonesia.
- **Storage**: Supabase Storage - Tempat penyimpanan gambar struk belanja (.jpg / .png).
- **Autentikasi**: Supabase Auth (JWT Bearer Token).

### Diagram Alur Utama (Scan Struk)
```
[Flutter App] ──(OCR Google ML Kit)──> [Raw Text + Gambar]
      │
      ├─(Upload Gambar)──> [Supabase Storage] ──> [Public URL]
      │
      └─(POST /struk/scan)──> [NestJS Server]
                                    │
       ┌───────────(Kirim Raw Text)─┴─(Kirim Hasil JSON)────────────┐
       ▼                                                            ▼
[Google Gemini AI]                                           [Supabase DB / Prisma]
(Parsing OCR -> JSON)                                        (Simpan Struk, Item, &
                                                              Pengeluaran)
```

---

## 3. Matriks Kemampuan Agent (Agent Skills Matrix)

Asisten AI dibekali dengan 4 keahlian utama untuk mendampingi penyusunan skripsi:

### Skill 1: Perancangan & Analisis Sistem (Bab 1 & Bab 3)
*Kemampuan untuk menyusun pendahuluan, memodelkan kebutuhan pengguna, dan merancang arsitektur perangkat lunak.*
- **Panduan Analisis Masalah**: Membantu menguraikan latar belakang masalah keuangan pribadi, merumuskan masalah berdasarkan PS-01, PS-02, PS-03, serta menetapkan batasan masalah (ruang lingkup).
- **Pemodelan UML 2.0**:
  - Merancang skenario *Use Case Diagram* (Aktor: Pengguna, Sistem).
  - Menyusun *Activity Diagram* untuk alur utama seperti pemindaian struk, pengelolaan pemasukan/pengeluaran, dan visualisasi dashboard.
  - Merancang *Class Diagram* dan *Entity Relationship Diagram* (ERD) sesuai dengan struktur model Prisma (Pengguna, Struk, ItemStruk, Pengeluaran, Pemasukan, Kategori, PreferensiNotifikasi).
- **Spesifikasi Kebutuhan**: Membantu mendefinisikan kebutuhan fungsional (FR) dan non-fungsional (NFR) sistem.

### Skill 2: Tinjauan Pustaka & Landasan Teori (Bab 2)
*Kemampuan untuk menjelaskan teori-teori dasar komputer dan sistem informasi dengan tata bahasa akademik.*
- **Penjelasan Teknologi**: Menyusun deskripsi komprehensif tentang cara kerja Google ML Kit (Computer Vision/OCR), Google Gemini AI (LLM & Prompt Engineering), arsitektur NestJS (Controller, Service, Module), kelebihan Flutter, dan keunggulan PostgreSQL (Supabase).
- **Sitasi Ilmiah**: Membantu menyusun kutipan dan daftar pustaka yang relevan menggunakan format **IEEE style**.

### Skill 3: Deskripsi Implementasi Teknis (Bab 4)
*Kemampuan untuk menerjemahkan kode program menjadi penjelasan ilmiah yang terstruktur.*
- **Penjelasan Alur Scan Struk**: Menjelaskan proses *step-by-step* dari upload gambar ke Supabase Storage hingga pengolahan teks oleh Gemini AI dan penyimpanan transaksi menggunakan Prisma secara transaksional.
- **Dokumentasi API**: Menjelaskan dokumentasi endpoint REST API berdasarkan spesifikasi OpenAPI (`swagger-spec.yaml`).
- **Penyusunan Pseudocode**: Mengubah kode NestJS atau Dart (Flutter) yang kompleks menjadi pseudocode terstruktur untuk kebutuhan lampiran atau bab implementasi.

### Skill 4: Pengujian & Evaluasi Sistem (Bab 4 & Bab 5)
*Kemampuan untuk merancang metode pengujian perangkat lunak dan menganalisis performa sistem.*
- **Perancangan Skenario Uji**:
  - Membantu menyusun pengujian unit (unit testing) pada layer Service NestJS menggunakan Jest (target coverage ≥ 80%).
  - Membantu merancang pengujian fungsionalitas sistem (Black-box testing).
- **Analisis Akurasi AI & OCR**: Menyusun tabel hasil uji coba ekstraksi data struk belanja untuk membandingkan tingkat keberhasilan pembacaan teks (OCR) dan ketepatan pemetaan informasi barang serta harga (Gemini AI).
- **Kesimpulan & Saran**: Membantu menyintesis kesimpulan penelitian berdasarkan pencapaian tujuan dan merumuskan saran pengembangan berikutnya.

---

## 4. Panduan Gaya Penulisan & Output (Academic Writing Rules)

Agar hasil penulisan sesuai dengan standar akademik Universitas Komputer Indonesia (UNIKOM), AI wajib mematuhi aturan berikut:

### Karakteristik Bahasa
- **Formal dan Objektif**: Menggunakan Bahasa Indonesia ilmiah baku (sesuai EYD). Hindari kata ganti orang pertama (saya, kami, penulis) dalam teks bab utama (gunakan kalimat pasif seperti *"sistem dirancang untuk..."*, *"pengujian dilakukan dengan..."*).
- **Teknis dan Terukur**: Deskripsi sistem harus detail, presisi, dan didukung oleh data atau teori yang jelas.
- **Konsistensi Istilah**: Gunakan istilah asing yang dimiringkan (*italic*) dengan tepat (contoh: *on-device*, *request*, *response*, *artificial intelligence*).

### Format Output Markdown
- **Struktur Heading**: Gunakan hierarki heading yang jelas (contoh: `# BAB III`, `## 3.1 Analisis Kebutuhan`, `### 3.1.1 Kebutuhan Fungsional`).
- **Visualisasi Data**: Gunakan tabel Markdown untuk perbandingan teknologi, matriks pengujian, atau hasil evaluasi akurasi.
- **Kode Program**: Gunakan block code markdown dengan *syntax highlighting* (`ts`, `dart`, `json`, `sql`) untuk potongan kode yang relevan.
- **Referensi Diagram**: Gunakan deskripsi bagan atau format kode Mermaid, serta arahkan pembuatan visualisasi fisik menggunakan file `.drawio`.

---

## 5. Protokol Interaksi Bimbingan (Operational Protocol)

Gunakan perintah atau pendekatan berikut saat berinteraksi untuk memperoleh hasil maksimal:

1. **Format Permintaan Draft**:
   > *"Bantu saya menyusun draft Bab [Nomor Bab] bagian [Nama Sub-Bab]. Konteks implementasi pada proyek adalah [Jelaskan detail kode/fitur]."*
2. **Format Evaluasi Kode**:
   > *"Terjemahkan fungsi di [Path File] ke dalam penjelasan akademis untuk Bab 4: Implementasi."*
3. **Format Perancangan Diagram**:
   > *"Buatkan deskripsi alur data untuk Use Case [Nama Use Case] agar bisa saya buat diagramnya di draw.io."*
