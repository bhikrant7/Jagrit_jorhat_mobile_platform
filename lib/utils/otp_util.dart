import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/utils/otpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
import 'package:flutter_application_2/widgets/custom_bg_scaffold.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OtpScreenUtil extends StatefulWidget {
  final Widget? destination;
  final UserModel? user;
  final String phone;
  final bool isPasswordReset;

  const OtpScreenUtil({
    super.key,
    this.destination,
    this.user,
    required this.phone,
    this.isPasswordReset = false,
  });

  @override
  State<OtpScreenUtil> createState() => _OtpScreenUtilState();
}

class _OtpScreenUtilState extends State<OtpScreenUtil> {
  final _formOtpKey = GlobalKey<FormState>();
  final Color primaryBgColor = const Color.fromRGBO(237, 232, 228, 1);
  final Color primaryColor = const Color.fromARGB(255, 65, 135, 197);

  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

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
        body: jsonEncode({"phone": widget.phone, "otp": otpController.text}),
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
        //next action will be handled by the caller
        if (!widget.isPasswordReset) {
          ///  Save to secure storage
          await UserSecureStorage.instance.setToken(token);
          await UserSecureStorage.instance.setPhone(userJson['phone'] ?? '');
          await UserSecureStorage.instance.setfName(userJson['f_name'] ?? '');
          await UserSecureStorage.instance.setlName(userJson['l_name'] ?? '');
          await UserSecureStorage.instance.setEmail(userJson['email'] ?? '');

          /// Set user in Provider
          if (!mounted) return;
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.setUser(
            cId: userJson['c_id']?.toString() ?? '',
            phone: userJson['phone'] ?? '',
            firstName: userJson['f_name'] ?? '',
            lastName: userJson['l_name'] ?? '',
            email: userJson['email'] ?? '',
            address: userJson['address'] ?? '',
            addressType: userJson['address_type'] ?? 'rural',
            gaonPanchayat: userJson['gaon_panchayat'] ?? '',
            ward: userJson['ward'] ?? '',
            block: userJson['block'] ?? '',
            circleOffice: userJson['circle_office'] ?? '',
            emailVerifiedAt: userJson['email_verified_at'] ?? '',
            rememberToken: userJson['remember_token'] ?? '', // fixed key
            createdAt: userJson['created_at'] ?? '',
            updatedAt: userJson['updated_at'] ?? '',
          );
        }

        if (!mounted) return;
        _showCustomSnackBar(
          message: "OTP verified successfully (অ’টিপি সফলতাৰে সত্যাপিত)",
          isError: false,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("OTP verified successfully")),
        // );
        Widget target = widget.destination ?? const HomeScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      } else {
        // _showCustomSnackBar(
        //   message: responseData['message'] ?? 'OTP verification failed',
        //   isError: true,
        // );
        throw Exception(responseData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      debugPrint('❌ OTP Verification Error: $e');

      if (!mounted) return;
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(e.toString())));
      _showCustomSnackBar(
        message:
            Text(e.toString()).data ??
            'An error occurred during OTP verification',
        isError: true,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Call it as soon as screen loads
    if (widget.user != null) {
      debugPrint("📱 User Phone: ${widget.user?.phone}");
      debugPrint("👤 User Name: ${widget.user?.firstName}");
      debugPrint("📧 Email: ${widget.user?.email}");
    }
  }

  Future<void> _sendOtp() async {
    final phone = widget.phone;
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
              // Removed bottom padding from here to let the white BG touch the bottom
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 0.0),
              decoration: BoxDecoration(
                color: primaryBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                // This Column keeps the footer pinned while the form scrolls
                children: [
                  Expanded(
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
                              '${widget.user?.phone} ফোন নম্বৰত প্ৰেৰণ কৰা অ’টিপি',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            Text(
                              'OTP sent to ${widget.user?.phone}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 30.0),

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
                              decoration: _inputDecoration(
                                'Enter OTP (অ’টিপি)',
                                Icons.lock,
                              ),
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
                                        'Verify (সত্যাপন কৰক)',
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
                                        final response =
                                            await OtpService.sendOtp(
                                              phone: widget.user?.phone ?? '',
                                            );
                                        if (response['success'] == true) {
                                          // ignore: use_build_context_synchronously
                                          _showCustomSnackBar(
                                            message:
                                                "OTP resent successfully (অ’টিপি সফলতাৰে পুনৰ প্ৰেৰণ কৰা হৈছে)",
                                            isError: false,
                                          );
                                        } else {
                                          throw Exception(
                                            response['message'] ??
                                                'Failed to resend OTP',
                                          );
                                        }
                                      } catch (e) {
                                        // ignore: use_build_context_synchronously
                                        // ScaffoldMessenger.of(
                                        //   // ignore: use_build_context_synchronously
                                        //   context,
                                        // ).showSnackBar(
                                        //   SnackBar(content: Text(e.toString())),
                                        // );
                                        _showCustomSnackBar(
                                          message:
                                              Text(e.toString()).data ??
                                              'An error occurred while resending OTP',
                                          isError: true,
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    },
                              child: Text(
                                'Resend OTP (অ’টিপি পুনৰ পঠাওক)',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Footer Section (Pinned at bottom of white region) ---
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
                        // Ensures white BG extends behind system nav bar
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      label: Text(label),

      labelStyle: TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
      hintText: 'Enter $label',
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon, color: primaryColor),

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
