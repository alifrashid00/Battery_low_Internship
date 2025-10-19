import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopTabs extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  const TopTabs({super.key, required this.currentIndex});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.primary.withOpacity(0.08);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: scheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withOpacity(0.06),
          ),
          tabs: const [
            Tab(text: 'Shop', icon: Icon(Icons.storefront_outlined)),
            Tab(text: 'Orders', icon: Icon(Icons.receipt_long_outlined)),
            Tab(text: 'Profile', icon: Icon(Icons.person_outline)),
          ],
          onTap: (i) {
            if (i == currentIndex) return;
            switch (i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/orders');
                break;
              case 2:
                context.go('/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}
