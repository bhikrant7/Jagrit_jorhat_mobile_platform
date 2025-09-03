import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  //  Private constructor
  UserSecureStorage._privateConstructor();

  //  Singleton instance
  static final UserSecureStorage instance = UserSecureStorage._privateConstructor();

  //  Flutter Secure Storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  //  Keys for the storage
  static const String _keyToken = 'auth_token';
  static const String _keyPhone = 'user_phone';
  static const String _keyfName = 'user_f_name';
  static const String _keylName = 'user_l_name';
  static const String _keyEmail = 'user_email';

  //  Save methods
  Future<void> setToken(String token) async => await _storage.write(key: _keyToken, value: token);
  Future<void> setPhone(String phone) async => await _storage.write(key: _keyPhone, value: phone);
  Future<void> setfName(String fname) async => await _storage.write(key: _keyfName, value: fname);
  Future<void> setlName(String lname) async => await _storage.write(key: _keylName, value: lname);
  Future<void> setEmail(String email) async => await _storage.write(key: _keyEmail, value: email);

  //  Read methods
  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getPhone() async => await _storage.read(key: _keyPhone);
  Future<String?> getfName() async => await _storage.read(key: _keyfName);
  Future<String?> getlName() async => await _storage.read(key: _keylName);
  Future<String?> getEmail() async => await _storage.read(key: _keyEmail);

  //  Delete a specific key
  Future<void> deleteToken() async => await _storage.delete(key: _keyToken);

  //  Clear all user data
  Future<void> clearAll() async => await _storage.deleteAll();
}
