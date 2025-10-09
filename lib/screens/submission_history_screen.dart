import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/pdf_viewer_screen.dart';
import 'package:flutter_application_2/screens/track_status_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:provider/provider.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  State<SubmissionHistoryScreen> createState() =>
      _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  late Future<List<dynamic>> _submissionsFuture;

  Future<List<dynamic>> fetchSubmissions(String cId) async {
    final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
    final apiUrl = (Platform.isAndroid && useEmulator)
        ? dotenv.env['API_URL_EMULATOR']
        : dotenv.env['API_URL'];

    final url = Uri.parse('$apiUrl/fetchform.php?c_id=$cId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          return jsonData['data'];
        } else {
          throw Exception("Failed: ${jsonData['message'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final cId = Provider.of<UserProvider>(context, listen: false).cId!;
    _submissionsFuture = fetchSubmissions(cId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4187C5),
        foregroundColor: Colors.white,
        title: const Text(
          'Submission History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _submissionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ ${snapshot.error}"));
          }

          final submissions = snapshot.data!;
          if (submissions.isEmpty) {
            return const Center(child: Text("No submissions found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final s = submissions[index];
              final createdAt = DateTime.tryParse(s['created_at'] ?? '');

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Issue and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s['issue'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (createdAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Reference Number
                    if (s['ref_numb'] != null && s['ref_numb'] != '')
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s['ref_numb'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    /// Description
                    Text(
                      s['description'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 10),

                    /// Attachment
                    // Row(
                    //   children: [
                    //     const Icon(
                    //       Icons.attachment,
                    //       size: 18,
                    //       color: Colors.grey,
                    //     ),
                    //     const SizedBox(width: 6),
                    //     Expanded(
                    //       child:
                    //           s['img_url'] != null &&
                    //               s['img_url'].toString().isNotEmpty
                    //           ? InkWell(
                    //               onTap: () async {
                    //                 final url = Uri.parse(s['img_url']);
                    //                 if (await canLaunchUrl(url)) {
                    //                   await launchUrl(
                    //                     url,
                    //                     mode: LaunchMode.externalApplication,
                    //                   );
                    //                 } else {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     const SnackBar(
                    //                       content: Text("Could not open file"),
                    //                     ),
                    //                   );
                    //                 }
                    //               },
                    //               child: const Text(
                    //                 'Open Attachment',
                    //                 style: TextStyle(
                    //                   color: Colors.blue,
                    //                   decoration: TextDecoration.underline,
                    //                 ),
                    //               ),
                    //             )
                    //           : const Text(
                    //               'No file attached',
                    //               style: TextStyle(color: Colors.grey),
                    //             ),
                    //     ),
                    //   ],
                    // ),

                    /// Attachment preview
                    /// Attachment Preview
                    if (s['img_url'] != null &&
                        s['img_url'].toString().isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.attach_file, size: 18, color: Colors.grey),
                          SizedBox(width: 6),
                          Text(
                            "Attachment (সংলগ্নক):",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (s['img_url'].toString().endsWith(".pdf"))
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PDFViewerScreen(
                                  url: getFileUrl(s['img_url']),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("View PDF (PDF চাওক)"),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            getFileUrl(s['img_url']),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Text("⚠️ Could not load image"),
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const CircularProgressIndicator(),
                          ),
                        ),
                    ] else
                      const Text(
                        "No file attached (কোনো ফাইল সংলগ্ন কৰা নাই)",
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 14),

                    /// Track Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.8, // 80% height drawer
                                child: TrackStatusScreen(
                                  applicationId: int.parse(
                                    s['a_id'].toString(),
                                  ),
                                ),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4187C5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(
                            Icons.track_changes,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Track (ট্ৰেক)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String getFileUrl(String raw) {
  if (raw.startsWith("http")) return raw;
  return '${dotenv.env['API_URL']}/uploads/tmp/$raw';
}
