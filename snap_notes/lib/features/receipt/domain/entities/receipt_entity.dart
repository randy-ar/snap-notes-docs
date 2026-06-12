import 'package:equatable/equatable.dart';

class ReceiptEntity extends Equatable {
  final String? id;
  final String storeName;
  final String date;
  final List<ReceiptItemEntity> items;
  final double totalAmount;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool? isConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReceiptEntity({
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

class ReceiptItemEntity extends Equatable {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? categoryId;
  final String? categoryName;

  const ReceiptItemEntity({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.categoryId,
    this.categoryName,
  });

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
