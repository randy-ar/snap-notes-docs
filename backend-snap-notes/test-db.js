const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const p = await prisma.pengeluaran.findMany({
    orderBy: { tanggal: 'desc' },
    take: 5
  });
  console.log(p);
}
main()
  .catch(e => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
