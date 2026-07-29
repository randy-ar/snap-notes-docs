import { Injectable, NotFoundException, ForbiddenException, UnprocessableEntityException, ServiceUnavailableException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LLMFactory } from '../common/llm/llm.factory';
import { ParsedStrukDto } from '../common/llm/llm-provider.interface';
import { StorageService } from '../common/storage/storage.service';
import { ScanStrukBatchDto, OcrDataDto } from './dto/scan-struk.dto';
import { ReparseStrukDto } from './dto/reparse-struk.dto';
import { UpdateStrukDto } from './dto/update-struk.dto';
import { StrukResponseDto, ItemStrukResponseDto } from './dto/struk-response.dto';

@Injectable()
export class StrukService {
  constructor(
    private prisma: PrismaService,
    private llmFactory: LLMFactory,
    private storageService: StorageService,
  ) {}

  async analyzeStrukBatch(penggunaId: string, dto: ScanStrukBatchDto): Promise<StrukResponseDto[]> {
    const startTime = Date.now();

    // Pastikan pengguna ada di database
    const pengguna = await this.prisma.pengguna.findUnique({
      where: { id: penggunaId },
    });

    if (!pengguna) {
      throw new NotFoundException('Data pengguna tidak ditemukan. Silakan login ulang.');
    }

    if (!dto.ocrDataBatch || dto.ocrDataBatch.length === 0) {
      throw new UnprocessableEntityException('ocrDataBatch tidak boleh kosong');
    }

    // Validasi struktur dasar tiap item
    for (const ocrData of dto.ocrDataBatch) {
      if (!ocrData.rawText || !Array.isArray(ocrData.lines)) {
        throw new UnprocessableEntityException('Struktur ocrData dalam batch tidak lengkap (rawText dan lines wajib ada)');
      }
    }

    let parsedDataArray: ParsedStrukDto[];
    const llmProvider = this.llmFactory.getProvider();

    try {
      const kategoriContext = await this.getKategoriContext(penggunaId);
      parsedDataArray = await llmProvider.parseStrukOCRBatch(
        dto.ocrDataBatch,
        dto.ocrDataBatch[0]?.customPrompt, // Gunakan prompt custom pertama jika ada
        kategoriContext
      );
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnprocessableEntityException) {
        throw error;
      }
      throw new ServiceUnavailableException('Gagal memproses batch struk dengan AI');
    }

    // Ambil SEMUA kategori sekaligus (In-Memory Caching) untuk menghindari N+1 Query Problem
    const semuaKategori = await this.prisma.kategori.findMany({
      where: {
        OR: [
          { adalahPreset: true },
          { penggunaId },
        ],
      },
    });

    const responseDtos: StrukResponseDto[] = [];

