import 'package:equatable/equatable.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt.dart';

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
  final Receipt? struk;

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

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      id: json['id'] as String,
      penggunaId: json['penggunaId'] as String,
      strukId: json['strukId'] as String?,
      kategoriId: json['kategoriId'] as String?,
      kategoriNama: json['kategoriNama'] as String?,
      deskripsi: json['deskripsi'] as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      tanggal: DateTime.parse(json['tanggal'] as String),
      catatan: json['catatan'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      struk: json['struk'] != null
          ? Receipt.fromJson(json['struk'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'penggunaId': penggunaId,
      'strukId': strukId,
      'kategoriId': kategoriId,
      'kategoriNama': kategoriNama,
      'deskripsi': deskripsi,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'struk': struk?.toJson(),
    };
  }

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
