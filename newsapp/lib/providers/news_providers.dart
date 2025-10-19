import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news.dart';
import '../services/news_service.dart';

// Provider for the NewsService
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService();
});

// Provider for fetching top headlines
final topHeadlinesProvider = FutureProvider<List<News>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  return newsService.getTopHeadlines();
});

// Provider for search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for search results
final searchResultsProvider = FutureProvider<List<News>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return [];
  }

  final newsService = ref.read(newsServiceProvider);
  return newsService.searchNews(query);
});

// Provider for getting a specific news article by ID
final newsDetailProvider = FutureProvider.family<News?, String>((
  ref,
  id,
) async {
  final newsService = ref.read(newsServiceProvider);
  return newsService.getNewsById(id);
});

// Provider for managing loading states
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for managing error states
final errorProvider = StateProvider<String?>((ref) => null);
