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

  factory Pemasukan.fromJson(Map<String, dynamic> json) {
    return Pemasukan(
      id: json['id'] as String,
      penggunaId: json['penggunaId'] as String,
      kategoriId: json['kategoriId'] as String?,
      kategoriNama: json['kategoriNama'] as String?,
      deskripsi: json['deskripsi'] as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      tanggal: DateTime.parse(json['tanggal'] as String),
      catatan: json['catatan'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'penggunaId': penggunaId,
      'kategoriId': kategoriId,
      'kategoriNama': kategoriNama,
      'deskripsi': deskripsi,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
