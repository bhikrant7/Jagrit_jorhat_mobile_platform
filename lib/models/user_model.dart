class UserModel {
  final String cId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String addressType;
  final String? gaonPanchayat;
  final String block;
  final String circleOffice;
  final String? ward;
  // final String district;
  // final String state;
  final String? emailVerifiedAt;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;
  // final String otp;
  // final bool otpValid;

  UserModel({
    required this.cId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.addressType,
    this.gaonPanchayat,
    required this.block,
    required this.circleOffice,
    this.ward,
    // required this.district,
    // required this.state,
    this.emailVerifiedAt,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,

    // required this.otp,
    // required this.otpValid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    cId: json['c_id'].toString(), // ensure it's String
    firstName: json['f_name'] ?? '',
    lastName: json['l_name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    addressType: json['address_type'] ?? 'rural', // default to 'home' if not provided
    gaonPanchayat: json['gaon_panchayat'] ?? '',
    ward: json['ward'] ?? '',
    block: json['block'] ?? '',
    circleOffice: json['circle_office'] ?? '',
    // district: json['district'] ?? '',
    // state: json['state'] ?? '',
    emailVerifiedAt: json['email_verified_at'],
    // password: json['password'] ?? '',
    // cpassword: json['cpassword'] ?? '',
    rememberToken: json['remember_token'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'c_id': cId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'gaonPanchayat': gaonPanchayat,
    'address_type': addressType,
    'block': block,
    'circleOffice': circleOffice,
    'ward': ward,
    // 'district': district,
    // 'state': state,
    'emailVerifiedAt': emailVerifiedAt,
    'rememberToken': rememberToken,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    // 'otp': otp,
    // 'otp_valid':otpValid
  };
}
