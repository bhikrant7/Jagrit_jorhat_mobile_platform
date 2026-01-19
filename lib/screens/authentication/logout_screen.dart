import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/screens/authentication/entry_screen.dart';
import 'package:provider/provider.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    _logout();
  }

  //  Add the helper method inside the State class
  void _showCustomSnackBar({required String message, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.logout_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.blueGrey[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await UserSecureStorage.instance.clearAll();
    userProvider.clearUser();

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // 2. Show the logout message
    _showCustomSnackBar(message: "Logged out successfully");

    // 3. Navigate back to Entry screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EntryScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
