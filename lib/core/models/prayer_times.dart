class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final gregorian = json['date']['gregorian'];
    final hijri = json['date']['hijri'];

    // Clean up time strings to ensure they're in 24-hour format without seconds
    String cleanTimeString(String time) {
      // Remove any (GMT+X) or similar suffixes
      if (time.contains('(')) {
        time = time.substring(0, time.indexOf('(')).trim();
      }

      // Extract hours and minutes only
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return time;
    }

    return PrayerTimes(
      fajr: cleanTimeString(timings['Fajr']),
      sunrise: cleanTimeString(timings['Sunrise']),
      dhuhr: cleanTimeString(timings['Dhuhr']),
      asr: cleanTimeString(timings['Asr']),
      maghrib: cleanTimeString(timings['Maghrib']),
      isha: cleanTimeString(timings['Isha']),
      date:
          '${gregorian['day']}-${gregorian['month']['number']}-${gregorian['year']}',
      hijriDate: '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}',
    );
  }

  Map<String, String> toMap() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  String getNextPrayer(DateTime now) {
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final prayers = toMap();

    // Sort prayers by time
    final sortedPrayers =
        prayers.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    // Filter out Sunrise and find the next prayer
    for (final entry in sortedPrayers) {
      if (entry.key != 'Sunrise' && currentTime.compareTo(entry.value) < 0) {
        return entry.key;
      }
    }

    return 'Fajr'; // Next day's Fajr
  }

  String getTimeForPrayer(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return fajr;
      case 'Sunrise':
        return sunrise;
      case 'Dhuhr':
        return dhuhr;
      case 'Asr':
        return asr;
      case 'Maghrib':
        return maghrib;
      case 'Isha':
        return isha;
      default:
        return '';
    }
  }
}
