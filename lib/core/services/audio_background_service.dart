import 'package:flutter/material.dart';

/// خدمة تشغيل الصوت في الخلفية
/// تستخدم لتهيئة خدمة تشغيل الصوت في الخلفية
class AudioBackgroundService {
  /// تهيئة خدمة تشغيل الصوت في الخلفية
  static Future<void> init() async {
    try {
      // تم إزالة تهيئة JustAudioBackground لأنها تسبب مشاكل
      debugPrint('تم تعطيل خدمة تشغيل الصوت في الخلفية');
    } catch (e) {
      debugPrint('خطأ في تهيئة خدمة تشغيل الصوت في الخلفية: $e');
    }
  }
}
