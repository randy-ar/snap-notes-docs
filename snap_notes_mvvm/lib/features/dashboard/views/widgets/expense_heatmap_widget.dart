import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:snap_notes_mvvm/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_detail_page.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_detail_page.dart';

class ExpenseHeatmapWidget extends StatefulWidget {
  final Map<DateTime, double> pengeluaranData;
  final Map<DateTime, double> pemasukanData;

  const ExpenseHeatmapWidget({
    super.key,
    required this.pengeluaranData,
    required this.pemasukanData,
  });

  @override
  State<ExpenseHeatmapWidget> createState() => _ExpenseHeatmapWidgetState();
}

class _ExpenseHeatmapWidgetState extends State<ExpenseHeatmapWidget> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);

    Widget buildHeatmapCell(DateTime date, {bool isToday = false}) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final pengeluaran = widget.pengeluaranData[dateOnly] ?? 0;
      final pemasukan = widget.pemasukanData[dateOnly] ?? 0;
      final hasPengeluaran = pengeluaran > 0;
      final hasPemasukan = pemasukan > 0;

      Color bgColor = theme.colorScheme.muted.withValues(alpha: 0.3);
      Color textColor = theme.colorScheme.foreground;

      if (hasPengeluaran && hasPemasukan) {
        // Kedua transaksi ada — gunakan gradient split
        return Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF22C55E), // Green 500 (pemasukan)
                Color(0xFFEF4444), // Red 500 (pengeluaran)
              ],
              stops: [0.5, 0.5],
            ),
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      if (hasPemasukan) {
        // Hanya pemasukan — hijau
        if (pemasukan < 100000) {
          bgColor = const Color(0xFF86EFAC); // Green 300
          textColor = Colors.black;
        } else if (pemasukan < 500000) {
          bgColor = const Color(0xFF4ADE80); // Green 400
          textColor = Colors.black;
        } else if (pemasukan < 1000000) {
          bgColor = const Color(0xFF22C55E); // Green 500
          textColor = Colors.white;
        } else if (pemasukan < 5000000) {
          bgColor = const Color(0xFF16A34A); // Green 600
          textColor = Colors.white;
        } else {
          bgColor = const Color(0xFF15803D); // Green 700
          textColor = Colors.white;
        }
      } else if (hasPengeluaran) {
        // Hanya pengeluaran — merah
        if (pengeluaran < 100000) {
          bgColor = const Color(0xFFFCA5A5); // Red 300
          textColor = Colors.black;
        } else if (pengeluaran < 500000) {
          bgColor = const Color(0xFFF87171); // Red 400
          textColor = Colors.black;
        } else if (pengeluaran < 1000000) {
          bgColor = const Color(0xFFEF4444); // Red 500
          textColor = Colors.white;
        } else if (pengeluaran < 5000000) {
          bgColor = const Color(0xFFDC2626); // Red 600
          textColor = Colors.white;
        } else {
          bgColor = const Color(0xFFB91C1C); // Red 700
          textColor = Colors.white;
        }
      }

      return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday && !hasPengeluaran && !hasPemasukan
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    return shadcn.Card(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: theme.colorScheme.foreground,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.foreground,
                size: 28,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.foreground,
                size: 28,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: theme.colorScheme.mutedForeground, fontSize: 12),
              weekendStyle:
                  TextStyle(color: theme.colorScheme.mutedForeground, fontSize: 12),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => buildHeatmapCell(day),
              todayBuilder: (context, day, focusedDay) =>
                  buildHeatmapCell(day, isToday: true),
              selectedBuilder: (context, day, focusedDay) => buildHeatmapCell(day),
              outsideBuilder: (context, day, focusedDay) =>
                  const SizedBox.shrink(),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });

              final dateOnly = DateTime(
                  selectedDay.year, selectedDay.month, selectedDay.day);
              final pengeluaran = widget.pengeluaranData[dateOnly] ?? 0;
              final pemasukan = widget.pemasukanData[dateOnly] ?? 0;

              if (pengeluaran > 0 || pemasukan > 0) {
                _showTransactionDetails(context, dateOnly, pengeluaran, pemasukan);
              }
            },
          ),
          const shadcn.Gap(12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF22C55E), 'Pemasukan'),
              const shadcn.Gap(16),
              _buildLegendItem(const Color(0xFFEF4444), 'Pengeluaran'),
            ],
          ),
          const shadcn.Gap(8),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    final theme = shadcn.Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const shadcn.Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(
      BuildContext context, DateTime tanggal, double pengeluaran, double pemasukan) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final tanggalStr = dateFormat.format(tanggal);
    final dashboardVM = context.read<DashboardViewModel>();

    shadcn.showDialog(
      context: context,
      builder: (dialogContext) {
        return shadcn.AlertDialog(
          title: shadcn.Text('Transaksi $tanggalStr'),
          content: SizedBox(
            width: 360,
            height: 380,
            child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                    future: dashboardVM.loadTransaksiHarian(tanggal),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: shadcn.CircularProgressIndicator(),
                        );
                      }

                      final pengeluaranList = snapshot.data?['pengeluaran'] ?? [];
                      final pemasukanList = snapshot.data?['pemasukan'] ?? [];

                      if (pengeluaranList.isEmpty && pemasukanList.isEmpty) {
                        return Center(
                          child: shadcn.Text('Tidak ada data transaksi').muted(),
                        );
                      }

                      final allTransactions = [
                        ...pemasukanList.map((item) => {...item, 'isPemasukan': true}),
                        ...pengeluaranList.map((item) => {...item, 'isPemasukan': false}),
                      ];

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: allTransactions.length,
                        separatorBuilder: (_, __) => const shadcn.Gap(8),
                        itemBuilder: (context, index) {
                          final item = allTransactions[index];
                          final isPemasukan = item['isPemasukan'] == true;
                          final id = item['id'] as String;
                          final title = (item['deskripsi'] as String?) ?? 'Transaksi';
                          final category = (item['kategoriNama'] as String?) ?? 'Lainnya';
                          final amount = (item['jumlah'] as num?)?.toDouble() ?? 0.0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(dialogContext);
                              if (isPemasukan) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PemasukanDetailPage(pemasukanId: id),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PengeluaranDetailPage(pengeluaranId: id),
                                  ),
                                );
                              }
                            },
                            child: shadcn.Card(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPemasukan
                                          ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                                          : const Color(0xFFEF4444).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isPemasukan
                                          ? shadcn.LucideIcons.arrowDownLeft
                                          : shadcn.LucideIcons.arrowUpRight,
                                      color: isPemasukan
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                      size: 18,
                                    ),
                                  ),
                                  const shadcn.Gap(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        shadcn.Text(title).small().semiBold(),
                                        shadcn.Text(category).xSmall().muted(),
                                      ],
                                    ),
                                  ),
                                  shadcn.Text(
                                    '${isPemasukan ? '+' : '-'} ${currencyFormat.format(amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isPemasukan
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  shadcn.OutlineButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const shadcn.Text('Tutup'),
                  ),
                ],
              );
      },
    );
  }
}
