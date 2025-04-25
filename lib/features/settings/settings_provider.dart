import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_moslim/core/services/permission_service.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/services/adkar_notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final PermissionService _permissionService = PermissionService();
  final NotificationService _notificationService = NotificationService();
  final AdkarNotificationService _adkarNotificationService =
      AdkarNotificationService();

  ThemeMode _themeMode = ThemeMode.system;
  String _reciterId = '7'; // Default reciter (Mishari Rashid al-`Afasy)
  bool _notificationsEnabled = true;
  bool _adhanNotificationsEnabled = true;
  bool _adkarNotificationsEnabled = true;
  bool _dailyAyahNotificationsEnabled = true;
  String _adhanSound = 'default';
  bool _notificationPermissionGranted = false;

  ThemeMode get themeMode => _themeMode;
  String get reciterId => _reciterId;
  bool get notificationsEnabled =>
      _notificationsEnabled && _notificationPermissionGranted;
  bool get adhanNotificationsEnabled =>
      _adhanNotificationsEnabled && _notificationPermissionGranted;
  bool get adkarNotificationsEnabled =>
      _adkarNotificationsEnabled && _notificationPermissionGranted;
  bool get dailyAyahNotificationsEnabled =>
      _dailyAyahNotificationsEnabled && _notificationPermissionGranted;
  String get adhanSound => _adhanSound;
  bool get notificationPermissionGranted => _notificationPermissionGranted;

  // Getter for isDarkMode to maintain compatibility with TafsirScreen
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final themeModeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    _reciterId = _prefs.getString('reciterId') ?? '7';
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _adhanNotificationsEnabled =
        _prefs.getBool('adhanNotificationsEnabled') ?? true;
    _adkarNotificationsEnabled =
        _prefs.getBool('adkarNotificationsEnabled') ?? true;
    _dailyAyahNotificationsEnabled =
        _prefs.getBool('dailyAyahNotificationsEnabled') ?? true;
    _adhanSound = _prefs.getString('adhanSound') ?? 'default';
    _notificationPermissionGranted =
        _prefs.getBool('notificationPermissionGranted') ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setReciterId(String id) async {
    _reciterId = id;
    await _prefs.setString('reciterId', id);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(
    bool enabled,
    BuildContext context,
  ) async {
    if (enabled && !_notificationPermissionGranted) {
      // Request permission if enabling notifications and permission not granted
      final permissionGranted =
          await _permissionService.requestNotificationPermission(context);
      if (permissionGranted) {
        _notificationPermissionGranted = true;
        await _prefs.setBool('notificationPermissionGranted', true);
      } else {
        // If permission denied, don't enable notifications
        return;
      }
    }

    _notificationsEnabled = enabled;
    await _prefs.setBool('notificationsEnabled', enabled);
    notifyListeners();
  }

  Future<void> setAdhanNotificationsEnabled(bool enabled) async {
    _adhanNotificationsEnabled = enabled;
    await _prefs.setBool('adhanNotificationsEnabled', enabled);
    notifyListeners();
  }

  Future<void> setAdkarNotificationsEnabled(bool enabled) async {
    _adkarNotificationsEnabled = enabled;
    await _prefs.setBool('adkarNotificationsEnabled', enabled);

    // If enabled, schedule adkar notifications
    if (enabled && _notificationPermissionGranted) {
      // Schedule morning adkar
      final morningTime = _adkarNotificationService.getMorningAdkarTime();
      await _notificationService.scheduleAdkarNotification(
        'أذكار الصباح',
        'حان وقت أذكار الصباح',
        morningTime.hour,
        morningTime.minute,
      );

      // Schedule evening adkar
      final eveningTime = _adkarNotificationService.getEveningAdkarTime();
      await _notificationService.scheduleAdkarNotification(
        'أذكار المساء',
        'حان وقت أذكار المساء',
        eveningTime.hour,
        eveningTime.minute,
      );
    }

    notifyListeners();
  }

  Future<void> setDailyAyahNotificationsEnabled(bool enabled) async {
    _dailyAyahNotificationsEnabled = enabled;
    await _prefs.setBool('dailyAyahNotificationsEnabled', enabled);

    // If enabled, schedule daily ayah notifications
    if (enabled && _notificationPermissionGranted) {
      final ayahTime = _adkarNotificationService.getDailyAyahTime();
      await _notificationService.scheduleDailyAyahNotification(
        'آية اليوم',
        ayahTime.hour,
        ayahTime.minute,
      );
    }

    notifyListeners();
  }

  Future<void> setAdhanSound(String sound) async {
    _adhanSound = sound;
    await _prefs.setString('adhanSound', sound);
    notifyListeners();
  }

  // Request notification permission
  Future<bool> requestNotificationPermission(BuildContext context) async {
    final permissionGranted =
        await _permissionService.requestNotificationPermission(context);
    if (permissionGranted) {
      _notificationPermissionGranted = true;
      await _prefs.setBool('notificationPermissionGranted', true);
      notifyListeners();
    }
    return permissionGranted;
  }
}
