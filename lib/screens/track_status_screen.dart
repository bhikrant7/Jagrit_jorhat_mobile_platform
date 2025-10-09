import 'dart:convert';
// import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/track_status_timeline.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class TrackStatusScreen extends StatelessWidget {
  final int applicationId;
  const TrackStatusScreen({super.key, required this.applicationId});

  Future<List<dynamic>> fetchStatus() async {
    final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
    final apiUrl = (Platform.isAndroid && useEmulator)
        ? dotenv.env['API_URL_EMULATOR']
        : dotenv.env['API_URL'];

    final url = Uri.parse('$apiUrl/track_status.php?a_id=$applicationId');

    // DEBUG: Log the URL we are about to call
    debugPrint("🚀 [API] Fetching status from URL: $url");

    try {
      final res = await http.get(url);

      // DEBUG: Log the response status code and the raw body
      debugPrint("📦 [API] Response Status Code: ${res.statusCode}");
      debugPrint("📦 [API] Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // DEBUG: Log the decoded JSON data
        debugPrint("✅ [API] Decoded Data: $data");

        if (data is Map<String, dynamic> && data['success'] == true) {
          debugPrint("👍 [API] Request successful. Returning data.");
          return List.from(data['data']);
        } else {
          debugPrint(
            "👎 [API] Server returned success=false or invalid format.",
          );
          throw Exception(data['message'] ?? 'Unknown error from server');
        }
      } else {
        debugPrint("❌ [API] HTTP Error occurred.");
        throw Exception('HTTP ${res.statusCode}: Failed to fetch data');
      }
    } catch (e) {
      // DEBUG: Log any exception caught during the process
      debugPrint("🛑 [API] An error occurred in fetchStatus: $e");
      throw Exception("Failed to fetch status: $e");
    }
  }

  String formatDateTime(String timestamp) {
    // DEBUG: Log the input to the formatter
    debugPrint("Formatting timestamp: '$timestamp'");
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      debugPrint("⚠️ Could not parse timestamp. Returning original value.");
      return timestamp;
    }
  }

  /// Choose gradient based on status
  LinearGradient getGradient(String status) {
    // DEBUG: Log the status used to determine the gradient
    debugPrint("Getting gradient for status: '$status'");
    switch (status.toLowerCase()) {
      case 'forwarded':
        return const LinearGradient(
          colors: [
            Color(0xFF2ECC71),
            Color.fromARGB(255, 0, 192, 80),
          ], // greens
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFD35400)], // oranges
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rejected':
      case 'reverted':
      case 'blocked':
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 230, 83, 67),
            Color.fromARGB(255, 197, 28, 9),
          ], // reds
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF4187C5), Color(0xFF62A8E5)], // fallback blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Icon getTypeIcon(String type) {
    // DEBUG: Log the type used to determine the icon
    debugPrint("Getting icon for type: '$type'");
    switch (type.toLowerCase()) {
      case 'forwarded':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'rejected':
      case 'blocked':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🛠️ TrackStatusScreen building...");
    return Column(
      children: [
        // Drawer "handle"
        Container(
          width: 50,
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        const Text(
          "Track Application Status",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF4187C5),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: fetchStatus(),
            builder: (context, snapshot) {
              // DEBUG: Log the state of the FutureBuilder
              debugPrint("🔄 FutureBuilder state: ${snapshot.connectionState}");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // DEBUG: Log the error received by the FutureBuilder
                debugPrint("🔥 FutureBuilder Error: ${snapshot.error}");
                return Center(child: Text("❌ ${snapshot.error}"));
              }

              final data = snapshot.data ?? [];
              // DEBUG: Log the data received by the FutureBuilder
              debugPrint("📊 FutureBuilder has data: $data");

              if (data.isEmpty) {
                return const Center(child: Text("No status updates yet"));
              }

              // 👇 ADD THIS TRANSFORMATION LOGIC
              final formattedData = data.map((item) {
                return {
                  'remark': item['remark'],
                  'department': item['department'],
                  'created_at': item['created_at'],
                  'status': item['type'], // <-- Rename 'type' to 'status'
                };
              }).toList();

              return TrackStatusTimeline(
                statusList: List<Map<String, dynamic>>.from(
                  formattedData,
                ), // <-- Use the new list
              );
            },
          ),
        ),
      ],
    );
  }

  // The commented-out code from your original file remains here
  // ...
}

final dummyStatusData = [
  {
    'department': 'Circle Office',
    'created_at': '2025-08-20T10:30:00',
    'status': 'forwarded',
  },
  {
    'department': 'District Collector Office',
    'created_at': '2025-08-20T12:15:00',
    'status': 'forwarded',
  },
  {
    'department': 'Block Office',
    'created_at': '2025-08-20T11:00:00',
    'status': 'rejected',
  },
];
