import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/notification_provider.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {

  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {

    /// ✅ Always use FirebaseAuth UID (Production Safe)
    final sellerId = FirebaseAuth.instance.currentUser!.uid;

    final notificationsAsync =
    ref.watch(notificationsStreamProvider(sellerId));

    final service =
    ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 2,
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black),
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
          const SizedBox(width: 12),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No notifications found',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {

              final AppNotification notification =
              filteredNotifications[index];

              return Dismissible(
                key: Key(notification.notificationId),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete,
                      color: Colors.white),
                ),

                /// ✅ FIXED delete call
                onDismissed: (_) async {
                  await service.deleteNotification(
                    sellerId,
                    notification.notificationId,
                  );
                },

                child: GestureDetector(

                  /// ✅ FIXED markAsRead call
                  onTap: () async {
                    if (!notification.isRead) {
                      await service.markAsRead(
                        sellerId,
                        notification.notificationId,
                      );
                    }
                  },

                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Stack(
                            children: [
                              const Icon(
                                Icons.notifications,
                                size: 30,
                                color: Colors.blue,
                              ),
                              if (!notification.isRead)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration:
                                    const BoxDecoration(
                                      color: Colors.red,
                                      shape:
                                      BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight:
                                    notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  notification.message,
                                  style: const TextStyle(
                                      fontSize: 14),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  DateFormat(
                                      'dd MMM yyyy • hh:mm a')
                                      .format(notification
                                      .createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}