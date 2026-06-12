// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptItemModel _$ReceiptItemModelFromJson(Map<String, dynamic> json) =>
    ReceiptItemModel(
      modelName: json['namaItem'] as String,
      modelQuantity: (json['jumlah'] as num).toInt(),
      modelPrice: (json['hargaSatuan'] as num).toDouble(),
      modelTotalPrice: (json['subtotal'] as num).toDouble(),
      itemId: json['id'] as String?,
      categoryId: json['kategoriId'] as String?,
      categoryName: json['kategoriNama'] as String?,
    );

Map<String, dynamic> _$ReceiptItemModelToJson(ReceiptItemModel instance) =>
    <String, dynamic>{
      'namaItem': instance.modelName,
      'jumlah': instance.modelQuantity,
      'hargaSatuan': instance.modelPrice,
      'subtotal': instance.modelTotalPrice,
      'id': instance.itemId,
      'kategoriId': instance.categoryId,
      'kategoriNama': instance.categoryName,
    };
