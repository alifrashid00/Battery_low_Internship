class OrderItem {
  final String id; // UUID from Supabase
  final int productId; // FakeStore product id
  final String title;
  final double unitPrice;
  final int quantity;
  final String image;

  OrderItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    required this.image,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    productId: json['product_id'] as int,
    title: json['title'] as String? ?? '',
    unitPrice: (json['unit_price'] as num).toDouble(),
    quantity: json['quantity'] as int,
    image: json['image'] as String? ?? '',
  );

  Map<String, dynamic> toInsert(String orderId) => {
    'order_id': orderId,
    'product_id': productId,
    'title': title,
    'unit_price': unitPrice,
    'quantity': quantity,
    'image': image,
  };
}

class Order {
  final String id; // UUID
  final String userId;
  final DateTime createdAt;
  final double total;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.total,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    total: (json['total'] as num).toDouble(),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
