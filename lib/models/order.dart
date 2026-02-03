import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? 'Unknown Product',
      quantity: map['quantity'] != null
          ? (map['quantity'] as num).toInt()
          : 1,
      price: map['price'] != null
          ? (map['price'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String docId;
  final String orderId;
  final String sellerId;
  final String customerId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;


  final DateTime? expectedDeliveryDate;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    required this.docId,
    required this.orderId,
    required this.sellerId,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
    this.expectedDeliveryDate,
    this.deliveredAt,
    this.cancelledAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<OrderItem> itemList = [];
    if (data['items'] is List) {
      itemList = (data['items'] as List).map((e) {
        if (e is Map<String, dynamic>) {
          return OrderItem.fromMap(e);
        } else if (e is String) {
          return OrderItem(
            productId: '',
            name: e,
            quantity: 1,
            price: 0.0,
          );
        } else {
          return OrderItem(
            productId: '',
            name: 'Unknown',
            quantity: 1,
            price: 0.0,
          );
        }
      }).toList();
    }

    return OrderModel(
      docId: doc.id,
      orderId: data['orderId'] ?? 'ORD_UNKNOWN',
      sellerId: data['sellerId'] ?? '',
      customerId: data['customerId'] ?? '',
      totalAmount: data['totalAmount'] != null
          ? (data['totalAmount'] as num).toDouble()
          : 0.0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      items: itemList,
      expectedDeliveryDate: data['expectedDeliveryDate'] != null
          ? (data['expectedDeliveryDate'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'sellerId': sellerId,
      'customerId': customerId,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((e) => e.toMap()).toList(),
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }
}