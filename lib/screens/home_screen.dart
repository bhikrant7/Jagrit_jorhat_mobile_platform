import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter_application_2/screens/application_form.dart';
import 'package:flutter_application_2/screens/submission_history_screen.dart';
import 'package:flutter_application_2/utils/user_provider.dart';
import 'package:flutter_application_2/utils/user_secure_storage.dart';
// import 'package:flutter_application_2/widgets/action_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF4187C5);
  final Color exitColor = const Color(0xFFFF8383);

  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  // late AnimationController _animationController;
  // late Animation<double> _fadeAnimation;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  String? _addressType;

  late TextEditingController _panchayatController;
  late TextEditingController _wardController;
  late TextEditingController _circleOfficeController;
  late TextEditingController _blockController;

  String? _selectedCircle;
  String? _selectedBlock;

  final List<String> blockOptions = [
    'East Teok\n(পূব তেওক)',
    'Central Jorhat\n(মধ্য জোৰহাট)',
    'East Jorhat\n(পূব জোৰহাট)',
    'Kaliapani\n(কলিয়াপানী)',
    'North West Jorhat\n(উত্তৰ-পশ্চিম জোৰহাট)',
    'Titabor\n(তিতাবৰ)',
  ];

  final List<String> circleOptions = [
    'Titabor Rev. Circle\n(তিতাবৰ ৰেভিনিউ চাৰ্কল)',
    'Teok Rev. Circle\n(তেওক ৰেভিনিউ চাৰ্কল)',
    'Mariani Rev. Circle\n(মাৰিয়ানী ৰেভিনিউ চাৰ্কল)',
    'East Rev. Circle\n(পূব ৰেভিনিউ চাৰ্কল)',
    'West Rev. Circle\n(পশ্চিম ৰেভিনিউ চাৰ্কল)',
  ];
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();

    _animationController.forward();

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

    if ((user.addressType ?? '').trim().isNotEmpty) {
      final addr = user.addressType!.trim();
      if (addr.toLowerCase() == "rural") {
        _addressType = "Rural";
        _panchayatController.text = user.gaonPanchayat ?? "";
        _wardController.clear();
      } else if (addr.toLowerCase() == "urban") {
        _addressType = "Urban";
        _wardController.text = user.ward ?? "";
        _panchayatController.clear();
      } else {
        _addressType = null;
        _panchayatController.clear();
        _wardController.clear();
      }
    } else {
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

    final circleValue = _circleOfficeController.text.trim();
    final blockValue = _blockController.text.trim();
    _selectedCircle = circleOptions.contains(circleValue) ? circleValue : null;
    _selectedBlock = blockOptions.contains(blockValue) ? blockValue : null;

    if (_selectedCircle == null && circleValue.isNotEmpty) {
      _circleOfficeController.clear();
    }
    if (_selectedBlock == null && blockValue.isNotEmpty) {
      _blockController.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.firstName == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Use SystemUiOverlayStyle.light for white status bar icons and text
      // Use SystemUiOverlayStyle.dark for black status bar icons and text
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildProfileHeader(context),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.waving_hand_rounded,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Welcome Back",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Your Application Portal",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildActionCard(
                              icon: Icons.upload_file_rounded,
                              label:
                                  'Post a Problem\n(আপোনাৰ আ‌ৱেদন দাখিল কৰক!)',
                              subtitle: 'Submit your issue',
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ApplicationForm(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildActionCard(
                              icon: Icons.history_edu_rounded,
                              label:
                                  'Submission History\n(আপোনাৰ দাখিলকৃত আ‌ৱেদনৰ ইতিহাস)',
                              subtitle: 'View past submissions',
                              gradient: const LinearGradient(
                                colors: [Colors.white, Colors.white],
                              ),
                              iconColor: primaryColor,
                              textColor: const Color(0xFF2D3748),
                              subtitleColor: const Color(0xFF718096),
                              borderColor: const Color(0xFFE2E8F0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SubmissionHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildActionCard(
                              icon: Icons.logout_rounded,
                              label: 'Logout \n(লগ আউট)',
                              subtitle: 'Sign out of your account',
                              gradient: LinearGradient(
                                colors: [
                                  exitColor,
                                  exitColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Text(
                                      "Confirm Logout",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                      "Are you sure you want to logout?",
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: exitColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          "Logout (লগ আউট)",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          "Cancel (বাতিল কৰক)",
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              15,
                                              14,
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  Navigator.pushNamed(context, '/logout');
                                }
                              },
                            ),
                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(bottom: 24, top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/govt_assam_white__.png', height: 36),
                      const SizedBox(width: 12),
                      const Text(
                        'Government of Assam',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Gradient gradient,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    Color subtitleColor = Colors.white70,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: (borderColor == null ? Colors.black : Colors.transparent)
                  .withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iconColor == Colors.white
                          ? Colors.white.withOpacity(0.2)
                          : iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: textColor.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D4E89),
            primaryColor,
            primaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/avatar.png'),
                    ),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${userProvider.email}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+91${userProvider.phone}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_isEditing) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _firstNameController,
                                label: 'First Name\n(প্ৰথম নাম)',
                                icon: Icons.person_outline,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernTextField(
                                controller: _lastNameController,
                                label: 'Last Name\n(উপাধি)',
                                icon: Icons.person_outline,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildModernTextField(
                          controller: _emailController,
                          label: 'Email address (ইমেইল ঠিকনা)(* optional)',
                          icon: Icons.email_outlined,
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
                        const SizedBox(height: 16),

                        _buildModernTextField(
                          controller: _addressController,
                          label: 'Address (ঠিকনা)',
                          icon: Icons.location_on_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField2<String>(
                          isExpanded: true,
                          value: _selectedCircle,
                          decoration: _modernDropdownDecoration(
                            'Circle Office',
                            Icons.apartment,
                          ),
                          hint: const Text(
                            "Select Circle Office",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF718096),
                            ),
                          ),
                          items: circleOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCircle = value;
                              _circleOfficeController.text = value ?? '';
                              _selectedBlock = null;
                              _blockController.clear();
                              _addressType = null;
                              _panchayatController.clear();
                              _wardController.clear();
                            });
                          },
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Please select a circle office'
                              : null,
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: primaryColor,
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
                          buttonStyleData: const ButtonStyleData(
                            height: 56,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                          ),
                        ),

                        if (_selectedCircle != null) const SizedBox(height: 16),
                        if (_selectedCircle != null)
                          DropdownButtonFormField2<String>(
                            isExpanded: true,
                            value: _selectedBlock,
                            decoration: _modernDropdownDecoration(
                              'Block',
                              Icons.business_center,
                            ),
                            hint: const Text(
                              "Select Block",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF718096),
                              ),
                            ),
                            items: blockOptions
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBlock = value;
                                _blockController.text = value ?? '';
                                _addressType = null;
                                _panchayatController.clear();
                                _wardController.clear();
                              });
                            },
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Please select a block'
                                : null,
                            iconStyleData: IconStyleData(
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: primaryColor,
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
                            buttonStyleData: const ButtonStyleData(
                              height: 56,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                            ),
                          ),

                        if (_selectedBlock != null) const SizedBox(height: 16),
                        if (_selectedBlock != null)
                          DropdownButtonFormField<String>(
                            value: _addressType,
                            items: const [
                              DropdownMenuItem(
                                value: 'Rural',
                                child: Text('Rural (গ্ৰাম্য)'),
                              ),
                              DropdownMenuItem(
                                value: 'Urban',
                                child: Text('Urban (নগৰ)'),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _addressType = val;
                                _panchayatController.clear();
                                _wardController.clear();
                              });
                            },
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please select address type'
                                : null,
                            decoration: _modernDropdownDecoration(
                              'Address Type',
                              Icons.home_work_outlined,
                            ),
                          ),

                        if (_addressType == "Rural") const SizedBox(height: 16),
                        if (_addressType == "Rural")
                          _buildModernTextField(
                            controller: _panchayatController,
                            label: "Panchayat (গাঁও পঞ্চায়েত)",
                            icon: Icons.maps_home_work_outlined,
                            validator: (v) {
                              if (_addressType == "Rural") {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Panchayat is required';
                                }
                              }
                              return null;
                            },
                          )
                        else if (_addressType == "Urban") ...[
                          const SizedBox(height: 16),
                          _buildModernTextField(
                            controller: _wardController,
                            label: "Ward (ৱাৰ্ড)",
                            icon: Icons.location_city_outlined,
                            validator: (v) {
                              if (_addressType == "Urban") {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ward is required';
                                }
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final formData = {
                                  "c_id": userProvider.cId ?? '',
                                  "firstName": _firstNameController.text.trim(),
                                  "lastName": _lastNameController.text.trim(),
                                  "email": _emailController.text.trim(),
                                  "phoneNumber": userProvider.phone ?? '',
                                  "address": _addressController.text.trim(),
                                  "gaonPanchayat": _panchayatController.text
                                      .trim(),
                                  "ward": _wardController.text.trim(),
                                  "circleOffice": _circleOfficeController.text
                                      .trim(),
                                  "block": _blockController.text.trim(),
                                };

                                final result = await _updateUser(formData);

                                if (!mounted) return;

                                if (result['success'] == true) {
                                  await UserSecureStorage.instance.setfName(
                                    _firstNameController.text.trim(),
                                  );
                                  await UserSecureStorage.instance.setlName(
                                    _lastNameController.text.trim(),
                                  );
                                  await UserSecureStorage.instance.setEmail(
                                    _emailController.text.trim(),
                                  );

                                  userProvider.setUser(
                                    cId: userProvider.cId ?? '',
                                    phone: userProvider.phone ?? '',
                                    address: _addressController.text.trim(),
                                    addressType: _addressType ?? 'rural',
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    gaonPanchayat: _panchayatController.text
                                        .trim(),
                                    ward: _wardController.text.trim(),
                                    circleOffice: _circleOfficeController.text
                                        .trim(),
                                    block: _blockController.text.trim(),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ??
                                            "Updated successfully",
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14),
      ),
      validator: validator,
    );
  }

  InputDecoration _modernDropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontSize: 14),
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
