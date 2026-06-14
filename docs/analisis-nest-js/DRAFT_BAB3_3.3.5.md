### 3.3.5 Analisis NestJS

Analisis NestJS dilakukan untuk memahami sejauh mana kapabilitas dan efektivitas teknologi *framework* ini dalam berperan sebagai *web service* sentral bagi aplikasi klien (Flutter), serta kemampuannya dalam melakukan integrasi dengan layanan pihak ketiga seperti Gemini API dan Supabase. NestJS dipilih karena memiliki arsitektur modular yang sangat terstruktur, yang memungkinkan pengelolaan komunikasi API, pemrosesan logika bisnis, dan pengamanan kredensial rahasia dilakukan secara efisien di sisi peladen (*server*). Melalui kapabilitas ini, NestJS tidak hanya bertindak sebagai penerima permintaan dari pengguna, tetapi juga sebagai orkestrator tangguh yang menjembatani pemrosesan kecerdasan buatan dan manajemen basis data. Peran krusial NestJS dalam sistem ini dibagi ke dalam tiga analisis integrasi utama yang akan diuraikan pada sub-bab berikut.

#### 3.3.5.1 Analisis Integrasi Komunikasi Klien (Flutter) dengan NestJS

Analisis ini dilakukan untuk memahami kapabilitas NestJS sebagai *web service* dalam mengelola dan mengamankan jalur komunikasi HTTP dari aplikasi klien (Flutter). Dalam konteks ini, NestJS berfungsi sebagai gerbang utama yang memproses setiap permintaan (*request*) pemindaian struk sebelum data tersebut diolah lebih jauh. Fokus utamanya adalah pada keandalan sistem dalam memvalidasi token keamanan secara langsung dan memastikan format data masukan telah sesuai dengan spesifikasi aplikasi. Berdasarkan *flowchart* yang dirancang, alur proses komunikasi ini dapat dilihat pada Gambar 3.x.

![Flowchart Komunikasi Klien NestJS](flowchart-komunikasi-client.drawio)

*Gambar 3.x Flowchart Komunikasi Klien NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. Proses komunikasi diawali ketika aplikasi klien mengirimkan HTTP *request* menuju *endpoint* API pada NestJS. *Request* ini membawa dua elemen utama, yaitu berkas gambar struk belanja dan teks hasil ekstraksi OCR.
2. Sebelum memproses data masukan, server NestJS melakukan tindakan pengamanan awal dengan mengekstrak *JSON Web Token* (JWT) yang disematkan pada bagian *header* HTTP *request*.
3. Sistem kemudian memverifikasi keabsahan sesi pengguna berdasarkan token tersebut. Apabila token tidak valid atau telah kedaluwarsa, server secara otomatis akan menolak permintaan dan mengembalikan respons *401 Unauthorized*. Sebaliknya, apabila token valid, modul *controller* akan menerima *payload* yang dikirimkan.
4. Setelah tahap autentikasi berhasil, sistem menjalankan tahap inspeksi data. Format berkas gambar dan teks diuji kesesuaiannya menggunakan aturan baku yang telah didefinisikan dalam *Data Transfer Object* (DTO).
5. Pada tahap pengujian ini, kelengkapan struktur data divalidasi secara ketat. Jika masukan tidak sesuai dengan spesifikasi DTO, sistem akan menolaknya dengan mengembalikan pesan *400 Bad Request*. Namun, jika data terbukti valid, modul *controller* akan meneruskan parameter tersebut kepada modul *service* untuk pemrosesan logika bisnis lanjutan.
6. Selama modul *service* mengeksekusi logika bisnis, NestJS menerapkan mekanisme pelindung bawaan bernama *Exception Filter*. Jika terjadi kegagalan sistem komputasi yang tidak terduga (*internal server error*), lapisan ini akan mencegah terjadinya *crash* pada server dan mengembalikan respons *500 Internal Server Error* secara aman.
7. Apabila keseluruhan pemrosesan data di modul *service* berjalan dengan sukses, server akan mengembalikan data hasil akhir dalam format JSON sebagai respons kesuksesan kepada aplikasi klien.

#### 3.3.5.2 Analisis Integrasi Gemini API dengan NestJS

Analisis ini bertujuan untuk mengevaluasi sejauh mana kapabilitas NestJS dalam melakukan integrasi dengan layanan Google Gemini API untuk memproses teks hasil pemindaian OCR. Penggunaan NestJS di sini sangat esensial untuk menjaga keamanan kredensial *API Key* agar tidak terekspos di sisi klien. Selain itu, NestJS memanfaatkan kapabilitas komputasi *backend*-nya untuk merakit instruksi (*prompt*) AI secara dinamis dan menangani pertukaran data yang kompleks. *Flowchart* alur integrasi NestJS dengan Gemini API dapat dilihat pada Gambar 3.y.

![Flowchart Integrasi Gemini API NestJS](flowchart-integrasi-llm.drawio)

