import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/services/notification_service.dart';

class AdkarNotificationService {
  static final AdkarNotificationService _instance =
      AdkarNotificationService._internal();
  final NotificationService _notificationService = NotificationService();

  // Timers for scheduling notifications
  Timer? _morningAdkarTimer;
  Timer? _eveningAdkarTimer;
  Timer? _dailyAyahTimer;

  // Default times
  TimeOfDay _morningAdkarTime = const TimeOfDay(hour: 5, minute: 0); // 5:00 AM
  TimeOfDay _eveningAdkarTime = const TimeOfDay(hour: 19, minute: 0); // 7:00 PM
  TimeOfDay _dailyAyahTime = const TimeOfDay(hour: 12, minute: 0); // 12:00 PM

  factory AdkarNotificationService() {
    return _instance;
  }

  AdkarNotificationService._internal();

  Future<void> initialize() async {
    await _loadSavedTimes();
    _scheduleAllNotifications();
  }

  Future<void> _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();

    // Load morning Adkar time
    final morningHour = prefs.getInt('morningAdkarHour') ?? 5;
    final morningMinute = prefs.getInt('morningAdkarMinute') ?? 0;
    _morningAdkarTime = TimeOfDay(hour: morningHour, minute: morningMinute);

    // Load evening Adkar time
    final eveningHour = prefs.getInt('eveningAdkarHour') ?? 19;
    final eveningMinute = prefs.getInt('eveningAdkarMinute') ?? 0;
    _eveningAdkarTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);

    // Load daily Ayah time
    final ayahHour = prefs.getInt('dailyAyahHour') ?? 12;
    final ayahMinute = prefs.getInt('dailyAyahMinute') ?? 0;
    _dailyAyahTime = TimeOfDay(hour: ayahHour, minute: ayahMinute);
  }

  Future<void> setMorningAdkarTime(TimeOfDay time) async {
    _morningAdkarTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('morningAdkarHour', time.hour);
    await prefs.setInt('morningAdkarMinute', time.minute);
    _scheduleMorningAdkar();
  }

  Future<void> setEveningAdkarTime(TimeOfDay time) async {
    _eveningAdkarTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('eveningAdkarHour', time.hour);
    await prefs.setInt('eveningAdkarMinute', time.minute);
    _scheduleEveningAdkar();
  }

  Future<void> setDailyAyahTime(TimeOfDay time) async {
    _dailyAyahTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyAyahHour', time.hour);
    await prefs.setInt('dailyAyahMinute', time.minute);
    _scheduleDailyAyah();
  }

  void _scheduleAllNotifications() {
    _scheduleMorningAdkar();
    _scheduleEveningAdkar();
    _scheduleDailyAyah();
  }

  void _scheduleMorningAdkar() {
    // Cancel existing timer if any
    _morningAdkarTimer?.cancel();

    // Calculate time until next notification
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _morningAdkarTime.hour,
      _morningAdkarTime.minute,
    );

    // If the scheduled time is in the past, add one day
    final timeUntilNotification =
        scheduledTime.isAfter(now)
            ? scheduledTime.difference(now)
            : scheduledTime.add(const Duration(days: 1)).difference(now);

    print(
      'Morning Adkar scheduled for ${timeUntilNotification.inMinutes} minutes from now',
    );

    // Schedule the notification
    _morningAdkarTimer = Timer(timeUntilNotification, () {
      _notificationService.scheduleAdkarNotification(
        'أذكار الصباح',
        'حان وقت أذكار الصباح',
        _morningAdkarTime.hour,
        _morningAdkarTime.minute,
      );

      // Show actual notification immediately when timer fires
      _showMorningAdkarNotification();

      // Schedule for the next day
      _scheduleMorningAdkar();
    });
  }

  void _showMorningAdkarNotification() {
    // This would use the platform's notification system in a real implementation
    print('NOTIFICATION: حان وقت أذكار الصباح');

    // In a real app, this would trigger the actual notification
    // For now, we'll just print to the console for debugging
  }

  void _scheduleEveningAdkar() {
    // Cancel existing timer if any
    _eveningAdkarTimer?.cancel();

    // Calculate time until next notification
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _eveningAdkarTime.hour,
      _eveningAdkarTime.minute,
    );

    // If the scheduled time is in the past, add one day
    final timeUntilNotification =
        scheduledTime.isAfter(now)
            ? scheduledTime.difference(now)
            : scheduledTime.add(const Duration(days: 1)).difference(now);

    print(
      'Evening Adkar scheduled for ${timeUntilNotification.inMinutes} minutes from now',
    );

    // Schedule the notification
    _eveningAdkarTimer = Timer(timeUntilNotification, () {
      _notificationService.scheduleAdkarNotification(
        'أذكار المساء',
        'حان وقت أذكار المساء',
        _eveningAdkarTime.hour,
        _eveningAdkarTime.minute,
      );

      // Show actual notification immediately when timer fires
      _showEveningAdkarNotification();

      // Schedule for the next day
      _scheduleEveningAdkar();
    });
  }

  void _showEveningAdkarNotification() {
    // This would use the platform's notification system in a real implementation
    print('NOTIFICATION: حان وقت أذكار المساء');

    // In a real app, this would trigger the actual notification
    // For now, we'll just print to the console for debugging
  }

  void _scheduleDailyAyah() {
    // Cancel existing timer if any
    _dailyAyahTimer?.cancel();

    // Calculate time until next notification
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dailyAyahTime.hour,
      _dailyAyahTime.minute,
    );

    // If the scheduled time is in the past, add one day
    final timeUntilNotification =
        scheduledTime.isAfter(now)
            ? scheduledTime.difference(now)
            : scheduledTime.add(const Duration(days: 1)).difference(now);

    print(
      'Daily Ayah scheduled for ${timeUntilNotification.inMinutes} minutes from now',
    );

    // Schedule the notification
    _dailyAyahTimer = Timer(timeUntilNotification, () {
      _notificationService.scheduleDailyAyahNotification(
        'آية اليوم',
        _dailyAyahTime.hour,
        _dailyAyahTime.minute,
      );

      // Show actual notification immediately when timer fires
      _showDailyAyahNotification();

      // Schedule for the next day
      _scheduleDailyAyah();
    });
  }

  void _showDailyAyahNotification() {
    // This would use the platform's notification system in a real implementation
    print('NOTIFICATION: آية اليوم');

    // In a real app, this would trigger the actual notification
    // For now, we'll just print to the console for debugging
  }

  void cancelAllNotifications() {
    _morningAdkarTimer?.cancel();
    _eveningAdkarTimer?.cancel();
    _dailyAyahTimer?.cancel();
  }

  TimeOfDay getMorningAdkarTime() => _morningAdkarTime;
  TimeOfDay getEveningAdkarTime() => _eveningAdkarTime;
  TimeOfDay getDailyAyahTime() => _dailyAyahTime;
}
