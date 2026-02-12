import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/notifications';

  final String sellerId;
  const NotificationsScreen({super.key, required this.sellerId});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {

  String selectedFilter = 'all'; // UI-level filter

  @override
  Widget build(BuildContext context) {
    final notificationsAsync =
    ref.watch(notificationsStreamProvider(widget.sellerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'order', child: Text('Orders')),
              DropdownMenuItem(value: 'payment', child: Text('Payments')),
              DropdownMenuItem(value: 'system', child: Text('System')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedFilter = value;
                });
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e')),
        data: (notifications) {
          final filteredNotifications =
          selectedFilter == 'all'
              ? notifications
              : notifications
              .where((n) => n.type == selectedFilter)
              .toList();

          if (filteredNotifications.isEmpty) {
            return const Center(
              child: Text('No notifications found'),
            );
          }

          return ListView.builder(
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final AppNotification notification =
              filteredNotifications[index];

              return ListTile(
                leading: Icon(
                  notification.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: notification.isRead
                      ? Colors.grey
                      : Colors.blue,
                ),
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: Text(
                  '${notification.createdAt.day}/'
                      '${notification.createdAt.month}/'
                      '${notification.createdAt.year}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}