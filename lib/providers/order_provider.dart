import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';
import '../models/order.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final ordersStreamProvider =
StreamProvider.family<List<OrderModel>, String>((ref, sellerId) {
  return ref.read(orderServiceProvider).getSellerOrders(sellerId);
});