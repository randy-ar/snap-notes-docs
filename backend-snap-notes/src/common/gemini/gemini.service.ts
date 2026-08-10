import { Injectable, UnprocessableEntityException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';

export interface ParsedItemDto {
  nama: string;
  jumlah: number;
  harga_satuan: number;
  subtotal: number;
  kategori?: string;
}

export interface ParsedStrukDto {
  nama_toko: string;
  tanggal: string;
  total: number;
  kategori_toko?: string;
  item: ParsedItemDto[];
}

interface OcrLine {
  lineIndex: number;
  text: string;
  boundingBox: {
    left: number;
    top: number;
    right: number;
    bottom: number;
  };
}

interface ImageSize {
  width: number;
  height: number;
}

const STRUK_JSON_SCHEMA = {
  type: 'object',
  properties: {
    nama_toko: {
      type: 'string',
      description: 'Nama toko atau merchant pada struk.',
    },
    tanggal: {
      type: 'string',
      description: 'Tanggal transaksi dalam format YYYY-MM-DD.',
    },
    total: {
      type: 'number',
      description: 'Total keseluruhan struk (angka tanpa pemisah ribuan).',
    },
    kategori_toko: {
      type: 'string',
      description:
        'Kategori toko (opsional): Makanan & Minuman, Perumahan & Utilitas, Komunikasi, Transportasi, Kesehatan, Pendidikan, Hiburan, Perawatan Pribadi, Pakaian, Lain-lain.',
    },
    error: {
      type: 'string',
      description:
        'Isi field ini jika gambar tidak jelas dan item tidak dapat diidentifikasi. Kosongkan jika berhasil.',
    },
    item: {
      type: 'array',
      description: 'Daftar item pada struk.',
      items: {
        type: 'object',
        properties: {
          nama: { type: 'string', description: 'Nama item/produk.' },
          jumlah: { type: 'integer', description: 'Jumlah/qty item.' },
          harga_satuan: { type: 'number', description: 'Harga per satuan item.' },
          subtotal: { type: 'number', description: 'jumlah * harga_satuan.' },
          kategori: {
            type: 'string',
            description: 'Kategori item (opsional).',
          },
        },
        required: ['nama', 'jumlah', 'harga_satuan', 'subtotal'],
      },
    },
  },
  required: ['nama_toko', 'tanggal', 'total', 'item'],
};

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
    this.model = 'gemini-2.5-flash';
  }

  async parseStrukOCR(rawText: string): Promise<ParsedStrukDto> {
    try {
      const prompt = this.buatPrompt(rawText);

      const geminiPromise = this.genAI.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
        config: {
          responseMimeType: 'application/json',
          responseSchema: STRUK_JSON_SCHEMA,
        },
      });

      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('Gemini AI timeout')), 28000);
      });

      const response = await Promise.race([geminiPromise, timeoutPromise]);

      const text = response.text;
      console.log('[Gemini AI] Raw response:', text);
      if (!text) {
        throw new ServiceUnavailableException('Gemini AI tidak memberikan response');
      }

      return this.validasiResponse(text);
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnprocessableEntityException) {
        throw error;
      }
      if (error.message === 'Gemini AI timeout') {
        throw new ServiceUnavailableException('Gemini AI timeout - coba lagi dengan struk yang lebih jelas');
      }
      throw new ServiceUnavailableException(`Gemini AI error: ${error.message}`);
    }
  }

  private buatPrompt(rawText: string): string {
    const currentDate = new Date().toISOString().split('T')[0];

    return `Anda adalah parser struk belanja berbasis penalaran hierarkis & matematika finansial. Analisis teks OCR berikut dan ekstrak informasi struk ke format JSON.
TEKS OCR:
"""
${rawText}
"""

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

Aturan WAJIB:
1. SELALU kembalikan semua field yang dibutuhkan (\`nama_toko\`, \`tanggal\`, \`total\`, \`totalItem\`, \`diskon\`, \`item\`).
2. Jika nama_toko tidak ditemukan, gunakan "Tidak diketahui".
3. Jika tanggal tidak ditemukan dalam teks, gunakan tanggal hari ini: ${currentDate} (format YYYY-MM-DD).
4. Jika tidak ada item produk sama sekali yang bisa diidentifikasi, return JSON dengan error message di field "error": "Gambar struk tidak jelas, mohon upload ulang".
5. Harga/nominal berupa angka (number) tanpa pemisah ribuan.
6. Kategori bisa: Makanan & Minuman, Perumahan & Utilitas, Komunikasi, Transportasi, Kesehatan, Pendidikan, Hiburan, Perawatan Pribadi, Pakaian, Lain-lain.`;
  }

  private validasiResponse(response: string): ParsedStrukDto {
    try {
      const parsed = JSON.parse(response) as ParsedStrukDto & { error?: string };

      // Cek jika AI mengembalikan error message
      if (parsed.error) {
        throw new UnprocessableEntityException(parsed.error);
      }

      if (!parsed.nama_toko || !parsed.tanggal || typeof parsed.total !== 'number') {
        throw new UnprocessableEntityException('Format JSON dari AI tidak lengkap');
      }

      if (!Array.isArray(parsed.item) || parsed.item.length === 0) {
        throw new UnprocessableEntityException('JSON tidak memiliki array item yang valid');
      }

      for (const item of parsed.item) {
        if (!item.nama || typeof item.jumlah !== 'number' || typeof item.harga_satuan !== 'number') {
          throw new UnprocessableEntityException('Format item dalam JSON tidak valid');
        }
        if (!item.subtotal) {
          item.subtotal = item.jumlah * item.harga_satuan;
        }
      }

      return parsed;
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw error;
      }
      throw new UnprocessableEntityException(`Response AI tidak valid JSON: ${error.message}`);
    }
  }
}
