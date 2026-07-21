# Skill: Snap Notes Sequence Diagram

## Deskripsi
Digunakan untuk membantu membuat, memperbarui, atau memvalidasi Sequence Diagram (UML 2.0) pada proyek Snap Notes agar selaras antara perancangan dokumen dan implementasi kode aktual.

## Instruksi Dasar

Sebagai agen yang menggunakan skill ini, kamu harus memastikan bahwa Sequence Diagram yang dihasilkan mematuhi aturan berikut dengan ketat:

### 1. Sumber Kebenaran (Source of Truth)
Sebelum membuat diagram, periksa dan padukan sumber-sumber berikut:
- **Skenario Use Case**: Baca deskripsi alur dari dokumen `docs/DRAFT_BAB1_BAB3.md` (khususnya Tabel Skenario Use Case).
- **Struktur Class**: Gunakan referensi class (View, ViewModel, Service, Model) dari `docs/UML/sequence_diagram/class_design_reference.md`.
- **Implementasi Kode**: Periksa kode aktual (khususnya di `snap_notes_mvvm` untuk mobile client dan direktori backend jika ada).

### 2. Keselarasan Perancangan & Implementasi
- Sequence diagram **wajib** mencerminkan apa yang diimplementasikan di kode, atau menjadi panduan akurat untuk implementasi yang akan dibuat.
- **Validasi Method**: Nama method yang dipanggil pada pesan (message arrow) di sequence diagram **WAJIB** sama persis (termasuk casing, biasanya camelCase) dengan method yang diimplementasikan di dalam kode sumber.
- Jika ada perbedaan antara perancangan dan implementasi, selaraskan keduanya (ubah diagram agar sesuai dengan kode, atau sebaliknya jika diminta pengguna).

### 3. Komponen Lifeline & Arsitektur MVVM
Pastikan komunikasi antar lifeline mengikuti pola MVVM dari referensi class:
- **Aktor**: `Pengguna`
- **View**: Menerima interaksi Pengguna dan memanggil method di `ViewModel`.
- **ViewModel**: Mengatur state, logika bisnis presentasi, dan memanggil method di `Service`.
- **Service**: Menangani logika bisnis inti, integrasi API, dan memanggil utility seperti `DioClient`.
- **Eksternal/Backend**: Web Service / Database / AI API.

### 4. Format & Gaya Diagram
- Gunakan bahasa **Mermaid** dengan blok kode `mermaid` dan deklarasi `sequenceDiagram` ATAU format XML untuk `draw.io` (berdasarkan ekstensi file yang direquest).
- Untuk format `draw.io`, patuhi struktur yang digunakan dalam contoh terlampir. Gunakan `<mxfile...>` dan `<mxGraphModel...>`.
- Susun diagram `draw.io` dengan *Lifelines* secara terurut di bagian atas, yang diikuti oleh node `act_...` yang menentukan dimensi garis aktivasi, diikuti oleh `msg_...` yang merupakan koneksi antar lifeline.
- **Return Message Konsisten**: Pesan balik dari `ViewModel` ke `View` HARUS merepresentasikan reaktivitas state. Gunakan anotasi `notifyListeners() : <keterangan state yang berubah>`.
  - Contoh saat loading: `notifyListeners() : isLoading = true`
  - Contoh saat sukses: `notifyListeners() : pengeluaranList diisi, isLoading = false`
  - Contoh saat gagal: `notifyListeners() : errorMessage diisi, isLoading = false`
  - Reaksi di Lifeline View HARUS ditunjukkan dengan panah *self-call* (menunjuk ke View itu sendiri) yang menjelaskan tindakan UI (misal: "Merender loading indicator", "Menarik data & menghilangkan loading", dsb).
- **Self Call Lifecycle Konsisten**: `ViewModel` HARUS memiliki panah muter ke dirinya sendiri untuk metode internal seperti `_setLoading(true)` dan `_setLoading(false)`.
- Pastikan ada konsistensi dalam alur: `View` memanggil public method di `ViewModel` -> `ViewModel` set loading -> `ViewModel` memanggil `Service` -> `Service` memanggil `DioClient` -> `DioClient` memanggil `Web Service` -> Hasil kembali ke atas secara sekuensial.

### 5. Langkah Kerja yang Disarankan
1. Cari Skenario Use Case yang relevan (jika belum diberikan).
2. Tentukan View, ViewModel, dan Service yang terlibat berdasarkan `class_design_reference.md`.
3. Cari file kode yang relevan (contoh: cari dengan `grep` di `snap_notes_mvvm/` untuk mendapatkan nama method aslinya).
4. Bangun Mermaid sequence diagram yang menyatukan alur user-scenario dengan class & method yang nyata.
5. Jika ada missing link (method di kode tidak ditemukan), laporkan ke user untuk disesuaikan.