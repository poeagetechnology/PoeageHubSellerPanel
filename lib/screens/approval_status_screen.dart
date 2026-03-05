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

    // If Approved → Go to Dashboard Automatically
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
                  Icons.verified_user_outlined,
                  size: 90,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),

                const Text(
                  "🟠 Status: Under Review",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                _infoTile(
                  icon: Icons.description,
                  title: "Documents Submitted",
                  subtitle: "Your verification documents are received.",
                  iconColor: Colors.green,
                ),

                const SizedBox(height: 15),

                _infoTile(
                  icon: Icons.access_time,
                  title: "Estimated Review Time",
                  subtitle: "24 – 48 Hours",
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 15),

                _infoTile(
                  icon: Icons.email_outlined,
                  title: "Email Notification",
                  subtitle:
                  "You will receive an email once your account is approved.",
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 35),

                const Text(
                  "Thank you for your patience.\nWe are reviewing your account carefully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                  "🔴 Account Rejected",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 20),

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

                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===================== Reusable Info Tile =====================
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}