import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class CartItemModel {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<CartItemModel> items;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final String? paymentMethod;

  @HiveField(5)
  final double? cashPaid;

  @HiveField(6)
  final double? change;

  @HiveField(7)
  bool? isCancelled;

  TransactionModel({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.paymentMethod = 'CASH',
    this.cashPaid = 0.0,
    this.change = 0.0,
    this.isCancelled = false,
  });

  // Getter pembantu agar UI tetap membaca boolean non-null
  bool get cancelled => isCancelled ?? false;
  String get validPaymentMethod => paymentMethod ?? 'CASH';
  double get validCashPaid => cashPaid ?? 0.0;
  double get validChange => change ?? 0.0;
}
