import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String code;

  @HiveField(2)
  String name;

  @HiveField(3)
  double price;

  @HiveField(4)
  int stock;

  @HiveField(5)
  String unit; // 'pcs', 'pack', 'bal'

  @HiveField(6, defaultValue: true)
  bool isActive;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
    required this.unit,
    this.isActive = true,
  });
}