    for (let i = 0; i < parsedDataArray.length; i++) {
      const parsedData = parsedDataArray[i];

      // Resolusi kategori untuk setiap item struk dan tentukan kategori utama struk
      const resolvedItems: {
        nama: string;
        jumlah: number;
        hargaSatuan: number;
        diskon: number | null;
        subtotal: number;
        kategoriId: string | null;
        kategoriNama: string | null;
      }[] = [];
      const subtotalPerKategori: Record<string, number> = {};

      for (const item of parsedData.item) {
        let itemKategoriId: string | null = null;
        let itemKategoriNama: string | null = null;

        if (item.kategori) {
          // Cari kategori di memori alih-alih query DB
          const itemKategori = semuaKategori.find((k) =>
            k.nama.toLowerCase().includes(item.kategori!.toLowerCase())
          );
          itemKategoriId = itemKategori?.id || null;
          itemKategoriNama = itemKategori?.nama || null;
        }

        const diskonItem = item.diskon || 0;
        const subtotal = item.subtotal || ((item.jumlah * item.harga_satuan) - diskonItem);
        if (itemKategoriId) {
          subtotalPerKategori[itemKategoriId] = (subtotalPerKategori[itemKategoriId] || 0) + subtotal;
        }

        resolvedItems.push({
          nama: item.nama,
          jumlah: item.jumlah,
          hargaSatuan: item.harga_satuan,
          diskon: diskonItem,
          subtotal,
          kategoriId: itemKategoriId,
          kategoriNama: itemKategoriNama,
        });
      }

      // Cari kategori item yang dominan (subtotal terbesar)
      let dominanKategoriId: string | null = null;
      let dominanKategoriNama: string | null = null;
      let maxSubtotal = -1;
      for (const [catId, subtotal] of Object.entries(subtotalPerKategori)) {
        if (subtotal > maxSubtotal) {
          maxSubtotal = subtotal;
          dominanKategoriId = catId;
          const cat = semuaKategori.find(k => k.id === catId);
          dominanKategoriNama = cat?.nama || null;
        }
      }

      let kategoriId: string | null = dominanKategoriId;
      let kategoriNama: string | null = dominanKategoriNama;

      // Fallback 1: Jika tidak ada kategori item, gunakan kategori_toko
      if (!kategoriId && parsedData.kategori_toko) {
        const kategoriToko = semuaKategori.find((k) =>
          k.nama.toLowerCase().includes(parsedData.kategori_toko!.toLowerCase())
        );
        kategoriId = kategoriToko?.id || null;
        kategoriNama = kategoriToko?.nama || null;
      }

      // Fallback 2: Jika masih null, gunakan kategori 'Lainnya' (PENGELUARAN)
      if (!kategoriId) {
        const kategoriLainnya = semuaKategori.find(
          (k) => k.nama === 'Lainnya' && k.jenis === 'PENGELUARAN' && k.adalahPreset
        );
        kategoriId = kategoriLainnya?.id || null;
        kategoriNama = kategoriLainnya?.nama || null;
      }

      responseDtos.push({
        id: '', // Will be generated on save
        penggunaId,
        kategoriId: kategoriId || undefined,
        kategoriNama: kategoriNama || undefined,
        namaToko: parsedData.nama_toko,
        tanggalBelanja: new Date(parsedData.tanggal),
        total: parsedData.total,
        totalItem: parsedData.totalItem,
        diskon: parsedData.diskon || 0,
        sudahDikonfirmasi: false,
        items: resolvedItems.map((item, index) => ({
          id: `temp-${index}`,
          namaItem: item.nama,
          jumlah: item.jumlah,
          hargaSatuan: item.hargaSatuan,
          diskon: item.diskon || 0,
          subtotal: item.subtotal,
          kategoriId: item.kategoriId || undefined,
          kategoriNama: item.kategoriNama || undefined,
        })),
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    }

    const endTime = Date.now();
    console.log(`[analyzeStrukBatch] Completed in ${endTime - startTime}ms for penggunaId: ${penggunaId} (Batch Size: ${dto.ocrDataBatch.length})`);

    return responseDtos;
  }

  async saveAnalyzedStruk(penggunaId: string, file: Express.Multer.File | undefined, receiptDataString: string): Promise<StrukResponseDto> {
    const startTime = Date.now();

    // Pastikan pengguna ada di database
    const pengguna = await this.prisma.pengguna.findUnique({
      where: { id: penggunaId },
    });

    if (!pengguna) {
      throw new NotFoundException('Data pengguna tidak ditemukan. Silakan login ulang.');
    }

    let receiptData: any;
    try {
      receiptData = JSON.parse(receiptDataString);
    } catch {
      throw new UnprocessableEntityException('Format receiptData JSON tidak valid');
    }

    let storageResult: { path: string; publicUrl: string } | null = null;

    if (file) {
      try {
        storageResult = await this.storageService.uploadGambarStruk(file.buffer, file.originalname, penggunaId);
      } catch (error) {
        console.error('Error uploading image to Supabase:', error);
        throw new ServiceUnavailableException(`Gagal mengupload gambar struk: ${error.message}`);
      }
    }

    const struk = await this.prisma.$transaction(async (tx) => {
      const createdStruk = await tx.struk.create({
        data: {
          penggunaId,
          kategoriId: receiptData.kategoriId || null,
          namaToko: receiptData.namaToko,
          tanggalBelanja: new Date(receiptData.tanggalBelanja),
          diskon: receiptData.diskon || null,
          total: receiptData.total,
          gambarUrl: storageResult?.publicUrl || null,
          gambarStoragePath: storageResult?.path || null,
          sudahDikonfirmasi: true, // Auto confirm when saving explicitly
        },
        include: {
          kategori: true,
        },
      });

      const items = [];
      if (receiptData.items && Array.isArray(receiptData.items)) {
        for (const item of receiptData.items) {
           const createdItem = await tx.itemStruk.create({
            data: {
              strukId: createdStruk.id,
              kategoriId: item.kategoriId || null,
              namaItem: item.namaItem,
              jumlah: item.jumlah,
              hargaSatuan: item.hargaSatuan,
              diskon: item.diskon || null,
              subtotal: item.subtotal,
            },
            include: {
              kategori: true,
            },
          });
          items.push(createdItem);
        }
      }

      await tx.pengeluaran.create({
        data: {
          penggunaId,
          strukId: createdStruk.id,
          kategoriId: receiptData.kategoriId || null,
          deskripsi: `Pembelian di ${receiptData.namaToko}`,
          jumlah: receiptData.total,
          tanggal: new Date(receiptData.tanggalBelanja),
        },
      });

      return { ...createdStruk, itemStruks: items };
    }, { timeout: 15000 });

    const endTime = Date.now();
    console.log(`[saveAnalyzedStruk] Completed in ${endTime - startTime}ms for penggunaId: ${penggunaId}`);

    return this.mapToResponseDto(struk);
  }

  async reparseStruk(penggunaId: string, id: string, dto: ReparseStrukDto): Promise<StrukResponseDto> {
    const startTime = Date.now();

    const existingStruk = await this.prisma.struk.findUnique({
      where: { id },
    });

    if (!existingStruk) {
      throw new NotFoundException('Struk tidak ditemukan');
    }

    if (existingStruk.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses ke struk ini');
    }

    if (!existingStruk.rawTextOcr) {
      throw new UnprocessableEntityException('Data OCR tidak tersedia untuk struk ini');
    }

    let ocrData: OcrDataDto;
    try {
      ocrData = JSON.parse(existingStruk.rawTextOcr) as OcrDataDto;
    } catch {
      throw new UnprocessableEntityException('Format ocrData JSON tidak valid pada struk yang ada');
    }

    let parsedData: ParsedStrukDto;
    const llmProvider = this.llmFactory.getProvider();

    try {
      const kategoriContext = await this.getKategoriContext(penggunaId);
      const parsedDataArray = await llmProvider.parseStrukOCRBatch(
        [ocrData],
        dto.prompt,
        kategoriContext
      );
      parsedData = parsedDataArray[0];
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnprocessableEntityException) {
        throw error;
      }
      throw new ServiceUnavailableException('Gagal memproses ulang struk dengan AI');
    }

    // Resolusi kategori untuk setiap item struk dan tentukan kategori utama struk
    const resolvedItems: {
      nama: string;
      jumlah: number;
      hargaSatuan: number;
      subtotal: number;
      kategoriId: string | null;
    }[] = [];
    const subtotalPerKategori: Record<string, number> = {};

    for (const item of parsedData.item) {
      let itemKategoriId: string | null = null;

      if (item.kategori) {
        const itemKategori = await this.prisma.kategori.findFirst({
          where: {
            OR: [
              { nama: { contains: item.kategori, mode: 'insensitive' }, adalahPreset: true },
              { nama: { contains: item.kategori, mode: 'insensitive' }, penggunaId },
            ],
          },
        });
        itemKategoriId = itemKategori?.id || null;
      }

      const subtotal = item.subtotal || (item.jumlah * item.harga_satuan);
      if (itemKategoriId) {
        subtotalPerKategori[itemKategoriId] = (subtotalPerKategori[itemKategoriId] || 0) + subtotal;
      }

      resolvedItems.push({
        nama: item.nama,
        jumlah: item.jumlah,
        hargaSatuan: item.harga_satuan,
        subtotal,
        kategoriId: itemKategoriId,
      });
    }

    // Cari kategori item yang dominan (subtotal terbesar)
    let dominanKategoriId: string | null = null;
    let maxSubtotal = -1;
    for (const [catId, subtotal] of Object.entries(subtotalPerKategori)) {
      if (subtotal > maxSubtotal) {
        maxSubtotal = subtotal;
        dominanKategoriId = catId;
      }
    }

    let kategoriId: string | null = dominanKategoriId;

    // Fallback 1: Jika tidak ada kategori item, gunakan kategori_toko
    if (!kategoriId && parsedData.kategori_toko) {
      const kategoriToko = await this.prisma.kategori.findFirst({
        where: {
          OR: [
            { nama: { contains: parsedData.kategori_toko, mode: 'insensitive' }, adalahPreset: true },
            { nama: { contains: parsedData.kategori_toko, mode: 'insensitive' }, penggunaId },
          ],
        },
      });
      kategoriId = kategoriToko?.id || null;
    }

    // Fallback 2: Jika masih null, gunakan kategori 'Lainnya' (PENGELUARAN)
    if (!kategoriId) {
      const kategoriLainnya = await this.prisma.kategori.findFirst({
        where: {
          nama: 'Lainnya',
          jenis: 'PENGELUARAN',
          adalahPreset: true,
        },
      });
      kategoriId = kategoriLainnya?.id || null;
    }

    const updatedStruk = await this.prisma.$transaction(async (tx) => {
      // Delete existing itemStruks
      await tx.itemStruk.deleteMany({
        where: { strukId: id },
      });

      // Update Struk
      const strukResult = await tx.struk.update({
        where: { id },
        data: {
          kategoriId,
          namaToko: parsedData.nama_toko,
          tanggalBelanja: new Date(parsedData.tanggal),
          total: parsedData.total,
        },
        include: {
          kategori: true,
        },
      });

      const items = await Promise.all(
        resolvedItems.map(resolvedItem => 
          tx.itemStruk.create({
            data: {
              strukId: id,
              kategoriId: resolvedItem.kategoriId,
              namaItem: resolvedItem.nama,
              jumlah: resolvedItem.jumlah,
              hargaSatuan: resolvedItem.hargaSatuan,
              subtotal: resolvedItem.subtotal,
            },
            include: {
              kategori: true,
            },
          })
        )
      );

      // Update Pengeluaran
      await tx.pengeluaran.updateMany({
        where: { strukId: id },
        data: {
          kategoriId,
          deskripsi: `Pembelian di ${parsedData.nama_toko}`,
          jumlah: parsedData.total,
          tanggal: new Date(parsedData.tanggal),
        },
      });

      return { ...strukResult, itemStruks: items };
    }, { timeout: 15000 });

    const endTime = Date.now();
    console.log(`[reparseStruk] Completed in ${endTime - startTime}ms for penggunaId: ${penggunaId}, strukId: ${id}`);

    return this.mapToResponseDto(updatedStruk);
  }

