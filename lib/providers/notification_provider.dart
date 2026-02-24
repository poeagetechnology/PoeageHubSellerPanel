import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/app_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notificationServiceProvider =
Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsStreamProvider =
StreamProvider.family<List<AppNotification>, String>(
        (ref, sellerId) {
      final service =
      ref.watch(notificationServiceProvider);

      return service.listenToNotifications(sellerId);
    });

final unreadNotificationCountProvider =
StreamProvider.family<int, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('sellerId', isEqualTo: sellerId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});