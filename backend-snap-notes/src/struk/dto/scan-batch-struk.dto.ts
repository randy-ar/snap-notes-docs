import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class ScanBatchStrukDto {
  @ApiProperty({
    description: 'Array data OCR dalam format JSON string (memuat array dari rawText, imageSize, lines, dan customPrompt)',
    example: '[{"rawText":"Indomaret...","imageSize":{"width":1080,"height":1920},"lines":[]},{"rawText":"Alfamart...","imageSize":{"width":1080,"height":1920},"lines":[]}]'
  })
  @IsString()
  @IsNotEmpty({ message: 'Data OCR batch tidak boleh kosong' })
  ocrData: string;
}
