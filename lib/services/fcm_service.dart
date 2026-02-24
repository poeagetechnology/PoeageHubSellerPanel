import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// CALL THIS FROM initState()
  Future<void> initialize(BuildContext context) async {
    await _requestPermission();
    await _initLocalNotifications(context);
    await _saveFCMToken();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // When app opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final orderId = message.data['orderId'];
      if (orderId != null) {
        _navigateToOrder(context, orderId);
      }
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> _saveFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(user.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> _initLocalNotifications(BuildContext context) async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final orderId = response.payload;
        if (orderId != null) {
          _navigateToOrder(context, orderId);
        }
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: 0,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      notificationDetails: notificationDetails,
      payload: message.data['orderId'],
    );
  }

  void _navigateToOrder(BuildContext context, String orderId) {
    Navigator.pushNamed(
      context,
      '/order-management',
      arguments: orderId,
    );
  }
}