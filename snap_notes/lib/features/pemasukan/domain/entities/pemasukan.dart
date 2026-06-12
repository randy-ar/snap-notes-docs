import 'package:equatable/equatable.dart';

class Pemasukan extends Equatable {
  final String id;
  final String penggunaId;
  final String? kategoriId;
  final String? kategoriNama;
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Pemasukan({
    required this.id,
    required this.penggunaId,
    this.kategoriId,
    this.kategoriNama,
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    });

  @override
  List<Object?> get props => [
        id,
        penggunaId,
        kategoriId,
        kategoriNama,
        deskripsi,
        jumlah,
        tanggal,
        catatan,
        createdAt,
        updatedAt,
        ];
}
