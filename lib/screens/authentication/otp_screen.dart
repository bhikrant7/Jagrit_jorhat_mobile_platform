import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/otpservice.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
// import 'package:flutter_application_2/utils/otpservice.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
import 'package:flutter_application_2/widgets/custom_bg_scaffold.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final Widget? destination;
  final UserModel user;

  const OtpScreen({super.key, required this.user, this.destination});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formOtpKey = GlobalKey<FormState>();
  final Color primaryColor = const Color.fromARGB(255, 65, 135, 197);

  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  Future<void> _verifyOtp() async {
    if (!_formOtpKey.currentState!.validate()) return;
    debugPrint("📨 Body at verifyOTP: ${widget.user}");

    final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
    final apiUrl = (Platform.isAndroid && useEmulator)
        ? dotenv.env['API_URL_EMULATOR']
        : dotenv.env['API_URL'];

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/verify_otp.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": widget.user.phone,
          "otp": otpController.text,
        }),
      );

      debugPrint("🔍 Raw Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to verify OTP. Server error: ${response.statusCode}',
        );
      }

      final responseData = jsonDecode(response.body);
      debugPrint("✅ OTP Verification Response: $responseData");

      if (responseData['success'] == true) {
        final userJson = responseData['user'];
        final token = responseData['token'] ?? '';

        ///  Save to secure storage
        await UserSecureStorage.instance.setToken(token);
        await UserSecureStorage.instance.setPhone(userJson['phone'] ?? '');
        await UserSecureStorage.instance.setfName(userJson['f_name'] ?? '');
        await UserSecureStorage.instance.setlName(userJson['l_name'] ?? '');
        await UserSecureStorage.instance.setEmail(userJson['email'] ?? '');

        /// Set user in Provider
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(
          cId: userJson['c_id'].toString(),
          phone: userJson['phone'],
          firstName: userJson['f_name'],
          lastName: userJson['l_name'],
          email: userJson['email'],
          address: userJson['address'] ?? '',
          addressType: userJson['address_type'] ?? 'rural', // default to 'rural'
          gaonPanchayat: userJson['gaon_panchayat'] ?? '',
          ward: userJson['ward'] ?? '',
          block: userJson['block'] ?? '',
          circleOffice: userJson['circle_office'] ?? '',
          // district: userJson['district'] ?? '',
          // state: userJson['state'] ?? '',
          emailVerifiedAt: userJson['email_verified_at'],
          rememberToken: userJson['rememberToken'],
          createdAt: userJson['created_at'] ?? '',
          updatedAt: userJson['updated_at'] ?? '',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully")),
        );
        Widget target = widget.destination ?? const HomeScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      } else {
        throw Exception(responseData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      debugPrint('❌ OTP Verification Error: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Call it as soon as screen loads

    debugPrint("📱 User Phone: ${widget.user.phone}");
    debugPrint("👤 User Name: ${widget.user.firstName}");
    debugPrint("📧 Email: ${widget.user.email}");
  }

  Future<void> _sendOtp() async {
    final phone = widget.user.phone;
    try {
      final result = await OtpService.sendOtp(phone: phone);
      debugPrint("OTP sent: $result");
    } catch (e) {
      debugPrint("Error sending OTP: $e");
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
                  key: _formOtpKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'OTP sent to ${widget.user.phone}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // OTP Field
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            (value == null ||
                                value.isEmpty ||
                                value.length != 6)
                            ? 'Enter a valid 6-digit OTP'
                            : null,
                        decoration: _inputDecoration('Enter OTP', Icons.lock),
                      ),
                      const SizedBox(height: 30.0),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: isLoading ? null : _verifyOtp,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                try {
                                  final response = await OtpService.sendOtp(
                                    phone: widget.user.phone,
                                  );
                                  if (response['success'] == true) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "OTP resent successfully",
                                        ),
                                      ),
                                    );
                                  } else {
                                    throw Exception(
                                      response['message'] ??
                                          'Failed to resend OTP',
                                    );
                                  }
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      label: Text(label),
      hintText: label,
      prefixIcon: Icon(icon),
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
