import 'package:equatable/equatable.dart';

class Receipt extends Equatable {
  final String? id;
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final double totalAmount;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool? isConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Receipt({
    this.id,
    required this.storeName,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.isConfirmed,
    this.createdAt,
    this.updatedAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String?,
      storeName: json['namaToko'] as String,
      date: json['tanggalBelanja'] as String,
      items: (json['items'] as List)
          .map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total'] as num).toDouble(),
      imageUrl: json['gambarUrl'] as String?,
      isConfirmed: json['sudahDikonfirmasi'] as bool?,
      categoryId: json['kategoriId'] as String?,
      categoryName: json['kategoriNama'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaToko': storeName,
      'tanggalBelanja': date,
      'items': items.map((e) => e.toJson()).toList(),
      'total': totalAmount,
      'gambarUrl': imageUrl,
      'sudahDikonfirmasi': isConfirmed,
      'kategoriId': categoryId,
      'kategoriNama': categoryName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        storeName,
        date,
        items,
        totalAmount,
        categoryId,
        categoryName,
        imageUrl,
        isConfirmed,
        createdAt,
        updatedAt,
      ];
}

class ReceiptItem extends Equatable {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? categoryId;
  final String? categoryName;

  const ReceiptItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.categoryId,
    this.categoryName,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] as String?,
      name: json['namaItem'] as String,
      quantity: json['jumlah'] as int,
      price: (json['hargaSatuan'] as num).toDouble(),
      totalPrice: (json['subtotal'] as num).toDouble(),
      categoryId: json['kategoriId'] as String?,
      categoryName: json['kategoriNama'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaItem': name,
      'jumlah': quantity,
      'hargaSatuan': price,
      'subtotal': totalPrice,
      'kategoriId': categoryId,
      'kategoriNama': categoryName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        price,
        totalPrice,
        categoryId,
        categoryName,
      ];
}
