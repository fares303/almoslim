import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/models/daily_dhikr.dart';
import 'package:al_moslim/core/models/adkar_notification_settings.dart';
import 'package:al_moslim/core/services/audio_service.dart';
import 'package:al_moslim/core/services/permission_service.dart';
import 'package:al_moslim/core/services/api_service.dart';
import 'package:al_moslim/core/services/daily_dhikr_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // تم إزالته بناءً على طلب المستخدم

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AudioService _audioService = AudioService();
  final PermissionService _permissionService = PermissionService();
  final ApiService _apiService = ApiService();
  final DailyDhikrService _dhikrService = DailyDhikrService();

  // تم إزالة Flutter Local Notifications Plugin بناءً على طلب المستخدم

  Timer? _prayerCheckTimer;
  DateTime? _nextPrayerTime;
  String? _nextPrayerName;

  // Store active timers for notifications
  final Map<String, Timer> _activeTimers = {};

  // Store user preferences
  SharedPreferences? _prefs;

  // Store adkar notification settings
  AdkarNotificationSettings? _adkarSettings;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// الحصول على النسخة الوحيدة من الخدمة
  static NotificationService get instance => _instance;

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Africa/Cairo'),
    ); // Default to Cairo for Islamic app

    // Initialize shared preferences
    _prefs = await SharedPreferences.getInstance();

    // Always initialize Firebase Messaging for topic-based notifications
    try {
      // Initialize Firebase Messaging
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Subscribe to topics for content types
      await _firebaseMessaging.subscribeToTopic('daily_adkar');
      await _firebaseMessaging.subscribeToTopic('daily_hadith');
      await _firebaseMessaging.subscribeToTopic('daily_ayah');

      debugPrint('Subscribed to notification topics');

      // Handle incoming messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification}');

          // Show overlay notification if app is open
          showSimpleNotification(
            Text(
              message.notification?.title ?? 'New Notification',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
            subtitle: Text(
              message.notification?.body ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
            background: _getNotificationColor(message.data['type']),
            duration: const Duration(seconds: 7),
            slideDismissDirection: DismissDirection.up,
            autoDismiss: true,
            position: NotificationPosition.top,
          );
        }
      });

      // Handle notification clicks when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification clicked: ${message.data}');
        // Handle navigation based on notification type if needed
      });
    } catch (e) {
      // Firebase initialization failed, but that's okay
      debugPrint('Firebase initialization failed: $e');
    }

    // Initialize audio service
    await _audioService.initialize();

    // Request notification permissions
    await requestPermissions();

    // Load adkar notification settings
    await _loadAdkarNotificationSettings();

    // Load saved notifications
    await loadSavedNotifications();
  }

  /// تحميل إعدادات إشعارات الأذكار
  Future<void> _loadAdkarNotificationSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? settingsJson =
        _prefs!.getString('adkar_notification_settings');
    if (settingsJson != null) {
      _adkarSettings = AdkarNotificationSettings.fromJson(
        json.decode(settingsJson) as Map<String, dynamic>,
      );
      debugPrint(
          'Loaded adkar notification settings: ${_adkarSettings?.enabled}');
    } else {
      // إعدادات افتراضية
      _adkarSettings = AdkarNotificationSettings(
        enabled: false,
        morningTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          7,
          0,
        ),
        eveningTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          19,
          0,
        ),
      );
    }

    // تم إزالة جدولة الإشعارات بناءً على طلب المستخدم
  }

  /// تم إزالة دوال جدولة الإشعارات بناءً على طلب المستخدم

  /// تم إزالة دوال الإشعارات بناءً على طلب المستخدم

  // Get notification color based on type
  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'adkar':
        return Colors.blue;
      case 'hadith':
        return Colors.purple;
      case 'ayah':
        return Colors.teal;
      case 'prayer':
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  Future<void> requestPermissions() async {
    await _permissionService.requestNotificationPermission();
  }

  Future<void> schedulePrayerNotification(
    String title,
    String message,
    String? sound,
  ) async {
    // Play adhan sound if specified
    if (sound != null) {
      await _playAdhan();
    }

    // Show overlay notification
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
        message,
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

  Future<void> schedulePrePrayerNotification(
    String title,
    String message,
  ) async {
    // Show overlay notification
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
        message,
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
          id: '${entry.key}_prayer',
          delay: Duration(minutes: delay),
          callback: () {
            _showPrayerNotification(
              prayerName,
              prayerTime,
            );
          },
        );

        // Schedule pre-notification (15 minutes before)
        final preNotificationTime =
            prayerDateTime.subtract(const Duration(minutes: 15));
        if (preNotificationTime.isAfter(now)) {
          final preDelay = preNotificationTime.difference(now).inMinutes;
          _scheduleDelayedNotification(
            id: '${entry.key}_pre',
            delay: Duration(minutes: preDelay),
            callback: () {
              schedulePrePrayerNotification(
                'تذكير بصلاة $prayerName',
                'متبقي 15 دقيقة لصلاة $prayerName',
              );
            },
          );

          debugPrint(
              'Scheduled pre-prayer notification for $prayerName in $preDelay minutes');
        }

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
      await _audioService.playAdhan();
    } catch (e) {
      debugPrint('Error playing adhan: $e');
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

    // Schedule the notification
    await scheduleNotification(
      title: title,
      body: body,
      channelId: 'adkar_channel',
      hour: hour,
      minute: minute,
      payload: 'adkar',
      daily: true,
    );

    debugPrint('Scheduled adkar notification for $title at $hour:$minute');
  }

  /// حفظ إعدادات إشعارات الأذكار
  Future<void> saveAdkarNotificationSettings(
      AdkarNotificationSettings settings) async {
    _prefs ??= await SharedPreferences.getInstance();

    // حفظ الإعدادات
    _adkarSettings = settings;
    await _prefs!.setString(
      'adkar_notification_settings',
      json.encode(settings.toJson()),
    );

    debugPrint('Saved adkar notification settings: ${settings.enabled}');
  }

  /// الحصول على إعدادات إشعارات الأذكار
  AdkarNotificationSettings? getAdkarNotificationSettings() {
    return _adkarSettings;
  }

  /// تفعيل/تعطيل إشعارات الأذكار
  Future<void> toggleAdkarNotifications(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(enabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تعيين وقت إشعارات أذكار الصباح
  Future<void> setMorningAdkarTime(TimeOfDay time) async {
    if (_adkarSettings != null) {
      final morningTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      final newSettings = _adkarSettings!.copyWith(
        morningTime: morningTime,
        morningEnabled: true,
      );

      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تعيين وقت إشعارات أذكار المساء
  Future<void> setEveningAdkarTime(TimeOfDay time) async {
    if (_adkarSettings != null) {
      final eveningTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      final newSettings = _adkarSettings!.copyWith(
        eveningTime: eveningTime,
        eveningEnabled: true,
      );

      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تفعيل/تعطيل إشعارات أذكار الصباح
  Future<void> toggleMorningAdkar(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(morningEnabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تفعيل/تعطيل إشعارات أذكار المساء
  Future<void> toggleEveningAdkar(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(eveningEnabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تفعيل/تعطيل إشعارات الأذكار العشوائية
  Future<void> toggleRandomAdkar(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(randomEnabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تعيين عدد إشعارات الأذكار العشوائية
  Future<void> setRandomAdkarCount(int count) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(randomCount: count);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تفعيل/تعطيل الصوت مع الإشعارات
  Future<void> toggleNotificationSound(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(soundEnabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// تفعيل/تعطيل الاهتزاز مع الإشعارات
  Future<void> toggleNotificationVibration(bool enabled) async {
    if (_adkarSettings != null) {
      final newSettings = _adkarSettings!.copyWith(vibrationEnabled: enabled);
      await saveAdkarNotificationSettings(newSettings);
    }
  }

  /// الحصول على ذكر اليوم
  Future<DailyDhikr> getDailyDhikr() async {
    return _dhikrService.getDailyDhikr();
  }

  Future<void> scheduleDailyAyahNotification(
    String title,
    int hour,
    int minute,
  ) async {
    // Ensure we have notification permissions
    await requestPermissions();

    // Get a random ayah from the API
    final ayah = await _apiService.getRandomAyah();
    final ayahText = ayah['arabic_text'];
    final surahName = ayah['surah_name'];

    // Schedule the notification
    await scheduleNotification(
      title: title,
      body: '$surahName: $ayahText',
      channelId: 'ayah_channel',
      hour: hour,
      minute: minute,
      payload: 'ayah_$surahName',
      daily: true,
    );

    debugPrint('Scheduled ayah notification for $title at $hour:$minute');
  }

  Future<void> saveAyahNotificationSettings(int hour, int minute) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setInt('ayah_notification_hour', hour);
    await _prefs!.setInt('ayah_notification_minute', minute);
    await _prefs!.setBool('ayah_notification_enabled', true);

    debugPrint('Saved ayah notification settings: $hour:$minute');
  }

  Future<Map<String, dynamic>?> getAyahNotificationSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    final bool enabled = _prefs!.getBool('ayah_notification_enabled') ?? false;
    if (!enabled) {
      return null;
    }

    final int hour = _prefs!.getInt('ayah_notification_hour') ?? 8;
    final int minute = _prefs!.getInt('ayah_notification_minute') ?? 0;

    return {
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
    };
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required String channelId,
    required int hour,
    required int minute,
    String? payload,
    bool daily = true,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    // Calculate delay in minutes
    final now = tz.TZDateTime.now(tz.local);
    final delay = scheduledDate.difference(now).inMinutes;

    // Schedule the notification using a timer
    _scheduleDelayedNotification(
      id: '${channelId}_${hour}_$minute',
      delay: Duration(minutes: delay),
      callback: () {
        // Show overlay notification
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
          background: channelId == 'prayer_channel'
              ? Colors.green
              : channelId == 'adkar_channel'
                  ? Colors.blue
                  : Colors.purple,
          duration: const Duration(seconds: 7),
          slideDismissDirection: DismissDirection.up,
          autoDismiss: true,
          position: NotificationPosition.top,
        );
      },
    );

    debugPrint('Scheduled notification for $title at $hour:$minute');
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> loadSavedNotifications() async {
    // Load saved ayah notification settings
    final ayahSettings = await getAyahNotificationSettings();
    if (ayahSettings != null && ayahSettings['enabled']) {
      // Get a random ayah from the API
      final ayah = await _apiService.getRandomAyah();
      final ayahText = ayah['arabic_text'];
      final surahName = ayah['surah_name'];

      await scheduleNotification(
        title: 'آية اليوم',
        body: '$surahName: $ayahText',
        channelId: 'ayah_channel',
        hour: ayahSettings['hour'],
        minute: ayahSettings['minute'],
        payload: 'ayah_$surahName',
        daily: true,
      );

      debugPrint(
          'Loaded saved Ayah notification settings: ${ayahSettings['hour']}:${ayahSettings['minute']}');
    } else {
      debugPrint('No saved Ayah notification settings found');
    }

    // تم إزالة جدولة إشعارات الأذكار بناءً على طلب المستخدم
    debugPrint('Adkar notifications disabled as requested by user');
  }

  void _scheduleDelayedNotification({
    required String id,
    required Duration delay,
    required VoidCallback callback,
  }) {
    // Cancel any existing timer with the same ID
    if (_activeTimers.containsKey(id)) {
      _activeTimers[id]?.cancel();
      _activeTimers.remove(id);
    }

    // Create a new timer
    _activeTimers[id] = Timer(delay, callback);

    debugPrint(
        'Scheduled delayed notification with ID: $id for ${delay.inMinutes} minutes from now');
  }

  Future<void> cancelAllNotifications() async {
    // Cancel all timers
    _prayerCheckTimer?.cancel();

    // Cancel all active notification timers
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();

    debugPrint('Cancelled all notifications');
  }

  Future<void> _showPrayerNotification(
    String prayerName,
    String prayerTime,
  ) async {
    // Play adhan sound
    await _playAdhan();

    final title = 'حان وقت صلاة $prayerName';
    final message = 'حان الآن وقت صلاة $prayerName - $prayerTime';

    // Show overlay notification
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
        message,
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

  Future<void> showAdkarNotification(
    String title,
    String body,
  ) async {
    // Show overlay notification
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

  Future<void> showAyahNotification(
    String title,
    String ayahText,
    String surahName,
  ) async {
    final String fullMessage = '$surahName: $ayahText';

    // Show overlay notification
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

    debugPrint('Prayer notification test sent');
  }

  Future<void> testAdkarNotification() async {
    // Request notification permissions first
    await requestPermissions();

    // Show the notification
    await showAdkarNotification(
      'أذكار الصباح',
      'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور',
    );

    debugPrint('Adkar notification test sent');
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

    debugPrint('Ayah notification test sent');
  }
}
