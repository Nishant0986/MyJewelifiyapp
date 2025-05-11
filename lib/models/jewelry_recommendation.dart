import 'recommendation.dart';

class JewelryRecommendation {
  final String predictionId;
  final double score;
  final String category;
  final List<Recommendation> recommendations;
  final String? faceImagePath;
  final String? jewelryImagePath;

  JewelryRecommendation({
    required this.predictionId,
    required this.score,
    required this.category,
    required this.recommendations,
    this.faceImagePath,
    this.jewelryImagePath,
  });

  factory JewelryRecommendation.fromJson(
    Map<String, dynamic> json, {
    required String baseImageUrl,
  }) {
    final recommendationList = json['recommendations'] as List<dynamic>;
    final recommendations =
        recommendationList.map((item) {
          final rec = item as Map<String, dynamic>;
          return Recommendation(
            name: rec['name'] as String,
            url:
                rec['url'] != null
                    ? rec['url'] as String
                    : '$baseImageUrl${rec['name']}', // Construct URL if not provided
            score: (rec['score'] as num?)?.toDouble(),
            category: rec['category'] as String?,
          );
        }).toList();

    return JewelryRecommendation(
      predictionId: json['prediction_id'] as String,
      score: (json['score'] as num).toDouble(),
      category: json['category'] as String,
      recommendations: recommendations,
      faceImagePath: json['face_image_path'] as String?,
      jewelryImagePath: json['jewelry_image_path'] as String?,
    );
  }
}
