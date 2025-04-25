import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Random _random = Random();
  
  // Base URLs for APIs
  static const String _quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _hadithBaseUrl = 'https://ahadith-api.herokuapp.com/api';
  
  // Cache for API responses
  final Map<String, dynamic> _cache = {};
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();
  
  // Get a random ayah from the Quran
  Future<Map<String, dynamic>> getRandomAyah() async {
    try {
      // Check if we have cached ayahs
      if (_cache.containsKey('ayahs')) {
        final ayahs = _cache['ayahs'] as List<dynamic>;
        return ayahs[_random.nextInt(ayahs.length)];
      }
      
      // If not cached, fetch a random surah
      final surahNumber = _random.nextInt(114) + 1; // 1-114
      final response = await http.get(
        Uri.parse('$_quranBaseUrl/surah/$surahNumber/ar'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List<dynamic>;
        
        // Cache the ayahs
        _cache['ayahs'] = ayahs.map((ayah) {
          return {
            'arabic_text': ayah['text'],
            'surah_name': data['data']['name'],
            'surah_number': surahNumber,
            'ayah_number': ayah['numberInSurah'],
          };
        }).toList();
        
        // Return a random ayah
        final randomIndex = _random.nextInt(ayahs.length);
        return {
          'arabic_text': ayahs[randomIndex]['text'],
          'surah_name': data['data']['name'],
          'surah_number': surahNumber,
          'ayah_number': ayahs[randomIndex]['numberInSurah'],
        };
      } else {
        // Return a default ayah if API call fails
        return {
          'arabic_text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'surah_name': 'الفاتحة',
          'surah_number': 1,
          'ayah_number': 1,
        };
      }
    } catch (e) {
      // Return a default ayah if an error occurs
      return {
        'arabic_text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'surah_name': 'الفاتحة',
        'surah_number': 1,
        'ayah_number': 1,
      };
    }
  }
  
  // Get a random hadith
  Future<Map<String, dynamic>> getRandomHadith() async {
    try {
      // Check if we have cached hadiths
      if (_cache.containsKey('hadiths')) {
        final hadiths = _cache['hadiths'] as List<dynamic>;
        return hadiths[_random.nextInt(hadiths.length)];
      }
      
      // If not cached, fetch hadiths
      final response = await http.get(
        Uri.parse('$_hadithBaseUrl/hadiths/random?limit=10'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hadiths = data['data'] as List<dynamic>;
        
        // Cache the hadiths
        _cache['hadiths'] = hadiths.map((hadith) {
          return {
            'text': hadith['text'],
            'book': hadith['book'],
            'chapter': hadith['chapter'],
            'hadith_number': hadith['hadithNumber'],
          };
        }).toList();
        
        // Return a random hadith
        final randomIndex = _random.nextInt(hadiths.length);
        return {
          'text': hadiths[randomIndex]['text'],
          'book': hadiths[randomIndex]['book'],
          'chapter': hadiths[randomIndex]['chapter'],
          'hadith_number': hadiths[randomIndex]['hadithNumber'],
        };
      } else {
        // Return a default hadith if API call fails
        return {
          'text': 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى',
          'book': 'صحيح البخاري',
          'chapter': 'بدء الوحي',
          'hadith_number': 1,
        };
      }
    } catch (e) {
      // Return a default hadith if an error occurs
      return {
        'text': 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى',
        'book': 'صحيح البخاري',
        'chapter': 'بدء الوحي',
        'hadith_number': 1,
      };
    }
  }
  
  // Get prayer times for a location
  Future<Map<String, dynamic>> getPrayerTimes(
    double latitude,
    double longitude,
    String date,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=2',
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['timings'];
      } else {
        // Return default prayer times if API call fails
        return {
          'Fajr': '05:00',
          'Sunrise': '06:30',
          'Dhuhr': '12:00',
          'Asr': '15:30',
          'Maghrib': '18:00',
          'Isha': '19:30',
        };
      }
    } catch (e) {
      // Return default prayer times if an error occurs
      return {
        'Fajr': '05:00',
        'Sunrise': '06:30',
        'Dhuhr': '12:00',
        'Asr': '15:30',
        'Maghrib': '18:00',
        'Isha': '19:30',
      };
    }
  }
}
