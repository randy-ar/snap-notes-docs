# **BAB 3**

# **ANALISIS DAN PERANCANGAN**

1. # **Analisis Masalah**

Langkah pertama dalam pembangunan sistem adalah melakukan analisis masalah yang bertujuan untuk memahami isu-isu yang ada pada sistem yang sedang berjalan. Dalam penelitian ini, analisis dilakukan untuk mengidentifikasi masalah yang dihadapi oleh mahasiswa terkait penerjemahan artikel jurnal, bantuan pemahaman lebih dari abstrak artikel jurnal berbahasa asing, serta membantu memahami definisi dari kata atau frasa. Temuan dari analisis ini akan menjadi landasan dalam merancang sistem yang dapat memenuhi kebutuhan.  
Dari hasil analisis yang dilakukan terhadap mahasiswa ditemukan beberapa permasalahan sebagai berikut:

1. Mahasiswa memerlukan waktu lama untuk menerjemahkan artikel jurnal berbahasa asing karena keterbatasan kemampuan bahasa, sehingga memerlukan waktu lama untuk memahami isi artikel jurnal.  
2. Mahasiswa memerlukan waktu lama untuk memperoleh pemahaman lebih dari abstrak artikel jurnal berbahasa asing.  
3. Mahasiswa memerlukan waktu lama untuk memahami definisi dari kata atau frasa bahasa asing yang belum dipahami saat membaca artikel jurnal.

   2. # **Analisis Proses Bisnis**

Analisis proses bisnis adalah upaya untuk memahami cara sistem operasional sedang berjalan saat ini. Tujuan dari analisis ini adalah untuk membantu memahami sistem yang sedang berjalan, karena perlu memiliki pemahaman tentang struktur dan cara kerja yang terlibat dalam proses tersebut. Adapun alur kerja proses bisnis untuk kegiatan penerjemahan artikel jurnal, serta pemahaman definisi dari kata atau frasa oleh mahasiswa adalah sebagai berikut:

1. Mahasiswa mencari artikel jurnal yang relevan dengan topik yang dicarinya dari berbagai sumber *online.*

46

2. Artikel jurnal yang ditemukan sebagian besar berbahasa asing (seperti Bahasa Inggris, Jepang, Jerman, dan bahasa lainnya), serta diunduh dalam format *PDF*.  
3. Mahasiswa membuka artikel jurnal tersebut, lalu membaca secara perlahan untuk memahami isinya.

4. Karena keterbatasan kemampuan bahasa, mahasiswa melakukan penerjemahan dengan menyalin paragraf/kalimat, atau terkadang menerjemahkan seluruh dokumen artikel jurnal ke dalam aplikasi penerjemah seperti *Google Translate*.

5. Mahasiswa kemudian melanjutkan untuk memahami dan menganalisis hasil terjemahan guna menggali konteks yang relevan dari artikel jurnal.

6. Ketika menemukan definisi dari kata atau frasa bahasa asing yang belum dipahami, mahasiswa mencari definisi tambahan melalui penelusuran *internet* manual, kamus, atau sumber literatur akademik lain secara terpisah.

7. Proses ini dilakukan berulang kali untuk seluruh istilah dalam artikel jurnal.

8. Proses dianggap selesai setelah mahasiswa merasa seluruh isi artikel sudah diterjemahkan dan dipahami sesuai kebutuhan.

Deskripsi dari alur kerja proses bisnis penerjemahan artikel jurnal, serta pemahaman definisi dari kata atau frasa dapat digambarkan menggunakan *BPMN (Business Process Model and Notation). BPMN* adalah sebuah standar notasi grafis berorientasi bisnis yang digunakan untuk menggambarkan langkah-langkah dalam proses bisnis dari awal hingga akhir dengan cara yang mudah dimengerti. Setiap langkah, keputusan dan interaksi dalam suatu proses bisnis dapat dimodelkan menggunakan notasi terstruktur dalam *BPMN*, yang memudahkan analisis proses bisnis. Dalam penerjemahan artikel jurnal, penerapan *BPMN* dapat mendukung dokumentasi proses bisnis secara sistematis. Berikut adalah gambaran proses bisnis menggunakan *BPMN* dapat dilihat pada Gambar 3.1:

![][image1]

Gambar 3.1 Alur Kerja Proses Bisnis

3. # **Analisis Teknologi**

Analisis teknologi digunakan untuk memahami jenis teknologi yang dibutuhkan dalam pembangunan sistem. Selain itu, analisis ini juga memberikan gambaran tentang proses penggunaan teknologi dalam sistem yang akan dibangun. Analisis teknologi mencakup pemahaman mendalam mengenai tren terbaru dalam teknologi serta potensi inovasi yang dapat diadopsi ke dalam sistem. Sistem yang mengadaptasi teknologi diharapkan memberi manfaat berkelanjutan bagi penggunanya.

1. # **Analisis Arsitektur Sistem**

Analisis arsitektur sistem menjelaskan singkat bagaimana sistem penerjemahan artikel jurnal, bantuan pemahaman definisi dari kata atau frasa, serta bantuan peringkasan otomatis artikel jurnal dengan memanfaatkan *DeepL* dan *Gemini* yang akan dibangun. Pada bagian ini akan memberikan gambaran mendalam tentang bagian-bagian utama sistem dan bagaimana mereka berinteraksi satu sama lain. Dapat dilihat pada Gambar 3.2 berikut:

![][image2]

Gambar 3.2 Arsitektur Sistem

Mengenai garis besar gambaran umum sistem dari sistem yang akan dibangun pada Gambar 3.2, maka penjelasan alur sistemnya adalah sebagai berikut:

1. Pengguna berinteraksi dengan Aplikasi

   Pengguna memulai akses melalui perangkat *Android* mereka, menggunakan aplikasi penerjemah multibahasa. Interaksi awal berupa pemilihan file jurnal dalam format *PDF* untuk diunggah dan diproses.

2. Aplikasi memproses input dengan *iText*

   Pengguna mengunggah file artikel jurnal dalam format *PDF*. Aplikasi akan memanfaatkan teknologi *iText* untuk mengekstrak teks dari dokumen *PDF* tersebut.

3. *iText* mengirimkan teks yang diekstrak ke Aplikasi

   Teks yang berhasil diekstrak oleh *iText* akan dikirimkan kembali ke aplikasi untuk diproses lebih lanjut.

4. Aplikasi mengirimkan teks untuk validasi Artikel Jurnal ke Backend Server

   Setelah ekstraksi teks dan sebelum terjemahan, aplikasi akan mengirimkan teks yang diekstrak dari dokumen PDF ke *backend server*. Aplikasi melakukan ini untuk memastikan dokumen adalah artikel jurnal.

5. Backend Server mengirim teks untuk vallidasi ke Gemini

   *Backend server* menerima teks dari aplikasi, menyusun *prompt* khusus, dan mengirimkannya ke Gemini API (melalui pustaka google/generative- ai) untuk menganalisis dan memvalidasi apakah teks tersebut merupakan artikel jurnal.

6. Gemini mengembalikan hasil validasi ke Backend Server

   Gemini API merespons dengan indikasi "YES" atau "NO" berdasarkan analisis teks.

7. Backend Server mengembalikan hasil validasi ke Aplikasi

   *Backend server* mengirimkan hasil validasi kembali ke aplikasi. Jika Gemini mengembalikan "NO" (dokumen bukan artikel jurnal), aplikasi akan menampilkan pesan *error* dan menghentikan proses terjemahan di sini.

8. Aplikasi mengirimkan file/teks ke Backend Server

   Jika dokumen telah teridentifikasi sebagai artikel jurnal yang valid (dari langkah 7), aplikasi akan mengirimkan file PDF asli yang diunggah ke *backend server.*

9. *Backend Server* berkomunikasi dengan *DeepL* melalui Axios

   - *Backend server* menerima file *PDF* dari aplikasi.

   - *Backend server* memanggil *DeepL API* menggunakan pustaka Axios untuk mengirim permintaan dengan respons HTTP untuk proses penerjemahan. *DeepL API* digunakan karena kemampuannya  untuk  menerjemahkan  dokumen  sekaligus

mempertahankan tata letak aslinya dan mengembalikan hasilnya dalam format *PDF.*

10. *DeepL API* mengembalikan hasil terjemahan (*PDF)* ke *Backend Server DeepL API* memproses permintaan terjemahan, mempertahankan struktur asli dokumen, dan mengembalikan hasilnya (dokumen yang sudah diterjemahkan) dalam format *PDF* ke *backend server* melalui Axios untuk menerima respons HTTP hasil terjemahan.

11. *Backend Server* mengirimkan teks ke *Gemini API*

    - *Backend server* akan mengambil teks dari dokumen *PDF* yang telah diterima (atau memproses teks yang sudah diekstrak dari awal) dan mengirimkannya ke *Gemini API* untuk proses peringkasan.

    - Jika pengguna membutuhkan penjelasan lebih lanjut mengenai definisi kata atau frasa dalam artikel jurnal, permintaan untuk penjelasan definisi juga akan dikirimkan dari aplikasi ke *backend server*, yang kemudian meneruskannya ke *Gemini API*.

12. *Gemini API* mengembalikan definisi/ringkasan ke *Backend Server*

    *Gemini API* memproses permintaan dan mengembalikan ringkasan otomatis atau definisi kata frasa yang diminta kepada *backend server.*

13. *Backend Server* mengirimkan data yang didapat ke *Firebase*

    Backend server mengunduh hasil terjemahan PDF dari DeepL API, menyimpan file PDF tersebut ke Firebase Cloud Storage, dan menyimpan metadata (termasuk URL unduhan file tersebut) serta riwayat penggunaan ke Firebase Firestore. Backend server juga akan mengirimkan hasil terjemahan PDF (atau konfirmasi keberadaan dan URL-nya) dan ringkasan kembali ke aplikasi.

14. *Firebase* mengembalikan status/data ke *Backend Server*

    *Firebase* merespons permintaan dari *backend server*, baik berupa status penyimpanan data atau data yang diminta.

15. *Backend Server* mengembalikan hasil/data ke Aplikasi

    *Backend server* akan mengirimkan semua hasil yang relevan (file *PDF*

    hasil terjemahan, definisi, ringkasan) kembali ke aplikasi.

16. Aplikasi menampilkan hasil akhirnya

    Hasil yang ditampilkan berupa hasil terjemahan artikel jurnal, hasil ringkasan, serta penjelasan definisi dari kata atau frasa.

    2. # **Analisis DeepL API**

Analisis DeepL API dilakukan untuk memahami kapabilitas dan efektivitas teknologi penerjemahan yang diintegrasikan ke dalam sistem. DeepL dipilih karena kemampuannya untuk menghasilkan terjemahan yang lebih alami, akurat, dan kontekstual dibandingkan dengan penerjemah mesin lainnya, terutama untuk teks-teks kompleks dan formal seperti artikel ilmiah.

Dalam konteks pembangunan aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android ini, DeepL API diintegrasikan sebagai komponen inti untuk mengatasi tantangan pemahaman jurnal ilmiah berbahasa asing yang dialami mahasiswa. Fungsi utama DeepL API dalam aplikasi ini adalah menerjemahkan dokumen artikel jurnal dari satu bahasa ke bahasa lain secara otomatis. Aplikasi mengirimkan file dokumen (khususnya PDF) ke DeepL API, yang kemudian memprosesnya dan mengembalikan hasil terjemahan dalam format PDF yang mempertahankan tata letak asli teks. Proses ini sangat krusial karena mahasiswa seringkali mengunduh artikel jurnal dalam format PDF dan membutuhkan terjemahan yang tidak mengubah struktur dokumen.  
Berikut adalah flowchart proses untuk penerjemahan pada DeepL dapat dilihat pada Gambar 3.3:

![][image3]

Gambar 3.3 Analisis Penerjemahan DeepL

Berikut merupakan alur proses penggunaan DeepL untuk penerjemahan:

1. Pengguna, melalui aplikasi atau antarmuka DeepL, mengirimkan teks atau dokumen yang ingin diterjemahkan. Ini termasuk menentukan bahasa sumber dan bahasa target.  
2. Sistem DeepL menerima data input dari pengguna.

3. DeepL menggunakan *transformer-based neural networks* untuk memproses input. Teknologi ini memungkinkan sistem untuk belajar dari volume data yang sangat besar dan memahami konteks linguistik secara mendalam.

4. Jaringan saraf tiruan DeepL menganalisis struktur kalimat, konteks semantik, dan sintaksis teks input secara menyeluruh. Ini membantu dalam menghasilkan terjemahan yang lebih koheren dan sesuai makna aslinya.

5. Berdasarkan analisis, DeepL menghasilkan terjemahan yang tidak hanya akurat secara literal tetapi juga terdengar alami dan kontekstual, mendekati kualitas terjemahan manusia.

6. Hasil terjemahan dikirimkan kembali kepada pengguna melalui API. Jika input adalah dokumen, DeepL berupaya mempertahankan tata letak asli dalam format yang sama (misalnya PDF).

7. Aplikasi yang terintegrasi dengan DeepL API menerima hasil terjemahan dan menampilkannya kepada pengguna.

Berikut adalah contoh implementasi DeepL API pada Aplikasi yang dibangun. Dalam pembangunan aplikasi ini, mencakup tiga tahapan utama:

1. Upload Dokumen

File PDF yang dipilih oleh pengguna diunggah ke DeepL API. Berikut adalah table spesifikasi Spesifikasi *Request* pada Upload Dokumen dapat dilihat pada Tabel 3.1:

Tabel 3.2 Spesifikasi *Request* pada Upload Dokumen

| Spesifikasi *Request* |  |
| ----- | :---- |
| **URL** | https://api.deepl.com/v2/document |
| **Method** | POST |
| **Format** | multipart/form-data |
| **Parameter** | file target\_lang |
|  **Contoh Request** | POST /v2/document HTTP/2 Host: api.deepl.com Authorization: DeepL-Auth-Key \[yourAuthKey\] User-Agent: YourApp/1.2.3 Content-Length: \[length\] Content-Type: multipart/form-data;boundary="boundary" \--boundary,Content-Disposition: form-data; name=target\_lang ID \--boundary,Content-Disposition: form-data; name=file @document.pdf |

Berikut	adalah	table	spesifikasi	Spesifikasi	*Response*	pada	Upload Dokumen dapat dilihat pada Tabel 3.2:  
Tabel 3.2 Spesifikasi *Response* pada Upload Dokumen

| Spesifikasi *Response* |  |
| ----- | :---- |
| **Format** | JSON |
|  **Contoh Response** | { "document\_id": "04DE5AD98A02647D83285A36021911C6", "document\_key": "0CB0054F1C132C1625B392EADDA41CB754A742822F6877173029A6C487E7F 60A" } |

Respons ini mengandung parameter document\_id dan document\_key yang unik untuk melacak status terjemahan.

2. Cek Status Dokumen dan Menunggu Terjemahan Selesai

Aplikasi secara berkala memeriksa status terjemahan dokumen. Berikut adalah table spesifikasi Spesifikasi *Request* pada Menunggu Terjemahan Selesai dilihat pada Tabel 3.3:

Tabel 3.3 Spesifikasi *Request* pada Menunggu Terjemahan Selesai

| Spesifikasi *Request* |  |
| ----- | :---- |
| **URL** | https://api.deepl.com/v2/document/{document\_id} |
| **Method** | POST |
| **Format** | JSON |
| **Parame ter** | document\_id document\_key |
|  **Contoh Request** | POST /v2/document/{document\_id} HTTP/2 Host: api.deepl.com Authorization: DeepL-Auth-Key \[yourAuthKey\] User-Agent: YourApp/1.2.3 Content-Length: 83 Content-Type: application/json {"document\_key":"0CB0054F1C132C1625B392EADDA41CB754A742822F6877173 029A6C487E7F60A"} |

Berikut adalah table spesifikasi Spesifikasi *Response* pada Menunggu Terjemahan Selesai dapat dilihat pada Tabel 3.4:  
Tabel 3.4 Spesifikasi *Response* pada Menunggu Terjemahan Selesai

| Spesifikasi *Response* |  |
| ----- | :---- |
| **Format** | JSON |
| **Contoh Response Menerjemahkan** | { "document\_id": "04DE5AD98A02647D83285A36021911C6", "status": "translating", "seconds\_remaining": 20 } |
| **Contoh Response Selesai** | { "document\_id": "04DE5AD98A02647D83285A36021911C6", "status": "done", "billed\_characters": 1337 } |
| **Contoh Response Queued** | { "document\_id": "04DE5AD98A02647D83285A36021911C6", "status": "queued" } |
|  **Contoh Response Error** | { "document\_id": "04DE5AD98A02647D83285A36021911C6", "status": "error", "message": "Source and target language are equal." |

| Spesifikasi *Response* |  |
| ----- | :---- |
|  | } |

3. Mengunduh Hasil Terjemahan

   Setelah terjemahan selesai, aplikasi mengunduh dokumen hasil terjemahan.

Berikut adalah table spesifikasi Spesifikasi *Request* pada Mengunduh Hasil Terjemahan dilihat pada Tabel 3.5:  
Tabel 3.5 Spesifikasi *Request* pada Mengunduh Hasil Terjemahan

| Spesifikasi *Request* |  |
| ----- | :---- |
| **URL** | https://api.deepl.com/v2/document/{document\_id}/result |
| **Method** | POST |
| **Format** | JSON |
| **Parame ter** | document\_id document\_key |
|  **Contoh Request** | POST /v2/document/{document\_id}/result HTTP/2 Host: api.deepl.com Authorization: DeepL-Auth-Key \[yourAuthKey\] User-Agent: YourApp/1.2.3 Content-Length: 83 Content-Type: application/json {"document\_key":"0CB0054F1C132C1625B392EADDA41CB754A742822F6877173 029A6C487E7F60A"} |

Responsnya adalah data biner langsung dari file dokumen yang telah diterjemahkan (misalnya, PDF). Aplikasi akan menerima. *stream byte* ini untuk disimpan sebagai file.

Penerapan teknologi DeepL ini membawa dampak yang signifikan terhadap cara mahasiswa berinteraksi dengan materi ilmiah berbahasa asing. DeepL digunakan untuk menghasilkan terjemahan artikel jurnal yang lebih akurat, natural, dan kontekstual dibandingkan dengan penerjemah mesin umum. Hal ini secara langsung mengurangi waktu dan usaha yang dibutuhkan mahasiswa untuk memeriksa dan mengoreksi hasil terjemahan manual atau yang kurang akurat, serta meminimalkan risiko kesalahpahaman konsep penting. Namun, hasil terjemahan otomatis tetap memerlukan evaluasi kritis dari mahasiswa untuk memastikan interpretasi yang utuh dan akurat sesuai konteks akademik.

3. # **Analisis Gemini API**

Analisis Gemini API dilakukan untuk memahami kapabilitas model kecerdasan buatan multimodal yang diintegrasikan ke dalam sistem. Dalam sistem

ini, Gemini AI digunakan untuk mempermudah mahasiswa dalam memahami istilah teknis dan ilmiah pada artikel jurnal. Aplikasi ini memanfaatkan kemampuan Pemrosesan Bahasa Alami (NLP) Gemini AI untuk menganalisis teks terjemahan dan mengidentifikasi istilah-istilah khusus yang jarang digunakan dalam percakapan sehari-hari. Gemini AI menyediakan penjelasan kontekstual atau definisi yang relevan untuk istilah-istilah tersebut secara langsung. Hal ini bertujuan untuk mengurangi waktu dan usaha mahasiswa dalam mencari definisi secara manual, serta mempercepat pemahaman keseluruhan artikel.  
Berikut adalah flowchart proses analisis pada Gemini dapat dilihat pada Gambar 3.4:

Gambar 3.4 Analisis Gemini API

Berikut merupakan alur proses penggunaan Gemini untuk peringkasan dan penjelasan kata atau frasa:

1. Aplikasi pengguna mengirimkan permintaan ke Gemini API. Untuk peringkasan, ini berupa seluruh teks dokumen. Untuk penjelasan istilah, ini berupa kata atau frasa yang dipilih beserta konteks dokumennya.  
2. Sistem Gemini menerima input dari aplikasi pengguna. Karena Gemini adalah model multimodal, ia dapat memproses berbagai jenis data, namun dalam konteks ini fokus pada teks.

3. Gemini menggunakan arsitektur *transformer-based neural networks* untuk memproses input teks. Model ini dirancang untuk memahami dan mengolah informasi dari berbagai modalitas, yang membantunya dalam menganalisis teks secara mendalam.  
4. Gemini menganalisis input teks untuk memahami konteks keseluruhan dokumen, bahasa yang digunakan, dan struktur informasi di dalamnya. Untuk permintaan penjelasan istilah, ini mencakup pemahaman konteks di sekitar kata atau frasa yang diminta.

5. Apabila permintaan adalah untuk meringkas dokumen, Gemini akan memproses teks tersebut untuk menghasilkan ringkasan yang terperinci, detail, dan terurut, seringkali dalam format Markdown sesuai permintaan.

6. Apabila permintaan adalah untuk penjelasan kata/frasa, Gemini akan mengidentifikasi istilah tersebut dalam konteks dokumen yang diberikan dan menghasilkan penjelasan yang singkat, jelas, dan mudah dimengerti, termasuk kepanjangan singkatan atau definisi teknis jika relevan.

7. Setelah pemrosesan, Gemini mengembalikan hasil yang diminta (teks ringkasan atau teks penjelasan) kembali ke aplikasi.

8. Aplikasi pengguna menerima teks ringkasan atau penjelasan dari Gemini API dan menampilkannya di antarmuka pengguna. Untuk ringkasan, ini akan ditampilkan di komponen Card Ringkasan Dokumen. Untuk penjelasan istilah, ini akan muncul dalam bentuk *popup* atau *tooltip.*

Dalam pembangunan aplikasi ini bertanggung jawab untuk mengelola alur komunikasi dengan Gemini API untuk dua fungsi utama: peringkasan dokumen dan penjelasan kata/frasa.

1. Meringkas Dokumen

Aplikasi mengirimkan teks dokumen yang diekstrak ke Gemini untuk diringkas secara rinci. Berikut adalah table spesifikasi Spesifikasi *Request* pada Meringkas Dokumen dilihat pada Tabel 3.6:

Tabel 3.6 Spesifikasi *Request* pada Meringkas Dokumen

| Spesifikasi *Request* |  |
| ----- | :---- |
| **URL** | https://generativelanguage.googleapis.com/v1beta/models/gemini- 2.0-flash:generateContent?key=YOUR\_API\_KEY |
| **Method** | POST |
| **Format** | JSON |
|  **Parameter** | key: YOUR\_API\_KEY contents parts text |
|  **Contoh Request** | { "contents": \[ { "parts": \[ { "text": "Buat ringkasan yang \*\*sangat rinci, detail, dan terurut\*\* dari dokumen berikut. Gunakan format Markdown berikut untuk kerapian:\\n- Gunakan poin-poin (\`- \` atau \`\* \`) untuk setiap detail penting.\\n- Gunakan sub-poin jika ada hirarki (\` \- \`).\\n- Gunakan \*\*tebal\*\* untuk istilah atau konsep kunci.\\n- Pisahkan bagian-bagian utama dengan dua baris baru.\\n- Mulai ringkasan dengan judul ringkasan (misal: \\"Ringkasan Dokumen \[Judul Dokumen\]\\"):\\n---\\nDokumen:\\n\[Seluruh teks dokumen artikel jurnal yang telah diekstrak dan diterjemahkan\]" } \] } \] } |

