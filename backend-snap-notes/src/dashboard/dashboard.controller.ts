import { Controller, Get, Query, UseGuards, Req } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';
import { RingkasanResponseDto } from './dto/ringkasan-response.dto';
import { QueryDashboardDto } from './dto/query-dashboard.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@ApiTags('dashboard')
@Controller('dashboard')
@UseGuards(SupabaseAuthGuard)
@ApiBearerAuth()
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('ringkasan')
  @ApiOperation({
    summary: 'Mendapatkan ringkasan dashboard (total pemasukan, pengeluaran, saldo)',
  })
  @ApiResponse({
    status: 200,
    description: 'Ringkasan berhasil diambil',
    type: RingkasanResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getRingkasan(
    @Req() req: any,
    @Query() query: QueryDashboardDto,
  ): Promise<RingkasanResponseDto> {
    const penggunaId = req.user.id || req.user.sub;
    return this.dashboardService.getRingkasan(penggunaId, query);
  }

  @Get('trend')
  @ApiOperation({
    summary: 'Mendapatkan tren ringkasan dashboard selama 6 bulan terakhir',
  })
  @ApiResponse({
    status: 200,
    description: 'Tren berhasil diambil',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTrend(
    @Req() req: any,
    @Query() query: QueryDashboardDto,
  ): Promise<any[]> {
    const penggunaId = req.user.id || req.user.sub;
    return this.dashboardService.getTrend(penggunaId, query);
  }

  @Get('kalender')
  @ApiOperation({
    summary: 'Mendapatkan data heatmap pengeluaran per hari dalam 1 bulan',
  })
  @ApiResponse({
    status: 200,
    description: 'Data kalender berhasil diambil',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getKalender(
    @Req() req: any,
    @Query() query: QueryDashboardDto,
  ): Promise<any> {
    const penggunaId = req.user.id || req.user.sub;
    return this.dashboardService.getKalender(penggunaId, query);
  }

  @Get('transaksi-harian')
  @ApiOperation({
    summary: 'Mendapatkan daftar pengeluaran & pemasukan pada tanggal tertentu',
  })
  @ApiResponse({
    status: 200,
    description: 'Data transaksi harian berhasil diambil',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTransaksiHarian(
    @Req() req: any,
    @Query('tanggal') tanggal: string,
  ): Promise<any> {
    const penggunaId = req.user.id || req.user.sub;
    return this.dashboardService.getDetailHarian(penggunaId, tanggal);
  }

  @Get('kategori')
  @ApiOperation({
    summary: 'Mendapatkan agregasi pengeluaran berdasarkan kategori dalam 1 bulan',
  })
  @ApiResponse({
    status: 200,
    description: 'Data kategori berhasil diambil',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getKategori(
    @Req() req: any,
    @Query() query: QueryDashboardDto,
  ): Promise<any[]> {
    const penggunaId = req.user.id || req.user.sub;
    return this.dashboardService.getKategori(penggunaId, query);
  }
}
