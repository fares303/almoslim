import 'package:flutter/material.dart';
import 'package:al_moslim/features/home/home_screen.dart';
import 'package:al_moslim/features/quran/quran_screen.dart';
import 'package:al_moslim/features/prayer_times/prayer_times_screen.dart';
import 'package:al_moslim/features/adkar/adkar_screen.dart';
import 'package:al_moslim/features/adkar/daily_dhikr_screen.dart';
import 'package:al_moslim/features/qibla/qibla_screen.dart';
import 'package:al_moslim/features/calendar/calendar_screen.dart';
import 'package:al_moslim/features/hadith/hadith_screen.dart';
import 'package:al_moslim/features/hadith/daily_hadith_screen.dart';
import 'package:al_moslim/features/settings/settings_screen.dart';
import 'package:al_moslim/screens/fcm_token_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String quran = '/quran';
  static const String quranReader = '/quran/reader';
  static const String quranPlayer = '/quran/player';
  static const String prayerTimes = '/prayer-times';
  static const String adkar = '/adkar';
  static const String adkarCategory = '/adkar/category';
  static const String dailyDhikr = '/daily-dhikr';
  static const String qibla = '/qibla';
  static const String calendar = '/calendar';
  static const String hadith = '/hadith';
  static const String dailyHadith = '/daily-hadith';
  static const String settings = '/settings';
  static const String fcmToken = '/fcm-token';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    quran: (context) => const QuranScreen(),
    prayerTimes: (context) => const PrayerTimesScreen(),
    adkar: (context) => const AdkarScreen(),
    dailyDhikr: (context) => const DailyDhikrScreen(),
    qibla: (context) => const QiblaScreen(),
    calendar: (context) => const CalendarScreen(),
    hadith: (context) => const HadithScreen(),
    dailyHadith: (context) => const DailyHadithScreen(),
    settings: (context) => const SettingsScreen(),
    fcmToken: (context) => const FCMTokenScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case quranReader:
        // Use arguments if needed in the future
        return MaterialPageRoute(
          builder: (context) => const QuranScreen(),
          settings: settings,
        );
      case quranPlayer:
        // Use arguments if needed in the future
        return MaterialPageRoute(
          builder: (context) => const QuranScreen(),
          settings: settings,
        );
      case adkarCategory:
        // Use arguments if needed in the future
        return MaterialPageRoute(
          builder: (context) => const AdkarScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