Berikut adalah table spesifikasi Spesifikasi *Response* pada Meringkas Dokumen dapat dilihat pada Tabel 3.7:

Tabel 3.7 Spesifikasi *Response* pada Meringkas Dokumen

| Spesifikasi *Response* |  |
| ----- | :---- |
| **Format** | JSON |
|  **Contoh Response** | { "candidates": \[ { "content": { "parts": \[ { "text": "Ringkasan Dokumen Fenomena Globalisasi Pendidikan Tinggi\\n\\n- \*\*Latar Belakang Masalah\*\*: Fenomena globalisasi menuntut sektor pendidikan tinggi untuk beradaptasi dan berinovasi. Akses ke sumber informasi primer dan kredibel (artikel jurnal ilmiah internasional) esensial bagi mahasiswa untuk pembelajaran, penelitian, dan penulisan karya ilmiah.\\n	\- Survei menunjukkan \*\*79.4% responden sering membaca artikel jurnal internasional\*\*.\\n	\- Kemampuan memahami jurnal efektif penting untuk kesuksesan studi.\\n\\n..." } \] |

| Spesifikasi *Response* |  |
| ----- | :---- |
|  | }, "finishReason": "STOP", "safetyRatings": \[\] } \] } |

2. Mendapatkan Penjelasan Kata/Frasa

Aplikasi mengirimkan kata atau frasa yang diklik oleh pengguna, beserta konteks dokumen, untuk mendapatkan penjelasannya. Berikut adalah table spesifikasi Spesifikasi *Request* pada Mendapatkan Penjelasan Kata/Frasa dilihat pada Tabel 3.8:

Tabel 3.8 Spesifikasi *Request* pada Mendapatkan Penjelasan Kata/Frasa

| Spesifikasi *Request* |  |
| ----- | :---- |
| **URL** | https://generativelanguage.googleapis.com/v1beta/models/gemini- 2.0-flash:generateContent?key=YOUR\_API\_KEY |
| **Method** | POST |
| **Format** | JSON |
|  **Parameter** | contents parts text key: YOUR\_API\_KEY |
|  **Contoh Request** | { "contents": \[ { "parts": \[ { "text": "Jelaskan kata atau frasa \*\*\\"\[kata/frasa yang diketik\]\\"\*\* dalam konteks ringkasan dokumen berikut. Berikan penjelasan yang singkat, jelas, dan mudah dimengerti. Jika kata tersebut adalah singkatan atau istilah teknis, berikan kepanjangan atau definisi singkatnya.\\nKonteks Dokumen:\\n\[Bagian ringkasan dokumen tempat kata/frasa itu ditemukan atau seluruh ringkasan\]" } \] } \] } |

Berikut adalah table spesifikasi Spesifikasi *Response* pada Mendapatkan Penjelasan Kata/Frasa dapat dilihat pada Tabel 3.9:

Tabel 3.9 Spesifikasi *Response* pada Mendapatkan Penjelasan Kata/Frasa

| Spesifikasi *Response* |  |
| :---: | :---- |
| **Format** | JSON |
| **Contoh Response** | { "candidates": \[ |

| Spesifikasi *Response* |  |
| ----- | :---- |
|  | { "content": { "parts": \[ { "text": "Penjelasan untuk \\"Neural Machine Translation\\": Neural Machine Translation (NMT) adalah teknologi penerjemahan mesin yang menggunakan jaringan saraf tiruan (neural network) untuk menerjemahkan teks dari satu bahasa ke bahasa lain. Pendekatan ini memungkinkan sistem belajar dari data dalam jumlah sangat besar dan menangkap konteks linguistik secara lebih mendalam, berbeda dari teknologi statistik atau rule-based sebelumnya." } \] }, "finishReason": "STOP", "safetyRatings": \[\] } \] } |

Penerapan kemampuan Gemini AI dalam aplikasi ini membawa dampak yang signifikan terhadap cara mahasiswa memahami istilah teknis dan ilmiah pada artikel jurnal. Gemini AI digunakan untuk menganalisis teks terjemahan dan secara cerdas mengidentifikasi istilah-istilah khusus yang jarang digunakan dalam percakapan sehari-hari. Dengan kemampuan pemrosesan bahasa alami (NLP) Gemini AI yang canggih, aplikasi dapat memberikan penjelasan kontekstual atau definisi yang relevan untuk istilah-istilah tersebut secara langsung. Hal ini secara langsung mengurangi waktu dan usaha mahasiswa yang sebelumnya dihabiskan untuk mencari definisi secara manual melalui kamus atau internet secara terpisah, serta mempercepat pemahaman keseluruhan artikel. Namun, penjelasan otomatis dari AI sebaiknya digunakan sebagai panduan awal dan tetap diverifikasi dengan sumber-sumber akademik yang kredibel untuk memastikan akurasi dan kedalaman pemahaman.

4. # **Analisis iText**

Penggunaan iText dalam aplikasi ini secara signifikan mempermudah mahasiswa dalam memahami jurnal berbahasa asing dengan mengekstrak teks dari PDF, mengatasi hambatan salin-tempel manual, dan memungkinkan analisis AI pada konten tersebut. Ini berkontribusi pada peningkatan efisiensi literasi ilmiah dan penelitian bagi pengguna.

Manfaat utama integrasi iText di aplikasi ini terletak pada kemampuannya untuk mengurai berbagai jenis elemen dalam PDF, termasuk teks dan struktur dokumen, sehingga memungkinkan aplikasi untuk mengakses isi tekstual jurnal ilmiah. Ini menjadi krusial karena mayoritas artikel jurnal ilmiah seringkali tersedia dalam format PDF, yang secara inheren mempertahankan tata letak asli namun sulit diakses teksnya secara langsung tanpa alat khusus. Dengan iText, aplikasi dapat memperoleh teks dari PDF, yang kemudian menjadi input bagi modul peringkasan dan penjelasan istilah menggunakan Gemini AI.  
Berikut adalah *flowchart* yang menggambarkan tahapan-tahapan yang dilakukan iText di aplikasi untuk mengekstrak teks dari dokumen PDF yang dipilih oleh pengguna, dapat dilihat pada Gambar 3.5 berikut:

Gambar 3.5 Flowchart Alur Proses Ekstraksi Teks PDF Menggunakan iText

Berikut adalah penjelasan alur proses Ekstraksi Teks PDF Menggunakan iText:

1. Start

   Proses ekstraksi teks dimulai ketika aplikasi menerima perintah untuk memproses dokumen PDF.

2. Aplikasi Memilih Dokumen PDF

   Tahap ini merepresentasikan aksi pengguna di aplikasi Android yang telah memilih sebuah dokumen PDF dari penyimpanan perangkat melalui *file picker*. Aplikasi mendapatkan URI (Uniform Resource Identifier) dari file PDF tersebut.

3. Dokumen PDF Ada dan Dapat Diakses?

   Sistem melakukan validasi awal terhadap URI yang diterima. Ini memeriksa apakah file PDF benar-benar ada di lokasi yang ditunjukkan oleh URI dan apakah aplikasi memiliki izin untuk membuka *input stream* dari file tersebut.

   - Jika validasi gagal (misalnya, file tidak ada, rusak, atau tidak bisa diakses), alur mengarah ke "TIDAK".

   - Jika validasi berhasil, alur mengarah ke "YA".

4. Tampilkan Pesan Error: Gagal membuka file.

   Jika dokumen tidak dapat diakses atau dibuka, sistem menampilkan pesan kesalahan yang memberitahu pengguna bahwa proses gagal, dan alur proses berakhir.

5. Dapatkan InputStream dari URI Dokumen

   Setelah memastikan dokumen dapat diakses, aplikasi memperoleh InputStream dari URI dokumen PDF. InputStream ini adalah aliran data mentah dari file PDF yang akan dibaca oleh library iText.

6. Buat Objek PdfReader dari InputStream

   iText menerima InputStream dari dokumen PDF dan menggunakannya untuk membuat instance PdfReader. PdfReader ini berfungsi sebagai pembaca tingkat rendah yang menangani struktur internal file PDF.

7. Buat Objek PdfDocument dari PdfReader

   Dari PdfReader yang telah dibuat, iText kemudian membangun objek PdfDocument. PdfDocument ini adalah representasi tingkat tinggi dari seluruh dokumen PDF di dalam memori, yang memungkinkan akses ke properti dokumen seperti jumlah halaman dan setiap halaman individual.

8. Loop untuk Setiap Halaman PDF

   Proses ini memulai iterasi, mengunjungi setiap halaman dalam PdfDocument satu per satu. Ini diperlukan karena teks dalam PDF disimpan per halaman.

   - Untuk Setiap Halaman

     Selama loop, untuk setiap halaman yang belum diproses, alur berlanjut ke langkah berikutnya.

   - Semua Halaman Selesai

     Setelah semua halaman PDF telah diproses, loop berakhir, dan alur bergerak ke langkah selanjutnya untuk menutup sumber daya.

9. Dapatkan Halaman PDF

   Dalam setiap iterasi loop, halaman PDF tertentu (berdasarkan nomor halaman saat ini dalam loop) diambil dari objek PdfDocument.

10. Buat SimpleTextExtractionStrategy

    Sebuah instance SimpleTextExtractionStrategy dibuat. Ini adalah komponen dari iText yang memberitahu library bagaimana cara mengekstraksi teks dari konten halaman PDF. Strategi ini secara dasar akan mengambil semua teks yang ditemukan di halaman.

11. Ekstrak Teks dari Halaman Menggunakan PdfTextExtractor.getTextFromPage() Metode utama dari iText ini dipanggil untuk melakukan ekstraksi teks aktual. Ia menerima objek halaman PDF dan strategi ekstraksi teks, lalu mengembalikan semua teks yang ditemukan di halaman tersebut sebagai sebuah string.

12. Tambahkan Teks Halaman ke StringBuilder

    Teks yang diekstrak dari halaman saat ini ditambahkan ke objek StringBuilder. StringBuilder digunakan untuk mengumpulkan teks dari semua halaman secara efisien menjadi satu string besar.

13. Tutup PdfDocument

    Setelah semua halaman selesai diekstraksi teksnya, sumber daya PdfDocument ditutup. Ini penting untuk membebaskan memori dan sumber daya sistem yang dialokasikan untuk dokumen.

14. Tutup PdfReader

    Sumber daya PdfReader juga ditutup. Ini memastikan bahwa *file stream* yang dibuka untuk membaca PDF juga ditutup dengan benar, mencegah kebocoran sumber daya.

15. Kembalikan Teks Hasil Ekstraksi (String)

    Seluruh teks yang telah dikumpulkan dalam StringBuilder dari semua halaman PDF kini dikembalikan sebagai sebuah string tunggal. String ini merupakan representasi teks mentah dari isi dokumen PDF.

16. END

    Proses ekstraksi teks selesai.

    5. # **Analisis Firebase Database**

Kegunaan Firebase dalam aplikasi ini sangat vital, terutama dalam menjamin persistensi data dan skalabilitas. Dengan Firebase Cloud Storage, file PDF hasil terjemahan dapat disimpan secara *persistent*, memungkinkan pengguna mengakses dokumen mereka di berbagai sesi atau perangkat. Sementara itu, Firebase Firestore atau Realtime Database menyediakan penyimpanan untuk histori file yang diterjemahkan dan metadata terkait, memastikan data terstruktur tersedia secara *real-time*. Manfaat dari penggunaan

Firebase ini adalah percepatan proses pengembangan aplikasi, karena menghilangkan kebutuhan untuk mengatur dan memelihara *server backend* secara manual. Ini memungkinkan pengembang untuk fokus pada pembangunan fitur *client-side* yang inovatif, sekaligus memastikan data aplikasi dikelola dengan efisien, aman, dan dapat diskalakan sesuai kebutuhan pengguna. Berikut adalah *flowchart* yang menggambarkan tahapan-tahapan utama interaksi aplikasi dengan Firebase dalam sistem. Dapat dilihat pada Gambar 3.6 berikut:

![][image4]

Gambar 3.6 Flowchart Proses Penyimpanan Hasil Terjemahan Di Firebase Berikut adalah penjelasan alur proses Penggunaan Firebase:

1. Mulai

   Proses ini menandai titik awal ketika aplikasi mulai berinteraksi dengan layanan Firebase.

2. Deteksi

   Mendeteksi bahwa proses terjemahan dokumen telah berhasil diselesaikan dan hasil terjemahan siap untuk disimpan.

3. Siapkan File

   Mempersiapkan file hasil terjemahan yang ada di perangkat lokal agar siap untuk diunggah ke layanan penyimpanan Firebase.

4. Mulai Unggah File Ke Firebase

   Menginisiasi proses pengunggahan file terjemahan. Permintaan ini diarahkan ke layanan Firebase, yang merupakan tempat penyimpanan file dan media berbasis cloud. Ini merupakan langkah di mana file PDF terjemahan dikirim dari perangkat pengguna ke server Firebase.

5. Berhasil Unggah File?

   Disini titik keputusan krusial yang mengecek status operasi pengunggahan file ke Firebase. Jika proses pengunggahan file gagal, alur akan beralih ke langkah Tampilkan Pesan Gagal Unggah. Jika proses pengunggahan file berhasil, alur berlanjut ke langkah Catat Metadata.

6. Tampilkan Pesan Gagal Unggah

   Ketika pengunggahan dokumen ke Firebase gagal (misalnya karena masalah koneksi atau izin). Aplikasi kemudian akan menampilkan pesan yang mengindikasikan bahwa dokumen tidak berhasil disimpan di cloud.

7. Catat Metadata Ke Database

   Setelah file PDF berhasil terunggah untuk mencatat metadata terkait file terjemahan tersebut. Metadata ini mencakup informasi seperti nama file asli, URL unduhan di storage, status terjemahan, dan timestamp.

8. Berhasil Catat Metadata?

   Ini adalah titik keputusan yang mengecek status operasi penyimpanan metadata ke database Firebase. Jika proses pencatatan metadata gagal, alur akan beralih ke langkah Tampilkan Pesan Gagal Catat Metadata. Jika proses pencatatan metadata berhasil, alur berlanjut ke langkah Penyimpanan Berhasil.

9. Tampilkan Pesan Gagal Catat Metadata

   Ketika penyimpanan metadata di Firebase gagal mengelola status kegagalan ini. Aplikasi kemudian akan menampilkan pesan yang mengindikasikan bahwa metadata tidak berhasil disimpan.

10. Penyimpanan Berhasil

    Ini adalah akhir dari alur keberhasilan penyimpanan. Memperbarui status internal aplikasi untuk mengonfirmasi bahwa file terjemahan PDF dan semua metadata terkait telah berhasil disimpan secara lengkap di cloud Firebase.

11. Selesai

    Ini adalah titik akhir dari proses penyimpanan hasil terjemahan, yang dicapai baik setelah semua langkah berhasil terselesaikan, atau setelah salah satu skenario kegagalan ditampilkan kepada pengguna.

    6. # **Analisis Axios**

Kegunaan Axios dalam aplikasi ini adalah untuk menjadi HTTP client yang efisien pada backend Node.js untuk menangani semua komunikasi dengan DeepL API. Fungsi utamanya adalah mengirimkan permintaan POST untuk mengunggah dokumen terjemahan, melakukan *polling* status terjemahan, dan mengunduh hasil terjemahan PDF setelah selesai.

Manfaat utama integrasi Axios di aplikasi ini adalah memastikan efisiensi dan stabilitas sistem secara keseluruhan. Dengan menempatkan semua interaksi API eksternal yang kompleks di *backend*, kunci API DeepL dapat disimpan dengan aman di server dan tidak terekspos di kode sumber aplikasi Android. Pendekatan ini menyederhanakan alur komunikasi, sehingga memungkinkan aplikasi Android tetap ringan dan responsif. Axios juga memfasilitasi penanganan kesalahan yang terpusat; jika terjadi kegagalan dari DeepL API, *backend* dapat mengelolanya secara terstruktur sebelum mengirimkan pesan yang lebih informatif kembali ke pengguna . Pada akhirnya, tujuan utama dari penggunaan Axios adalah untuk mendukung fungsionalitas inti terjemahan dokumen dengan menyediakan koneksi yang andal dan terprogram ke layanan DeepL.  
Berikut adalah *flowchart* yang menggambarkan tahapan-tahapan yang dilakukan Axios di dalam *backend* aplikasi Anda untuk mengelola proses terjemahan dokumen dengan DeepL API. Dapat dilihat pada Gambar 3.7 berikut.

![][image5]

Gambar 3.7 Flowchart Alur Proses Axios Berikut merupakan alur proses penggunaan Axios:

1. Proses dimulai.

2. Axios yang mengeksekusi permintaan untuk mengunggah dokumen dan mengembalikan ID serta kunci dokumen.

3. Axios menerima ID dokumen dan memulai proses untuk memantau status terjemahan.

4. Axios yang menjalankan permintaan POST untuk memeriksa status dokumen.  
5. Ketika status done, Axios membuat permintaan untuk mengunduh dokumen.  
6. Axios	yang	mengeksekusi	permintaan	unduh	file	dan mengembalikannya.  
7. Proses yang melibatkan Axios selesai.

4. # **Analisis Kebutuhan Non Fungsional**

Analisis kebutuhan non fungsional adalah tahap yang bertujuan untuk mengidentifikasi elemen-elemen yang diperlukan agar sistem yang akan dibangun dapat berfungsi dengan baik, tanpa menjelaskan fungsi spesifik yang harus disediakan sistem. Kebutuhan non-fungsional berfokus pada kualitas sistem seperti kinerja, keamanan, keandalan, skalabilitas, dan kemudahan penggunaan. Bagian ini penting untuk memastikan aplikasi memenuhi standar kualitas yang diharapkan dan dapat beroperasi secara optimal dalam berbagai kondisi. Dalam konteks aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android, analisis kebutuhan non fungsional mencakup aspek analisis pengguna, perangkat keras, dan perangkat lunak yang krusial untuk pengalaman pengguna dan operasional sistem secara keseluruhan. Spesifikasi terkait kebutuhan non- fungsional ini dapat dilihat pada Tabel 3.10:

Tabel 3.10 Spesifikasi Kebutuhan Non Fungsional

| Kode SKPL | Spesifikasi Kebutuhan Non Fungsional |
| :---: | :---- |
| SKPL-NF-001 | Sistem harus dirancang sebagai aplikasi Android yang memberikan pengalaman pengguna yang optimal. |
| SKPL-NF-002 | Sistem harus berjalan dengan aman, memastikan data pengguna dan API Key dilindungi secara terenkripsi dan tidak disalahgunakan. |
| SKPL-NF-003 | Sistem harus memiliki kinerja yang responsif, dengan waktu pemrosesan terjemahan DeepL dan ringkasan Gemini yang minimal. |
| SKPL-NF-004 | Sistem harus mampu menangani format dokumen teks PDF untuk diunggah dan diproses. |
| SKPL-NF-005 | Sistem harus menyediakan antarmuka pengguna (UI) yang intuitif, mudah dipahami, dan *responsive* di berbagai ukuran layar perangkat Android. |
| SKPL-NF-006 | Sistem harus dapat menyimpan hasil terjemahan dalam format PDF secara lokal pada perangkat pengguna dan mengelola riwayat terjemahan. |
| SKPL-NF-007 | Sistem membutuhkan koneksi internet yang stabil untuk berinteraksi dengan DeepL API dan Gemini API. |
| SKPL-NF-008 | Sistem harus dapat diakses oleh pengguna dengan beragam tingkat literasi digital, menyediakan pesan *feedback* yang jelas. |
| SKPL-NF-009 | Sistem harus memastikan bahwa *library* dan dependensi yang digunakan kompatibel dan tidak menimbulkan konflik dalam lingkungan pengembangan Android. |
| SKPL-NF-010 | Aplikasi harus memiliki tingkat ketersediaan (uptime) yang |

| Kode SKPL | Spesifikasi Kebutuhan Non Fungsional |
| ----- | :---- |
|  | tinggi dan mekanisme penanganan kesalahan yang baik untuk permintaan API. |
| SKPL-NF-011 | Sistem harus dapat menangani proses ekstraksi teks dari dokumen yang diunggah, dengan mempertimbangkan ukuran file dan kinerja. |
| SKPL-NF-012 | Sistem harus menyediakan fungsionalitas penjelasan kata/frasa yang akurat dan relevan dari Gemini AI, dengan waktu respons yang cepat. |

1. # **Analisis Kebutuhan Perangkat Pikir**

Analisis perangkat pikir bertujuan untuk mengidentifikasi pengguna yang akan terlibat dalam penggunaan aplikasi yang dibangun serta memastikan aplikasi tersebut dapat beroperasi dengan baik sesuai dengan kemampuan pengguna. Pada tahap ini, dilakukan peninjauan terhadap keterampilan dan pengalaman pengguna dalam menggunakan perangkat yang dibutuhkan oleh aplikasi. Analisis ini memberikan dasar yang penting untuk memastikan bahwa solusi yang diterapkan akan membantu pekerjaan setiap pengguna dengan cara yang efisien dan efektif. Dalam konteks aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android, pengguna utama adalah mahasiswa. Analisis ini akan berfokus pada profil, tanggung jawab, dan keterampilan yang mereka miliki terkait penggunaan aplikasi mobile dan literasi digital.  
Berikut adalah analisis perangkat pikir pengguna yang terlibat dalam sistem yang dibangun, dapat dilihat pada Tabel 3.11:  
Tabel 3.11 Spesifikasi Kebutuhan Perangkat Pikir Pengguna

|  Stakeholder |  Tanggung Jawab | Tingkat Keterampilan | Keterampilan Menggunakan Perangkat |
| ----- | ----- | ----- | ----- |
|  Mahasiswa | Mengakses aplikasi penerjemah multibahasa pada perangkat *smartphone* Android, memilih dokumen jurnal (PDF), melakukan terjemahan, mendapatkan ringkasan dokumen, berinteraksi dengan fitur | Mampu mengoperasikan *smartphone* Android, menggunakan aplikasi mobile, menavigasi antarmuka digital, | Umumnya menggunakan *smartphone* untuk keperluan akademik (mencari jurnal, mengakses materi daring), komunikasi (WhatsApp), dan |

|  | penjelasan istilah/frasa, dan mengelola histori file terjemahan. | dan memahami konsep dasar internet serta *file management* di perangkat. | belajar mandiri. Terbiasa mengunduh dan membuka berbagai format file di perangkat mobile mereka. |
| :---- | :---: | :---: | :---: |

Selanjutnya, analisis spesifikasi kebutuhan perangkat pikir pengguna terhadap sistem aplikasi yang akan dibangun dapat dilihat pada Tabel 3.12:

Tabel 3.12 Spesifikasi Kebutuhan Perangkat Pikir Pengguna Terhadap Sistem

|  Stakeholder |  Tanggung Jawab | Keterampilan Yang Dibutuhkan | Jenis Pelatihan Yang Akan Dibreikan |
| ----- | ----- | ----- | :---: |
|  Mahasiswa |  Menggunakan aplikasi untuk menerjemahkan artikel jurnal, mendapatkan ringkasan dan penjelasan istilah/frasa, serta mengakses fitur histori. | Mampu mengoperasikan antarmuka aplikasi Android yang intuitif, memahami ikon dan navigasi *material design*, serta mampu memahami *feedback* visual (misalnya, indikator loading, pesan error). Kemampuan dasar dalam literasi digital untuk mencari dan mengelola file. | Pelatihan singkat mengenai alur penggunaan aplikasi, terutama fitur-fitur baru seperti pemilih dokumen, proses terjemahan dan peringkasan, serta interaksi dengan fitur penjelasan istilah/frasa (*tooltip*). Tidak memerlukan pelatihan teknis mendalam. |

