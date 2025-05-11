// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _username = '';
//   String _password = '';
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   // Login method to handle form submission
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save(); // Triggers normalization
//     setState(() => _isLoading = true);

//     try {
//       print('Attempting login with:');
//       print('  usernameOrMobile: $_username');
//       print('  password: $_password');
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await authProvider.login(_username, _password);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Login successful!')));
//       Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//     } catch (e) {
//       print('Login error: $e');
//       String errorMessage = 'Login failed. Please check your credentials.';
//       if (e.toString().contains('Failed to fetch user details')) {
//         errorMessage = 'Unable to fetch user details. Please try again later.';
//       } else if (e.toString().contains(
//         'Incorrect username/mobileNo or password',
//       )) {
//         errorMessage = 'Incorrect username or password.';
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(errorMessage)));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // Validation for username or mobile number
//   String? _validateUsernameOrMobile(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your username or mobile number';
//     }

//     String input = value.trim();
//     input = input.replaceAll(RegExp(r'\s+'), '');

//     // Check if the input is a mobile number (starts with +91 or just digits)
//     if (RegExp(r'^\+?\d+$').hasMatch(input)) {
//       // Remove +91 or leading zeros if present
//       String cleanedNumber =
//           input.startsWith('+91') ? input.substring(3) : input;
//       cleanedNumber =
//           cleanedNumber.startsWith('0')
//               ? cleanedNumber.substring(1)
//               : cleanedNumber;

//       // Validate that the cleaned number is exactly 10 digits
//       if (!RegExp(r'^\d{10}$').hasMatch(cleanedNumber)) {
//         return 'Please enter a valid 10-digit mobile number';
//       }
//     }

//     // No additional validation for usernames
//     return null;
//   }

//   // Normalization logic for username or mobile number
//   void _normalizeAndSaveUsernameOrMobile(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       _username = '';
//       return;
//     }

//     String input = value.trim();
//     input = input.replaceAll(RegExp(r'\s+'), '');

//     // Check if the input is a mobile number (starts with +91 or just digits)
//     if (RegExp(r'^\+?\d+$').hasMatch(input)) {
//       // Remove +91 or leading zeros if present
//       String cleanedNumber =
//           input.startsWith('+91') ? input.substring(3) : input;
//       cleanedNumber =
//           cleanedNumber.startsWith('0')
//               ? cleanedNumber.substring(1)
//               : cleanedNumber;

//       // If it's a 10-digit number, prepend +91
//       if (RegExp(r'^\d{10}$').hasMatch(cleanedNumber)) {
//         _username = '+91$cleanedNumber';
//       } else {
//         _username = input; // Keep as-is if not a valid mobile number
//       }
//     } else {
//       // If it's a username, save as-is
//       _username = input;
//     }

//     print('Normalized usernameOrMobile: $_username');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 80),
//                 Center(
//                   child: Image.asset(
//                     'assets/images/login_illustration.png',
//                     height: 180,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Log-in',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     hintText: 'Username or +91 Mobile No.',
//                     hintStyle: TextStyle(color: Color(0xFF757575)),
//                   ),
//                   style: const TextStyle(color: Color(0xFF757575)),
//                   validator: _validateUsernameOrMobile,
//                   onSaved: _normalizeAndSaveUsernameOrMobile,
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     hintText: 'Password',
//                     hintStyle: const TextStyle(color: Color(0xFF757575)),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                       onPressed:
//                           () => setState(
//                             () => _obscurePassword = !_obscurePassword,
//                           ),
//                     ),
//                   ),
//                   obscureText: _obscurePassword,
//                   style: const TextStyle(color: Color(0xFF757575)),
//                   validator:
//                       (value) =>
//                           value!.isEmpty ? 'Please enter your password' : null,
//                   onSaved: (value) => _password = value ?? '',
//                 ),
//                 const SizedBox(height: 25),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child:
//                       _isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : ElevatedButton(
//                             onPressed: _login,
//                             child: const Text('Login'),
//                           ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Don't have an account? ",
//                       style: TextStyle(color: Color(0xFF757575)),
//                     ),
//                     GestureDetector(
//                       onTap: () => Navigator.pushNamed(context, '/register'),
//                       child: const Text(
//                         'Sign-up',
//                         style: TextStyle(
//                           color: Color(0xFF2D4356),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _usernameOrEmail = ''; // Changed from _username to _usernameOrEmail
  String _password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Login method to handle form submission
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      print('Attempting login with:');
      print('  usernameOrEmail: $_usernameOrEmail');
      print('  password: $_password');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(_usernameOrEmail, _password);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e.toString().contains('Failed to fetch user details')) {
        errorMessage = 'Unable to fetch user details. Please try again later.';
      } else if (e.toString().contains('Incorrect username/email or password')) {
        errorMessage = 'Incorrect username or email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Validation for username or email
  String? _validateUsernameOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username or email';
    }

    String input = value.trim();
    // Check if the input is an email
    if (input.contains('@')) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input)) {
        return 'Please enter a valid email address';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Image.asset(
                    'assets/images/login_illustration.png',
                    height: 180,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log-in',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Username or Email',
                    hintStyle: TextStyle(color: Color(0xFF757575)),
                  ),
                  style: const TextStyle(color: Color(0xFF757575)),
                  validator: _validateUsernameOrEmail,
                  onSaved: (value) => _usernameOrEmail = value ?? '',
                ),
                const SizedBox(height: 20),
                TextFormField(
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Color(0xFF757575)),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                  onSaved: (value) => _password = value ?? '',
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF757575)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Sign-up',
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
      ),
    );
  }
}