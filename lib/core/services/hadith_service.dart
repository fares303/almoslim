import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_moslim/core/constants/api_constants.dart';
import 'package:al_moslim/core/models/hadith.dart';
import 'package:al_moslim/core/data/hadith_data.dart';

class HadithService {
  Future<Hadith> getRandomHadith() async {
    try {
      try {
        final response = await http
            .get(
              Uri.parse(ApiConstants.hadithRandomUrl),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Hadith.fromJson(data['data']);
        } else {
          // If API fails, use local data
          return Hadith.fromJson(HadithData.getRandomHadith());
        }
      } catch (e) {
        // If any error occurs, use local data
        return Hadith.fromJson(HadithData.getRandomHadith());
      }
    } catch (e) {
      // Fallback to local data if anything goes wrong
      return Hadith.fromJson(HadithData.getRandomHadith());
    }
  }

  Future<List<Hadith>> getHadithsByBook(
    String book, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      try {
        // Try primary API first
        final response = await http
            .get(
              Uri.parse(
                '${ApiConstants.hadithBaseUrl}/$book?page=$page&limit=$limit',
              ),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> hadithsData = data['data']['hadiths'];
          return hadithsData.map((hadith) => Hadith.fromJson(hadith)).toList();
        } else {
          // Try alternative API
          return await _getHadithsFromAlternativeApi(book, page, limit);
        }
      } catch (e) {
        // Try alternative API if primary fails
        return await _getHadithsFromAlternativeApi(book, page, limit);
      }
    } catch (e) {
      // Fallback to local data if anything goes wrong
      return HadithData.hadiths
          .map((hadith) => Hadith.fromJson(hadith))
          .toList();
    }
  }

  Future<List<Hadith>> _getHadithsFromAlternativeApi(
    String book,
    int page,
    int limit,
  ) async {
    try {
      // Map the book name to a collection in the alternative API
      String collection = 'bukhari'; // Default to Bukhari
      if (ApiConstants.hadithCollections.contains(book.toLowerCase())) {
        collection = book.toLowerCase();
      }

      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.hadithByBookUrl}/$collection/hadiths?page=$page&limit=$limit',
            ),
            headers: {
              'Accept': 'application/json',
              'X-API-Key': 'SqD712P3E82xnwOAEOkGd5JZH8s9wRR24TqNFzjk',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hadithsData = data['data'];

        // Convert to our Hadith model
        return hadithsData.map((hadith) {
          return Hadith(
            id: hadith['hadithNumber'].toString(),
            title: hadith['chapterTitle'] ?? 'Hadith',
            text: hadith['hadithArabic'] ?? '',
            translation: hadith['hadithEnglish'] ?? '',
            source: 'Sahih ${collection.capitalize()}',
            reference:
                'Book ${hadith['bookNumber']}, Hadith ${hadith['hadithNumber']}',
            grade: hadith['grade'] ?? 'Unknown',
          );
        }).toList();
      } else {
        // If alternative API fails, use local data
        return HadithData.hadiths
            .map((hadith) => Hadith.fromJson(hadith))
            .toList();
      }
    } catch (e) {
      // If any error occurs, use local data
      return HadithData.hadiths
          .map((hadith) => Hadith.fromJson(hadith))
          .toList();
    }
  }

  Future<Hadith> getHadithByNumber(String book, int number) async {
    try {
      try {
        final response = await http
            .get(
              Uri.parse('${ApiConstants.hadithBaseUrl}/$book/$number'),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Hadith.fromJson(data['data']);
        } else {
          // If API fails, use local data (first hadith as fallback)
          return Hadith.fromJson(HadithData.hadiths[0]);
        }
      } catch (e) {
        // If any error occurs, use local data
        return Hadith.fromJson(HadithData.hadiths[0]);
      }
    } catch (e) {
      // Fallback to local data if anything goes wrong
      return Hadith.fromJson(HadithData.hadiths[0]);
    }
  }

  // Get daily hadith
  Future<List<Hadith>> getDailyHadiths() async {
    try {
      // Use local data for daily hadiths
      final dailyHadiths = HadithData.getDailyHadiths();
      return dailyHadiths.map((hadith) => Hadith.fromJson(hadith)).toList();
    } catch (e) {
      // Fallback to first hadith if anything goes wrong
      return [Hadith.fromJson(HadithData.hadiths[0])];
    }
  }
}
