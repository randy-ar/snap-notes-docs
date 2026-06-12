import 'package:json_annotation/json_annotation.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/data/models/receipt_item_model.dart';

part 'receipt_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReceiptModel extends ReceiptEntity {
  @JsonKey(name: 'namaToko')
  final String modelStoreName;

  @JsonKey(name: 'tanggalBelanja')
  final String modelDate;

  @JsonKey(name: 'total')
  final double modelTotalAmount;

  @JsonKey(name: 'items')
  final List<ReceiptItemModel> modelItems;

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'gambarUrl')
  final String? imageUrl;

  @JsonKey(name: 'sudahDikonfirmasi')
  final bool? isConfirmed;

  @JsonKey(name: 'kategoriId')
  final String? modelCategoryId;

  @JsonKey(name: 'kategoriNama')
  final String? modelCategoryName;

  @JsonKey(name: 'createdAt')
  final DateTime? modelCreatedAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? modelUpdatedAt;

  const ReceiptModel({
    this.id,
    required this.modelStoreName,
    required this.modelDate,
    required this.modelItems,
    required this.modelTotalAmount,
    this.imageUrl,
    this.isConfirmed,
    this.modelCategoryId,
    this.modelCategoryName,
    this.modelCreatedAt,
    this.modelUpdatedAt,
  }) : super(
         id: id,
         storeName: modelStoreName,
         date: modelDate,
         items: modelItems,
         totalAmount: modelTotalAmount,
         imageUrl: imageUrl,
         isConfirmed: isConfirmed,
         categoryId: modelCategoryId,
         categoryName: modelCategoryName,
         createdAt: modelCreatedAt,
         updatedAt: modelUpdatedAt,
       );

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => _$ReceiptModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptModelToJson(this);
}
