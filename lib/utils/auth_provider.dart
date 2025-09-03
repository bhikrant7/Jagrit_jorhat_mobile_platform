import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_application_2/screens/authentication/entry_screen.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _isTransitioning = false;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await UserSecureStorage.instance.getToken();
    final phone = await UserSecureStorage.instance.getPhone();

    if (token != null && phone != null) {
      try {
        final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
        final apiUrl = (Platform.isAndroid && useEmulator)
            ? dotenv.env['API_URL_EMULATOR']
            : dotenv.env['API_URL'];

        final response = await http.post(
          Uri.parse("$apiUrl/get_user.php"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"phone": phone, "token": token}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final user = data['user'];

            // ignore: use_build_context_synchronously
            Provider.of<UserProvider>(context, listen: false).setUser(
              cId: user['c_id'].toString(),
              phone: user['phone'] ?? '',
              firstName: user['f_name'] ?? '',
              lastName: user['l_name'] ?? '',
              email: user['email'] ?? '',
              address: user['address'] ?? '',
              addressType: user['address_type'] ?? 'rural', // Default to 'rural'
              gaonPanchayat: user['gaon_panchayat'] ?? '',
              block: user['block'] ?? '',
              circleOffice: user['circle_office'] ?? '',
              // district: user['district'] ?? '',
              // state: user['state'] ?? '',
              emailVerifiedAt: user['email_verified_at'],
              rememberToken: user['remember_token'],
              createdAt: user['created_at'],
              updatedAt: user['updated_at'],
            );
          }
        } else {
          debugPrint(
            "❌ Failed to fetch user from server: ${response.statusCode}",
          );
        }
      } catch (e) {
        debugPrint("❌ Auto-login error: $e");
      }
    }

    // Transition delay (for smoother Lottie)
    setState(() {
      _isChecking = false;
      _isTransitioning = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isTransitioning = false);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isChecking || _isTransitioning;

    if (isLoading) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/bgmain.png', fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
              ), // Dimmed blur
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/Loading Screen.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: Tween(
                    begin: 0.3,
                    end: 1.0,
                  ).animate(_breatheController),
                  child: const Text(
                    "Verifying your session...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isLoggedIn =
        Provider.of<UserProvider>(context, listen: false).phone != null;

    return isLoggedIn ? const HomeScreen() : const EntryScreen();
  }
}
