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

  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await UserSecureStorage.instance.clearAll(); // ✅ Clear secure storage
    userProvider.clearUser(); // ✅ Clear provider

    await Future.delayed(const Duration(milliseconds: 200));

    // Navigate back to Entry screen and remove all previous routes
    if (!mounted) return;
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