  async getDaftarStruk(penggunaId: string, query?: { bulan?: number; tahun?: number }): Promise<StrukResponseDto[]> {
    const where: { penggunaId: string; tanggalBelanja?: { gte: Date; lte: Date } } = { penggunaId };

    if (query?.bulan && query?.tahun) {
      const startDate = new Date(query.tahun, query.bulan - 1, 1);
      const endDate = new Date(query.tahun, query.bulan, 0);
      where.tanggalBelanja = {
        gte: startDate,
        lte: endDate,
      };
    }

    const struks = await this.prisma.struk.findMany({
      where,
      include: {
        kategori: true,
        itemStruks: {
          include: {
            kategori: true,
          },
        },
      },
      orderBy: { tanggalBelanja: 'desc' },
    });

    return struks.map((struk) => this.mapToResponseDto(struk));
  }

  async getDetailStruk(penggunaId: string, id: string): Promise<StrukResponseDto> {
    const struk = await this.prisma.struk.findUnique({
      where: { id },
      include: {
        kategori: true,
        itemStruks: {
          include: {
            kategori: true,
          },
        },
      },
    });

    if (!struk) {
      throw new NotFoundException('Struk tidak ditemukan');
    }

    if (struk.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses ke struk ini');
    }

    return this.mapToResponseDto(struk);
  }

