import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A service that can show pop-out notifications outside the app
/// using Android's SYSTEM_ALERT_WINDOW permission
class ForegroundService {
  static const MethodChannel _channel = MethodChannel('com.almoslim/foreground_service');
  static final ForegroundService _instance = ForegroundService._internal();

  factory ForegroundService() {
    return _instance;
  }

  ForegroundService._internal();

  /// Initialize the foreground service
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      debugPrint('Error initializing foreground service: ${e.message}');
    }
  }

  /// Request permission to draw over other apps
  Future<bool> requestOverlayPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('requestOverlayPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint('Error requesting overlay permission: ${e.message}');
      return false;
    }
  }

  /// Check if the app has permission to draw over other apps
  Future<bool> hasOverlayPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('hasOverlayPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint('Error checking overlay permission: ${e.message}');
      return false;
    }
  }

  /// Show a prayer notification outside the app
  Future<void> showPrayerNotification({
    required String title,
    required String message,
    required VoidCallback onTap,
    required VoidCallback onDismiss,
  }) async {
    try {
      await _channel.invokeMethod('showPrayerNotification', {
        'title': title,
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint('Error showing prayer notification: ${e.message}');
    }
  }

  /// Show an adkar notification outside the app
  Future<void> showAdkarNotification({
    required String title,
    required String message,
    required VoidCallback onDismiss,
  }) async {
    try {
      await _channel.invokeMethod('showAdkarNotification', {
        'title': title,
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint('Error showing adkar notification: ${e.message}');
    }
  }

  /// Show an ayah notification outside the app
  Future<void> showAyahNotification({
    required String title,
    required String message,
    required VoidCallback onDismiss,
  }) async {
    try {
      await _channel.invokeMethod('showAyahNotification', {
        'title': title,
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint('Error showing ayah notification: ${e.message}');
    }
  }

  /// Dismiss all notifications
  Future<void> dismissAllNotifications() async {
    try {
      await _channel.invokeMethod('dismissAllNotifications');
    } on PlatformException catch (e) {
      debugPrint('Error dismissing notifications: ${e.message}');
    }
  }
}
