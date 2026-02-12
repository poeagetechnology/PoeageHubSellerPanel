import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

      ],
      child: MaterialApp(
        title: 'Seller Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',

        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/waiting': (_) => const WaitingApprovalScreen(),
          '/rejected': (_) => const RejectedScreen(),
          '/home': (_) => const HomeScreen(),
          '/add-product': (_) => const AddProductScreen(),


          '/edit-product': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            if (args is Product) {
              return AddProductScreen(product: args);
            }

            return const Scaffold(
              body: Center(
                child: Text('Invalid product data'),
              ),
            );
          },

          VendorProfileScreen.routeName: (_) =>
          const VendorProfileScreen(),
          ProductManagementScreen.routeName: (_) =>
          const ProductManagementScreen(),
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


        onGenerateRoute: (settings) {
          if (settings.name == NotificationsScreen.routeName) {
            final sellerId = settings.arguments;

            if (sellerId is String) {
              return MaterialPageRoute(
                builder: (_) => NotificationsScreen(sellerId: sellerId),
              );
            }
          }

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Route not found'),
              ),
            ),
          );
        },
      ),
    );
  }
}