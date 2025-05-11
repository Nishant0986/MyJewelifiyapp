import 'recommendation.dart';

class HistoryItem {
  final String id;
  final double score;
  final String category;
  final List<Recommendation> recommendations;
  final String? faceImagePath;
  final String? jewelryImagePath;
  final String timestamp;
  bool isExpanded;

  HistoryItem({
    required this.id,
    required this.score,
    required this.category,
    required this.recommendations,
    this.faceImagePath,
    this.jewelryImagePath,
    required this.timestamp,
    this.isExpanded = false,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      score: (json['score'] as num).toDouble(),
      category: json['category'] as String,
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map(
                (item) => Recommendation.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      faceImagePath: json['face_image_path'] as String?,
      jewelryImagePath: json['jewelry_image_path'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }
}
