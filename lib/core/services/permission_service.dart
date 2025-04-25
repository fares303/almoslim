import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  // Check and request location permission
  Future<bool> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      _showPermissionDialog(
        context,
        'خدمات الموقع غير مفعلة',
        'يرجى تفعيل خدمات الموقع في إعدادات الجهاز لاستخدام ميزة القبلة.',
      );
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        _showPermissionDialog(
          context,
          'تم رفض إذن الموقع',
          'يرجى السماح للتطبيق بالوصول إلى موقعك لاستخدام ميزة القبلة.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever
      _showPermissionDialog(
        context,
        'تم رفض إذن الموقع بشكل دائم',
        'يرجى الذهاب إلى إعدادات التطبيق وتفعيل إذن الموقع.',
      );
      return false;
    }

    // Permission granted
    return true;
  }

  // Check and request notification permission
  Future<bool> requestNotificationPermission([BuildContext? context]) async {
    // Use permission_handler to request notification permission
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    // If context is provided and permission is permanently denied, show dialog
    if (status.isPermanentlyDenied && context != null) {
      _showPermissionDialog(
        context,
        'تم رفض إذن الإشعارات بشكل دائم',
        'يرجى الذهاب إلى إعدادات التطبيق وتفعيل إذن الإشعارات.',
      );
    }

    return status.isGranted;
  }

  // Show permission dialog
  void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          ),
    );
  }

  // Show notification permission dialog
  Future<bool> _showNotificationPermissionDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إذن الإشعارات'),
            content: const Text(
              'هل تسمح للتطبيق بإرسال إشعارات لتنبيهك بأوقات الصلاة والأذكار؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('لا'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نعم'),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}
