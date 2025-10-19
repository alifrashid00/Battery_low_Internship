class Product {
  final String id;
  final String name;
  final String type;
  final String description;
  final String shortDescription;
  final double regularPrice;
  final double? salePrice;
  final List<String> images;
  final String categories;
  final String brand;
  final bool inStock;
  final bool isVariable;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.shortDescription,
    required this.regularPrice,
    this.salePrice,
    required this.images,
    required this.categories,
    required this.brand,
    required this.inStock,
    required this.isVariable,
  });

  double get displayPrice => salePrice ?? regularPrice;
  bool get isOnSale => salePrice != null && salePrice! < regularPrice;

  factory Product.fromCsv(List<String> csvRow) {
    // Helper function to safely parse double
    double parsePrice(String priceStr) {
      if (priceStr.isEmpty) return 0.0;
      return double.tryParse(priceStr) ?? 0.0;
    }

    // Helper function to parse images
    List<String> parseImages(String imageStr) {
      if (imageStr.isEmpty) return [];
      return imageStr.split(', ').map((img) => img.trim()).toList();
    }

    // Helper function to check if in stock
    bool parseInStock(String stockStr) {
      return stockStr == '1' || stockStr.toLowerCase() == 'true';
    }

    return Product(
      id: csvRow[0], // ID
      name: csvRow[3], // Name
      type: csvRow[1], // Type
      description: csvRow[8].isNotEmpty
          ? csvRow[8]
          : csvRow[7], // Description or Short description
      shortDescription: csvRow[7], // Short description
      regularPrice: parsePrice(csvRow[25]), // Regular price
      salePrice: csvRow[24].isNotEmpty
          ? parsePrice(csvRow[24])
          : null, // Sale price
      images: parseImages(csvRow[30]), // Images
      categories: csvRow[26], // Categories
      brand: csvRow.length > 39 && csvRow[39].isNotEmpty
          ? csvRow[39]
          : 'Unknown', // Brand from attributes
      inStock: parseInStock(csvRow[12]), // In stock?
      isVariable: csvRow[1] == 'variable', // Type == variable
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: \$${displayPrice.toStringAsFixed(2)}, brand: $brand}';
  }
}
