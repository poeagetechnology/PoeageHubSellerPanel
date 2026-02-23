import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/app_notification.dart';

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