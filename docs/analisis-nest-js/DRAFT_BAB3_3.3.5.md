### 3.3.5 Analisis NestJS

Analisis NestJS dilakukan untuk memahami sejauh mana kapabilitas dan efektivitas teknologi *framework* ini dalam berperan sebagai *web service* sentral bagi aplikasi klien (Flutter), serta kemampuannya dalam melakukan integrasi dengan layanan pihak ketiga seperti Gemini API dan Supabase. NestJS dipilih karena memiliki arsitektur modular yang sangat terstruktur, yang memungkinkan pengelolaan komunikasi API, pemrosesan logika bisnis, dan pengamanan kredensial rahasia dilakukan secara efisien di sisi peladen (*server*). Melalui kapabilitas ini, NestJS tidak hanya bertindak sebagai penerima permintaan dari pengguna, tetapi juga sebagai orkestrator tangguh yang menjembatani pemrosesan kecerdasan buatan dan manajemen basis data. Peran krusial NestJS dalam sistem ini dibagi ke dalam tiga analisis integrasi utama yang akan diuraikan pada sub-bab berikut.

#### 3.3.5.1 Analisis Integrasi Komunikasi Klien (Flutter) dengan NestJS

Analisis ini dilakukan untuk memahami kapabilitas NestJS sebagai *web service* dalam mengelola dan mengamankan jalur komunikasi HTTP dari aplikasi klien (Flutter). Dalam konteks ini, NestJS berfungsi sebagai gerbang utama yang memproses setiap permintaan (*request*) pemindaian struk sebelum data tersebut diolah lebih jauh. Fokus utamanya adalah pada keandalan sistem dalam memvalidasi token keamanan secara langsung dan memastikan format data masukan telah sesuai dengan spesifikasi aplikasi. Berdasarkan *flowchart* yang dirancang, alur proses komunikasi ini dapat dilihat pada Gambar 3.x.

![Flowchart Komunikasi Klien NestJS](flowchart-komunikasi-client.drawio)

*Gambar 3.x Flowchart Komunikasi Klien NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. Aplikasi klien mengirimkan permintaan yang berisi data gambar struk fisik dan teks hasil OCR ke *endpoint* API NestJS.
2. NestJS mengekstrak token keamanan (*JSON Web Token*) dari *header* permintaan.
3. Sistem memeriksa apakah token dan sesi pengguna tersebut valid atau tidak.
   - Jika **Tidak**, sistem menolak permintaan dan mengembalikan pesan *error* dengan status HTTP *401 Unauthorized*.
   - Jika **Ya**, modul *controller* pada NestJS menerima berkas gambar dan teks yang dikirimkan klien.
4. Sistem melakukan validasi terhadap kelengkapan dan format data masukan menggunakan standar *Data Transfer Object* (DTO).
5. Sistem memastikan format masukan sudah sesuai dengan spesifikasi DTO.
   - Jika **Tidak**, sistem mengembalikan pesan *error* dengan status HTTP *400 Bad Request*.
   - Jika **Ya**, modul *controller* meneruskan data yang sudah valid tersebut ke modul *service* untuk diproses.
6. Modul *service* kemudian memproses logika bisnis. Jika di tengah pemrosesan terjadi kesalahan sistem yang tidak terduga (*internal error*), fitur pelindung bawaan NestJS (*Exception Filter*) secara otomatis akan mencegah peladen mati (*crash*) dan mengembalikan status HTTP *500 Internal Server Error*.
7. Namun, apabila seluruh data berhasil diproses tanpa hambatan, sistem akan mengirimkan respons sukses berformat JSON kembali ke aplikasi klien.

#### 3.3.5.2 Analisis Integrasi Gemini API dengan NestJS

Analisis ini bertujuan untuk mengevaluasi sejauh mana kapabilitas NestJS dalam melakukan integrasi dengan layanan Google Gemini API untuk memproses teks hasil pemindaian OCR. Penggunaan NestJS di sini sangat esensial untuk menjaga keamanan kredensial *API Key* agar tidak terekspos di sisi klien. Selain itu, NestJS memanfaatkan kapabilitas komputasi *backend*-nya untuk merakit instruksi (*prompt*) AI secara dinamis dan menangani pertukaran data yang kompleks. *Flowchart* alur integrasi NestJS dengan Gemini API dapat dilihat pada Gambar 3.y.

