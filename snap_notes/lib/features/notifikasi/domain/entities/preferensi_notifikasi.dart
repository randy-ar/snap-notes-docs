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

  @override
  List<Object?> get props => [id, hariAktif, jamNotifikasi, aktif];
}
