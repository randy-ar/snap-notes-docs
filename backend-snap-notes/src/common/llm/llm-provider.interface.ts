export interface ParsedItemDto {
  nama: string;
  jumlah: number;
  harga_satuan: number;
  diskon?: number;
  subtotal: number;
  kategori?: string;
}

export interface ParsedStrukDto {
  nama_toko: string;
  tanggal: string;
  total: number;
  totalItem?: number;
  diskon?: number;
  kategori_toko?: string;
  item: ParsedItemDto[];
}

export interface OcrLine {
  lineIndex: number;
  text: string;
  boundingBox: {
    left: number;
    top: number;
    right: number;
    bottom: number;
  };
}

export interface ImageSize {
  width: number;
  height: number;
}

export interface ILLMProvider {
  parseStrukOCRBatch(ocrDataBatch: any[], customPrompt?: string, kategoriContext?: string): Promise<ParsedStrukDto[]>;
}
