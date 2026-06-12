# Spesifikasi Kebutuhan Perangkat Lunak (SKPL) — Snap Notes MVP

Dokumen ini berisi daftar Spesifikasi Kebutuhan Fungsional (SKPL) untuk versi *Minimum Viable Product* (MVP) dari aplikasi pencatatan keuangan Snap Notes.

## Aktor Sistem

| Aktor | Deskripsi |
|-------|-----------|
| **Pengguna** | Pengguna aplikasi mobile yang melakukan pencatatan keuangan pribadi |
| **Gemini AI** | Layanan *artificial intelligence* eksternal dari Google untuk pemrosesan dan strukturisasi data teks hasil OCR |
| **Web Service** | Sistem backend berbasis NestJS yang menangani logika bisnis, manajemen data, dan integrasi dengan layanan eksternal |

## Daftar Use Case (19 Use Case)

### PS-01: Solusi Lupa Mencatat Struk (5 Use Case)

| Kode SKPL | Spesifikasi Kebutuhan Fungsional | Aktor Utama | Aktor Pendukung | Terkait PS |
|-----------|----------------------------------|-------------|-----------------|------------|
| SKPL-F-001 | Sistem dapat mendaftarkan akun baru bagi masyarakat pengguna aplikasi | Pengguna | Web Service | PS-01 |
| SKPL-F-002 | Sistem dapat menyediakan fitur autentikasi masuk ke dalam aplikasi | Pengguna | Web Service | PS-01 |
| SKPL-F-003 | Sistem dapat menyediakan fitur pengakhiran sesi aktif pengguna di dalam sistem | Pengguna | Web Service | PS-01 |
| SKPL-F-018 | Sistem dapat mengirimkan notifikasi pengingat pencatatan keuangan secara otomatis kepada pengguna | Web Service | Pengguna | PS-01 |
| SKPL-F-019 | Sistem dapat menyediakan pengaturan preferensi notifikasi pengingat sesuai kebutuhan pengguna | Pengguna | Web Service | PS-01 |

### PS-02: Solusi Kemalasan Mencatat Manual (9 Use Case)

| Kode SKPL | Spesifikasi Kebutuhan Fungsional | Aktor Utama | Aktor Pendukung | Terkait PS |
|-----------|----------------------------------|-------------|-----------------|------------|
| SKPL-F-004 | Sistem dapat menyediakan antarmuka pengambilan foto struk belanja menggunakan kamera *smartphone* | Pengguna | Web Service | PS-02 |
| SKPL-F-005 | Sistem dapat menyediakan fitur pengunggahan gambar struk belanja dari galeri perangkat | Pengguna | Web Service | PS-02 |
| SKPL-F-006 | Sistem dapat melakukan pemindaian teks pada gambar struk belanja secara otomatis menggunakan Google ML Kit | Web Service | - | PS-02 |
| SKPL-F-007 | Sistem dapat melakukan strukturisasi data struk belanja dari teks mentah hasil pemindaian menjadi data keuangan terstruktur menggunakan Gemini AI | Gemini AI | Web Service | PS-02 |
| SKPL-F-008 | Sistem dapat menyediakan antarmuka untuk meninjau dan mengubah data hasil ekstraksi sebelum disimpan ke basis data | Pengguna | Web Service | PS-02 |
| SKPL-F-009 | Sistem dapat menyimpan data pengeluaran hasil pemindaian struk belanja secara permanen ke basis data | Pengguna | Web Service | PS-02 |
| SKPL-F-010 | Sistem dapat menyediakan antarmuka riwayat pengeluaran yang telah dicatat oleh pengguna | Pengguna | Web Service | PS-02 |
| SKPL-F-011 | Sistem dapat menyediakan pengelolaan struk belanja meliputi operasi ubah dan hapus data | Pengguna | Web Service | PS-02 |
| SKPL-F-012 | Sistem dapat menampilkan detail data struk belanja yang telah berhasil disimpan oleh sistem | Pengguna | Web Service | PS-02 |

### PS-03: Solusi Kurangnya Informasi/Overview Laporan (5 Use Case)

| Kode SKPL | Spesifikasi Kebutuhan Fungsional | Aktor Utama | Aktor Pendukung | Terkait PS |
|-----------|----------------------------------|-------------|-----------------|------------|
| SKPL-F-013 | Sistem dapat menyediakan antarmuka riwayat pemasukan yang telah dicatat oleh pengguna | Pengguna | Web Service | PS-03 |
| SKPL-F-014 | Sistem dapat menyediakan pengelolaan data pemasukan meliputi operasi tambah, ubah, dan hapus | Pengguna | Web Service | PS-03 |
| SKPL-F-015 | Sistem dapat menampilkan antarmuka tren pengeluaran per bulan dalam bentuk grafik | Pengguna | Web Service | PS-03 |
| SKPL-F-016 | Sistem dapat menampilkan antarmuka kalender pengeluaran interaktif berdasarkan data transaksi harian | Pengguna | Web Service | PS-03 |
| SKPL-F-017 | Sistem dapat menampilkan visualisasi persentase pengeluaran per kategori dalam bentuk diagram | Pengguna | Web Service | PS-03 |

---

## Relasi Use Case

### Keterangan Relasi:
- **<<include>>**: F-004/F-005 → F-006 → F-007 (alur pemindaian struk wajib)
- **<<extend>>**: F-008 → F-009 (penyimpanan opsional setelah tinjauan)
- **Aktor Pendukung**: Web Service berperan di hampir semua use case sebagai backend
- **Aktor Eksternal**: Gemini AI hanya terlibat di F-007 (AI parsing)

## Ringkasan Statistik

| Kategori | Jumlah | Persentase |
|----------|--------|------------|
| **Total Use Case** | 19 | 100% |
| PS-01 (Autentikasi & Notifikasi) | 5 | 26,32% |
| PS-02 (OCR & AI — Core Research) | 9 | 47,37% |
| PS-03 (Dashboard & Visualisasi) | 5 | 26,32% |
| **Aktor Utama: Pengguna** | 17 use case | 89,47% |
| **Aktor Utama: Web Service** | 1 use case | 5,26% |
| **Aktor Utama: Gemini AI** | 1 use case | 5,26% |

---

*Dokumen ini merupakan acuan fungsionalitas utama yang wajib dipenuhi dalam pengembangan aplikasi Snap Notes.*
