import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/authentication/forgot_pass_screen.dart';
import 'package:flutter_application_2/screens/authentication/logout_screen.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/auth_provider.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// import 'screens/authentication/entry_screen.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/register_screen.dart';
import 'dart:io';

Future<void> main() async {
  // Ensure Flutter bindings initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  if (dotenv.env['API_URL'] == null) {
    debugPrint("🚨 .env not loaded or API_URL missing");
  }
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Organizer',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        // '/': (context) => EntryScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/logout': (context) => const LogoutScreen(),
      },
    );
  }
}
