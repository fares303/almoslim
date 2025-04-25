import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color accent = Color(0xFFFF9800);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
}

// App Text Styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
}

// App Strings
class AppStrings {
  // App Name
  static const String appName = 'AlMoslim';
  
  // Prayer Names
  static const String fajr = 'الفجر';
  static const String sunrise = 'الشروق';
  static const String dhuhr = 'الظهر';
  static const String asr = 'العصر';
  static const String maghrib = 'المغرب';
  static const String isha = 'العشاء';
  
  // Notification Titles
  static const String prayerTimeTitle = 'حان وقت الصلاة';
  static const String adkarMorningTitle = 'أذكار الصباح';
  static const String adkarEveningTitle = 'أذكار المساء';
  static const String dailyAyahTitle = 'آية اليوم';
  static const String dailyHadithTitle = 'حديث اليوم';
  
  // Notification Messages
  static const String prayerTimeMessage = 'حان وقت صلاة %s';
  static const String prePrayerTimeMessage = 'سيحين وقت صلاة %s بعد %d دقيقة';
  
  // Settings
  static const String settings = 'الإعدادات';
  static const String darkMode = 'الوضع الداكن';
  static const String notifications = 'الإشعارات';
  static const String language = 'اللغة';
  static const String about = 'عن التطبيق';
  
  // Quran
  static const String quran = 'القرآن الكريم';
  static const String surah = 'سورة';
  static const String juz = 'جزء';
  static const String page = 'صفحة';
  static const String bookmark = 'المرجعيات';
  
  // Prayer Times
  static const String prayerTimes = 'مواقيت الصلاة';
  static const String qibla = 'القبلة';
  
  // Adkar
  static const String adkar = 'الأذكار';
  static const String morning = 'الصباح';
  static const String evening = 'المساء';
  static const String sleep = 'النوم';
  static const String wake = 'الاستيقاظ';
  static const String prayer = 'الصلاة';
  
  // Hadith
  static const String hadith = 'الحديث الشريف';
  static const String dailyHadith = 'حديث اليوم';
  static const String favorites = 'المفضلة';
  
  // Calendar
  static const String calendar = 'التقويم الهجري';
  static const String today = 'اليوم';
  static const String events = 'المناسبات';
  
  // General
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String ok = 'موافق';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String noData = 'لا توجد بيانات';
  static const String search = 'بحث';
}

// App Assets
class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String quranBackground = 'assets/images/quran_background.png';
  
  // Icons
  static const String quranIcon = 'assets/icons/quran.svg';
  static const String prayerIcon = 'assets/icons/prayer.svg';
  static const String qiblaIcon = 'assets/icons/qibla.svg';
  static const String adkarIcon = 'assets/icons/adkar.svg';
  static const String hadithIcon = 'assets/icons/hadith.svg';
  static const String calendarIcon = 'assets/icons/calendar.svg';
  static const String settingsIcon = 'assets/icons/settings.svg';
  
  // Animations
  static const String prayerAnimation = 'assets/animations/prayer.json';
  static const String adkarAnimation = 'assets/animations/adkar.json';
  static const String quranAnimation = 'assets/animations/quran.json';
  
  // Audio
  static const String adhanAudio = 'assets/audio/adhan.mp3';
}

// App Routes
class AppRoutes {
  static const String home = '/';
  static const String quran = '/quran';
  static const String quranReader = '/quran/reader';
  static const String prayerTimes = '/prayer-times';
  static const String qibla = '/qibla';
  static const String adkar = '/adkar';
  static const String adkarDetails = '/adkar/details';
  static const String hadith = '/hadith';
  static const String hadithDetails = '/hadith/details';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String about = '/about';
}

// Shared Preferences Keys
class PrefsKeys {
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String lastQuranPosition = 'last_quran_position';
  static const String bookmarks = 'bookmarks';
  static const String favorites = 'favorites';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String prayerNotificationsEnabled = 'prayer_notifications_enabled';
  static const String adkarNotificationsEnabled = 'adkar_notifications_enabled';
  static const String ayahNotificationsEnabled = 'ayah_notifications_enabled';
  static const String adhanSound = 'adhan_sound';
  static const String prePrayerNotificationTime = 'pre_prayer_notification_time';
  static const String morningAdkarTime = 'morning_adkar_time';
  static const String eveningAdkarTime = 'evening_adkar_time';
  static const String dailyAyahTime = 'daily_ayah_time';
}
