import { Injectable, UnprocessableEntityException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ILLMProvider,
  ParsedStrukDto,
  OcrLine,
  ImageSize,
} from './llm-provider.interface';

interface OpenRouterMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface OpenRouterResponse {
  choices: {
    message: {
      content: string;
    };
  }[];
  error?: {
    message: string;
  };
}

@Injectable()
export class OpenRouterService implements ILLMProvider {
  private readonly apiKey: string;
  private readonly model: string;
  private readonly timeoutMs: number;
  private readonly apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('OPENROUTER_API_KEY');
    if (!apiKey) {
      throw new Error('OPENROUTER_API_KEY harus diatur di environment variables');
    }
    this.apiKey = apiKey;
    this.model = this.configService.get<string>('OPENROUTER_MODEL') || 'google/gemini-1.5-flash';
    this.timeoutMs = this.configService.get<number>('OPENROUTER_TIMEOUT_MS') || 28000;
  }

  async parseStrukOCRBatch(ocrDataBatch: any[], customPrompt?: string, kategoriContext?: string): Promise<ParsedStrukDto[]> {
    try {
      const prompt = this.buatPromptBatch(ocrDataBatch, customPrompt, kategoriContext);
      const messages: OpenRouterMessage[] = [
        {
          role: 'system',
          content: 'Anda adalah parser struk belanja yang mengkonversi teks OCR menjadi JSON terstruktur. Selalu kembalikan JSON array valid tanpa markdown.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ];

      const openRouterPromise = this.callOpenRouter(messages);
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('OpenRouter timeout')), this.timeoutMs * 1.5);
      });

      const response = await Promise.race([openRouterPromise, timeoutPromise]);

      const text = response.choices?.[0]?.message?.content;
      console.log('[OpenRouter Batch] Raw response:', text);

      if (!text) {
        throw new ServiceUnavailableException('OpenRouter tidak memberikan response');
      }

      return this.validasiResponseBatch(text, ocrDataBatch.length);
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnprocessableEntityException) {
        throw error;
      }
      if (error.message === 'OpenRouter timeout') {
        throw new ServiceUnavailableException('OpenRouter timeout - coba lagi dengan batch yang lebih kecil');
      }
      throw new ServiceUnavailableException(`OpenRouter error: ${error.message}`);
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
    "kategori_toko": "Kategori toko (opsional)",
    "item": [
      {
        "nama": "Nama item",
        "jumlah": 1,
        "harga_satuan": 0,
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
3. Selalu isi field nama_toko, tanggal, total, dan item.
4. Jika nama_toko tidak ditemukan, gunakan "Tidak diketahui".
5. Jika tanggal tidak ditemukan dalam teks, gunakan tanggal hari ini: ${currentDate}
6. Tanggal harus format YYYY-MM-DD.
7. Total adalah angka keseluruhan struk (bukan subtotal item). Jika tidak ada total, jumlahkan subtotal item.
8. Harga dalam format number tanpa pemisah ribuan.
9. Pastikan jumlah * harga_satuan = subtotal untuk setiap item.
10. Return HANYA JSON array, tanpa markdown atau string tambahan lain.`;
  }

  private validasiResponseBatch(text: string, expectedLength: number): ParsedStrukDto[] {
    try {
      const cleaned = text.replace(/```json\n?|\n?```/g, '').trim();
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
          if (!item.subtotal) {
            item.subtotal = item.jumlah * item.harga_satuan;
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

  private async callOpenRouter(messages: OpenRouterMessage[]): Promise<OpenRouterResponse> {
    const response = await fetch(this.apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
        'HTTP-Referer': 'https://snap-notes.app',
        'X-Title': 'Snap Notes Backend',
      },
      body: JSON.stringify({
        model: this.model,
        messages,
        temperature: 0.1,
        max_tokens: 4096,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    return response.json() as Promise<OpenRouterResponse>;
  }
}
