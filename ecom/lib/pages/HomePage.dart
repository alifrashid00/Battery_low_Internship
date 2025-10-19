import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../models/fake_store_product.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/top_tabs.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openCart(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _CartSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);
    final cart = ref.watch(cartProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shop'),
          elevation: 0,
          bottom: const TopTabs(currentIndex: 0),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.refresh(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab-cart',
          tooltip: 'Cart',
          onPressed: () => _openCart(context, ref),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 26),
              if (cart.totalItems > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(context, state, notifier, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductListState state,
    ProductListNotifier notifier,
    WidgetRef ref,
  ) {
    if (state.loading && state.products.isEmpty) {
      return _ShimmerGrid();
    }

    if (state.error != null && state.products.isEmpty) {
      return _ErrorView(message: state.error!, onRetry: notifier.load);
    }

    if (state.products.isEmpty) {
      return _EmptyView(onReload: notifier.load);
    }

    return _ProductGrid(products: state.products, ref: ref);
  }
}

class _ProductGrid extends StatelessWidget {
  final List<FakeStoreProduct> products;
  final WidgetRef ref;
  const _ProductGrid({required this.products, required this.ref});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 900)
      crossAxisCount = 5;
    else if (width > 700)
      crossAxisCount = 4;
    else if (width > 500)
      crossAxisCount = 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {},
          onAddToCart: () {
            ref.read(cartProvider.notifier).add(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added to cart: ${product.title}')),
            );
          },
        );
      },
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 2;
        if (width > 900)
          crossAxisCount = 5;
        else if (width > 700)
          crossAxisCount = 4;
        else if (width > 500)
          crossAxisCount = 3;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (_, __) => const _ShimmerCard(),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('Oops!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onReload;
  const _EmptyView({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No products found'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}

class _CartSheet extends ConsumerWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Cart', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (!cart.isEmpty)
                  TextButton(
                    onPressed: cartNotifier.clear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (cart.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Your cart is empty',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.elementAt(index);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item.product.image),
                      ),
                      title: Text(
                        item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cartNotifier.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            ),
                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cartNotifier.updateQuantity(
                              item.product.id,
                              item.quantity + 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                cartNotifier.remove(item.product.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (!cart.isEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Subtotal', style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(
                        '\$${cart.subtotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final checkoutState = ref.read(
                          checkoutControllerProvider,
                        );
                        if (checkoutState.isLoading) return;
                        final controller = ref.read(
                          checkoutControllerProvider.notifier,
                        );
                        final order = await controller.placeOrder();
                        final newState = ref.read(checkoutControllerProvider);
                        if (order != null && context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order #${order.id.substring(0, 8)} placed',
                              ),
                            ),
                          );
                          controller.reset();
                        } else if (newState.hasError && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Checkout failed: ${newState.error}',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Consumer(
                        builder: (context, ref, _) {
                          final st = ref.watch(checkoutControllerProvider);
                          if (st.isLoading) {
                            return const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            );
                          }
                          return const Icon(Icons.lock_outline);
                        },
                      ),
                      label: const Text('Checkout'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
