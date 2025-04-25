class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int page;
  final int hizbQuarter;
  final bool sajda;
  final String? translation;
  final String? transliteration;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    required this.sajda,
    this.translation,
    this.transliteration,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    // Handle potential null or missing values
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      sajda: json['sajda'] == true, // Convert to boolean safely
      translation: json['translation'],
      transliteration: json['transliteration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'page': page,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda,
      'translation': translation,
      'transliteration': transliteration,
    };
  }
}
