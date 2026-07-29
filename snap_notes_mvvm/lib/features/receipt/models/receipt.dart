import 'package:equatable/equatable.dart';

class Receipt extends Equatable {
  final String? id;
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final double totalAmount; // Bersih, sudah dikurangi diskon
  final double? totalItemAmount; // Kotor, sebelum dikurangi diskon
  final double? discount;
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
    this.totalItemAmount,
    this.discount,
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
      totalItemAmount: json['totalItem'] != null
          ? (json['totalItem'] as num).toDouble()
          : null,
      discount: json['diskon'] != null
          ? (json['diskon'] as num).toDouble()
          : null,
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
      'totalItem': totalItemAmount,
      'diskon': discount,
      'gambarUrl': imageUrl,
      'sudahDikonfirmasi': isConfirmed,
      'kategoriId': categoryId,
      'kategoriNama': categoryName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Receipt copyWith({
    String? id,
    String? storeName,
    String? date,
    List<ReceiptItem>? items,
    double? totalAmount,
    double? totalItemAmount,
    double? discount,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    bool? isConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      date: date ?? this.date,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItemAmount: totalItemAmount ?? this.totalItemAmount,
      discount: discount ?? this.discount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    storeName,
    date,
    items,
    totalAmount,
    totalItemAmount,
    discount,
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
  final double? discount;
  final double totalPrice;
  final String? categoryId;
  final String? categoryName;

  const ReceiptItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.discount,
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
      discount: json['diskon'] != null
          ? (json['diskon'] as num).toDouble()
          : null,
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
      'diskon': discount,
      'subtotal': totalPrice,
      'kategoriId': categoryId,
      'kategoriNama': categoryName,
    };
  }

  ReceiptItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    double? discount,
    double? totalPrice,
    String? categoryId,
    String? categoryName,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    price,
    discount,
    totalPrice,
    categoryId,
    categoryName,
  ];
}
