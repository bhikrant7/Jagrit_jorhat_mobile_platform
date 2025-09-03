import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? cId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? addressType; // Added addressType
  String? gaonPanchayat;
  String? ward;
  String? block;
  String? circleOffice;
  // String? district;
  // String? state;
  String? emailVerifiedAt;
  String? rememberToken;
  String? createdAt;
  String? updatedAt;

  void setUser({
    required String cId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String addressType, // Added addressType
    String? gaonPanchayat,
    String? ward,
    required String block,
    required String circleOffice,
    // required String district,
    // required String state,
    String? emailVerifiedAt,
    String? rememberToken,
    String? createdAt,
    String? updatedAt,
  }) {
    this.cId = cId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.phone = phone;
    this.address = address;
    this.addressType = addressType; // Set addressType
    this.gaonPanchayat = gaonPanchayat;
    this.ward = ward;
    this.block = block;
    this.circleOffice = circleOffice;
    // this.district = district;
    // this.state = state;
    this.emailVerifiedAt = emailVerifiedAt;
    this.rememberToken = rememberToken;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    // Notify listeners to update the UI

    notifyListeners();
  }

  void clearUser() {
    cId = null;
    firstName = null;
    lastName = null;
    email = null;
    phone = null;
    address = null;
    addressType = null; // Clear addressType
    gaonPanchayat = null;
    ward = null;
    block = null;
    circleOffice = null;
    // district = null;
    // state = null;
    emailVerifiedAt = null;
    rememberToken = null;
    createdAt = null;
    updatedAt = null;

    // Notify listeners to update the UI
    notifyListeners();
  }
}
