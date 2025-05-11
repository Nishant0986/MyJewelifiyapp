// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
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
//   bool _isOtpSent = false;

//   void _sendOtp() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       final fullMobileNo = '+91$_mobileNo';
//       try {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
//         final userExists = await authProvider.checkUserExists(fullMobileNo);
//         if (userExists) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('User already exists. Please log in.'),
//             ),
//           );
//           return;
//         }
//         await authProvider.sendOtp(fullMobileNo);
//         setState(() {
//           _isOtpSent = true;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('OTP sent to your mobile number!')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
//       }
//     }
//   }

//   void _register() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       final fullMobileNo = '+91$_mobileNo';
//       try {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
//         await authProvider.register(fullMobileNo, _username, _password, _otp);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registration successful!')),
//         );
//         Navigator.pushReplacementNamed(context, '/home'); // Redirect to home
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
//       }
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
//                 decoration: const InputDecoration(
//                   hintText: 'Mobile No. (10 digits)',
//                   hintStyle: TextStyle(color: Color(0xFF757575)),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 style: const TextStyle(color: Color(0xFF757575)),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter your mobile number';
//                   }
//                   if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//                     return 'Please enter a valid 10-digit mobile number';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => _mobileNo = value!,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
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
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 obscureText: _obscurePassword,
//                 style: const TextStyle(color: Color(0xFF757575)),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? 'Please enter your password' : null,
//                 onSaved: (value) => _password = value!,
//               ),
//               if (_isOtpSent) ...[
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     hintText: 'Enter OTP',
//                     hintStyle: TextStyle(color: Color(0xFF757575)),
//                   ),
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(color: Color(0xFF757575)),
//                   validator:
//                       (value) => value!.isEmpty ? 'Please enter the OTP' : null,
//                   onSaved: (value) => _otp = value!,
//                 ),
//               ],
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isOtpSent ? _register : _sendOtp,
//                   child: Text(_isOtpSent ? 'Register' : 'Send OTP'),
//                 ),
//               ),
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
