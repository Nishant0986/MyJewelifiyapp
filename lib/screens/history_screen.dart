import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import '../models/recommendation.dart'; // Import Recommendation directly
import '../providers/auth_provider.dart';
import 'image_storage.dart';
import '../models/history_item.dart';
import 'app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _history = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isZoomed = false;
  String? _zoomedImageUrl;
  File? _zoomedLocalFile;

  static const String _baseImageUrl =
      'https://jewelify-images.s3.eu-north-1.amazonaws.com/Necklace+with+earings_sorted_jpg/';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _errorMessage = "Unauthorized: Please log in.";
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('https://jewelify-server.onrender.com/history/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 90));

      print(
        'HistoryScreen API Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _history =
                data
                    .map(
                      (item) =>
                          HistoryItem.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
            _isLoading = false;
          });
        } else if (data is Map && data.containsKey('message')) {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Session expired. Please log in again.";
          _isLoading = false;
        });
        authProvider.logout();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage =
              "Failed to fetch history: ${response.statusCode} - ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching history: $e";
        _isLoading = false;
      });
    }
  }

  void toggleExpand(int index) {
    setState(() {
      _history[index].isExpanded = !_history[index].isExpanded;
    });
  }

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

  String addEmojiToCategory(String? category) {
    if (category == null) return 'Unknown';
    switch (category.trim().toLowerCase()) {
      case 'very good':
        return '🌟 Very Good';
      case 'good':
        return '👍 Good';
      case 'neutral':
        return '😐 Neutral';
      case 'bad':
        return '👎 Bad';
      case 'very bad':
        return '😞 Very Bad';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageStorage = ImageStorage();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Prediction History',
                    style: AppTheme.titleStyle.copyWith(
                      color: theme.colorScheme.onSurface, // Adapt to theme
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _fetchHistory,
                                    style: AppTheme.primaryButtonStyle,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                            : _history.isEmpty
                            ? const Center(child: Text('No history exists'))
                            : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final item = _history[index];
                                Future<File?>? faceImageFuture;
                                Future<File?>? jewelryImageFuture;

                                if (item.isExpanded) {
                                  faceImageFuture =
                                      item.faceImagePath != null
                                          ? imageStorage.getImage(
                                            item.faceImagePath!,
                                          )
                                          : Future.value(null);
                                  jewelryImageFuture =
                                      item.jewelryImagePath != null
                                          ? imageStorage.getImage(
                                            item.jewelryImagePath!,
                                          )
                                          : Future.value(null);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: AppTheme.cardDecoration,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () => toggleExpand(index),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.timestamp,
                                                      style:
                                                          AppTheme
                                                              .itemTitleStyle,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      addEmojiToCategory(
                                                        item.category,
                                                      ),
                                                      style: AppTheme.scoreStyle
                                                          .copyWith(
                                                            fontFamily:
                                                                'NotoColorEmoji',
                                                            color:
                                                                theme
                                                                    .colorScheme
                                                                    .primary,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Score: ${(item.score * 100).toStringAsFixed(1)}%',
                                                      style: AppTheme.scoreStyle
                                                          .copyWith(
                                                            color:
                                                                theme
                                                                    .colorScheme
                                                                    .primary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                item.isExpanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (item.isExpanded)
                                        Column(
                                          children: [
                                            if (item.faceImagePath != null ||
                                                item.jewelryImagePath != null)
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    if (item.faceImagePath !=
                                                        null)
                                                      FutureBuilder<File?>(
                                                        future: faceImageFuture,
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const CircularProgressIndicator();
                                                          }
                                                          if (snapshot
                                                              .hasError) {
                                                            print(
                                                              'HistoryScreen - Face Image Error: ${snapshot.error}',
                                                            );
                                                            return Container(
                                                              width: 80,
                                                              height: 80,
                                                              color:
                                                                  Colors
                                                                      .grey[300],
                                                              child: const Icon(
                                                                Icons.error,
                                                              ),
                                                            );
                                                          }
                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null) {
                                                            return GestureDetector(
                                                              onTap:
                                                                  () => _showZoomableImage(
                                                                    null,
                                                                    snapshot
                                                                        .data,
                                                                  ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                child: Image.file(
                                                                  snapshot
                                                                      .data!,
                                                                  width: 80,
                                                                  height: 80,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    if (item.jewelryImagePath !=
                                                        null)
                                                      FutureBuilder<File?>(
                                                        future:
                                                            jewelryImageFuture,
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const CircularProgressIndicator();
                                                          }
                                                          if (snapshot
                                                              .hasError) {
                                                            print(
                                                              'HistoryScreen - Jewelry Image Error: ${snapshot.error}',
                                                            );
                                                            return Container(
                                                              width: 80,
                                                              height: 80,
                                                              color:
                                                                  Colors
                                                                      .grey[300],
                                                              child: const Icon(
                                                                Icons.error,
                                                              ),
                                                            );
                                                          }
                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null) {
                                                            return GestureDetector(
                                                              onTap:
                                                                  () => _showZoomableImage(
                                                                    null,
                                                                    snapshot
                                                                        .data,
                                                                  ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                child: Image.file(
                                                                  snapshot
                                                                      .data!,
                                                                  width: 80,
                                                                  height: 80,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  item.recommendations.length,
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color:
                                                            AppTheme
                                                                .dividerColor,
                                                      ),
                                              itemBuilder: (context, recIndex) {
                                                final recommendation =
                                                    item.recommendations[recIndex];
                                                final imageUrl =
                                                    '$_baseImageUrl${recommendation.name}';
                                                final recScore =
                                                    recommendation.score != null
                                                        ? (recommendation
                                                                    .score! *
                                                                100)
                                                            .toStringAsFixed(1)
                                                        : 'N/A';
                                                final recCategory =
                                                    addEmojiToCategory(
                                                      recommendation.category,
                                                    );

                                                return GestureDetector(
                                                  onTap:
                                                      () => _showZoomableImage(
                                                        imageUrl,
                                                        null,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16.0,
                                                        ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          child: CachedNetworkImage(
                                                            imageUrl: imageUrl,
                                                            width: 80,
                                                            height: 80,
                                                            fit: BoxFit.cover,
                                                            fadeInDuration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  color:
                                                                      Colors
                                                                          .grey[300],
                                                                  child: const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  ),
                                                                ),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) {
                                                              print(
                                                                'Image Load Error: $error for URL: $url',
                                                              );
                                                              return Container(
                                                                width: 80,
                                                                height: 80,
                                                                color:
                                                                    Colors
                                                                        .grey[300],
                                                                child:
                                                                    const Icon(
                                                                      Icons
                                                                          .error,
                                                                    ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                recommendation
                                                                    .name,
                                                                style:
                                                                    AppTheme
                                                                        .itemTitleStyle,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Score: $recScore%',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Category: $recCategory',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                  fontFamily:
                                                                      'NotoColorEmoji',
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
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
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
