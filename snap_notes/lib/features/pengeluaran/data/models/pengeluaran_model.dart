import 'package:json_annotation/json_annotation.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/receipt/data/models/receipt_model.dart';

part 'pengeluaran_model.g.dart';

@JsonSerializable()
class PengeluaranModel extends Pengeluaran {
  const PengeluaranModel({
    required super.id,
    required super.penggunaId,
    super.strukId,
    super.kategoriId,
    super.kategoriNama,
    required super.deskripsi,
    required super.jumlah,
    required super.tanggal,
    super.catatan,
    required super.createdAt,
    required super.updatedAt,
    @JsonKey(name: 'struk') ReceiptModel? strukModel,
  }) : super(struk: strukModel);

  factory PengeluaranModel.fromJson(Map<String, dynamic> json) => _$PengeluaranModelFromJson(json);

  Map<String, dynamic> toJson() => _$PengeluaranModelToJson(this);
}
