import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  static const String _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  // Get top stories from Hacker News
  Future<List<News>> getTopHeadlines() async {
    try {
      // Get top story IDs
      final response = await http.get(Uri.parse('$_baseUrl/topstories.json'));

      if (response.statusCode == 200) {
        final List<dynamic> storyIds = json.decode(response.body);

        // Get first 20 stories
        final List<int> topStoryIds = storyIds.take(20).cast<int>().toList();

        // Fetch individual stories
        final List<News> stories = [];
        for (final id in topStoryIds) {
          final story = await _getStoryById(id);
          if (story != null) {
            stories.add(story);
          }
        }

        return stories;
      } else {
        throw Exception('Failed to load top stories');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  Future<List<News>> searchNews(String query) async {
    try {
      // Get top stories and filter by query
      final allNews = await getTopHeadlines();
      return allNews
          .where(
            (news) =>
                news.title.toLowerCase().contains(query.toLowerCase()) ||
                (news.text?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  Future<News?> getNewsById(String id) async {
    try {
      return await _getStoryById(int.parse(id));
    } catch (e) {
      return null;
    }
  }

  Future<News?> _getStoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Only return stories (not comments or other types)
        if (data['type'] == 'story') {
          return News.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
