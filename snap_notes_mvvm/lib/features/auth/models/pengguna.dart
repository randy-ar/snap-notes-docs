import 'package:equatable/equatable.dart';

class Pengguna extends Equatable {
  final String id;
  final String email;
  final String namaLengkap;
  final String? fotoProfilUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pengguna({
    required this.id,
    required this.email,
    required this.namaLengkap,
    this.fotoProfilUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Pengguna(
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

  Pengguna copyWith({
    String? id,
    String? email,
    String? namaLengkap,
    String? fotoProfilUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pengguna(
      id: id ?? this.id,
      email: email ?? this.email,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      fotoProfilUrl: fotoProfilUrl ?? this.fotoProfilUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, namaLengkap, fotoProfilUrl, createdAt, updatedAt];
}
