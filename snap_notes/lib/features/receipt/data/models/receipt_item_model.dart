import 'package:json_annotation/json_annotation.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';

part 'receipt_item_model.g.dart';

@JsonSerializable()
class ReceiptItemModel extends ReceiptItemEntity {
  @JsonKey(name: 'namaItem')
  final String modelName;

  @JsonKey(name: 'jumlah')
  final int modelQuantity;

  @JsonKey(name: 'hargaSatuan')
  final double modelPrice;

  @JsonKey(name: 'subtotal')
  final double modelTotalPrice;

  @JsonKey(name: 'id')
  final String? itemId;

  @JsonKey(name: 'kategoriId')
  final String? categoryId;

  @JsonKey(name: 'kategoriNama')
  final String? categoryName;

  const ReceiptItemModel({
    required this.modelName,
    required this.modelQuantity,
    required this.modelPrice,
    required this.modelTotalPrice,
    this.itemId,
    this.categoryId,
    this.categoryName,
  }) : super(
         id: itemId,
         name: modelName,
         quantity: modelQuantity,
         price: modelPrice,
         totalPrice: modelTotalPrice,
         categoryId: categoryId,
         categoryName: categoryName,
       );

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) => _$ReceiptItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptItemModelToJson(this);
}
