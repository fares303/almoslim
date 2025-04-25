class Reciter {
  final String id;
  final String name;
  final String server;
  final int count;
  final String letter;
  final String suras;

  Reciter({
    required this.id,
    required this.name,
    required this.server,
    required this.count,
    required this.letter,
    required this.suras,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'],
      name: json['name'],
      server: json['Server'],
      count: int.parse(json['count']),
      letter: json['letter'],
      suras: json['suras'],
    );
  }

  String getAudioUrl(int surahNumber, {bool bitRate128 = true}) {
    final surahFormatted = surahNumber.toString().padLeft(3, '0');
    final bitRateFolder = bitRate128 ? '128' : '64';
    return '$server/$bitRateFolder/$surahFormatted.mp3';
  }
}
