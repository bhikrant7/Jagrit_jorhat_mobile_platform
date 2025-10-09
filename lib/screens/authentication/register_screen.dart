import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/screens/authentication/login_screen.dart';

import 'package:flutter_application_2/screens/home_screen.dart';
import 'package:flutter_application_2/utils/otp_util.dart';
// import 'package:flutter_application_2/screens/home_screen.dart';
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
  String? urbanOrRural; // "Urban" or "Rural"

  //state variable for selected values of block and circle
  String? selectedBlock;
  String? selectedCircle;

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
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formRegisterKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
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
                            child: _buildTextField(
                              'First Name\n(প্ৰথম নাম)',
                              'Enter First Name',
                              firstNameController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Last Name\n(উপাধি)',
                              'Enter Last Name',
                              lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      _buildTextField(
                        'Email address (ইমেইল ঠিকনা)(* optional)',
                        'Enter email address',
                        emailController,
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        'Phone Number (ফোন নম্বৰ)',
                        'Enter phone number',
                        phoneNumberController,
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextField(
                        'Address (ঠিকনা)',
                        'Enter Address',
                        addressController,
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
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              items: circleOptions.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.apartment,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        item,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCircle = value;
                                  circleOfficeController.text = value ?? '';
                                  selectedBlock = null;
                                  urbanOrRural = null; // Reset next field
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 55,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey.shade300,
                                  //     blurRadius: 8,
                                  //     offset: const Offset(0, 4),
                                  //   ),
                                  // ],
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                offset: const Offset(0, 5),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.blue,
                                ),
                                iconSize: 24,
                              ),
                            ),
                          ),

                          // DropdownButtonFormField<String>(
                          //   value: selectedCircle,
                          //   decoration: InputDecoration(
                          //     labelText: 'Circle Office',
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //   ),
                          //   items: circleOptions.map((circle) {
                          //     return DropdownMenuItem(
                          //       value: circle,
                          //       child: Text(circle),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectedCircle = value;
                          //       circleOfficeController.text = value ?? '';
                          //       selectedBlock = null; // Reset next field
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Please select a circle office';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          

                          // Show Block only after Circle selected
                          if (selectedCircle != null)
                            const SizedBox(height: 25.0),
                          if (selectedCircle != null)
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                value: selectedBlock,
                                hint: const Text(
                                  "Select Block (ব্লক)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                items: blockOptions.map((item) {
                                  return DropdownMenuItem<String>(
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
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBlock = value;
                                    blockController.text = value ?? '';
                                    urbanOrRural = null; // Reset next field
                                    
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 55,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey.shade300,
                                    //     blurRadius: 8,
                                    //     offset: const Offset(0, 4),
                                    //   ),
                                    // ],
                                    border: Border.all(
                                      color: Colors.green.shade100,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(0, 5),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.green,
                                  ),
                                  iconSize: 24,
                                ),
                              ),
                            ),

                          // DropdownButtonFormField<String>(
                          //   value: selectedBlock,
                          //   decoration: InputDecoration(
                          //     labelText: 'Block',
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //   ),
                          //   items: blockOptions.map((block) {
                          //     return DropdownMenuItem(
                          //       value: block,
                          //       child: Text(block),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectedBlock = value;
                          //       blockController.text = value ?? '';
                          //       urbanOrRural = null; // Reset next field
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Please select a block';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          if (selectedBlock != null)
                            const SizedBox(height: 25.0),

                          // Show Address Type only after Block selected
                          if (selectedBlock != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Address Type: (ঠিকনাৰ ধৰণ)',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                ToggleButtons(
                                  selectedBorderColor: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  borderWidth: 2,
                                  selectedColor: Colors.white,
                                  fillColor: primaryColor,
                                  color: Colors.black,
                                  constraints: BoxConstraints.expand(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                  ), // Equal width
                                  isSelected: [
                                    urbanOrRural == 'Urban',
                                    urbanOrRural == 'Rural',
                                  ],
                                  onPressed: (index) {
                                    setState(() {
                                      urbanOrRural = index == 0
                                          ? 'Urban'
                                          : 'Rural';
                                      gaonPanchayatController.clear();
                                      wardController.clear();
                                    });
                                  },
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text("Urban (নগৰ)"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text("Rural (গ্ৰাম্য)"),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Show Ward or Gaon Panchayat based on Urban/Rural
                          if (urbanOrRural == 'Rural')
                            _buildTextField(
                              'Gaon Panchayat (গাঁও পঞ্চায়েত)',
                              'Enter Gaon Panchayat',
                              gaonPanchayatController,
                            )
                          else if (urbanOrRural == 'Urban')
                            _buildTextField(
                              'Ward (ৱাৰ্ড)',
                              'Enter Ward',
                              wardController,
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
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (_formRegisterKey.currentState!
                                          .validate() &&
                                      agreePersonalData) {
                                    // Show snackbar for "processing"
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                      "phoneNumber": phoneNumberController.text,
                                      "address": addressController.text,
                                      "address_type": urbanOrRural?.toLowerCase() ?? 'rural',
                                      "gaonPanchayat":
                                          gaonPanchayatController.text,
                                      "block": blockController.text,
                                      "circleOffice":
                                          circleOfficeController.text,

                                      "ward": wardController.text,
                                    };

                                    //model instance
                                    UserModel userData = UserModel(
                                      cId: '', //comes from backend
                                      firstName: firstNameController.text,
                                      lastName: lastNameController.text,
                                      email: emailController.text,
                                      phone: phoneNumberController.text,
                                      address: addressController.text,
                                      addressType: urbanOrRural?.toLowerCase() ?? 'rural',
                                      gaonPanchayat:
                                          gaonPanchayatController.text,
                                      block: blockController.text,
                                      circleOffice: circleOfficeController.text,
                                      ward: wardController.text,
                                      // district: districtController.text,
                                      // state: stateController.text,
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

                                    if (!mounted) {
                                      return;
                                    } //  guard context

                                    if (result != null &&
                                        result['success'] == true) {
                                      ScaffoldMessenger.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ??
                                                'Registered user.Please verify your number',
                                          ),
                                        ),
                                      );
                                      final phoneNum =
                                          phoneNumberController.text;
                                      // Reset form
                                      _formRegisterKey.currentState!.reset();

                                      // Clear all controllers
                                      firstNameController.clear();
                                      lastNameController.clear();
                                      emailController.clear();
                                      phoneNumberController.clear();
                                      addressController.clear();
                                      gaonPanchayatController.clear();
                                      wardController.clear();
                                      blockController.clear();
                                      circleOfficeController.clear();
                                      //

                                      Future.delayed(Duration(seconds: 2), () {
                                        if (!mounted) return; // ✅ Fix again
                                        Navigator.pushReplacement(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OtpScreenUtil(
                                              destination: HomeScreen(),
                                              user: userData,
                                              phone: phoneNum,
                                              isPasswordReset: false,
                                            ),
                                          ),
                                        );
                                      });
                                    } else {
                                      ScaffoldMessenger.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result?['message'] ??
                                                'Registration failed',
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (!agreePersonalData) {
                                    if (!mounted) {
                                      return;
                                    } //  Fix: guard context
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please agree to the processing of personal data',
                                        ),
                                      ),
                                    );
                                  }
                                },

                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Sign up (চাইন আপ)',
                                  style: TextStyle(
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
                      const SizedBox(height: 20.0),
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controllerText, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controllerText,
      obscureText: obscure,
      obscuringCharacter: '*',
      validator: (value) {
        if (label != 'Email address(* optional)' &&
            (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        if (label == 'Phone Number') {
          final phoneRegex = RegExp(r'^\d{10}$');
          if (!phoneRegex.hasMatch(value!)) {
            return 'Phone number must be exactly 10 digits';
          }
        }
        return null;
      },

      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
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
