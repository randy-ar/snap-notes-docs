import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';

class ExpensePieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> kategoriData;

  const ExpensePieChartWidget({super.key, required this.kategoriData});

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

    // 2. Gunakan data dari backend
    final categoryData = widget.kategoriData;

    // 3. Jika tidak ada transaksi, tampilkan pie chart abu-abu placeholder
    if (categoryData.isEmpty) {
      return Column(
        children: [
          Card(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Kategori Pengeluaran').small().muted(),
                  ],
                ),
                const Gap(16),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: [
                        PieChartSectionData(
                          color: theme.colorScheme.muted,
                          value: 1,
                          title: 'Belum ada data',
                          radius: 85,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pengeluaran').medium().muted(),
                      Text(currencyFormat.format(0)).medium().semiBold(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            'Belum ada data pengeluaran di bulan ${_getMonthName(currentMonth)} $currentYear.',
            textAlign: TextAlign.center,
          ).xSmall().muted(),
        ],
      );
    }

    // 4. Hitung agregasi nominal per kategori
    final Map<String, double> categorySums = {};
    double totalAmount = 0.0;

    for (final item in categoryData) {
      final category = item['kategoriNama'] as String? ?? 'Lainnya';
      final amount = (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
      categorySums[category] = amount;
      totalAmount += amount;
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

      final color = _colorPalette[i % _colorPalette.length];

      final isLargest = i == 0;
      final double radius = isTouched ? 105.0 : (isLargest ? 98.0 : 85.0);

      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: isTouched || isLargest ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.card,
          ),
        ),
      );
    }

    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Kategori Pengeluaran').small().muted(),
            ],
          ),
          const Gap(16),
          SizedBox(
            height: 220,
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
                centerSpaceRadius: 0,
                sections: sections,
              ),
            ),
          ),
          const Gap(24),
          // Detail Section (on hover/touch)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
               color: theme.colorScheme.muted.withValues(alpha: 0.5),
               borderRadius: BorderRadius.circular(8),
            ),
            child: _touchedIndex != -1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _colorPalette[_touchedIndex % _colorPalette.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(8),
                        Text(sortedCategories[_touchedIndex].key).medium().semiBold(),
                      ],
                    ),
                    Text(currencyFormat.format(sortedCategories[_touchedIndex].value)).medium().semiBold(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pengeluaran').medium().muted(),
                    Text(currencyFormat.format(totalAmount)).medium().semiBold(),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
