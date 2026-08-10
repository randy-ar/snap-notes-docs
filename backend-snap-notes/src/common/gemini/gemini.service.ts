import { Injectable, UnprocessableEntityException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI, Type, Schema } from '@google/genai';

export interface ParsedItemDto {
  nama: string;
  jumlah: number;
  harga_satuan: number;
  diskon?: number;
  subtotal: number;
  kategori?: string;
}

export interface ParsedStrukDto {
  nama_toko: string;
  tanggal: string;
  total: number;
  totalItem?: number;
  diskon?: number;
  kategori?: string;
  kategori_toko?: string;
  error?: string;
  item: ParsedItemDto[];
}

export interface OcrDataPayload {
  rawText: string;
  imageSize?: { width: number; height: number };
  lines?: any[];
}

@Injectable()
export class GeminiService {
  private genAI: GoogleGenAI;
  private model: string;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY harus diatur di environment variables');
    }
    this.genAI = new GoogleGenAI({ apiKey });
    this.model = this.configService.get<string>('GEMINI_MODEL') || 'gemini-3.6-flash';
  }

  async parseStrukOCRBatch(ocrDataBatch: OcrDataPayload[], customPrompt?: string, kategoriContext?: string): Promise<ParsedStrukDto[]> {
    const startTime = Date.now();
    try {
      const prompt = this.buatPromptBatch(ocrDataBatch, customPrompt, kategoriContext);

      const responseSchema: Schema = {
        type: Type.ARRAY,
        items: {
          type: Type.OBJECT,
          properties: {
            nama_toko: { type: Type.STRING, description: 'Nama toko/merchant' },
            tanggal: { type: Type.STRING, description: 'Tanggal belanja (YYYY-MM-DD)' },
            total: { type: Type.NUMBER, description: 'Total belanja keseluruhan' },
            totalItem: { type: Type.NUMBER, description: 'Total akumulasi seluruh item' },
            diskon: { type: Type.NUMBER, description: 'Diskon/voucher pada level struk' },
            kategori: { type: Type.STRING, description: 'Kategori pengeluaran' },
            error: { type: Type.STRING, description: 'Pesan kesalahan jika struk tidak jelas' },
            item: {
              type: Type.ARRAY,
              items: {
                type: Type.OBJECT,
                properties: {
                  nama: { type: Type.STRING, description: 'Nama item' },
                  jumlah: { type: Type.NUMBER, description: 'Jumlah item' },
                  harga_satuan: { type: Type.NUMBER, description: 'Harga satuan item' },
                  diskon: { type: Type.NUMBER, description: 'Diskon per item' },
                  subtotal: { type: Type.NUMBER, description: 'Subtotal per item' },
                  kategori: { type: Type.STRING, description: 'Kategori per item' },
                },
                required: ['nama', 'jumlah', 'harga_satuan', 'subtotal'],
              },
            },
          },
          required: ['nama_toko', 'tanggal', 'total', 'item'],
        },
      };

      const geminiPromise = this.genAI.models.generateContent({
        model: this.model,
        contents: prompt,
        config: {
          responseMimeType: 'application/json',
          responseSchema,
        },
      });

      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('Gemini AI timeout')), 50000);
      });

      const response = await Promise.race([geminiPromise, timeoutPromise]);

      const text = response.text;
      const endTime = Date.now();
      console.log(`[Gemini AI Batch] Received raw response in ${endTime - startTime}ms`);
      console.log('[Gemini AI Batch] Raw response:', text);
      if (!text) {
        throw new ServiceUnavailableException('Gemini AI tidak memberikan response');
      }

      return this.validasiResponseBatch(text);
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnprocessableEntityException) {
        throw error;
      }
      if ((error as Error).message === 'Gemini AI timeout') {
        throw new ServiceUnavailableException('Gemini AI timeout - coba lagi dengan batch yang lebih kecil');
      }
      throw new ServiceUnavailableException(`Gemini AI error: ${(error as Error).message}`);
    }
  }

  private buatPromptBatch(ocrDataBatch: OcrDataPayload[], customPrompt?: string, kategoriContext?: string): string {
    let batchInfo = '';

    ocrDataBatch.forEach((ocrData, index) => {
      let layoutInfo = '';
      if (ocrData.imageSize && ocrData.imageSize.width && ocrData.imageSize.height) {
        layoutInfo += `UKURAN GAMBAR STRUK: ${ocrData.imageSize.width}px x ${ocrData.imageSize.height}px (width x height)\n`;
      }
      if (ocrData.lines && Array.isArray(ocrData.lines) && ocrData.lines.length > 0) {
        layoutInfo += `STRUKTUR LINES OCR DENGAN KOORDINAT BOUNDING BOX (JSON):\n"""\n${JSON.stringify(ocrData.lines)}\n"""\n`;
      }

      batchInfo += `\n--- STRUK ${index + 1} ---\nTEKS OCR:\n"""\n${ocrData.rawText}\n"""\n${layoutInfo}`;
    });

    const currentDate = new Date().toISOString().split('T')[0];

    return `Anda adalah parser struk belanja berbasis penalaran hierarkis & matematika finansial. Analisis ${ocrDataBatch.length} teks OCR berikut dan ekstrak informasi setiap struk ke format array JSON.

DATA BATCH OCR:
${batchInfo}

${customPrompt ? `KONTEKS TAMBAHAN DARI USER UNTUK KOREKSI:\n"""\n${customPrompt}\n"""\n` : ''}

METODOLOGI EKSTRAKSI KONTEKSTUAL (BERHAP):
1. **Analisis Informasi Kunci Per Item (Array \`item\`)**:
   - Ekstrak setiap item transaksi: nama item, jumlah (qty), harga_satuan, diskon (jika ada potongan per item), dan subtotal.
   - Formula per item: subtotal = (jumlah * harga_satuan) - diskon.

2. **Kerucutkan ke Total Item (\`totalItem\`)**:
   - Hitung total kotor dari seluruh item: \`totalItem\` = penjumlahan seluruh \`subtotal\` dari item di array \`item\`.
   - Pastikan nilai \`totalItem\` konsisten dengan jumlah akumulasi subtotal array \`item\`.

3. **Kerucutkan ke Total Belanja (\`total\`)**:
   - \`diskon\` pada level struk adalah diskon/voucher/potongan transaksi secara keseluruhan.
   - Formula Total Belanja: \`total\` = \`totalItem\` - \`diskon\`.
   - Jika terdapat selisih pembulatan, biaya admin, biaya penanganan, kantong plastik/kresek, atau biaya membingungkan lainnya yang membuat \`total\` pada struk tidak sesuai dengan hitungan di atas, **MASUKKAN SELISIH BIAYA TERSEBUT SEBAGAI ITEM BARU** ke dalam array \`item\` dengan nama \`"Biaya lainnya"\` (kategori \`"Lain-lain"\`, jumlah 1, subtotal sesuai selisih).
	   - Pastikan secara mutlak matematika perhitungan konsisten: penjumlahan seluruh subtotal item = \`totalItem\`, dan \`totalItem\` - \`diskon\` = \`total\`.

${kategoriContext ? `${kategoriContext}\n` : `Aturan Kategori Pengeluaran (Standar Turunan Kelompok Komoditas Konsumsi BPS):
Kamu HANYA diizinkan mengklasifikasikan item ke dalam salah satu dari 10 kategori persis berikut (jangan membuat kategori baru):
1. "Makanan & Minuman" (Kelompok Makanan BPS: pangan harian, bumbu, bahan mentah, olahan, minuman, tembakau)
2. "Perumahan & Utilitas" (Kelompok Bukan Makanan BPS: operasional tempat tinggal, sewa, listrik, air, gas LPG)
3. "Komunikasi" (Kelompok Bukan Makanan BPS: pulsa, paket data, tagihan telepon, internet, ongkos kirim)
4. "Transportasi" (Kelompok Bukan Makanan BPS: mobilisasi, bensin, tol, parkir, tiket transportasi)
5. "Kesehatan" (Kelompok Bukan Makanan BPS: pengeluaran medis, obat-obatan, vitamin, rumah sakit/klinik)
6. "Pendidikan" (Kelompok Bukan Makanan BPS: investasi edukasi, buku, uang sekolah/kuliah, alat tulis, kursus)
7. "Hiburan" (Kelompok Bukan Makanan BPS: rekreasi, gaya hidup, hobi, bioskop, langganan streaming)
8. "Perawatan Pribadi" (Kelompok Bukan Makanan BPS: higienitas diri, sabun, sampo, kosmetik, skincare)
9. "Pakaian" (Kelompok Bukan Makanan BPS: kebutuhan sandang, baju, celana, alas kaki, jilbab/topi)
10. "Lain-lain" (Kelompok Bukan Makanan BPS: pengeluaran eksternal/sosial, pajak, asuransi, barang tahan lama)
`}
Aturan WAJIB:
1. Kembalikan array JSON berisi persis ${ocrDataBatch.length} object struk.
2. Jika ada struk yang teksnya tidak jelas atau kosong, kembalikan object tersebut dengan array item kosong dan error: "error": "Gambar struk tidak jelas".
3. Selalu isi field nama_toko, tanggal, total, totalItem, diskon, dan item. Untuk field diskon (baik pada struk maupun item), isi 0 jika tidak ada.
4. Jika nama_toko tidak ditemukan, gunakan "Tidak diketahui".
5. Jika tanggal tidak ditemukan, gunakan tanggal hari ini: ${currentDate} (format YYYY-MM-DD).
6. Harga/nominal berupa angka (number) tanpa pemisah ribuan.
7. Return HANYA JSON array murni, tanpa markdown (\`\`\`json) atau teks tambahan lain.`;
  }

  private validasiResponseBatch(response: string): ParsedStrukDto[] {
    try {
      const cleaned = response.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const parsedArray = JSON.parse(cleaned);

      if (!Array.isArray(parsedArray)) {
        throw new UnprocessableEntityException('Response AI bukan berupa array JSON');
      }

      for (let i = 0; i < parsedArray.length; i++) {
        const parsed = parsedArray[i];

        if (parsed.error && (!parsed.item || parsed.item.length === 0)) {
           continue;
        }

        if (!parsed.nama_toko) parsed.nama_toko = 'Tidak diketahui';
        if (!parsed.tanggal) parsed.tanggal = new Date().toISOString().split('T')[0];
        if (typeof parsed.total !== 'number') parsed.total = 0;
        if (parsed.totalItem === undefined || typeof parsed.totalItem !== 'number') parsed.totalItem = parsed.total;
        if (parsed.diskon === undefined || typeof parsed.diskon !== 'number') parsed.diskon = 0;

        if ((parsed as any).items && Array.isArray((parsed as any).items) && !parsed.item) {
          parsed.item = (parsed as any).items;
        }
        if (!Array.isArray(parsed.item)) {
          parsed.item = [];
        }

        for (const item of parsed.item) {
          if (!item.nama) item.nama = "Unknown Item";
          if (typeof item.jumlah !== 'number') item.jumlah = 1;
          if (typeof item.harga_satuan !== 'number') item.harga_satuan = 0;
          if (item.diskon === undefined || typeof item.diskon !== 'number') item.diskon = 0;
          if (!item.subtotal) {
            item.subtotal = (item.jumlah * item.harga_satuan) - item.diskon;
          }
        }
      }

      return parsedArray;
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw error;
      }
      throw new UnprocessableEntityException(`Response AI tidak valid JSON array: ${(error as Error).message}`);
    }
  }
}
