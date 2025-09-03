import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OtpService {
  static final bool useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
  static final String apiUrl = (Platform.isAndroid && useEmulator)
      ? dotenv.env['API_URL_EMULATOR'] ?? ''
      : dotenv.env['API_URL'] ?? '';

  /// Send OTP to the given phone number
  static Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/send_otp.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      debugPrint("📨 Send OTP Request Body: $phone");
      debugPrint("✅ Send OTP Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Send OTP Error: $e');
      rethrow;
    }
  }

  /// Verify the OTP for the given phone number
  // static Future<Map<String, dynamic>> verifyOtp({
  //   required String phone,
  //   required String otp,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$apiUrl/verify_otp.php"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'phone': phone, 'otp': otp}),
  //     );

  //     debugPrint("📨 Verify OTP Request Body: phone=$phone, otp=$otp");
  //     debugPrint("✅ Verify OTP Response: ${response.body}");

  //     if (response.statusCode != 200) {
  //       throw Exception('Server error: ${response.statusCode}');
  //     }

  //     return jsonDecode(response.body);
  //   } catch (e) {
  //     debugPrint('❌ Verify OTP Error: $e');
  //     rethrow;
  //   }
  // }
}
