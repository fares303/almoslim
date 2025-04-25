import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:al_moslim/core/constants/api_constants.dart';
import 'package:al_moslim/core/models/prayer_times.dart';

class PrayerTimesService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition();
  }

  Future<PrayerTimes> getPrayerTimes({double? latitude, double? longitude, DateTime? date}) async {
    try {
      // If location is not provided, get current location
      if (latitude == null || longitude == null) {
        final position = await getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      // If date is not provided, use current date
      final formattedDate = date != null 
          ? '${date.day}-${date.month}-${date.year}'
          : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.prayerTimesBaseUrl}/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=${ApiConstants.prayerTimesMethod}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data['data']);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<PrayerTimes>> getPrayerTimesForMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.prayerTimesBaseUrl}/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=${ApiConstants.prayerTimesMethod}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> daysData = data['data'];
        return daysData.map((day) => PrayerTimes.fromJson(day)).toList();
      } else {
        throw Exception('Failed to load prayer times for month');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getHijriDate() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.prayerTimesBaseUrl}/gToH'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['hijri'];
      } else {
        throw Exception('Failed to load Hijri date');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
