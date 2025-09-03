// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/success_screen.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../widgets/file_picker_drawer.dart';

class ApplicationForm extends StatefulWidget {
  const ApplicationForm({super.key});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  String? selectedFilePath;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController issueController = TextEditingController();
  final TextEditingController refController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  PlatformFile? selectedFile;
  bool isSubmitting = false;

  void handleFilePicked(String path) async {
    final file = File(path);
    final fileSize = await file.length();

    const maxSize = 4 * 1024 * 1024; // 5MB

    if (fileSize > maxSize) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ File too large. Max allowed size is 5MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // Don't set the file
    }

    setState(() {
      selectedFilePath = path;
      selectedFile = PlatformFile(
        name: path.split('/').last,
        path: path,
        size: fileSize,
      );
    });
  }

  Future<void> _submitForm(String cId) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
      final apiUrl = (Platform.isAndroid && useEmulator)
          ? dotenv.env['API_URL_EMULATOR']
          : dotenv.env['API_URL'];

      final uri = Uri.parse('$apiUrl/form.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['c_id'] = cId;
      request.fields['issue'] = issueController.text.trim();
      request.fields['description'] = descController.text.trim();
      request.fields['ref_numb'] = refController.text.trim();

      debugPrint('📤 Submitting Form...');
      debugPrint('🔗 Endpoint: $uri');
      debugPrint('📝 Fields: ${request.fields}');

      if (selectedFilePath != null) {
        final file = await http.MultipartFile.fromPath(
          'media',
          selectedFilePath!,
        );
        request.files.add(file);
      } else {
        debugPrint('⚠️ No file selected');
      }

      try {
        final client = http.Client();
        final streamedResponse = await client
            .send(request)
            .timeout(const Duration(seconds: 40));
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('✅ Response Code: ${response.statusCode}');
        debugPrint('📦 Response Body: ${response.body}');

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['success'] == true) {
          _formKey.currentState!.reset();
          issueController.clear();
          descController.clear();
          refController.clear();
          setState(() {
            selectedFile = null;
            selectedFilePath = null;
          });

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()),
            );
          }
        } else {
          final msg = responseBody['message'] ?? 'Unknown error';
          // ignore: unused_local_variable
          final errorCode = responseBody['error'];

          if (msg.contains('Media upload error: 1')) {
            // Specific error handling for file too large
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "File too large. Please upload a file under 5MB.",
                ),
                backgroundColor: Color.fromARGB(255, 236, 122, 114),
              ),
            );
          } else {
            // Generic error
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $msg')));
          }
        }
      } catch (e, stack) {
        debugPrint('❌ Upload exception: $e');
        debugPrint('🔍 Stack trace:\n$stack');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Application Form"),
          backgroundColor: const Color(0xFF4187C5),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Issue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: issueController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter issue' : null,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Reference No./Application No. (If any)",
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: refController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: descController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter description'
                      : null,
                ),
                const SizedBox(height: 16),

                const Text("Upload File (If any)"),
                const SizedBox(height: 6),
                FilePickerDrawer(onFilePicked: handleFilePicked),

                const SizedBox(height: 16),
                if (selectedFilePath != null)
                  Text('Selected File: ${selectedFilePath!.split('/').last}')
                else
                  Text(
                    selectedFile?.name ?? "No file chosen",
                    style: const TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 12),
                const Text(
                  "* File should be of jpeg, jpg, png and pdf format.\n* For multiple files, merge into a single pdf.\n* Pdf file size should be less than 5MB.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 24),
                Center(
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => _submitForm(userProvider.cId ?? ''),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.deepOrange.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Submit"),
                        ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "← Go Back",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
