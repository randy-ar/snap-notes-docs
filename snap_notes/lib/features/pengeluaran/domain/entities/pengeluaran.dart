import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';

class Pengeluaran extends Equatable {
  final String id;
  final String penggunaId;
  final String? strukId;
  final String? kategoriId;
  final String? kategoriNama;
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReceiptEntity? struk;

  const Pengeluaran({
    required this.id,
    required this.penggunaId,
    this.strukId,
    this.kategoriId,
    this.kategoriNama,
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.struk,
  });

  @override
  List<Object?> get props => [
        id,
        penggunaId,
        strukId,
        kategoriId,
        kategoriNama,
        deskripsi,
        jumlah,
        tanggal,
        catatan,
        createdAt,
        updatedAt,
        struk,
      ];
}
