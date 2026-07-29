import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsNumber, IsOptional, IsDateString, IsUUID, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class CreateStrukItemDto {
  @ApiProperty({ description: 'Nama item' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'Kuantitas' })
  @IsNumber()
  @IsNotEmpty()
  quantity: number;

  @ApiProperty({ description: 'Harga satuan' })
  @IsNumber()
  @IsNotEmpty()
  price: number;

  @ApiPropertyOptional({ description: 'Diskon' })
  @IsNumber()
  @IsOptional()
  discount?: number;

  @ApiProperty({ description: 'Subtotal harga' })
  @IsNumber()
  @IsNotEmpty()
  total_price: number;

  @ApiPropertyOptional({ description: 'Kategori item' })
  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional({ description: 'Nama kategori item (opsional/informasi)' })
  @IsString()
  @IsOptional()
  categoryName?: string;
}

export class CreateStrukManualDto {
  @ApiPropertyOptional({ description: 'Daftar item belanja' })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateStrukItemDto)
  @IsOptional()
  items?: CreateStrukItemDto[];
}

export class CreatePengeluaranDto {
  @ApiProperty({ description: 'Deskripsi pengeluaran', example: 'Makan siang' })
  @IsString()
  @IsNotEmpty()
  deskripsi: string;

  @ApiProperty({ description: 'Jumlah pengeluaran', example: 25000 })
  @IsNumber()
  @IsNotEmpty()
  jumlah: number;

  @ApiProperty({ description: 'Tanggal pengeluaran (ISO 8601)', example: '2026-05-28T00:00:00.000Z' })
  @IsDateString()
  @IsNotEmpty()
  tanggal: string;

  @ApiPropertyOptional({ description: 'ID kategori' })
  @IsUUID()
  @IsOptional()
  kategoriId?: string;

  @ApiPropertyOptional({ description: 'Catatan tambahan' })
  @IsString()
  @IsOptional()
  catatan?: string;

  @ApiPropertyOptional({ description: 'Data struk manual (jika ada)' })
  @ValidateNested()
  @Type(() => CreateStrukManualDto)
  @IsOptional()
  struk?: CreateStrukManualDto;
}
