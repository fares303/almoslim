class ApiConstants {
  // Al-Quran Cloud API
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String quranEdition = 'quran-uthmani'; // Arabic Uthmani text
  static const String quranTranslationEdition =
      'en.sahih'; // English translation
  static const String quranAudioEdition = 'ar.alafasy'; // Default reciter

  // Aladhan API for Prayer Times
  static const String prayerTimesBaseUrl = 'https://api.aladhan.com/v1';
  static const String prayerTimesMethod = '4'; // Umm al-Qura University, Makkah

  // MP3Quran API
  static const String mp3QuranBaseUrl = 'https://www.mp3quran.net/api';
  static const String mp3QuranRadioUrl =
      'https://www.mp3quran.net/api/radio/radio_ar.json';
  static const String mp3QuranRecitersUrl =
      'https://www.mp3quran.net/api/get-reciters.php';

  // Hisnul Muslim API for Adkar
  static const String adkarBaseUrl = 'https://hisnmuslim.com/api/ar';
  static const String adkarCategoriesUrl = '$adkarBaseUrl/categories';
  static const String adkarByCategory = '$adkarBaseUrl/category';

  // Hadith API
  static const String hadithBaseUrl = 'https://api.hadith.gading.dev/books';
  static const String hadithRandomUrl =
      'https://api.hadith.gading.dev/books/random';

  // Alternative Hadith API
  static const String sunnah1BaseUrl = 'https://api.sunnah.com/v1';
  static const String hadithBooksUrl = '$sunnah1BaseUrl/collections';
  static const String hadithByBookUrl = '$sunnah1BaseUrl/collections';

  // Hadith collections
  static const List<String> hadithCollections = [
    'bukhari',
    'muslim',
    'abudawud',
    'tirmidhi',
    'nasai',
    'ibnmajah',
    'malik',
    'riyadussalihin',
    'adab',
    'bulugh',
    'hisn',
    'shamail',
  ];
}