*Gambar 3.y Flowchart Integrasi Gemini API NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. Proses integrasi dengan layanan kecerdasan buatan dimulai dengan pengamanan kredensial. Server NestJS membaca *API Key* (`GEMINI_API_KEY`) yang disimpan secara ketat di dalam berkas lingkungan `.env`. Pendekatan arsitektural ini dilakukan untuk mencegah tereksposnya kunci rahasia pada sisi aplikasi klien pengguna.
2. Dengan menggunakan kunci referensi tersebut, modul *service* pada lapisan NestJS melakukan inisialisasi terhadap pustaka `@google/genai`, yang berfungsi sebagai modul penghubung utama dengan ekosistem Gemini API.
3. Setelah inisialisasi berhasil, modul *service* menyusun teks mentah hasil OCR menjadi instruksi terstruktur (*prompt*), kemudian mengirimkannya melalui antarmuka HTTP *request* menuju server Gemini API.
4. Selama proses komunikasi data, sistem NestJS mengaktifkan mekanisme *timeout* untuk mengantisipasi keterlambatan laju jaringan. Apabila server pihak ketiga (Google) sedang mengalami gangguan atau tidak merespons dalam rentang waktu yang wajar, NestJS akan mengambil alih kendali dengan memutus koneksi lalu mengembalikan pesan *503 Service Unavailable*.
5. Apabila permintaan berhasil diproses oleh Gemini API, server NestJS akan menerima respons kembalian berupa teks hasil ekstraksi dari *Large Language Model* (LLM).
6. Teks keluaran (*output*) dari AI tersebut kemudian divalidasi dan diurai (*parsing*) untuk memastikan bahwa parameter yang dikembalikan mematuhi struktur format JSON murni. Setelah keutuhan data terverifikasi secara valid, hasil informasi keuangan ini siap dilanjutkan ke proses pencatatan basis data.

#### 3.3.5.3 Analisis Integrasi Supabase dengan NestJS

Analisis ini bertujuan untuk memahami kapabilitas NestJS dalam mengelola persistensi data pengguna melalui integrasi dengan ekosistem layanan Supabase. NestJS mengemban tugas ganda dalam tahap ini, yaitu melakukan sinkronisasi berkas gambar fisik ke layanan *Cloud Storage* dan melakukan pencatatan rekaman pengeluaran ke dalam basis data relasional PostgreSQL. Dengan kapabilitas dukungan *Prisma ORM* dan SDK Supabase, NestJS mampu menjalankan operasi yang presisi untuk menjamin keutuhan data finansial. *Flowchart* alur integrasi Supabase dengan NestJS dapat dilihat pada Gambar 3.z.

![Flowchart Integrasi Database Supabase NestJS](flowchart-integrasi-database.drawio)

*Gambar 3.z Flowchart Integrasi Database Supabase NestJS*

Tahapan proses pada *flowchart* tersebut dijelaskan sebagai berikut:

1. Proses penyimpanan data finansial dimulai ketika server NestJS membaca variabel parameter koneksi dari berkas `.env`. Konfigurasi ini mencakup URL basis data (`DATABASE_URL`) untuk ruang PostgreSQL, serta kredensial antarmuka layanan (`SUPABASE_URL` dan *API Key*) untuk penyimpanan berkas *Cloud Storage*.
2. Memanfaatkan paramater kredensial koneksi tersebut, sistem NestJS menginisialisasi modul *Prisma ORM* yang bertugas penuh untuk mengeksekusi lalu lintas kueri menuju tabel-tabel relasional di dalam PostgreSQL.
3. Secara paralel, sistem juga membentuk ruang koneksi terhadap *Supabase Storage Client*. Layanan ini khusus disiapkan untuk menangani tata kelola objek statis, yakni pengunggahan berkas gambar fisik dari bukti pembayaran.
4. Langkah awal dalam alur transaksi sistem adalah mengunggah (*upload*) berkas gambar struk ke dalam *bucket* penyimpanan Supabase. Apabila proses unggahan terhenti akibat instabilitas sinyal jaringan, operasional seketika dihentikan dan server akan mengembalikan status *503 Service Unavailable* kepada klien.
5. Apabila proses *upload* rampung dengan sempurna, server NestJS akan mengekstrak tautan URL publik yang merepresentasikan gambar tersebut di awan. Tautan akses ini kemudian disematkan ke dalam struktur objek data (*payload*) transaksi riwayat belanja.
6. Selanjutnya, modul *service* memerintahkan *Prisma ORM* untuk memasukkan objek kumpulan transaksi tersebut ke dalam PostgreSQL, yang secara teknis diproteksi menggunakan fitur *database transaction*.
7. Implementasi proteksi dari *database transaction* bertujuan untuk menjamin terpenuhinya prinsip keutuhan data (*Atomicity*). Apabila terjadi kegagalan perekaman parsial ke dalam tabel basis data, *Prisma ORM* secara terprogram akan membatalkan seluruh komit perubahan sistem (*rollback*) demi menghindari inkonsistensi data, lantas meneruskan sinyal pengecualian *error* ke aplikasi klien. Sebaliknya, bila tahapan penyimpanan basis data berjalan sukses, server menyegel keseluruhan rangkaian interaksi penyelesaian transaksi.
