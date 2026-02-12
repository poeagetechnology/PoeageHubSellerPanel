import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppNotification>> listenToNotifications(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((d) => AppNotification.fromFirestore(d)).toList());
  }

  Future<void> markAsRead(String sellerId, String notificationId) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(String sellerId, String notificationId) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}