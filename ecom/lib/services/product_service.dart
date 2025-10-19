import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> loadProductsFromCsv() async {
    try {
      // Load the CSV file from assets
      final String csvData = await rootBundle.loadString(
        'Divi-Engine-WooCommerce-Sample-Products.csv',
      );

      // Parse CSV
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvData,
      );

      // Skip header row and convert to products
      final List<Product> products = [];

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];

        // Convert dynamic list to string list
        final List<String> stringRow = row
            .map((e) => e?.toString() ?? '')
            .toList();

        // Only include simple products and main variable products (not variations)
        final String type = stringRow[1];
        final String name = stringRow[3];
        final String regularPriceStr = stringRow[25];

        // Skip if no name or no price
        if (name.isEmpty || regularPriceStr.isEmpty) continue;

        // Include simple products and main variable products (not variations)
        if (type == 'simple' || type == 'variable') {
          try {
            final product = Product.fromCsv(stringRow);
            // Only add products with valid prices and images
            if (product.regularPrice > 0 && product.images.isNotEmpty) {
              products.add(product);
            }
          } catch (e) {
            print('Error parsing product row $i: $e');
            continue;
          }
        }
      }

      return products;
    } catch (e) {
      print('Error loading products from CSV: $e');
      return [];
    }
  }

  static List<Product> getFilteredProducts(
    List<Product> products, {
    String? category,
    String? brand,
    double? maxPrice,
    bool? inStockOnly,
  }) {
    return products.where((product) {
      if (category != null &&
          !product.categories.toLowerCase().contains(category.toLowerCase())) {
        return false;
      }
      if (brand != null &&
          !product.brand.toLowerCase().contains(brand.toLowerCase())) {
        return false;
      }
      if (maxPrice != null && product.displayPrice > maxPrice) {
        return false;
      }
      if (inStockOnly == true && !product.inStock) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<String> getUniqueCategories(List<Product> products) {
    final Set<String> categories = {};
    for (final product in products) {
      if (product.categories.isNotEmpty) {
        final categoryList = product.categories.split(',');
        for (final category in categoryList) {
          categories.add(category.trim());
        }
      }
    }
    return categories.toList()..sort();
  }

  static List<String> getUniqueBrands(List<Product> products) {
    final Set<String> brands = {};
    for (final product in products) {
      if (product.brand.isNotEmpty && product.brand != 'Unknown') {
        brands.add(product.brand);
      }
    }
    return brands.toList()..sort();
  }
}
