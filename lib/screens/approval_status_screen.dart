import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ApprovalStatusScreen extends StatelessWidget {
  const ApprovalStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final seller = authProvider.currentSeller;

    if (seller == null) {
      return const LoginScreen();
    }


    if (seller.approvalStatus == 'approved') {
      return const HomeScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ================= PENDING =================
              if (seller.approvalStatus == 'pending') ...[
                const Icon(
                  Icons.hourglass_empty,
                  size: 90,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Account Under Review",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your documents are being verified.\nPlease wait for admin approval.",
                  textAlign: TextAlign.center,
                ),
              ],

              // ================= REJECTED =================
              if (seller.approvalStatus == 'rejected') ...[
                const Icon(
                  Icons.cancel,
                  size: 90,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Account Rejected",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    seller.rejectionReason ??
                        "No reason provided by admin.",
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () async {
                    await authProvider.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Go Back to Login"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}