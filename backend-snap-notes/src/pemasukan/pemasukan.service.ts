import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePemasukanDto } from './dto/create-pemasukan.dto';
import { UpdatePemasukanDto } from './dto/update-pemasukan.dto';
import { QueryPemasukanDto } from './dto/query-pemasukan.dto';
import { PemasukanResponseDto } from './dto/pemasukan-response.dto';

@Injectable()
export class PemasukanService {
  constructor(private readonly prisma: PrismaService) {}

  async tambah(penggunaId: string, dto: CreatePemasukanDto): Promise<PemasukanResponseDto> {
    const pemasukan = await this.prisma.pemasukan.create({
      data: {
        penggunaId,
        deskripsi: dto.deskripsi,
        jumlah: dto.jumlah,
        tanggal: new Date(dto.tanggal),
        kategoriId: dto.kategoriId,
        catatan: dto.catatan,
      },
      include: {
        kategori: true,
      },
    });

    return {
      id: pemasukan.id,
      penggunaId: pemasukan.penggunaId,
      
      kategoriId: pemasukan.kategoriId ?? undefined,
      kategoriNama: pemasukan.kategori?.nama,
      deskripsi: pemasukan.deskripsi,
      jumlah: Number(pemasukan.jumlah),
      tanggal: pemasukan.tanggal,
      catatan: pemasukan.catatan ?? undefined,
      createdAt: pemasukan.createdAt,
      updatedAt: pemasukan.updatedAt,
    };
  }

  async getDaftar(penggunaId: string, query: QueryPemasukanDto): Promise<any> {
    const where: any = { penggunaId };

    if (query.bulan && query.tahun) {
      const startDate = new Date(Date.UTC(query.tahun, query.bulan - 1, 1, -7, 0, 0, 0));
      const endDate = new Date(Date.UTC(query.tahun, query.bulan, 0, 16, 59, 59, 999));
      where.tanggal = {
        gte: startDate,
        lte: endDate,
      };
    }

    const page = query.page && query.page > 0 ? query.page : 1;
    const limit = query.limit && query.limit > 0 ? query.limit : 10;
    const skip = (page - 1) * limit;

    const [pemasukans, total] = await Promise.all([
      this.prisma.pemasukan.findMany({
        where,
        include: {
          kategori: true,
        },
        orderBy: { tanggal: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.pemasukan.count({ where }),
    ]);

    return {
      data: pemasukans.map(p => this.mapToResponseDto(p)),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getOverview(penggunaId: string, query: QueryPemasukanDto): Promise<any> {
    const now = new Date();
    const bulan = query.bulan ? Number(query.bulan) : now.getMonth() + 1;
    const tahun = query.tahun ? Number(query.tahun) : now.getFullYear();

    const currStartDate = new Date(Date.UTC(tahun, bulan - 1, 1, -7, 0, 0, 0));
    const currEndDate = new Date(Date.UTC(tahun, bulan, 0, 16, 59, 59, 999));

    let prevBulan = bulan - 1;
    let prevTahun = tahun;
    if (prevBulan === 0) {
      prevBulan = 12;
      prevTahun -= 1;
    }
    const prevStartDate = new Date(Date.UTC(prevTahun, prevBulan - 1, 1, -7, 0, 0, 0));
    const prevEndDate = new Date(Date.UTC(prevTahun, prevBulan, 0, 16, 59, 59, 999));

    const [currAgg, prevAgg] = await Promise.all([
      this.prisma.pemasukan.aggregate({
        _sum: { jumlah: true },
        where: { penggunaId, tanggal: { gte: currStartDate, lte: currEndDate } },
      }),
      this.prisma.pemasukan.aggregate({
        _sum: { jumlah: true },
        where: { penggunaId, tanggal: { gte: prevStartDate, lte: prevEndDate } },
      }),
    ]);

    const totalCurrentMonth = currAgg._sum.jumlah ? Number(currAgg._sum.jumlah) : 0;
    const totalPreviousMonth = prevAgg._sum.jumlah ? Number(prevAgg._sum.jumlah) : 0;
    let percentageChange = 0;

    if (totalPreviousMonth > 0) {
      percentageChange = ((totalCurrentMonth - totalPreviousMonth) / totalPreviousMonth) * 100;
    } else if (totalCurrentMonth > 0) {
      percentageChange = 100;
    }

    return {
      totalCurrentMonth,
      totalPreviousMonth,
      percentageChange,
      isTrendingGood: percentageChange >= 0,
    };
  }

  async getDetail(penggunaId: string, id: string): Promise<PemasukanResponseDto> {
    const pemasukan = await this.prisma.pemasukan.findUnique({
      where: { id },
      include: {
        kategori: true,
      },
    });

    if (!pemasukan) {
      throw new NotFoundException('Pemasukan tidak ditemukan');
    }

    if (pemasukan.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses ke pemasukan ini');
    }

    return this.mapToResponseDto(pemasukan);
  }

  async update(penggunaId: string, id: string, dto: UpdatePemasukanDto): Promise<PemasukanResponseDto> {
    const existing = await this.prisma.pemasukan.findUnique({ where: { id } });

    if (!existing) {
      throw new NotFoundException('Pemasukan tidak ditemukan');
    }

    if (existing.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses untuk mengubah pemasukan ini');
    }

    const updated = await this.prisma.pemasukan.update({
      where: { id },
      data: {
        deskripsi: dto.deskripsi,
        jumlah: dto.jumlah,
        tanggal: dto.tanggal ? new Date(dto.tanggal) : undefined,
        kategoriId: dto.kategoriId,
        catatan: dto.catatan,
      },
      include: {
        kategori: true,
      },
    });

    return this.mapToResponseDto(updated);
  }

  async hapus(penggunaId: string, id: string): Promise<void> {
    const existing = await this.prisma.pemasukan.findUnique({ where: { id } });

    if (!existing) {
      throw new NotFoundException('Pemasukan tidak ditemukan');
    }

    if (existing.penggunaId !== penggunaId) {
      throw new ForbiddenException('Anda tidak memiliki akses untuk menghapus pemasukan ini');
    }

    await this.prisma.pemasukan.delete({
      where: { id },
    });
  }

  private mapToResponseDto(pemasukan: any): PemasukanResponseDto {
    return {
      id: pemasukan.id,
      penggunaId: pemasukan.penggunaId,
      
      kategoriId: pemasukan.kategoriId ?? undefined,
      kategoriNama: pemasukan.kategori?.nama,
      deskripsi: pemasukan.deskripsi,
      jumlah: Number(pemasukan.jumlah),
      tanggal: pemasukan.tanggal,
      catatan: pemasukan.catatan ?? undefined,
      createdAt: pemasukan.createdAt,
      updatedAt: pemasukan.updatedAt,

    };
  }
}
