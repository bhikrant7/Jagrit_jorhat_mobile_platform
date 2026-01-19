import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/screens/authentication/login_screen.dart';
import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/otp_util.dart';
import 'package:flutter_application_2/widgets/custom_bg_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formRegisterKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gaonPanchayatController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController circleOfficeController = TextEditingController();

  // Urban / Rural selection
  String? urbanOrRural;

  //state variable for selected values of block and circle
  String? selectedBlock;
  String? selectedCircle;

  final List<String> blockOptions = [
    'East Teok\n(পূব টীয়ক)',
    'Central Jorhat\n(মধ্য যোৰহাট)',
    'East Jorhat\n(পূব যোৰহাট)',
    'Kaliapani\n(কলিয়াপানী)',
    'North West Jorhat\n(উত্তৰ-পশ্চিম যোৰহাট)',
    'Titabor\n(তিতাবৰ)',
  ];

  final List<String> circleOptions = [
    'Titabor Rev. Circle\n(তিতাবৰ ৰেভিনিউ চাৰ্কল)',
    'Teok Rev. Circle\n(টীয়ক ৰেভিনিউ চাৰ্কল)',
    'Mariani Rev. Circle\n(মৰিয়নী ৰেভিনিউ চাৰ্কল)',
    'East Rev. Circle\n(পূব ৰেভিনিউ চাৰ্কল)',
    'West Rev. Circle\n(পশ্চিম ৰেভিনিউ চাৰ্কল)',
  ];

  bool agreePersonalData = true;
  bool isSubmitting = false;
  bool isScrolled = false;
  double topPadding = 100;

  Color primaryColor = const Color.fromARGB(255, 65, 135, 197);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;

    if (offset > 10 && !isScrolled) {
      setState(() {
        isScrolled = true;
        topPadding = 0;
      });
    } else if (offset <= 10 && isScrolled) {
      setState(() {
        isScrolled = false;
        topPadding = 100;
      });
    }
  }

  // --- HELPER METHOD: Custom SnackBar ---
  void _showCustomSnackBar({required String message, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBgScaffold(
      child: Stack(
        children: [
          /// Animated Slide-Up Container
          AnimatedPadding(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(top: topPadding),
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 0.0),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(237, 232, 228, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formRegisterKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Register here!',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 40.0),

                            // First & Last Name
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: firstNameController,
                                    label: 'First Name\n(প্ৰথম নাম)',
                                    hint: 'First Name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: lastNameController,
                                    label: 'Last Name\n(উপাধি)',
                                    hint: 'Last Name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),

                            _buildModernTextField(
                              controller: emailController,
                              label: 'Email address (ইমেইল ঠিকনা)(* optional)',
                              hint: 'example@gmail.com',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16.0),
                            _buildModernTextField(
                              controller: phoneNumberController,
                              label: 'Phone Number (ফোন নম্বৰ)',
                              hint: '10-digit number',
                              icon: Icons.phone_android,
                              isNumber: true,
                            ),
                            const SizedBox(height: 16.0),
                            _buildModernTextField(
                              controller: addressController,
                              label: 'Address (ঠিকনা)',
                              hint: 'Enter your address',
                              icon: Icons.home_outlined,
                            ),
                            const SizedBox(height: 25.0),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Circle Office Dropdown
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedCircle,
                                    hint: const Text(
                                      "Select Circle Office (চাৰ্কল কাৰ্যালয়)",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    items: circleOptions.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCircle = value;
                                        circleOfficeController.text =
                                            value ?? '';
                                        selectedBlock = null;
                                        urbanOrRural = null;
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 55,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                          237,
                                          232,
                                          228,
                                          1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black12,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),

                                if (selectedCircle != null)
                                  const SizedBox(height: 16.0),

                                // Block Dropdown
                                if (selectedCircle != null)
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      value: selectedBlock,
                                      hint: const Text(
                                        "Select Block (ব্লক)",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      items: blockOptions.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedBlock = value;
                                          blockController.text = value ?? '';
                                          urbanOrRural = null;
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 55,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                            237,
                                            232,
                                            228,
                                            1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.black12,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      iconStyleData: IconStyleData(
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),

                                if (selectedBlock != null)
                                  const SizedBox(height: 16.0),

                                // Show Address Type only after Block selected
                                // ... inside your Column children ...
                                if (selectedBlock != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Address Type: (ঠিকনাৰ ধৰণ)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // FIX: Custom "Toggle" using Row + Expanded to guarantee NO OVERFLOW
                                      Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color:
                                              primaryColor, // Background color for selected state logic
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Option 1: Urban
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    urbanOrRural = 'Urban';
                                                    gaonPanchayatController
                                                        .clear();
                                                    wardController.clear();
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    // If Urban is selected, it's trans parent (showing blue bg).
                                                    // If NOT selected, it's white.
                                                    color:
                                                        urbanOrRural == 'Urban'
                                                        ? primaryColor
                                                        : const Color.fromRGBO(237, 232, 228, 1),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Urban (নগৰ)",
                                                    style: TextStyle(
                                                      color:
                                                          urbanOrRural ==
                                                              'Urban'
                                                          ? Colors.white
                                                          : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Thin Divider line
                                            Container(
                                              width: 1,
                                              color: primaryColor,
                                            ),

                                            // Option 2: Rural
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    urbanOrRural = 'Rural';
                                                    gaonPanchayatController
                                                        .clear();
                                                    wardController.clear();
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        urbanOrRural == 'Rural'
                                                        ? primaryColor
                                                        : const Color.fromRGBO(237, 232, 228, 1),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Rural (গ্ৰাম্য)",
                                                    style: TextStyle(
                                                      color:
                                                          urbanOrRural ==
                                                              'Rural'
                                                          ? Colors.white
                                                          : Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                // ... rest of your code
                                const SizedBox(height: 16),

                                // Show Ward or Gaon Panchayat
                                if (urbanOrRural == 'Rural')
                                  _buildModernTextField(
                                    controller: gaonPanchayatController,
                                    label: 'Gaon Panchayat (গাঁও পঞ্চায়েত)',
                                    hint: 'Enter Panchayat',
                                    icon: Icons.holiday_village_outlined,
                                  )
                                else if (urbanOrRural == 'Urban')
                                  _buildModernTextField(
                                    controller: wardController,
                                    label: 'Ward (ৱাৰ্ড)',
                                    hint: 'Enter Ward',
                                    icon: Icons.location_city,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Checkbox(
                                  value: agreePersonalData,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreePersonalData = value ?? false;
                                    });
                                  },
                                  activeColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Expanded(
                                  child: Wrap(
                                    children: [
                                      Text(
                                        'I agree to the processing of ',
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Personal data',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            65,
                                            135,
                                            197,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25.0),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        // 1. VALIDATION
                                        if (!_formRegisterKey.currentState!
                                            .validate()) {
                                          return; // Form validator handles UI messages
                                        }

                                        if (selectedCircle == null) {
                                          _showCustomSnackBar(
                                            message: "Select Circle Office",
                                            isError: true,
                                          );
                                          return;
                                        }
                                        if (selectedBlock == null) {
                                          _showCustomSnackBar(
                                            message: "Select Block",
                                            isError: true,
                                          );
                                          return;
                                        }
                                        if (urbanOrRural == null) {
                                          _showCustomSnackBar(
                                            message: "Select Address Type",
                                            isError: true,
                                          );
                                          return;
                                        }

                                        if (!agreePersonalData) {
                                          _showCustomSnackBar(
                                            message:
                                                "Please agree to personal data processing",
                                            isError: true,
                                          );
                                          return;
                                        }

                                        // 2. SUBMISSION
                                        setState(() => isSubmitting = true);

                                        // Show processing snackbar
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Submitting registration...",
                                            ),
                                          ),
                                        );

                                        final formData = {
                                          "c_id": "",
                                          "firstName": firstNameController.text,
                                          "lastName": lastNameController.text,
                                          "email": emailController.text,
                                          "phoneNumber":
                                              phoneNumberController.text,
                                          "address": addressController.text,
                                          "address_type":
                                              urbanOrRural?.toLowerCase() ??
                                              'rural',
                                          "gaonPanchayat":
                                              gaonPanchayatController.text,
                                          "block": blockController.text,
                                          "circleOffice":
                                              circleOfficeController.text,
                                          "ward": wardController.text,
                                        };

                                        UserModel userData = UserModel(
                                          cId: '',
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text,
                                          email: emailController.text,
                                          phone: phoneNumberController.text,
                                          address: addressController.text,
                                          addressType:
                                              urbanOrRural?.toLowerCase() ??
                                              'rural',
                                          gaonPanchayat:
                                              gaonPanchayatController.text,
                                          block: blockController.text,
                                          circleOffice:
                                              circleOfficeController.text,
                                          ward: wardController.text,
                                          emailVerifiedAt: null,
                                          rememberToken: null,
                                          createdAt: DateTime.now()
                                              .toIso8601String(),
                                          updatedAt: DateTime.now()
                                              .toIso8601String(),
                                        );

                                        final result = await submitFormData(
                                          formData,
                                        );

                                        if (!mounted) return;
                                        setState(() => isSubmitting = false);

                                        if (result != null &&
                                            result['success'] == true) {
                                          _showCustomSnackBar(
                                            message:
                                                result['message'] ??
                                                'Registered! Verify your number',
                                          );

                                          final phoneNum =
                                              phoneNumberController.text;
                                          _formRegisterKey.currentState!
                                              .reset();
                                          firstNameController.clear();
                                          lastNameController.clear();
                                          emailController.clear();
                                          phoneNumberController.clear();
                                          addressController.clear();
                                          gaonPanchayatController.clear();
                                          wardController.clear();
                                          blockController.clear();
                                          circleOfficeController.clear();
                                          setState(() {
                                            selectedCircle = null;
                                            selectedBlock = null;
                                            urbanOrRural = null;
                                          });

                                          Future.delayed(
                                            const Duration(seconds: 2),
                                            () {
                                              if (!mounted) return;
                                              Navigator.pushReplacement(
                                                // ignore: use_build_context_synchronously
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OtpScreenUtil(
                                                    destination:
                                                        const HomeScreen(),
                                                    user: userData,
                                                    phone: phoneNum,
                                                    isPasswordReset: false,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          _showCustomSnackBar(
                                            message:
                                                result?['message'] ??
                                                'Registration failed',
                                            isError: true,
                                          );
                                        }
                                      },
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign up (চাইন আপ)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 30.0),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Footer Section ---
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
                        // Safe area for bottom
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

  // --- MODERN TEXT FIELD HELPER ---
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      validator: (value) {
        // 1. Email Optional Check
        if (label.contains('Email')) {
          if (value == null || value.isEmpty) {
            return null; // Allowed to be empty
          }
          final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email (e.g., abc@gmail.com)';
          }
          return null;
        }

        // 2. Required Check for other fields
        if (value == null || value.isEmpty) {
          return 'Please enter ${label.split('\n')[0]}';
        }

        // 3. Phone Number Strict Check
        if (isNumber || label.contains('Phone')) {
          final phoneRegex = RegExp(r'^\d{10}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Phone number must be exactly 10 digits';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: const Color.fromRGBO(237, 232, 228, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12, width: 2.0),
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
    );
  }
}

Future<Map<String, dynamic>?> submitFormData(
  Map<String, String> formData,
) async {
  final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
  final apiUrl = (Platform.isAndroid && useEmulator)
      ? dotenv.env['API_URL_EMULATOR']
      : dotenv.env['API_URL'];

  if (apiUrl == null) {
    debugPrint("API URL not found in .env");
    return {'success': false, 'message': 'API URL not configured'};
  }

  final url = Uri.parse("$apiUrl/register.php");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    debugPrint("Network error: $e");
    return {'success': false, 'message': 'Network error: $e'};
  }
}
