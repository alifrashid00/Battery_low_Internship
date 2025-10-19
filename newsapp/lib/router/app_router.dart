import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/news_list_page.dart';
import '../pages/news_detail_page.dart';

class AppRouter {
  static const String home = '/';
  static const String newsDetail = '/news/:id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const NewsListPage(),
      ),
      GoRoute(
        path: newsDetail,
        name: 'newsDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NewsDetailPage(newsId: id);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.fullPath}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
