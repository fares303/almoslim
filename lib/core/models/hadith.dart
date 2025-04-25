class Hadith {
  final String id;
  final String title;
  final String text;
  final String source;
  final String? grade;
  final String? reference;
  final String? translation;
  bool isFavorite;

  Hadith({
    required this.id,
    required this.title,
    required this.text,
    required this.source,
    this.grade,
    this.reference,
    this.translation,
    this.isFavorite = false,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      source: json['source'] ?? '',
      grade: json['grade'],
      reference: json['reference'],
      translation: json['translation'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'source': source,
      'grade': grade,
      'reference': reference,
      'translation': translation,
      'isFavorite': isFavorite,
    };
  }

  Hadith copyWith({
    String? id,
    String? title,
    String? text,
    String? source,
    String? grade,
    String? reference,
    String? translation,
    bool? isFavorite,
  }) {
    return Hadith(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      source: source ?? this.source,
      grade: grade ?? this.grade,
      reference: reference ?? this.reference,
      translation: translation ?? this.translation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Extension on String to add capitalize method
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
