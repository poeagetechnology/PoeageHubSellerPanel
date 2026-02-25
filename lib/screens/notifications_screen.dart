import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/notification_provider.dart';
import 'order_management_screen.dart';

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

  String getDateGroup(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }

    return "Older";
  }

  @override
  Widget build(BuildContext context) {

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

          String? lastGroup;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: filteredNotifications.map((notification) {

              final group =
              getDateGroup(notification.createdAt);

              List<Widget> widgets = [];

              /// ✅ Insert Date Header
              if (group != lastGroup) {
                widgets.add(
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      group,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
                lastGroup = group;
              }

              /// ✅ Notification Card
              widgets.add(
                Dismissible(
                  key: Key(notification.notificationId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding:
                    const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(Icons.delete,
                        color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await service.deleteNotification(
                      sellerId,
                      notification.notificationId,
                    );
                  },
                  child: GestureDetector(
                    onTap: () async {

                      /// ✅ Mark as Read
                      if (!notification.isRead) {
                        await service.markAsRead(
                          sellerId,
                          notification.notificationId,
                        );
                      }

                      /// ✅ Navigate to Order
                      if (notification.type == 'order' &&
                          notification.orderId != null) {
                        Navigator.of(context).pushNamed(
                          OrderManagementScreen.routeName,
                          arguments:
                          notification.orderId,
                        );
                      }
                    },
                    child: Card(
                      elevation: 3,
                      shape:
                      RoundedRectangleBorder(
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

                            /// 🔴 Notification Icon + Unread Dot
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

                            /// 📄 Text Section
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
                                    style:
                                    const TextStyle(
                                        fontSize: 14),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    DateFormat(
                                        'dd MMM yyyy • hh:mm a')
                                        .format(notification
                                        .createdAt),
                                    style:
                                    const TextStyle(
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
                ),
              );

              return Column(children: widgets);

            }).toList(),
          );
        },
      ),
    );
  }
}