Berdasarkan hasil analisis terhadap spesifikasi kebutuhan perangkat pikir, dapat disimpulkan bahwa mahasiswa sebagai pengguna utama memiliki tingkat literasi digital dan kemampuan dasar penggunaan *smartphone* yang memadai untuk mengoperasikan aplikasi ini. Fitur-fitur aplikasi dirancang agar intuitif dan

*user-friendly* sesuai dengan pengalaman pengguna *mobile* pada umumnya. Pelatihan yang diperlukan bersifat minimal dan berfokus pada alur penggunaan fitur spesifik aplikasi (penerjemahan, peringkasan, penjelasan istilah), sehingga dapat mempermudah mahasiswa dalam memanfaatkan sistem secara efisien dan efektif.

2. # **Analisis Kebutuhan Perangkat Lunak**

Analisis kebutuhan perangkat lunak merupakan bagian penting dalam perencanaan dan pengembangan aplikasi. Proses analisis ini mencakup perangkat lunak yang diperlukan untuk pembangunan dan pemeliharaan sistem di masa depan. Ketiadaan pemahaman yang mendalam terhadap kebutuhan perangkat lunak dapat berujung pada produk yang tidak relevan dan sulit digunakan. Oleh karena itu, analisis kebutuhan perangkat lunak yang komprehensif sangat penting untuk keberhasilan dan keberlanjutan sistem perangkat lunak, karena dapat memastikan bahwa sistem yang dibangun berfungsi dengan baik dan sesuai dengan alur sistem yang akan diterapkan. Dalam hal ini, kebutuhan perangkat lunak untuk aplikasi penerjemah multibahasa berbasis Android meliputi sistem operasi dan berbagai *library* serta *framework* yang diperlukan untuk mendukung kelancaran operasional.

Berikut adalah spesifikasi minimum yang tersedia untuk kebutuhan perangkat lunak yang bertujuan untuk memastikan perangkat lunak yang sedang dipakai untuk kelancaran proses analisis kebutuhan perangkat lunak dapat dilihat pada Tabel 3.13:

Tabel 3.13 Spesifikasi Minimum Kebutuhan Perangkat Lunak

| Komponen | Spesifikasi Minimum |
| :---: | :---: |
| Sistem Operasi | Android 9 (Pie) atau lebih |
| Android Studio | Versi terbaru yang mendukung AGP 8.6.0 dan Kotlin 2.0.21 |
| Kotlin | Versi 2.0.21 |
| Gradle | Versi 8.x atau yang kompatibel |
| Java Development Kit (JDK) | Versi 17 atau lebih |

Adapun spesifikasi yang direkomendasikan untuk kebutuhan perangkat lunak yang bertujuan untuk memastikan kinerja optimal dan kelancaran proses analisis kebutuhan perangkat lunak dapat dilihat pada Tabel 3.14:  
Tabel 3.14 Spesifikasi Rekomendasi Kebutuhan Perangkat Lunak

| Komponen | Spesifikasi Rekomendasi |
| :---: | :---: |
| Sistem Operasi | Android 12 (Snow Cone) atau lebih |
| Android Studio | Versi terbaru stabil |
| Kotlin | Versi terbaru stabil (2.0.21 atau yang lebih baru) |
| Gradle | Versi terbaru stabil |
| Java Development Kit (JDK) | Versi 17 atau lebih |

Kesimpulannya adalah seluruh kebutuhan sistem yang akan dibangun dapat dipenuhi oleh analisis kebutuhan perangkat lunak yang tersedia untuk *smartphone* dan komputer. Meskipun *smartphone* Android yang digunakan mungkin masih menggunakan Android 10, hal tersebut tetap mendukung teknologi inti yang dibutuhkan dan bisa digunakan tanpa perlu peningkatan signifikan pada perangkat lunak saat ini. Oleh karena itu, pembangunan sistem dapat dilaksanakan tanpa perlu adanya peningkatan yang berarti pada perangkat lunak yang digunakan saat ini.

3. # **Analisis Kebutuhan Perangkat Keras**

Analisis kebutuhan perangkat keras adalah tahap analisis yang bertujuan untuk menentukan spesifikasi perangkat keras yang diperlukan untuk mendukung proses implementasi dan operasional sistem. Perangkat keras yang memadai menjadi fondasi penting dalam menjamin kestabilan sistem, terutama untuk aplikasi penerjemah multibahasa berbasis Android yang mengandalkan konektivitas internet, pemrosesan dokumen, dan interaksi dengan layanan AI. Untuk memastikan bahwa spesifikasi ini memenuhi kebutuhan sistem, detail spesifikasi akan dijelaskan lebih lanjut.

Berikut adalah spesifikasi minimum yang tersedia untuk kebutuhan perangkat keras yang bertujuan untuk memastikan perangkat keras yang sedang

dipakai untuk kelancaran proses analisis kebutuhan perangkat keras dapat dilihat pada Tabel 3.15:  
Tabel 3.15 Spesifikasi Minimum Perangkat Keras

| Nama Perangkat Keras | Komponen | Spesifikasi |
| :---- | :---: | :---: |
|  Smartphone | OS (Operating System) | Android 9 atau lebih |
|  | RAM (Random Access Memory) | 4 GB (Gigabyte) |
|  | Storage | 64 GB (Gigabyte) |
|  | Konektivitas | 4G LTE, Wi-Fi |
|  Komputer/Laptop (untuk pengembangan) | OS (Operating System) | Windows 10 atau lebih |
|  | CPU (Central Processing Unit) | Intel Core i3 Generasi ke-7 atau setara |
|  | RAM (Random Access Memory) | 8 GB (Gigabyte) |
|  | Storage | 256 GB SSD (Solid State Drive) |
|  | Konektivitas | Kabel LAN atau Wi-Fi |

Adapun spesifikasi yang direkomendasikan untuk kebutuhan perangkat keras mempertimbangkan keseimbangan antara performa, efisiensi daya, dan daya tahan dalam penggunaan sehari-hari. Serta mendukung fitur-fitur canggih seperti pemrosesan AI dan tampilan PDF dengan akurat dan efisien dapat dilihat pada Tabel 3.16:  
Tabel 3.16 Spesifikasi Rekomendasi Kebutuhan Perangkat Keras

| Nama Perangkat Keras | Komponen | Spesifikasi |
| :---- | :---: | :---: |
|  Smartphone | OS (Operating System) | Android 12 atau lebih |
|  | RAM (Random Access Memory) | 6 GB (Gigabyte) atau lebih |
|  | Storage | 128 GB (Gigabyte) atau lebih |
|  | Konektivitas | 5G, Wi-Fi Dual Band |
| Komputer/Laptop (untuk pengembangan) | OS (Operating System) | Windows 10/11 atau macOS terbaru |
|  | CPU (Central Processing | Intel Core i5 Generasi ke- |

|  | Unit) | 10 atau AMD Ryzen 5 generasi setara atau lebih |
| :---- | :---: | ----- |
|  | RAM (Random Access Memory) | 16 GB (Gigabyte) atau lebih |
|  | Storage | 512 GB SSD (Solid State Drive) atau lebih |
|  | Konektivitas | Gigabit Ethernet \+ Wi-Fi 6 |

Kesimpulannya adalah perangkat keras pada *smartphone* dan komputer saat ini umumnya cukup untuk menjalankan sistem aplikasi penerjemah multibahasa dengan baik. Pemrosesan, memori, dan penyimpanan yang tersedia, serta fitur pendukung dan konektivitas internet, telah mencukupi untuk mengoperasikan teknologi yang digunakan seperti terjemahan DeepL, peringkasan Gemini, dan tampilan dokumen PDF. Kondisi ini juga memberikan landasan yang kuat untuk pengembangan dan implementasi teknologi yang lebih kompleks di masa depan. Dengan spesifikasi saat ini, diharapkan sistem berjalan dengan lancar dan tanpa kendala.

5. # **Analisis Kebutuhan Fungsional**

Analisis kebutuhan fungsional bertujuan untuk mengidentifikasi dan mendokumentasikan fungsi-fungsi yang harus ada dalam sistem yang akan dibangun. Kebutuhan fungsional menjelaskan bagaimana sistem bekerja dan fitur apa saja yang harus disediakan untuk memenuhi kebutuhan pengguna, dalam hal ini mahasiswa yang akan menggunakan aplikasi penerjemah multibahasa untuk artikel jurnal berbasis *Android*. Setiap fitur yang disediakan akan mendukung proses literasi ilmiah dan penelitian dengan memanfaatkan teknologi penerjemahan dan kecerdasan buatan. Berikut adalah spesifikasi kebutuhan fungsional untuk aplikasi penerjemah multibahasa yang akan dibangun, yang dapat dilihat pada Tabel 3.17.  
Tabel 3.17 Spesifikasi Kebutuhan Fungsional

| Kode SKPL | Spesifikasi Kebutuhan Fungsional |
| :---: | :---- |
| SKPL-F-001 | Sistem  menyediakan  fitur  untuk  *login*  ke  dalam  aplikasi menggunakan akun terdaftar. |
| SKPL-F-002 | Sistem menyediakan fitur untuk *logout* dari akun pengguna. |
| SKPL-F-003 | Sistem menyediakan fitur untuk mengunggah artikel jurnal |

|  | (PDF) dari penyimpanan perangkat. |
| ----- | :---- |
| SKPL-F-004 | Sistem menyediakan fitur untuk menerjemahkan artikel jurnal ke Bahasa Indonesia menggunakan *DeepL*. |
| SKPL-F-005 | Sistem menyediakan fitur untuk menyimpan hasil terjemahan artikel jurnal ke *Firebase*. |
| SKPL-F-006 | Sistem  menyediakan  fitur  untuk	membagikan  PDF  hasil terjemahan ke aplikasi lain. |
| SKPL-F-007 | Sistem	menyediakan	fitur	untuk	mengunduh	PDF	hasil terjemahan. |
| SKPL-F-008 | Sistem	menyediakan	fitur	untuk	membuka	PDF	hasil terjemahan. |
| SKPL-F-009 | Sistem menyediakan fitur untuk melihat riwayat terjemahan artikel jurnal yang telah disimpan. |
| SKPL-F-010 | Sistem menyediakan fitur untuk memilih riwayat terjemahan untuk melihat kembali artikel jurnal yang sudah diterjemahkan. |
| SKPL-F-011 | Sistem menyediakan fitur untuk menghapus riwayat terjemahan artikel jurnal. |
| SKPL-F-012 | Sistem  menyediakan  fitur  untuk  meringkas  artikel  jurnal menggunakan Gemini AI. |
| SKPL-F-013 | Sistem menyediakan fitur untuk menampilkan ringkasan artikel jurnal yang dihasilkan. |
| SKPL-F-014 | Sistem menyediakan fitur untuk menjelaskan definisi kata/frasa dari teks artikel jurnal menggunakan Gemini AI. |
| SKPL-F-015 | Sistem menyediakan fitur untuk mengetik kata/frasa secara manual untuk mendapatkan penjelasan. |
| SKPL-F-016 | Sistem menyediakan fitur untuk menampilkan hasil terjemahan artikel jurnal dalam antarmuka aplikasi. |
| SKPL-F-017 | Sistem menyediakan fitur untuk menampilkan artikel jurnal asli dalam antarmuka aplikasi. |
| SKPL-F-018 | Sistem menyediakan fitur untuk pindah halaman artikel jurnal saat melihat pratinjau artikel jurnal. |
| SKPL-F-019 | Sistem	menyediakan	fitur	untuk	menampilkan	definisi kata/frasa yang dihasilkan oleh Gemini AI. |
| SKPL-F-020 | Sistem menyediakan fitur untuk memulai terjemahan baru artikel jurnal. |

1. # **Use Case Diagram**

*Use Case Diagram* adalah tahapan yang digunakan untuk menggambarkan interaksi antara aktor (pengguna atau sistem eksternal) dengan sistem yang dikembangkan. Diagram ini berfungsi untuk memetakan peran pengguna dan bagaimana mereka berinteraksi dengan fitur-fitur yang tersedia dalam sistem. Tujuannya adalah untuk mengidentifikasi aktor yang berwenang untuk mengakses fitur-fitur pada sistem yang akan dibangun. Diagram ini memberikan gambaran

umum tentang apa yang dilakukan sistem, bukan bagaimana sistem melakukannya.  
Pada penelitian ini, *use case diagram* mencakup interaksi dalam aplikasi penerjemah multibahasa berbasis *Android*, yang memiliki skenario penggunaan seperti pemilihan artikel jurnal, penerjemahan, peringkasan, penjelasan kata/frasa, dan pengelolaan riwayat terjemahan dapat dilihat pada Gambar 3.8 berikut.

Gambar 3.8 Use Case Diagram

1. # **Definisi Aktor Pada Use Case**

Definisi aktor merupakan penjelasan mengenai peran setiap aktor dalam *use case diagram*. Penjabaran definisi aktor yang digunakan dalam sistem ini dapat dilihat pada Tabel 3.18:

Tabel 3.18 Definisi Aktor Pada Use Case

| No | Aktor | Deskripsi |
| ----- | ----- | ----- |
|  1 |  Pengguna | Aktor dengan *role* ini memiliki wewenang untuk melakukan: Register dan login akun . Mengelola dokumen (mengunggah, membagikan, mengunduh, menghapus, melihat riwayat, memilih riwayat, memulai terjemahan baru) . Memahami isi artikel jurnal (melihat ringkasan, melihat kata/frasa, mengetik kata/frasa, melihat isi artikel jurnal asli/terjemahan, pindah halaman) . Mengelola akun (logout, ganti akun) |
|  2 |  DeepL API | Aktor dengan *role* ini memiliki wewenang untuk menyediakan layanan penerjemahan artikel jurnal berbasis *neural network*. Berinteraksi dengan aplikasi (melalui *backend server*) untuk menerima artikel jurnal sumber dan mengembalikan artikel jurnal terjemahan dalam format PDF yang mempertahankan tata letak asli. |
|  3 |  Gemini API | Aktor dengan *role* ini memiliki wewenang untuk menyediakan layanan kecerdasan buatan multimodal. Berinteraksi dengan sistem (melalui *backend server*) untuk menerima teks atau *prompt* dan mengembalikan ringkasan dokumen atau penjelasan kata/frasa yang relevan. |
| 4 | Firebase | Aktor dengan *role* ini memiliki wewenang untuk melakukan penyimpanan data dan juga memberikan data. |
| 5 | Google SSO | Aktor dengan *role* ini memiliki wewenang untuk melakukan autentikasi dan validasi akun google saat login aplikasi. |

2. # **Definisi Use Case**

Proses menjelaskan setiap use case yang terdapat dalam use case diagram disebut sebagai definisi use case. Berikut adalah definisi use case yang ada pada use case diagram dapat dilihat pada Tabel 3.19.

Tabel 3.19 Definisi Use Case

| No | Use Case | Deskripsi |
| ----- | :---- | ----- |
|  1 |  Login | Sistem melakukan proses autentikasi pengguna. Sistem menerima kredensial (email dan password) dari pengguna, memverifikasinya melalui Firebase, dan jika valid, mengarahkan pengguna ke halaman utama aplikasi. |
|  2 |  Logout | Sistem melakukan proses keluar dari sesi pengguna saat ini. Sistem menghapus sesi login pengguna dari Firebase dan mengarahkan pengguna kembali ke halaman login. |
|  3 |  Mengunggah Artikel Jurnal | Sistem memungkinkan pengguna untuk memilih file artikel jurnal (PDF) dari penyimpanan lokal perangkat Android. Sistem kemudian akan mendapatkan URI dari file yang dipilih untuk diproses lebih lanjut. |
|  4 |  Menerjemahkan Artikel Jurnal | Sistem melakukan pengiriman artikel jurnal (PDF) yang telah dipilih oleh pengguna ke *backend server*. *Backend server* kemudian akan meneruskan artikel jurnal tersebut ke DeepL API untuk proses terjemahan ke Bahasa Indonesia. |
|  5 |  Menyimpan Hasil Terjemahan | Sistem melakukan penyimpanan otomatis artikel jurnal hasil terjemahan. Sistem mengunggah file PDF hasil terjemahan ke Firebase dan menyimpan metadata terkait (nama file asli, nama file terjemahan, URL di *storage*, hash artikel jurnal asli, status terjemahan, timestamp) ke Firebase sebagai riwayat terjemahan. |
|  6 | Membagikan PDF Hasil Terjemahan | Sistem melakukan pembagian file PDF hasil terjemahan. Sistem mendapatkan URI, kemudian pengguna memilih aplikasi lain (misalnya, email, aplikasi pesan) untuk berbagi file. |
|  7 | Mengunduh PDF Hasil Terjemahan | Sistem melakukan pengunduhan salinan file PDF hasil terjemahan. Sistem menyalin file terjemahan dari direktori internal aplikasi ke direktori download publik pada perangkat pengguna. |
|  8 | Membuka PDF Hasil Terjemahan | Sistem melakukan pembukaan file PDF hasil terjemahan. Sistem mendapatkan URI yang akan mencari dan membuka file tersebut menggunakan aplikasi PDF *viewer* eksternal yang terinstal di perangkat. |
| 9 | Melihat | Sistem menampilkan daftar semua artikel jurnal yang telah |

|  | Riwayat Terjemahan | diterjemahkan sebelumnya. Pengguna dapat mengakses daftar ini melalui *sidebar* untuk meninjau histori terjemahan mereka. |
| ----- | :---- | :---- |
|  10 | Memilih Riwayat Terjemahan | Sistem melakukan pemuatan ulang artikel jurnal dari riwayat. Pengguna dapat memilih item artikel jurnal dari daftar histori di *sidebar*, dan sistem akan memuat kembali artikel jurnal tersebut serta ringkasannya ke antarmuka utama. |
|  11 |  Menghapus Riwayat Terjemahan | Sistem melakukan penghapusan riwayat terjemahan. Pengguna dapat memilih untuk menghapus item riwayat terjemahan tertentu dari daftar, yang akan memicu penghapusan file terjemahan terkait dari Firebase dan metadata dari Firebase, serta mencabut izin URI. |
|  12 |  Meringkas Artikel Jurnal | Sistem melakukan proses peringkasan artikel jurnal. Sistem mengekstrak teks dari artikel jurnal yang dipilih, kemudian mengirimkan teks tersebut ke *backend server* untuk diteruskan ke Gemini AI guna menghasilkan ringkasan detail. |
|  13 |  Menampilkan Ringkasan | Sistem menampilkan hasil ringkasan artikel jurnal yang dihasilkan oleh Gemini AI. Ringkasan ini muncul di antarmuka utama  aplikasi  dalam  sebuah  *card*  yang  dapat  diperluas (*expandable*) atau dilipat (*collapsible*) untuk melihat ringkasan. |
|  14 | Menjelaskan Definisi Kata/Frasa | Sistem melakukan permintaan penjelasan kata/frasa. Pengguna dapat mengetik kata/frasa secara manual, yang kemudian akan dikirimkan ke *backend server* untuk diteruskan ke Gemini AI guna mendapatkan penjelasan kontekstual. |
|  15 |  Mengetik Kata/Frasa | Sistem memungkinkan pengguna untuk memasukkan kata atau frasa secara manual. Pengguna dapat mengetikkan kata atau frasa di *input field* yang tersedia dalam dialog penjelasan untuk mendapatkan definisi dari Gemini AI. |
|  16 | Menampilkan Hasil Terjemahan | Sistem menampilkan pratinjau artikel jurnal hasil terjemahan (PDF) di area tampilan artikel jurnal pada antarmuka utama aplikasi. |
|  17 | Menampilkan Artikel Jurnal Asli | Sistem menampilkan pratinjau artikel jurnal asli (PDF) di area tampilan artikel jurnal pada antarmuka utama aplikasi, sebagai alternatif tampilan dari artikel jurnal terjemahan. |
| 18 | Pindah | Sistem	melakukan	navigasi	halaman	pada	artikel	jurnal. |

|  | Halaman Artikel Jurnal | Pengguna dapat berpindah antar halaman dalam artikel jurnal PDF yang sedang ditampilkan di area pratinjau (baik artikel jurnal asli maupun terjemahan) melalui tombol navigasi. |
| ----- | :---- | :---- |
|  19 | Menampilkan Definisi Kata/Frasa | Sistem	menampilkan	hasil	penjelasan	definisi	kata/frasa. Penjelasan yang diterima dari Gemini AI akan disajikan dalam bentuk *popup* yang informatif kepada pengguna. |
|  20 | Memulai Terjemahan Baru | Sistem melakukan inisiasi proses terjemahan artikel jurnal baru. Pengguna dapat memilih opsi ini untuk mengunggah artikel jurnal baru dan memulai siklus terjemahan dan peringkasan dari awal. |

3. # **Skenario Use Case**

Skenario *use case* digunakan untuk menggambarkan bagaimana aktor dan sistem berinteraksi guna mencapai tujuan tertentu. Skenario ini memuat langkah- langkah spesifik yang dilakukan pengguna saat menggunakan sistem, serta respons yang diberikan sistem terhadap setiap tindakan tersebut. Berikut adalah skenario use case yang telah dirancang sesuai dengan kebutuhan sistem yang akan dibangun:

1. Skenario Use Case Pada Login

   Skenario *use case* pada Login akan menjelaskan bagaimana pengguna melakukan autentikasi untuk masuk ke dalam aplikasi, dapat dilihat pada Tabel 3.20.

   Tabel 3.20 Skenario Use Case Pada Login

| Nama Use Case | Login |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-001 |  |
| ***Goal in Context*** | Pengguna dapat mengakses aplikasi setelah berhasil autentikasi. |  |
| ***Precondition*** | Pengguna telah terdaftar dan berada di halaman login. |  |
| ***Successful End Condition*** | Pengguna berhasil masuk ke halaman utama aplikasi. |  |
| ***Failed End Condition*** | Pengguna gagal login karena kredensial salah atau masalah lainnya. |  |
| ***Actors*** | Pengguna, Firebase |  |
| ***Trigger*** | Pengguna menekan tombol login dengan google dan menekan login. |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna membuka aplikasi |
|  | 2 | Pengguna menekan tombol masuk dengan google. |
|  | 3 | Sistem meluncurkan google sign-in. |
|  | 4 | Pengguna memilih akun Google. |

| Nama Use Case | Login |  |
| ----- | :---: | ----- |
|  | 5 | Sistem menerima ID Token. |
|  | 6 | Sistem mengirimkan ID Token ke Firebase |
|  | 7 | Firebase memvalidasi dan mengautentikasi pengguna. |
|  | 8 | Login Berhasil |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 5.1 | Gagal mendapatkan ID Token |
|  | 7.1 | Gagal mengautentikasi di Firebase |

2. Skenario Use Case Pada Logout

   Skenario *use case* pada Logout menjelaskan bagaimana pengguna keluar dari sesi aplikasi, dapat dilihat pada Tabel 3.21.

   Tabel 3.21 Skenario Use Case Pada Logout

