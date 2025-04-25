import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/models/hadith.dart';

class HadithFavoritesService {
  static const String _favoritesKey = 'hadith_favorites';
  
  // Singleton instance
  static final HadithFavoritesService _instance = HadithFavoritesService._internal();
  
  factory HadithFavoritesService() {
    return _instance;
  }
  
  HadithFavoritesService._internal();
  
  // Get all favorite hadiths
  Future<List<Hadith>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    return favoritesJson
        .map((json) => Hadith.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // Add a hadith to favorites
  Future<bool> addToFavorites(Hadith hadith) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      // Check if hadith is already in favorites
      if (favorites.any((h) => h.id == hadith.id)) {
        return false;
      }
      
      // Update the hadith to mark as favorite
      final updatedHadith = hadith.copyWith(isFavorite: true);
      
      // Add to favorites
      final updatedFavorites = [...favorites, updatedHadith];
      
      // Save to SharedPreferences
      await prefs.setStringList(
        _favoritesKey,
        updatedFavorites.map((h) => jsonEncode(h.toJson())).toList(),
      );
      
      return true;
    } catch (e) {
      print('Error adding hadith to favorites: $e');
      return false;
    }
  }
  
  // Remove a hadith from favorites
  Future<bool> removeFromFavorites(String hadithId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      // Remove the hadith from favorites
      final updatedFavorites = favorites.where((h) => h.id != hadithId).toList();
      
      // Save to SharedPreferences
      await prefs.setStringList(
        _favoritesKey,
        updatedFavorites.map((h) => jsonEncode(h.toJson())).toList(),
      );
      
      return true;
    } catch (e) {
      print('Error removing hadith from favorites: $e');
      return false;
    }
  }
  
  // Check if a hadith is in favorites
  Future<bool> isFavorite(String hadithId) async {
    final favorites = await getFavorites();
    return favorites.any((h) => h.id == hadithId);
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(Hadith hadith) async {
    final isFav = await isFavorite(hadith.id);
    
    if (isFav) {
      return await removeFromFavorites(hadith.id);
    } else {
      return await addToFavorites(hadith);
    }
  }
}
