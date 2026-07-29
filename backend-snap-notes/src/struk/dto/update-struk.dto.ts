import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsDateString, IsNumber, IsUUID, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateItemStrukDto {
  @ApiPropertyOptional({ description: 'ID kategori item' })
  @IsOptional()
  @IsUUID(undefined, { message: 'ID kategori tidak valid' })
  kategoriId?: string;

  @ApiPropertyOptional({ description: 'Nama item' })
  @IsOptional()
  @IsString()
  namaItem?: string;

  @ApiPropertyOptional({ description: 'Jumlah item' })
  @IsOptional()
  @IsNumber({}, { message: 'Jumlah harus berupa angka' })
  jumlah?: number;

  @ApiPropertyOptional({ description: 'Harga satuan item' })
  @IsOptional()
  @IsNumber({}, { message: 'Harga satuan harus berupa angka' })
  hargaSatuan?: number;

  @ApiPropertyOptional({ description: 'Diskon per item' })
  @IsOptional()
  @IsNumber({}, { message: 'Diskon harus berupa angka' })
  diskon?: number;

  @ApiPropertyOptional({ description: 'Subtotal item' })
  @IsOptional()
  @IsNumber({}, { message: 'Subtotal harus berupa angka' })
  subtotal?: number;
}

export class UpdateStrukDto {
  @ApiPropertyOptional({ description: 'ID kategori toko' })
  @IsOptional()
  @IsUUID(undefined, { message: 'ID kategori tidak valid' })
  kategoriId?: string;

  @ApiPropertyOptional({ description: 'Nama toko/merchant' })
  @IsOptional()
  @IsString()
  namaToko?: string;

  @ApiPropertyOptional({ description: 'Tanggal belanja (YYYY-MM-DD)' })
  @IsOptional()
  @IsDateString({}, { message: 'Format tanggal tidak valid' })
  tanggalBelanja?: string;

  @ApiPropertyOptional({ description: 'Total keseluruhan struk (setelah diskon)' })
  @IsOptional()
  @IsNumber({}, { message: 'Total harus berupa angka' })
  total?: number;

  @ApiPropertyOptional({ description: 'Total keseluruhan struk sebelum diskon' })
  @IsOptional()
  @IsNumber({}, { message: 'Total item harus berupa angka' })
  totalItem?: number;

  @ApiPropertyOptional({ description: 'Diskon keseluruhan struk' })
  @IsOptional()
  @IsNumber({}, { message: 'Diskon harus berupa angka' })
  diskon?: number;

  @ApiPropertyOptional({ description: 'Daftar item dalam struk (menggantikan yang lama)', type: [UpdateItemStrukDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UpdateItemStrukDto)
  items?: UpdateItemStrukDto[];
}