| Nama Use Case | Logout |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-002 |  |
| ***Goal in Context*** | Pengguna berhasil keluar dari sesi akun. |  |
| ***Precondition*** | Pengguna sedang login ke dalam aplikasi. |  |
| ***Successful End Condition*** | Pengguna keluar dari akun dan diarahkan ke halaman login. |  |
| ***Failed End Condition*** | Proses logout gagal. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna memilih opsi "Logout" dari *sidebar* dan mengkonfirmasi. |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon menu |
|  | 2 | Pengguna memilih opsi logout/ganti akun |
|  | 3 | Sistem menampilkan dialog konfirmasi. |
|  | 4 | Pengguna menekan tombol keluar |
|  | 5 | Sistem melakukan logout |
|  | 6 | Sistem membersihkan data sesi lokal |
|  | 7 | Logout Berhasil |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 4.1 | Gagal keluar pengguna menekan batal |
|  | 5.1 | Gagal melakukan logout |

   3. Skenario Use Case Pada Mengunggah Artikel Jurnal

      Skenario *use case* pada Mengunggah Artikel Jurnal menjelaskan bagaimana pengguna dapat memilih file artikel jurnal dari perangkat untuk diproses dalam aplikasi, dapat dilihat pada Tabel 3.22.

      Tabel 3.22 Skenario Use Case Pada Mengunggah Artikel Jurnal

| Nama Use Case | Mengunggah Artikel Jurnal |
| :---: | :---- |
| ***Related Requerment*** | SKPL-F-003 |
| ***Goal in Context*** | Pengguna berhasil memilih artikel jurnal dari perangkat untuk diterjemahkan dan diringkas. |
| ***Precondition*** | Pengguna berada di halaman utama aplikasi. |
| ***Successful End Condition*** | Artikel jurnal berhasil dipilih, URI-nya dimuat di |

| Nama Use Case | Mengunggah Artikel Jurnal |  |
| ----- | ----- | ----- |
|  | aplikasi, dan proses terjemahan/peringkasan dimulai. |  |
| ***Failed End Condition*** | Pemilihan artikel jurnal dibatalkan atau terjadi kesalahan saat memuat artikel jurnal. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol mengunggah |  |
| ***Include Cases*** | Menerjemahkan Artikel Jurnal, Meringkas Artikel Jurnal |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol mengunggah. |
|  | 2 | Sistem meluncurkan pemilihan file Android. |
|  | 3 | Pengguna memilih file artikel jurnal (PDF). |
|  | 4 | Sistem menerima URI file. |
|  | 5 | Sistem memuat URI dan menampilkan nama file. |
|  | 6 | Sistem otomatis memicu terjemahan dan peringkasan. |
|  | 7 | Berhasil mengunggah artikel jurnal |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal pengguna membatalkan pemilihan. |

4. Skenario Use Case Pada Menerjemahkan Artikel Jurnal

   Skenario *use case* pada Menerjemahkan Artikel Jurnal menjelaskan bagaimana sistem mengirimkan artikel jurnal yang dipilih ke DeepL API untuk diterjemahkan ke Bahasa Indonesia, dapat dilihat pada Tabel 3.23.

   Tabel 3.23 Skenario Use Case Pada Menerjemahkan Artikel Jurnal

| Nama Use Case | Menerjemahkan Artikel Jurnal |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-004 |  |
| ***Goal in Context*** | Pengguna mendapatkan artikel jurnal PDF yang telah diterjemahkan. |  |
| ***Precondition*** | Artikel jurnal (PDF) sudah dipilih, pengguna sudah login, dan koneksi internet tersedia. |  |
| ***Successful End Condition*** | Artikel jurnal berhasil diterjemahkan |  |
| ***Failed End Condition*** | Proses terjemahan gagal. |  |
| ***Actors*** | Pengguna, DeepL, Firebase |  |
| ***Trigger*** | Pengguna memilih artikel jurnal baru atau memilih artikel jurnal lama yang belum diterjemahkan dari histori. |  |
| ***Include Cases*** | Menyimpan Hasil Terjemahan |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Sistem mendeteksi artikel jurnal |
|  | 2 | Sistem menampilkan *loading* terjemahan. |
|  | 3 | Sistem menghitung hash artikel jurnal |
|  | 4 | Sistem memeriksa duplikat terjemahan di *cloud*. |
|  | 5 | Sistem memuat info terjemahan yang sudah ada |
|  | 6 | Sistem mengirimkan artikel jurnal ke *backend server* untuk DeepL |
|  | 7 | Sistem menerima dan meneruskan ke DeepL |

| Nama Use Case | Menerjemahkan Artikel Jurnal |  |
| ----- | ----- | ----- |
|  |  | API. |
|  | 8 | Sistem memantau status terjemahan hingga selesai. |
|  | 9 | Sistem mengunggah dokumen terjemahan ke Firebase |
|  | 10 | Sistem mengembalikan URL unduhan ke aplikasi. |
|  | 11 | Sistem mengunduh file terjemahan PDF lokal |
|  | 12 | Sistem memperbarui informasi artikel jurnal |
|  | 13 | Artikel jurnal berhasil diterjemahkan & disimpan di cloud |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 4.1 | Gagal terhubung saat cek duplikasi. |
|  | 5.1 | Gagal artikel jurnal ini sudah pernah diterjemahkan |
|  | 6.1 | Gagal format tidak didukung DeepL. |
|  | 11.1 | Gagal mengunduh file terjemahan. |

5. Skenario Use Case Pada Menyimpan Hasil Terjemahan

   Skenario *use case* pada Menyimpan Hasil Terjemahan menjelaskan bagaimana aplikasi berinteraksi dengan Firebase untuk menyimpan artikel jurnal hasil terjemahan dan metadata lainnya, dapat dilihat pada Tabel 3.24.

   Tabel 3.24 Skenario Use Case Pada Menyimpan Hasil Terjemahan

| Nama Use Case | Menyimpan Hasil Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-005 |  |
| ***Goal in Context*** | Hasil terjemahan PDF tersimpan secara *persistent* untuk akses di masa mendatang. |  |
| ***Precondition*** | Artikel jurnal PDF telah berhasil diterjemahkan dan disimpan secara lokal. Koneksi internet tersedia. |  |
| ***Successful End Condition*** | File terjemahan berhasil disimpan di Firebase. |  |
| ***Failed End Condition*** | Proses penyimpanan gagal. |  |
| ***Actors*** | Firebase |  |
| ***Trigger*** | Artikel jurnal berhasil diterjemahkan |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Sistem mendeteksi terjemahan selesai. |
|  | 2 | Sistem menyiapkan file terjemahan untuk upload. |
|  | 3 | Sistem memulai *upload* ke Firebase |
|  | 4 | Sistem menerima dan menyimpan file. |
|  | 5 | Sistem menyimpan metadata artikel jurnal ke Firebase |
|  | 6 | Sistem mencatat metadata. |
|  | 7 | File terjemahan berhasil disimpan ke *cloud* |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal mengunggah file ke Firebase |
|  | 5.1 | Gagal menyimpan metadata |

6. Skenario Use Case Pada Membagikan PDF Hasil Terjemahan

   Skenario *use case* pada Membagikan PDF Hasil Terjemahan menjelaskan bagaimana pengguna dapat membagikan file artikel jurnal PDF hasil terjemahan ke aplikasi lain, dapat dilihat pada Tabel 3.25.

   Tabel 3.25 Skenario Use Case Pada Membagikan PDF Hasil Terjemahan

| Nama Use Case | Membagikan PDF Hasil Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-006 |  |
| ***Goal in Context*** | Pengguna dapat berbagi artikel jurnal terjemahan dengan aplikasi lain atau kontak. |  |
| ***Precondition*** | Artikel jurnal terjemahan telah tersimpan. |  |
| ***Successful End Condition*** | Berhasil membagikan PDF hasil terjemahan |  |
| ***Failed End Condition*** | Gagal berbagi atau file tidak tersedia. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol bagikan |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol bagikan |
|  | 2 | Sistem memeriksa ketersediaan file terjemahan. |
|  | 3 | Sistem mendapatkan URI file terjemahan |
|  | 4 | Sistem membuat *Intent* berbagi file PDF |
|  | 5 | Sistem menampilkan dialog pilihan berbagi |
|  | 6 | Pengguna memilih aplikasi tujuan |
|  | 7 | Sistem Android meluncurkan aplikasi berbagi |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 2.1 | Gagal file terjemahan tidak tersedia |
|  | 6.1 | Gagal dialog berbagi tidak muncul |

   7. Skenario Use Case Pada Mengunduh PDF Hasil Terjemahan

      Skenario *use case* pada Mengunduh PDF Hasil Terjemahan menjelaskan bagaimana pengguna dapat mengunduh file artikel jurnal PDF hasil terjemahan ke penyimpanan perangkat, dapat dilihat pada Tabel 3.26.

      Tabel 3.26 Skenario Use Case Pada Mengunduh PDF Hasil Terjemahan

| Nama Use Case | Mengunduh PDF Hasil Terjemahan |
| :---: | :---- |
| ***Related Requerment*** | SKPL-F-007 |
| ***Goal in Context*** | Pengguna memiliki salinan artikel jurnal terjemahan di direktori download perangkat. |
| ***Precondition*** | Artikel jurnal terjemahan telah tersedia. |
| ***Successful End Condition*** | File terjemahan berhasil diunduh |
| ***Failed End Condition*** | Gagal proses pengunduhan |
| ***Actors*** | Pengguna |
| ***Trigger*** | Pengguna menekan tombol download |
| ***Include Cases*** | \- |

| Nama Use Case | Mengunduh PDF Hasil Terjemahan |  |
| ----- | ----- | ----- |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol download |
|  | 2 | Sistem mendapatkan referensi file terjemahan |
|  | 3 | Sistem mendapatkan direktori download |
|  | 4 | Sistem memastikan direktori download ada |
|  | 5 | Sistem mengunduh file terjemahan |
|  | 6 | File berhasil didownload |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 2.1 | Gagal file terjemahan tidak ditersedia |
|  | 5.1 | Gagal mengunduh file |

8. Skenario Use Case Pada Membuka PDF Hasil Terjemahan

   Skenario *use case* pada Membuka PDF Hasil Terjemahan menjelaskan bagaimana pengguna dapat membuka file artikel jurnal PDF hasil terjemahan yang tersedia, menggunakan aplikasi PDF *viewer* eksternal, dapat dilihat pada Tabel 3.27.

   Tabel 3.27 Skenario Use Case Pada Membuka PDF Hasil Terjemahan

| Nama Use Case | Membuka PDF Hasil Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-008 |  |
| ***Goal in Context*** | Pengguna dapat melihat artikel jurnal terjemahan di aplikasi pihak ketiga. |  |
| ***Precondition*** | Artikel jurnal terjemahan telah tersedia |  |
| ***Successful End Condition*** | Artikel jurnal terjemahan berhasil dibuka di aplikasi PDF *viewer* eksternal. |  |
| ***Failed End Condition*** | Artikel jurnal gagal dibuka |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol buka pdf |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol buka pdf |
|  | 2 | Sistem memeriksa ketersediaan file terjemahan |
|  | 3 | Sistem mendapatkan URI file terjemahan |
|  | 4 | Sistem membuat *Intent* membuka file PDF |
|  | 5 | Sistem mencoba meluncurkan *Intent* |
|  | 6 | Pengguna memilih aplikasi pdf viewer |
|  | 7 | Sistem mendeteksi aplikasi PDF *viewer* |
|  | 8 | PDF hasil terjemahan berhasil ditampilkan |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 2.1 | Gagal file terjemahan tidak tersedia |
|  | 5.1 | Gagal tidak ada aplikasi yang dapat menangani *Intent* |

   9. Skenario Use Case Pada Melihat Riwayat Terjemahan

      Skenario *use case* pada Melihat Riwayat Terjemahan menjelaskan bagaimana pengguna dapat mengakses *sidebar* untuk melihat daftar semua artikel jurnal yang telah diterjemahkan sebelumnya, dapat dilihat pada Tabel 3.28.

Tabel 3.28 Skenario Use Case Pada Melihat Riwayat Terjemahan

| Nama Use Case | Melihat Riwayat Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-009 |  |
| ***Goal in Context*** | Pengguna dapat meninjau dan mengakses artikel jurnal terjemahan yang pernah dibuat. |  |
| ***Precondition*** | Ada artikel jurnal yang pernah diterjemahkan yang tersimpan di Firebase. |  |
| ***Successful End Condition*** | *Sidebar* menampilkan daftar histori file terjemahan yang dimuat dari Firebase. |  |
| ***Failed End Condition*** | *Sidebar* kosong atau gagal memuat histori. |  |
| ***Actors*** | Pengguna, Firebase |  |
| ***Trigger*** | Pengguna menekan ikon menu |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon menu |
|  | 2 | Sistem membuka *sidebar* |
|  | 3 | Sistem meminta riwayat dari Firebase |
|  | 4 | Sistem mengembalikan daftar riwayat terjemahan. |
|  | 5 | Sistem menampilkan daftar file terjemahan di *sidebar*. |
|  | 6 | Berhasil menampilkan setiap file terjemahan |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 4.1 | Gagal memuat riwayat dari Firebase |

10. Skenario Use Case Pada Memilih Riwayat Terjemahan

    Skenario *use case* pada Memilih Riwayat Terjemahan menjelaskan bagaimana pengguna memilih artikel jurnal dari daftar histori di *sidebar*, dan sistem memuat ulang artikel jurnal serta ringkasannya di antarmuka utama, dapat dilihat pada Tabel 3.29.

    Tabel 3.29 Skenario Use Case Pada Memilih Riwayat Terjemahan

| Nama Use Case | Memilih Riwayat Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-010 |  |
| ***Goal in Context*** | Pengguna dapat dengan cepat beralih ke artikel jurnal terjemahan yang pernah diproses. |  |
| ***Precondition*** | *Sidebar* terbuka dan menampilkan daftar histori file. |  |
| ***Successful End Condition*** | Artikel jurnal yang dipilih dari histori dimuat di antarmuka utama dan ringkasannya ditampilkan. |  |
| ***Failed End Condition*** | Artikel jurnal dari histori gagal dimuat atau diringkas. |  |
| ***Actors*** | Pengguna, Firebase |  |
| ***Trigger*** | Pengguna mengklik salah satu item file di daftar histori *sidebar*. |  |
| ***Include Cases*** | Meringkas Artikel Jurnal |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon menu |
|  | 2 | Sistem membuka *sidebar* |
|  | 3 | Sistem meminta riwayat dari Firebase |
|  | 4 | Sistem mengembalikan daftar riwayat terjemahan. |
|  | 5 | Sistem menampilkan daftar file terjemahan di |

| Nama Use Case | Memilih Riwayat Terjemahan |  |
| ----- | ----- | ----- |
|  |  | *sidebar*. |
|  | 6 | Pengguna mengklik nama file di daftar histori |
|  | 7 | Sistem mendeteksi item histori |
|  | 8 | Berhasil mengatur info artikel jurnal & status tampilan |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal memuat riwayat dari Firebase |
|  | 7.1 | Gagal mendeteksi item histori |

11. Skenario Use Case Pada Menghapus Riwayat Terjemahan

    Skenario *use case* pada Menghapus Riwayat Terjemahan menjelaskan bagaimana pengguna dapat menghapus riwayat terjemahan artikel jurnal tertentu dari daftar, termasuk menghapus file terkait dari Firebase, dapat dilihat pada Tabel 3.30.

    Tabel 3.30 Skenario Use Case Pada Menghapus Riwayat Terjemahan

| Nama Use Case | Menghapus Riwayat Terjemahan |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-011 |  |
| ***Goal in Context*** | Riwayat terjemahan artikel jurnal yang tidak diinginkan berhasil dihapus dari sistem dan *cloud*. |  |
| ***Precondition*** | Riwayat terjemahan tersedia di *sidebar* dan koneksi internet tersedia. |  |
| ***Successful End Condition*** | Riwayat dan file terkait berhasil dihapus, dan daftar histori diperbarui. |  |
| ***Failed End Condition*** | Proses penghapusan gagal. |  |
| ***Actors*** | Pengguna, Firebase |  |
| ***Trigger*** | Pengguna menekan ikon hapus pada sidebar |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon hapus pada sidebar |
|  | 2 | Sistem menampilkan dialog konfirmasi |
|  | 3 | Pengguna menekan tombol hapus |
|  | 4 | Sistem memanggil fungsi penghapusan |
|  | 5 | Sistem mengirim permintaan ke *backend server* |
|  | 6 | Sistem menghapus file & metadata dari Firebase |
|  | 7 | Sistem mengembalikan status keberhasilan |
|  | 8 | Sistem mencabut izin URI artikel jurnal asli |
|  | 9 | Sistem membersihkan info artikel jurnal aktif dan memperbarui riwayat. |
|  | 10 | Riwayat terjemahan berhasil dihapus |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal pengguna menekan batal |
|  | 6.1 | Gagal menghapus file dari Firebase |

    12. Skenario Use Case Pada Meringkas Artikel Jurnal

        Skenario *use case* pada Meringkas Artikel Jurnal menjelaskan bagaimana sistem secara otomatis mengambil teks dari artikel jurnal

yang dipilih dan mengirimkannya ke Gemini AI untuk proses peringkasan, dapat dilihat pada Tabel 3.31.  
Tabel 3.31 Skenario Use Case Pada Meringkas Artikel Jurnal

| Nama Use Case | Meringkas Artikel Jurnal |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-012 |  |
| ***Goal in Context*** | Pengguna mendapatkan ringkasan dari artikel yang dipilih. |  |
| ***Precondition*** | Artikel jurnal telah dipilih (PDF) |  |
| ***Successful End Condition*** | Ringkasan artikel jurnal berhasil dihasilkan dan ditampilkan. |  |
| ***Failed End Condition*** | Proses peringkasan gagal |  |
| ***Actors*** | Gemini |  |
| ***Trigger*** | Sistem mendeteksi artikel jurnal yang dipilih oleh pengguna atau dari riwayat terjemahan |  |
| ***Include Cases*** | Menampilkan Ringkasan |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Sistem mendeteksi artikel jurnal baru/dari riwayat terjemahan. |
|  | 2 | Sistem menampilkan *loading* ringkasan. |
|  | 3 | Sistem mengekstrak teks dari artikel jurnal. |
|  | 4 | Sistem membuat *prompt* untuk Gemini AI. |
|  | 5 | Sistem mengirim *prompt* ke *backend server* untuk Gemini AI. |
|  | 6 | Gemini AI mengembalikan teks ringkasan. |
|  | 7 | Sistem menerima teks ringkasan. |
|  | 8 | Sistem memperbarui status ringkasan ke sukses. |
|  | 9 | Aplikasi menampilkan ringkasan. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal mengekstrak teks. |
|  | 6.1 | Gagal Gemini AI mengembalikan error. |
|  | 8.1 | Gagal memperbarui status ringkasan |

13. Skenario Use Case Pada Menampilkan Ringkasan

    Skenario *use case* pada Menampilkan Ringkasan menjelaskan bagaimana sistem menampilkan ringkasan artikel jurnal yang dihasilkan, dengan opsi untuk membuka dan menutup tampilan detailnya, dapat dilihat pada Tabel 3.32.

    Tabel 3.32 Skenario Use Case Pada Menampilkan Ringkasan

| Nama Use Case | Menampilkan Ringkasan |
| :---: | :---- |
| ***Related Requerment*** | SKPL-F-013 |
| ***Goal in Context*** | Pengguna dapat mengakses ringkasan artikel jurnal secara penuh atau ringkas sesuai kebutuhan. |
| ***Precondition*** | Ringkasan artikel jurnal sudah berhasil dihasilkan |
| ***Successful End Condition*** | Berhasil menampilkan ringkasan |
| ***Failed End Condition*** | \- |
| ***Actors*** | Pengguna |
| ***Trigger*** | Pengguna mengklik pada area ringkasan |
| ***Include Cases*** | \- |

| Nama Use Case | Menampilkan Ringkasan |  |
| ----- | ----- | ----- |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna mengklik area ringkasan |
|  | 2 | Sistem mengubah status tampilan ringkasan. |
|  | 3 | Sistem menampilkan seluruh teks. |
|  | 4 | Ringkasan berhasil ditampilkan. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 1 | \- |

14. Skenario Use Case Pada Menjelaskan Definisi Kata/Frasa

    Skenario *use case* pada Menjelaskan Definisi Kata/Frasa menjelaskan bagaimana sistem mengirimkan kata atau frasa yang diketik oleh pengguna ke Gemini AI untuk mendapatkan penjelasannya, dapat dilihat pada Tabel 3.33.

    Tabel 3.33 Skenario Use Case Pada Menjelaskan Definisi Kata/Frasa

| Nama Use Case | Menjelaskan Definisi Kata/Frasa |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-014 |  |
| ***Goal in Context*** | Pengguna mendapatkan definisi atau penjelasan singkat untuk kata atau frasa yang tidak dikenal dalam ringkasan artikel jurnal. |  |
| ***Precondition*** | Artikel jurnal sudah ditampilkan |  |
| ***Successful End Condition*** | *Popup* berisi penjelasan untuk kata/frasa muncul |  |
| ***Failed End Condition*** | *Popup* muncul dengan pesan *error* atau tidak ada penjelasan yang didapatkan. |  |
| ***Actors*** | Pengguna, Gemini |  |
| ***Trigger*** | Pengguna menekan tombol jelaskan kata dan mengetik input. |  |
| ***Include Cases*** | Mengetik Kata/Frasa, Menampilkan Definisi Kata/Frasa |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon jelaskan kata |
|  | 2 | Sistem mendeteksi kata/frasa |
|  | 3 | Sistem mencoba mengidentifikasi kata/frasa |
|  | 4 | Sistem menampilkan *loading* di *popup* |
|  | 5 | Sistem mengirim *prompt* penjelasan ke *backend server* untuk Gemini AI |
|  | 6 | Gemini AI mengembalikan teks penjelasan |
|  | 7 | Sistem menerima penjelasan |
|  | 8 | Sistem memperbarui status penjelasan ke sukses. |
|  | 9 | Sistem menampilkan *popup* dengan penjelasan. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 2.1 | Gagal kata/frasa tidak boleh kosong |
|  | 6.1 | Gagal Gemini AI mengembalikan error |
|  | 8.1 | Gagal memperbarui status penjelasan |

15. Skenario Use Case Pada Mengetik Kata/Frasa

    Skenario *use case* pada Mengetik Kata/Frasa menjelaskan bagaimana pengguna dapat memasukkan kata atau frasa secara manual untuk mendapatkan penjelasan dari Gemini AI, dapat dilihat pada Tabel 3.34.

    Tabel 3.34 Skenario Use Case Pada Mengetik Kata/Frasa

