import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Listen to notifications from ROOT collection
  Stream<List<AppNotification>> listenToNotifications(String sellerId) {
    return _firestore
        .collection('notifications')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(
      String sellerId,
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(
      String sellerId,
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Optional manual create
  Future<void> createNotification({
    required String sellerId,
    required String title,
    required String message,
    required String type,
    required String orderId,
  }) async {
    await _firestore.collection('notifications').add({
      'sellerId': sellerId,
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }
}