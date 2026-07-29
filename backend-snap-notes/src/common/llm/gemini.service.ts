import { Injectable, UnprocessableEntityException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import {
  ILLMProvider,
  ParsedStrukDto,
  OcrLine,
  ImageSize,
} from './llm-provider.interface';

export type { ParsedItemDto, ParsedStrukDto } from './llm-provider.interface';

@Injectable()
export class GeminiService implements ILLMProvider {
  private genAI: GoogleGenAI;
  private model: string;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY harus diatur di environment variables');
    }
    this.genAI = new GoogleGenAI({ apiKey });
    this.model = this.configService.get<string>('GEMINI_MODEL') || 'gemini-2.5-flash';
  }

  async parseStrukOCRBatch(ocrDataBatch: any[], customPrompt?: string, kategoriContext?: string): Promise<ParsedStrukDto[]> {
    const startTime = Date.now();
    try {
      const prompt = this.buatPromptBatch(ocrDataBatch, customPrompt, kategoriContext);

      const geminiPromise = this.genAI.models.generateContent({
        model: this.model,
        contents: prompt,
      });

      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('Gemini AI timeout')), 50000); // 50 seconds for batch processing
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

  private buatPromptBatch(ocrDataBatch: any[], customPrompt?: string, kategoriContext?: string): string {
    let batchInfo = '';

    ocrDataBatch.forEach((ocrData, index) => {
      let layoutInfo = '';
      if (ocrData.lines && ocrData.lines.length > 0 && ocrData.imageSize) {
        const lineInfo = ocrData.lines.map((line: any) => {
          const centerX = (line.boundingBox.left + line.boundingBox.right) / 2;
          const centerY = (line.boundingBox.top + line.boundingBox.bottom) / 2;
          const relativeX = (centerX / ocrData.imageSize.width * 100).toFixed(1);
          const relativeY = (centerY / ocrData.imageSize.height * 100).toFixed(1);
          const textPreview = line.text.substring(0, 40);
          const ellipsis = line.text.length > 40 ? '...' : '';
          return `[${line.lineIndex}] X:${relativeX}% Y:${relativeY}% | "${textPreview}${ellipsis}"`;
        }).join('\n');

        layoutInfo = `INFO LAYOUT LINE POSISI:\n${lineInfo}\n`;
      }

      batchInfo += `\n--- STRUK ${index + 1} ---\nTEKS OCR:\n"""\n${ocrData.rawText}\n"""\n${layoutInfo}`;
    });

    const currentDate = new Date().toISOString().split('T')[0];

    return `Anda adalah parser struk belanja. Analisis ${ocrDataBatch.length} teks OCR berikut dan ekstrak informasi setiap struk ke format array JSON.

DATA BATCH OCR:
${batchInfo}

${customPrompt ? `KONTEKS TAMBAHAN DARI USER UNTUK KOREKSI:\n"""\n${customPrompt}\n"""\n` : ''}
Ekstrak informasi seluruh struk dalam format Array JSON yang berisi objek-objek struk dengan urutan yang sama (dari struk 1 hingga ${ocrDataBatch.length}):
[
  {
    "nama_toko": "Nama toko/merchant",
    "tanggal": "YYYY-MM-DD",
    "total": 0,
    "totalItem": 0,
    "diskon": 0,
    "kategori_toko": "Kategori toko (opsional)",
    "item": [
      {
        "nama": "Nama item",
        "jumlah": 1,
        "harga_satuan": 0,
        "diskon": 0,
        "subtotal": 0,
        "kategori": "Pilihan dari 10 kategori di bawah"
      }
    ]
  },
  ...
]

Aturan Kategori Pengeluaran:
Kamu HANYA diizinkan mengklasifikasikan item ke dalam salah satu dari 10 kategori persis berikut (jangan membuat kategori baru):
1. "Makanan & Minuman"
2. "Perumahan & Utilitas"
3. "Komunikasi"
4. "Transportasi"
5. "Kesehatan"
6. "Pendidikan"
7. "Hiburan"
8. "Perawatan Pribadi"
9. "Pakaian"
10. "Lain-lain"

Aturan WAJIB:
1. Kembalikan array JSON berisi persis ${ocrDataBatch.length} object struk (sesuai jumlah struk pada input).
2. Jika ada struk yang teksnya tidak jelas atau kosong, kembalikan object tersebut dengan array item kosong dan error: "error": "Gambar struk tidak jelas". Namun struktur lainnya (nama_toko dsb) tetap isi sebisanya.
3. Selalu isi field nama_toko, tanggal, total, totalItem, diskon, dan item. Untuk field diskon (baik pada struk maupun item), isi 0 jika tidak ada diskon.
4. Jika nama_toko tidak ditemukan, gunakan "Tidak diketahui".
5. Jika tanggal tidak ditemukan dalam teks, gunakan tanggal hari ini: ${currentDate}
6. Tanggal harus format YYYY-MM-DD.
7. totalItem (total kotor) adalah jumlah dari semua subtotal item. total (total bersih) adalah totalItem - diskon keseluruhan. Jika field total tidak tertera dengan jelas, hitung secara manual.
8. Harga dalam format number tanpa pemisah ribuan.
9. Diskon per item (pada array "item") BUKAN diskon keseluruhan. Jika sebuah item dipotong harga, masukkan nilai potongannya pada properti "diskon" miliknya.
10. Pastikan (jumlah * harga_satuan) - diskon = subtotal untuk setiap item.
11. Return HANYA JSON array, tanpa markdown atau string tambahan lain.`;
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
           // It's allowed to have an error state, it will be handled upstream or returned empty
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
      throw new UnprocessableEntityException(`Response AI tidak valid JSON array: ${error.message}`);
    }
  }
}
