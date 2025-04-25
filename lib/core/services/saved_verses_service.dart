import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/models/ayah.dart';
import 'package:al_moslim/core/models/surah.dart';

class SavedVersesService {
  static const String _savedVersesKey = 'saved_verses';
  static const String _bookmarkedAyahsKey = 'bookmarked_ayahs';
  
  // Singleton instance
  static final SavedVersesService _instance = SavedVersesService._internal();
  
  factory SavedVersesService() {
    return _instance;
  }
  
  SavedVersesService._internal();
  
  // Get all saved verses
  Future<List<Map<String, dynamic>>> getSavedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersesJson = prefs.getStringList(_savedVersesKey) ?? [];
    
    return savedVersesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }
  
  // Save a verse
  Future<bool> saveVerse(Ayah ayah, Surah surah) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVerses = await getSavedVerses();
      
      // Check if verse is already saved
      final isAlreadySaved = savedVerses.any((verse) => 
        verse['ayahNumber'] == ayah.number && 
        verse['surahNumber'] == surah.number
      );
      
      if (isAlreadySaved) {
        return false;
      }
      
      // Create verse data
      final verseData = {
        'ayahNumber': ayah.number,
        'surahNumber': surah.number,
        'surahName': surah.name,
        'ayahText': ayah.text,
        'ayahTranslation': ayah.translation,
        'numberInSurah': ayah.numberInSurah,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Add to saved verses
      savedVerses.add(verseData);
      
      // Save to SharedPreferences
      await prefs.setStringList(
        _savedVersesKey,
        savedVerses.map((verse) => jsonEncode(verse)).toList(),
      );
      
      return true;
    } catch (e) {
      print('Error saving verse: $e');
      return false;
    }
  }
  
  // Remove a saved verse
  Future<bool> removeSavedVerse(int ayahNumber, int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVerses = await getSavedVerses();
      
      // Remove the verse
      final updatedVerses = savedVerses.where((verse) => 
        !(verse['ayahNumber'] == ayahNumber && verse['surahNumber'] == surahNumber)
      ).toList();
      
      // Save to SharedPreferences
      await prefs.setStringList(
        _savedVersesKey,
        updatedVerses.map((verse) => jsonEncode(verse)).toList(),
      );
      
      return true;
    } catch (e) {
      print('Error removing saved verse: $e');
      return false;
    }
  }
  
  // Check if a verse is saved
  Future<bool> isVerseSaved(int ayahNumber, int surahNumber) async {
    final savedVerses = await getSavedVerses();
    return savedVerses.any((verse) => 
      verse['ayahNumber'] == ayahNumber && 
      verse['surahNumber'] == surahNumber
    );
  }
  
  // Get bookmarked ayahs
  Future<Set<int>> getBookmarkedAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarkedAyahsKey) ?? [];
    
    return bookmarks
        .map((bookmark) => int.tryParse(bookmark) ?? 0)
        .where((id) => id > 0)
        .toSet();
  }
  
  // Toggle bookmark for an ayah
  Future<bool> toggleBookmark(int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarkedAyahsKey) ?? [];
    final bookmarkedAyahs = await getBookmarkedAyahs();
    
    bool isNowBookmarked = false;
    
    if (bookmarkedAyahs.contains(ayahNumber)) {
      bookmarkedAyahs.remove(ayahNumber);
      bookmarks.remove(ayahNumber.toString());
      isNowBookmarked = false;
    } else {
      bookmarkedAyahs.add(ayahNumber);
      bookmarks.add(ayahNumber.toString());
      isNowBookmarked = true;
    }
    
    await prefs.setStringList(_bookmarkedAyahsKey, bookmarks);
    return isNowBookmarked;
  }
}
