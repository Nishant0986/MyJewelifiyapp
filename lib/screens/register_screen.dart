// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import '../providers/auth_provider.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _username = '';
//   String _mobileNo = '';
//   String _password = '';
//   String _otp = '';
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//   bool _isOtpSent = false;

//   final _usernameController = TextEditingController();
//   final _mobileNoController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _otpController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _usernameController.addListener(_checkFieldsAndSendOtp);
//     _mobileNoController.addListener(_checkFieldsAndSendOtp);
//     _passwordController.addListener(_checkFieldsAndSendOtp);
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _mobileNoController.dispose();
//     _passwordController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   void _checkFieldsAndSendOtp() {
//     if (_usernameController.text.isNotEmpty &&
//         _mobileNoController.text.length == 10 &&
//         _passwordController.text.isNotEmpty &&
//         !_isLoading &&
//         !_isOtpSent) {
//       if (_formKey.currentState!.validate()) {
//         _formKey.currentState!.save();
//         _sendOtp();
//       }
//     }
//   }

//   Future<void> _sendOtp() async {
//     setState(() => _isLoading = true);
//     final fullMobileNo = '+91$_mobileNo';

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await authProvider.sendOtp(fullMobileNo);
//       setState(() {
//         _isOtpSent = true;
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
//     } catch (e) {
//       print('Send OTP error: $e'); // Add this for debugging
//       setState(() {
//         _isOtpSent = false; // Ensure _isOtpSent remains false on failure
//         _isLoading = false;
//       });
//       String errorMessage = 'Failed to send OTP. Please try again.';
//       if (e.toString().contains('Failed to send OTP')) {
//         errorMessage = e.toString().replaceFirst(
//           'Exception: Failed to send OTP: ',
//           '',
//         );
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(errorMessage)));
//     }
//   }

//   Future<void> _verifyOtpAndRegister() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     setState(() => _isLoading = true);

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final fullMobileNo = '+91$_mobileNo';

//       // Verify the OTP
//       await authProvider.verifyOtp(fullMobileNo, _otp);

