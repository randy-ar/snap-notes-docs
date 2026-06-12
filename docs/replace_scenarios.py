import sys

def replace_scenarios(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    start_idx = -1
    end_idx = -1

    for i, line in enumerate(lines):
        if "3. **Skenario Use Case**" in line:
            start_idx = i
            break

    if start_idx != -1:
        for i in range(start_idx, len(lines)):
            if "2. #### **Activity Diagram**" in line or "#### **Activity Diagram**" in lines[i]:
                end_idx = i
                break

    if start_idx != -1 and end_idx != -1:
        new_content = """3. **Skenario Use Case**

Skenario use case digunakan untuk menggambarkan interaksi antara aktor (baik manusia maupun sistem eksternal) dengan sistem yang sedang dikembangkan guna mencapai tujuan tertentu. Skenario ini memuat langkah-langkah spesifik yang dilakukan aktor saat menggunakan sistem, serta respons yang diberikan sistem terhadap setiap tindakan tersebut. Berikut adalah skenario use case yang telah dirancang sesuai dengan kebutuhan sistem aplikasi Snap Notes:

1. Skenario Use Case Menyediakan Fitur Pendaftaran Akun  
   Tabel 3.7 Skenario Use Case Menyediakan Fitur Pendaftaran Akun

| *Nama Use Case* | *Menyediakan Fitur Pendaftaran Akun* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-001 |  |
| ***Goal in Context*** | Pengguna dapat membuat akun baru agar dapat mengakses aplikasi. |  |
| ***Precondition*** | Pengguna berada pada halaman pendaftaran (*register*). |  |
| ***Successful End Condition*** | Akun baru berhasil dibuat dan data profil pengguna tersimpan di basis data. |  |
| ***Failed End Condition*** | Pendaftaran gagal karena email sudah terdaftar, kesalahan format, atau masalah koneksi. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna mengisi formulir pendaftaran dan menekan tombol daftar. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna mengisi formulir pendaftaran (nama, email, kata sandi). |
|  | 2 | Pengguna menekan tombol "Daftar". |
|  | 3 | Sistem memvalidasi kelengkapan data input secara lokal. |
|  | 4 | Sistem mengirimkan data pendaftaran ke Web Service. |
|  | 5 | Web Service memverifikasi keunikan email dan kekuatan kata sandi melalui Supabase Auth. |
|  | 6 | Supabase Auth membuat akun baru dan mengembalikan respons sukses. |
|  | 7 | Web Service menyimpan profil pengguna ke database PostgreSQL. |
|  | 8 | Web Service mengembalikan konfirmasi sukses ke aplikasi. |
|  | 9 | Aplikasi menampilkan pesan pendaftaran berhasil dan mengarahkan ke halaman login. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Menampilkan pesan kesalahan input dan membatalkan proses. |
|  | 5.1 | Mengembalikan pesan kesalahan email telah digunakan. |
|  | 6.1 | Menampilkan pesan kegagalan pendaftaran. |

2. Skenario Use Case Menyediakan Fitur Autentikasi Masuk  
   Tabel 3.8 Skenario Use Case Menyediakan Fitur Autentikasi Masuk

| *Nama Use Case* | *Menyediakan Fitur Autentikasi Masuk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-002 |  |
| ***Goal in Context*** | Pengguna dapat masuk ke aplikasi untuk menggunakan fitur utama. |  |
| ***Precondition*** | Pengguna berada pada halaman masuk (login). |  |
| ***Successful End Condition*** | Pengguna berhasil masuk dan diarahkan ke halaman dashboard utama. |  |
| ***Failed End Condition*** | Masuk gagal karena email/kata sandi salah atau kegagalan koneksi. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna memasukkan email dan kata sandi, lalu menekan tombol masuk. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna memasukkan email dan kata sandi pada halaman masuk. |
|  | 2 | Pengguna menekan tombol "Masuk". |
|  | 3 | Sistem mengirimkan permintaan masuk beserta kredensial ke Web Service. |
|  | 4 | Web Service meneruskan verifikasi ke Supabase Auth. |
|  | 5 | Supabase Auth memvalidasi email dan kata sandi, lalu menghasilkan JWT token. |
|  | 6 | Web Service memproses token dan mengirimkannya kembali ke aplikasi beserta data profil pengguna. |
|  | 7 | Aplikasi menyimpan token secara aman pada *secure storage* perangkat. |
|  | 8 | Aplikasi mengarahkan Pengguna ke halaman utama aplikasi. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 5.1 | Supabase Auth mengembalikan kesalahan autentikasi (email atau sandi salah). |
|  | 5.2 | Web Service meneruskan pesan kesalahan ke aplikasi. |
|  | 5.3 | Aplikasi menampilkan pesan kesalahan autentikasi. |

3. Skenario Use Case Menyediakan Fitur Keluar dari Sistem  
   Tabel 3.9 Skenario Use Case Menyediakan Fitur Keluar dari Sistem

| *Nama Use Case* | *Menyediakan Fitur Keluar dari Sistem* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-003 |  |
| ***Goal in Context*** | Pengguna dapat mengakhiri sesi aktif aplikasi secara aman. |  |
| ***Precondition*** | Pengguna dalam keadaan masuk (sesi login aktif). |  |
| ***Successful End Condition*** | Token autentikasi dihapus dari perangkat dan sesi masuk diakhiri. |  |
| ***Failed End Condition*** | Sesi gagal diakhiri karena kesalahan sistem. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna menekan tombol "Keluar". |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna membuka menu profil pengaturan. |
|  | 2 | Pengguna menekan tombol "Keluar". |
|  | 3 | Sistem menampilkan dialog konfirmasi keluar. |
|  | 4 | Pengguna mengonfirmasi pilihan untuk keluar. |
|  | 5 | Sistem menghapus token autentikasi dari *secure storage* perangkat. |
|  | 6 | Sistem mengirimkan permintaan pembersihan sesi ke Web Service. |
|  | 7 | Web Service menonaktifkan sesi aktif pengguna pada Supabase Auth. |
|  | 8 | Sistem mengarahkan Pengguna kembali ke halaman masuk. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Pengguna membatalkan pilihan keluar dan dialog konfirmasi ditutup. |

4. Skenario Use Case Menyediakan Antarmuka Pengambilan Foto Struk  
   Tabel 3.10 Skenario Use Case Menyediakan Antarmuka Pengambilan Foto Struk

| *Nama Use Case* | *Menyediakan Antarmuka Pengambilan Foto Struk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-004 |  |
| ***Goal in Context*** | Pengguna dapat mengambil gambar struk belanja langsung menggunakan kamera ponsel. |  |
| ***Precondition*** | Aplikasi memiliki izin akses kamera. |  |
| ***Successful End Condition*** | Gambar struk belanja berhasil ditangkap dan dimuat ke aplikasi. |  |
| ***Failed End Condition*** | Gambar tidak berhasil ditangkap atau izin kamera ditolak. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol pindai menggunakan kamera. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna menekan tombol "Kamera". |
|  | 2 | Aplikasi memeriksa izin akses kamera perangkat. |
|  | 3 | Aplikasi mengaktifkan antarmuka kamera. |
|  | 4 | Pengguna membidik dan mengambil foto struk belanja fisik. |
|  | 5 | Aplikasi menampilkan hasil jepretan foto untuk pratinjau. |
|  | 6 | Pengguna menyetujui gambar struk belanja yang diambil. |
|  | 7 | Gambar struk siap diproses oleh sistem lebih lanjut. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Aplikasi meminta izin akses kamera. Jika ditolak, proses dibatalkan. |
|  | 6.1 | Pengguna menekan tombol "Ulangi" dan sistem kembali ke langkah 3. |

5. Skenario Use Case Menyediakan Fitur Unggah Gambar Struk  
   Tabel 3.11 Skenario Use Case Menyediakan Fitur Unggah Gambar Struk

| *Nama Use Case* | *Menyediakan Fitur Unggah Gambar Struk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-005 |  |
| ***Goal in Context*** | Pengguna dapat memilih dan memuat gambar struk belanja dari penyimpanan galeri perangkat. |  |
| ***Precondition*** | Aplikasi memiliki izin akses penyimpanan/galeri. |  |
| ***Successful End Condition*** | Gambar struk belanja terpilih berhasil dimuat ke dalam aplikasi. |  |
| ***Failed End Condition*** | Pemilihan gambar dibatalkan atau format gambar tidak didukung. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol unggah dari galeri. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna menekan tombol "Galeri". |
|  | 2 | Aplikasi menginisiasi antarmuka pemilihan berkas (*file picker*) perangkat. |
|  | 3 | Pengguna memilih file gambar struk belanja yang relevan (JPG, JPEG, PNG). |
|  | 4 | Aplikasi memvalidasi format dan batasan ukuran gambar. |
|  | 5 | Gambar berhasil dimuat ke dalam aplikasi dan siap diproses. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Pengguna membatalkan pemilihan dan kembali ke aplikasi. |
|  | 4.1 | Aplikasi menampilkan pesan kesalahan format tidak valid atau terlalu besar, proses dibatalkan. |

6. Skenario Use Case Memindai Teks Pada Struk Belanja  
   Tabel 3.12 Skenario Use Case Memindai Teks Pada Struk Belanja

| *Nama Use Case* | *Memindai Teks Pada Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-006 |  |
| ***Goal in Context*** | Sistem mengekstraksi teks mentah dari citra digital struk belanja secara *on-device*. |  |
| ***Precondition*** | Gambar struk belanja telah berhasil dimuat ke dalam aplikasi. |  |
| ***Successful End Condition*** | Teks mentah (*raw text)* beserta koordinat spasialnya berhasil diekstrak oleh Google ML Kit. |  |
| ***Failed End Condition*** | Pemindaian gagal karena gambar terlalu buram. |  |
| ***Actors*** | Web Service |  |
| ***Trigger*** | Sistem mendeteksi ketersediaan gambar struk yang siap dipindai. |  |
| ***Include Cases*** | Menyediakan Antarmuka Pengambilan Foto Struk, Menyediakan Fitur Unggah Gambar Struk |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Sistem mengonversi gambar struk belanja menjadi format data InputImage. |
|  | 2 | Sistem menjalankan modul OCR TextRecognizer *on-device.* |
|  | 3 | Google ML Kit mengekstrak teks mentah beserta *bounding box* (koordinat spasial) dari gambar tersebut. |
|  | 4 | Sistem menyusun hasil ekstraksi teks mentah spasial. |
|  | 5 | Sistem membebaskan alokasi memori OCR dari perangkat. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | ML Kit tidak menemukan teks terbaca, sistem memunculkan notifikasi kegagalan dan meminta pengguna mengunggah gambar yang lebih jelas. |

7. Skenario Use Case Melakukan Strukturisasi Data Struk Belanja  
   Tabel 3.13 Skenario Use Case Melakukan Strukturisasi Data Struk Belanja

| *Nama Use Case* | *Melakukan Strukturisasi Data Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-007 |  |
| ***Goal in Context*** | Mengubah teks mentah hasil OCR menjadi objek data JSON keuangan terstruktur dengan AI. |  |
| ***Precondition*** | Teks mentah spasial OCR telah tersedia di sistem. |  |
| ***Successful End Condition*** | Web Service menerima *response* JSON terstruktur (nama toko, tanggal, daftar item belanja, total pengeluaran) dari Gemini AI. |  |
| ***Failed End Condition*** | Parsing gagal karena *response* AI tidak stabil atau layanan tidak tersedia. |  |
| ***Actors*** | Gemini AI, Web Service |  |
| ***Trigger*** | Web Service menerima muatan teks mentah dari aplikasi klien. |  |
| ***Include Cases*** | Memindai Teks Pada Struk Belanja |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Web Service menyusun *prompt* instruksi yang merangkum data teks mentah beserta tata letak koordinatnya. |
|  | 2 | Web Service memanggil layanan Gemini AI API menggunakan protokol generatif AI. |
|  | 3 | Gemini AI menganalisis tata letak dan konten tulisan untuk mengklasifikasikan data (toko, item, nominal). |
|  | 4 | Gemini AI mengembalikan objek data dengan format JSON terstruktur ke Web Service. |
|  | 5 | Web Service memvalidasi kelengkapan bidang data (wajib ada total, array item). |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Gemini AI API sedang tidak stabil, Web Service mencatat *log error* dan memberitahu pengguna. |
|  | 5.1 | Hasil JSON gagal divalidasi, Web Service memicu *retry request* ulang ke AI. |

8. Skenario Use Case Menyediakan Formulir Tinjauan Data Ekstraksi  
   Tabel 3.14 Skenario Use Case Menyediakan Formulir Tinjauan Data Ekstraksi

| *Nama Use Case* | *Menyediakan Formulir Tinjauan Data Ekstraksi* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-008 |  |
| ***Goal in Context*** | Pengguna dapat meninjau dan memperbaiki data hasil *parsing* AI sebelum disimpan ke *database*. |  |
| ***Precondition*** | JSON data transaksi hasil AI telah diterima oleh aplikasi. |  |
| ***Successful End Condition*** | Data transaksi dikonfirmasi dan disetujui penyimpanannya oleh Pengguna. |  |
| ***Failed End Condition*** | Pengguna membatalkan proses dan memilih untuk tidak menyimpan transaksi. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Aplikasi berhasil merender *form* data hasil strukturisasi ke antarmuka pengguna. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi menampilkan formulir data transaksi keuangan berisikan kolom nama toko, tanggal, item barang, harga, dan total. |
|  | 2 | Pengguna meninjau kecocokan data dengan fisik struk belanja di layar. |
|  | 3 | Jika terdapat kekeliruan nominal atau teks, Pengguna langsung menyunting *field* yang salah di aplikasi. |
|  | 4 | Aplikasi memvalidasi kebenaran rekapitulasi matematis transaksi secara lokal. |
|  | 5 | Pengguna menekan tombol "Simpan" untuk memvalidasi akhir data transaksi. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Pengguna memilih untuk membuang dan membatalkan proses pencatatan, data dibersihkan dari layar. |

9. Skenario Use Case Menyimpan Data Pengeluaran Hasil Scan  
   Tabel 3.15 Skenario Use Case Menyimpan Data Pengeluaran Hasil Scan

| *Nama Use Case* | *Menyimpan Data Pengeluaran Hasil Scan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-009 |  |
| ***Goal in Context*** | Menyimpan data pengeluaran terstruktur dan *file* gambar struk belanja ke dalam *database* dan *storage*. |  |
| ***Precondition*** | Pengguna telah menyetujui *form* tinjauan ekstraksi data. |  |
| ***Successful End Condition*** | Data transaksi berhasil direkam di PostgreSQL dan gambar struk di Supabase Storage. |  |
| ***Failed End Condition*** | Proses penyimpanan dibatalkan akibat kegagalan sinkronisasi pangkalan data. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Tombol simpan ditekan pada formulir tinjauan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengirimkan paket final data transaksi beserta berkas gambar ke Web Service. |
|  | 2 | Web Service mengunggah berkas gambar struk ke Supabase Storage. |
|  | 3 | Supabase Storage mengembalikan URL atau *path* penyimpanan gambar tersebut. |
|  | 4 | Web Service menggunakan ORM untuk menyimpan entitas Pengeluaran beserta detail *ItemStruk* yang menautkan URL gambar ke PostgreSQL. |
|  | 5 | PostgreSQL menyelesaikan transaksi relasional dan mengembalikan konfirmasi sukses. |
|  | 6 | Web Service mengirimkan respons sukses kepada klien aplikasi. |
|  | 7 | Aplikasi menampilkan pesan konfirmasi dan membawa Pengguna ke halaman utama. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Unggahan gagal, Web Service membatalkan seluruh operasi dan memberikan notifikasi error koneksi. |

10. Skenario Use Case Menyediakan Antarmuka Riwayat Pengeluaran  
    Tabel 3.16 Skenario Use Case Menyediakan Antarmuka Riwayat Pengeluaran

| *Nama Use Case* | *Menyediakan Antarmuka Riwayat Pengeluaran* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-010 |  |
| ***Goal in Context*** | Pengguna dapat melihat daftar transaksi riwayat pengeluaran yang telah dicatat di sistem. |  |
| ***Precondition*** | Pengguna dalam keadaan masuk (*login*) di aplikasi. |  |
| ***Successful End Condition*** | Daftar riwayat transaksi pengeluaran ditampilkan dengan benar dari yang terbaru. |  |
| ***Failed End Condition*** | Riwayat gagal dimuat dari *database* karena gangguan koneksi. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna membuka halaman *Tab* Riwayat Pengeluaran. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengirim *request* HTTP GET ke Web Service untuk menarik data pengeluaran. |
|  | 2 | Web Service memverifikasi token dan melakukan kueri penarikan entitas Pengeluaran ke *database*. |
|  | 3 | Web Service mengembalikan daftar transaksi pengeluaran berformat JSON. |
|  | 4 | Aplikasi merender data ke dalam antarmuka riwayat transaksi secara urut. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Jika belum ada transaksi sama sekali, Web Service mengembalikan daftar kosong, dan aplikasi menampilkan ilustrasi "Riwayat masih kosong". |

11. Skenario Use Case Menyediakan Fitur Pengelolaan Struk Belanja  
    Tabel 3.17 Skenario Use Case Menyediakan Fitur Pengelolaan Struk Belanja

| *Nama Use Case* | *Menyediakan Fitur Pengelolaan Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-011 |  |
| ***Goal in Context*** | Pengguna dapat memperbarui rincian transaksi struk belanja atau menghapus data struk yang sudah tidak valid. |  |
| ***Precondition*** | Pengguna membuka halaman detail dari sebuah struk belanja di dalam daftar riwayat. |  |
| ***Successful End Condition*** | Perubahan detail struk atau penghapusan data struk berhasil dieksekusi di *database*. |  |
| ***Failed End Condition*** | Operasi gagal dijalankan akibat kegagalan sinkronisasi. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna memilih opsi Ubah/Hapus pada antarmuka detail transaksi struk. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna menekan tombol "Ubah" atau "Hapus" pada struk belanja tertentu. |
|  | 2 | [Jika Hapus]: Sistem memunculkan dialog peringatan penghapusan data permanen. |
|  | 3 | [Jika Ubah]: Sistem menampilkan form *edit* detail struk belanja. Pengguna mengubah data lalu menekan "Simpan". |
|  | 4 | Aplikasi mengirimkan *request* mutasi/penghapusan ke Web Service. |
|  | 5 | Web Service menjalankan kueri mutasi entitas pada PostgreSQL. |
|  | 6 | Sistem mengembalikan respons sukses dan antarmuka aplikasi memperbarui daftar tampilan terbaru. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Pengguna membatalkan penghapusan, proses dihentikan. |

12. Skenario Use Case Menyediakan Akses Gambar Struk Tersimpan  
    Tabel 3.18 Skenario Use Case Menyediakan Akses Gambar Struk Tersimpan

| *Nama Use Case* | *Menyediakan Akses Gambar Struk Tersimpan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-012 |  |
| ***Goal in Context*** | Menyajikan visualisasi gambar asli struk belanja dari arsip penyimpanan *cloud*. |  |
| ***Precondition*** | Pengguna membuka detail transaksi struk belanja. |  |
| ***Successful End Condition*** | Gambar struk belanja ditarik dari *storage* dan tertampil jelas pada layar ponsel. |  |
| ***Failed End Condition*** | Gambar gagal ditampilkan akibat *URL* rusak atau *timeout* internet. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna mengetuk gambar pratinjau struk belanja di halaman detail. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengambil referensi *URL path* dari gambar struk belanja terkait. |
|  | 2 | Aplikasi mengirimkan *request* penarikan aset gambar ke layanan penyimpanan Supabase melalui *endpoint* Web Service. |
|  | 3 | Gambar diunduh sementara ke memori (*cache*) *device*. |
|  | 4 | Sistem menampilkan visualisasi struktur gambar penuh di dalam aplikasi. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Gagal mengambil aset, aplikasi menampilkan ilustrasi "Gambar Tidak Dapat Dimuat". |

13. Skenario Use Case Menyediakan Antarmuka Riwayat Pemasukan  
    Tabel 3.19 Skenario Use Case Menyediakan Antarmuka Riwayat Pemasukan

| *Nama Use Case* | *Menyediakan Antarmuka Riwayat Pemasukan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-013 |  |
| ***Goal in Context*** | Pengguna dapat melihat daftar transaksi riwayat pemasukan yang pernah dikelola oleh sistem. |  |
| ***Precondition*** | Pengguna dalam keadaan masuk (*login*) di aplikasi. |  |
| ***Successful End Condition*** | Daftar transaksi pemasukan berhasil disajikan di layar secara kronologis. |  |
| ***Failed End Condition*** | Transaksi gagal dimuat dari Web Service. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna memilih *Tab* Pemasukan pada aplikasi. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengirim *request* pengambilan data spesifik untuk tipe transaksi Pemasukan. |
|  | 2 | Web Service melakukan *fetch* entitas Pemasukan dari PostgreSQL. |
|  | 3 | Web Service memberikan balasan data berformat JSON. |
|  | 4 | Aplikasi memuat data tersebut ke dalam komponen *list* antarmuka. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Jika Pemasukan belum pernah dicatat, aplikasi memunculkan teks "Data Pemasukan Anda Kosong". |

14. Skenario Use Case Menyediakan Fitur Pengelolaan Pemasukan  
    Tabel 3.20 Skenario Use Case Menyediakan Fitur Pengelolaan Pemasukan

| *Nama Use Case* | *Menyediakan Fitur Pengelolaan Pemasukan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-014 |  |
| ***Goal in Context*** | Pengguna dapat melakukan siklus operasi Tambah, Ubah, atau Hapus terhadap entitas data Pemasukan. |  |
| ***Precondition*** | Pengguna berada di menu Pemasukan. |  |
| ***Successful End Condition*** | Operasi mutasi data Pemasukan berhasil direkam atau dihilangkan dari basis data secara permanen. |  |
| ***Failed End Condition*** | Web Service menolak *request* karena kesalahan *input* atau masalah konektivitas. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna menekan tombol "Tambah Pemasukan" atau mengeklik "Opsi" pada salah satu riwayat pemasukan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna memilih aksi: Tambah baru, Ubah data lama, atau Hapus riwayat. |
|  | 2 | Sistem menampilkan *form input* yang meminta detail Nominal Pemasukan, Tanggal, dan Kategori. |
|  | 3 | Pengguna menekan tombol Eksekusi (Simpan/Hapus). |
|  | 4 | Aplikasi memvalidasi nominal tidak boleh nol secara lokal. |
|  | 5 | Web Service menjalankan eksekusi CRUD entitas Pemasukan di PostgreSQL menggunakan Prisma ORM. |
|  | 6 | Aplikasi menampilkan umpan balik sukses (toast) kepada Pengguna. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Validasi form tidak lolos, aplikasi meminta pengguna melengkapi data yang wajib diisi. |

15. Skenario Use Case Menampilkan Antarmuka Tren Pengeluaran Per bulan  
    Tabel 3.21 Skenario Use Case Menampilkan Antarmuka Tren Pengeluaran Per bulan

| *Nama Use Case* | *Menampilkan Antarmuka Tren Pengeluaran Per bulan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-015 |  |
| ***Goal in Context*** | Menghasilkan grafik garis yang dapat dievaluasi secara statistik mengenai pergerakan belanja bulanan. |  |
| ***Precondition*** | Pengguna mengakses halaman Analisis / Statistik. |  |
| ***Successful End Condition*** | Modul grafik tren (bar/line chart) berhasil digambar di layar menggunakan agregasi data transaksi. |  |
| ***Failed End Condition*** | Modul grafik rusak akibat balasan format JSON tidak sesuai. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Sistem otomatis memuat bagian statistik saat *tab* terkait ditekan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi meminta agregat data bulanan tren pengeluaran kepada Web Service. |
|  | 2 | Web Service mengalkulasi *sum* pengeluaran setiap bulannya dari PostgreSQL. |
|  | 3 | Web Service mengembalikan titik data teragregasi bulanan secara berurutan. |
|  | 4 | Aplikasi mem- *parsing* data ke dalam pustaka grafik visual dan merender *chart*. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Data bulan-bulan tertentu tidak ada, titik grafik dirender sebagai angka nol (0). |

16. Skenario Use Case Menampilkan Antarmuka Kalender Pengeluaran Interaktif  
    Tabel 3.22 Skenario Use Case Menampilkan Antarmuka Kalender Pengeluaran Interaktif

| *Nama Use Case* | *Menampilkan Antarmuka Kalender Pengeluaran Interaktif* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-016 |  |
| ***Goal in Context*** | Memberikan tinjauan spasial hari per hari berbasis antarmuka kalender bulanan kepada Pengguna. |  |
| ***Precondition*** | Pengguna memilih mode tampilan Kalender di menu Analisis. |  |
| ***Successful End Condition*** | Angka akumulasi pengeluaran harian ditanamkan di sel-sel tanggal yang relevan. |  |
| ***Failed End Condition*** | Kalender gagal di *generate* oleh aplikasi klien. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Tampilan antarmuka Kalender dimuat aktif. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengidentifikasi bulan dan tahun pada tampilan kalender, lalu meminta datanya ke Web Service. |
|  | 2 | Web Service menarik akumulasi transaksi harian untuk bulan yang diminta. |
|  | 3 | Aplikasi menerima respons dan menanamkan penanda titik atau teks nominal di tanggal (*day cell*) yang relevan pada UI kalender. |
|  | 4 | Pengguna dapat mengetuk tanggal spesifik untuk membentangkan ringkasan transaksi di bawahnya. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Mengetuk sel tanpa transaksi menampilkan status kosong. |

17. Skenario Use Case Menampilkan Visualisasi Persentase per Kategori  
    Tabel 3.23 Skenario Use Case Menampilkan Visualisasi Persentase per Kategori

| *Nama Use Case* | *Menampilkan Visualisasi Persentase per Kategori* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-017 |  |
| ***Goal in Context*** | Menyajikan alokasi segmentasi pengeluaran ke dalam diagram *Pie Chart* atau *Donut Chart*. |  |
| ***Precondition*** | Pengguna berada di modul analisis *Kategori*. |  |
| ***Successful End Condition*** | Visualisasi diagram lingkaran terbagi rata berdasarkan kontribusi perhitungan masing-masing kategori pengeluaran. |  |
| ***Failed End Condition*** | Gagal merender diagram warna karena data yang diterima tidak utuh. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Filter analisis kategori diaktifkan oleh pengguna. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Web Service menerima permintaan kueri kelompok pengeluaran dari aplikasi klien berdasarkan parameter kategori (*Group By Category*). |
|  | 2 | Web Service menjumlahkan besaran per kategori dan merumuskannya dalam bentuk metrik persentase. |
|  | 3 | Web Service menyuplai array objek tersebut. |
|  | 4 | Aplikasi memutar dan mewarnai irisan visual diagram kategori sesuai dengan besaran persentasenya. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Data kategori kosong, Web Service membalas dengan status null, dan grafis dirender menjadi satu warna abu-abu bertuliskan "Belum Ada Data". |

18. Skenario Use Case Mengirimkan Notifikasi Pengingat Otomatis  
    Tabel 3.24 Skenario Use Case Mengirimkan Notifikasi Pengingat Otomatis

| *Nama Use Case* | *Mengirimkan Notifikasi Pengingat Otomatis* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-018 |  |
| ***Goal in Context*** | Mengirimkan pemicu notifikasi eksternal (*Push Notification*) ke *smartphone* pengguna untuk rutin mencatat. |  |
| ***Precondition*** | Aplikasi terpasang, terhubung internet, dan izin notifikasi diberikan pada sistem operasi ponsel. |  |
| ***Successful End Condition*** | Balon pesan pengingat berhasil ditangkap dan dimunculkan oleh perangkat seluler di jam terjadwal. |  |
| ***Failed End Condition*** | Ponsel mati atau izin notifikasi sistem ditolak. |  |
| ***Actors*** | Web Service |  |
| ***Trigger*** | Rutinitas *background job* atau waktu yang disetel mencapai pukul penjadwalan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Fungsi pekerja latar belakang Web Service atau perangkat mendeteksi jadwal pengingat untuk pengguna spesifik. |
|  | 2 | Sistem mendeteksi status bahwa pengguna belum melakukan pencatatan transaksi harian. |
|  | 3 | Web Service menembakkan muatan notifikasi melalui layanan pihak ketiga pendistribusi *push messaging* (misal: Firebase). |
|  | 4 | Sistem operasi ponsel menangkap sinyal dan meluncurkan modul *Push Notification* ke layar pengguna. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Jika sistem mendeteksi aktivitas pencatatan sudah ada di hari ini, jadwal notifikasi diabaikan. |

19. Skenario Use Case Menyediakan Pengaturan Preferensi Notifikasi  
    Tabel 3.25 Skenario Use Case Menyediakan Pengaturan Preferensi Notifikasi

| *Nama Use Case* | *Menyediakan Pengaturan Preferensi Notifikasi* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-019 |  |
| ***Goal in Context*** | Pengguna bebas menyesuaikan setelan jam kapan notifikasi pengingat otomatis boleh dikirimkan. |  |
| ***Precondition*** | Pengguna masuk ke halaman menu Setelan (*Settings*). |  |
| ***Successful End Condition*** | Data preferensi jam terbaru tersimpan dengan sinkronisasi Web Service. |  |
| ***Failed End Condition*** | Kegagalan penyimpanan form preferensi karena kendala komunikasi jaringan. |  |
| ***Actors*** | Pengguna, Web Service |  |
| ***Trigger*** | Pengguna mengganti nilai pada panel pengaturan waktu notifikasi. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Pengguna memilih opsi konfigurasi pengaturan "Jam Notifikasi Pengingat" pada aplikasi. |
|  | 2 | Sistem memunculkan jendela pemilihan antarmuka waktu (*Time Picker*). |
|  | 3 | Pengguna menetapkan pukul tertentu (misalnya 20:00) dan menekan "Terapkan". |
|  | 4 | Aplikasi mencatat preferensi di memori lokal lalu mengirim mutasi setelan profil ke Web Service. |
|  | 5 | Web Service memperbarui tabel *PreferensiNotifikasi* pada basis data pengguna. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Pengguna memilih mode "Nonaktifkan Notifikasi", sehingga sistem tidak akan lagi menembakkan pengingat di masa mendatang. |

"""

        lines[start_idx:end_idx] = [new_content + "\n"]

        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"Replaced successfully, replaced {end_idx - start_idx} lines.")
    else:
        print("Could not find start or end index.")

if __name__ == "__main__":
    replace_scenarios("/home/sweetpotet/Documents/Kuliah/Semester 8/Skripsi/Projects/docs/BAB 3.md")
