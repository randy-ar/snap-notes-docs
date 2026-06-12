### 3.3.5 Analisis NestJS

Analisis NestJS difokuskan pada perancangan arsitektur *back-end* sebagai *Web Server* sentral yang bertugas mengorkestrasi tiga komponen utama ekosistem aplikasi: Aplikasi Klien (Flutter), Layanan Penyimpanan dan Autentikasi (Supabase), serta Layanan Pemrosesan Kecerdasan Buatan (Gemini AI). Penggunaan NestJS didasarkan pada dukungan arsitektur modular yang ketat (*modular architecture*) serta penerapan pola desain *Controller-Service* yang memperjelas pemisahan tanggung jawab (*Separation of Concerns*). Dalam perancangan sistem Snap Notes, peran NestJS sebagai penghubung dibagi ke dalam tiga lapisan integrasi utama yang akan diuraikan lebih lanjut pada sub-bab berikut.

#### 3.3.5.1 Analisis Komunikasi Client NestJS

Analisis komunikasi *client* dengan NestJS dilakukan untuk menjabarkan bagaimana antarmuka API pada peladen (*server*) menangani aliran permintaan dari aplikasi seluler pengguna. Lapisan komunikasi ini memegang peranan penting sebagai gerbang keamanan dan validasi awal, di mana sistem akan memastikan setiap pengguna memiliki sesi otorisasi yang sah serta menjamin bahwa data masukan, seperti berkas gambar dan hasil ekstraksi OCR, telah memenuhi standar format sebelum masuk ke proses pengolahan bisnis utama.

Berikut adalah gambaran *flowchart* alur komunikasi *client* menuju layanan *Controller* pada NestJS yang ditunjukkan oleh Gambar 3.x:
*(Sisipkan Gambar Flowchart Komunikasi Client NestJS di sini)*
Gambar 3.x Flowchart Alur Komunikasi Client - NestJS

Berdasarkan *flowchart* yang telah dijabarkan, berikut adalah algoritma deskriptif dari setiap langkah yang dieksekusi:
1. Alur komunikasi diawali saat aplikasi klien Flutter mengirimkan permintaan HTTP menuju *endpoint* `POST /struk/scan`, yang membawa muatan data (*payload*) berupa berkas gambar struk fisik beserta teks mentah hasil pemindaian OCR.
2. Permintaan yang masuk akan dicegat terlebih dahulu oleh `SupabaseAuthGuard`. Komponen pelindung ini bertugas membongkar *header* dari permintaan untuk mengekstrak keberadaan token keamanan JWT (*JSON Web Token*) milik pengguna.
3. Sistem kemudian memverifikasi integritas dan keabsahan sesi dari token JWT tersebut dengan mencocokkannya terhadap layanan autentikasi.
4. Apabila token terdeteksi usang, tidak valid, atau tidak ditemukan, sistem akan memblokir akses secara sepihak dan mengembalikan respons HTTP `401 Unauthorized` guna mencegah akses yang tidak sah.
5. Sebaliknya, jika pengguna dinyatakan valid, eksekusi permintaan akan diteruskan menuju `StrukController` yang mengeksekusi fungsi `scanStruk()`. Pada tahap ini, pengontrol mengamankan identitas pengguna beserta berkas gambar dan data teks yang dilampirkan.
6. Sebelum data dilempar ke inti aplikasi, komponen `ValidationPipe` akan menyeleksi objek masukan pada struktur `ScanStrukDto` untuk memastikan seluruh atribut wajib telah terisi dengan tipe data yang dapat dipertanggungjawabkan.
7. Sistem meninjau kembali hasil dari penyaringan pipa validasi tersebut untuk mengambil keputusan eksekusi lanjutan.
8. Jika struktur data masukan ternyata cacat atau tidak lengkap, NestJS secara otomatis merespons klien dengan status HTTP `400 Bad Request` sebagai indikator penolakan parameter.
9. Apabila seluruh validasi format berhasil dilewati, pengontrol akhirnya mendelegasikan tugas pemrosesan aplikasi secara komprehensif ke fungsi `scanStruk()` yang berada di dalam lingkup `StrukService`.
10. Rangkaian interaksi ini ditutup setelah modul layanan menyelesaikan pekerjaannya; `StrukController` akan merangkum informasi hasil laporan ke dalam bentuk `StrukResponseDto` dan mengembalikannya ke layar perangkat pengguna sebagai respons berformat JSON dengan status `201 Created`.

