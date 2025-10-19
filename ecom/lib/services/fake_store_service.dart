import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fake_store_product.dart';

class FakeStoreService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  Future<List<FakeStoreProduct>> fetchProducts() async {
    final uri = Uri.parse('$_baseUrl/products');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data
          .map((e) => FakeStoreProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load products: ${res.statusCode}');
    }
  }
}
