import 'package:flutter/material.dart';
import 'package:al_moslim/core/widgets/notification_popup.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  
  // Global key to access the navigator state
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  factory NotificationManager() {
    return _instance;
  }
  
  NotificationManager._internal();
  
  // Show a notification popup
  void showNotification({
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color color = Colors.green,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showNotificationPopup(
        context,
        title: title,
        message: message,
        icon: icon,
        color: color,
        onTap: onTap,
        duration: duration,
      );
    }
  }
  
  // Show a prayer notification popup
  void showPrayerNotification({
    required String title,
    required String message,
  }) {
    showNotification(
      title: title,
      message: message,
      icon: Icons.access_time,
      color: Colors.green,
      duration: const Duration(seconds: 6),
    );
  }
  
  // Show an adkar notification popup
  void showAdkarNotification({
    required String title,
    required String message,
  }) {
    showNotification(
      title: title,
      message: message,
      icon: Icons.book,
      color: Colors.teal,
      duration: const Duration(seconds: 5),
    );
  }
  
  // Show an ayah notification popup
  void showAyahNotification({
    required String title,
    required String message,
  }) {
    showNotification(
      title: title,
      message: message,
      icon: Icons.menu_book,
      color: Colors.indigo,
      duration: const Duration(seconds: 8),
    );
  }
}
