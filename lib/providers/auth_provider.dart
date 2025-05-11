import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserOut {
  final String id;
  final String? username;
  final String email;
  final String? mobileNo;
  final String? createdAt;
  final String? accessToken;

  UserOut({
    required this.id,
    this.username,
    required this.email,
    this.mobileNo,
    this.createdAt,
    this.accessToken,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final email = json['email'] as String?;
    if (id == null || email == null) {
      throw FormatException('Invalid JSON: id and email are required');
    }
    return UserOut(
      id: id,
      username: json['username'] as String?,
      email: email,
      mobileNo: json['mobileNo'] as String?,
      createdAt: json['created_at'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }
}

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _username;
  String? _email; // Changed from _mobileNo to _email
  String? _mobileNo; // Keep for future use

  final _storage = const FlutterSecureStorage();

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email; // Changed from mobileNo to email
  String? get mobileNo => _mobileNo; // Keep for future use
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    loadToken();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    _userId = await _storage.read(key: 'user_id');
    _username = await _storage.read(key: 'username');
    _email = await _storage.read(
      key: 'email',
    ); // Changed from mobileNo to email
    _mobileNo = await _storage.read(key: 'mobileNo'); // Keep for future use
    notifyListeners();
  }

  Future<void> _saveToken({
    String? token,
    String? userId,
    String? username,
    String? email, // Changed from mobileNo to email
    String? mobileNo, // Keep for future use
  }) async {
    if (token != null) await _storage.write(key: 'auth_token', value: token);
    if (userId != null) await _storage.write(key: 'user_id', value: userId);
    if (username != null) {
      await _storage.write(key: 'username', value: username);
    }
    if (email != null) {
      await _storage.write(
        key: 'email',
        value: email,
      ); // Changed from mobileNo to email
    }
    if (mobileNo != null) {
      await _storage.write(
        key: 'mobileNo',
        value: mobileNo,
      ); // Keep for future use
    }
  }

  Future<void> updateUserDetails({
    required String token,
    required String userId,
    required String username,
    required String email, // Changed from mobileNo to email
    String? mobileNo, // Keep for future use
  }) async {
    _token = token;
    _userId = userId;
    _username = username;
    _email = email; // Changed from _mobileNo to _email
    _mobileNo = mobileNo; // Keep for future use
    await _saveToken(
      token: token,
      userId: userId,
      username: username,
      email: email, // Changed from mobileNo to email
      mobileNo: mobileNo, // Keep for future use
    );
    notifyListeners();
  }

  Future<void> sendVerificationEmail(String email) async {
    try {
      print('Sending verification email to: $email');
      final url =
          'https://jewelify-server.onrender.com/auth/send-verification-email';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to send verification email: $errorDetail');
      }
    } catch (e) {
      print('Send verification email error: $e');
      rethrow;
    }
  }

  Future<void> verifyEmailCode(String email, String code) async {
    try {
      print('Verifying email code for email: $email, code: $code');
      final url = 'https://jewelify-server.onrender.com/auth/verify-email-code';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to verify email code: $errorDetail');
      }
    } catch (e) {
      print('Verify email code error: $e');
      rethrow;
    }
  }

  Future<void> login(String usernameOrEmail, String password) async {
    try {
      print('Logging in with usernameOrEmail: $usernameOrEmail');
      final url = 'https://jewelify-server.onrender.com/auth/login';
      final body = {
            'username': usernameOrEmail, // Changed to match backend expectation
            'password': password,
          }.entries
          .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to login: ${errorData['detail'] ?? response.body}',
        );
      }

      final data = jsonDecode(response.body);
      _token = data['access_token'];
      final userData = await _fetchUserDetails(data['access_token']);
      _userId = userData['id'];
      _username = userData['username'];
      _email = userData['email']; // Changed from mobileNo to email
      _mobileNo = userData['mobileNo']; // Keep for future use
      print(
        'Fetched user details: id=$_userId, username=$_username, email=$_email, mobileNo=$_mobileNo',
      );
      await _saveToken(
        token: _token!,
        userId: _userId,
        username: _username,
        email: _email, // Changed from mobileNo to email
        mobileNo: _mobileNo, // Keep for future use
      );
      notifyListeners();
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchUserDetails(String token) async {
    final url = 'https://jewelify-server.onrender.com/auth/me';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user details: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _username = null;
    _email = null; // Changed from _mobileNo to _email
    _mobileNo = null; // Keep for future use
    await _storage.deleteAll();
    notifyListeners();
  }

  // Commented out mobile number-based OTP methods for future use
  /*
  Future<void> sendOtp(String mobileNo) async {
    try {
      print('Sending OTP for mobileNo: $mobileNo');
      final url = 'https://jewelify-server.onrender.com/auth/send-otp';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNo': mobileNo}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to send OTP: $errorDetail');
      }
    } catch (e) {
      print('Send OTP error: $e');
      rethrow;
    }
  }

  Future<void> verifyOtp(String mobileNo, String otp) async {
    try {
      print('Verifying OTP for mobileNo: $mobileNo, OTP: $otp');
      final url = 'https://jewelify-server.onrender.com/auth/verify-otp';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNo': mobileNo, 'otp': otp}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to verify OTP: $errorDetail');
      }
    } catch (e) {
      print('Verify OTP error: $e');
      rethrow;
    }
  }
  */
}
