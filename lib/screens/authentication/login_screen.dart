import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/otp_util.dart';
// import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/widgets/custom_bg_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLoginKey = GlobalKey<FormState>();
  final Color primaryColor = const Color.fromARGB(255, 65, 135, 197);
  final Color primaryBgColor = const Color.fromRGBO(237, 232, 228, 1);
  bool obscurePassword = true;

  void _showCustomSnackBar({
    // required BuildContext context,
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
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
        backgroundColor: isError ? Colors.redAccent : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  //  Add controllers
  final TextEditingController phoneController = TextEditingController();

  Future<void> _loginUser() async {
    final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
    final apiUrl = (Platform.isAndroid && useEmulator)
        ? dotenv.env['API_URL_EMULATOR']
        : dotenv.env['API_URL']; // for real device or web

    debugPrint("📡 Login Request URL: $apiUrl");

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/login.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phoneNumber": phoneController.text.trim()}),
      );

      debugPrint("📡 Login Request URL: $apiUrl");
      debugPrint(
        "📦 Sent: ${jsonEncode({"phoneNumber": phoneController.text.trim()})}",
      );
      debugPrint("📬 Response: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      final result = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 200 && result['success'] == true) {
        final userData = UserModel.fromJson(result['user']);
        //  Show success message
        _showCustomSnackBar(
          message:
              result['message'] ??
              "OTP sent successfully(OTP সফলতাৰে প্ৰেৰণ কৰা হৈছে)",
          isError: false,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       result['message'] ??
        //           "OTP sent successfully(OTP সফলতাৰে প্ৰেৰণ কৰা হৈছে)",
        //     ),
        //   ),
        // );
        final phoneNum = phoneController.text;
        //  Clear inputs
        phoneController.clear();

        //  Placeholder: Navigate to otp screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreenUtil(
              destination: HomeScreen(),
              user: userData,
              phone: phoneNum,
              isPasswordReset: false,
            ),
          ),
        );
      } else if (result['message'] == "User not found") {
        //  Show user not found message
        _showCustomSnackBar(
          message:
              "User not found, please register first(ব্যৱহাৰকাৰী পোৱা নগ'ল, অনুগ্ৰহ কৰি প্ৰথমে পঞ্জীয়ন কৰক)",
          isError: true,
        );
        Navigator.pushNamed(context, '/register');
      } else {
        //  Show error message from backend
        _showCustomSnackBar(
          message: result['message'] ?? "Login failed (লগ-ইন বিফল)",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Error at login: $e");
      _showCustomSnackBar(
        message:
            "Network error, try again later (নেটৱৰ্ক ত্ৰুটি, পাছত পুনৰ চেষ্টা কৰক)",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBgScaffold(
      child: Column(
        children: [
          // Top spacing to show background
          const Expanded(flex: 1, child: SizedBox(height: 10)),

          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                25.0,
                50.0,
                25.0,
                0.0,
              ), // Removed bottom padding here
              decoration: BoxDecoration(
                color: primaryBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                // Added this Column to hold the ScrollView and Footer together
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formLoginKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22.0),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.asset(
                                    'assets/ddd.gif',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const SizedBox(height: 10.0),
                            const Text(
                              'নাগৰিকৰ লগ-ইন',
                              textAlign:
                                  TextAlign.center, // Center text for better UI
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const Text(
                              'Please login to continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 34.0),

                            // Phone Field
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter phone number (অনুগ্ৰহ কৰি আপোনাৰ ফোন নম্বৰ দিয়ক)'
                                  : null,
                              decoration: _inputDecoration(
                                'Phone Number (ফোন নং)',
                                Icons.phone,
                              ),
                            ),
                            const SizedBox(height: 25.0),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () {
                                  if (_formLoginKey.currentState!.validate()) {
                                    _loginUser();
                                  }
                                },
                                child: const Text(
                                  'Login (লগ-ইন)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Footer Section (Inside White Region) ---
                  Visibility(
                    visible: MediaQuery.of(context).viewInsets.bottom == 0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/govt_assam_white__.png',
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Government of Assam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Only show the bottom padding when the keyboard is closed
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      label: Text(label),

      labelStyle: TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
      hintText: 'Enter $label',
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            )
          : null,

      // filled: true,
      // fillColor: Colors.grey, // Very light grey background
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0), // Glow effect
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
