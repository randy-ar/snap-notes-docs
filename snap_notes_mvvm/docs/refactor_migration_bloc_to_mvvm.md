# Log Perubahan: Migrasi Arsitektur BLoC ke MVVM

Log ini mendokumentasikan migrasi seluruh fungsionalitas aplikasi client Snap Notes dari arsitektur Clean Architecture + BLoC (`snap_notes`) ke arsitektur Model-View-ViewModel + Provider (`snap_notes_mvvm`).

---

## Ringkasan Perubahan

### 1. Lapisan State Management
- Seluruh Cubit dan BLoC dihapus dan digantikan oleh **ViewModel (ChangeNotifier)** yang dikelola menggunakan package `provider`.
- Penyederhanaan alur state di mana View langsung mendengarkan property dari ViewModel dan memanggil method asinkronus secara langsung.
- **Implementasi Logout**: Tombol logout dengan dialog konfirmasi ditambahkan ke bagian AppBar `DashboardPage` untuk memicu `AuthViewModel.logout()` dan kembali ke halaman login secara otomatis.

### 2. Lapisan Data & Bisnis (Service Layer)
- Penggabungan DataSources (Remote/Local/Supabase) dan Repositories yang terpisah pada arsitektur lama menjadi satu **Service Class** per-modul di proyek MVVM.
- Penanganan pengecualian menggunakan exception standard (`ServerException`, `LocalException`) yang dilemparkan dari Service dan ditangkap oleh ViewModel.

### 3. Alur Pemindaian Struk & OCR (PS-02)
- Integrasi pustaka `google_mlkit_text_recognition` langsung pada `ReceiptService.extractTextFromImage` untuk pemindaian teks struk secara lokal.
- Migrasi alur multi-step debug preview struk untuk analisis mahasiswa:
  - `TextRecognitionPreviewPage`: Visualisasi bounding box baris teks menggunakan `CustomPainter` (`BoundingBoxPainter`).
  - `PayloadPreviewPage`: Tinjau JSON payload yang akan dikirim ke REST API.
  - `ResponsePreviewPage`: Tinjau hasil ekstraksi data struk oleh Gemini AI.
  - `UploadSuccessPage` & `UploadFailurePage`: Tampilan status akhir proses scan struk.

### 4. Modul Pengeluaran & CRUD (PS-02 & PS-03)
- Migrasi detail pengeluaran manual dan OCR ke `PengeluaranDetailPage`.
- Migrasi form tambah/edit pengeluaran manual ke `PengeluaranFormPage`.

### 5. Visualisasi Tren Transaksi (Line Chart)
- Menambahkan visualisasi tren bulanan transaksi menggunakan pustaka `fl_chart` pada widget `ExpenseLineChartWidget`.
- Menampilkan data pengeluaran (garis merah) dan pemasukan (garis hijau) secara paralel dalam rentang waktu 6 bulan.
- Menyediakan navigasi interaktif (tombol "Prev" dan "Next") untuk berpindah ke periode 6 bulan berikutnya atau sebelumnya.

### 6. Standardisasi UI shadcn_flutter & Ikon Lucide
- Melakukan migrasi dan perbaikan UI di berbagai halaman (`LoginPage`, `RegisterPage`, `DashboardPage`, `ExpenseLineChartWidget`) agar sepenuhnya menggunakan komponen dari ekosistem `shadcn_flutter`.
- Menggantikan semua ikon Material lama (`Icons`) dengan ikon `LucideIcons` bawaan shadcn_flutter agar antarmuka terasa seragam dan premium.
- Menyelesaikan konflik pengimporan tipe dan konstanta warna (*ambiguous import*) antara pustaka Material dengan shadcn_flutter melalui penggunaan konstanta warna mandiri.

### 7. Visualisasi Distribusi Kategori Pengeluaran (Pie Chart)
- Menambahkan visualisasi distribusi pengeluaran kategorikal bulan berjalan dalam bentuk **Pie Chart** menggunakan pustaka `fl_chart`.
- Melakukan penyaringan dinamis di sisi client untuk menyajikan hanya data transaksi pengeluaran di bulan berjalan (`DateTime.now().month` & `DateTime.now().year`).
- Menambahkan legenda interaktif yang menunjukkan dot warna kategori, persentase kontribusi, serta nominal pengeluaran dalam Rupiah.
- Mengatur tata letak dashboard dengan urutan: 1. Heatmap, 2. Line Chart, 3. Pie Chart.

---

## Verifikasi
- Pengujian static analysis menggunakan `dart analyze` menunjukkan kode terkompilasi dengan sukses dan 100% bebas dari error kompilasi maupun kesalahan impor tipe/ikon.
