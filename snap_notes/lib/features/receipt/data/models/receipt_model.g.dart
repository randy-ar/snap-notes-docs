// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
  id: json['id'] as String?,
  modelStoreName: json['namaToko'] as String,
  modelDate: json['tanggalBelanja'] as String,
  modelItems: (json['items'] as List<dynamic>)
      .map((e) => ReceiptItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  modelTotalAmount: (json['total'] as num).toDouble(),
  imageUrl: json['gambarUrl'] as String?,
  isConfirmed: json['sudahDikonfirmasi'] as bool?,
  modelCategoryId: json['kategoriId'] as String?,
  modelCategoryName: json['kategoriNama'] as String?,
  modelCreatedAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  modelUpdatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'namaToko': instance.modelStoreName,
      'tanggalBelanja': instance.modelDate,
      'total': instance.modelTotalAmount,
      'items': instance.modelItems.map((e) => e.toJson()).toList(),
      'id': instance.id,
      'gambarUrl': instance.imageUrl,
      'sudahDikonfirmasi': instance.isConfirmed,
      'kategoriId': instance.modelCategoryId,
      'kategoriNama': instance.modelCategoryName,
      'createdAt': instance.modelCreatedAt?.toIso8601String(),
      'updatedAt': instance.modelUpdatedAt?.toIso8601String(),
    };
