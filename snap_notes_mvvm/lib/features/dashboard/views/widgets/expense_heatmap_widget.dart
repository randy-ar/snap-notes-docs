import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:table_calendar/table_calendar.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran.dart';
import 'package:intl/intl.dart';

class ExpenseHeatmapWidget extends StatefulWidget {
  final List<Pengeluaran> dataTransaksi;

  const ExpenseHeatmapWidget({super.key, required this.dataTransaksi});

  @override
  State<ExpenseHeatmapWidget> createState() => _ExpenseHeatmapWidgetState();
}

class _ExpenseHeatmapWidgetState extends State<ExpenseHeatmapWidget> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);

    // Transformasi data transaksi menjadi format intensitas Heatmap
    final Map<DateTime, int> datasetHeatmap = {};
    final Map<DateTime, List<Pengeluaran>> groupedData = {};

    for (var pengeluaran in widget.dataTransaksi) {
      final dateOnly = DateTime(
          pengeluaran.tanggal.year, pengeluaran.tanggal.month, pengeluaran.tanggal.day);
      if (!groupedData.containsKey(dateOnly)) {
        groupedData[dateOnly] = [];
      }
      groupedData[dateOnly]!.add(pengeluaran);
      datasetHeatmap[dateOnly] = (datasetHeatmap[dateOnly] ?? 0) + 1;
    }

    Widget buildHeatmapCell(DateTime date, {bool isToday = false}) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final intensity = datasetHeatmap[dateOnly] ?? 0;

      Color bgColor = theme.colorScheme.muted.withValues(alpha: 0.3); // Muted background for no data
      Color textColor = theme.colorScheme.foreground;

      if (intensity > 0) {
        if (intensity == 1) {
          bgColor = const Color(0xFFFCA5A5); // Red 300
          textColor = Colors.black; // Text hitam untuk background terang
        } else if (intensity == 2) {
          bgColor = const Color(0xFFF87171); // Red 400
          textColor = Colors.black; // Text hitam untuk background terang
        } else if (intensity == 3) {
          bgColor = const Color(0xFFEF4444); // Red 500
          textColor = Colors.white; // Text putih untuk background agak gelap
        } else if (intensity == 4) {
          bgColor = const Color(0xFFDC2626); // Red 600
          textColor = Colors.white; // Text putih untuk background gelap
        } else {
          bgColor = const Color(0xFFB91C1C); // Red 700
          textColor = Colors.white; // Text putih untuk background sangat gelap
        }
      }

      return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday && intensity == 0
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
      child: TableCalendar(
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
              const SizedBox.shrink(), // Hide outside days
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
          final transaksiHariIni = groupedData[dateOnly] ?? [];

          if (transaksiHariIni.isNotEmpty) {
            _showTransactionDetails(context, dateOnly, transaksiHariIni);
          }
        },
      ),
    );
  }

  void _showTransactionDetails(
      BuildContext context, DateTime tanggal, List<Pengeluaran> listTransaksi) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final tanggalStr = dateFormat.format(tanggal);

    shadcn.showDialog(
      context: context,
      builder: (context) {
        return shadcn.AlertDialog(
          title: shadcn.Text('Transaksi $tanggalStr'),
          content: listTransaksi.isEmpty
              ? const shadcn.Text('Tidak ada riwayat pengeluaran.')
              : SizedBox(
                  width: 320,
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = listTransaksi[index];
                      return ListTile(
                        title: shadcn.Text(transaksi.deskripsi),
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
