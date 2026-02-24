import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String notificationId;
  final String sellerId;
  final String title;
  final String message;
  final String type; // order, payment, system
  final String referenceId;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;

  AppNotification({
    required this.notificationId,
    required this.sellerId,
    required this.title,
    required this.message,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppNotification(
      notificationId: doc.id,
      sellerId: data['sellerId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'system',
      referenceId: data['referenceId'] ?? '',
      isRead: data['isRead'] ?? false,
      orderId: data['orderId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}