#### 3.3.5.2 Analisis Integrasi LLM dengan NestJS

Analisis integrasi LLM dilakukan untuk mengevaluasi bagaimana NestJS menjembatani proses strukturisasi teks OCR mentah menggunakan kemampuan analitis model kecerdasan buatan dari Google. Dengan mendelegasikan pengolahan ini pada sisi *server*, sistem dapat menerapkan teknik *prompt engineering* yang canggih sambil tetap merahasiakan kredensial kunci API dari perangkat pengguna akhir. Alur ini merancang bagaimana peladen menyusun instruksi yang memuat konteks spasial gambar struk agar Gemini AI dapat memetakan format JSON transaksi yang akurat.

Berikut adalah gambaran *flowchart* alur kerja integrasi pemrosesan *Language Model* dengan NestJS yang ditunjukkan oleh Gambar 3.y:
*(Sisipkan Gambar Flowchart Integrasi LLM NestJS di sini)*
Gambar 3.y Flowchart Alur Integrasi LLM (Gemini AI) - NestJS

Berdasarkan *flowchart* yang telah dijabarkan, berikut adalah algoritma deskriptif dari setiap langkah yang dieksekusi:
1. Tahapan integrasi dimulai ketika `StrukService` menerima objek parameter `ocrData` yang dikirimkan oleh klien dalam bentuk teks murni berformat JSON.
2. Sistem mengurai teks JSON tersebut untuk mengekstraksi dua komponen struktural utama, yaitu `rawText` yang mewakili rincian keseluruhan teks hasil pemindaian, serta koleksi `lines` yang memuat setiap baris teks beserta informasi titik koordinat visualnya.
3. Setelah proses ekstraksi awal selesai, sistem melakukan pengecekan validitas internal untuk memastikan bahwa variabel teks mentah dan daftar koordinat tidak berada dalam kondisi kosong.
4. Jika kelengkapan data ruang spasial OCR tersebut tidak terpenuhi, proses akan dihentikan seketika dengan sistem menerbitkan pengecualian `UnprocessableEntityException` dengan status 422 kepada klien.
5. Memasuki tahap komputasi AI, aplikasi memanfaatkan kelas pengatur `LLMFactory.getProvider()` untuk memanggil instansi layanan spesifik, yaitu `GeminiService`, yang memegang tanggung jawab penuh atas interaksi dengan sistem kecerdasan buatan.
6. Modul layanan mengeksekusi fungsi `buatPrompt()` guna merakit instruksi terpadu. Teks mentah dan pemetaan posisi spasial diolah menjadi satu kesatuan perintah (*prompt*) yang terstruktur, memberikan panduan tata letak bagi AI untuk mengekstraksi makna logis pada setiap lokasi kolom struk.
7. Sistem melangsungkan komunikasi keluar dengan memanggil layanan `genAI.models.generateContent()`, yang bertugas mengangkut muatan instruksi komprehensif tersebut menuju peladen model `gemini-2.5-flash`.
8. Selama proses kognisi berlangsung, peladen menerapkan mekanisme pertahanan batas waktu tunggu (*timeout*) maksimal sebesar 28 detik untuk mencegah aplikasi menggantung akibat respon balik API eksternal yang tidak menentu.
9. Apabila kecerdasan buatan gagal menyodorkan tanggapan dalam tenggat waktu tersebut, NestJS akan memutus saluran koneksi secara otomatis dan mencetuskan pengecualian `ServiceUnavailableException` (503).
10. Namun, apabila luaran berhasil dikembalikan dengan selamat, tahap pamungkas dikelola oleh fungsi `validasiResponse()`. Proses ini membongkar tanggapan, mendeteksi ketersediaan atribut esensial seperti nama toko, nominal nilai total, serta deretan komoditas belanjaan, guna memastikan kesiapan data finansial tersebut untuk pencatatan permanen.

