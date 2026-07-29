import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;

  constructor(private configService: ConfigService) {
    const url = this.configService.get<string>('SUPABASE_URL');
    const key = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!url || !key) {
      throw new Error('SUPABASE_URL dan SUPABASE_SERVICE_ROLE_KEY harus diatur di environment variables');
    }
    
    this.client = createClient(url, key, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });
  }

  getClient(): SupabaseClient {
    return this.client;
  }

  async uploadImage(file: Express.Multer.File, bucket: string = 'struk'): Promise<string> {
    const fileName = `${Date.now()}-${file.originalname}`;
    
    // Gunakan bucket 'struk-images' sesuai yang ada di Supabase
    const targetBucket = 'struk-images';

    const { data, error } = await this.client
      .storage
      .from(targetBucket)
      .upload(fileName, file.buffer, {
        contentType: file.mimetype,
        upsert: false
      });

    if (error) {
      throw new Error(`Gagal upload gambar ke Supabase: ${error.message}`);
    }

    const { data: publicUrlData } = this.client
      .storage
      .from(targetBucket)
      .getPublicUrl(fileName);

    return publicUrlData.publicUrl;
  }
}
