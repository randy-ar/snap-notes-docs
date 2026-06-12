import '../../domain/entities/preferensi_notifikasi.dart';

class PreferensiNotifikasiModel extends PreferensiNotifikasi {
  const PreferensiNotifikasiModel({
    super.id,
    required super.hariAktif,
    required super.jamNotifikasi,
    required super.aktif,
  });

  factory PreferensiNotifikasiModel.fromJson(Map<String, dynamic> json) {
    return PreferensiNotifikasiModel(
      id: json['id'],
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

  factory PreferensiNotifikasiModel.fromEntity(PreferensiNotifikasi entity) {
    return PreferensiNotifikasiModel(
      id: entity.id,
      hariAktif: entity.hariAktif,
      jamNotifikasi: entity.jamNotifikasi,
      aktif: entity.aktif,
    );
  }
}
