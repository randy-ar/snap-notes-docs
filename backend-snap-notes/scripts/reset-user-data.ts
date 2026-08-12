import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const EMAIL_TARGET = process.argv[2] || 'randyabdulrahman15@gmail.com';

async function resetUserData() {
  const pengguna = await prisma.pengguna.findUnique({
    where: { email: EMAIL_TARGET },
  });

  if (!pengguna) {
    console.error(`User dengan email ${EMAIL_TARGET} tidak ditemukan.`);
    process.exit(1);
  }

  const userId = pengguna.id;

  await prisma.$transaction([
    prisma.struk.deleteMany({ where: { penggunaId: userId } }),
    prisma.pengeluaran.deleteMany({ where: { penggunaId: userId } }),
    prisma.pemasukan.deleteMany({ where: { penggunaId: userId } }),
    prisma.preferensiNotifikasi.deleteMany({ where: { penggunaId: userId } }),
    prisma.kategori.deleteMany({
      where: { penggunaId: userId, adalahPreset: false },
    }),
  ]);

  console.log(`Data transaksi dan kustomisasi user ${EMAIL_TARGET} berhasil di-reset.`);
}

resetUserData()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
