class Paper {
  final String id;
  final String title;
  final String summary;
  final List<String> tags;
  final String recommendationReason;
  final String imageUrl;

  Paper({
    required this.id,
    required this.title,
    required this.summary,
    this.tags = const [],
    this.recommendationReason = '',
    required this.imageUrl,
  });

  // JSON 변환 메소드
  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      recommendationReason: json['recommendationReason'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  ///샘플 데이터 반환
  static List<Paper> sampleList() {
    return [
      Paper(
        id: '1',
        title: 'Understanding Flutter State Management',
        summary:
            'A comprehensive guide to managing state in Flutter applications.',
        tags: ['Flutter', 'State Management'],
        recommendationReason:
            'Highly rated by developers for its clarity and practical examples.',
        imageUrl: 'https://example.com/flutter_state_management.png',
      ),
      Paper(
        id: '2',
        title: 'Advanced Dart Programming Techniques',
        summary: 'Explore advanced features of the Dart programming language.',
        tags: ['Dart', 'Programming'],
        recommendationReason:
            'Recommended for experienced developers looking to deepen their Dart knowledge.',
        imageUrl: 'https://example.com/advanced_dart_programming.png',
      ),
      Paper(
        id: '3',
        title: 'Building Responsive UIs with Flutter',
        summary: 'Learn how to create responsive user interfaces in Flutter.',
        tags: ['Flutter', 'UI Design'],
        recommendationReason:
            'Popular among UI designers for its practical tips and examples.',
        imageUrl: 'https://example.com/flutter_responsive_ui.png',
      ),
    ];
  }
}
