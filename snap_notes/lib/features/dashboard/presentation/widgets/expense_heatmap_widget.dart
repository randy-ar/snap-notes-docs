import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';

class ExpenseHeatmapWidget extends StatelessWidget {
  final List<Pengeluaran> dataTransaksi;

  const ExpenseHeatmapWidget({super.key, required this.dataTransaksi});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);

    // 1. Transformasi data transaksi menjadi format intensitas Heatmap (DateTime -> Jumlah Transaksi)
    final Map<DateTime, int> datasetHeatmap = {};
    final Map<String, List<Pengeluaran>> groupedData = {};

    for (var pengeluaran in dataTransaksi) {
      final dateStr = "${pengeluaran.tanggal.year}-${pengeluaran.tanggal.month.toString().padLeft(2, '0')}-${pengeluaran.tanggal.day.toString().padLeft(2, '0')}";
      if (!groupedData.containsKey(dateStr)) {
        groupedData[dateStr] = [];
      }
      groupedData[dateStr]!.add(pengeluaran);

      final dateOnly = DateTime(pengeluaran.tanggal.year, pengeluaran.tanggal.month, pengeluaran.tanggal.day);
      datasetHeatmap[dateOnly] = (datasetHeatmap[dateOnly] ?? 0) + 1;
    }

    return shadcn.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const shadcn.Text(
              'Pola Aktivitas Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            shadcn.Text(
              'Makin pekat warna kotak, makin tinggi frekuensi belanja Anda.',
              style: TextStyle(color: theme.colorScheme.mutedForeground, fontSize: 12),
            ),
            const SizedBox(height: 16),
            
            // 2. Render Grid Heatmap
            HeatMapCalendar(
              defaultColor: theme.colorScheme.muted,
              textColor: theme.colorScheme.foreground, // Memberikan warna default teks yang kontras dengan theme
              flexible: true,
              colorMode: ColorMode.color,
              datasets: datasetHeatmap,
              // Memanfaatkan warna primary dari tema Shadcn dengan opasitas bergradasi
              colorsets: {
                1: theme.colorScheme.primary.withOpacity(0.25),
                2: theme.colorScheme.primary.withOpacity(0.5),
                3: theme.colorScheme.primary.withOpacity(0.75),
                4: theme.colorScheme.primary,
              },
              // 3. Logika Interaksi ketika Tanggal diklik
              onClick: (DateTime date) {
                String key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                List<Pengeluaran> transaksiHariIni = groupedData[key] ?? [];
                
                if (transaksiHariIni.isNotEmpty) {
                  _showTransactionDetails(context, key, transaksiHariIni);
                }
              },
            ),
          ],
        ),
    );
  }

  // 4. Pop-up Dialog Detail Menggunakan Shadcn Dialog
  void _showTransactionDetails(BuildContext context, String tanggal, List<Pengeluaran> listTransaksi) {
    shadcn.showDialog(
      context: context,
      builder: (context) {
        return shadcn.AlertDialog(
          title: shadcn.Text('Transaksi Tanggal $tanggal'),
          content: listTransaksi.isEmpty
              ? const shadcn.Text('Tidak ada riwayat pengeluaran atau pemindaian struk di tanggal ini.')
              : SizedBox(
                  width: 320,
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = listTransaksi[index];
                      return ListTile(
                        title: shadcn.Text(transaksi.struk?.storeName ?? transaksi.deskripsi),
                        subtitle: shadcn.Text(transaksi.kategoriNama ?? ''),
                        trailing: shadcn.Text(
                          'Rp ${transaksi.jumlah.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            shadcn.OutlineButton(
              onPressed: () => Navigator.pop(context),
              child: const shadcn.Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
