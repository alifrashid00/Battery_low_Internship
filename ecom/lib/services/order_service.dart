import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrderService {
  final SupabaseClient _client;
  OrderService(this._client);

  Future<Order> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (items.isEmpty) {
        throw Exception('No items to place order');
      }
      final double total = items.fold(
        0.0,
        (p, e) => p + ((e['unit_price'] as num) * (e['quantity'] as int)),
      );
      final orderInsert = await _client
          .from('orders')
          .insert({'user_id': userId, 'total': total})
          .select()
          .single();
      final orderId = orderInsert['id'] as String?;
      if (orderId == null) {
        throw Exception('Order insert did not return id');
      }
      final itemsWithOrderId = items
          .map((i) => {...i, 'order_id': orderId})
          .toList();
      await _client.from('order_items').insert(itemsWithOrderId);
      return fetchOrder(orderId);
    } catch (e) {
      // Re-throw with context
      throw Exception('createOrder failed: $e');
    }
  }

  Future<Order> fetchOrder(String id) async {
    final raw = await _client
        .from('orders')
        .select(
          'id,user_id,created_at,total,order_items(id,product_id,title,unit_price,quantity,image)',
        )
        .eq('id', id)
        .single();

    final orderJson = {
      'id': raw['id'],
      'user_id': raw['user_id'],
      'created_at': raw['created_at'],
      'total': raw['total'],
      'items': (raw['order_items'] as List<dynamic>)
          .map(
            (e) => {
              'id': e['id'],
              'product_id': e['product_id'],
              'title': e['title'],
              'unit_price': e['unit_price'],
              'quantity': e['quantity'],
              'image': e['image'],
            },
          )
          .toList(),
    };
    return Order.fromJson(orderJson);
  }

  Future<List<Order>> fetchOrdersForUser(String userId) async {
    final rows = await _client
        .from('orders')
        .select(
          'id,user_id,created_at,total,order_items(id,product_id,title,unit_price,quantity,image)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map<Order>((raw) {
      final json = {
        'id': raw['id'],
        'user_id': raw['user_id'],
        'created_at': raw['created_at'],
        'total': raw['total'],
        'items': (raw['order_items'] as List<dynamic>)
            .map(
              (e) => {
                'id': e['id'],
                'product_id': e['product_id'],
                'title': e['title'],
                'unit_price': e['unit_price'],
                'quantity': e['quantity'],
                'image': e['image'],
              },
            )
            .toList(),
      };
      return Order.fromJson(json);
    }).toList();
  }
}
