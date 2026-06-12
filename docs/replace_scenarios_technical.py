import sys
import re

def main():
    file_path = "/home/sweetpotet/Documents/Kuliah/Semester 8/Skripsi/Projects/docs/BAB 3.md"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the start and end of Skenario Use Case
    start_str = "3. **Skenario Use Case**"
    end_str = "2. #### **Activity Diagram**"
    
    start_idx = content.find(start_str)
    end_idx = content.find(end_str)
    
    if start_idx == -1 or end_idx == -1:
        print("Could not find start or end bounds.")
        return
        
    replacement = """3. **Skenario Use Case**

Skenario use case digunakan untuk menggambarkan interaksi antara aktor (baik manusia maupun sistem eksternal) dengan sistem yang sedang dikembangkan guna mencapai tujuan tertentu. Skenario ini memuat langkah-langkah spesifik yang dilakukan aktor saat menggunakan sistem, serta respons yang diberikan sistem terhadap setiap tindakan tersebut. Berikut adalah skenario use case yang telah dirancang sesuai dengan kebutuhan sistem aplikasi Snap Notes:

1. Skenario Use Case Menyediakan Fitur Pendaftaran Akun  
   Tabel 3.7 Skenario Use Case Menyediakan Fitur Pendaftaran Akun

| *Nama Use Case* | *Menyediakan Fitur Pendaftaran Akun* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-001 |  |
| ***Goal in Context*** | Masyarakat dapat membuat akun baru agar dapat mengakses aplikasi. |  |
| ***Precondition*** | Masyarakat berada pada halaman pendaftaran (*register*). |  |
| ***Successful End Condition*** | Akun baru berhasil dibuat dan data profil masyarakat tersimpan di basis data. |  |
| ***Failed End Condition*** | Pendaftaran gagal karena email sudah terdaftar, kesalahan format, atau masalah koneksi. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat mengisi formulir pendaftaran dan menekan tombol daftar. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat memasukkan nama, *email*, dan kata sandi melalui form antarmuka aplikasi klien. |
|  | 2 | Masyarakat menekan tombol "Daftar", memicu aplikasi untuk mengelola *state* proses registrasi dan memvalidasi form secara lokal. |
|  | 3 | Aplikasi mengirimkan *request* pemuatan data pendaftaran ke *endpoint* Web Service. |
|  | 4 | Web Service memvalidasi ketersediaan *email* dan tingkat keamanan kata sandi melalui integrasi layanan autentikasi pihak ketiga. |
|  | 5 | Web Service mengeksekusi penulisan kueri *Object-Relational Mapping* (ORM) ke basis data relasional untuk merekam profil pengguna baru. |
|  | 6 | Web Service mengembalikan *response* sukses (HTTP 201) kepada klien aplikasi. |
|  | 7 | Aplikasi mendeteksi status sukses dan melakukan navigasi rute (*routing*) halaman ke tampilan masuk (login). |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Menampilkan pesan kesalahan input (contoh: format email tidak valid) dan menangguhkan proses permintaan. |
|  | 4.1 | Mengembalikan pesan kesalahan *email* telah digunakan ke aplikasi klien. |

2. Skenario Use Case Menyediakan Fitur Autentikasi Masuk  
   Tabel 3.8 Skenario Use Case Menyediakan Fitur Autentikasi Masuk

| *Nama Use Case* | *Menyediakan Fitur Autentikasi Masuk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-002 |  |
| ***Goal in Context*** | Masyarakat dapat masuk ke aplikasi untuk menggunakan fitur utama. |  |
| ***Precondition*** | Masyarakat berada pada halaman masuk (login). |  |
| ***Successful End Condition*** | Masyarakat berhasil masuk dan diarahkan ke halaman dashboard utama. |  |
| ***Failed End Condition*** | Masuk gagal karena email/kata sandi salah atau kegagalan koneksi. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat memasukkan email dan kata sandi, lalu menekan tombol masuk. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat memasukkan *email* dan kata sandi melalui form antarmuka klien. |
|  | 2 | Masyarakat menekan tombol "Masuk", memicu aplikasi untuk mengelola *state* proses autentikasi. |
|  | 3 | Aplikasi mengirimkan *request* HTTP berisi kumpulan kredensial ke *endpoint* Web Service. |
|  | 4 | Web Service memvalidasi kecocokan kredensial tersebut menggunakan layanan autentikasi pihak ketiga. |
|  | 5 | Web Service mengembalikan *response* balasan berupa token akses autentikasi (*JWT token*) dan payload data profil masyarakat. |
|  | 6 | Aplikasi menyalin dan menyimpan persentase token tersebut pada area penyimpanan aman di perangkat lokal (*secure storage*). |
|  | 7 | Aplikasi mengarahkan navigasi (*routing*) Masyarakat ke layar halaman utama (*Dashboard*). |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Layanan autentikasi menolak kredensial karena ketidakcocokan email atau kata sandi. |
|  | 4.2 | Web Service meneruskan pesan instruksi kesalahan dari layanan ke aplikasi. |

3. Skenario Use Case Menyediakan Fitur Keluar dari Sistem  
   Tabel 3.9 Skenario Use Case Menyediakan Fitur Keluar dari Sistem

| *Nama Use Case* | *Menyediakan Fitur Keluar dari Sistem* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-003 |  |
| ***Goal in Context*** | Masyarakat dapat mengakhiri sesi aktif aplikasi secara aman. |  |
| ***Precondition*** | Masyarakat dalam keadaan masuk (sesi login aktif). |  |
| ***Successful End Condition*** | Token autentikasi dihapus dari perangkat dan sesi masuk diakhiri. |  |
| ***Failed End Condition*** | Sesi gagal diakhiri karena kesalahan sistem. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat menekan tombol "Keluar". |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat membuka antarmuka menu profil dan mengetuk tombol "Keluar". |
|  | 2 | Aplikasi memicu komponen pembentukan dialog konfirmasi untuk memastikan intensi masyarakat. |
|  | 3 | Masyarakat memberikan konfirmasi persetujuan pengakhiran sesi. |
|  | 4 | Aplikasi mengeksekusi penghapusan *JWT token* otorisasi dari memori area penyimpanan aman perangkat (*secure storage*). |
|  | 5 | Aplikasi mengirimkan *request* pembersihan sesi aktif (*logout*) ke *endpoint* Web Service. |
|  | 6 | Web Service menarik validitas sesi token yang terdaftar pada layanan autentikasi. |
|  | 7 | Aplikasi menghapus jejak susunan tampilan sebelumnya dan me-*routing* arah sistem kembali ke antarmuka login. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Masyarakat menekan opsi batal, sistem meruntuhkan dialog tanpa mengeksekusi aksi apapun. |

4. Skenario Use Case Menyediakan Antarmuka Pengambilan Foto Struk  
   Tabel 3.10 Skenario Use Case Menyediakan Antarmuka Pengambilan Foto Struk

| *Nama Use Case* | *Menyediakan Antarmuka Pengambilan Foto Struk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-004 |  |
| ***Goal in Context*** | Masyarakat dapat mengambil gambar struk belanja langsung menggunakan kamera ponsel. |  |
| ***Precondition*** | Aplikasi memiliki izin akses kamera. |  |
| ***Successful End Condition*** | Gambar struk belanja berhasil ditangkap dan dimuat ke aplikasi. |  |
| ***Failed End Condition*** | Gambar tidak berhasil ditangkap atau izin kamera ditolak. |  |
| ***Actors*** | Masyarakat |  |
| ***Trigger*** | Masyarakat menekan tombol pindai menggunakan kamera. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat menekan ikon pemindai berbasis "Kamera" pada antarmuka aplikasi. |
|  | 2 | Aplikasi meminta dan memverifikasi izin akses komponen periferal kamera sistem operasi perangkat seluler (*native API*). |
|  | 3 | Aplikasi menginisialisasi pustaka penyokong kamera lokal untuk membangkitkan jendela pratinjau jepretan (*camera preview*). |
|  | 4 | Masyarakat membidik lembar fisik struk pembelanjaan dan menginstruksikan modul menangkap *frame* citra (foto). |
|  | 5 | Aplikasi menangkap dan menyuntikkan data citra tersebut ke dalam alokasi memori sementara program (*cache*). |
|  | 6 | Aplikasi merender resolusi gambar jepretan agar Masyarakat dapat memverifikasi kualitas foto yang ditangkap. |
|  | 7 | Masyarakat menekan opsi validasi untuk meneruskan data gambar ke pemrosesan lebih lanjut. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Aplikasi gagal mengantongi izin akses perangkat, sistem memunculkan pop-up peringatan dan proses pun tertunda. |
|  | 6.1 | Masyarakat membatalkan persetujuan dengan menekan "Ulangi", sehingga mengembalikan *state* ke pratinjau kamera awal. |

5. Skenario Use Case Menyediakan Fitur Unggah Gambar Struk  
   Tabel 3.11 Skenario Use Case Menyediakan Fitur Unggah Gambar Struk

| *Nama Use Case* | *Menyediakan Fitur Unggah Gambar Struk* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-005 |  |
| ***Goal in Context*** | Masyarakat dapat memilih dan memuat gambar struk belanja dari penyimpanan galeri perangkat. |  |
| ***Precondition*** | Aplikasi memiliki izin akses penyimpanan/galeri. |  |
| ***Successful End Condition*** | Gambar struk belanja terpilih berhasil dimuat ke dalam aplikasi. |  |
| ***Failed End Condition*** | Pemilihan gambar dibatalkan atau format gambar tidak didukung. |  |
| ***Actors*** | Masyarakat |  |
| ***Trigger*** | Masyarakat menekan tombol unggah dari galeri. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat menekan ikon opsi "Galeri" pada navigasi aplikasi. |
|  | 2 | Aplikasi memanggil layanan *native file picker* pada sistem operasi perangkat untuk membangkitkan senarai dokumen galeri. |
|  | 3 | Masyarakat menelusuri memori internal dan memilih berkas (*file*) gambar struk belanja yang dikehendaki. |
|  | 4 | Aplikasi membaca atribut objek berkas tersebut dan memvalidasi ekstensi (MIME Type) serta ukuran batasan penyangga gambar. |
|  | 5 | Aplikasi menarik muatan objek gambar secara memadai dan mendaftarkannya ke dalam ruang memori operasional aplikasi. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Masyarakat keluar dari tampilan galeri sistem, aplikasi menanggalkan siklus tanpa memuat apa pun. |
|  | 4.1 | Jika format citra rusak atau melampaui standar muatan memori, aplikasi menyela dengan pemberitahuan galat (*error message*). |

6. Skenario Use Case Memindai Teks Pada Struk Belanja  
   Tabel 3.12 Skenario Use Case Memindai Teks Pada Struk Belanja

| *Nama Use Case* | *Memindai Teks Pada Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-006 |  |
| ***Goal in Context*** | Sistem mengekstraksi teks mentah dari citra digital struk belanja secara *on-device*. |  |
| ***Precondition*** | Gambar struk belanja telah berhasil dimuat ke dalam aplikasi. |  |
| ***Successful End Condition*** | Teks mentah (*raw text)* beserta koordinat spasialnya berhasil diekstrak. |  |
| ***Failed End Condition*** | Pemindaian gagal karena gambar terlalu buram. |  |
| ***Actors*** | Web Service |  |
| ***Trigger*** | Sistem mendeteksi ketersediaan gambar struk yang siap dipindai. |  |
| ***Include Cases*** | Menyediakan Antarmuka Pengambilan Foto Struk, Menyediakan Fitur Unggah Gambar Struk |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengonversi komponen bit citra struk ke dalam format matriks *InputImage* yang dikenali oleh pustaka *Machine Learning*. |
|  | 2 | Aplikasi merangkai alur pemicuan algoritma pemrosesan penglihatan komputer (*Optical Character Recognition*) bawaan perangkat. |
|  | 3 | Mesin pengenal mendeteksi gugus-gugus piksel (*blocks*), lalu mengekstraksinya menjadi blok teks mentah beserta data koordinat tata ruang lokasinya (*bounding box*). |
|  | 4 | Aplikasi mengompilasi keluaran *array* objek hasil ekstraksi menjadi gumpalan teks (*raw text*) bertata spasial. |
|  | 5 | Aplikasi memberhentikan jalinan instansiasi modul OCR guna merelokasi dan membebaskan alokasi memori sistem operasi seluler. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Jika kerangka piksel terlalu buram sehingga batas toleransi ambang baca gagal, sistem segera menghentikan rantai blok penguraian dan menerbitkan notifikasi kegagalan kepada klien. |

7. Skenario Use Case Melakukan Strukturisasi Data Struk Belanja  
   Tabel 3.13 Skenario Use Case Melakukan Strukturisasi Data Struk Belanja

| *Nama Use Case* | *Melakukan Strukturisasi Data Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-007 |  |
| ***Goal in Context*** | Mengubah teks mentah hasil OCR menjadi objek data JSON keuangan terstruktur dengan AI. |  |
| ***Precondition*** | Teks mentah spasial OCR telah tersedia di sistem. |  |
| ***Successful End Condition*** | Web Service menerima *response* JSON terstruktur (nama toko, tanggal, daftar item belanja, total pengeluaran). |  |
| ***Failed End Condition*** | Parsing gagal karena *response* AI tidak stabil atau layanan tidak tersedia. |  |
| ***Actors*** | Gemini AI, Web Service |  |
| ***Trigger*** | Web Service menerima muatan teks mentah dari aplikasi klien. |  |
| ***Include Cases*** | Memindai Teks Pada Struk Belanja |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mengirimkan muatan *payload* bertipe string teks mentah keluaran OCR menuju *endpoint* antarmuka Web Service. |
|  | 2 | Web Service menyusun rekayasa promp (*prompt engineering*) berupa tata pola klasifikasi keuangan yang disisipi nilai mentah tersebut. |
|  | 3 | Web Service meneruskan *prompt* ini melewati koneksi lapisan protokol HTTP menuju penyedia layanan kecerdasan buatan tipe *Large Language Model* (LLM). |
|  | 4 | Model bahasa LLM memanfaatkan paramater atensi untuk mengenali semantik tulisan (nama tempat, jajaran item, harga parsial, total agregat). |
|  | 5 | Jaringan penyedia layanan LLM mengembalikan *response* dalam struktur korpus format JSON mentah ke penampungan Web Service. |
|  | 6 | Web Service mem- *parsing* ketersediaan bidang absolut (kolom susunan item dan rentang nilai matematis total), memvalidasinya, dan mengirimkannya lagi ke perangkat lunak klien. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | API LLM menolak koneksi karena kepadatan beban peladen (*server overload*). |
|  | 6.1 | Hasil susunan validasi terdeteksi cacat struktur (*malformed JSON*), Web Service memerintahkan pengulangan permintaan ke layanan LLM. |

8. Skenario Use Case Menyediakan Formulir Tinjauan Data Ekstraksi  
   Tabel 3.14 Skenario Use Case Menyediakan Formulir Tinjauan Data Ekstraksi

| *Nama Use Case* | *Menyediakan Formulir Tinjauan Data Ekstraksi* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-008 |  |
| ***Goal in Context*** | Masyarakat dapat meninjau dan memperbaiki data hasil *parsing* AI sebelum disimpan ke *database*. |  |
| ***Precondition*** | JSON data transaksi hasil AI telah diterima oleh aplikasi. |  |
| ***Successful End Condition*** | Data transaksi dikonfirmasi dan disetujui penyimpanannya oleh Masyarakat. |  |
| ***Failed End Condition*** | Masyarakat membatalkan proses dan memilih untuk tidak menyimpan transaksi. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Aplikasi berhasil merender *form* data hasil strukturisasi ke antarmuka pengguna. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi melakukan pemetaan variabel (*data binding*) dari susunan JSON terstruktur ke komponen isian (*input fields*) antarmuka (nama toko, item, nominal harga). |
|  | 2 | Masyarakat membaca sinkronisasi angka pengenal pada aplikasi dengan tampilan visual struk asli di monitor sistem. |
|  | 3 | Masyarakat menyunting karakter atau nominal secara dinamis melalui pemicu form pada aplikasi. |
|  | 4 | Aplikasi memicu sirkulasi pembaruan *state* reaktif setiap terjadi *event* perubahan teks, lantas menghitung ulang rekapitulasi matematis total secara *client-side*. |
|  | 5 | Masyarakat menginisiasi prosedur pengiriman akhir data (*submit form*) dengan mengetuk kontrol konfirmasi simpan. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Masyarakat memilih membongkar seluruh rekaman pada langkah tersebut dan sistem menggugurkan susunan kerangka objek di memori (*flush state*). |

9. Skenario Use Case Menyimpan Data Pengeluaran Hasil Scan  
   Tabel 3.15 Skenario Use Case Menyimpan Data Pengeluaran Hasil Scan

| *Nama Use Case* | *Menyimpan Data Pengeluaran Hasil Scan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-009 |  |
| ***Goal in Context*** | Menyimpan data pengeluaran terstruktur dan *file* gambar struk belanja ke dalam *database* dan *storage*. |  |
| ***Precondition*** | Masyarakat telah menyetujui *form* tinjauan ekstraksi data. |  |
| ***Successful End Condition*** | Data transaksi berhasil direkam di pangkalan data dan gambar struk di layanan *storage*. |  |
| ***Failed End Condition*** | Proses penyimpanan dibatalkan akibat kegagalan sinkronisasi pangkalan data. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Tombol simpan ditekan pada formulir tinjauan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi mentransmisikan *payload multipart* berisikan bongkahan *file* gambar struk belanja ke *endpoint Cloud Storage* pada jaringan *backend*. |
|  | 2 | Mekanisme *Cloud Storage* Web Service menaruh artefak gambar dan mengembalikan referensi URL publik terpadu (*Public URL*). |
|  | 3 | Aplikasi menyerangkaikan alamat URL gambar tersebut ke dalam badan format *payload* transaksi final, lalu mengirim permintaan penyisipan (*HTTP POST request*) ke Web Service. |
|  | 4 | Web Service menggunakan metode penjagaan otentikasi (*Auth Guard*) untuk memverifikasi keabsahan klaim sesi *JWT token* Masyarakat. |
|  | 5 | Web Service mengeksekusi metode pencatatan relasional ORM untuk memasukkan himpunan baris entitas Pengeluaran beserta properti rincian ItemStruk ke dalam mesin pangkalan data. |
|  | 6 | Basis data mengembalikan *callback* positif dan Web Service merespons aplikasi melalui rentetan pengiriman kode status HTTP 201 (Sukses Dibuat). |
|  | 7 | Aplikasi mencopot tumpukan panel navigasi sementara, memberikan *snackbar feedback*, dan menugaskan kembali masyarakat ke beranda. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 1.1 | Punggawa transmisi mendeteksi gangguan konektivitas, memicu blok pembatalan asinkron (*abort/timeout error*). |

10. Skenario Use Case Menyediakan Antarmuka Riwayat Pengeluaran  
    Tabel 3.16 Skenario Use Case Menyediakan Antarmuka Riwayat Pengeluaran

| *Nama Use Case* | *Menyediakan Antarmuka Riwayat Pengeluaran* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-010 |  |
| ***Goal in Context*** | Masyarakat dapat melihat daftar transaksi riwayat pengeluaran yang telah dicatat di sistem. |  |
| ***Precondition*** | Masyarakat dalam keadaan masuk (*login*) di aplikasi. |  |
| ***Successful End Condition*** | Daftar riwayat transaksi pengeluaran ditampilkan dengan benar dari yang terbaru. |  |
| ***Failed End Condition*** | Riwayat gagal dimuat dari *database* karena gangguan koneksi. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat membuka halaman *Tab* Riwayat Pengeluaran. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi merangkai susunan rute *HTTP GET request* dengan pembubuhan kredensial menuju layanan pangkalan riwayat Web Service. |
|  | 2 | Web Service mengekstrak *payload Bearer Token* dari tajuk peladen untuk mengenali identitas profil Masyarakat yang bersangkutan. |
|  | 3 | Web Service mengeksekusi klausa penarikan bertahap ORM pada tabel Pengeluaran dengan parameter urutan desenden berdasarkan waktu pencatatan (*orderBy desc*). |
|  | 4 | Web Service meneruskan wujud data larik *JSON array* transaksi pengeluaran ke *stream* klien. |
|  | 5 | Aplikasi mende- *serialize* *payload* respons JSON dan memetakannya (*mapping*) satu demi satu ke struktur elemen antarmuka daftar senarai (*list view*) perangkat. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Evaluasi perhitungan jumlah indeks data pada ORM mendeteksi ukuran nol (0), sistem melemparkan ilustrasi pesan keranjang belanja kosong di antarmuka perangkat. |

11. Skenario Use Case Menyediakan Fitur Pengelolaan Struk Belanja  
    Tabel 3.17 Skenario Use Case Menyediakan Fitur Pengelolaan Struk Belanja

| *Nama Use Case* | *Menyediakan Fitur Pengelolaan Struk Belanja* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-011 |  |
| ***Goal in Context*** | Masyarakat dapat memperbarui rincian transaksi struk belanja atau menghapus data struk yang sudah tidak valid. |  |
| ***Precondition*** | Masyarakat membuka halaman detail dari sebuah struk belanja di dalam daftar riwayat. |  |
| ***Successful End Condition*** | Perubahan detail struk atau penghapusan data struk berhasil dieksekusi di *database*. |  |
| ***Failed End Condition*** | Operasi gagal dijalankan akibat kegagalan sinkronisasi. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat memilih opsi Ubah/Hapus pada antarmuka detail transaksi struk. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat berinteraksi dengan tombol pemicu aksi "Ubah" atau "Hapus" pada lembar detail entitas transaksi di memori klien. |
|  | 2 | [Jika Hapus]: Aplikasi menerbitkan jendela modul konfirmasi dialog (*alert dialog*). Setelah Masyarakat menekan setuju, aplikasi merakit HTTP *DELETE request* berisikan kode unik (ID) transaksi ke Web Service. |
|  | 3 | [Jika Ubah]: Aplikasi mewarisi parameter status saat ini pada bidang edit antarmuka. Masyarakat mendikte nilai terbaru lalu aplikasi memaketkan properti revisi tersebut ke dalam struktur HTTP *PUT request* pembaruan. |
|  | 4 | Web Service memverifikasi otoritas kepemilikan *record* sesuai relasi subjek sesi yang meminta ke *database*. |
|  | 5 | Web Service menjalankan kueri modifikasi permanen (*update/delete clause*) menggunakan ORM pada PostgreSQL. |
|  | 6 | Klien aplikasi menerima kode konfirmasi balikan jaringan dan menyuruh sistem pemicu antarmuka (*UI framework*) untuk membuang atau merefleksikan perubahan senarai lama. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Verifikasi silang kepemilikan gagal karena *record* tersebut milik entitas lain, lalu Web Service melontarkan eksepsi akses ditolak (*Forbidden Exception*). |

12. Skenario Use Case Menyediakan Akses Gambar Struk Tersimpan  
    Tabel 3.18 Skenario Use Case Menyediakan Akses Gambar Struk Tersimpan

| *Nama Use Case* | *Menyediakan Akses Gambar Struk Tersimpan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-012 |  |
| ***Goal in Context*** | Menyajikan visualisasi gambar asli struk belanja dari arsip penyimpanan *cloud*. |  |
| ***Precondition*** | Masyarakat membuka detail transaksi struk belanja. |  |
| ***Successful End Condition*** | Gambar struk belanja ditarik dari *storage* dan tertampil jelas pada layar ponsel. |  |
| ***Failed End Condition*** | Gambar gagal ditampilkan akibat *URL* rusak atau *timeout* internet. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat mengetuk gambar pratinjau struk belanja di halaman detail. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat mengetuk blok komponen *thumbnail* pada halaman detail interaksi aplikasi. |
|  | 2 | Aplikasi mengidentifikasi *property link* rujukan gambar tersebut dari objek JSON yang tersimpan pada sesi memori halaman. |
|  | 3 | Aplikasi menginisiasi pembacaan layanan transfer berkas dan mengeksekusi koneksi unduh *stream byte* menuju referensi alamat URL publik (*Public URL*) milik pangkalan penyedia gambar (*Cloud Storage*). |
|  | 4 | Mesin aplikasi menahan dan menyimpan bongkahan data gambar di ruang singgah sementara perangkat (*local caching layer*). |
|  | 5 | Aplikasi membangun struktur tampilan visual interaktif mode layar lebar (*fullscreen modal*) untuk merender resolusi gambar tersebut di depan layar. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Blok URL mengalami pemutusan, korup, atau *timeout* sambungan, aplikasi memberlakukan substitusi tata rupa memunculkan ilustrasi pengganti "Gambar Gagal Dimuat". |

13. Skenario Use Case Menyediakan Antarmuka Riwayat Pemasukan  
    Tabel 3.19 Skenario Use Case Menyediakan Antarmuka Riwayat Pemasukan

| *Nama Use Case* | *Menyediakan Antarmuka Riwayat Pemasukan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-013 |  |
| ***Goal in Context*** | Masyarakat dapat melihat daftar transaksi riwayat pemasukan yang pernah dikelola oleh sistem. |  |
| ***Precondition*** | Masyarakat dalam keadaan masuk (*login*) di aplikasi. |  |
| ***Successful End Condition*** | Daftar transaksi pemasukan berhasil disajikan di layar secara kronologis. |  |
| ***Failed End Condition*** | Transaksi gagal dimuat dari Web Service. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat memilih *Tab* Pemasukan pada aplikasi. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Aplikasi menyusun parameter navigasi rute dan mengeksekusi sebuah sesi pemanggilan rute HTTP *GET* parameter spesifik filter entitas Pemasukan pada Web Service. |
|  | 2 | Lapis pengendali Web Service menerima parameter lalu mendelegasikan rutinitas kepada pustaka abstraksi basis data (ORM). |
|  | 3 | ORM memproses fungsi panggil susunan data dari entitas Pemasukan dalam repositori *backend* SQL, menyelaraskannya ke spesifikasi tipe properti masyarakat. |
|  | 4 | Web Service merapatkan objek data hasil luaran fungsi ke dalam paket transfer berbasis JSON *array* ke lintasan jaringan klien. |
|  | 5 | Aplikasi mende- *serialize* *response byte* berantai tersebut agar kompatibel disajikan ke dalam wadah senarai hierarkis antarmuka layar ponsel. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Logika ORM tak mampu mengambil satupun catatan relasi entitas, lalu menyebarkan tanda larik entitas kosong, ditangkap klien dengan pesan ilustrasi kekosongan. |

14. Skenario Use Case Menyediakan Fitur Pengelolaan Pemasukan  
    Tabel 3.20 Skenario Use Case Menyediakan Fitur Pengelolaan Pemasukan

| *Nama Use Case* | *Menyediakan Fitur Pengelolaan Pemasukan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-014 |  |
| ***Goal in Context*** | Masyarakat dapat melakukan siklus operasi Tambah, Ubah, atau Hapus terhadap entitas data Pemasukan. |  |
| ***Precondition*** | Masyarakat berada di menu Pemasukan. |  |
| ***Successful End Condition*** | Operasi mutasi data Pemasukan berhasil direkam atau dihilangkan dari basis data secara permanen. |  |
| ***Failed End Condition*** | Web Service menolak *request* karena kesalahan *input* atau masalah konektivitas. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat menekan tombol "Tambah Pemasukan" atau mengeklik "Opsi" pada salah satu riwayat pemasukan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat menstimulasi pemicu instruksi manipulasi mutlak (Tambah, Ubah, atau Hapus) pada sistem visualisasi senarai Pemasukan. |
|  | 2 | Aplikasi merangkai properti pemetaan struktur variabel masukan yang mencakup form Tanggal, Kategori, dan Nominal. |
|  | 3 | Masyarakat berinteraksi dengan form penambahan/perubahan, lalu mengaktifkan tombol pengeksekusi perintah simpan mutasi ke memori antarmuka (*UI framework*). |
|  | 4 | Aplikasi memicu prosedur analitis sisi klien (*client-side validation rule*) agar kelengkapan formulir divalidasi presisi. |
|  | 5 | Aplikasi mengalokasikan parameter data dan referensi identitas ke tubuh protokol muatan HTTP *Request* untuk dihantarkan kepada *endpoint* operasi mutasi (POST/PUT/DELETE) Web Service. |
|  | 6 | Web Service menjalankan validasi rute autentikasi lalu membangkitkan kueri transaksi CRUD *database* menggunakan ORM. |
|  | 7 | Web Service melemparkan respon umpan balik positif ke klien agar diteruskan dengan mekanisme unjuk umpan visual pop-up sejenak (*toast/snackbar message*). |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Filter sisi klien merintangi pengerjaan (*validation failed*) apabila masukan karakter tidak relevan, membatalkan serah terima paket jaringan dan mengembalikan notifikasi pembaruan kolom wajib kepada pihak klien. |

15. Skenario Use Case Menampilkan Antarmuka Tren Pengeluaran Per bulan  
    Tabel 3.21 Skenario Use Case Menampilkan Antarmuka Tren Pengeluaran Per bulan

| *Nama Use Case* | *Menampilkan Antarmuka Tren Pengeluaran Per bulan* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-015 |  |
| ***Goal in Context*** | Menghasilkan grafik garis yang dapat dievaluasi secara statistik mengenai pergerakan belanja bulanan. |  |
| ***Precondition*** | Masyarakat mengakses halaman Analisis / Statistik. |  |
| ***Successful End Condition*** | Modul grafik tren (bar/line chart) berhasil digambar di layar menggunakan agregasi data transaksi. |  |
| ***Failed End Condition*** | Modul grafik rusak akibat balasan format JSON tidak sesuai. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Sistem otomatis memuat bagian statistik saat *tab* terkait ditekan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Peramban aplikasi menyelenggarakan permintaan pengunduhan statistik tren bulanan melewati protokol HTTP. |
|  | 2 | Web Service membangkitkan rutinitas agregasi basis data dengan mensyaratkan mekanisme relasional *Group By* dan kalkulasi *Sum* akumulatif terhadap blok properti data log periodik (bulan dan jumlah). |
|  | 3 | Web Service menyusun rekayasa kueri hasil penarikan tersebut pada struktur data matriks koordinat sekuensi waktu dan harga sebagai objek respon JSON. |
|  | 4 | Klien aplikasi mengeksekusi integrasi dan mem- *parsing* ketersediaan balasan struktur titik JSON tersebut menuju ke ranah pemetaan pustaka perender grafik antarmuka (*charting library*). |
|  | 5 | Aplikasi merender bentangan pergerakan kurva linier interaktif di atas penampang antarmuka visual pelaporan. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Blok hasil kompilasi Web Service menyatakan bahwa terdapat ruang kosong ketersediaan rentang waktu, titik diagram tidak dibangun pada rentang tersebut. |

16. Skenario Use Case Menampilkan Antarmuka Kalender Pengeluaran Interaktif  
    Tabel 3.22 Skenario Use Case Menampilkan Antarmuka Kalender Pengeluaran Interaktif

| *Nama Use Case* | *Menampilkan Antarmuka Kalender Pengeluaran Interaktif* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-016 |  |
| ***Goal in Context*** | Memberikan tinjauan spasial hari per hari berbasis antarmuka kalender bulanan kepada Masyarakat. |  |
| ***Precondition*** | Masyarakat memilih mode tampilan Kalender di menu Analisis. |  |
| ***Successful End Condition*** | Angka akumulasi pengeluaran harian ditanamkan di sel-sel tanggal yang relevan. |  |
| ***Failed End Condition*** | Kalender gagal di *generate* oleh aplikasi klien. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Tampilan antarmuka Kalender dimuat aktif. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Modul pengelola penanggalan pada aplikasi mendeteksi sorotan awal hari di *state* navigasi lalu menyorongkan kueri perikatan permintaan jangkauan waktu kalender ke Web Service. |
|  | 2 | Web Service mendalangi pemrosesan perolehan kumulatif agregasi harian entitas terkait sesuai penyaringan jangkauan (*date range filtering*) pada basis data. |
|  | 3 | Aplikasi melangsungkan deserialisasi respon balik lalu mengaitkan penjalinan objek susunan jumlah ke masing-masing blok (*cell*) parameter pilar penyusun grid matriks tanggal. |
|  | 4 | Modul *UI framework* merefleksikan penyajian kerangka *heatmap calendar*, membedakan rona warna intensitas pilar sesuai akumulasi parameter. |
|  | 5 | Masyarakat meletikkan pemicu interaksi seleksi ketukan pada blok pilar sel kalender tertentu, aplikasi mendengarkan peristiwa *event listener* dan memodulasi struktur bingkai tampilan antarmuka *pop-up* rincian agregat harian. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 5.1 | Masyarakat membangkitkan deteksi modul sel kosong (angka nol), pemicu meletupkan tanggapan balik status kekosongan di papan petunjuk aplikasi. |

17. Skenario Use Case Menampilkan Visualisasi Persentase per Kategori  
    Tabel 3.23 Skenario Use Case Menampilkan Visualisasi Persentase per Kategori

| *Nama Use Case* | *Menampilkan Visualisasi Persentase per Kategori* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-017 |  |
| ***Goal in Context*** | Menyajikan alokasi segmentasi pengeluaran ke dalam diagram *Pie Chart* atau *Donut Chart*. |  |
| ***Precondition*** | Masyarakat berada di modul analisis *Kategori*. |  |
| ***Successful End Condition*** | Visualisasi diagram lingkaran terbagi rata berdasarkan kontribusi perhitungan masing-masing kategori pengeluaran. |  |
| ***Failed End Condition*** | Gagal merender diagram warna karena data yang diterima tidak utuh. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Filter analisis kategori diaktifkan oleh pengguna. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat beralih menetapkan penyaring komputasi Kategori pada antarmuka pelaporan. |
|  | 2 | Peranti kelola aplikasi mendelegasikan kueri perintah parameter komputasi *Group By Category* menuju layanan API Web Service. |
|  | 3 | Web Service mengeksekusi operasi skriptural ORM pada ranah peritungan matematis pengelompokan sumbu pengeluaran lintas ketersediaan dimensi Kategori. |
|  | 4 | Web Service melandaskan rumusan kalkulasi persentase dan memaketkan format penyusunan serangkaian persentase tersebut ke dalam ikatan objek JSON *Array*. |
|  | 5 | Pustaka rekayasa visualisasi (*charting component*) dalam perangkat klien melangsungkan adaptasi konversi properti data persentase kepada bidang rotasi radial interaktif menjadi grafis lingkaran beraneka ragam palet warna (*Pie/Donut Chart*). |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 4.1 | Relasi komputasi bernilai *null*, antarmuka menuntaskan rendering dengan memberikan bingkai abu satu lapis beralasan teks eksplanasi nihil rekaman. |

18. Skenario Use Case Mengirimkan Notifikasi Pengingat Otomatis  
    Tabel 3.24 Skenario Use Case Mengirimkan Notifikasi Pengingat Otomatis

| *Nama Use Case* | *Mengirimkan Notifikasi Pengingat Otomatis* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-018 |  |
| ***Goal in Context*** | Memunculkan notifikasi pengingat secara lokal (*Local Notification*) pada *smartphone* masyarakat untuk rutin mencatat keuangan. |  |
| ***Precondition*** | Aplikasi terpasang dan izin notifikasi diberikan pada sistem operasi ponsel. |  |
| ***Successful End Condition*** | Pesan pengingat berhasil dipicu secara lokal dan dimunculkan oleh perangkat seluler di jam terjadwal. |  |
| ***Failed End Condition*** | Ponsel mati atau izin notifikasi sistem ditolak. |  |
| ***Actors*** | Aplikasi |  |
| ***Trigger*** | Waktu pada sistem perangkat lokal telah mencapai pukul penjadwalan. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Modul pelayanan latar belakang (*background service worker*) internal ponsel terstimulasi sesaat mesin rotasi waktu pendeteksi sistem sinkron menyentuh batas setelan penjadwalan alarm masyarakat. |
|  | 2 | Prosesor latar aplikasi mengeksekusi verifikasi periksa rujukan lokal basis data tanpa GUI guna mengendus apakah persentase frekuensi catatan di hari bersangkutan sudah berstatus terlaksana atau nihil. |
|  | 3 | Jika sistem menangguhkan kondisi absensi catatan, aplikasi menginisialisasi pustaka pemicuan notifikasi mandiri piranti keras (*Local Notification broadcasting channel*). |
|  | 4 | Sistem fungsional penyiaran operasi layar ponsel membangkitkan struktur peringatan berbasis teks interaktif di atas bilah informasi visual Masyarakat. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 2.1 | Algoritma menjejaki keberadaan log interaksi bahwa pendaftaran mutasi pada parameter hari bersangkutan sudah genap, penjadwalan pemicu segera mereset alarm untuk penantian rute siklus peladen harian berikutnya. |

19. Skenario Use Case Menyediakan Pengaturan Preferensi Notifikasi  
    Tabel 3.25 Skenario Use Case Menyediakan Pengaturan Preferensi Notifikasi

| *Nama Use Case* | *Menyediakan Pengaturan Preferensi Notifikasi* |  |
| :---: | ----- | ----- |
| ***Related Requirement*** | SKPL-F-019 |  |
| ***Goal in Context*** | Masyarakat bebas menyesuaikan setelan hari dan jam kapan notifikasi pengingat otomatis boleh dikirimkan. |  |
| ***Precondition*** | Masyarakat masuk ke halaman menu Setelan (*Settings*). |  |
| ***Successful End Condition*** | Data preferensi hari dan jam terbaru tersimpan dengan sinkronisasi Web Service. |  |
| ***Failed End Condition*** | Kegagalan penyimpanan form preferensi karena kendala komunikasi jaringan. |  |
| ***Actors*** | Masyarakat, Web Service |  |
| ***Trigger*** | Masyarakat mengganti nilai pada panel pengaturan jadwal notifikasi. |  |
| ***Include Cases*** | \\- |  |
| ***Main Flow*** | ***Step*** |  ***Action*** |
|  | 1 | Masyarakat bermanuver mengarahkan lintasan ke navigasi konfigurasi pembaruan pilihan "Jadwal Notifikasi Pengingat". |
|  | 2 | Sistem melontarkan konstruksi modal antarmuka pemilihan parameter ganda (*native picker component*) berupa opsi pilihan susunan kualitatif hari kalender ganda dan kuantitatif setelan titik jam pengingat. |
|  | 3 | Masyarakat berinteraksi menyematkan atribut pengaturan pada *checkbox* dan jarum fiktif antarmuka *time picker*, lantas mendorong ketukan eksekusi ke tombol konfirmasi. |
|  | 4 | Aplikasi melaksanakan perintah *save persistence* ke dalam blok penyangga internal preferensi sistem seluler (*shared preferences/secure storage*), diteruskan dengan transmisi mutasi pembaruan ke dalam peladen rute Web Service. |
|  | 5 | Web Service menjamah penimpaan *record* spesifikasi identitas basis data PostgreSQL entitas preferensi menggunakan teknik sintaks manipulasi ORM perbaruan. |
| ***Extension*** | ***Step*** | ***Branch Action*** |
|  | 3.1 | Masyarakat membongkar kesepakatan notifikasi sepenuhnya dengan memadamkan *toggle* prasyarat, sistem mengheningkan layanan pelacakan waktu. |

"""
    
    new_content = content[:start_idx] + replacement + content[end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Successfully replaced scenarios. Start: {start_idx}, End: {end_idx}")

if __name__ == "__main__":
    main()
