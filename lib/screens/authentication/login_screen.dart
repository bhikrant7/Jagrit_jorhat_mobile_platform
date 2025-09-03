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
  bool obscurePassword = true;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "OTP sent successfully")),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found, please register first"),
          ),
        );
        Navigator.pushNamed(context, '/register');
      } else {
        //  Show error message from backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Login failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Error at login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error, try again later")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBgScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formLoginKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Please login to continue',
                        style: TextStyle(fontSize: 14, color: Colors.black45),
                      ),
                      const SizedBox(height: 40.0),

                      //  Phone
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter phone number'
                            : null,
                        decoration: _inputDecoration(
                          'Phone Number',
                          Icons.phone,
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // //  Password
                      // TextFormField(
                      //   controller: passwordController,
                      //   obscureText: obscurePassword,
                      //   obscuringCharacter: '*',
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please enter password'
                      //       : null,
                      //   decoration: _inputDecoration(
                      //     'Password',
                      //     Icons.lock,
                      //     isPassword: true,
                      //   ),
                      // ),
                      // const SizedBox(height: 10),

                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       Navigator.pushNamed(context, '/forgot-password');
                      //     },
                      //     child: Text(
                      //       'Forgot Password?',
                      //       style: TextStyle(color: primaryColor),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 20.0),

                      //  Login Button
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
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Text(
                      //       "Don't have an account? ",
                      //       style: TextStyle(color: Colors.black45),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         Navigator.pushNamed(context, '/register');
                      //       },
                      //       child: Text(
                      //         'Sign up',
                      //         style: TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           color: primaryColor,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20.0),
                    ],
                  ),
                ),
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
      hintText: 'Enter $label',
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
