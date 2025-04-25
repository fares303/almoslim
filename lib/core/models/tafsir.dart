/// نموذج بيانات لتفسير الآيات
class TafsirModel {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String source;

  TafsirModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.source,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'],
      text: json['text'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'text': text,
      'source': source,
    };
  }
}

/// نموذج بيانات لمصادر التفسير
class TafsirSource {
  final String id;
  final String name;
  final String description;
  final String language;

  TafsirSource({
    required this.id,
    required this.name,
    required this.description,
    required this.language,
  });

  factory TafsirSource.fromJson(Map<String, dynamic> json) {
    return TafsirSource(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'language': language,
    };
  }
}
