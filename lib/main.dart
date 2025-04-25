import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:al_moslim/app.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';
import 'package:al_moslim/core/utils/performance_utils.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/services/audio_background_service.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handlers
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Message data: ${message.data}");
  debugPrint("Message notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');

    // Set up Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await messaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة تحسينات الأداء
  PerformanceUtils.init();

  // تعيين نمط تراكب واجهة المستخدم للنظام لتحسين الأداء
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // تحسين ذاكرة التخزين المؤقت للصور
  PaintingBinding.instance.imageCache.maximumSize =
      150; // زيادة حجم الذاكرة المؤقتة
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Load saved notifications
  await notificationService.loadSavedNotifications();

  // Initialize audio background service
  await AudioBackgroundService.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SettingsProvider())],
      child: const AlMoslimApp(),
    ),
  );
}
