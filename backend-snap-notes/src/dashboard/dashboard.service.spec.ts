import { Test, TestingModule } from '@nestjs/testing';
import { DashboardService } from './dashboard.service';
import { PrismaService } from '../prisma/prisma.service';
import { UnauthorizedException } from '@nestjs/common';

describe('DashboardService', () => {
  let service: DashboardService;
  let prisma: PrismaService;

  const mockPrisma = {
    pemasukan: {
      aggregate: jest.fn(),
      findMany: jest.fn(),
    },
    pengeluaran: {
      aggregate: jest.fn(),
      findMany: jest.fn(),
      groupBy: jest.fn(),
    },
    kategori: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  it('should throw UnauthorizedException if penggunaId is empty', async () => {
    await expect(service.getRingkasan('', {})).rejects.toThrow(UnauthorizedException);
  });

  it('should query ringkasan with exact penggunaId', async () => {
    mockPrisma.pemasukan.aggregate.mockResolvedValue({ _sum: { jumlah: 500000 } });
    mockPrisma.pengeluaran.aggregate.mockResolvedValue({ _sum: { jumlah: 200000 } });

    const res = await service.getRingkasan('user-123', { bulan: '5', tahun: '2026' });

    expect(res).toEqual({
      totalPemasukan: 500000,
      totalPengeluaran: 200000,
      saldo: 300000,
    });

    expect(mockPrisma.pemasukan.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ penggunaId: 'user-123' }),
      }),
    );
    expect(mockPrisma.pengeluaran.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ penggunaId: 'user-123' }),
      }),
    );
  });
});
