import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String notificationId;
  final String sellerId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.sellerId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      notificationId: doc.id,
      sellerId: data['sellerId'],
      title: data['title'],
      message: data['message'],
      type: data['type'],
      isRead: data['isRead'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}