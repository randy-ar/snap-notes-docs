import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RingkasanResponseDto } from './dto/ringkasan-response.dto';
import { QueryDashboardDto } from './dto/query-dashboard.dto';

@Injectable()
export class DashboardService {
  private readonly logger = new Logger(DashboardService.name);

  constructor(private readonly prisma: PrismaService) {}

  async getRingkasan(
    penggunaId: string,
    query: QueryDashboardDto,
  ): Promise<RingkasanResponseDto> {
    const now = new Date();
    const bulan = query.bulan ? parseInt(query.bulan, 10) : now.getMonth() + 1;
    const tahun = query.tahun ? parseInt(query.tahun, 10) : now.getFullYear();

    // Buat range tanggal untuk filter dengan penyesuaian zona waktu WIB (UTC+7)
    const startDate = new Date(Date.UTC(tahun, bulan - 1, 1, -7, 0, 0, 0));
    const endDate = new Date(Date.UTC(tahun, bulan, 0, 16, 59, 59, 999));

    this.logger.debug(
      `Menghitung ringkasan untuk pengguna ${penggunaId} periode ${bulan}/${tahun} (${startDate.toISOString()} - ${endDate.toISOString()})`,
    );

    // Hitung total pemasukan
    const aggregasiPemasukan = await this.prisma.pemasukan.aggregate({
      _sum: {
        jumlah: true,
      },
      where: {
        penggunaId,
        tanggal: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    // Hitung total pengeluaran
    const aggregasiPengeluaran = await this.prisma.pengeluaran.aggregate({
      _sum: {
        jumlah: true,
      },
      where: {
        penggunaId,
        tanggal: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    const totalPemasukan = aggregasiPemasukan._sum.jumlah ? Number(aggregasiPemasukan._sum.jumlah) : 0;
    const totalPengeluaran = aggregasiPengeluaran._sum.jumlah ? Number(aggregasiPengeluaran._sum.jumlah) : 0;
    const saldo = totalPemasukan - totalPengeluaran;

    return {
      totalPemasukan,
      totalPengeluaran,
      saldo,
    };
  }

  async getKalender(
    penggunaId: string,
    query: QueryDashboardDto,
  ): Promise<Record<string, number>> {
    const now = new Date();
    const bulan = query.bulan ? parseInt(query.bulan, 10) : now.getMonth() + 1;
    const tahun = query.tahun ? parseInt(query.tahun, 10) : now.getFullYear();

    const startDate = new Date(Date.UTC(tahun, bulan - 1, 1, -7, 0, 0, 0));
    const endDate = new Date(Date.UTC(tahun, bulan, 0, 16, 59, 59, 999));

    const pengeluaran = await this.prisma.pengeluaran.findMany({
      where: {
        penggunaId,
        tanggal: {
          gte: startDate,
          lte: endDate,
        },
      },
      select: {
        tanggal: true,
        jumlah: true,
      },
    });

    const result: Record<string, number> = {};
    for (const item of pengeluaran) {
      // Format as YYYY-MM-DD
      const dateKey = item.tanggal.toISOString().split('T')[0];
      result[dateKey] = (result[dateKey] || 0) + Number(item.jumlah);
    }
    
    return result;
  }

  async getKategori(
    penggunaId: string,
    query: QueryDashboardDto,
  ): Promise<any[]> {
    const now = new Date();
    const bulan = query.bulan ? parseInt(query.bulan, 10) : now.getMonth() + 1;
    const tahun = query.tahun ? parseInt(query.tahun, 10) : now.getFullYear();

    const startDate = new Date(Date.UTC(tahun, bulan - 1, 1, -7, 0, 0, 0));
    const endDate = new Date(Date.UTC(tahun, bulan, 0, 16, 59, 59, 999));

    const pengeluaran = await this.prisma.pengeluaran.groupBy({
      by: ['kategoriId'],
      where: {
        penggunaId,
        tanggal: {
          gte: startDate,
          lte: endDate,
        },
      },
      _sum: {
        jumlah: true,
      },
    });

    if (pengeluaran.length === 0) return [];

    const kategoriIds = pengeluaran.map(p => p.kategoriId).filter(Boolean) as string[];
    const kategoris = await this.prisma.kategori.findMany({
      where: { id: { in: kategoriIds } },
    });

    return pengeluaran.map(p => {
      const kategori = kategoris.find(k => k.id === p.kategoriId);
      return {
        kategoriId: p.kategoriId,
        kategoriNama: kategori ? kategori.nama : 'Lainnya',
        totalAmount: Number(p._sum.jumlah || 0),
      };
    });
  }

  async getTrend(
    penggunaId: string,
    query: QueryDashboardDto,
  ): Promise<any[]> {
    const now = new Date();
    const focusBulan = query.bulan ? parseInt(query.bulan, 10) : now.getMonth() + 1;
    const focusTahun = query.tahun ? parseInt(query.tahun, 10) : now.getFullYear();
    const focusDate = new Date(focusTahun, focusBulan - 1, 1);

    // Limit range to -6 to +6 months to reduce payload and processing
    const startDate = new Date(Date.UTC(focusDate.getFullYear(), focusDate.getMonth() - 6, 1, -7, 0, 0, 0));
    const endDate = new Date(Date.UTC(focusDate.getFullYear(), focusDate.getMonth() + 7, 0, 16, 59, 59, 999));

    const months: { bulan: number; tahun: number; date: Date }[] = [];
    for (let i = -6; i <= 6; i++) {
      const d = new Date(focusDate.getFullYear(), focusDate.getMonth() + i, 1);
      months.push({ bulan: d.getMonth() + 1, tahun: d.getFullYear(), date: d });
    }

    // Fetch all transactions within the range to memory, then group them using JS.
    // This uses standard Prisma APIs (efficient query) and avoids raw SQL typing issues.
    const [pemasukanList, pengeluaranList] = await Promise.all([
      this.prisma.pemasukan.findMany({
        where: {
          penggunaId,
          tanggal: {
            gte: startDate,
            lte: endDate,
          },
        },
        select: { tanggal: true, jumlah: true },
      }),
      this.prisma.pengeluaran.findMany({
        where: {
          penggunaId,
          tanggal: {
            gte: startDate,
            lte: endDate,
          },
        },
        select: { tanggal: true, jumlah: true },
      }),
    ]);

    const pemasukanMap = new Map<string, number>();
    for (const p of pemasukanList) {
      const key = `${p.tanggal.getFullYear()}-${p.tanggal.getMonth() + 1}`;
      pemasukanMap.set(key, (pemasukanMap.get(key) || 0) + Number(p.jumlah));
    }

    const pengeluaranMap = new Map<string, number>();
    for (const p of pengeluaranList) {
      const key = `${p.tanggal.getFullYear()}-${p.tanggal.getMonth() + 1}`;
      pengeluaranMap.set(key, (pengeluaranMap.get(key) || 0) + Number(p.jumlah));
    }

    return months.map((m) => {
      const key = `${m.tahun}-${m.bulan}`;
      return {
        bulan: m.bulan,
        tahun: m.tahun,
        totalPemasukan: pemasukanMap.get(key) || 0,
        totalPengeluaran: pengeluaranMap.get(key) || 0,
        dateTime: m.date.toISOString(),
      };
    });
  }
}
