class AdkarCategory {
  final int id;
  final String name;
  final String description;
  final int count;

  AdkarCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
  });

  factory AdkarCategory.fromJson(Map<String, dynamic> json) {
    return AdkarCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class Dhikr {
  final int id;
  final String text;
  final String? translation;
  final int? count;
  final String? reference;
  final int categoryId;
  bool isFavorite;
  bool isCompleted;

  Dhikr({
    required this.id,
    required this.text,
    this.translation,
    this.count,
    this.reference,
    required this.categoryId,
    this.isFavorite = false,
    this.isCompleted = false,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json, int categoryId) {
    return Dhikr(
      id: json['id'],
      text: json['text'],
      translation: json['translation'],
      count: json['count'],
      reference: json['reference'],
      categoryId: categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'count': count,
      'reference': reference,
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'isCompleted': isCompleted,
    };
  }

  Dhikr copyWith({
    int? id,
    String? text,
    String? translation,
    int? count,
    String? reference,
    int? categoryId,
    bool? isFavorite,
    bool? isCompleted,
  }) {
    return Dhikr(
      id: id ?? this.id,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      count: count ?? this.count,
      reference: reference ?? this.reference,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
