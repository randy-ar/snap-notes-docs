import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';

class PenggunaModel {
  final String id;
  final String email;
  final String namaLengkap;
  final String? fotoProfilUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PenggunaModel({
    required this.id,
    required this.email,
    required this.namaLengkap,
    this.fotoProfilUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PenggunaModel(
      id: (json['id'] ?? json['userId']) as String,
      email: json['email'] as String,
      namaLengkap: (json['namaLengkap'] as String?) ?? '',
      fotoProfilUrl: json['fotoProfilUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'namaLengkap': namaLengkap,
      'fotoProfilUrl': fotoProfilUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Pengguna toEntity() {
    return Pengguna(
      id: id,
      email: email,
      namaLengkap: namaLengkap,
      fotoProfilUrl: fotoProfilUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PenggunaModel.fromEntity(Pengguna entity) {
    return PenggunaModel(
      id: entity.id,
      email: entity.email,
      namaLengkap: entity.namaLengkap,
      fotoProfilUrl: entity.fotoProfilUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
