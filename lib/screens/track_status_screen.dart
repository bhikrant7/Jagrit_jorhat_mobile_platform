import 'dart:convert';
import 'package:flutter/material.dart';
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

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic> && data['success'] == true) {
          return List.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Unknown error from server');
        }
      } else {
        throw Exception('HTTP ${res.statusCode}: Failed to fetch data');
      }
    } catch (e) {
      throw Exception("Failed to fetch status: $e");
    }
  }

  String formatDateTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  /// Choose gradient based on status
  LinearGradient getGradient(String status) {
    switch (status.toLowerCase()) {
      case 'forwarded':
        return const LinearGradient(
          colors: [Color(0xFF2ECC71), Color.fromARGB(255, 0, 192, 80)], // greens
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
          colors: [Color.fromARGB(255, 230, 83, 67), Color.fromARGB(255, 197, 28, 9)], // reds
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
    switch (type.toLowerCase()) {
      case 'forwarded':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'pending':
        return Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'rejected':
      case 'blocked':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return Icon(Icons.info,color: Colors.grey,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4187C5),
        foregroundColor: Colors.white,
        title: const Text(
          "Track Application Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // body: FutureBuilder<List<dynamic>>(
      //   future: fetchStatus(),
      //   builder: (context, snapshot) {
          body: FutureBuilder<List<dynamic>>(
            future: Future.delayed(const Duration(seconds: 1), () {
              return [
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
            }),
            builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: getGradient("pending"),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.hourglass_empty, color: Colors.orange),
                  ),
                  title: Text(
                    "Pending at DC office",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final dept = item['department']?.toString() ?? 'Unknown Dept';
              final time = formatDateTime(item['created_at'] ?? '');
              final type = item['status']?.toString() ?? 'pending';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: getGradient(type),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: getTypeIcon(type),
                  ),
                  title: Text(
                    dept,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "🕒 $time",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