  async updateStruk(penggunaId: string, id: string, dto: UpdateStrukDto): Promise<StrukResponseDto> {
    const existingStruk = await this.prisma.struk.findUnique({
      where: { id },
    });

    if (!existingStruk) {
      throw new NotFoundException('Struk tidak ditemukan');
    }

    if (existingStruk.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses untuk mengubah struk ini');
    }

    const updatedStruk = await this.prisma.$transaction(async (tx) => {
      let strukResult = await tx.struk.update({
        where: { id },
        data: {
          kategoriId: dto.kategoriId,
          namaToko: dto.namaToko,
          tanggalBelanja: dto.tanggalBelanja ? new Date(dto.tanggalBelanja) : undefined,
          diskon: dto.diskon,
          total: dto.total,
        },
        include: {
          kategori: true,
        },
      });

      if (dto.items) {
        await tx.itemStruk.deleteMany({
          where: { strukId: id },
        });

        await Promise.all(
          dto.items.map(item =>
            tx.itemStruk.create({
              data: {
                strukId: id,
                kategoriId: item.kategoriId,
                namaItem: item.namaItem || 'Item Baru',
                jumlah: item.jumlah || 1,
                hargaSatuan: item.hargaSatuan || 0,
                diskon: item.diskon || 0,
                subtotal: item.subtotal || 0,
              },
            })
          )
        );
      }

      if (dto.total || dto.namaToko || dto.kategoriId || dto.tanggalBelanja) {
        const pengeluaranUpdateData: any = {};
        if (dto.total) pengeluaranUpdateData.jumlah = dto.total;
        if (dto.namaToko) pengeluaranUpdateData.deskripsi = `Pembelian di ${dto.namaToko}`;
        if (dto.kategoriId) pengeluaranUpdateData.kategoriId = dto.kategoriId;
        if (dto.tanggalBelanja) pengeluaranUpdateData.tanggal = new Date(dto.tanggalBelanja);

        if (Object.keys(pengeluaranUpdateData).length > 0) {
          await tx.pengeluaran.updateMany({
            where: { strukId: id },
            data: pengeluaranUpdateData,
          });
        }
      }

      return await tx.struk.findUnique({
        where: { id },
        include: {
          kategori: true,
          itemStruks: {
            include: {
              kategori: true,
            },
          },
        },
      });
    });

    return this.mapToResponseDto(updatedStruk!);
  }

