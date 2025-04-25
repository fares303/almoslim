import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'AlMoslim';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String prefLastReadSurah = 'last_read_surah';
  static const String prefLastReadAyah = 'last_read_ayah';
  static const String prefBookmarkedAyahs = 'bookmarked_ayahs';
  static const String prefFavoriteAdkar = 'favorite_adkar';
  static const String prefCompletedAdkar = 'completed_adkar';
  static const String prefLastLocation = 'last_location';

  // Navigation Bar Items
  static const List<NavigationDestination> navigationDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'القرآن',
    ),
    NavigationDestination(
      icon: Icon(Icons.access_time_outlined),
      selectedIcon: Icon(Icons.access_time),
      label: 'الصلاة',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: 'الأذكار',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'الإعدادات',
    ),
  ];

  // Prayer Names in Arabic
  static const Map<String, String> prayerNames = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  // Prayer Icons
  static const Map<String, IconData> prayerIcons = {
    'Fajr': Icons.wb_twilight,
    'Sunrise': Icons.wb_sunny_outlined,
    'Dhuhr': Icons.wb_sunny,
    'Asr': Icons.sunny_snowing,
    'Maghrib': Icons.nightlight_round,
    'Isha': Icons.nights_stay,
  };

  // Adkar Categories
  static const Map<String, String> adkarCategories = {
    'morning': 'أذكار الصباح',
    'evening': 'أذكار المساء',
    'after_prayer': 'أذكار بعد الصلاة',
    'before_sleep': 'أذكار النوم',
    'waking_up': 'أذكار الاستيقاظ',
    'entering_mosque': 'أذكار دخول المسجد',
    'leaving_mosque': 'أذكار الخروج من المسجد',
    'travel': 'أذكار السفر',
  };

  // Reciters
  static const Map<String, String> reciters = {
    '7': 'مشاري راشد العفاسي',
    '3': 'عبد الباسط عبد الصمد',
    '128': 'سعد الغامدي',
    '6': 'محمود خليل الحصري',
    '9': 'أحمد العجمي',
    '10': 'محمد صديق المنشاوي',
    '11': 'ماهر المعيقلي',
    '12': 'عبد الرحمن السديس',
    '13': 'بندر بليلة',
    '14': 'إدريس أبكر',
    '15': 'هاني الرفاعي',
    '16': 'علي الحذيفي',
    '17': 'فارس عباد',
  };
}
