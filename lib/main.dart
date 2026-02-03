import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/waiting_approval_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/vendor_profile_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/order_management_screen.dart';
import 'screens/payments_payouts_screen.dart';
import 'screens/reports_analytics_screen.dart';
import 'screens/support_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/rejected_screen.dart';
import 'screens/offer_banner_screen.dart';
import 'screens/offer_scroller_screen.dart';

import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Seller Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/waiting': (context) => const WaitingApprovalScreen(),
          '/rejected': (context) => const RejectedScreen(),
          '/home': (context) => const HomeScreen(),
          '/add-product': (context) => const AddProductScreen(),
          '/edit-product': (context) => AddProductScreen(
            product:
            ModalRoute.of(context)!.settings.arguments as Product,
          ),

          // Management screens
          VendorProfileScreen.routeName: (_) =>
          const VendorProfileScreen(),
          ProductManagementScreen.routeName: (_) =>
          const ProductManagementScreen(),
          NotificationsScreen.routeName: (_) =>
          const NotificationsScreen(),
          OrderManagementScreen.routeName: (_) =>
          const OrderManagementScreen(),
          PaymentsPayoutsScreen.routeName: (_) =>
          const PaymentsPayoutsScreen(),
          ReportsAnalyticsScreen.routeName: (_) =>
          const ReportsAnalyticsScreen(),
          SupportScreen.routeName: (_) => const SupportScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
          OfferBannerScreen.routeName: (_) =>
          const OfferBannerScreen(),
          OfferScrollerScreen.routeName: (_) =>
          const OfferScrollerScreen(),
        },
      ),
    );
  }
}