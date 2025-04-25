import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/services/prayer_times_service.dart';

class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();
  final NotificationService _notificationService = NotificationService();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  // Timers for scheduling notifications
  final Map<String, Timer?> _prayerTimers = {
    'fajr': null,
    'sunrise': null,
    'dhuhr': null,
    'asr': null,
    'maghrib': null,
    'isha': null,
  };

  // Notification settings
  bool _notificationsEnabled = true;
  String _adhanSound = 'default'; // default, makkah, madinah, etc.
  bool _vibrateOnly = false;

  // Pre-notification time (minutes before prayer)
  int _preNotificationTime = 15;

  factory PrayerNotificationService() {
    return _instance;
  }

  PrayerNotificationService._internal();

  Future<void> initialize() async {
    await _loadSettings();
    if (_notificationsEnabled) {
      await _scheduleAllPrayerNotifications();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _notificationsEnabled = prefs.getBool('prayerNotificationsEnabled') ?? true;
    _adhanSound = prefs.getString('adhanSound') ?? 'default';
    _vibrateOnly = prefs.getBool('vibrateOnly') ?? false;
    _preNotificationTime = prefs.getInt('preNotificationTime') ?? 15;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayerNotificationsEnabled', enabled);

    if (enabled) {
      await _scheduleAllPrayerNotifications();
    } else {
      _cancelAllPrayerNotifications();
    }
  }

  Future<void> setAdhanSound(String sound) async {
    _adhanSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adhanSound', sound);

    // Reschedule notifications with new sound
    if (_notificationsEnabled) {
      await _scheduleAllPrayerNotifications();
    }
  }

  Future<void> setVibrateOnly(bool vibrateOnly) async {
    _vibrateOnly = vibrateOnly;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrateOnly', vibrateOnly);
  }

  Future<void> setPreNotificationTime(int minutes) async {
    _preNotificationTime = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preNotificationTime', minutes);

    // Reschedule notifications with new pre-notification time
    if (_notificationsEnabled) {
      await _scheduleAllPrayerNotifications();
    }
  }

  Future<void> _scheduleAllPrayerNotifications() async {
    // Cancel any existing timers
    _cancelAllPrayerNotifications();

    // Get today's prayer times
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes();

      // Schedule notifications for each prayer
      _schedulePrayerNotification('fajr', prayerTimes.fajr, 'الفجر');
      _schedulePrayerNotification('sunrise', prayerTimes.sunrise, 'الشروق');
      _schedulePrayerNotification('dhuhr', prayerTimes.dhuhr, 'الظهر');
      _schedulePrayerNotification('asr', prayerTimes.asr, 'العصر');
      _schedulePrayerNotification('maghrib', prayerTimes.maghrib, 'المغرب');
      _schedulePrayerNotification('isha', prayerTimes.isha, 'العشاء');
    } catch (e) {
      // Handle error silently
      return;
    }
  }

  void _schedulePrayerNotification(
    String prayer,
    String prayerTimeStr,
    String arabicName,
  ) {
    // Convert string time to TimeOfDay
    final timeParts = prayerTimeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final prayerTime = TimeOfDay(hour: hour, minute: minute);
    // Cancel existing timer if any
    _prayerTimers[prayer]?.cancel();

    // Calculate time until notification
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      prayerTime.hour,
      prayerTime.minute,
    );

    // If the scheduled time is in the past, add one day
    final timeUntilPrayer =
        scheduledTime.isAfter(now)
            ? scheduledTime.difference(now)
            : scheduledTime.add(const Duration(days: 1)).difference(now);

    // Calculate pre-notification time (if enabled)
    final timeUntilPreNotification =
        timeUntilPrayer - Duration(minutes: _preNotificationTime);
    final shouldSendPreNotification =
        timeUntilPreNotification.isNegative == false;

    // Debug logging removed for production

    // Schedule the notification
    _prayerTimers[prayer] = Timer(timeUntilPrayer, () {
      _showPrayerNotification(prayer, arabicName);

      // Schedule for the next day
      _schedulePrayerNotification(
        prayer,
        '${prayerTime.hour}:${prayerTime.minute}',
        arabicName,
      );
    });

    // Schedule pre-notification if needed
    if (shouldSendPreNotification) {
      Timer(timeUntilPreNotification, () {
        _showPrayerPreNotification(prayer, arabicName, _preNotificationTime);
      });
    }
  }

  void _showPrayerNotification(String prayer, String arabicName) {
    // Skip Adhan for sunrise as it's not a prayer time
    final bool playAdhan = prayer != 'sunrise' && !_vibrateOnly;

    // This would use the platform's notification system in a real implementation

    // Schedule the actual notification
    _notificationService.schedulePrayerNotification(
      'حان وقت صلاة $arabicName',
      'حان الآن وقت صلاة $arabicName',
      playAdhan ? _adhanSound : null,
    );
  }

  void _showPrayerPreNotification(
    String prayer,
    String arabicName,
    int minutes,
  ) {
    // Skip pre-notification for sunrise
    if (prayer == 'sunrise') return;

    // This would use the platform's notification system in a real implementation

    // Schedule the actual notification
    _notificationService.schedulePrePrayerNotification(
      'تذكير بصلاة $arabicName',
      'متبقي $minutes دقيقة لصلاة $arabicName',
    );
  }

  void _cancelAllPrayerNotifications() {
    for (final timer in _prayerTimers.values) {
      timer?.cancel();
    }
  }

  // Getters for settings
  bool get notificationsEnabled => _notificationsEnabled;
  String get adhanSound => _adhanSound;
  bool get vibrateOnly => _vibrateOnly;
  int get preNotificationTime => _preNotificationTime;
}
