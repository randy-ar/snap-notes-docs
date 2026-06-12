import 'package:json_annotation/json_annotation.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';

part 'pemasukan_model.g.dart';

@JsonSerializable()
class PemasukanModel extends Pemasukan {
  const PemasukanModel({
    required super.id,
    required super.penggunaId,
    super.kategoriId,
    super.kategoriNama,
    required super.deskripsi,
    required super.jumlah,
    required super.tanggal,
    super.catatan,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PemasukanModel.fromJson(Map<String, dynamic> json) => _$PemasukanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PemasukanModelToJson(this);
}
