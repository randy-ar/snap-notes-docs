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

  @override
  List<Object?> get props => [totalPemasukan, totalPengeluaran, saldo];
}
