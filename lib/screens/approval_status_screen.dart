import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class ApprovalStatusScreen extends StatelessWidget {
  const ApprovalStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final seller = authProvider.currentSeller;

    // If not logged in
    if (seller == null) {
      return const LoginScreen();
    }

    // ✅ If Approved → Go to Dashboard Automatically
    if (seller.approvalStatus == 'approved') {
      return const HomeScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ===================== PENDING =====================
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
                const SizedBox(height: 12),
                const Text(
                  "Your documents are being verified by our team.\nYou will be notified once approved.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Optional logout
                TextButton(
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
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],

              // ===================== REJECTED =====================
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

                // Rejection Reason Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    seller.rejectionReason ??
                        "No reason provided by admin.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 25),

                // ✅ NEW: Edit & Resubmit Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(
                          isEditMode: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Edit & Resubmit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 15),

                // Logout Option
                TextButton(
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
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}