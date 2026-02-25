import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppNotification>> listenToNotifications(String sellerId) {
    return _firestore
        .collection('notifications')
        .doc(sellerId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  Future<void> markAsRead(
      String sellerId,
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(sellerId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(
      String sellerId,
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(sellerId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> createNotification({
    required String sellerId,
    required String title,
    required String message,
    required String type,
    required String orderId,
  }) async {
    final docRef = _firestore
        .collection('notifications')
        .doc(sellerId)
        .collection('notifications')
        .doc();

    await docRef.set({
      'notificationId': docRef.id,
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }
}