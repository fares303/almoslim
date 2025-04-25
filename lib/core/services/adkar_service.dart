import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/constants/api_constants.dart';
import 'package:al_moslim/core/models/adkar.dart';
import 'package:al_moslim/core/data/adkar_data.dart';

class AdkarService {
  Future<List<AdkarCategory>> getCategories() async {
    try {
      try {
        final response = await http
            .get(
              Uri.parse(ApiConstants.adkarCategoriesUrl),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> categoriesData = data['data'];
          return categoriesData
              .map((category) => AdkarCategory.fromJson(category))
              .toList();
        } else {
          // If API fails, use local data
          return _getLocalCategories();
        }
      } catch (e) {
        // If any error occurs, use local data
        return _getLocalCategories();
      }
    } catch (e) {
      // Fallback to local data if anything goes wrong
      return _getLocalCategories();
    }
  }

  List<AdkarCategory> _getLocalCategories() {
    return AdkarData.categories
        .map((category) => AdkarCategory.fromJson(category))
        .toList();
  }

  Future<List<Dhikr>> getAdkarByCategory(int categoryId) async {
    try {
      try {
        final response = await http
            .get(
              Uri.parse('${ApiConstants.adkarByCategory}/$categoryId'),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> adkarData = data['data'];

          // Get favorite and completed adkar from shared preferences
          final prefs = await SharedPreferences.getInstance();
          final favoriteAdkar = prefs.getStringList('favorite_adkar') ?? [];
          final completedAdkar = prefs.getStringList('completed_adkar') ?? [];

          return adkarData.map((dhikr) {
            final dhikrObj = Dhikr.fromJson(dhikr, categoryId);
            dhikrObj.isFavorite = favoriteAdkar.contains('${dhikrObj.id}');
            dhikrObj.isCompleted = completedAdkar.contains('${dhikrObj.id}');
            return dhikrObj;
          }).toList();
        } else {
          // If API fails, use local data
          return _getLocalAdkarByCategory(categoryId);
        }
      } catch (e) {
        // If any error occurs, use local data
        return _getLocalAdkarByCategory(categoryId);
      }
    } catch (e) {
      // Fallback to local data if anything goes wrong
      return _getLocalAdkarByCategory(categoryId);
    }
  }

  Future<List<Dhikr>> _getLocalAdkarByCategory(int categoryId) async {
    // Get favorite and completed adkar from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final favoriteAdkar = prefs.getStringList('favorite_adkar') ?? [];
    final completedAdkar = prefs.getStringList('completed_adkar') ?? [];

    if (AdkarData.adkarByCategory.containsKey(categoryId)) {
      final adkarData = AdkarData.adkarByCategory[categoryId] ?? [];
      return adkarData.map((dhikr) {
        final dhikrObj = Dhikr.fromJson(dhikr, categoryId);
        dhikrObj.isFavorite = favoriteAdkar.contains('${dhikrObj.id}');
        dhikrObj.isCompleted = completedAdkar.contains('${dhikrObj.id}');
        return dhikrObj;
      }).toList();
    } else {
      return [];
    }
  }

  Future<void> toggleFavorite(Dhikr dhikr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteAdkar = prefs.getStringList('favorite_adkar') ?? [];

      if (dhikr.isFavorite) {
        favoriteAdkar.remove('${dhikr.id}');
      } else {
        favoriteAdkar.add('${dhikr.id}');
      }

      await prefs.setStringList('favorite_adkar', favoriteAdkar);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleCompleted(Dhikr dhikr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedAdkar = prefs.getStringList('completed_adkar') ?? [];

      if (dhikr.isCompleted) {
        completedAdkar.remove('${dhikr.id}');
      } else {
        completedAdkar.add('${dhikr.id}');
      }

      await prefs.setStringList('completed_adkar', completedAdkar);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Dhikr>> getFavoriteAdkar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteAdkar = prefs.getStringList('favorite_adkar') ?? [];

      if (favoriteAdkar.isEmpty) {
        return [];
      }

      // Get all categories
      final categories = await getCategories();
      final List<Dhikr> allFavorites = [];

      // For each category, get adkar and filter favorites
      for (final category in categories) {
        final adkar = await getAdkarByCategory(category.id);
        final favorites = adkar.where((dhikr) => dhikr.isFavorite).toList();
        allFavorites.addAll(favorites);
      }

      return allFavorites;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
