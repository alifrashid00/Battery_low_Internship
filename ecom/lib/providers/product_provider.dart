import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fake_store_product.dart';
import '../services/fake_store_service.dart';

final fakeStoreServiceProvider = Provider<FakeStoreService>((ref) {
  return FakeStoreService();
});

class ProductListState {
  final List<FakeStoreProduct> products;
  final bool loading;
  final String? error;

  const ProductListState({
    this.products = const [],
    this.loading = false,
    this.error,
  });

  ProductListState copyWith({
    List<FakeStoreProduct>? products,
    bool? loading,
    String? error,
  }) => ProductListState(
    products: products ?? this.products,
    loading: loading ?? this.loading,
    error: error,
  );
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier(this._service) : super(const ProductListState());
  final FakeStoreService _service;

  Future<void> load() async {
    if (state.loading) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _service.fetchProducts();
      state = state.copyWith(products: items, loading: false, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await load();
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      final service = ref.watch(fakeStoreServiceProvider);
      final notifier = ProductListNotifier(service);
      // eager load
      notifier.load();
      return notifier;
    });
