import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:al_moslim/core/constants/api_constants.dart';
import 'package:al_moslim/core/models/surah.dart';
import 'package:al_moslim/core/models/ayah.dart';

class QuranService {
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.quranBaseUrl}/surah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsData = data['data'];
        return surahsData.map((surah) => Surah.fromJson(surah)).toList();
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.quranBaseUrl}/surah/$surahNumber/${ApiConstants.quranEdition}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahsData = data['data']['ayahs'];

        // Print for debugging
        debugPrint('Loaded ${ayahsData.length} ayahs for surah $surahNumber');
        if (ayahsData.isNotEmpty) {
          debugPrint('First ayah sample: ${ayahsData.first}');
        }

        return ayahsData.map((ayah) => Ayah.fromJson(ayah)).toList();
      } else {
        debugPrint('Failed to load ayahs: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to load ayahs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading ayahs: $e');
      throw Exception('Error: $e');
    }
  }

  // Get text for a specific ayah
  Future<String> getAyahText(int surahNumber, int ayahNumber) async {
    try {
      final ayahs = await getAyahsForSurah(surahNumber);
      if (ayahs.isEmpty || ayahNumber > ayahs.length) {
        return 'لم يتم العثور على الآية';
      }

      // Ayah numbers are 1-based, but list indices are 0-based
      final ayah = ayahs[ayahNumber - 1];
      return ayah.text;
    } catch (e) {
      debugPrint('Error in getAyahText: $e');
      return 'حدث خطأ في تحميل الآية';
    }
  }

  Future<List<Ayah>> getAyahsWithTranslation(int surahNumber) async {
    try {
      final arabicResponse = await http.get(
        Uri.parse(
          '${ApiConstants.quranBaseUrl}/surah/$surahNumber/${ApiConstants.quranEdition}',
        ),
      );

      final translationResponse = await http.get(
        Uri.parse(
          '${ApiConstants.quranBaseUrl}/surah/$surahNumber/${ApiConstants.quranTranslationEdition}',
        ),
      );

      if (arabicResponse.statusCode == 200 &&
          translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);

        final List<dynamic> arabicAyahs = arabicData['data']['ayahs'];
        final List<dynamic> translationAyahs = translationData['data']['ayahs'];

        final List<Ayah> ayahs = [];

        for (int i = 0; i < arabicAyahs.length; i++) {
          final arabicAyah = arabicAyahs[i];
          final translationAyah = translationAyahs[i];

          ayahs.add(
            Ayah(
              number: arabicAyah['number'],
              text: arabicAyah['text'],
              numberInSurah: arabicAyah['numberInSurah'],
              juz: arabicAyah['juz'],
              page: arabicAyah['page'],
              hizbQuarter: arabicAyah['hizbQuarter'],
              sajda: arabicAyah['sajda'] ?? false,
              translation: translationAyah['text'],
            ),
          );
        }

        return ayahs;
      } else {
        throw Exception('Failed to load ayahs with translation');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Ayah>> searchQuran(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.quranBaseUrl}/search/${ApiConstants.quranEdition}/$query',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesData = data['data']['matches'];
        return matchesData.map((match) => Ayah.fromJson(match)).toList();
      } else {
        throw Exception('Failed to search Quran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get audio URL for a surah and reciter
  Future<List<String>> getAllAudioUrls(
      int surahNumber, String reciterId) async {
    try {
      // Format surah number with leading zeros (e.g., 001, 002, etc.)
      String formattedSurahNumber = surahNumber.toString().padLeft(3, '0');

      // List to store all possible URLs
      List<String> urls = [];

      // MP3Quran.net - Using only server6 as requested
      final Map<String, String> mp3QuranFolders = {
        '7': 'mishari', // Mishari Rashid al-Afasy
        '3': 'basit', // Abdul Basit
        '6': 'husr', // Mahmoud Khalil Al-Husary
        '9': 'ahmad_huth', // Ahmed Al-Ajamy
        '10': 'minsh', // Mohammad Siddiq Al-Minshawi
        '11': 'maher', // Maher Al Muaiqly
        '12': 'sds', // Abdurrahman As-Sudais
        '128': 's_gmd', // Saad Al-Ghamdi
        '13': 'bna', // Bandar Baleela
        '14': 'idrees', // Idrees Abkar
        '15': 'hani', // Hani Ar-Rifai
        '16': 'hudhaify', // Ali Al-Hudhaifi
        '17': 'fares', // Fares Abbad
      };

      if (mp3QuranFolders.containsKey(reciterId)) {
        final folder = mp3QuranFolders[reciterId]!;

        // Add only server6.mp3quran.net URL as requested
        urls.add(
            'https://server6.mp3quran.net/$folder/$formattedSurahNumber.mp3');
      }

      // Always add Mishari (Alafasy) as fallback for any reciter
      if (reciterId != '7') {
        // Add only server6.mp3quran.net URL for Mishari as fallback
        urls.add(
            'https://server6.mp3quran.net/mishari/$formattedSurahNumber.mp3');
      }

      return urls;
    } catch (e) {
      debugPrint('Error in getAllAudioUrls: $e');
      // Return the most reliable URL for Mishari if everything fails
      String formattedSurahNumber = surahNumber.toString().padLeft(3, '0');
      return ['https://server6.mp3quran.net/mishari/$formattedSurahNumber.mp3'];
    }
  }

  // Get the primary audio URL (first one to try)
  Future<String> getAudioUrl(int surahNumber, String reciterId) async {
    try {
      List<String> allUrls = await getAllAudioUrls(surahNumber, reciterId);
      return allUrls.first; // Return the first URL (primary)
    } catch (e) {
      throw Exception('فشل في الحصول على رابط الصوت');
    }
  }

  // Get alternative URLs to try if the primary one fails
  Future<List<String>> getAlternativeAudioUrls(
      int surahNumber, String reciterId) async {
    try {
      List<String> allUrls = await getAllAudioUrls(surahNumber, reciterId);
      return allUrls.skip(1).toList(); // Return all URLs except the first one
    } catch (e) {
      return [];
    }
  }

  // For backward compatibility
  Future<String?> getAlternativeAudioUrl(
      int surahNumber, String reciterId) async {
    try {
      List<String> alternatives =
          await getAlternativeAudioUrls(surahNumber, reciterId);
      return alternatives.isNotEmpty ? alternatives.first : null;
    } catch (e) {
      return null;
    }
  }

  /// توليد رابط مباشر لملف صوتي للآية القرآنية
  ///
  /// [surahNumber]: رقم السورة (1-114)
  /// [ayahNumber]: رقم الآية
  /// [reciterId]: معرف القارئ (اختياري، الافتراضي هو المشاري راشد العفاسي)
  ///
  /// يعيد رابط URL للملف الصوتي أو null إذا كانت المدخلات غير صالحة
  String? generateAyahAudioUrl({
    required int surahNumber,
    required int ayahNumber,
    String reciterId = '7', // المشاري راشد العفاسي هو الافتراضي
  }) {
    // التحقق من صحة المدخلات
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      return null;
    }

    // تنسيق رقم السورة ورقم الآية بإضافة أصفار في البداية إذا لزم الأمر
    String formattedSurahNumber = surahNumber.toString().padLeft(3, '0');
    String formattedAyahNumber = ayahNumber.toString().padLeft(3, '0');

    // خريطة معرفات القراء إلى أسماء المجلدات في everyayah.com
    final Map<String, String> reciterFolders = {
      '7': 'Alafasy_128kbps', // المشاري راشد العفاسي
      '3': 'Abdul_Basit_Murattal', // عبد الباسط عبد الصمد
      '6': 'Husary_128kbps', // محمود خليل الحصري
      '9': 'Ajamy_128kbps', // أحمد العجمي
      '10': 'Minshawy_Murattal', // محمد صديق المنشاوي
      '11': 'Maher_AlMuaiqly_64kbps', // ماهر المعيقلي
      '12': 'Abdurrahmaan_As-Sudais_192kbps', // عبد الرحمن السديس
      '128': 'Ghamadi_40kbps', // سعد الغامدي
      '13': 'bandar', // بندر بليلة
      '14': 'ahmad_ibn_ali_al_ajamy', // إدريس أبكر
      '15': 'hani_rifai', // هاني الرفاعي
      '16': 'hudhaify', // علي الحذيفي
      '17': 'fares_abbad', // فارس عباد
    };

    // الحصول على اسم مجلد القارئ، استخدام المشاري راشد العفاسي كقارئ افتراضي إذا لم يتم العثور على القارئ
    final reciterFolder = reciterFolders[reciterId] ?? 'Alafasy_128kbps';

    // بناء رابط URL
    return 'https://everyayah.com/data/$reciterFolder/$formattedSurahNumber$formattedAyahNumber.mp3';
  }

  /// توليد قائمة بروابط بديلة للآية القرآنية من مصادر مختلفة
  ///
  /// [surahNumber]: رقم السورة (1-114)
  /// [ayahNumber]: رقم الآية
  /// [reciterId]: معرف القارئ (اختياري، الافتراضي هو المشاري راشد العفاسي)
  ///
  /// يعيد قائمة بروابط URL بديلة للملف الصوتي
  List<String> generateAlternativeAyahAudioUrls({
    required int surahNumber,
    required int ayahNumber,
    String reciterId = '7', // المشاري راشد العفاسي هو الافتراضي
  }) {
    List<String> urls = [];

    // التحقق من صحة المدخلات
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      return urls;
    }

    // تنسيق رقم السورة ورقم الآية بإضافة أصفار في البداية إذا لزم الأمر
    String formattedSurahNumber = surahNumber.toString().padLeft(3, '0');
    String formattedAyahNumber = ayahNumber.toString().padLeft(3, '0');

    // خريطة معرفات القراء إلى معرفاتهم في مصادر مختلفة
    final Map<String, Map<String, String>> reciterMappings = {
      '7': {
        'everyayah': 'Alafasy_128kbps',
        'everyayah_alt': 'alafasy',
        'verses': 'Alafasy',
      },
      '3': {
        'everyayah': 'Abdul_Basit_Murattal',
        'everyayah_alt': 'AbdulSamad_64kbps_QuranExplorer.Com',
        'verses': 'AbdulSamad',
      },
      '6': {
        'everyayah': 'Husary_128kbps',
        'everyayah_alt': 'Husary_Mujawwad_128kbps',
        'verses': 'Husary',
      },
      '11': {
        'everyayah': 'Maher_AlMuaiqly_64kbps',
        'verses': 'Maher',
      },
      '12': {
        'everyayah': 'Abdurrahmaan_As-Sudais_192kbps',
        'everyayah_alt': 'Abdurrahmaan_As-Sudais_64kbps',
        'verses': 'Sudais',
      },
      '128': {
        'everyayah': 'Ghamadi_40kbps',
        'verses': 'Ghamadi',
      },
    };

    // الحصول على معرفات القارئ، استخدام المشاري راشد العفاسي كقارئ افتراضي إذا لم يتم العثور على القارئ
    final reciterIds = reciterMappings[reciterId] ?? reciterMappings['7']!;

    // إضافة روابط من everyayah.com
    if (reciterIds.containsKey('everyayah')) {
      urls.add(
          'https://everyayah.com/data/${reciterIds['everyayah']}/$formattedSurahNumber$formattedAyahNumber.mp3');
    }

    // إضافة روابط بديلة من everyayah.com
    if (reciterIds.containsKey('everyayah_alt')) {
      urls.add(
          'https://everyayah.com/data/${reciterIds['everyayah_alt']}/$formattedSurahNumber$formattedAyahNumber.mp3');
    }

    // إضافة روابط من verses.quran.com
    if (reciterIds.containsKey('verses')) {
      urls.add(
          'https://verses.quran.com/${reciterIds['verses']}/$formattedSurahNumber$formattedAyahNumber.mp3');
    }

    // إضافة المشاري راشد العفاسي كبديل إذا كان القارئ المطلوب ليس هو
    if (reciterId != '7') {
      urls.add(
          'https://everyayah.com/data/Alafasy_128kbps/$formattedSurahNumber$formattedAyahNumber.mp3');
    }

    return urls;
  }

  /// الحصول على جميع روابط الآية الصوتية (الرئيسية والبديلة)
  ///
  /// [surahNumber]: رقم السورة (1-114)
  /// [ayahNumber]: رقم الآية
  /// [reciterId]: معرف القارئ (اختياري، الافتراضي هو المشاري راشد العفاسي)
  Future<List<String>> getAllAyahAudioUrls({
    required int surahNumber,
    required int ayahNumber,
    String reciterId = '7',
  }) async {
    List<String> urls = [];

    // إضافة الرابط الرئيسي
    String? primaryUrl = generateAyahAudioUrl(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );

    if (primaryUrl != null) {
      urls.add(primaryUrl);
    }

    // إضافة الروابط البديلة
    urls.addAll(generateAlternativeAyahAudioUrls(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    ));

    return urls;
  }
}