  async hapusStruk(penggunaId: string, id: string): Promise<void> {
    const existingStruk = await this.prisma.struk.findUnique({
      where: { id },
    });

    if (!existingStruk) {
      throw new NotFoundException('Struk tidak ditemukan');
    }

    if (existingStruk.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses untuk menghapus struk ini');
    }

    await this.prisma.$transaction(async (tx: any) => {
      await tx.pengeluaran.deleteMany({
        where: { strukId: id },
      });

      await tx.itemStruk.deleteMany({
        where: { strukId: id },
      });

      await tx.struk.delete({
        where: { id },
      });
    });

    if (existingStruk.gambarStoragePath) {
      try {
        await this.storageService.hapusGambar(existingStruk.gambarStoragePath);
      } catch {
      }
    }
  }

  async konfirmasiStruk(penggunaId: string, id: string): Promise<StrukResponseDto> {
    const existingStruk = await (this.prisma as any).struk.findUnique({
      where: { id },
    });

    if (!existingStruk) {
      throw new NotFoundException('Struk tidak ditemukan');
    }

    if (existingStruk.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses ke struk ini');
    }

    const updatedStruk = await (this.prisma as any).struk.update({
      where: { id },
      data: { sudahDikonfirmasi: true },
      include: {
        kategori: true,
        itemStruks: {
          include: {
            kategori: true,
          },
        },
      },
    });

    return this.mapToResponseDto(updatedStruk);
  }

