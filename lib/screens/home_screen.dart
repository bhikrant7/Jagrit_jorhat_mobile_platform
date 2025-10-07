import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/application_form.dart';
import 'package:flutter_application_2/screens/submission_history_screen.dart';
import 'package:flutter_application_2/screens/test_screen.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
import 'package:flutter_application_2/widgets/action_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF4187C5);
  final Color exitColor = const Color(0xFFFF8383);

  bool _isEditing = false; // track edit mode
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  // Address type (Rural / Urban)
  String? _addressType; // nullable so we can force re-selection after resets

  late TextEditingController _panchayatController;
  late TextEditingController _wardController;
  late TextEditingController _circleOfficeController;
  late TextEditingController _blockController;

  // Dropdown selections (mirroring RegisterScreen options)
  String? _selectedCircle;
  String? _selectedBlock;

  // === Options copied from RegisterScreen ===
  final List<String> blockOptions = const [
    'East Teok',
    'Central Jorhat',
    'East Jorhat',
    'Kaliapani',
    'North West Jorhat',
    'Titabor',
  ];

  final List<String> circleOptions = const [
    'Titabor Rev. Circle',
    'Teok Rev. Circle',
    'Mariani Rev. Circle',
    'East Rev. Circle',
    'West Rev. Circle',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    _firstNameController = TextEditingController(text: user.firstName ?? "");
    _lastNameController = TextEditingController(text: user.lastName ?? "");
    _emailController = TextEditingController(text: user.email ?? "");
    _addressController = TextEditingController(text: user.address ?? "");

    _panchayatController = TextEditingController(
      text: user.gaonPanchayat ?? "",
    );
    _wardController = TextEditingController(text: user.ward ?? "");
    _circleOfficeController = TextEditingController(
      text: user.circleOffice ?? "",
    );
    _blockController = TextEditingController(text: user.block ?? "");

    //determine address type and prefill accordingly
    if ((user.addressType ?? '').trim().isNotEmpty) {
      final addr = user.addressType!.trim();
      if (addr.toLowerCase() == "rural") {
        _addressType = "Rural";
        _panchayatController.text = user.gaonPanchayat ?? ""; // prefill
        _wardController.clear(); // clear opposite field
      } else if (addr.toLowerCase() == "urban") {
        _addressType = "Urban";
        _wardController.text = user.ward ?? ""; // prefill
        _panchayatController.clear();
      } else {
        _addressType = null;
        _panchayatController.clear();
        _wardController.clear();
      }
    } else {
      // fallback if addressType is missing
      final hasPanchayat = (user.gaonPanchayat ?? '').trim().isNotEmpty;
      final hasWard = (user.ward ?? '').trim().isNotEmpty;

      if (hasPanchayat) {
        _addressType = "Rural";
        _panchayatController.text = user.gaonPanchayat!;
        _wardController.clear();
      } else if (hasWard) {
        _addressType = "Urban";
        _wardController.text = user.ward!;
        _panchayatController.clear();
      } else {
        _addressType = null;
        _panchayatController.clear();
        _wardController.clear();
      }
    }

    // Preselect dropdowns if existing values match options
    final circleValue = _circleOfficeController.text.trim();
    final blockValue = _blockController.text.trim();
    _selectedCircle = circleOptions.contains(circleValue) ? circleValue : null;
    _selectedBlock = blockOptions.contains(blockValue) ? blockValue : null;

    // If circle is not recognized, clear it to avoid stale mismatch
    if (_selectedCircle == null && circleValue.isNotEmpty) {
      _circleOfficeController.clear();
    }
    // If block is not recognized, clear it to avoid stale mismatch
    if (_selectedBlock == null && blockValue.isNotEmpty) {
      _blockController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // ✅ Prevent crash when user is null after logout
    if (userProvider.firstName == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Icon(
                          Icons.waving_hand_rounded,
                          color: primaryColor,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "To Your Application Portal",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ActionCard(
                      icon: Icons.upload_file_rounded,
                      label: 'Post a Problem',
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApplicationForm(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ActionCard(
                      icon: Icons.history_edu_rounded,
                      label: 'Submission History',
                      color: Colors.white,
                      iconColor: primaryColor,
                      textColor: Colors.black87,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubmissionHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ActionCard(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: exitColor,
                      onTap: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Logout"),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, '/logout');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ActionCard(
                      icon: Icons.analytics_rounded,
                      label: 'Test Action',
                      color: exitColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TestScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 25, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/govt_assam_white__.png', height: 40),
                  const SizedBox(width: 12),
                  const Text(
                    'Government of Assam',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4E89), Color(0xFF3C82C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (userProvider.firstName!.isNotEmpty ||
                              userProvider.lastName!.isNotEmpty)
                          ? '${userProvider.firstName} ${userProvider.lastName}'
                          : 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${userProvider.email}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '+91${userProvider.phone}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: Colors.white,
                ),
                tooltip: 'Edit Profile',
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),

          /// If editing, show form
          if (_isEditing) ...[
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'First Name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Last Name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email Address (optional)",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    // Email is optional; validate only if provided
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return null;
                      final emailReg = RegExp(
                        r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
                      );
                      if (!emailReg.hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ===== Circle Office (Dropdown) =====
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    value: _selectedCircle,
                    decoration: _dropdownDecoration('Circle Office'),
                    hint: const Text(
                      "Select Circle Office",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    items: circleOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              children: [
                                const Icon(Icons.apartment, color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(
                                  item,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCircle = value;
                        _circleOfficeController.text = value ?? '';

                        // Reset dependent fields on parent change
                        _selectedBlock = null;
                        _blockController.clear();

                        _addressType = null; // force reselect of address type
                        _panchayatController.clear();
                        _wardController.clear();
                      });
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please select a circle office'
                        : null,
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      offset: const Offset(0, 5),
                    ),
                    buttonStyleData: ButtonStyleData(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // ===== Block (Dropdown) – visible after Circle selected =====
                  if (_selectedCircle != null) const SizedBox(height: 12),
                  if (_selectedCircle != null)
                    DropdownButtonFormField2<String>(
                      isExpanded: true,
                      value: _selectedBlock,
                      decoration: _dropdownDecoration('Block'),
                      hint: const Text(
                        "Select Block",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      items: blockOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.business_center,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBlock = value;
                          _blockController.text = value ?? '';

                          // Reset the next dependent fields
                          _addressType = null; // force reselect
                          _panchayatController.clear();
                          _wardController.clear();
                        });
                      },
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please select a block'
                          : null,
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.green,
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        offset: const Offset(0, 5),
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade100,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== Address Type (after Block) =====
                  if (_selectedBlock != null)
                    DropdownButtonFormField<String>(
                      value: _addressType,
                      items: const [
                        DropdownMenuItem(value: 'Rural', child: Text('Rural')),
                        DropdownMenuItem(value: 'Urban', child: Text('Urban')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _addressType = val;
                          // Clear both; only one will be used further
                          _panchayatController.clear();
                          _wardController.clear();
                        });
                      },
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please select address type'
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Address Type",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== Panchayat/Ward based on Address Type =====
                  if (_addressType == "Rural")
                    TextFormField(
                      controller: _panchayatController,
                      decoration: const InputDecoration(
                        labelText: "Panchayat",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) {
                        if (_addressType == "Rural") {
                          if (v == null || v.trim().isEmpty) {
                            return 'Panchayat is required';
                          }
                        }
                        return null;
                      },
                    )
                  else if (_addressType == "Urban")
                    TextFormField(
                      controller: _wardController,
                      decoration: const InputDecoration(
                        labelText: "Ward",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) {
                        if (_addressType == "Urban") {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ward is required';
                          }
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Prepare request body
                        final formData = {
                          "c_id": userProvider.cId ?? '',
                          "firstName": _firstNameController.text.trim(),
                          "lastName": _lastNameController.text.trim(),
                          "email": _emailController.text.trim(),
                          "phoneNumber": userProvider.phone ?? '',
                          "address": _addressController.text.trim(),
                          "gaonPanchayat": _panchayatController.text.trim(),
                          "ward": _wardController.text.trim(),
                          "circleOffice": _circleOfficeController.text.trim(),
                          "block": _blockController.text.trim(),
                        };

                        // 🔥 Call update_user.php
                        final result = await _updateUser(formData);

                        if (!mounted) return;

                        if (result['success'] == true) {
                          // Update local storage
                          await UserSecureStorage.instance.setfName(
                            _firstNameController.text.trim(),
                          );
                          await UserSecureStorage.instance.setlName(
                            _lastNameController.text.trim(),
                          );
                          await UserSecureStorage.instance.setEmail(
                            _emailController.text.trim(),
                          );

                          // Update provider
                          userProvider.setUser(
                            cId: userProvider.cId ?? '',
                            phone: userProvider.phone ?? '',
                            address: _addressController.text.trim(),
                            addressType: _addressType ?? 'rural',
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            email: _emailController.text.trim(),
                            gaonPanchayat: _panchayatController.text.trim(),
                            ward: _wardController.text.trim(),
                            circleOffice: _circleOfficeController.text.trim(),
                            block: _blockController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? "Updated successfully",
                              ),
                            ),
                          );

                          setState(() {
                            _isEditing = false;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? "Update failed",
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper for consistent dropdown decoration
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // border: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(12),
      // ),
      // enabledBorder: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(12),
      //   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      // ),
    );
  }
}

Future<Map<String, dynamic>> _updateUser(Map<String, String> formData) async {
  final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
  final apiUrl = (Platform.isAndroid && useEmulator)
      ? dotenv.env['API_URL_EMULATOR']
      : dotenv.env['API_URL'];

  if (apiUrl == null) {
    debugPrint("API URL not found in .env");
    return {'success': false, 'message': 'API URL not configured'};
  }

  final url = Uri.parse("$apiUrl/update_user.php");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(formData),
    );

    debugPrint("📡 Request URL: $url");
    debugPrint("📦 Sent body: ${jsonEncode(formData)}");
    debugPrint("📬 Response: ${response.statusCode}");
    debugPrint("📨 Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Server error: ${response.statusCode}",
      };
    }
  } catch (e) {
    return {"success": false, "message": "Network error: $e"};
  }
}