| Nama Use Case | Mengetik Kata/Frasa |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-015 |  |
| ***Goal in Context*** | Pengguna mendapatkan definisi atau penjelasan singkat untuk kata atau frasa yang dimasukkan secara manual. |  |
| ***Precondition*** | Pengguna berada di jelaskan kata |  |
| ***Successful End Condition*** | *Popup* menampilkan penjelasan untuk kata/frasa yang diketik. |  |
| ***Failed End Condition*** | *Popup* menampilkan pesan *error* atau tidak ada penjelasan yang didapatkan. |  |
| ***Actors*** | Pengguna, Gemini |  |
| ***Trigger*** | Pengguna mengetikkan kata/frasa dan menekan tombol "Jelaskan". |  |
| ***Include Cases*** | Menampilkan Definisi Kata/Frasa |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon jelaskan kata |
|  | 2 | Sistem menampilkan dialog penjelasan dengan *input field*. |
|  | 3 | Pengguna mengetikkan kata atau frasa. |
|  | 4 | Pengguna menekan tombol jelaskan |
|  | 5 | Sistem menampilkan *loading* di dialog. |
|  | 6 | Sistem mengirim *prompt* ke *backend server* untuk Gemini AI. |
|  | 7 | Gemini AI mengembalikan teks penjelasan. |
|  | 8 | Sistem menerima penjelasan. |
|  | 9 | Sistem memperbarui status penjelasan ke sukses. |
|  | 10 | Sistem menampilkan teks penjelasan |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 5.1 | Gagal Kata/frasa tidak boleh kosong |
|  | 7.1 | Gagal Gemini AI mengembalikan error. |

    16. Skenario Use Case Pada Menampilkan Hasil Terjemahan

        Skenario *use case* pada Menampilkan Hasil Terjemahan menjelaskan bagaimana sistem menampilkan artikel jurnal hasil terjemahan (PDF) di area pratinjau dalam antarmuka aplikasi, dapat dilihat pada Tabel 3.35.

        Tabel 3.35 Skenario Use Case Pada Menampilkan Hasil Terjemahan

| Nama Use Case | Menampilkan Hasil Terjemahan |
| :---: | :---- |
| ***Related Requerment*** | SKPL-F-016 |
| ***Goal in Context*** | Pengguna dapat melihat pratinjau visual artikel jurnal hasil terjemahan di dalam aplikasi. |

| Nama Use Case | Menampilkan Hasil Terjemahan |  |
| ----- | ----- | ----- |
| ***Precondition*** | Artikel jurnal telah berhasil diterjemahkan |  |
| ***Successful End Condition*** | Artikel jurnal terjemahan berhasil dimuat |  |
| ***Failed End Condition*** | Artikel junral terjemahan gagal dimuat atau ditampilkan. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Artikel jurnal berhasil diterjemahkan |  |
| ***Include Cases*** | Pindah Halaman Artikel Jurnal |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Sistem mendeteksi file terjemahan |
|  | 2 | Sistem menampilkan area pratinjau PDF. |
|  | 3 | Sistem memuat dokumen terjemahan. |
|  | 4 | Sistem menerapkan konfigurasi tampilan. |
|  | 5 | Sistem memberi tahu total halaman. |
|  | 6 | Sistem memperbarui jumlah total dan halaman saat ini. |
|  | 7 | Sistem menampilkan kontrol navigasi halaman. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 5.1 | Gagal tidak dapat menampilkan dokumen |

17. Skenario Use Case Pada Menampilkan Artikel Jurnal Asli

    Skenario *use case* pada Menampilkan Artikel Asli menjelaskan bagaimana sistem menampilkan artikel jurnal asli (PDF) di area pratinjau dalam antarmuka aplikasi, sebagai alternatif tampilan dari artikel jurnal terjemahan, dapat dilihat pada Tabel 3.36.

    Tabel 3.36 Skenario Use Case Pada Menampilkan Artikel Jurnal Asli

| Nama Use Case | Menampilkan Artikel Jurnal Asli |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-017 |  |
| ***Goal in Context*** | Pengguna dapat melihat pratinjau visual artikel jurnal asli di dalam aplikasi. |  |
| ***Precondition*** | Artikel jurnal asli tersedia |  |
| ***Successful End Condition*** | Artikel jurnal asli berhasil dimuat |  |
| ***Failed End Condition*** | Artikel jurnal asli gagal dimuat atau ditampilkan. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan ikon Tukar pdf asli/terjemahan dan memilih mode asli |  |
| ***Include Cases*** | Pindah Halaman Artikel Jurnal |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan ikon tukar pdf asli/terjemahan |
|  | 2 | Sistem mengubah mode tampilan menjadi artikel jurnal asli. |
|  | 3 | Sistem menampilkan artikel jurnal asli |
|  | 4 | Sistem membuat file temporer dari artikel jurnal asli. |
|  | 5 | Sistem menampilkan area pratinjau PDF. |
|  | 6 | Sistem memuat artikel jurnal asli. |
|  | 7 | Sistem menerapkan konfigurasi tampilan. |
|  | 8 | Sistem memberi tahu total halaman. |
|  | 9 | Sistem memperbarui jumlah total dan halaman |

| Nama Use Case | Menampilkan Artikel Jurnal Asli |  |
| ----- | ----- | ----- |
|  |  | saat ini. |
|  | 10 | Sistem menampilkan kontrol navigasi halaman. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 4.1 | Gagal membuat file temporer |
|  | 6.1 | Gagal memuat artikel jurnal di pratinjau PDF. |

18. Skenario Use Case Pada Pindah Halaman Artikel Jurnal

    Skenario *use case* pada Pindah Halaman Artikel Jurnal menjelaskan bagaimana pengguna dapat menavigasi antar halaman dalam artikel jurnal PDF yang ditampilkan di area pratinjau, dapat dilihat pada Tabel 3.37.

    Tabel 3.37 Skenario Use Case Pada Pindah Halaman Artikel Jurnal

| Nama Use Case | Pindah Halaman Artikel Jurnal |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-018 |  |
| ***Goal in Context*** | Pengguna dapat melihat berbagai halaman dari artikel junral PDF yang sedang aktif. |  |
| ***Precondition*** | Artikel jurnal PDF (asli atau terjemahan) sedang ditampilkan |  |
| ***Successful End Condition*** | Tampilan halaman beralih ke halaman yang diminta. |  |
| ***Failed End Condition*** | Navigasi halaman gagal. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol navigasi halaman pada pratinjau PDF |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol navigasi. |
|  | 2 | Sistem memperbarui halaman saat ini. |
|  | 3 | Sistem beralih ke halaman yang diminta. |
|  | 4 | Sistem memperbarui indikator halaman |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal melakukan perubahan halaman. |

    19. Skenario Use Case Pada Menampilkan Definisi Kata/Frasa

        Skenario *use case* pada Menampilkan Definisi Kata/Frasa menjelaskan bagaimana sistem menampilkan hasil penjelasan definisi kata/frasa dari Gemini AI dalam bentuk *popup* kepada pengguna, dapat dilihat pada Tabel 3.38.

        Tabel 3.38 Skenario Use Case Pada Menampilkan Definisi Kata/Frasa

| Nama Use Case | Menampilkan Definisi Kata/Frasa |
| :---: | :---- |
| ***Related Requerment*** | SKPL-F-019 |
| ***Goal in Context*** | Pengguna dapat melihat dan membaca penjelasan untuk kata/frasa yang diminta. |
| ***Precondition*** | Penjelasan kata/frasa sudah berhasil didapatkan dari Gemini AI |

| Nama Use Case | Menampilkan Definisi Kata/Frasa |  |
| ----- | ----- | ----- |
| ***Successful End Condition*** | Menampilkan teks penjelasan. |  |
| ***Failed End Condition*** | \- |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna mengetik kata/frasa |  |
| ***Include Cases*** | \- |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Sistem berhasil menerima penjelasan dari Gemini AI |
|  | 2 | Sistem mendeteksi hasil penjelasan sukses. |
|  | 3 | Sistem menampilkan *popup* berisi penjelasan. |
|  | 4 | Pengguna membaca penjelasan. |
|  | 5 | Pengguna menekan tutup atau mengklik di luar *popup*. |
|  | 6 | Sistem menyembunyikan *popup* dan mereset status. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 1 | \- |

20. Skenario Use Case Pada Memulai Terjemahan Baru

    Skenario *use case* pada Memulai Terjemahan Baru menjelaskan bagaimana pengguna memulai proses pemilihan artikel jurnal untuk terjemahan, biasanya setelah menyelesaikan sesi terjemahan sebelumnya atau saat aplikasi pertama kali dibuka, dapat dilihat pada Tabel 3.39.

    Tabel 3.39 Skenario Use Case Pada Memulai Terjemahan Baru

| Nama Use Case | Memulai Terjemahan Baru |  |
| ----- | ----- | ----- |
| ***Related Requerment*** | SKPL-F-020 |  |
| ***Goal in Context*** | Pengguna dapat memulai proses terjemahan untuk artikel jurnal baru. |  |
| ***Precondition*** | Pengguna berada di sidebar. |  |
| ***Successful End Condition*** | Pemilih file artikel jurnal diluncurkan. |  |
| ***Failed End Condition*** | Pemilih file gagal diluncurkan. |  |
| ***Actors*** | Pengguna |  |
| ***Trigger*** | Pengguna menekan tombol mulai terjemahan baru |  |
| ***Include Cases*** | Mengunggah Artikel Jurnal |  |
| ***Main Flow*** | ***Step*** | ***Action*** |
|  | 1 | Pengguna menekan tombol mulai terjemahan baru |
|  | 2 | Sistem meluncurkan pemilih file Android. |
|  | 3 | Pengguna melanjutkan ke proses Mengunggah Artikel Jurnal. |
| ***Extension*** | ***Step*** | ***Brach Action*** |
|  | 3.1 | Gagal membuka pemilihan artikel jurnal |

    2. # **Activity Diagram**

*Activity diagram* merupakan diagram yang menggambarkan alur aktivitas atau proses dalam suatu sistem, termasuk bagaimana aktivitas dimulai, keputusan

(*decision*) yang mungkin terjadi, dan bagaimana proses tersebut berakhir. Diagram ini bertujuan untuk menjelaskan secara visual urutan langkah-langkah atau aktivitas yang terjadi dalam sistem, sehingga memudahkan pemahaman alur kerja yang sedang atau akan dibangun. Bagi pengguna, diagram ini membantu memahami interaksi yang diperlukan untuk menyelesaikan suatu tugas dalam sistem. Berikut adalah *activity diagram* yang sudah dirancang sesuai kebutuhan sistem aplikasi penerjemah multibahasa.

1. Activity Diagram Pada Login

   Alur proses untuk login pada aplikasi aplikasi dapat dilihat pada Gambar 3.9 di bawah ini.

   Gambar 3.9 Activity Diagram Pada Login

2. Activity Diagram Pada Logout

   Alur proses untuk logout pada aplikasi aplikasi dapat dilihat pada Gambar 3.10 di bawah ini.

   Gambar 3.10 Activity Diagram Pada Logout

3. Activity Diagram Pada Mengunggah Artikel Jurnal

   Alur proses untuk mengunggah artikel jurnal aplikasi dapat dilihat pada Gambar 3.11 di bawah ini.

   Gambar 3.11 Activity Diagram Pada Mengunggah Artikel Jurnal

4. Activity Diagram Pada Menerjemahkan Artikel Jurnal

   Alur proses untuk menerjemahkan artikel jurnal pada aplikasi dapat dilihat pada Gambar 3.12 di bawah ini:

   Gambar 3.12 Activity Diagram Pada Menerjemahkan Artikel Jurnal

5. Activity Diagram Pada Menyimpan Hasil Terjemahan

   Alur proses untuk menyimpan hasil terjemahan pada aplikasi dapat dilihat pada Gambar 3.13 di bawah ini:

   Gambar 3.13 Activity Diagram Pada Menyimpan Hasil Terjemahan

6. Activity Diagram Pada Membagikan PDF Hasil Terjemahan

   Alur proses untuk membagikan pdf hasil terjemahan pada aplikasi dapat dilihat pada Gambar 3.14 di bawah ini:

   Gambar 3.14 Activity Diagram Pada Membagikan PDF Hasil Terjemahan

7. Activity Diagram Pada Mengunduh PDF Hasil Terjemahan

   Alur proses untuk mengunduh pdf hasil terjemahan pada aplikasi dapat dilihat pada Gambar 3.15 di bawah ini:

   Gambar 3.15 Activity Diagram Pada Mengunduh PDF Hasil Terjemahan

8. Activity Diagram Pada Membuka PDF Hasil Terjemahan

   Alur proses untuk membuka pdf hasil terjemahan pada aplikasi dapat dilihat pada Gambar 3.16 di bawah ini:

   Gambar 3.16 Activity Diagram Pada Membuka PDF Hasil Terjemahan

9. Activity Diagram Pada Melihat Riwayat Terjemahan

   Alur proses untuk melihat riwayat terjemahan pada aplikasi dapat dilihat pada Gambar 3.17 di bawah ini:

   Gambar 3.17 Activity Diagram Pada Melihat Riwayat Terjemahan

10. Activity Diagram Pada Memilih Riwayat Terjemahan

    Alur proses untuk memilih riwayat terjemahan pada aplikasi dapat dilihat pada Gambar 3.18 di bawah ini:

    Gambar 3.18 Activity Diagram Pada Memilih Riwayat Terjemahan

11. Activity Diagram Pada Menghapus Riwayat Terjemahan

    Alur proses untuk menghapus riwayat terjemahan pada aplikasi dapat dilihat pada Gambar 3.19 di bawah ini:

    Gambar 3.19 Activity Diagram Pada Menghapus Riwayat Terjemahan

12. Activity Diagram Pada Meringkas Artikel Jurnal

    Alur proses untuk meringkas artikel jurnal pada aplikasi dapat dilihat pada Gambar 3.20 di bawah ini:

    Gambar 3.20 Activity Diagram Pada Meringkas Artikel Jurnal

13. Activity Diagram Pada Menampilkan Ringkasan

    Alur proses untuk menampilkan ringkasan pada aplikasi dapat dilihat pada Gambar 3.21 di bawah ini:

    Gambar 3.21 Activity Diagram Pada Menampilkan Ringkasan

14. Activity Diagram Pada Menjelaskan Definisi Kata/Frasa

    Alur proses untuk menjelaskan definisi kata/frasa pada aplikasi dapat dilihat pada Gambar 3.22 di bawah ini:

    Gambar 3.22 Activity Diagram Pada Menjelaskan Definisi Kata/Frasa

15. Activity Diagram Pada Mengetik Kata/Frasa

    Alur proses untuk mengetik kata/frasa pada aplikasi dapat dilihat pada Gambar 3.23 di bawah ini:

    Gambar 3.23 Activity Diagram Pada Mengetik Kata/Frasa

16. Activity Diagram Pada Menampilkan Hasil Terjemahan

    Alur proses untuk menampilkan hasil terjemahan pada aplikasi dapat dilihat pada Gambar 3.24 di bawah ini:

    Gambar 3.24 Activity Diagram Pada Menampilkan Hasil Terjemahan

17. Activity Diagram Pada Menampilkan Artikel Jurnal Asli

    Alur proses untuk menampilkan artikel jurnal asli pada aplikasi dapat dilihat pada Gambar 3.25 di bawah ini:

    Gambar 3.25 Activity Diagram Pada Menampilkan Artikel Jurnal Asli

18. Activity Diagram Pada Pindah Halaman Artikel Jurnal

    Alur proses untuk pindah halaman artikel jurnal pada aplikasi dapat dilihat pada Gambar 3.26 di bawah ini:

    Gambar 3.26 Activity Diagram Pada Pindah Halaman Artikel Jurnal

19. Activity Diagram Pada Menampilkan Definisi Kata/Frasa

    Alur proses untuk menampilkan definisi kata/frasa pada aplikasi dapat dilihat pada Gambar 3.27 di bawah ini:

    Gambar 3.27 Activity Diagram Pada Menampilkan Definisi Kata/Frasa

20. Activity Diagram Pada Memulai Terjemahan Baru

    Alur proses untuk memulai terjemahan baru pada aplikasi dapat dilihat pada Gambar 3.28 di bawah ini:

    Gambar 3.28 Activity Diagram Pada Memulai Terjemahan Baru

    3. # **Class Diagram**

*Class diagram* adalah representasi statis dari struktur sistem yang memodelkan kelas-kelas (*tipe data*) beserta atribut, operasi (*metode*), dan hubungan antar kelas. Diagram ini menyediakan panduan yang jelas bagi tim pengembang untuk membangun sistem yang konsisten dengan desain awal.

Dalam konteks aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android, *class diagram* memvisualisasikan bagaimana berbagai komponen aplikasi (UI, ViewModel, Service, Util, dan Data Model) diorganisir dan berinteraksi. Diagram ini juga menunjukkan data yang mereka kelola dan operasi yang mereka lakukan.

1. # **Struktur Class Diagram**

Struktur *class diagram* merupakan representasi visual dari hubungan antar kelas dalam suatu sistem, yang ditampilkan secara sederhana dengan hanya

mencantumkan nama-nama kelas tanpa detail atribut atau *method*. Tujuannya adalah untuk memberikan gambaran umum mengenai bagaimana kelas-kelas saling terhubung dan berinteraksi satu sama lain. Struktur *Class Diagram* untuk aplikasi yang dibangun dapat dilihat pada Gambar 3.29 berikut:

Gambar 3.29 Class Diagram

2. # **Rancangan Class Diagram**

Rancangan *class diagram* merupakan representasi detail dari struktur internal sistem yang menggambarkan setiap kelas secara lengkap, termasuk atribut, *method* (fungsi), serta relasi antar kelas. Rancangan ini menyediakan panduan yang jelas bagi tim pengembang untuk membangun sistem yang konsisten dengan desain awal.

1. Class MainActivity

   *Class Diagram* untuk MainActivity dapat dilihat pada Gambar 3.30.

   Gambar 3.30 Class DiagramMainActivity

2. Class MainScreenViewModel

   *Class Diagram* untuk MainScreenViewModel dapat dilihat pada Gambar 3.31.

   Gambar 3.31 Class Diagram MainScreenViewModel

3. Class DeepLDocumentClient

   *Class Diagram* untuk DeepLDocumentClient dapat dilihat pada Gambar 3.32.

   Gambar 3.32 Class Diagram DeepLDocumentClient

   4. Class GeminiService

      *Class Diagram* untuk GeminiService dapat dilihat pada Gambar 3.33.

      Gambar 3.33 Class Diagram GeminiService

      5. Class DocumentContentExtractor

      *Class Diagram* untuk DocumentContentExtractor dapat dilihat pada Gambar 3.34.

         Gambar 3.34 Class Diagram DocumentContentExtractor

6. Class PdfHandler

   *Class Diagram* untuk PdfHandler dapat dilihat pada Gambar 3.35.

   Gambar 3.35 Class Diagram PdfHandle

   7. Class TranslationHistoryItem

      *Class Diagram* untuk TranslationHistoryItem dapat dilihat pada Gambar 3.36.

      Gambar 3.36 Class Diagram TranslationHistoryItem

      8. Class DocumentSummary

      *Class Diagram* untuk DocumentSummary dapat dilihat pada Gambar 3.37.

         Gambar 3.37 Class Diagram DocumentSummary

9. Class UiState

   *Class Diagram* untuk UiState dapat dilihat pada Gambar 3.38.

   Gambar 3.38 Class Diagram UiState

   10. Class LoginScreen

       *Class Diagram* untuk LoginScreen dapat dilihat pada Gambar 3.39.

       Gambar 3.39 Class Diagram LoginScreen

       11. Class WelcomeBackScreen

       *Class Diagram* untuk WelcomeBackScreen dapat dilihat pada Gambar 3.40.

           Gambar 3.40 Class Diagram WelcomeBackScreen

12. Class MainScreen

    *Class Diagram* untuk MainScreen dapat dilihat pada Gambar 3.41.

    Gambar 3.41 Class Diagram MainScreen

    13. Class SummaryCard

        *Class Diagram* untuk SummaryCard dapat dilihat pada Gambar 3.42.

        Gambar 3.42 Class Diagram SummaryCard

14. Class TranslatedFileContent

    *Class Diagram*	untuk	TranslatedFileContent	dapat	dilihat	pada Gambar 3.43.

    Gambar 3.43 Class Diagram TranslatedFileContent

    15. Class ExplanationDialog

        *Class Diagram* untuk ExplanationDialogdapat dilihat pada Gambar 3.44.

        Gambar 3.44 Class Diagram ExplanationDialog

        16. Class AppUtils

        *Class Diagram* untuk AppUtils dapat dilihat pada Gambar 3.45.

            Gambar 3.45 Class Diagram AppUtils

17. Class Color

    *Class Diagram* untuk Color dapat dilihat pada Gambar 3.46.

    Gambar 3.46 Class Diagram Color

    18. Class Theme

*Class Diagram* untuk Theme dapat dilihat pada Gambar 3.47.

Gambar 3.47 Class Diagram Theme

19. Class Type

*Class Diagram* untuk Type dapat dilihat pada Gambar 3.48.

Gambar 3.48 Class Diagram Type

20. Class Typography

*Class Diagram* untuk Typography dapat dilihat pada Gambar 3.49.

Gambar 3.49 Class Diagram Typography

21. Class ItextPdfExtractor

    *Class Diagram* untuk ItextPdfExtractor dapat dilihat pada Gambar 3.50.

    Gambar 3.50 Class Diagram ItextPdfExtractor

    4. # **Sequence Diagram**

*Sequence diagram* menggambarkan interaksi antara objek-objek dalam urutan waktu tertentu untuk menyelesaikan suatu kasus penggunaan atau fungsi sistem. Dengan menampilkan pesan yang dikirim di antara objek, diagram ini memperlihatkan dinamika pelaksanaan proses. Setiap objek direpresentasikan oleh garis vertikal (*lifeline*) yang menunjukkan keberadaannya sepanjang waktu. Pesan-pesan digambarkan sebagai panah horizontal antara *lifeline* objek-objek tersebut. Urutan pesan dari atas ke bawah menunjukkan urutan kejadian dalam waktu. Diagram ini sangat berguna untuk memahami alur kerja dan kolaborasi antar objek dalam suatu sistem. Melalui *Sequence Diagram*, kompleksitas interaksi antar objek dapat divisualisasikan dengan mudah. Berikut adalah *sequence diagram* yang sudah dirancang sesuai kebutuhan sistem aplikasi.

1. Sequence Diagram Pada Login

   *Sequence diagram* yang menggambarkan alur ketika login dapat dilihat pada Gambar 3.51.

   Gambar 3.51 Sequence Diagram Pada Login

2. Sequence Diagram Pada Logout

   *Sequence diagram* yang menggambarkan alur ketika logout dapat dilihat pada Gambar 3.52.

   Gambar 3.52 Sequence Diagram Pada Logout

3. Sequence Diagram Pada Mengunggah Artikel Jurnal

   *Sequence diagram* yang menggambarkan alur ketika mengunggah artikel jurnal dapat dilihat pada Gambar 3.53.

   Gambar 3.53 Sequence Diagram Pada Mengunggah Artikel Jurnal

4. Sequence Diagram Pada Menerjemahkan Artikel Jurnal

   *Sequence diagram* yang menggambarkan alur ketika menerjemahkan artikel jurnal dapat dilihat pada Gambar 3.54.

   Gambar 3.54 Sequence Diagram Pada Menerjemahkan Artikel Jurnal

5. Sequence Diagram Pada Menyimpan Hasil Terjemahan

   *Sequence diagram* yang menggambarkan alur ketika menyimpan hasil terjemahan dapat dilihat pada Gambar 3.55.

   Gambar 3.55 Sequence Diagram Pada Menyimpan Hasil Terjemahan

6. Sequence Diagram Pada Membagikan PDF Hasil Terjemahan *Sequence diagram* yang menggambarkan alur ketika membagikan pdf hasil terjemahan dapat dilihat pada Gambar 3.56.

   ![][image6]

   Gambar 3.56 Sequence Diagram Pada Membagikan PDF Hasil Terjemahan

7. Sequence Diagram Pada Mengunduh PDF Hasil Terjemahan

   *Sequence diagram* yang menggambarkan alur ketika mengunduh pdf hasil terjemahan dapat dilihat pada Gambar 3.57.

   Gambar 3.57 Sequence Diagram Pada Mengunduh PDF Hasil Terjemahan