#### 3.3.5.3 Analisis Integrasi Database dengan NestJS

Analisis integrasi *database* menjabarkan strategi pengamanan persistensi data ganda yang dilakukan NestJS terhadap luaran pemrosesan AI. Pada rancangan ini, sistem harus menjamin bahwa berkas gambar mentah berhasil diunggah ke dalam wadah penyimpanan *cloud* (*Supabase Storage*), sementara entitas hasil ekstraksi transaksinya dapat disinkronkan ke dalam basis data relasional (*PostgreSQL*) secara atomik. Pendekatan transaksi terpusat menggunakan abstraksi *Prisma ORM* diaplikasikan guna memitigasi kemungkinan anomali data di mana gambar tersimpan namun catatan keuangan gagal direkam, atau sebaliknya.

Berikut adalah gambaran *flowchart* alur kerja penyelarasan data NestJS dengan layanan Supabase yang ditunjukkan oleh Gambar 3.z:
*(Sisipkan Gambar Flowchart Integrasi Database NestJS di sini)*
Gambar 3.z Flowchart Alur Integrasi Database (Supabase + Prisma) - NestJS

Berdasarkan *flowchart* yang telah dijabarkan, berikut adalah algoritma deskriptif dari setiap langkah yang dieksekusi:
1. Skenario persistensi secara formal terpicu sesaat setelah `StrukService` merengkuh objek `ParsedStrukDto` yang memuat rangkuman ekstraksi transaksi dari penyedia layanan *Language Model*.
2. Sebagai tahap permulaan, sistem berupaya mendokumentasikan berkas visual dengan mengeksekusi metode `uploadGambarStruk()` pada perantara `StorageService`. Perintah ini menyalurkan bit-bit muatan memori gambar dari pengguna langsung ke fasilitas peletakan data *bucket* milik Supabase.
3. Setelah serah terima dilakukan, peladen meninjau isyarat status transmisi berkas gambar tersebut guna mendeteksi ada tidaknya gangguan koneksi yang mengancam keutuhan fail.
4. Jika proses penempatan fisik mengalami kendala layanan, algoritma akan terputus dan membuang pengecualian fungsional bersandi HTTP 503 (`ServiceUnavailableException`) ke klien pengunggah.
5. Sebaliknya, saat berkas dilabuhkan dengan sukses, layanan pangkalan data mendistribusikan representasi objek `StorageResultDto` yang menampung rute permanen penyimpanan serta alamat tautan bebas (*publicUrl*) yang kelak melekat secara eksklusif pada riwayat struk.
6. Memasuki fase pengolahan data persisten, sistem memetakan kumpulan teks JSON transaksi ke dalam skema entitas yang berelasi. Proses ini mencakup identifikasi kategori anggaran yang relevan, serta pengelompokan entitas induk (struk) beserta rincian entitas anak (barang-barang belanjaan).
7. Sebagai tahap pemungkas, seluruh catatan yang telah dipetakan tersebut disimpan secara serentak ke dalam tabel-tabel PostgreSQL di Supabase. Proses penyisipan ini dibungkus dalam sebuah transaksi atomik (*database transaction*) guna memastikan bahwa riwayat pengeluaran hanya akan tercatat apabila seluruh skenario pengamanan—mulai dari relasi barang hingga tautan gambar—berhasil dieksekusi tanpa cela.