//       // Register the user
//       final url = 'https://jewelify-server.onrender.com/auth/register';
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': _username,
//           'mobileNo': fullMobileNo,
//           'password': _password,
//           'otp': _otp, // Include the OTP field
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         await authProvider.updateUserDetails(
//           token: data['access_token'],
//           userId: data['id'],
//           username: _username,
//           mobileNo: fullMobileNo,
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registration successful!')),
//         );
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//       } else {
//         final errorDetail =
//             jsonDecode(response.body)['detail'] ?? response.body;
//         if (errorDetail == "Mobile number already exists") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Mobile number already registered. Please login.'),
//             ),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         } else if (errorDetail == "Username already exists") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Username already taken. Please choose another.'),
//             ),
//           );
//           setState(() {
//             _isOtpSent = false; // Allow retry
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Registration failed: $errorDetail')),
//           );
//           setState(() {
//             _isOtpSent = false; // Allow retry
//           });
//         }
//       }
//     } catch (e) {
//       print('Registration error: $e'); // Add this for debugging
//       String errorMessage = 'Registration failed. Please try again.';
//       if (e.toString().contains('Failed to verify OTP')) {
//         errorMessage = 'Invalid OTP. Please try again.';
//       } else if (e.toString().contains('OTP not found or expired')) {
//         errorMessage = 'OTP not found or expired. Please request a new OTP.';
//         setState(() {
//           _isOtpSent = false; // Allow retry
//         });
//       } else if (e.toString().contains('OTP has expired')) {
//         errorMessage = 'OTP has expired. Please request a new OTP.';
//         setState(() {
//           _isOtpSent = false; // Allow retry
//         });
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(errorMessage)));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 50),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey.shade200,
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back_ios_new,
//                     size: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: Image.asset(
//                   'assets/images/login_illustration.png',
//                   height: 180,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Sign-up',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(
//                   hintText: 'Username',
//                   hintStyle: TextStyle(color: Color(0xFF757575)),
//                 ),
//                 style: const TextStyle(color: Color(0xFF757575)),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? 'Please enter a username' : null,
//                 onSaved: (value) => _username = value!,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _mobileNoController,
//                 decoration: const InputDecoration(
//                   hintText: 'Mobile No. (e.g., 9876543210)',
//                   hintStyle: TextStyle(color: Color(0xFF757575)),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 style: const TextStyle(color: Color(0xFF757575)),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Please enter your mobile number';
//                   if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//                     return 'Enter a valid 10-digit mobile number';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => _mobileNo = value!,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   hintText: 'Password',
//                   hintStyle: const TextStyle(color: Color(0xFF757575)),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed:
//                         () => setState(
//                           () => _obscurePassword = !_obscurePassword,
//                         ),
//                   ),
//                 ),
//                 obscureText: _obscurePassword,
//                 style: const TextStyle(color: Color(0xFF757575)),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Please enter your password';
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => _password = value!,
//               ),
//               if (_isOtpSent) ...[
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _otpController,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter OTP',
//                     hintStyle: TextStyle(color: Color(0xFF757575)),
//                   ),
//                   keyboardType: TextInputType.number,
//                   maxLength: 6,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   style: const TextStyle(color: Color(0xFF757575)),
//                   validator: (value) {
//                     if (value!.isEmpty) return 'Please enter the OTP';
//                     if (value.length != 6) return 'OTP must be 6 digits';
//                     return null;
//                   },
//                   onSaved: (value) => _otp = value!,
//                   onChanged: (value) {
//                     if (value.length == 6) {
//                       FocusScope.of(context).unfocus();
//                     }
//                   },
//                 ),
//               ],
//               const SizedBox(height: 30),
//               if (_isOtpSent)
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child:
//                       _isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : ElevatedButton(
//                             onPressed: _verifyOtpAndRegister,
//                             child: const Text('Verify OTP & Register'),
//                           ),
//                 ),
//               if (_isLoading && !_isOtpSent)
//                 const Center(child: CircularProgressIndicator()),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Already have an account? ',
//                     style: TextStyle(color: Color(0xFF757575)),
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.pushNamed(context, '/login'),
//                     child: const Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Color(0xFF2D4356),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = ''; // Changed from _mobileNo to _email
  String _password = '';
  String _verificationCode = ''; // Changed from _otp to _verificationCode
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isVerificationCodeSent = false; // Changed from _isOtpSent

  final _usernameController = TextEditingController();
  final _emailController =
      TextEditingController(); // Changed from _mobileNoController
  final _passwordController = TextEditingController();
  final _verificationCodeController =
      TextEditingController(); // Changed from _otpController

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkFieldsAndSendVerificationEmail);
    _emailController.addListener(_checkFieldsAndSendVerificationEmail);
    _passwordController.addListener(_checkFieldsAndSendVerificationEmail);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _checkFieldsAndSendVerificationEmail() {
    if (_usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !_isLoading &&
        !_isVerificationCodeSent) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _sendVerificationEmail();
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendVerificationEmail(_email);
      setState(() {
        _isVerificationCodeSent = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to your email!')),
      );
    } catch (e) {
      print('Send verification email error: $e');
      setState(() {
        _isVerificationCodeSent = false;
        _isLoading = false;
      });
      String errorMessage =
          'Failed to send verification email. Please try again.';
      if (e.toString().contains('Failed to send verification email')) {
        errorMessage = e.toString().replaceFirst(
          'Exception: Failed to send verification email: ',
          '',
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _verifyCodeAndRegister() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verify the email code
      await authProvider.verifyEmailCode(_email, _verificationCode);

      // Register the user
      final url = 'https://jewelify-server.onrender.com/auth/register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'email': _email,
          'password': _password,
          'verification_code':
              _verificationCode, // Changed from otp to verification_code
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await authProvider.updateUserDetails(
          token: data['access_token'],
          userId: data['id'],
          username: _username,
          email: _email,
          mobileNo: data['mobileNo'], // Keep for future use
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? response.body;
        if (errorDetail == "Email already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered. Please login.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (errorDetail == "Username already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already taken. Please choose another.'),
            ),
          );
          setState(() {
            _isVerificationCodeSent = false; // Allow retry
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $errorDetail')),
          );
          setState(() {
            _isVerificationCodeSent = false; // Allow retry
          });
        }
      }
    } catch (e) {
      print('Registration error: $e');
      String errorMessage = 'Registration failed. Please try again.';
      if (e.toString().contains('Failed to verify email code')) {
        errorMessage = 'Invalid verification code. Please try again.';
      } else if (e.toString().contains(
        'Verification session not found or expired',
      )) {
        errorMessage =
            'Verification code not found or expired. Please request a new code.';
        setState(() {
          _isVerificationCodeSent = false; // Allow retry
        });
      } else if (e.toString().contains('Verification session has expired')) {
        errorMessage =
            'Verification code has expired. Please request a new code.';
        setState(() {
          _isVerificationCodeSent = false; // Allow retry
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/login_illustration.png',
                  height: 180,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign-up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Color(0xFF757575)),
                ),
                style: const TextStyle(color: Color(0xFF757575)),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a username' : null,
                onSaved: (value) => _username = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email (e.g., user@example.com)',
                  hintStyle: TextStyle(color: Color(0xFF757575)),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFF757575)),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF757575)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFF757575)),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your password';
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              if (_isVerificationCodeSent) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _verificationCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Verification Code',
                    hintStyle: TextStyle(color: Color(0xFF757575)),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Color(0xFF757575)),
                  validator: (value) {
                    if (value!.isEmpty)
                      return 'Please enter the verification code';
                    if (value.length != 6)
                      return 'Verification code must be 6 digits';
                    return null;
                  },
                  onSaved: (value) => _verificationCode = value!,
                  onChanged: (value) {
                    if (value.length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
              const SizedBox(height: 30),
              if (_isVerificationCodeSent)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _verifyCodeAndRegister,
                            child: const Text('Verify Code & Register'),
                          ),
                ),
              if (_isLoading && !_isVerificationCodeSent)
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF2D4356),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
