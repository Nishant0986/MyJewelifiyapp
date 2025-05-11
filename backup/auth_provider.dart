// // This is the auth code which is generating the error in registration but i think this code is necessary for history and other features

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthProvider with ChangeNotifier {
//   String? _token;
//   String? _userId;
//   String? _phoneNumber;

//   String? get token => _token;
//   String? get userId => _userId;
//   String? get phoneNumber => _phoneNumber;
//   bool get isAuthenticated => _token != null;

//   // Load saved token on app startup
//   Future<void> loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('auth_token');
//     notifyListeners();
//   }

//   // Set token and notify listeners
//   void setToken(String token) {
//     _token = token;
//     notifyListeners();
//   }

//   // Check if user exists in MongoDB via FastAPI
//   Future<bool> checkUserExists(String mobileNo) async {
//     final url =
//         'https://jewelify-server.onrender.com/auth/check-user?mobile_no=$mobileNo';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         return data['exists'] ?? false;
//       } else if (response.statusCode == 404) {
//         return false; // User does not exist
//       } else {
//         throw Exception(
//           'Failed to check user existence: ${response.statusCode} - ${response.body}',
//         );
//       }
//     } catch (e) {
//       print('Check User Exists Error: $e');
//       return false; // Default to false on error
//     }
//   }

//   // Send OTP to the user's mobile number
//   Future<void> sendOtp(String mobileNo) async {
//     final url = 'https://jewelify-server.onrender.com/auth/send-otp';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'mobileNo': mobileNo}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to send OTP: ${response.body}');
//     }
//   }

//   // Register a new user with the backend
//   Future<void> register(
//     String mobileNo,
//     String username,
//     String password,
//     String otp,
//   ) async {
//     final url = 'https://jewelify-server.onrender.com/auth/register';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'username': username,
//         'mobileNo': mobileNo,
//         'password': password,
//         'otp': otp,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to register: ${response.body}');
//     }

//     final data = json.decode(response.body);
//     _userId = data['id']; // Store user ID from response
//     _phoneNumber = mobileNo;
//     // Uncomment below if backend returns access_token and you want to auto-login
//     // if (data.containsKey('access_token')) {
//     //   _token = data['access_token'];
//     //   final prefs = await SharedPreferences.getInstance();
//     //   await prefs.setString('auth_token', _token!);
//     // }
//     notifyListeners();
//   }

//   // Log in an existing user
//   Future<void> login(String usernameOrMobile, String password) async {
//     final url = 'https://jewelify-server.onrender.com/auth/login';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {'username': usernameOrMobile, 'password': password},
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to login: ${response.body}');
//     }

//     final data = json.decode(response.body);
//     _token = data['access_token'];
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', _token!);
//     notifyListeners();
//   }

//   // Log out and clear local data
//   Future<void> logout() async {
//     _token = null;
//     _userId = null;
//     _phoneNumber = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//     notifyListeners();
//   }
// }
