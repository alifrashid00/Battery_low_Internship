import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fake_store_product.dart';

class CartItemData {
  final FakeStoreProduct product;
  final int quantity;
  const CartItemData({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;

  CartItemData copyWith({FakeStoreProduct? product, int? quantity}) =>
      CartItemData(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );
}

class CartState {
  final Map<int, CartItemData> items; // key: productId
  const CartState({this.items = const {}});

  int get totalItems => items.values.fold(0, (p, e) => p + e.quantity);
  double get subtotal => items.values.fold(0.0, (p, e) => p + e.lineTotal);
  bool get isEmpty => items.isEmpty;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void add(FakeStoreProduct product, {int qty = 1}) {
    final current = Map<int, CartItemData>.from(state.items);
    final existing = current[product.id];
    if (existing != null) {
      current[product.id] = existing.copyWith(
        quantity: existing.quantity + qty,
      );
    } else {
      current[product.id] = CartItemData(product: product, quantity: qty);
    }
    state = CartState(items: current);
  }

  void updateQuantity(int productId, int qty) {
    if (qty <= 0) {
      remove(productId);
      return;
    }
    final current = Map<int, CartItemData>.from(state.items);
    final existing = current[productId];
    if (existing != null) {
      current[productId] = existing.copyWith(quantity: qty);
      state = CartState(items: current);
    }
  }

  void remove(int productId) {
    final current = Map<int, CartItemData>.from(state.items)..remove(productId);
    state = CartState(items: current);
  }

  void clear() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
