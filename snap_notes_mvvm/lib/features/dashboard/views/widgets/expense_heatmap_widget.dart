import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final tanggalStr = dateFormat.format(tanggal);

    shadcn.showDialog(
      context: context,
      builder: (context) {
        return shadcn.AlertDialog(
          title: shadcn.Text('Transaksi $tanggalStr'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pemasukan > 0)
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const shadcn.Gap(8),
                    shadcn.Text('Pemasukan: ${currencyFormat.format(pemasukan)}'),
                  ],
                ),
              if (pemasukan > 0 && pengeluaran > 0)
                const shadcn.Gap(8),
              if (pengeluaran > 0)
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const shadcn.Gap(8),
                    shadcn.Text('Pengeluaran: ${currencyFormat.format(pengeluaran)}'),
                  ],
                ),
            ],
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
