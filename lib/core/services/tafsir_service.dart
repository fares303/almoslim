import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:al_moslim/core/models/tafsir.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تفسير القرآن
class TafsirService {
  // قائمة مصادر التفسير المتاحة
  final List<TafsirSource> _availableSources = [
    TafsirSource(
      id: 'ar-muyassar',
      name: 'التفسير الميسر',
      description: 'تفسير ميسر للقرآن الكريم',
      language: 'ar',
    ),
    TafsirSource(
      id: 'ar-jalalayn',
      name: 'تفسير الجلالين',
      description: 'تفسير الجلالين للقرآن الكريم',
      language: 'ar',
    ),
    TafsirSource(
      id: 'ar-baghawy',
      name: 'تفسير البغوي',
      description: 'تفسير البغوي للقرآن الكريم',
      language: 'ar',
    ),
    TafsirSource(
      id: 'ar-tabari',
      name: 'تفسير الطبري',
      description: 'تفسير الطبري للقرآن الكريم',
      language: 'ar',
    ),
    TafsirSource(
      id: 'ar-qurtubi',
      name: 'تفسير القرطبي',
      description: 'تفسير القرطبي للقرآن الكريم',
      language: 'ar',
    ),
    TafsirSource(
      id: 'ar-ibn-kathir',
      name: 'تفسير ابن كثير',
      description: 'تفسير ابن كثير للقرآن الكريم',
      language: 'ar',
    ),
  ];

  // الحصول على قائمة مصادر التفسير المتاحة
  List<TafsirSource> getAvailableSources() {
    return _availableSources;
  }

  // الحصول على مصدر التفسير الافتراضي
  Future<String> getDefaultTafsirSource() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_tafsir_source') ?? 'ar-muyassar';
  }

  // تعيين مصدر التفسير الافتراضي
  Future<void> setDefaultTafsirSource(String sourceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_tafsir_source', sourceId);
  }

  // الحصول على تفسير آية محددة
  Future<TafsirModel?> getTafsir(int surahNumber, int ayahNumber, String sourceId) async {
    try {
      // استخدام API للحصول على تفسير الآية
      final url = 'https://api.quran.com/api/v4/quran/tafsirs/$sourceId?verse_key=$surahNumber:$ayahNumber';
      
      debugPrint('Fetching tafsir from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['tafsirs'] != null && data['tafsirs'].isNotEmpty) {
          return TafsirModel(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            text: data['tafsirs'][0]['text'],
            source: sourceId,
          );
        } else {
          // استخدام API بديل إذا لم يتم العثور على تفسير
          return await _getAlternativeTafsir(surahNumber, ayahNumber, sourceId);
        }
      } else {
        // استخدام API بديل إذا فشل الاتصال
        return await _getAlternativeTafsir(surahNumber, ayahNumber, sourceId);
      }
    } catch (e) {
      debugPrint('Error in getTafsir: $e');
      // استخدام API بديل إذا حدث خطأ
      return await _getAlternativeTafsir(surahNumber, ayahNumber, sourceId);
    }
  }
  
  // الحصول على تفسير آية من مصدر بديل
  Future<TafsirModel?> _getAlternativeTafsir(int surahNumber, int ayahNumber, String sourceId) async {
    try {
      // استخدام API بديل للحصول على تفسير الآية
      final alternativeSourceId = _mapSourceToAlternative(sourceId);
      final url = 'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/editions/quran-uthmani,$alternativeSourceId';
      
      debugPrint('Fetching alternative tafsir from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && data['data'].length > 1) {
          return TafsirModel(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            text: data['data'][1]['text'],
            source: sourceId,
          );
        }
      }
      
      // إذا فشلت جميع المحاولات، استخدم تفسيرًا افتراضيًا
      return _getDefaultTafsir(surahNumber, ayahNumber, sourceId);
    } catch (e) {
      debugPrint('Error in _getAlternativeTafsir: $e');
      return _getDefaultTafsir(surahNumber, ayahNumber, sourceId);
    }
  }
  
  // تحويل معرف المصدر إلى معرف بديل متوافق مع API البديل
  String _mapSourceToAlternative(String sourceId) {
    switch (sourceId) {
      case 'ar-muyassar':
        return 'ar.muyassar';
      case 'ar-jalalayn':
        return 'ar.jalalayn';
      case 'ar-baghawy':
        return 'ar.baghawy';
      case 'ar-tabari':
        return 'ar.tabari';
      case 'ar-qurtubi':
        return 'ar.qurtubi';
      case 'ar-ibn-kathir':
        return 'ar.ibnkathir';
      default:
        return 'ar.muyassar';
    }
  }
  
  // الحصول على تفسير افتراضي إذا فشلت جميع المحاولات
  TafsirModel _getDefaultTafsir(int surahNumber, int ayahNumber, String sourceId) {
    String sourceName = '';
    
    for (var source in _availableSources) {
      if (source.id == sourceId) {
        sourceName = source.name;
        break;
      }
    }
    
    return TafsirModel(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: 'لم يتم العثور على تفسير لهذه الآية. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      source: sourceName,
    );
  }
  
  // حفظ تفسير في التخزين المحلي
  Future<void> saveTafsirToCache(TafsirModel tafsir) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'tafsir_${tafsir.surahNumber}_${tafsir.ayahNumber}_${tafsir.source}';
      await prefs.setString(key, json.encode(tafsir.toJson()));
    } catch (e) {
      debugPrint('Error in saveTafsirToCache: $e');
    }
  }
  
  // الحصول على تفسير من التخزين المحلي
  Future<TafsirModel?> getTafsirFromCache(int surahNumber, int ayahNumber, String sourceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'tafsir_${surahNumber}_${ayahNumber}_$sourceId';
      final tafsirJson = prefs.getString(key);
      
      if (tafsirJson != null) {
        return TafsirModel.fromJson(json.decode(tafsirJson));
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in getTafsirFromCache: $e');
      return null;
    }
  }
}
