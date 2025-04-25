import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/services/notification_manager.dart';
import 'package:al_moslim/core/services/api_service.dart';

class HadithNotificationService {
  static final HadithNotificationService _instance =
      HadithNotificationService._internal();
  final NotificationService _notificationService = NotificationService();
  final NotificationManager _notificationManager = NotificationManager();
  final ApiService _apiService = ApiService();

  // Timer for scheduling notifications
  Timer? _dailyHadithTimer;

  // Default time
  TimeOfDay _dailyHadithTime = const TimeOfDay(hour: 9, minute: 0); // 9:00 AM

  factory HadithNotificationService() {
    return _instance;
  }

  HadithNotificationService._internal();

  Future<void> initialize() async {
    await _loadSavedTimes();
    _scheduleHadithNotification();
  }

  Future<void> _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();

    // Load daily Hadith time
    final hadithHour = prefs.getInt('dailyHadithHour') ?? 9;
    final hadithMinute = prefs.getInt('dailyHadithMinute') ?? 0;
    _dailyHadithTime = TimeOfDay(hour: hadithHour, minute: hadithMinute);
  }

  Future<void> setDailyHadithTime(TimeOfDay time) async {
    _dailyHadithTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyHadithHour', time.hour);
    await prefs.setInt('dailyHadithMinute', time.minute);
    _scheduleHadithNotification();
  }

  void _scheduleHadithNotification() {
    // Cancel existing timer if any
    _dailyHadithTimer?.cancel();

    // Calculate time until next notification
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dailyHadithTime.hour,
      _dailyHadithTime.minute,
    );

    // If the scheduled time is in the past, add one day
    final timeUntilNotification =
        scheduledTime.isAfter(now)
            ? scheduledTime.difference(now)
            : scheduledTime.add(const Duration(days: 1)).difference(now);

    debugPrint(
      'Daily Hadith scheduled for ${timeUntilNotification.inMinutes} minutes from now',
    );

    // Schedule the notification
    _dailyHadithTimer = Timer(timeUntilNotification, () {
      _notificationService.scheduleDailyAyahNotification(
        'حديث اليوم',
        _dailyHadithTime.hour,
        _dailyHadithTime.minute,
      );

      // Show actual notification immediately when timer fires
      _showDailyHadithNotification();

      // Schedule for the next day
      _scheduleHadithNotification();
    });
  }

  void _showDailyHadithNotification() async {
    // Get a random hadith from the API
    final hadith = await _apiService.getRandomHadith();
    final hadithText = hadith['text'];
    final hadithBook = hadith['book'];

    // Show a popup notification
    final context = _notificationManager.navigatorKey.currentContext;
    if (context != null) {
      _notificationManager.showNotification(
        title: 'حديث اليوم',
        message: '$hadithBook: $hadithText',
        icon: Icons.format_quote,
        color: Colors.teal,
        duration: const Duration(seconds: 8),
      );
    }
  }

  void cancelNotifications() {
    _dailyHadithTimer?.cancel();
  }

  TimeOfDay getDailyHadithTime() => _dailyHadithTime;
}
