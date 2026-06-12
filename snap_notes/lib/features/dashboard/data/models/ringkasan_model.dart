import 'package:snap_notes/features/dashboard/domain/entities/ringkasan.dart';

class RingkasanDashboardModel extends RingkasanDashboard {
  const RingkasanDashboardModel({
    required super.totalPemasukan,
    required super.totalPengeluaran,
    required super.saldo,
  });

  factory RingkasanDashboardModel.fromJson(Map<String, dynamic> json) {
    return RingkasanDashboardModel(
      totalPemasukan: (json['totalPemasukan'] as num).toDouble(),
      totalPengeluaran: (json['totalPengeluaran'] as num).toDouble(),
      saldo: (json['saldo'] as num).toDouble(),
    );
  }
}
