import { PrismaClient, JenisKategori } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Start seeding preset categories (Focused on Struk Belanja)...');

  // Bersihkan kategori preset yang ada sebelumnya untuk menghindari duplikasi
  await prisma.kategori.deleteMany({
    where: { adalahPreset: true }
  });
  console.log('Cleared existing preset categories.');

  const presetCategories = [
    { nama: 'Makanan & Minuman', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Perumahan & Utilitas', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Komunikasi', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Transportasi', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Kesehatan', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Pendidikan', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Hiburan', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Perawatan Pribadi', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Pakaian', jenis: JenisKategori.PENGELUARAN },
    { nama: 'Lain-lain', jenis: JenisKategori.PENGELUARAN },

    // PEMASUKAN
    { nama: 'Saku', jenis: JenisKategori.PEMASUKAN },
    { nama: 'Gaji', jenis: JenisKategori.PEMASUKAN },
    { nama: 'Beasiswa', jenis: JenisKategori.PEMASUKAN },
    { nama: 'Bonus', jenis: JenisKategori.PEMASUKAN },
    { nama: 'Bisnis', jenis: JenisKategori.PEMASUKAN },
    { nama: 'Lainnya', jenis: JenisKategori.PEMASUKAN },

    // KEDUANYA
    { nama: 'Transfer', jenis: JenisKategori.KEDUANYA },
    { nama: 'Utang', jenis: JenisKategori.KEDUANYA },
    { nama: 'Piutang', jenis: JenisKategori.KEDUANYA },
  ];

  for (const cat of presetCategories) {
    await prisma.kategori.create({
      data: {
        nama: cat.nama,
        jenis: cat.jenis,
        adalahPreset: true,
      },
    });
    console.log(`Created preset category: ${cat.nama} (${cat.jenis})`);
  }

  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
