part of 'pos_cubit.dart';

class PosState extends Equatable {
  final List<ProductModel> products;
  final Map<String, CartItemModel> cart;

  const PosState({this.products = const [], this.cart = const {}});

  int get totalItemCount =>
      cart.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      cart.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  PosState copyWith({
    List<ProductModel>? products,
    Map<String, CartItemModel>? cart,
  }) {
    return PosState(
      products: products ?? this.products,
      cart: cart ?? this.cart,
    );
  }

  @override
  List<Object?> get props => [products, cart];
}
