import 'package:equatable/equatable.dart';

class RingkasanDashboard extends Equatable {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;

  const RingkasanDashboard({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
  });

  factory RingkasanDashboard.fromJson(Map<String, dynamic> json) {
    return RingkasanDashboard(
      totalPemasukan: (json['totalPemasukan'] as num).toDouble(),
      totalPengeluaran: (json['totalPengeluaran'] as num).toDouble(),
      saldo: (json['saldo'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [totalPemasukan, totalPengeluaran, saldo];
}