  private mapToResponseDto(struk: any): StrukResponseDto {
    return {
      id: struk.id,
      penggunaId: struk.penggunaId,
      kategoriId: struk.kategoriId || undefined,
      kategoriNama: struk.kategori?.nama || undefined,
      namaToko: struk.namaToko,
      tanggalBelanja: struk.tanggalBelanja,
      diskon: struk.diskon ? Number(struk.diskon) : undefined,
      totalItem: struk.totalItem ? Number(struk.totalItem) : undefined,
      total: Number(struk.total),
      gambarUrl: struk.gambarUrl || undefined,
      sudahDikonfirmasi: struk.sudahDikonfirmasi,
      items: struk.itemStruks?.map((item: any): ItemStrukResponseDto => ({
        id: item.id,
        namaItem: item.namaItem,
        jumlah: item.jumlah,
        hargaSatuan: Number(item.hargaSatuan),
        diskon: item.diskon ? Number(item.diskon) : undefined,
        subtotal: Number(item.subtotal),
        kategoriId: item.kategoriId || undefined,
        kategoriNama: item.kategori?.nama || undefined,
      })) || [],
      createdAt: struk.createdAt,
      updatedAt: struk.updatedAt,
    };
  }

  private async getKategoriContext(penggunaId: string): Promise<string> {
    const kategoris = await (this.prisma as any).kategori.findMany({
      where: {
        OR: [
          { adalahPreset: true },
          { penggunaId },
        ],
      },
      orderBy: {
        jenis: 'asc',
      },
    });

    const presetDescriptions: Record<string, string> = {
      'Makanan & Minuman': 'Padi-padian, umbi-umbian, ikan, daging, telur, susu, sayuran, kacang, buah, minyak, bumbu, minuman siap saji, rokok, tembakau',
      'Perumahan & Utilitas': 'Sewa rumah, listrik, air, gas LPG, minyak tanah, kayu bakar, pemeliharaan rumah, iuran kebersihan/keamanan',
      'Komunikasi': 'Pulsa HP, paket data, tagihan telepon, biaya internet/warnet, ongkos kirim paket',
      'Transportasi': 'Bensin, solar, ongkos transportasi umum, tiket perjalanan, biaya tol, parkir',
      'Kesehatan': 'Obat-obatan, vitamin, biaya dokter/klinik/rumah sakit, iuran BPJS Kesehatan',
      'Pendidikan': 'Uang sekolah, buku pelajaran, alat tulis, kursus/les, biaya pendidikan lainnya',
      'Hiburan': 'Tiket rekreasi/bioskop, mainan, hobi, langganan streaming, penginapan/hotel',
      'Perawatan Pribadi': 'Sabun mandi, pasta gigi, sampo, kosmetik, skincare, parfum, potong rambut/salon',
      'Pakaian': 'Baju, celana, alas kaki (sepatu/sandal), tutup kepala (topi/jilbab), bahan pakaian, ongkos jahit',
      'Lain-lain': 'Pajak (PBB/kendaraan), asuransi, barang tahan lama (perabot/elektronik/kendaraan), keperluan pesta/upacara (pernikahan/ulang tahun)',
      'Saku': 'Uang jatah bulanan/mingguan dari orang tua',
      'Gaji': 'Hasil part-time, pekerjaan tetap, upah',
      'Beasiswa': 'Pencairan dana beasiswa',
      'Bonus': 'Uang kaget, hadiah, THR, cashback besar',
    };

    const lines = kategoris.map((k: any) => {
      let desc = '';
      if (k.adalahPreset && presetDescriptions[k.nama]) {
        desc = ` (Contoh: ${presetDescriptions[k.nama]})`;
      }
      return `- [${k.id}] ${k.nama}${desc}`;
    });

    return `KATEGORI PENGELUARAN YANG TERSEDIA:\n${lines.join('\n')}\n(Gunakan ID kategori dari daftar di atas. Jika tidak ada yang cocok, gunakan kategori 'Lainnya')`;
  }
}
