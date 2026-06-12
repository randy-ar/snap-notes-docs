// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pemasukan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PemasukanModel _$PemasukanModelFromJson(Map<String, dynamic> json) =>
    PemasukanModel(
      id: json['id'] as String,
      penggunaId: json['penggunaId'] as String,
      kategoriId: json['kategoriId'] as String?,
      kategoriNama: json['kategoriNama'] as String?,
      deskripsi: json['deskripsi'] as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      tanggal: DateTime.parse(json['tanggal'] as String),
      catatan: json['catatan'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PemasukanModelToJson(PemasukanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'penggunaId': instance.penggunaId,
      'kategoriId': instance.kategoriId,
      'kategoriNama': instance.kategoriNama,
      'deskripsi': instance.deskripsi,
      'jumlah': instance.jumlah,
      'tanggal': instance.tanggal.toIso8601String(),
      'catatan': instance.catatan,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
