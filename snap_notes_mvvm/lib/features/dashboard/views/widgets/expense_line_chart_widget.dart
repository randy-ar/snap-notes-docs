import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes_mvvm/features/dashboard/viewmodels/dashboard_viewmodel.dart';

const Color colorGreen = Color(0xFF22C55E); // Tailwind Green 500
const Color colorRed = Color(0xFFEF4444); // Tailwind Red 500

class ExpenseLineChartWidget extends StatelessWidget {
  const ExpenseLineChartWidget({super.key});

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  String _formatYAxis(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final trendData = viewModel.monthlyTrend;
    final isTrendLoading = viewModel.isTrendLoading;

    if (isTrendLoading) {
      return Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(LucideIcons.chevronLeft, size: 16),
                const Text('Periode').small().semiBold(),
                const Icon(LucideIcons.chevronRight, size: 16),
              ],
            ),
            const Gap(24),
            const SizedBox(height: 220),
          ],
        ).asSkeleton(),
      );
    }

    if (trendData.isEmpty) {
      return Card(
        padding: const EdgeInsets.all(16),
        child: const SizedBox(
          height: 300,
          child: Center(
            child: Text(
              'Gagal memuat grafik atau data kosong. Coba muat ulang.',
            ),
          ),
        ),
      );
    }

    // Hitung nilai maksimum Y untuk autoscaling chart
    double maxVal = 100000; // nilai default minimal
    for (final item in trendData) {
      final double pem = item['totalPemasukan'] as double;
      final double peng = item['totalPengeluaran'] as double;
      if (pem > maxVal) maxVal = pem;
      if (peng > maxVal) maxVal = peng;
    }
    // Berikan ruang/padding atas 15% pada Y axis
    maxVal = maxVal * 1.15;

    // Persiapkan data spot untuk fl_chart
    final List<FlSpot> spotsPemasukan = [];
    final List<FlSpot> spotsPengeluaran = [];

    for (int i = 0; i < trendData.length; i++) {
      spotsPemasukan.add(
        FlSpot(i.toDouble(), trendData[i]['totalPemasukan'] as double),
      );
      spotsPengeluaran.add(
        FlSpot(i.toDouble(), trendData[i]['totalPengeluaran'] as double),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Chart & Navigasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                onPressed: () => viewModel.prevSixMonths(),
              ),
              Text(
                '${trendData.last['tahun']} Periode ${trendData.last['bulan'] <= 6 ? 1 : 2}',
              ).small().semiBold(),
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: const Icon(LucideIcons.chevronRight, size: 16),
                onPressed: () => viewModel.nextSixMonths(),
              ),
            ],
          ),
          const Gap(24),
          // Line Chart View
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trendData.length) {
                          final label = _getMonthName(
                            trendData[index]['bulan'],
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(label).xSmall().muted(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        // Hanya tampilkan 5 pembagian sumbu Y
                        if (value == 0 ||
                            value == meta.max ||
                            (value - (meta.max / 2)).abs() < (meta.max / 4)) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(_formatYAxis(value)).xSmall().muted(),
                          );
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(_formatYAxis(value)).xSmall().muted(),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: maxVal,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        Theme.of(context).colorScheme.card,
                    tooltipBorder: BorderSide(
                      color: Theme.of(context).colorScheme.border,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isPemasukan = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isPemasukan ? 'Pemasukan' : 'Pengeluaran'}\n',
                          TextStyle(
                            color: isPemasukan ? colorGreen : colorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: currencyFormat.format(spot.y),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.foreground,
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Line Pemasukan (Garis Hijau)
                  LineChartBarData(
                    spots: spotsPemasukan,
                    isCurved: true,
                    color: colorGreen.withValues(alpha: 0.8),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colorGreen.withValues(alpha: 0.4),
                          colorGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Line Pengeluaran (Garis Merah)
                  LineChartBarData(
                    spots: spotsPengeluaran,
                    isCurved: true,
                    color: colorRed.withValues(alpha: 0.8),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colorRed.withValues(alpha: 0.4),
                          colorRed.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(6),
        Text(label).xSmall().muted(),
      ],
    );
  }
}
