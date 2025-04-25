import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/models/daily_dhikr.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

/// خدمة الأذكار اليومية
class DailyDhikrService {
  static const String _dailyDhikrKey = 'daily_dhikr';
  static const String _lastUpdateKey = 'daily_dhikr_last_update';
  
  // قائمة الأذكار المحلية
  final List<Map<String, dynamic>> _localDhikrs = [
    {
      'id': 1,
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'source': 'متفق عليه',
      'repetition_count': 100,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
    },
    {
      'id': 2,
      'text': 'لا إلَهَ إلاّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'source': 'متفق عليه',
      'repetition_count': 100,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من قالها في يوم مائة مرة كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة، وكانت له حرزا من الشيطان يومه ذلك حتى يمسي',
    },
    {
      'id': 3,
      'text': 'أسْتَغْفِرُ اللهَ وَأتُوبُ إلَيْهِ',
      'source': 'رواه البخاري',
      'repetition_count': 100,
      'category': 'أذكار الاستغفار',
      'virtue': 'من قالها في يوم مائة مرة غفرت ذنوبه وإن كانت مثل زبد البحر',
    },
    {
      'id': 4,
      'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      'source': 'متفق عليه',
      'repetition_count': 10,
      'category': 'الصلاة على النبي',
      'virtue': 'من صلى علي صلاة صلى الله عليه بها عشرا',
    },
    {
      'id': 5,
      'text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      'source': 'رواه ابن ماجه',
      'repetition_count': 3,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من أفضل ما يدعو به العبد',
    },
    {
      'id': 6,
      'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنْ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنْ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
      'source': 'رواه البخاري',
      'repetition_count': 3,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
    {
      'id': 7,
      'text': 'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ إِلا أَنْتَ',
      'source': 'رواه البخاري',
      'repetition_count': 1,
      'category': 'سيد الاستغفار',
      'virtue': 'من قالها موقنا بها حين يمسي فمات من ليلته دخل الجنة، وكذلك حين يصبح',
    },
    {
      'id': 8,
      'text': 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لا إِلَهَ إِلا أَنْتَ وَحْدَكَ لا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      'source': 'رواه أبو داود',
      'repetition_count': 4,
      'category': 'أذكار الصباح',
      'virtue': 'من قالها أعتقه الله من النار',
    },
    {
      'id': 9,
      'text': 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
      'source': 'رواه أبو داود',
      'repetition_count': 1,
      'category': 'أذكار الصباح',
      'virtue': 'من قالها حين يصبح فقد أدى شكر يومه',
    },
    {
      'id': 10,
      'text': 'حَسْبِيَ اللَّهُ لا إِلَهَ إِلا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      'source': 'رواه أبو داود',
      'repetition_count': 7,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من قالها كفاه الله ما أهمه من أمر الدنيا والآخرة',
    },
    {
      'id': 11,
      'text': 'بِسْمِ اللَّهِ الَّذِي لا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      'source': 'رواه أبو داود والترمذي',
      'repetition_count': 3,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من قالها ثلاث مرات حين يصبح وثلاث مرات حين يمسي لم يضره شيء',
    },
    {
      'id': 12,
      'text': 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
      'source': 'رواه أبو داود والترمذي',
      'repetition_count': 3,
      'category': 'أذكار الصباح والمساء',
      'virtue': 'من قالها ثلاث مرات حين يصبح وثلاث مرات حين يمسي كان حقا على الله أن يرضيه يوم القيامة',
    },
    {
      'id': 13,
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
      'source': 'رواه مسلم',
      'repetition_count': 3,
      'category': 'أذكار الصباح',
      'virtue': 'من أفضل الذكر',
    },
    {
      'id': 14,
      'text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
      'source': 'رواه ابن ماجه',
      'repetition_count': 1,
      'category': 'أذكار الصباح',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
    {
      'id': 15,
      'text': 'اللَّهُمَّ أَنْتَ السَّلامُ، وَمِنْكَ السَّلامُ، تَبَارَكْتَ يَا ذَا الْجَلالِ وَالإِكْرَامِ',
      'source': 'رواه مسلم',
      'repetition_count': 1,
      'category': 'أذكار بعد الصلاة',
      'virtue': 'من أذكار النبي صلى الله عليه وسلم بعد الصلاة',
    },
    {
      'id': 16,
      'text': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
      'source': 'رواه أبو داود والنسائي',
      'repetition_count': 1,
      'category': 'أذكار بعد الصلاة',
      'virtue': 'وصية النبي صلى الله عليه وسلم لمعاذ بن جبل',
    },
    {
      'id': 17,
      'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لا يَنْفَعُ، وَمِنْ قَلْبٍ لا يَخْشَعُ، وَمِنْ نَفْسٍ لا تَشْبَعُ، وَمِنْ دَعْوَةٍ لا يُسْتَجَابُ لَهَا',
      'source': 'رواه مسلم',
      'repetition_count': 1,
      'category': 'أدعية مأثورة',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
    {
      'id': 18,
      'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ مَا عَمِلْتُ، وَمِنْ شَرِّ مَا لَمْ أَعْمَلْ',
      'source': 'رواه مسلم',
      'repetition_count': 1,
      'category': 'أدعية مأثورة',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
    {
      'id': 19,
      'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
      'source': 'رواه مسلم',
      'repetition_count': 1,
      'category': 'أدعية مأثورة',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
    {
      'id': 20,
      'text': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ، دِقَّهُ وَجِلَّهُ، وَأَوَّلَهُ وَآخِرَهُ، وَعَلانِيَتَهُ وَسِرَّهُ',
      'source': 'رواه مسلم',
      'repetition_count': 1,
      'category': 'أدعية الاستغفار',
      'virtue': 'من أدعية النبي صلى الله عليه وسلم',
    },
  ];
  
  /// الحصول على الذكر اليومي
  Future<DailyDhikr> getDailyDhikr() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // التحقق مما إذا كان يجب تحديث الذكر اليومي
      final shouldUpdate = _shouldUpdateDailyDhikr(prefs);
      
      if (shouldUpdate) {
        // محاولة الحصول على ذكر جديد من الإنترنت
        try {
          final dhikr = await _fetchDhikrFromApi();
          if (dhikr != null) {
            // حفظ الذكر الجديد في التخزين المحلي
            await _saveDailyDhikr(prefs, dhikr);
            return dhikr;
          }
        } catch (e) {
          debugPrint('Error fetching dhikr from API: $e');
          // في حالة فشل الاتصال بالإنترنت، استخدم الأذكار المحلية
        }
        
        // اختيار ذكر عشوائي من القائمة المحلية
        final dhikr = _getRandomLocalDhikr();
        
        // حفظ الذكر الجديد في التخزين المحلي
        await _saveDailyDhikr(prefs, dhikr);
        
        return dhikr;
      } else {
        // استخدام الذكر المخزن محليًا
        final dhikrJson = prefs.getString(_dailyDhikrKey);
        if (dhikrJson != null) {
          return DailyDhikr.fromJson(json.decode(dhikrJson));
        } else {
          // إذا لم يكن هناك ذكر مخزن، اختر ذكر عشوائي
          final dhikr = _getRandomLocalDhikr();
          await _saveDailyDhikr(prefs, dhikr);
          return dhikr;
        }
      }
    } catch (e) {
      debugPrint('Error in getDailyDhikr: $e');
      // في حالة حدوث خطأ، استخدم ذكر افتراضي
      return _getDefaultDhikr();
    }
  }
  
  /// التحقق مما إذا كان يجب تحديث الذكر اليومي
  bool _shouldUpdateDailyDhikr(SharedPreferences prefs) {
    final lastUpdateString = prefs.getString(_lastUpdateKey);
    if (lastUpdateString == null) {
      return true;
    }
    
    final lastUpdate = DateTime.parse(lastUpdateString);
    final now = DateTime.now();
    
    // تحديث الذكر إذا كان آخر تحديث في يوم مختلف
    return lastUpdate.day != now.day || 
           lastUpdate.month != now.month || 
           lastUpdate.year != now.year;
  }
  
  /// حفظ الذكر اليومي في التخزين المحلي
  Future<void> _saveDailyDhikr(SharedPreferences prefs, DailyDhikr dhikr) async {
    await prefs.setString(_dailyDhikrKey, json.encode(dhikr.toJson()));
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }
  
  /// الحصول على ذكر عشوائي من القائمة المحلية
  DailyDhikr _getRandomLocalDhikr() {
    final random = Random();
    final randomIndex = random.nextInt(_localDhikrs.length);
    return DailyDhikr.fromJson(_localDhikrs[randomIndex]);
  }
  
  /// الحصول على ذكر افتراضي
  DailyDhikr _getDefaultDhikr() {
    return DailyDhikr(
      id: 1,
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      source: 'متفق عليه',
      repetitionCount: 100,
      category: 'أذكار الصباح والمساء',
      virtue: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
    );
  }
  
  /// الحصول على ذكر من واجهة برمجة التطبيقات
  Future<DailyDhikr?> _fetchDhikrFromApi() async {
    try {
      // يمكن استبدال هذا برابط API حقيقي
      final response = await http.get(
        Uri.parse('https://api.example.com/daily-dhikr'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DailyDhikr.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in _fetchDhikrFromApi: $e');
      return null;
    }
  }
  
  /// الحصول على قائمة الأذكار المحلية
  List<DailyDhikr> getAllLocalDhikrs() {
    return _localDhikrs.map((json) => DailyDhikr.fromJson(json)).toList();
  }
  
  /// الحصول على قائمة الأذكار حسب الفئة
  List<DailyDhikr> getDhikrsByCategory(String category) {
    return _localDhikrs
        .where((json) => json['category'] == category)
        .map((json) => DailyDhikr.fromJson(json))
        .toList();
  }
  
  /// الحصول على فئات الأذكار
  List<String> getDhikrCategories() {
    final categories = <String>{};
    for (final dhikr in _localDhikrs) {
      if (dhikr['category'] != null) {
        categories.add(dhikr['category'] as String);
      }
    }
    return categories.toList();
  }
}
