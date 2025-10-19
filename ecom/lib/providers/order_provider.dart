import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'auth_provider.dart';
import '../services/order_service.dart';
import 'cart_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final client = ref.watch(supabaseProvider);
  return OrderService(client);
});

final userOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(orderServiceProvider);
  return service.fetchOrdersForUser(user.id);
});

final placeOrderProvider = FutureProvider.autoDispose<Order?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final cart = ref.read(cartProvider);
  if (cart.isEmpty) return null;
  final service = ref.watch(orderServiceProvider);

  final items = cart.items.values
      .map(
        (ci) => {
          'product_id': ci.product.id,
          'title': ci.product.title,
          'unit_price': ci.product.price,
          'quantity': ci.quantity,
          'image': ci.product.image,
        },
      )
      .toList();

  final order = await service.createOrder(userId: user.id, items: items);
  // Clear cart after placing order
  ref.read(cartProvider.notifier).clear();
  // Invalidate orders list
  ref.invalidate(userOrdersProvider);
  return order;
});

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<Order?>>((ref) {
      return CheckoutController(ref);
    });

class CheckoutController extends StateNotifier<AsyncValue<Order?>> {
  CheckoutController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<Order?> placeOrder() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return null;
    }
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) {
      state = AsyncValue.error('Cart is empty', StackTrace.current);
      return null;
    }
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(orderServiceProvider);
      final items = cart.items.values
          .map(
            (ci) => {
              'product_id': ci.product.id,
              'title': ci.product.title,
              'unit_price': ci.product.price,
              'quantity': ci.quantity,
              'image': ci.product.image,
            },
          )
          .toList();
      final order = await service.createOrder(userId: user.id, items: items);
      _ref.read(cartProvider.notifier).clear();
      _ref.invalidate(userOrdersProvider);
      state = AsyncValue.data(order);
      return order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
