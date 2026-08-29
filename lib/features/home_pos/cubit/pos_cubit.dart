import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/transaction_model.dart';

part 'pos_state.dart';

class PosCubit extends Cubit<PosState> {
  final Box<ProductModel> productBox;
  final Box<TransactionModel> transactionBox;

  PosCubit(this.productBox, this.transactionBox) : super(const PosState());

  void loadProducts() {
    final activeProducts = productBox.values.where((p) => p.isActive).toList();
    emit(state.copyWith(products: activeProducts));
  }

  void addToCart(ProductModel product) {
    if (product.stock <= 0) return;

    final updatedCart = Map<String, CartItemModel>.from(state.cart);

    if (updatedCart.containsKey(product.id)) {
      final current = updatedCart[product.id]!;
      if (current.quantity < product.stock) {
        updatedCart[product.id] = CartItemModel(
          productId: current.productId,
          name: current.name,
          price: current.price,
          quantity: current.quantity + 1,
        );
      }
    } else {
      updatedCart[product.id] = CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
      );
    }
    emit(state.copyWith(cart: updatedCart));
  }

  void removeFromCart(String productId) {
    final updatedCart = Map<String, CartItemModel>.from(state.cart);
    if (!updatedCart.containsKey(productId)) return;

    if (updatedCart[productId]!.quantity > 1) {
      final current = updatedCart[productId]!;
      updatedCart[productId] = CartItemModel(
        productId: current.productId,
        name: current.name,
        price: current.price,
        quantity: current.quantity - 1,
      );
    } else {
      updatedCart.remove(productId);
    }
    emit(state.copyWith(cart: updatedCart));
  }

  void clearCart() {
    emit(state.copyWith(cart: {}));
  }

  TransactionModel? checkout({
    required String paymentMethod,
    double cashPaid = 0.0,
    double change = 0.0,
  }) {
    if (state.cart.isEmpty) return null;

    for (var cartItem in state.cart.values) {
      final productIndex = productBox.values.toList().indexWhere(
        (p) => p.id == cartItem.productId,
      );
      if (productIndex != -1) {
        final product = productBox.getAt(productIndex);
        if (product != null) {
          product.stock -= cartItem.quantity;
          product.save();
        }
      }
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: state.cart.values.toList(),
      totalAmount: state.totalPrice,
      paymentMethod: paymentMethod,
      cashPaid: cashPaid,
      change: change,
      isCancelled: false,
    );

    transactionBox.add(transaction);
    emit(
      state.copyWith(
        cart: {},
        products: productBox.values.where((p) => p.isActive).toList(),
      ),
    );

    return transaction;
  }
}
