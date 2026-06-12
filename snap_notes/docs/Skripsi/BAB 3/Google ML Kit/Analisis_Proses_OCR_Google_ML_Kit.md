### 3.X Analisis Proses Ekstraksi Teks (OCR) Menggunakan Google ML Kit

Teknologi Google ML Kit Text Recognition diterapkan pada aplikasi klien (Flutter) untuk memfasilitasi ekstraksi teks dari gambar struk belanja secara *on-device*. Pemrosesan yang dilakukan secara lokal ini dirancang sebagai solusi untuk menyelesaikan permasalahan inefisiensi dalam pencatatan pengeluaran (**PS-02**). Dengan kemampuan membaca teks secara instan tanpa membutuhkan koneksi ke *server* eksternal, proses OCR ini memastikan waktu respons aplikasi yang jauh lebih cepat sekaligus menjaga keamanan serta privasi data gambar pengguna.

Berikut adalah rincian tahapan spesifik dari proses ekstraksi teks OCR, mulai dari penerimaan *input* gambar, pemanggilan pustaka (*library*), hingga pembentukan hasil *output*:

1. **Penerimaan Data Input (Gambar Struk)**
   Proses dimulai ketika aplikasi klien menerima *input* representasi gambar struk belanja. Gambar ini bersumber dari jepretan kamera secara langsung atau tangkapan gambar dari galeri penyimpanan lokal perangkat. Dalam implementasi teknisnya pada platform Flutter, gambar tersebut ditampung sementara dalam bentuk tipe data `File` atau `XFile`.
   
2. **Prapemrosesan dan Konversi ke Format `InputImage`**
   Sebelum gambar dapat diproses oleh *engine* dari Google ML Kit, *file* gambar mentah tersebut harus dikonversi menjadi objek berkelas `InputImage`. Konversi ini dilakukan dengan memanggil *method* bawaan `InputImage.fromFile(file)` atau `InputImage.fromFilePath(path)`. Objek `InputImage` berfungsi sebagai wadah (*wrapper*) yang merangkum *byte array* dari piksel gambar beserta metadatanya (seperti rotasi derajat perangkat) yang sangat krusial bagi akurasi model *Machine Learning*.

3. **Inisialisasi Modul `TextRecognizer`**
   Selanjutnya, aplikasi menginisialisasi pustaka `google_mlkit_text_recognition` dengan cara menginstansiasi *class* `TextRecognizer`. Saat pemanggilan *constructor*, skrip bahasa yang akan dideteksi dideklarasikan. Mengingat format cetak struk belanja pada umumnya memakai abjad biasa, sistem dikonfigurasi untuk membaca alfabet Latin melalui argumen `TextRecognizer(script: TextRecognitionScript.latin)`.

4. **Eksekusi Pengenalan Teks (*Method* `processImage`)**
   Objek `InputImage` yang telah dipersiapkan kemudian dilemparkan sebagai parameter ke dalam sebuah *method asynchronous* bernama `processImage(inputImage)`. Pada tahap krusial ini, model inferensi ML Kit langsung mengambil alih operasi komputasi di tingkat perangkat (*on-device*) untuk memindai kontur setiap karakter, memisahkan rupa huruf menjadi kata, dan mengidentifikasi untaian teks utuh di dalam gambar struk.

5. **Ekstraksi Hasil Output (`RecognizedText`)**
   Setelah masa inferensi algoritma selesai, nilai kembalian (*return value*) yang dihasilkan adalah sebuah objek hierarkis bernama `RecognizedText`. Objek hasil OCR ini memiliki turunan terstruktur yang terdiri dari:
   - `TextBlock`: Objek yang mengelompokkan area atau paragraf teks secara utuh.
   - `TextLine`: Objek yang menampung setiap baris teks dari sebuah *block*.
   - `TextElement`: Objek referensi terkecil yang merepresentasikan satu kata.
   Aplikasi kemudian mengekstrak *property* induk `recognizedText.text` untuk segera menyatukan (*concatenate*) seluruh elemen teks hasil pembacaan tersebut menjadi satu kesatuan tipe data *string* mentah (*raw text*). Data inilah yang pada tahapan selanjutnya akan dikirimkan menuju *server* untuk dirapikan (*parsing*) oleh Google Gemini AI.

6. **Pelepasan Sumber Daya (Pemanggilan `close`)**
   Pada langkah terakhir, demi merawat stabilitas performa aplikasi dan menghindari terjadinya kebocoran memori (*memory leak*), *method* `close()` pada *instance* dari `TextRecognizer` wajib dieksekusi. Tindakan preventif ini membebaskan sumber daya pengolahan CPU perangkat keras dan Random Access Memory (RAM) yang sebelumnya dialokasikan paksa bagi *engine* ML Kit.

---

### Algoritma Deskriptif Alur Proses OCR

Berdasarkan *flowchart* UML, logika bisnis dan alur komputasi dijabarkan secara mengalir ke dalam enam langkah bernomor sebagai berikut:

1. Proses OCR diawali pada saat aplikasi **menerima gambar struk belanja** hasil jepretan kamera maupun sisipan dari pustaka galeri yang diinisiasi oleh pengguna dari peranti lunak antarmuka.
2. Gambar mentah bertipe file dasar tersebut lalu dilemparkan ke unit prapemrosesan untuk **diubah tipe datanya menjadi format `InputImage`**. Pengemasan ulang ini diperlukan agar bit gambar dapat dipahami dan diterima secara spesifik oleh kerangka kerja Google ML Kit.
3. Setelah *payload* gambar berhasil disiapkan, sistem menyalakan perangkat pendeteksi dengan **menginisialisasi modul `TextRecognizer`**. Komponen ini diberi tugas dan argumen parameter secara presisi untuk menyeleksi pola skrip atau aksara berbentuk Latin.
4. Inti pengolahan kecerdasan komputasi dimulai tatkala aplikasi **menjalankan fungsi `processImage()` secara *on-device***. Model cerdas yang disematkan menelusuri piksel gambar, menandai *bounding box* di sekitar rupa bentuk abjad, dan menerjemahkan grafis struk ke dalam makna tekstual tanpa jeda perpindahan data melalui internet.
5. Selesainya proses deteksi algoritma akan melahirkan sebuah kelas data abstrak baru. Dari kelas data ini, aplikasi **mengekstrak dan menggabungkan seluruh nilai variabel dari objek `RecognizedText`** hingga menjadi satu rangkaian utuh *string* murni (*raw text*) bertindak sebagai *output* akhir pada modul klien ini.
6. Sebelum aplikasi benar-benar berpindah layar kerja untuk menyalurkan *raw text* menuju antarmuka antrean *server*, klien memastikan efisiensi perangkat seluler berlanjut sehat dengan **menutup modul `TextRecognizer` untuk membebaskan memori** yang sedari tadi ditahan di dalam ekosistem sistem operasi Flutter.
