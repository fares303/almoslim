/// نموذج بيانات للذكر اليومي
class DailyDhikr {
  final int id;
  final String text;
  final String source;
  final String? translation;
  final int? repetitionCount;
  final String? category;
  final String? virtue;

  DailyDhikr({
    required this.id,
    required this.text,
    required this.source,
    this.translation,
    this.repetitionCount,
    this.category,
    this.virtue,
  });

  factory DailyDhikr.fromJson(Map<String, dynamic> json) {
    return DailyDhikr(
      id: json['id'],
      text: json['text'],
      source: json['source'],
      translation: json['translation'],
      repetitionCount: json['repetition_count'],
      category: json['category'],
      virtue: json['virtue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'source': source,
      'translation': translation,
      'repetition_count': repetitionCount,
      'category': category,
      'virtue': virtue,
    };
  }
}
