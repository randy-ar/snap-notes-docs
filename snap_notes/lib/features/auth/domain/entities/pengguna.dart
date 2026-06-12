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
