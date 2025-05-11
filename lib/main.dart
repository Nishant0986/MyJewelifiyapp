import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => authProvider)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'Jewelry Match',
          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: authProvider.isAuthenticated ? '/home' : '/register',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/register':
                return MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              case '/home':
                return MaterialPageRoute(
                  builder:
                      (context) => HomeScreen(
                        toggleTheme: toggleTheme,
                        isDarkMode: isDarkMode,
                      ),
                );
              case '/upload':
                return MaterialPageRoute(
                  builder: (context) => const UploadScreen(),
                );
              case '/processing':
                return MaterialPageRoute(
                  builder: (context) => const ProcessingScreen(),
                  settings: settings, // Pass the settings to preserve arguments
                );
              case '/results':
                return MaterialPageRoute(
                  builder: (context) => const ResultsScreen(),
                  settings: settings,
                );
              case '/history':
                return MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                );
              default:
                return MaterialPageRoute(
                  builder:
                      (context) => Scaffold(
                        body: Center(
                          child: Text('Route not found: ${settings.name}'),
                        ),
                      ),
                );
            }
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
