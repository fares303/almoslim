import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/services/audio_service.dart';
import 'package:al_moslim/core/services/permission_service.dart';
import 'package:al_moslim/core/services/api_service.dart';
import 'package:al_moslim/core/widgets/notification_widget.dart';
import 'package:al_moslim/core/services/foreground_service.dart';

class CustomNotificationService {
  static final CustomNotificationService _instance = CustomNotificationService._internal();
  final AudioService _audioService = AudioService();
  final PermissionService _permissionService = PermissionService();
  final ApiService _apiService = ApiService();
  final NotificationManager _notificationManager = NotificationManager();
  final ForegroundService _foregroundService = ForegroundService();
  
  // Method channel for native notifications
  final MethodChannel _channel = const MethodChannel('com.almoslim/notifications');

  Timer? _prayerCheckTimer;
  DateTime? _nextPrayerTime;
  String? _nextPrayerName;
  bool _isAdhanPlaying = false;

  // Notification IDs
  static const int prayerNotificationId = 1;
  static const int adkarNotificationId = 2;
  static const int ayahNotificationId = 3;

  factory CustomNotificationService() {
    return _instance;
  }

  CustomNotificationService._internal();

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Africa/Cairo'),
    ); // Default to Cairo for Islamic app

    // Initialize audio service
    await _audioService.initialize();
    
    // Initialize foreground service
    await _foregroundService.initialize();
    
    // Set up method call handler for stopping adhan
    _channel.setMethodCallHandler(_handleMethodCall);

    // Request notification permissions
    await requestPermissions();
  }
  
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'stopAdhan':
        await _stopAdhan();
        break;
      default:
        debugPrint('Unknown method ${call.method}');
    }
  }

  Future<void> requestPermissions() async {
    await _permissionService.requestNotificationPermission();
    
    // Request overlay permission for pop-out notifications
    final hasOverlayPermission = await _foregroundService.hasOverlayPermission();
    if (!hasOverlayPermission) {
      await _foregroundService.requestOverlayPermission();
    }
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
    
    // Cancel all system notifications
    await _channel.invokeMethod('cancelAllNotifications');
    
    // Dismiss all pop-out notifications
    await _foregroundService.dismissAllNotifications();

    debugPrint('Cancelled all notifications');
  }

  Future<void> _showPrayerNotification(
    String prayerName,
    String prayerTime,
  ) async {
    // Play adhan sound
    await _playAdhan();
    
    // Show system notification
    await _channel.invokeMethod('showPrayerNotification', {
      'title': 'حان وقت صلاة $prayerName',
      'message': 'حان الآن وقت صلاة $prayerName - $prayerTime',
    });
    
    // Show pop-out notification outside the app
    await _foregroundService.showPrayerNotification(
      title: 'حان وقت صلاة $prayerName',
      message: 'حان الآن وقت صلاة $prayerName - $prayerTime',
      onTap: _stopAdhan,
      onDismiss: () {},
    );
    
    // Also show in-app notification if app is open
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

      // Also show in-app notification
      _notificationManager.showPrayerNotification(
        title: 'حان وقت صلاة $prayerName',
        message: 'حان الآن وقت صلاة $prayerName - $prayerTime',
        onTap: _stopAdhan,
      );
    }
  }

  Future<void> showAdkarNotification(
    String title,
    String body,
  ) async {
    // Show system notification
    await _channel.invokeMethod('showAdkarNotification', {
      'title': title,
      'message': body,
    });
    
    // Show pop-out notification outside the app
    await _foregroundService.showAdkarNotification(
      title: title,
      message: body,
      onDismiss: () {},
    );
    
    // Also show in-app notification if app is open
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

      // Also show in-app notification
      _notificationManager.showAdkarNotification(
        title: title,
        message: body,
      );
    }
  }

  Future<void> showAyahNotification(
    String title,
    String ayahText,
    String surahName,
  ) async {
    final String fullMessage = '$surahName: $ayahText';

    // Show system notification
    await _channel.invokeMethod('showAyahNotification', {
      'title': title,
      'message': fullMessage,
    });
    
    // Show pop-out notification outside the app
    await _foregroundService.showAyahNotification(
      title: title,
      message: fullMessage,
      onDismiss: () {},
    );
    
    // Also show in-app notification if app is open
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

      // Also show in-app notification
      _notificationManager.showAyahNotification(
        title: title,
        message: fullMessage,
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
