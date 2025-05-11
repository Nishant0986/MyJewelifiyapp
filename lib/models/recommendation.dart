class Recommendation {
  final String name;
  final String? url;
  final double? score; // Add score field
  final String? category; // Add category field

  Recommendation({required this.name, this.url, this.score, this.category});

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'] as String,
      url: json['url'] as String?,
      score: (json['score'] as num?)?.toDouble(), // Parse score
      category: json['category'] as String?, // Parse category
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'score': score, 'category': category};
  }
}
