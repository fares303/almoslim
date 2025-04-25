import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:al_moslim/config/routes.dart';
import 'package:al_moslim/core/theme/app_theme.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';
import 'package:al_moslim/core/utils/performance_utils.dart';
import 'package:al_moslim/core/services/notification_manager.dart';

class AlMoslimApp extends StatelessWidget with WidgetsBindingObserver {
  const AlMoslimApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Get the notification manager instance
          final notificationManager = NotificationManager();

          return OverlaySupport.global(
            child: MaterialApp(
              navigatorKey: notificationManager.navigatorKey,
              title: 'AlMoslim',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settings.themeMode,
              locale: const Locale('ar'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar')],
              initialRoute: AppRoutes.home,
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              builder: (context, child) {
                // Add performance optimizations to the entire app
                return MediaQuery(
                  // Avoid unnecessary rebuilds when keyboard appears
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: PerformanceUtils.cachedWidget(
                    child: child!,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