8. Sequence Diagram Pada Membuka PDF Hasil Terjemahan

   *Sequence diagram* yang menggambarkan alur ketika membuka pdf hasil terjemahan dapat dilihat pada Gambar 3.58.

   Gambar 3.58 Sequence Diagram Pada Membuka PDF Hasil Terjemahan

9. Sequence Diagram Pada Melihat Riwayat Terjemahan

   *Sequence diagram* yang menggambarkan alur ketika melihat riwayat terjemahan dapat dilihat pada Gambar 3.59.

   Gambar 3.59 Sequence Diagram Pada Melihat Riwayat Terjemahan

10. Sequence Diagram Pada Memilih Riwayat Terjemahan

    *Sequence diagram* yang menggambarkan alur ketika memilih riwayat terjemahan dapat dilihat pada Gambar 3.60.

    Gambar 3.60 Sequence Diagram Pada Memilih Riwayat Terjemahan

11. Sequence Diagram Pada Menghapus Riwayat Terjemahan

    *Sequence diagram* yang menggambarkan alur ketika menghapus riwayat terjemahan dapat dilihat pada Gambar 3.61.

    Gambar 3.61 Sequence Diagram Pada Menghapus Riwayat Terjemahan

12. Sequence Diagram Pada Meringkas Artikel Jurnal

    *Sequence diagram* yang menggambarkan alur ketika meringkas artikel jurnal dapat dilihat pada Gambar 3.62.

    Gambar 3.62 Sequence Diagram Pada Meringkas Artikel Jurnal

    13. Sequence Diagram Pada Menampilkan Ringkasan

        *Sequence diagram* yang menggambarkan alur ketika menampilkan ringkasan dapat dilihat pada Gambar 3.63.

        Gambar 3.63 Sequence Diagram Pada Menampilkan Ringkasan

14. Sequence Diagram Pada Menjelaskan Definisi Kata/Frasa

    *Sequence diagram* yang menggambarkan alur ketika menjelaskan definisi kata/frasa dapat dilihat pada Gambar 3.64.

    Gambar 3.64 Sequence Diagram Pada Menjelaskan Definisi Kata/Frasa

    15. Sequence Diagram Pada Mengetik Kata/Frasa

        *Sequence	diagram*	yang	menggambarkan	alur	ketika	mengetik kata/frasa dapat dilihat pada Gambar 3.65.

        Gambar 3.65 Sequence Diagram Pada Mengetik Kata/Frasa

16. Sequence Diagram Pada Menampilkan Hasil Terjemahan

    *Sequence diagram* yang menggambarkan alur ketika menampilkan hasil terjemahan dapat dilihat pada Gambar 3.66.

    Gambar 3.66 Sequence Diagram Pada Menampilkan Hasil Terjemahan

17. Sequence Diagram Pada Menampilkan Artikel Jurnal Asli

    *Sequence diagram* yang menggambarkan alur ketika menampilkan artikel jurnal asli dapat dilihat pada Gambar 3.67.

    Gambar 3.67 Sequence Diagram Pada Menampilkan Artikel Jurnal Asli

18. Sequence Diagram Pada Pindah Halaman Artikel Jurnal

    *Sequence diagram* yang menggambarkan alur ketika pindah halaman artikel jurnal dapat dilihat pada Gambar 3.68.

    Gambar 3.68 Sequence Diagram Pada Pindah Halaman Artikel Jurnal

    19. Sequence Diagram Pada Menampilkan Definisi Kata/Frasa

        *Sequence diagram* yang menggambarkan alur ketika menampilkan definisi kata/frasa dapat dilihat pada Gambar 3.69.

        Gambar 3.69 Sequence Diagram Pada Menampilkan Definisi Kata/Frasa

20. Sequence Diagram Pada Memulai Terjemahan Baru

    *Sequence	diagram*	yang	menggambarkan	alur	ketika	memulai terjemahan baru dapat dilihat pada Gambar 3.70.

    Gambar 3.70 Sequence Diagram Pada Memulai Terjemahan Baru

    6. # **Perancangan Sistem**

Tahap perancangan sistem dalam penelitian bertujuan untuk menyusun dan memvisualisasikan cara kerja aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android. Pada tahap ini, dilakukan perencanaan serta pembuatan rancangan yang mencakup berbagai komponen utama dalam aplikasi. Hasil dari proses ini diharapkan dapat memberikan gambaran menyeluruh mengenai sistem yang akan dikembangkan, memastikan bahwa kebutuhan fungsional dan non- fungsional dapat terpenuhi secara efektif.

Perancangan sistem ini berfokus pada detail implementasi dari setiap modul aplikasi, mulai dari struktur menu yang intuitif hingga desain antarmuka pengguna yang responsif. Hal ini penting untuk mentransformasikan kebutuhan abstrak yang diidentifikasi pada tahap analisis menjadi blueprint teknis yang dapat diimplementasikan, sehingga menghasilkan aplikasi yang stabil, efisien, dan mudah digunakan oleh mahasiswa.

1. # **Perancangan Basis Data**

Perancangan basis data merupakan tahap yang bertujuan untuk mentransformasikan model konseptual menjadi struktur basis data yang siap diimplementasikan. Pada tahap ini, dilakukan perencanaan serta pembuatan rancangan yang mencakup berbagai komponen utama dalam basis data. Hasil dari proses ini diharapkan dapat memberikan gambaran yang jelas dan terstruktur mengenai basis data yang akan dikembangkan, sehingga mampu menyimpan dan mengelola data secara efisien dan akurat.

Dalam konteks aplikasi penerjemah multibahasa untuk artikel jurnal berbasis Android, perancangan basis data berfokus pada penyimpanan histori dokumen terjemahan, metadata terkait, serta riwayat interaksi dengan fitur AI. Hal ini penting untuk memastikan bahwa setiap aktivitas pengguna, seperti hasil terjemahan artikel jurnal dapat tercatat dan diakses kembali, serta mendukung fungsionalitas utama aplikasi. Perancangan basis data ini dibagi menjadi dua bagian utama, yaitu pemetaan entitas ke koleksi dan perancangan struktur koleksi.

1. # **Pemetaan Struktur Koleksi**

Dalam sistem yang dibangun menggunakan database Firebase, data diatur dalam koleksi untuk mencerminkan hubungan hierarkis dan ketergantungan data yang diimplementasikan dalam kode. Pemetaan ini memastikan bahwa setiap entitas konseptual disimpan secara efisien dan benar sesuai dengan model NoSQL. Tabel berikut menggambarkan pemetaan antara entitas, nama koleksi yang akan digunakan dan deskripsi mengenai struktur dokumen ini, dapat dilihat pada Tabel 3.40.  
Tabel 3.40 Daftar Koleksi

| No | Nama | Nama Koleksi | Deskripsi |
| :---: | ----- | :---: | ----- |
| 1 | Pengguna | Users | Koleksi ini menyimpan setiap profil pengguna. Dokumen di koleksi ini diidentifikasi oleh userId, dan berfungsi sebagai induk untuk semua data spesifik pengguna. |
| 2 | Riwayat Terjemahan | Conversations | Setiap dokumen dalam koleksi ini mewakili satu riwayat terjemahan, menyimpan objek dengan semua metadatanya. |

2. # **Perancangan Struktur Koleksi**

Perancangan struktur koleksi merupakan salah satu aspek yang paling penting dalam membangun sebuah sistem. Struktur koleksi yang dirancang dengan baik akan memastikan bahwa sistem dapat mengelola data secara efisien dan memenuhi kebutuhan operasional. Berikut adalah struktur koleksi untuk masing-masing koleksi Firebase yang digunakan dalam sistem ini, demi kemudahan dokumentasi dan pengembangan.

1. Koleksi Users

   Koleksi ini menyimpan setiap profil pengguna dalam aplikasi. Dokumen di dalamnya diidentifikasi oleh userId dari setiap pengguna, dan utamanya berfungsi sebagai penampung untuk koleksi conversations yang terkait dengan pengguna tersebut. Koleksi users pada aplikasi yang dibangun dapat dilihat pada Tabel 3.41.

   Tabel 3.41 Koleksi Users

| Users |  |  |  |
| :---: | :---: | :---: | :---: |
| No | Field | Tipe Data | Deskripsi |
| 1 | userId | String | ID unik pengguna |

   2. Koleksi Conversations

      Koleksi ini secara spesifik menyimpan semua riwayat terjemahan dan interaksi dokumen yang terkait dengan pengguna tersebut. Setiap dokumen dalam koleksi ini adalah representasi dari sebuah riwayat terjemahan yang menyimpan semua metadata historis yang relevan. Koleksi conversations pada aplikasi yang dibangun dapat dilihat pada Tabel 3.42.

      Tabel 3.42 Koleksi Conversations

| Users |  |  |  |
| :---: | :---: | :---: | ----- |
| No | Field | Tipe Data | Deskripsi |
| 1 | documentId | String | ID unik dokumen |
| 2 | originalFileName | String | Nama asli file dokumen yang diunggah |
| 3 | originalDocUri | String | URI atau URL referensi ke |

|  |  |  | dokumen asli |
| ----- | ----- | ----- | :---- |
| 4 | originalDocHash | String | Hash SHA256 dari konten dokumen asli untuk deteksi duplikasi |
| 5 | translatedFilePath | String | Jalur file lokal dokumen terjemahan di perangkat Android |
| 6 | translatedDocUri | String | URL unduhan file terjemahan |
| 7 | translatedFileName | String | Nama file hasil terjemahan |
| 8 | translated | Boolean | Menandakan apakah dokumen sudah berhasil diterjemahkan (true/false) |
| 9 | timestamp | Timestamp | Waktu kapan riwayat ini dibuat atau terjemahan diselesaikan |

2. # **Perancangan Struktur Menu**

   Perancangan sistem merupakan tahap yang bertujuan untuk merancang dan menggambarkan bagaimana suatu sistem akan berjalan dan berfungsi. Hasil dari tahapan ini diharapkan dapat memberikan gambaran yang jelas dan terstruktur mengenai sistem yang akan dikembangkan. Gambar perancangan struktur menu pada aplikasi yang dibangun dapat dilihat pada Gambar 3.71.

![][image7]

Gambar 3.71 Perancangan Struktur Menu

3. # **Perancangan Antarmuka**

   Perancangan antarmuka pengguna merupakan proses yang berfokus pada pengaturan tata letak dan tampilan visual sistem guna memastikan kemudahan penggunaan, daya tarik estetika, serta kenyamanan pengguna dalam berinteraksi dengan sistem. Setiap komponen antarmuka dirancang secara sistematis berdasarkan fungsi spesifik dan kebutuhan pengguna yang telah diidentifikasi. Berikut merupakan desain antarmuka yang dirancang oleh peneliti sebagai bagian dari proses pengembangan aplikasi Artikel Jurnal Translator.

1. Perancangan antarmuka T01 Login

   Berikut adalah perancangan antarmuka T01 merupakan perancangan antarmuka login pada aplikasi yang dibangun dapat dilihat pada Gambar 3.72:

Gambar 3.72 Perancangan Antarmuka T01 Login

2. Perancangan antarmuka T02 Splash Screen

   Berikut adalah perancangan antarmuka T02 merupakan perancangan antarmuka splash screen pada aplikasi yang dibangun dapat dilihat pada Gambar 3.73:

Gambar 3.73 Perancangan Antarmuka T02 Splash Screen

3. Perancangan antarmuka T03 Unggah

   Berikut adalah perancangan antarmuka T03 merupakan perancangan antarmuka unggah pada aplikasi yang dibangun dapat dilihat pada Gambar 3.74:

Gambar 3.74 Perancangan Antarmuka T03 Unggah

4. Perancangan antarmuka T04 Menu

   Berikut adalah perancangan antarmuka T04 merupakan perancangan antarmuka menu pada aplikasi yang dibangun dapat dilihat pada Gambar 3.75:

Gambar 3.75 Perancangan Antarmuka T04 Menu

5. Perancangan antarmuka T05 Pratinjau PDF Terjemahan

   Berikut adalah perancangan antarmuka T05 merupakan perancangan antarmuka pratinjau PDF terjemahan pada aplikasi yang dibangun dapat dilihat pada Gambar 3.76:

   Gambar 3.76 Perancangan Antarmuka T05 Pratinjau PDF Terjemahan

6. Perancangan antarmuka T06 Pratinjau PDF Asli

   Berikut adalah perancangan antarmuka T06 merupakan perancangan antarmuka pratinjau PDF asli pada aplikasi yang dibangun dapat dilihat pada Gambar 3.77:

Gambar 3.77 Perancangan Antarmuka T06 Pratinjau PDF Asli

7. Perancangan antarmuka T07 Logout

   Berikut adalah perancangan antarmuka T07 merupakan perancangan antarmuka logout pada aplikasi yang dibangun dapat dilihat pada Gambar 3.78:

Gambar 3.78 Perancangan Antarmuka T07 Logout

8. Perancangan antarmuka T08 Hapus Riwayat Terjemahan

   Berikut adalah perancangan antarmuka T08 merupakan perancangan antarmuka hapus riwayat terjemahan pada aplikasi yang dibangun dapat dilihat pada Gambar 3.79:

   Gambar 3.79 Perancangan Antarmuka T08 Hapus Riwayat Terjemahan

9. Perancangan antarmuka T09 Summary

   Berikut adalah perancangan antarmuka T09 merupakan perancangan antarmuka summary pada aplikasi yang dibangun dapat dilihat pada Gambar 3.80:

Gambar 3.80 Perancangan Antarmuka T09 Summary

10. Perancangan antarmuka T10 Kata/Frasa

    Berikut adalah perancangan antarmuka T10 merupakan perancangan antarmuka kata/frasa pada aplikasi yang dibangun dapat dilihat pada Gambar 3.81:

Gambar 3.81 Perancangan Antarmuka T10 Kata/Frasa

11. Perancangan antarmuka T11 Share

    Berikut adalah perancangan antarmuka T11 merupakan perancangan antarmuka share pada aplikasi yang dibangun dapat dilihat pada Gambar 3.82:

Gambar 3.82 Perancangan Antarmuka T11 Share

12. Perancangan antarmuka T12 Penjelasan Kata/Frasa

    Berikut adalah perancangan antarmuka T12 merupakan perancangan antarmuka penjelasan kata/frasa pada aplikasi yang dibangun dapat dilihat pada Gambar 3.83:

Gambar 3.83 Perancangan Antarmuka T12 Penjelasan Kata/Frasa

13. Perancangan antarmuka T13 Pilih Upload File

    Berikut adalah perancangan antarmuka T13 merupakan perancangan antarmuka pilih upload file pada aplikasi yang dibangun dapat dilihat pada Gambar 3.84:

    Gambar 3.84 Perancangan Antarmuka T13 Pilih Upload File

14. Perancangan antarmuka T14 Menunggu Terjemahan

    Berikut adalah perancangan antarmuka T14 merupakan perancangan antarmuka menunggu terjemahan pada aplikasi yang dibangun dapat dilihat pada Gambar 3.85:

Gambar 3.85 Perancangan Antarmuka T14 Menunggu Terjemahan

4. # **Perancangan Pesan**

   Perancangan pesan merupakan bagian penting dalam pengembangan aplikasi yang bertujuan untuk memastikan informasi yang disampaikan kepada pengguna dapat diterima dengan jelas, tepat, dan sesuai konteks. Pesan-pesan ini mencakup berbagai jenis komunikasi dalam sistem, seperti notifikasi, peringatan, konfirmasi, maupun umpan balik dari sistem terhadap tindakan pengguna. Dengan perancangan pesan yang efektif, diharapkan

interaksi antara pengguna dan aplikasi menjadi lebih informatif, efisien, serta meningkatkan pengalaman pengguna secara keseluruhan. Perancangan pesan pada aplikasi artikel jurnal translator dapat dilihat pada gambar di bawah ini.

1. Perancangan Pesan PP01

   Berikut merupakan perancangan pesan PP01. Pesan ini ditampilkan ketika pengguna berhasil masuk ke aplikasi, yang dapat dilihat pada Gambar 3.86.

   Gambar 3.86 Perancangan Pesan PP01

   2. Perancangan Pesan PP02

      Berikut merupakan perancangan pesan PP02. Pesan ini ditampilkan ketika pengguna berhasil keluar dari akun, yang dapat dilihat pada Gambar 3.87.

      Gambar 3.87 Perancangan Pesan PP02

      3. Perancangan Pesan PP03

         Berikut merupakan perancangan pesan PP03. Pesan ini ditampilkan ketika artikel jurnal berhasil diterjemahkan, yang dapat dilihat pada Gambar 3.88.

         Gambar 3.88 Perancangan Pesan PP03

4. Perancangan Pesan PP04

   Berikut merupakan perancangan pesan PP04. Pesan ini ditampilkan ketika hasil terjemahan berhasil didownload, yang dapat dilihat pada Gambar 3.89.

   Gambar 3.89 Perancangan Pesan PP04

   5. Perancangan Pesan PP05

      Berikut merupakan perancangan pesan PP05. Pesan ini ditampilkan ketika pemilihan artikel jurnal dibatalkan, yang dapat dilihat pada Gambar 3.90.

      Gambar 3.90 Perancangan Pesan PP05

      6. Perancangan Pesan PP06

         Berikut merupakan perancangan pesan PP06. Pesan ini ditampilkan ketika PDF hasil terjemahan berhasil ditampilkan di pratinjau PDF, yang dapat dilihat pada Gambar 3.91.

         Gambar 3.91 Perancangan Pesan PP06

         7. Perancangan Pesan PP07

         Berikut merupakan perancangan pesan PP07. Pesan ini ditampilkan ketika PDF artikel jurnal asli berhasil ditampilkan di pratinjau PDF, yang dapat dilihat pada Gambar 3.92.

![][image8]

Gambar 3.92 Perancangan Pesan PP07

8. Perancangan Pesan PP08

   Berikut merupakan perancangan pesan PP08. Pesan ini ditampilkan ketika riwayat terjemahan gagal dihapus, yang dapat dilihat pada Gambar 3.93.

   Gambar 3.93 Perancangan Pesan PP08

   9. Perancangan Pesan PP09

      Berikut merupakan perancangan pesan PP09. Pesan ini ditampilkan ketika riwayat terjemahan berhasil dihapus, yang dapat dilihat pada Gambar 3.94.

      Gambar 3.94 Perancangan Pesan PP09

      10. Perancangan Pesan PP10

          Berikut merupakan perancangan pesan PP10. Pesan ini ditampilkan ketika artikel jurnal sudah pernah diterjemahkan, yang dapat dilihat pada Gambar 3.95.

          Gambar 3.95 Perancangan Pesan PP10

11. Perancangan Pesan PP11

    Berikut merupakan perancangan pesan PP11. Pesan ini ditampilkan ketika email yang dipakai untuk login bukan email tervalidasi sebagai email mahasiswa, yang dapat dilihat pada Gambar 3.96.

    Gambar 3.96 Perancangan Pesan PP11

    12. Perancangan Pesan PP12

        Berikut merupakan perancangan pesan PP12. Pesan ini ditampilkan ketika dokumen yang akan diterjemahkan teridentifikasi sebagai artikel jurnal, yang dapat dilihat pada Gambar 3.97.

        Gambar 3.97 Perancangan Pesan PP12

        13. Perancangan Pesan PP13

            Berikut merupakan perancangan pesan PP13. Pesan ini ditampilkan ketika dokumen yang akan diterjemahkan tidak teridentifikasi sebagai artikel jurnal, yang dapat dilihat pada Gambar 3.98.

            Gambar 3.98 Perancangan Pesan PP13

5. # **Perancangan Jaringan Semantik**

   Perancangan jaringan semantik adalah tahapan yang berfungsi untuk menggambarkan relasi antara antarmuka pengguna dan pesan yang terdapat dalam perangkat lunak yang dibangun. Tahapan ini bertujuan untuk memastikan hubungan antara elemen dalam perangkat lunak yang dibangun. Berikut merupakan perancangan jaringan semantik pada aplikasi yang dibangun. Dapat dilihat pada Gambar 3.99.

