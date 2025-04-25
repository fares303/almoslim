import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// أدوات تحسين الأداء
class PerformanceUtils {
  /// تهيئة إعدادات الأداء
  static void init() {
    // تعيين وضع الأداء العالي
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // تعيين اتجاه الشاشة
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // تسجيل مستمع لدورة حياة التطبيق
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

    // تسجيل مستمع للاستثناءات غير المعالجة
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      developer.log(
        'FlutterError: ${details.exception}',
        name: 'PerformanceUtils',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // تعيين مستمع للاستثناءات غير المتزامنة
    PlatformDispatcher.instance.onError = (error, stack) {
      developer.log(
        'PlatformDispatcher Error: $error',
        name: 'PerformanceUtils',
        error: error,
        stackTrace: stack,
      );
      return true;
    };

    // تمكين أعلام الأداء للتصحيح
    enablePerformanceFlags();
  }

  /// تمكين أعلام الأداء للتصحيح
  static void enablePerformanceFlags() {
    if (kDebugMode) {
      // تمكين تراكب أداء العرض
      debugPrintMarkNeedsLayoutStacks = false;
      debugPrintMarkNeedsPaintStacks = false;
      debugPrintLayouts = false;
      debugPrintRebuildDirtyWidgets = false;
    }
  }

  /// تنظيف الذاكرة
  static void cleanMemory() {
    // تنظيف ذاكرة التخزين المؤقت للصور
    imageCache.clear();
    imageCache.clearLiveImages();

    // إجبار جامع القمامة على العمل
    developer.log('تنظيف الذاكرة', name: 'PerformanceUtils');
  }

  /// تسجيل أداء الإطار
  static void logFramePerformance(Duration duration) {
    if (duration > const Duration(milliseconds: 16)) {
      developer.log(
        'إطار بطيء: ${duration.inMilliseconds}ms',
        name: 'PerformanceUtils',
      );
    }
  }

  /// تتبع أداء العملية
  static Stopwatch startPerformanceTracking(String operationName) {
    developer.log('بدء العملية: $operationName', name: 'PerformanceUtils');
    return Stopwatch()..start();
  }

  /// إنهاء تتبع أداء العملية
  static void endPerformanceTracking(
      Stopwatch stopwatch, String operationName) {
    stopwatch.stop();
    developer.log(
      'انتهاء العملية: $operationName - ${stopwatch.elapsedMilliseconds}ms',
      name: 'PerformanceUtils',
    );
  }

  /// Optimize image loading
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      cacheWidth: width != null ? (width * 2).toInt() : null,
      cacheHeight: height != null ? (height * 2).toInt() : null,
      filterQuality: FilterQuality.medium,
    );
  }

  /// Create a cached widget to avoid rebuilds
  static Widget cachedWidget({
    required Widget child,
    Key? key,
  }) {
    return RepaintBoundary(
      key: key,
      child: child,
    );
  }

  /// تحسين أداء القائمة
  static Widget optimizedListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required String listKey,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool addRepaintBoundaries = true,
    bool addAutomaticKeepAlives = false,
    double? itemExtent,
    Widget? separatorBuilder,
  }) {
    return ListView.builder(
      key: PageStorageKey<String>(listKey),
      controller: controller,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      addRepaintBoundaries: addRepaintBoundaries,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      itemExtent: itemExtent,
    );
  }

  /// تحسين أداء الشبكة
  static Widget optimizedGridView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required String gridKey,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      key: PageStorageKey<String>(gridKey),
      gridDelegate: gridDelegate,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
    );
  }
}

/// مراقب دورة حياة التطبيق
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // تنظيف الذاكرة عند إيقاف التطبيق مؤقتًا أو إغلاقه
        PerformanceUtils.cleanMemory();
        break;
      case AppLifecycleState.resumed:
        // إعادة تحميل البيانات عند استئناف التطبيق
        developer.log('استئناف التطبيق', name: 'PerformanceUtils');
        break;
      default:
        break;
    }
  }
}
