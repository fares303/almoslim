import 'package:intl/intl.dart';

class TimeUtils {
  static String formatTime(String time24Hour) {
    try {
      final timeParts = time24Hour.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final dateTime = DateTime(2022, 1, 1, hour, minute);
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      return time24Hour;
    }
  }

  static String formatTimeArabic(String time24Hour) {
    try {
      final timeParts = time24Hour.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final amPm = hour < 12 ? 'ص' : 'م';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '$hour12:${minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return time24Hour;
    }
  }

  static String getTimeRemaining(String targetTime) {
    try {
      final now = DateTime.now();
      final timeParts = targetTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      var targetDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      // If target time is in the past, add a day
      if (targetDateTime.isBefore(now)) {
        targetDateTime = targetDateTime.add(const Duration(days: 1));
      }
      
      final difference = targetDateTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return '$hours ساعة و $minutes دقيقة';
      } else {
        return '$minutes دقيقة';
      }
    } catch (e) {
      return '';
    }
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy', 'ar');
    return formatter.format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 6) {
      return 'طاب ليلك';
    } else if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 18) {
      return 'مساء الخير';
    } else {
      return 'طاب مساؤك';
    }
  }
}
