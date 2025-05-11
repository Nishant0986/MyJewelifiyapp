import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import '../models/jewelry_recommendation.dart';
import 'image_storage.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isZoomed = false;
  String? _zoomedImageUrl;
  File? _zoomedLocalFile;

  void _showZoomableImage(String? imageUrl, File? localFile) {
    setState(() {
      _isZoomed = true;
      _zoomedImageUrl = imageUrl;
      _zoomedLocalFile = localFile;
    });
    HapticFeedback.lightImpact();
  }

  void _hideZoomableImage() {
    setState(() {
      _isZoomed = false;
      _zoomedImageUrl = null;
      _zoomedLocalFile = null;
    });
  }

  String _addEmojiToCategory(String? category) {
    if (category == null) return 'Unknown';
    switch (category) {
      case 'Very Good':
        return '🌟 Very Good';
      case 'Good':
        return '👍 Good';
      case 'Neutral':
        return '😐 Neutral';
      case 'Bad':
        return '👎 Bad';
      case 'Very Bad':
        return '😞 Very Bad';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    print('ResultsScreen received arguments: $args');
    if (args == null || args is! Map<String, dynamic>) {
      print('Invalid arguments type: ${args.runtimeType}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: Invalid navigation arguments. Expected Map<String, dynamic>, but got ${args.runtimeType}. Arguments: $args',
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final JewelryRecommendation recommendation =
        args['recommendation'] as JewelryRecommendation;
    final String facePath = args['facePath'] as String;
    final String jewelryPath = args['jewelryPath'] as String;

    final double scaledScore = recommendation.score * 100;

    String categoryWithEmoji = _addEmojiToCategory(recommendation.category);

    final imageStorage = ImageStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Prediction Result',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<File?>(
                      future: imageStorage.getImage(facePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Face image not found');
                        }
                        return GestureDetector(
                          onTap: () => _showZoomableImage(null, snapshot.data),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              snapshot.data!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    FutureBuilder<File?>(
                      future: imageStorage.getImage(jewelryPath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Jewelry image not found');
                        }
                        return GestureDetector(
                          onTap: () => _showZoomableImage(null, snapshot.data),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              snapshot.data!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Compatibility Score: ${scaledScore.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  'Category: $categoryWithEmoji',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendation.recommendations.length,
                  separatorBuilder:
                      (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                  itemBuilder: (context, index) {
                    final rec = recommendation.recommendations[index];
                    final recScore =
                        rec.score != null
                            ? (rec.score! * 100).toStringAsFixed(1)
                            : 'N/A';
                    final recCategory = _addEmojiToCategory(rec.category);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _showZoomableImage(rec.url, null),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: rec.url ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  placeholder:
                                      (context, url) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) {
                                    print(
                                      'Image Load Error: $error for URL: $url',
                                    );
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Score: $recScore%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: $recCategory',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
          if (_isZoomed)
            GestureDetector(
              onTap: _hideZoomableImage,
              child: Container(
                color: Colors.black54,
                child: Stack(
                  children: [
                    Center(
                      child: PhotoView(
                        imageProvider:
                            _zoomedLocalFile != null
                                ? FileImage(_zoomedLocalFile!)
                                : CachedNetworkImageProvider(_zoomedImageUrl!),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        initialScale: PhotoViewComputedScale.contained,
                        onTapUp: (context, details, controllerValue) {
                          _hideZoomableImage();
                        },
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: _hideZoomableImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