Gambar 3.99 Perancangan Jaringan Semantik Pada Aplikasi

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAg8AAAD/CAYAAAB2KDWSAAAvAElEQVR4Xu3dCZgUxdkH8IVdlt1FDrkEjxijeKF48SVGxYgkggcaCeKBJyoEJDGR5BMvVBQVWIkKBhGvRKMfRAXk1AVWQQWUKPcCIaAiiEcUQRE5tr5+a6fK7rd7Znp7enqrZ/7v8/yqp6tnZmu7Zqf/2zM7WyACVkFBgVwAAABAfqEmUCE8AAAA5CdqAhXCAwAAQH6iJlAhPAAAAOQnagIVwgMAAEB+oiZQITwAAADkJ2oCFcIDAABAfqImUCE8AAAA5CdqAhXCAwAAQH6iJlAhPAAAAOQnagIVwgMAAEB+oiZQITwAAADkJ2oCFcIDAABAfqImUCE8AAAA5CdqAhXCAwAAQH6iJlAhPAAAJGfVDtvl6z22z7Zd3ml5y3Iovx6AiagJVAgPAADpWTXd6/mSwoPlewoM9vBg+dry98R16tuuv9eyx1JtaVdgu8/E7b/hXwMgW6gJVPYHLgAA/CBxgKeDvUist08s9QG+IHHmwarBiYO/Cg9028Ye99khsaTm57Rk2xEeIDLUBCr+wAUAgLpj1RDeB7WTCGY3qcuJJYW5TpYtOO79gJpAhZ0IAAC5RIUHyxpbHwUHurCFXz+fUROoEB4AACCX2MJDvcR6sa2fzjxU89vkK2oCFcIDQHBW/Vs9QfF+3pcNtifHZ/g2zqopvC8K9ucYq7bx7XFh1TW8rzbs+yEVqxbW5voAmaAmUOEBCpCZgpp32l/F+uTPluV1W9/+ltJE/65E308Sy3X22yUulySW8g17qp99nWssj1sqLJdahvNx2K/Lbx+VZOOPA6tOTKB9vchju0gs5ZspE5c/TCxXJL73Xfbv36r1BTVvllxUUPPXGs0thfw+AbKNmkCFBylA5qzazNblz5Zlscd19c9dwQ/hQb8Oa9s2wes27L7qW06xzLdUWWaw7fo2Vh3Ibx8Vqxp6jd9karwFNW+0W1NQEx6WWUYnud7Vli8Tlz+09cu5U+u2vmcKEB6gjlETqPAgBQiHVV35ZavaJbseLS2licudLT9LcT90XXt/EUlcbmbpaNv2c377xOW26jJkV0HizAOA6agJVAWGh4eTL3qw9IkZa8TaLXuMc+eTdAbTPeZMvbf+W9fXMsG0RZtFv5EVZ/DxZuK3D1RcNWvxFtfXMsHidd+I/uWz1/IxR8GqI3lf1AaMnL2B7xNTDBxVKfh4oXZoH1Zt2uXatyYYN3U1HdVc7yWC8FETqEwOD/Tg5g8qE1lPso5T1kH1HVFxGb9vE4X5xM3v20R9hs88go87171QucG1H0zExw3+DHhw7qd8X5qIjxvCR02gMjk88AeSqcZOWSX42IP405j5rvs2FR97EHEJh2GGpbjg+8BU+Tg3YXjm1X+79qWJ+g5/7bd87BAuagJVkPBw15RrJ905+brqIVOuncu3hYk/kEzGxx7EiOffd92vqfjYg0B4SO5f/+wuP8K4rvB9YKq6mJtcwPejqeI8v1Y15H3ZUHFet9Om9zi/euaF3efzbX5QE6hqEx6GTu0rVm5Z4XLvNAqH7utnij+QTMbHHgTCgzd6jPI+P1q1buPqU2pzn1E/gVXNukyIbfRHGu5tUeH7wE7tu7KyRq5tYVq85ou08xT13Pj1RdW4Op/DVPh+TOXsCy5y9UUl8vm15uzbTVOFqz8DVk2zHFBg+++sYZjV89di53uLPfHrpkJNoPITHoZNH+AKDF7CPhPBH0gm42MPAuHBGz1GFfv6tDeWiPv+Ml72vVP1mWMbXabwcPhRx8jLhYVFjvtre8BBrq+TTFRPYMun9egsDzg2i188r07eOMn3QTJqfy//8Bu5Pu+9D0TVpu/l5aXrv3Yc/KfOfV/8Y/Jcxzw+9vcpol69evLy0BFjRf369eU2dR/v/ftL19e0i2puauOLqsccc7hqRi/Br1PX+H70QnPSomVrGR7UPJeWlTmuM3TkWHHHsIf09mv73+SYszesx4Oa71uHjtLXu7rvjeLlVxe5viYX1fzKObLN2Y6QAoRVOxPL3XxbUJO6dv0xDwte1j85XvDbeqEmUNFE0iKZZGcbkuk77qQG/D6Csj+I7Uu/Djv8KFefUlRUVOv741Zu/E5f5mMPgoeHoN93UItWfaqftO28vj4fexC1CQ+0XL255p3hrdu0lX2z3lzhCA9PTZgpJlcsltu6dOvuOPNwxbUD9eUf/fgn8joPjXvB9bW8RPUExoOD8t7Uc11/7pltfB9wak4aNGhgHfT/qvspPNC24uKGctnx5E56G4WHAw482PG4btGylRjz1IvycoMGxeIvj/1DX5/mtsMJ/yPWfLLb9fWVyObGJx4cNI/r1iW+H71Mnr1YLik8DL57pJwjHh6ObH9czXXO7ym3e4UHWq6ynitvvnOEDPEUFpu3aGVUeHDNl+Xbj18RruvVklWPJpb0r9dD+esRHhJSmXNVb8Fvz1ETqGjCaZEMDwfpPPHmAynvrzbUA6hJ02Zy+bs/D5HLoxIP2NZt9pfjV07vcra47Z5R1oHkU3H38Ed1eKhXr75o0aq1vEwHjHsffFyHB3pQ0/KU07u4HrgKPdiXbdgu2h3ZXq5fckVfeZuowsOyDdvk8oKevXW/2kZjs1/fvu2uB8bober7VdvIveWPibeXbxYF1n1Mf2OZDg90kF5juWPYw2Lm/BWO2yh87EH4DQ91LYonsKpZl7uevOyWv9ztUH6bbOL7oDYa7dNYHhx4fzZEMTd+fbFqrGveHDxuU1f4fjRVJPPL58nm242Thev6dSjVSxXJTLvgnKv5/dhRE6hShYfLR/6qEQ8Hfgx55dp+/L78KEj8n3tFPYAoPNA4KTy8vWKz48FFT1TvrftKjP/HNH2Qo/BASxUeVn38nZjzjvPdxepgunLjDnHAQQe7HrQchQdaqt+CogoPdHqdwoP6rVt9/dvuHSWG3PeIPl2srk/LR56YIP72YoXrvmg5YZrzLzpuuOk2cfxJJ8vL9jMPg+8aWXO7xCll+20IH7sfVh1lXzctPIx7doqrj4T1BGbVFbxv6eTzT+dPWMksm3au/DTKKPB9UFtPT5jl6qsNr7lQPwN2Yc2NXwVJPmjr86o0wSGhrl7CKGAfTc73Y6Zee7vK1ReGbM4vf6kimW83ThL8tnWFBwM/dix+R/D7saMmUNGBgRZeavuShUK34/flF42nIPEBOfyBZDL+fQTBw0M6v71xsOcTahT42P1KzK/8VEV6YuD3SxYs3ywuvuJ6fcZJhRdaUnhqtE8Tud64Sc12OlU64pGn5SnzQbcNc9yG/GVszanwtvsfJO4pf8yxrXmL1vo0q73fLswnMNfPm8eTVSoLJ/7qEH6fYbBqt31sfB88/twroqS0TDQobijXX5n7nhgx+hm5z0pKSsQNf7xN9u/X9gDx7urPRev92or7H37CsV8fePhJK8jvlC9p2O+7NPHGy1vuLnfNNV3ucEJHuaSzhHxcYc6NXzQ2S2u1/vmqv7rmKZU6DBBCXeb70QsFuKIGDeTlNvsfKOeDXrZIfP+y/5Ir+4rRT0wUfxg8VLQ7oubMbHHDErmklxKfmzRHTEm8/KFuQ2eI+ddKJqz5TYx5q1r3GxyUbza+LPh9RkHta7o889fdV/Jg4Be/X8fXoK1Byv6A4jIJD+qbzgR/IJmM77sgahse6hKfqyDoiYHfLxn+yFPixRlvy8vN9m0hunQ733E7+3XpjNDqzd/LM1BvL9+k++2/CdGT3nkXXuJ4iUd9D7T8eaczPe9boXHysYehalZv15OUHwe0/uEJPEsq+T6g8KAuL1n/tTiza3c9L/brURCjPgoPt9/7kOx7470N8uBDl/n1CZ3xUpdfnrVQX49eMqO5o6+zdMO2pOHBY/yRqW1wUPj9RI3vRy/q7A9dn+agqKiB6z0PVZt2ioYlpaKPFeBV3zP/fE1fbtKk5qwxXZ5WuUS8lJhf9cbYdLI0v1v5fPhBAcLjviLzwrndqnko8Isfa+yoCVQ0KFp4ySQ88PvyS+0ouswfSCbj30cQcQoPfOx+Jeb3e7pMTwz8fsmzL8/R4YEOVLTcxwoH6rGhrqdeYqGzL2rbqLHPyTfe2e+P/uSv67kXypeqaN3+BrxJr70rb0dv5LLftx2Nk38fQSXGeaPu83iSSiVbv7VadW5ibEtpne8DHh5KS8vEX5+Z5NhnKz+q+Vh16lPh4djja84atGy9n95mv98XZy5wrKs30dH16OVI+fX+U/MYSBYe+PeSbeqxpvs85imVje8M+eG2EUqM+890me9HLyo80Jsl6YwR3Z6HB/pZon4680Dr9DLw3Hf/o7er8EDo5/T5yTU/87UJD/z7CILP2drZ17rmJZ0ZD/+0Cb/fbFPjtjSc0aP7Jh4K/OL36/gatDVIOX4IPPBg4MegFy87mN9PEPyB5IVObT8yfoJEp6/pfQj0DuBzL+gl2h97ouNP8trsf4AoTLzXQf2W2rxFS72d+k/66aly2bJVG7nkXy8ZPvYg/IaH56e8Ic6xvj+6TGOkU4e2B5kosX4T4LdR3wudUn7QOsCq/rF/m+S6rh987EHQEwO/XxOF9QSWzN6tC11PVJ48bpstfB+YKttz45ff0+DLp/aYyW9bF/h+9PLMxFddfVHL5vyumN7jJj4/XrIV2IPgocCPLZNTv+RCTaAKOzys+GR5yvurDf5ASoY+rOatZR/LNKtOi9H39ZPDjnBdt9m+zSUKD/RbKl2m/rvur/nLBHUApvAwYar/j4vmYw8iaHhQ/Zde2U+uN222r+5Tb6i0Xy9ZeHhw7LOur5UMH3sQ9MTA79dE2XwCU6q3LnI9adXlExjfB6aKYm5885g3uxXTfjPLdZs6wvejqbI9vyum9BjE58nF43Z1ZfGt/+sKB+lMv/D8z/n92FHjqwoLC1VgkJUuPIyY9UdXQEjljslXPcbvIyj+QErl+JN+Jr+X+0bV/N0/XR7398mOg6bqp9e+1ZkHtb3dEUfr9TiEBxqj+lt61a/CwxFHHeu6jf166nuky3E+89CwpOaNWelULFjt6quNbD+BafxJK2H51J7Vrut6sEr+OadVnyWWZ/Lr+MX3QW11PPk0Vx9nf0wGFdnc+OUxf2TF1J6vuq5bh/h+zAS9pMH7lBUfZvYfgqOY32UpAsTEiQXF/Pp1jYeDVL6aWyH47TlqfNXw4cNF48aN9Tr9ANMiFR4QksnkvQ5e+APJC70RjvcpdOYhjCcoP/jYg/ATHt5d87nnBzmlot7NHiY+9iAyDQ80t/QmLrps/4RJ/qFCcQkPXqe+a3PGwRYetlvOon1hacSv5wffB7XV4cSfymViDHpOxv9jqihu2FC/T4XfrraimptaYXNYV+9xSIXvx1Ro7tR7G9Rc2udUhYfjEr/A2eeV3ij75AvT5V9gBPnLsKjmd/WrV7h+9haH+IGHYZpxYfe9PCQkw2/rhRpfRRPrse66Q+7Wl665kocFuyGTrl3Nb5Mp/kAyGR97EH7Cgyn42IMIIzy0aFXzRjwVHtSfiyn0BBeX8KCpJzDen0aBMzxcbNllcZwJtOpxfjsvfB/UFg8Pqv+Pg4eKS6/qJ16ctSB3wwNJzGGmL1VY9ZXt8izLZ5ajLT0Tfcfw2/jB92Mql1x5vVza51It6ecrVXigMw9XXvc70bvPADFx+puu+04nyvld+UqPPwf92YvatHPOOuXbRQtcYUGxAkbKlyrsqPFV9HGyL774ol6niaaFX3R24d5p/QW9nEH/82LIpKtcH3wTFv5AMhkfexAID7UTxsHHjyifwJTanHHIBr4PaqvzWee6+rKhLubGD/qtdcW0njN4f23Zw0NifWNiSR996Lq+X3w/mirq+V0x5Tc3W3NXxvtNNfG001rRp07OvfpyUXFZL0GX+XXSocZ3JQKD/bLrDk3AH0immrvsC8HHHsRdT7/jum9T8bEHkWl4iErUT2Am4PvAVLk+N/bwYFV99XxtFT3p0HI7v40f81am/odjpug/smIeHzuEixpfRX+RQH/vrsrk8GA9cGbzB5OJrrxnRij/d+CiiyYW8vs2UZhP2Py+TcTHnA/iEuz4uMGfviNf/Rnflybi44bwUeOrbrnlFvnXBqpMDg8k7Ccx+n55Xyb6j5y9lo85E78dXvFn/jVMEmZwIGHPb9jC/n7jxOS5ebPqK0Fhm48Z/LvrqfT/1bIu5fPPXpSoCVSmhwfIjFWLeR8AQNis6sz7wHzUpK0dO3ZoqhAechvmF0xh1T68D3KHqc81NC4LvQbi2gY+wwNVeXm5aNKEPqK7pkydcAhH4genIe8HiJJVX+O5JnclnmeMPJ5Y9VJibEcn1oV9ya7b0VKvwOMD1hL3cZ7lTctFib7X+fXihhpfVVFRIaqqqvS61w6E3IH5BYBss6qbpa+JzzdWdUgsj0ss5V+wJBtrQU14uNajXx4vLesK8jE80DffsCH9IvrDOi0gN2F+zWHVd2o+rLqfb4f4UAeSxOVhfHs+soo+YtjVD2ajxlfZHvR6nRaQmzC/5rLqEN4H8WNVfd6XjxAe4okaXXTAKC0ttXfpom19+vRxrNMCAKJh1aGWNwp8flQ0mMuq4ZZyCz3hurbnk6jDg59jV6rrpNoWFvoall/xfpNQo2vdunUqFDgq8Y04tkWxA6HuYH4BIAoFdRAeCn74D7L/TSw3WNpZplluTFznbcvJlkLLvy17Ev1E/k8mq6osZ1v2Wr5M9B2Z6P/E0jZx/SWWDxPbv0/0PU/LRJ/rP+CqbaaiRtfkyfSx58lrzx75yV2yTP/GIDOYXwCIQkHdhIczLHfZDt7UHJdYKjo8JK6jw0NivVVifafq8/g6rmNloq/aQh/ZrPvYdU7j92caanQlvgHPsu0EvU4LyE2YXwCIQkHE4cEUVrXgfXFCjaO8AsRnn32mqcLBBQAAMpWv4SHuqElbhYWFrlCB8JDbrOrI+wAAwobwEE/U6Fq0aJErJFDRex2ov3fv3roP4SG3YX4BIAoID/FEja62bduKDRs22LuSFg4uuQ3zCwBRQHiIJ2pkVVZWykDgdebBq3BwATBH4mf3j4nL3/PtAKZCeIgnanRt375d/gMsP4XwAGAWW/h3bQMwFcJDPFHjKPv/r0hVeJLKbZjf+EF4gDhCeIgnagIVnqRyG+YXIHoqAObTzx/CQzxR46jEgzZt5dODOx9hfqM18v+WiLVb9hjh7qfeEXx8EI18Cw4E4SGeqNH1xRdfIDwAROyGkbN38QN4XVv5Mb3n0j1WyC6rTsi351aEh3iiRpct9aatfHuA5xvMb3T4gdsUA0dVCj5W8Na/fPZG2l8m6T9y7td8nGEZUD53Kf96dW2AFcL5OCF7qJGlggPCAxDMbzT6jZw9lR+0TbFqE84+pNP3gdeu4fvNRHzcmeD3bSI+ZggfNYEKB5fchvmNRv/yuXP4E18qNC+0POa4k+Ty8msGiDN+eY6krtOl2/nizaUfiaf+b6ZcV9vt1/GLjxecFv9nu2ufmYh+M+djD4Luh9+3iawfk/p87BAuanTt2rULZx4AIlTb8KBQeGjZuo0YOnKsDhRL138t6tWrp69z4813J55Ia84o8vvwg48XnPj+MtVtjy8QfOxBrNy403XfJhpQXrGNjx3CRU2gQnjIbZjfaAQJDxQQKDys3rxLNG7c1BEe1HXKyvYRaz7ZLS8jPGQP31+mun38QsHHHgS/X1OFdaYFkqNGlnqCadasmepKWTi45DbMbzSChIdU9m3e0tWXCT5ecOL7y1QIDxA2anTt3btXhYK0hYNLbsP8RiPs8BA2Pl5w4vvLVAgPEDZqZPkNDapwcAHIXFThYb82+7v67AoLC119hI8XnPj+UsY/N1UuS8vKXNuS6XDC/7j67E4/s5urz68owkNxcUO5/PVFV7i2hYmOPW/8a4Or3w7hIfuoCVQID7kN8xsNr/AwZNjD8uer7QEHiRM6nux40rzs6n6iYsEa15PppVf1c/SNeeqfctm8RSu5ncLDnQ+MFnc9MEYsXPmJ3DZx+ptyG0F4CIbvL2XeextE5bvr9Pz0vmaA1P7YExL7u0huW/XxTtGiZWt5mcKDut6BB/3YdZ8qPFzY60p9v/Xr18ybmkd+GyWK8NCwYYlo1Ggf8ZtLrxadOneV34faRiHKPj77eFu1biNeW7BaXHzF9Y77s1//553O1Jff+/eXosz6Ovzr2yE8ZB81gQoHl9yG+Y2GV3g4v8dl8s2QJSWljidJmpMBN90mL9v/qoL6h9z/iOsJlPrr1a8v7yddeDilUxfX7QkfLzjx/aVQeKhv7Xv7XNBShYe3ln0slxQe1HYKD7T80+33OcLDcSf+VC7tZx7UvF10WR+xcuMOvc7HoUQVHgbddp8MD2qMaps6A3P/Q0/obWo7hYcnX5iu/7RYsd/efrmktEw0KC52XJdDeMg+anTNmzdPfPnll/aupEWTSQvITZjfaHiFh0uvdJ5F8JLqQBEmPl5w4vvLr36/uzmyOSRRhId0Vny0Q/zokENd/dmA8JB91MhSSTBx0EhbOLjkNqte4X0QPq/wYBI+XnDi+8tUJoSHKCE8ZB81uhAeAKKVLDy073Ciq0+Zv+QjVx+X6rfaVNs4Pl5w4vsrnVT7PtU2P9uJehmEi2N4UC9xBIHwkH3U6KqurkZ4AAnzGw2v8NC9x6WO8DDv/Q/lkl4bpqUKD0VFDeTyX2v/q6+7YPlm/UuAOtjcMrRcLs86r4ejX7ntnlGiMHFfHB8vONn3FX0oV9Wm7x37b+VHO/Rlte/pg734frbPi31+1BsiCb9vfrvnJs11vIfCfr1shwf7OMY9O0UuKxevF8s2bHNdV+lx8VXijF+eLSoW1rwBeOb85Y7tFB6uvG6g63ZEfa2Z81e4thGEh+yjJlDR5NECchPmNxpe4eHgQw6T4UE9QXqFB9p28CHt5Po/Jtf8v4GmzZqL3/5+sH4iV7dX4eGIo4919CsUHg5td6SjT+HjBSf7vqLwsHDVFv3JnoTCw2ln/EpeVvs+VXh4a+lGx/zwueLsc92t+2+MCg/vr/tKhgd68+/sRWtdtzn08KPEHwYPlSGD1u3hocr6Pig8HHLYEa7bqa+nLh/Toeb/vNghPGQfNbr27JFPFr6KJo8WABCcV3gwCR8vOPH9ZapshwfTIDxkHzWyEmFAL9MVwgNA5hAe4o3vL1MhPEDYqJG1bRv9EzLq0V0pC+Eht2F+o5HN8MBPXQfBxwtOfH+ZCuEBwkaNLPWa1YQJE1RXysLBJbdhfqORLjyccnoXMXHGW44++oCh/doe4AoH5114ib6sfp755fN7XCqXLVvtJ5etWtW8jyIZPl5w4vvLVAgPEDZqAhUOLrkN8xsNr/Bw9LHHy+XJp54hmjRp5goP9El+TZrt6woPpEnTfcWBB/9EfkKhPTzs07iJaN6ipQ4PN985Qm8rLWvkuh+Fjxecbn98oWufmSisgyndD79vE/FxQ/io0aV+Q/FTOLgAZK7viNdG8Se+sHmFDD/eWStfynSNGZz4fjPNrePeFnzMmeD3byI+ZggfNYEK4SG3YX6jw5/4TBHWb6v54KbR88QdTyzM2HGndnf1BTX4sbeyMofn/3lyY7pf/vXq2m2PL8jK9wveqJGlzjrgzAMQzG90TD0VzMcJ2WdVDwud8nFtAzAJNbq2b9+O8AAS5jdaYQQImrNplUtc/bWF394gSniuiSdqdG3YsAHhASCm6GfSMoD3A5jKqv44lsQTNbJOOeUUzU9hwgEAIBOJwEtK+DYwGzWyKisr1SSqrpSF8JDbML8AAJAMNY6qX78+7/IsHFxyG+YXAACSoUbWPffcI82fP191pSwcXAAAIFNW9eV9YD5qdG3ZsgUvWwAAQGQQHuKJGl14zwMomF8AiALCQzxRI0sFB4QHIJhfAABIhppAhYNLbsP8AkAUcOYhnqhJWvazEQAAAAASDwx+i25MC8hNmF8AiEIBzjzEEjW6VKLwUzi45DbMLwAAJEONrnXr1oklS5bYu5IWDi65DfMLAFGwqinvA/NRo+u7777zPPOwdetWTRUOLgAAkCm8bBFP1AQqhIfchvkFgCggPMQTNb7q5JNPdpyVwMElt2F+AQAgGWp00QHD62ULKr4NB5fchvkFAIBkqNHFA4K92rVr51jHwQUAADKFly3iiRpdt9xyi+jYsaO9SxcPFggPuQ3zCwBRQHiIJ2oclezMQ9Om9Nc0PxQOLrkN8wsAUUB4iCdqdG3btk00atTI3qUrn888WHWG5RoL7RzX9lyUT/MLAAC1Q43vytfwQPLt+wUAiALOPMQTNbLUmQV7QLAX35ZvB1OrPuV9AACQGYSHeKImbZWVlUmffkrHz5qKQ3joP3LOmIGjKoVp+g2v6M3Hapo4zC8AxB/CQzxR46hkZx6oGjZsqC+bfnAZM2mlWLtlj7FufPh1wcdsEtPnFwAA6g41gcrkg8vD/1zuOlib6PcPvS742AEA8gnOPMQTNboGDRok7r77bnuXrBUrVmiqTA4P/CBtqqrNuwQfOwBAPkF4iCdqdFEgSPWyhb0QHsLBx24Kk+cXAHIHwkM8UaMrVXg45JBDHNtMPrjwA7TJ+NhNYfL8AgBA3aJG17Rp00R1dbW9K2mZfHDhB2iT8bGbwuT5BYDcgTMP8USNowoLC3mXrMaNGzuChckHF/vB+f11X8kljZcur/lkt1yfMG2+WLphm7z816dfchzQJ89erC+PfnKivvzI+AlyOfZvk+RltU6mVS4RKzd+Jxav+UKMeeqf4rG/T5b9T7wwXcx77wOx6uOdYvXmXY6vQ/jYAQDyCcJDPFGjiw6w5eXl9i5ZJSUlmqq4hAca5+V9BsjlVOsAT+zbKUw8+cIMcUHP3qKs0T7yevwAT332/uUfbPe8XvvjThRTbMGD/HHwPXLp9bUJH7spTJ5fAMgdCA/xRI2s4uJiUa9ePbWatkw+uPADNKHxHtn+OPGrcy509B9y6OFyuWzDdnl2gC6XljXS2+lMjAoKtPxJuyPFDTfd7goPtP7C1Hk6PJSUlMolnXlof9xJosMJPxXHHt/RcRvCx24Kk+cXAADqFjWyKioqRNeuXcWuXfLPBx01Y8YM/du3KpMPLvwAncrshWtdfVEZOOgOwcduCpPnFwAA6hY1vipO/5KbH6RN9fri9YKPHQAgn+Bli3iixld17NhRUpUv4WHE6Gf0ZXp/RGFRkWjdZn+5TsvGTZrqy6q/NvjYAQDyCcJDPFEjS/2VxfXXX6+6dPGXLFQfLUzED9DpDLjpdrEs8ZcXhL43Wp51zoU6PJx82hl6m9puv35ZWSOJ33c6fOwAAACmo0bWtm3bPEMC1ejRo139uRIeln2wXZ494OGhRj0dHi69sp9cHnb40Z73wfv84mMHAAAwHTW66HMczj77bHuXo/bu3asv50p4qGt87AAA+QQvW8QTNb6qSZMmjnWEh3DwsQMA5BOEh3iiRtYPp+p1l6PWrVsnqUJ4CAcfOwBAPkF4iCdqdJ111lnimGOOsXfp4sEC4SFza7YgPAAAQPxQ46hknzIZp/DwXMV614HaRDc9Mk/wsQMA5BOceYgnanxVnMIDmfXup66DtUmGPvOu4GMGAMg3CA/xRI2uZP+O+9FHH5VhoaioSPeZHh7IgAfnfjpwVKUwTf+Rs6fwsQIA5COEh3iiRhc/u5Cq4hAeAAAAIHzU6Nq+fbt91VFdunRxrCM8AAAA5CdqfNW9997rWEd4AACATOFli3iiRleqly34NoQHAADIFMJDPFHjKIQHAAAASIUaWY899piU7C8uEB4AACBsOPMQT9Q4Sv1rbnvt3LlTLi+66CLdh/AAAACZQniIJ2ocdfzxx/MuGRSOPPJIxz/HQngAAIBMITzEEzVpa9iwYaJ58+aidevWug/hAQAAMoXwEE/UyCouLtb8FMIDAABAfqJGFwWC0tJSe1fSQngAAIBM4cxDPFHjqEQoSFsIDwAAkCmEh3iiJlAhPAAAQKYQHuKJGl38rAOtAwAAADiooHDQQQdpfopuTAsAAICgCnDmIZaokVVZWakThZ9CeAAAgEwhPMQTNY7Cn2oCAEBUEB7iiRpd27dvt6+mLIQHAACA/ESNLrxsAQAAUcKZh3iixlEIDwAAEBWEh3iiRlarVq3URV+F8AAAAJlCeIgnanQtW7Ys6ZkH/pIGwgMAAEB+oiZtLVq0SIYFWqpCeAAAAMhP1Dhq69atvMuzEB4AACBTeNkinqjRtXfvXvuqozp06ICXLQAMZntp0bUNwFQID/FETaDCkxSAWawqxc8lAESBGl2231xc1atXL8c6nqQAzGPVYt4HABA2anRt2bIlaXjgwQLhASA81w9/7Re3Pr5AVG36XqzdsqfODB77luhz7/SOfHwA2YKXLeKJGl08INirrKxMUoXwABCOG0bOruYH8bq2atMuwccJkA0ID/FEja/iwQLhASAc/MBtioGjKgUfK0DYEB7iiRpZl112meZVCA8A4es78rUe/KBtipnvbhF8vAAAhBpHeb1soYKDPUAgPABkrn/57Dn8oN206b5yeUHPy10H9KDo55WWRUVFrm2p8PEChA1nHuKJGl2bNm3yDA9UjRo1cqwjPABkLlV4GDjoDnHn/aMd21SAX7N5l6jatNOx7arrbxT9fn+z6NK1u6P/3F9f7AgP9z/0hGP70g3bxF/GPe/oU/h4AcKG8BBP1Oiyn1lIVwgPAJlLFh7KyvaR4eHpCa86ttHPXePGTcXiNV+4wsOPDz1chodzft3L0c/Dwwkdf+7YTv76zMuuPsLHCxA2hId4osZX8WCB8ACQOa/wYBI+XgAAQo2v4h9djfAAkDmEB8h3OPMQT9ToOvDAAyWvwpkHgPCp8HDY4Ue5DtyceunBS6ptXhat3CKXTZvVvL/C7u3lm/VlPl6AsCE8xBM1unhAsFdhYaEYOHCgXkd4AMicPTwsXvuF+P2fhjgO5EOGPSw6de6qfzZVSJi9cI1ctmjZ2tGv0PsmeJ+y6uPvHOHBfr3lH2xHeIBIITzEEzW66KWJZOGBF8IDQObs4YF+pk474yx50Ka/gKAl9V1x7Q3i6GNO8AwPzVu0Sh4e6tXT61UfO99caQ8PbfY/UPe/U/UZwgMApEWNrMrKSv0k1LJlS9Wtq7i42BEsEB4AMmfyex7wMw5RsIr+66KrH8xGja5vvvlGLufMmWPvllVdXe1YxxMLQOZMDg/E+jk/XqHx8nV7H1/3exurfsyvw9chdxXgZYtYokZXQeLMAy/q27NHnsJ09NECAILLJDzQzyDvS8X+HzsbNCh2bffCxwsQNoSHeKJGV7Lw8Oyzz2qqEB4AMpcsPMx7/wO5pA91Uj+XtL7iox3i1bdWibYH/Ej39bz0Gtft7bdRVHigfgoP9evXl2+E5re14+MFACDU6Bo0aJBnePAqhAeAzCULD++u/lwueXhY/sE3YtrrS8V+bQ/QfVf1/b3r9qnCw8VX9JXhobSsTAy57xGx5pPdrtsrfLwAAISatKWeiOzBAuEBIHPJwoMp+HgBwlaAly1iiRpd/FMk7bVjxw75j7NUITwAZA7hAfIdwkM8UaNrzJgxkleVlJTgzANAyLIRHlaxz3RQ+MsYfvDxAoStAH9RE0vU6OIvTdhr4sSJYsiQIXod4QEgc37Cw6GHHyXuKR8rbh36oFiw4ocPcCKL13wunps0V15u2qy5XNL7Ipas2yovv7Vso1w2btxEh4cJ094Urfdr6/o6Xvh4AQAINbp2796dNDyUl5fLsw+qEB4AMucnPPT/w61yecYvz3FtIyo8qHBA4YGW9EbITp27yaX6xUDdplfva13344WPFyBseNkinqjxVfR+iHHjxul1hAeAzPkJD8r/3vGAq+/pCbPEzPkr9Hrva/qLlRu/k5cvubKvXPb93c3yslonI8f8zXVfXvh4AcKG8BBP1MiaPn26OPXUU9Wqq+ishL0QHgDCwQ/YprjjiYWCjxUgbAgP8USNLHVaM9nLFrwQHgDCMfPdmn9SZZrrhlecx8cKAECoSVudOnXSVCE8AISHH7jr2sBRlYKPESAbcOYhnqjR9fXXX4tevegfnKUvhAeA8PUrn/3GgPI579QVPh6AbEN4iCdqHEX/etur6tWr53hJA+EBAAAyhfAQT9ToOvjgg8WXX35p79LF3xOB8AAAAJCfqNFlDwdeReFCFcIDAABAfqJGFwWCl156yd6l+6urq119tAAAAAgKL1vEEzW6Pv/885RnHuzbEB4AACBTCA/xRI0u+iAoemOkn0J4AACATFnVgPeB+ajRtXXrVtfLE8kK4QEAACA/UeOoZH+qyQvhAQAAMoWXLeKJGl0UCO677z57V9JCeAAAgEwhPMQTNbq+//57+2rKQngAAIBMITzEEzW6KBAkQkHaQngAAADIT9TIqk1woEJ4AACATOHMQzxRI6uyslKcffbZajVtITwAAECmEB7iiZpAhfAAAACZQniIJ2oCFcIDAABAfqImUCE8AABApnDmIZ6o8VVVVVVi/Pjxeh3hAQAAMoXwEE/U+Kry8nLHOsIDAABkCuEhnqgJVAgPAAAA+YkaX3XdddepwCAL4QEAADJl1Y94H5iPGl/VvHlzhAcAAAgVXraIJ2rSFgUFxd5HCwAAgKAQHuKJmrTVuXNnTRXCAwAAQH6iJm21adMGZx4AAABAosZX7d69W+zcuVOvIzwAAECm8LJFPFHjq4qKinDmAQAgi6y6g/D+XIbwEE/UpK3NmzdrqhAeAADCZXt52LUtVyE8xBM1gSrfHuAAANlm1el4boU4oCZQ4QEOAACZwpmHeKImUCE8AACIgiUf7BBrt+wx1sBRlYKP2SQID/FEja8aMGCAKC4u1usIDwCQ7258+A3XwdpE/UfOfp6P3RQID/FEja+isIDwAADwA36QNtWfxswXfOwAmaDGV1FYSAQGvU4LAIB8xQ/Sprp9/ELBx24Kq7rxPjAfNb4K4QEAwIkfpE1leHjAyxYxRI2v6tWrlzjzzDP1OsIDAOQ7fpA2FcIDhI0aX9W/f39RWFio1xEeACDf8YN08+YtXQfusNFzr339vr+Md6yXlpbpy8ef9DO5NDk8QDxR46saNWrkWEd4AIB8pw7S+zRpKp8TKTw8+vRLommz5qJhwxLXgX/MUy/K691+70OubU9PnOUIBuWP/t0VFIh6CfmBh58Uqzfvcmx7/LlXZHhQt4tDeMCZh3iixle99NJLkiqEBwDId+qgPWL003KpzjzQ86M9PPT73WC57HlpH7Ff2/3l9hUffauvS8unJszU16dQ8MtuF4jCwiJHOFDXJ4cfdUzS8NC6jfU16tVDeICsocZXqQesfZ0WAAD5ih/YkznksCNcfVG6oM8QwcduCoSHeKLGVyE8AAA48YO0qejMg3oOV8/dfN3ex9eT3caqwwLchq93UreF+KAmbbHJ1n20AADIV/wgXVuD7xqpL3fp2t213etliyBMftkC4okaX7V06VLx+uuv63WEBwDId/wgXVsqPND7H+zh4fQzu4lfdDlbPs8u+c9W1+1qC+EBwkaNrxo2bJgoKyvT6wgPAJDv+EG6tig8nN/zcvHClDcc4aGoQQPxr7X/xZkHMBY1gQrhAQDyHT9I1xaFB3oupcslJaW6v0FxsVj18U6EBzAWNWmLHtwbN2509dECACBf8YO0qRAeIGzUpC28YRIAwI0fpE2F8ABhoyZQITwAQL7jB2lTITxA2KjxVdXV1Y51hAcAyHf8IG2qP42ZL/jYATJBja9av369pArhAQDyXf8Rc/7LD9Qm4uMGyBQ1vgrveQAAcBs4qtJ1sDZF5fIvRcEv7iziYwbIFDW+CuEBAAAACDW+CuEBAAAACDVpa/bs2QgPAAAAIFETqBAeAAAA8hM1vqpz586OdYQHAACA/ESNrxo6dKhjHeEBAAAgP1Hjq/CeBwAAACDU+CqEBwAAACDU+C6EBwAAAKAmbe3evVsu+/Tpo/sQHgAAAPITNWmLgkL79u1FkyZNHH20AAAAgPxCTdoaMmSIDA4tW7bUfQgPAAAA+YmaQIXwAAAAkJ+oCVQIDwAAAPmJmkCF8AAAAJCfqAlUCA8AAAD56f8B6yeobUii9R4AAAAASUVORK5CYII=>

