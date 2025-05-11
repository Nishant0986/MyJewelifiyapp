import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'image_storage.dart';
import '../providers/auth_provider.dart';
import '../models/jewelry_recommendation.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _isLoading = true;
  String? _error;
  JewelryRecommendation? _recommendation;
  bool _hasProcessed = false;

  // Define the base URL here (same as in ResultsScreen)
  static const String _baseImageUrl =
      'https://jewelify-images.s3.eu-north-1.amazonaws.com/Necklace+with+earings_sorted_jpg/';

  @override
  void initState() {
    super.initState();
    print('ProcessingScreen created');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasProcessed) {
      _hasProcessed = true;
      _processImages();
    }
  }

  Future<void> _processImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final args = ModalRoute.of(context)!.settings.arguments;
        print(
          'Attempt $attempt - Arguments received: $args, type: ${args.runtimeType}',
        );
        if (args is! Map<String, dynamic>) {
          throw Exception(
            'Invalid arguments: expected Map<String, dynamic>, got ${args.runtimeType}',
          );
        }
        final Map<String, dynamic> argsMap = args as Map<String, dynamic>;
        final String facePath = argsMap['facePath'] as String;
        final String jewelryPath = argsMap['jewelryPath'] as String;
        final File face = File(facePath);
        final File jewelry = File(jewelryPath);

        if (!await face.exists()) {
          throw Exception('Face image file does not exist: $facePath');
        }
        if (!await jewelry.exists()) {
          throw Exception('Jewelry image file does not exist: $jewelryPath');
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;

        if (token == null) {
          throw Exception('User not authenticated');
        }

        final imageStorage = ImageStorage();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final savedFacePath = await imageStorage.saveImage(
          face,
          'face_$timestamp',
        );
        final savedJewelryPath = await imageStorage.saveImage(
          jewelry,
          'jewelry_$timestamp',
        );

        if (savedFacePath == null || savedJewelryPath == null) {
          throw Exception('Failed to save images locally');
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://jewelify-server.onrender.com/predictions/predict'),
        );

        request.headers['Authorization'] = 'Bearer $token';

        request.files.add(
          await http.MultipartFile.fromPath(
            'face',
            face.path,
            contentType: http_parser.MediaType('image', 'jpeg'),
          ),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'jewelry',
            jewelry.path,
            contentType: http_parser.MediaType('image', 'jpeg'),
          ),
        );
        request.fields['face_image_path'] = savedFacePath;
        request.fields['jewelry_image_path'] = savedJewelryPath;

        print(
          'Attempt $attempt: Sending request to /predictions/predict with token: $token',
        );
        print('Face path: ${face.path}, Jewelry path: ${jewelry.path}');
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}, body: $responseBody');

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          setState(() {
            _recommendation = JewelryRecommendation.fromJson(
              data,
              baseImageUrl: _baseImageUrl,
            );
            _isLoading = false;
          });

          if (mounted) {
            final navArgs = {
              'recommendation': _recommendation,
              'facePath': savedFacePath,
              'jewelryPath': savedJewelryPath,
            };
            print('Navigating to /results with arguments: $navArgs');
            try {
              Navigator.pushReplacementNamed(
                context,
                '/results',
                arguments: navArgs,
              );
            } catch (navError) {
              print('Navigation to /results failed: $navError');
              setState(() {
                _error = 'Failed to navigate to results: $navError';
                _isLoading = false;
              });
              return;
            }
          }
          return;
        } else {
          final errorData = jsonDecode(responseBody);
          setState(() {
            _error = errorData['detail'] ?? 'Unknown error';
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        } else {
          print('Retrying after ${2 * attempt} seconds...');
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Processing your images...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
                : _error != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}