![Flowchart Integrasi Gemini API NestJS](flowchart-integrasi-llm.drawio)

*Gambar 3.y Flowchart Integrasi Gemini API NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. NestJS membaca kredensial kunci API (`GEMINI_API_KEY`) yang disimpan secara aman di dalam berkas konfigurasi `.env`. Hal ini dilakukan di peladen untuk mencegah tereksposnya kunci API pada perangkat pengguna.
2. Modul layanan di NestJS menggunakan kunci tersebut untuk menginisialisasi pustaka pemrosesan AI, yaitu `@google/genai`.
3. Modul layanan menyusun teks mentah (*rawText*) menjadi *prompt* terstruktur, lalu mengirimkan permintaan ke peladen Gemini API.
4. Pada tahap ini, NestJS menerapkan batas waktu tunggu (*timeout*). Jika server pihak ketiga (Google) sedang gangguan atau tidak merespons dalam batas waktu tersebut, NestJS dengan sigap memutus koneksi dan mengembalikan pesan *error* dengan status HTTP *503 Service Unavailable*.
5. Apabila Gemini API merespons dengan sukses, NestJS akan menerima teks keluaran dari AI dan memvalidasi kelengkapan datanya.
6. Hasil yang sudah tervalidasi kemudian dikonversi menjadi format JSON terstruktur untuk dilanjutkan ke proses pencatatan basis data atau dikembalikan ke klien.

#### 3.3.5.3 Analisis Integrasi Supabase dengan NestJS

Analisis ini bertujuan untuk memahami kapabilitas NestJS dalam mengelola persistensi data pengguna melalui integrasi dengan ekosistem layanan Supabase. NestJS mengemban tugas ganda dalam tahap ini, yaitu melakukan sinkronisasi berkas gambar fisik ke layanan *Cloud Storage* dan melakukan pencatatan rekaman pengeluaran ke dalam basis data relasional PostgreSQL. Dengan kapabilitas dukungan *Prisma ORM* dan SDK Supabase, NestJS mampu menjalankan operasi yang presisi untuk menjamin keutuhan data finansial. *Flowchart* alur integrasi Supabase dengan NestJS dapat dilihat pada Gambar 3.z.

![Flowchart Integrasi Database Supabase NestJS](flowchart-integrasi-database.drawio)

*Gambar 3.z Flowchart Integrasi Database Supabase NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. NestJS membaca parameter koneksi dari berkas `.env`, yang mencakup URL basis data (`DATABASE_URL`) untuk PostgreSQL, serta kredensial layanan (`SUPABASE_URL` dan *API Key*) untuk penyimpanan *file*.
2. Menggunakan koneksi basis data tersebut, NestJS menginisialisasi *Prisma ORM* untuk mengelola jalur komunikasi ke tabel-tabel di PostgreSQL.
3. Di waktu yang sama, NestJS juga menginisialisasi *Supabase Storage Client* menggunakan kredensial layanan untuk mengelola unggahan gambar struk.
4. Saat proses berjalan, NestJS akan terlebih dahulu mengunggah gambar struk fisik ke ruang penyimpanan *bucket* Supabase. Apabila proses unggahan gagal karena gangguan jaringan, proses langsung dihentikan dan sistem mengembalikan pesan kegagalan (*HTTP 503*).
5. Jika unggahan berhasil, sistem menerima tautan publik (URL) dari gambar tersebut dan menggabungkannya dengan data riwayat transaksi.
6. NestJS kemudian mengirimkan perintah pencatatan ke PostgreSQL menggunakan fitur transaksi basis data (*database transaction*) bawaan dari *Prisma ORM*.
7. Melalui mekanisme transaksi ini, NestJS menjamin keutuhan data (*Atomicity*). Apabila terjadi kegagalan mendadak saat pencatatan di pangkalan data, NestJS secara otomatis akan membatalkan seluruh proses penyimpanan (*rollback*) sehingga tidak ada data sebagian yang tertinggal, lalu mengirimkan laporan kesalahan ke aplikasi klien. Apabila berhasil, sistem merampungkan seluruh proses transaksi.
