import 'package:equatable/equatable.dart';

class PreferensiNotifikasi extends Equatable {
  final String? id;
  final List<String> hariAktif;
  final String jamNotifikasi;
  final bool aktif;

  const PreferensiNotifikasi({
    this.id,
    required this.hariAktif,
    required this.jamNotifikasi,
    required this.aktif,
  });

  factory PreferensiNotifikasi.fromJson(Map<String, dynamic> json) {
    return PreferensiNotifikasi(
      id: json['id'] as String?,
      hariAktif: List<String>.from(json['hariAktif'] ?? []),
      jamNotifikasi: json['jamNotifikasi'] ?? '19:00',
      aktif: json['aktif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'hariAktif': hariAktif,
      'jamNotifikasi': jamNotifikasi,
      'aktif': aktif,
    };
  }

  @override
  List<Object?> get props => [id, hariAktif, jamNotifikasi, aktif];
}