[image2]: <data:image/png;base64,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jLlhEd3t1PX0008/ZL+elQk6QNciweWRxwZFoaY1J5zYj8ADNJiiT1OpgCNPUxUEnCG5kPP5i9YLxnz8yNRV/DaLB50pH+WCzu0/1COdtgg6QNey/wE9WkodwSlF1t9vvx7vy/YAdF2fj5gx+4vXZpuJI2aZz1+1XsmZOHy2+fxl23+5xYYbMSfkFAQc6zMbcj573pJjOm67xYOOhByvixRBB+ga9t3vwMm1BpzQgw8/ytEdoIv77NUZZsLw6Wb8sGlmnBhqDRHTzbiXppsJQ2aaz4bMsmzwGdISHcVJQ85zOROetZ6a9Zhst/Kgo693ouoKQWcWRXVg6f+PHUECyWMDn4jCSj3Itvfdt/ulJmO/ADqvsUO+axnz4rfmo+e/MaOe/cp8+MxX5oOnvjQfPvWVGf30N+ajZ741Y5+baj593oae52eY8S/MMhOen23DTUvBUZw04DzjPG2kygw6PtxkBZ9OVPUIOkl6aqG4X0f5eu+99/LLL7zwQkpXsX5Yn376qck9hpVX4fZaWlpKbr+tS+9/xAg581Pr9fXXX1f0NddaY8aMKbidEyZMCEYrK/31huV/3mLSpEnmu+++01PSktsjP7sqSv9/bBe77757Nwkhhx3RNwon9XTDjbdwZAfogj54eqJ596lxZsp4Y6aMcz41ZrLz6avfmPcGTjQfPvG1+fjJ78zYZ6aZT5+dacY/O9uGm5bCkGMDzvinrCdzyg46My5ZOA4+UkPXsdaac70Dq9qgY2sHCTiObKOfdbJ1onW8dZx1jPMP62jrKKuvdaR1mHWoJScs7O30tA6yulsHWvtb+/rbKjXPPPOklzNmzDBnn322uf/++8PhgkpyASy9/MUv5DQBuWVx7rnnmm+//bZgzv77758uH3fccQV9z5cs+wfMmTNnptfXXHPN9Pqiiy6akho/fry56aabCtafa6658strr722+f73v58fnz17dvpALcu/+c1von3L5UUXXWS+/PLLgp6UfH3LLbdcev2jjz4quI1yKdcPOuigNATober9hNv125HLu+66y5xyyimmd+/eBePLLrus2XHHHQvWXX311c2pp55asP7//d//5cf1/mXOaaedli4vtthimbdHrxOO+ZKw88orr+Tn+O+JnBzzP//5j9l4441Nt25yItA528n6niyxxBL5bSa5E2qW0q01splySeio51NU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XhJw0nBzWe4ozh/EJab7NheY/X7/X/OXzU8Lws24fLh5Qpz/qRnkRCEneKoqH3JGzwk5344yZsgtI82bd0w0Hz043Yx+cIacuyV/21oNOvmQ80wZIaeKoCOH+STYyOFaCTrS94cMr7rqqvS6vCBTLuWpLjmic8899xQNOwQdoGNkBR0xbPjLZtDgJ6Mg05pbb78rCi+VaMegA8AqCDhpuLnUHCS2syFn24vM/luflz5ltftvTiw4epMGnP5zAs7A88amvv5wRktrIScfcMQo50NjXr15nPnwvilG376iQWfyacELkHWgKaal/U7gllUEHaBj+KAj79SRF23qwDNq9Kgo0Gj33v9gFFqqQdAB2k+SbDZPLty4gGPDTY/tLjY9bMCRkCNPWe271Tnmr5ufah4668Po6I0PN4+f640xj/13TMUhRwy74RMz/LoJ8hZgdRszgk7LdbmjOS3PlXhNjjYs9zbAjiqCDtAxwqDj3w0mdOB57LGBUcC54MJLorBSC4IO0H78kZs54ebClJwnR0KOnBBwry3OMH/+Xb+MYDPGPP7fXLARj57zSeqRs8XHUcjRT1eFIWeS9cz/0k8biG5jHHRaZudCzgtlPl2ldWARdICOUSzoiIGDBheEHfkAztfffMNcefW1UUiph64edGbNmvWUoRq9op97VyVnN5YjN2G4OWCb880BW5+fPmUlR3PktTm7/fbEgiM2xcLNw2flPHSWCzplhpxJNsbceurAXvr2iTjoDN7OzH6uypBD0AGakg86EmRee+PNKOzIOynDsPPsc89HAaVeGinoyFul5a3F8tZuORVHErzt2Je8xVhOWhi+1TirstYtVuFceQu3nIulkvXrXfL1hVXqs+Yqva2l5sv4vffeW3KeL3l7vC4511dQ0c+9I8nXZb2v++UoCDhbzwk4+/3+3PQFyPtseZbZc7N/m103Pb71gONCjgSch878yDxo+ZP+5T1uv4/eY4FHc87q9UD+LeUhqYKgM/vKRePwUokOLIIO0DESF3TkPCs+zPiTzYXknDEEndb5oONPTidBR0o+2sWf8TYsOWu5vIFDzoor70z156yRN3vIuWT8g7N7MMtclnlyvjI5j45sz49Jyf579ZI/lHOl15UzCvtL3/NnfQ/nSklfrst5eORyoYUWSs+OXOx2+beKhz2Zf9ZZZ6XL/rYK//3yZ5k+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>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALMAAAE5CAYAAADbSBH5AAA7J0lEQVR4Xu2dB7gURdaGB0XXZQ24KOiq4KqYs5hdMxhWRUyYMCCuOaCuWQSVoILZFTPmhAKCuqKIkTUn9DeLATMCRhRD/fWe22dsunv6zp0702Fufc/z3b7d09NdXfN1dfWpU+cUCoXCKZZ3ODrmnKdZFh4wDg45h9XxeCdmh7qAE7ND3cCJ2aFu4MTsUDdwYnaoG1QsZvudIp988kmz4447mt122y24W9n45Zdf5Fjl4uSTTzavvvrqHNvatWsnx/jmm29k/aKLLjJ//vOf59gnDv5rGjlyZPDjqmHChAlznOuHH34I7tJkNOU6ozBixAgz99xzBzeXhYcffniO65k2bVpwl7Kx7bbbBjeVjUJzxOyHX8z33HOP2Wuvvczvv/9uvvjiC7m477//3nzwwQfy+fvvvy+fvf7666Z///4iZBVz3759zdixY2W/jz76SI554YUXyvqUKVPMt99+KyKea665zP33399wcg98f+ONNzaLL764rPvF/OWXX8pSz83yww8/NN99990c31fww+p+PXv2NL/99pvcJHvuuaf56quvZJ/Zs2dL+e69915ZZ58jjzzSXHDBBbL+888/y/r48eOLxwWIeZFFFpH/KStl5PqPO+44c/nll8t2zvH111+bYcOGmenTp8s2jkdZVCyU7frrrzfPPfec1A348ccfzT777FO8oT/++GP5PQYMGGCeeuopc8QRR0g5weGHH2569eolv42KmZtYfyduMq5v0qRJxfPNmDFDykDdKBDzwgsvLP9TJ9Qjn//666+y7+effy6f6XefeeaZ4vFmzZplBg0aVCxTamJWAhUzFULhuRg+QywsO3XqJEsucPfddzfbbbed6dKli4iMCvS3zBzjwQcfNC+99JIcp3PnzvK9+eabzxx44IGyjX38LTM/9AorrCCVosfxi3n//feXpVY0y8GDB8/xo7BNy8U59YehbJ9++mnxuEsttZQZPXq0ad++vXnkkUfM5MmTi/ty/qlTp8r2tm3byk3NdXAMBWKeZ555TNeuXeU7CIklokLAiOPggw82a6+9drFc/vqZf/75zTvvvCPriJVzcp3c6K1atZJ9WrdubWbOnFm8XuqGJb8T5+U7HHPUqFHSMGgZtG4Ax9bz6u/41ltvyT59+vRp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>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAYIAAAFbCAYAAADYy4luAAA75ElEQVR4Xu2dCbgUxb32h31RNpVVJWyCqCyBJApeFBU1McYloCKoREWTuD5Ro4aocYl7zAXjTdCYgNGPoCa5Kmpigku8ognuuCKKQlgChE2QRZb66q3T/7amumfOdE/PnOmZ932e36mlq5eprlPvdE91dSaTyShCCCE1TUZRFEVRtakhQ4bQCCiKompZNAKKoqgaF42AoiiqxkUjoCiKqnHRCMog+5d5ScdVoetu2rRJffLJJ1l5HTp0yFq/0G1NnTo18BmSVrHbb9mypZtVckWty7322suERx99dFa+/dn/67/+K2uZrUL2kUtx17WP7Y9//KOfl6tM2HJbK1euzLucahjRCMogt37tNOI7d+5Un3/+udqyZYvJc8OmTZuqrVu3+uVff/119fLLL5s01kXejh07TBxho0aN1EMPPaTmz59vyojsf1ZJQ+7+EMpxQTCCDRs2BNaROJb17t3bxKGJEyeqYcOG+eljjjlGLVq0yMTXrFmjGjdu7O9LJNtq27atCe3PBaH80qVL1X333WeWbd++3c+XEKAeZVsSSr3Yn/2qq65S/fv399eV/YkQP/HEE/3lH330UdZyKePGt23bllV3+Dx77723icuxukYA7bLLLn58v/32UyNGjDBxrDNv3jyzPVl/8eLFasKECSaOesAyGKH7GRHHtiS+ceNGde6552YtxxcGCNtGJ/3oo4/6y6UM9Mwzz/hx99yNHz8+K43laK+bN29Wffr08esWoRhB3759/XOLz2DXWbNmzVSPHj387WHZ008/7aep5EUjKINQv4Kkc4UffvihCR988MGsdQ444IBAWQidgqTtf6j//d//DVwRYNmTTz5pOnZJ5wrlnxJCeXTsAwYMCJSBCZxwwgl+Hhg9erRvTEijUxgzZoxfBnrnnXfqNu4J+fg2HHYshYToCLt06WLS2HfXrl3VwoULTQcGc2jXrp0pB5OEVq1apV599VW/YzrllFPU+vXrjWmtXbvWlBk7dmzWPv75z39mdUjyeQVIzFc+DzpfCMeU64oAEiM4+OCDTYi622effVSTJk2M8UPYJvKPO+44/1w//PDDasqUKWr48OHm+KCePXv6HTw+47p167Lq65BDDvE/o1uPEorsdL4yAPUs6QMPPFD96Ec/Chiz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>

[image5]: <data:image/png;base64,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>

[image6]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgYAAAIYCAYAAAAW4yRLAABjDklEQVR4XuydB5jc1Nm2j3s3LnSwDTYldBJ67ySE9tFbgAAfJJQACYQQAsa0D0wLCRBqKIFQQn5qCBAIoRvTTIjBxhRjCMY27r2fX89ZvfKZI2lWmp31rnSe57runaNXR2WadI+knVFKKU1IC3OS1loRP0h4/kkz4D7uhGQF0QzTUjniiCPwKqQYeAS3Oc0figFpCnyTMi0aioF/cJvT/KEYkKbANynToqEY+Ae3Oc0figFpCnyTMi0aioF/cJvT/KEYkKbANynToqEY+Ae3Oc0figFpCnyTMi0aioF/cJvT/KEYkKbANynToqEY+Ae3Oc0figFpCnyT1iHt2rVzS0zGUAz8g9uc5g/FgDQFL9+kDz30kF68eLFb1s8++6yeP3++W240eR/DCy+80C2ZTJo0SS9ZssQtlzoUA//I+35h8odiQJqCV2/Ss846y7xhvv/971fUx44dqzt37qx32mmnqIZ+wn777RfVTz/99KgOiTjmmGOiYeSTTz6Jhk899VRTGzlypN5iiy2i+gUXXGBu11133Wi+yNKlS019lVVW0dOmTasYV9ZQDPxD3itM8yV8jGOPPSFZKP2bVHa2m222mTvK1NdZZ53Yp/TRo0dXDMtjtNJKK+m77rorqvfu3bti/JgxYypOK9x222164MCBRgzatm0b1e1AOjD91KlTK+qQDizv+eefr6iXLRQD/yj7Nqc1hGJAmoIXb9Itt9zSvFFefvllIwqS/fff39RXX311PWXKFGsKrUeMGFFxdABJe6ykfv755+vDDz88qs+aNcuMgxj069cvqksgEhg/aNCgCjn58ssvzREMjJs3b541RflCMfCPtPcRU79QDEhT8OpNusMOO5g3TM+ePSsEYfbs2bpXr15mZ4z6Y489pvfYY4/oOgRbDOxrE8aNGxcdkUAuv/xyveuuu0bjJ06cmCgGBx98sKn3798/qiGLFi0y9VVXXdW0fQjFwD982ua0VCgGpCl4+SadM2dO4sWHCxYsMIfwN95446gmO2sEO7H11lvPtDG9LQxuDYGIHHLIITExwJGLpEyePNktlT4UA/+oxzbniy++qHivSeRanmo57rjj3FIsEP5zzjnHzGv48OEVHySKEIoBaQp1eZOWMX379jWf3BFsICTYQKy4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>

[image7]: <data:image/png;base64,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>

[image8]: <data:image/png;base64,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>