import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';

class ExpensePieChartWidget extends StatefulWidget {
  final List<Pengeluaran> dataTransaksi;

  const ExpensePieChartWidget({super.key, required this.dataTransaksi});

  @override
  State<ExpensePieChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends State<ExpensePieChartWidget> {
  int _touchedIndex = -1;

  // Palette warna Tailwind yang modern & harmonis
  final List<Color> _colorPalette = const [
    Color(0xFF3B82F6), // Blue 500
    Color(0xFF10B981), // Emerald 500
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFEC4899), // Pink 500
    Color(0xFF8B5CF6), // Violet 500
    Color(0xFFEF4444), // Red 500
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFF6B7280), // Gray 500
  ];

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // 1. Dapatkan bulan dan tahun berjalan
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // 2. Filter transaksi pengeluaran untuk bulan ini
    final monthlyExpenses = widget.dataTransaksi.where((e) {
      return e.tanggal.month == currentMonth && e.tanggal.year == currentYear;
    }).toList();

    // 3. Jika tidak ada transaksi, tampilkan state kosong secara anggun
    if (monthlyExpenses.isEmpty) {
      return Card(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.chartPie,
                size: 48,
              ).muted(),
              const Gap(12),
              const Text('Kategori Pengeluaran').small().semiBold(),
              const Gap(4),
              Text(
                'Belum ada pengeluaran dicatat pada ${_getMonthName(currentMonth)} $currentYear.',
                textAlign: TextAlign.center,
              ).xSmall().muted(),
            ],
          ),
        ),
      );
    }

    // 4. Hitung agregasi nominal per kategori
    final Map<String, double> categorySums = {};
    double totalAmount = 0.0;

    for (final exp in monthlyExpenses) {
      final category = exp.kategoriNama ?? 'Lainnya';
      categorySums[category] = (categorySums[category] ?? 0.0) + exp.jumlah;
      totalAmount += exp.jumlah;
    }

    // 5. Urutkan kategori dari yang terbesar ke terkecil
    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 6. Buat section data untuk Pie Chart
    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      final isTouched = i == _touchedIndex;
      final percentage = (entry.value / totalAmount) * 100;
      
      // Batasi penggunaan index warna agar tidak out of bounds
      final color = _colorPalette[i % _colorPalette.length];
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: isTouched ? 55.0 : 45.0,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.card,
          ),
        ),
      );
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Widget
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kategori Pengeluaran').small().semiBold(),
              const Gap(2),
              Text('Distribusi bulan ${_getMonthName(currentMonth)} $currentYear').xSmall().muted(),
            ],
          ),
          const Gap(16),
          
          // Row untuk Pie Chart & Statistik Ringkas
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sections,
                  ),
                ),
              ),
              const Gap(16),
              
              // Total Pengeluaran Ringkas di samping chart
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pengeluaran').xSmall().muted(),
                    const Gap(2),
                    Text(currencyFormat.format(totalAmount)).large().semiBold(),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),
          
          // Legenda Kategori
          Column(
            children: List.generate(sortedCategories.length, (index) {
              final entry = sortedCategories[index];
              final percentage = (entry.value / totalAmount) * 100;
              final color = _colorPalette[index % _colorPalette.length];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    // Dot Warna
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(8),
                    
                    // Nama Kategori & Persentase
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key).xSmall().medium(),
                          Text('${percentage.toStringAsFixed(1)}%').xSmall().muted(),
                        ],
                      ),
                    ),
                    const Gap(16),
                    
                    // Jumlah Rupiah
                    Text(currencyFormat.format(entry.value)).xSmall().semiBold(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
