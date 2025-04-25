import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/services/audio_service.dart';
import 'package:al_moslim/core/services/permission_service.dart';
import 'package:al_moslim/core/services/api_service.dart';
import 'package:al_moslim/core/widgets/notification_widget.dart';

class NotificationServiceSimple {
  static final NotificationServiceSimple _instance = NotificationServiceSimple._internal();
  final AudioService _audioService = AudioService();
  final PermissionService _permissionService = PermissionService();
  final ApiService _apiService = ApiService();
  final NotificationManager _notificationManager = NotificationManager();

  Timer? _prayerCheckTimer;
  DateTime? _nextPrayerTime;
  String? _nextPrayerName;
  bool _isAdhanPlaying = false;

  factory NotificationServiceSimple() {
    return _instance;
  }

  NotificationServiceSimple._internal();

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Africa/Cairo'),
    ); // Default to Cairo for Islamic app

    // Initialize audio service
    await _audioService.initialize();

    // Request notification permissions
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _permissionService.requestNotificationPermission();
  }

  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    // Ensure we have notification permissions
    await requestPermissions();

    // Show toast notification for prayer times
    final prayers = prayerTimes.toMap();
    final now = DateTime.now();

    // Find the next prayer time
    String nextPrayer = prayerTimes.getNextPrayer(now);
    String nextPrayerTime = prayerTimes.getTimeForPrayer(nextPrayer);

    // Parse the next prayer time
    final timeParts = nextPrayerTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Create DateTime for the next prayer
    DateTime prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the prayer time has already passed today, schedule for tomorrow
    if (prayerDateTime.isBefore(now)) {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }

    // Store the next prayer time and name
    _nextPrayerTime = prayerDateTime;
    _nextPrayerName = nextPrayer;

    // Start a timer to check for prayer times
    _startPrayerCheckTimer();

    // Schedule notifications for all prayers
    for (final entry in prayers.entries) {
      if (entry.key != 'Sunrise') {
        final prayerName = getPrayerNameInArabic(entry.key);
        final prayerTime = entry.value;

        // Parse the prayer time
        final timeParts = prayerTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Create DateTime for the prayer
        DateTime prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If the prayer time has already passed today, schedule for tomorrow
        if (prayerDateTime.isBefore(now)) {
          prayerDateTime = prayerDateTime.add(const Duration(days: 1));
        }

        // Calculate the delay in minutes
        final delay = prayerDateTime.difference(now).inMinutes;

        // Schedule the notification
        _scheduleDelayedNotification(
          delay: Duration(minutes: delay),
          callback: () {
            _showPrayerNotification(
              prayerName,
              prayerTime,
            );
          },
        );

        debugPrint(
            'Scheduled prayer notification for $prayerName in $delay minutes');
      }
    }
  }

  void _startPrayerCheckTimer() {
    // Cancel any existing timer
    _prayerCheckTimer?.cancel();

    // Start a new timer that checks every minute
    _prayerCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPrayerTime();
    });
  }

  void _checkPrayerTime() {
    if (_nextPrayerTime == null || _nextPrayerName == null) return;

    final now = DateTime.now();
    final difference = _nextPrayerTime!.difference(now).inMinutes;

    // If it's prayer time (within 1 minute)
    if (difference <= 0 && difference > -2) {
      _playAdhan();

      // Show notification
      final prayerName = getPrayerNameInArabic(_nextPrayerName!);

      // Show the notification
      _showPrayerNotification(
        prayerName,
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _playAdhan() async {
    try {
      _isAdhanPlaying = true;
      await _audioService.playAdhan();
    } catch (e) {
      debugPrint('Error playing adhan: $e');
    }
  }

  Future<void> _stopAdhan() async {
    try {
      if (_isAdhanPlaying) {
        await _audioService.stopAdhan();
        _isAdhanPlaying = false;
      }
    } catch (e) {
      debugPrint('Error stopping adhan: $e');
    }
  }

  Future<void> scheduleAdkarNotification(
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    // Ensure we have notification permissions
    await requestPermissions();

    // Create DateTime for the adkar
    final now = DateTime.now();
    DateTime adkarDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (adkarDateTime.isBefore(now)) {
      adkarDateTime = adkarDateTime.add(const Duration(days: 1));
    }

    // Calculate the delay in minutes
    final delay = adkarDateTime.difference(now).inMinutes;

    // Schedule the notification
    _scheduleDelayedNotification(
      delay: Duration(minutes: delay),
      callback: () {
        showAdkarNotification(
          title,
          body,
        );
      },
    );

    debugPrint('Scheduled adkar notification for $title in $delay minutes');
  }

  Future<void> scheduleDailyAyahNotification(
    String title,
    int hour,
    int minute,
  ) async {
    // Ensure we have notification permissions
    await requestPermissions();

    // Create DateTime for the ayah
    final now = DateTime.now();
    DateTime ayahDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (ayahDateTime.isBefore(now)) {
      ayahDateTime = ayahDateTime.add(const Duration(days: 1));
    }

    // Calculate the delay in minutes
    final delay = ayahDateTime.difference(now).inMinutes;

    // Schedule the notification
    _scheduleDelayedNotification(
      delay: Duration(minutes: delay),
      callback: () async {
        // Get a random ayah from the API
        final ayah = await _apiService.getRandomAyah();
        final ayahText = ayah['arabic_text'];
        final surahName = ayah['surah_name'];

        showAyahNotification(
          title,
          ayahText,
          surahName,
        );
      },
    );

    debugPrint('Scheduled ayah notification for $title in $delay minutes');
  }

  void _scheduleDelayedNotification({
    required Duration delay,
    required VoidCallback callback,
  }) {
    Timer(delay, callback);
  }

  Future<void> cancelAllNotifications() async {
    // Cancel all timers
    _prayerCheckTimer?.cancel();

    debugPrint('Cancelled all notifications');
  }

  Future<void> _showPrayerNotification(
    String prayerName,
    String prayerTime,
  ) async {
    // Play adhan sound
    await _playAdhan();
    
    // Show in-app notification
    _notificationManager.showPrayerNotification(
      title: 'حان وقت صلاة $prayerName',
      message: 'حان الآن وقت صلاة $prayerName - $prayerTime',
      onTap: _stopAdhan,
    );
    
    // Also show overlay notification if app is open
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      showSimpleNotification(
        Text(
          'حان وقت صلاة $prayerName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          'حان الآن وقت صلاة $prayerName - $prayerTime',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.right,
        ),
        background: Colors.green,
        duration: const Duration(seconds: 10),
        slideDismissDirection: DismissDirection.up,
        autoDismiss: true,
        position: NotificationPosition.top,
      );
    }
  }

  Future<void> showAdkarNotification(
    String title,
    String body,
  ) async {
    // Show in-app notification
    _notificationManager.showAdkarNotification(
      title: title,
      message: body,
    );
    
    // Also show overlay notification if app is open
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      showSimpleNotification(
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          body,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.right,
        ),
        background: Colors.blue,
        duration: const Duration(seconds: 7),
        slideDismissDirection: DismissDirection.up,
        autoDismiss: true,
        position: NotificationPosition.top,
      );
    }
  }

  Future<void> showAyahNotification(
    String title,
    String ayahText,
    String surahName,
  ) async {
    final String fullMessage = '$surahName: $ayahText';

    // Show in-app notification
    _notificationManager.showAyahNotification(
      title: title,
      message: fullMessage,
    );
    
    // Also show overlay notification if app is open
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      showSimpleNotification(
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          fullMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.right,
        ),
        background: Colors.purple,
        duration: const Duration(seconds: 7),
        slideDismissDirection: DismissDirection.up,
        autoDismiss: true,
        position: NotificationPosition.top,
      );
    }
  }
  
  // Helper method to get Arabic prayer name
  String getPrayerNameInArabic(String englishName) {
    switch (englishName) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return englishName;
    }
  }
  
  // Test methods for notifications
  Future<void> testPrayerNotification() async {
    // Request notification permissions first
    await requestPermissions();
    
    // Play adhan sound
    await _playAdhan();
    
    // Show the notification
    await _showPrayerNotification(
      'الظهر',
      '12:00',
    );
  }
  
  Future<void> testAdkarNotification() async {
    // Request notification permissions first
    await requestPermissions();
    
    // Show the notification
    await showAdkarNotification(
      'أذكار الصباح',
      'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور',
    );
  }
  
  Future<void> testAyahNotification() async {
    // Request notification permissions first
    await requestPermissions();
    
    // Show the notification
    await showAyahNotification(
      'آية اليوم',
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      'سورة الفاتحة',
    );
  }
}
