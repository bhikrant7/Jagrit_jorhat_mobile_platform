import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
import 'package:provider/provider.dart';

Future<void> debugUserSessionData(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  debugPrint("📦 SECURE STORAGE:");
  final token = await UserSecureStorage.instance.getToken();
  final phone = await UserSecureStorage.instance.getPhone();
  final fname = await UserSecureStorage.instance.getfName();
  final lname = await UserSecureStorage.instance.getlName();
  final email = await UserSecureStorage.instance.getEmail();

  debugPrint("🔐 Token: $token");
  debugPrint("📱 Phone: $phone");
  debugPrint("👤 First Name: $fname");
  debugPrint("👤 Last Name: $lname");
  debugPrint("📧 Email: $email");

  debugPrint("🧠 PROVIDER STATE:");
  debugPrint("🆔 cId: ${userProvider.cId}");
  debugPrint("📱 Phone: ${userProvider.phone}");
  debugPrint("👤 Name: ${userProvider.firstName} ${userProvider.lastName}");
  debugPrint("📧 Email: ${userProvider.email}");
  debugPrint("🏠 Address: ${userProvider.address}");
  debugPrint("🏡 Address Type: ${userProvider.addressType ?? 'Not Set'}");
  debugPrint("Ward: ${userProvider.ward}");
  debugPrint("🏘️ Gaon Panchayat: ${userProvider.gaonPanchayat}");
  debugPrint("🏢 Block: ${userProvider.block}");
  debugPrint("🏣 Circle Office: ${userProvider.circleOffice}");
  // debugPrint("📍 District: ${userProvider.district}");
  // debugPrint("🌍 State: ${userProvider.state}");
  debugPrint("📅 Created At: ${userProvider.createdAt}");
  debugPrint("📅 Updated At: ${userProvider.updatedAt}");
  debugPrint("🔑 Remember Token: ${userProvider.rememberToken}");
  debugPrint("📧 Email Verified At: ${userProvider.emailVerifiedAt}");
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            debugUserSessionData(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debug data printed to console')),
            );
          },
          child: const Text('Press Me'),
        ),
      ),
    );
  }
}
