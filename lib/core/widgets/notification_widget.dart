import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Duration duration;
  final NotificationType type;

  const NotificationWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications,
    this.color = Colors.green,
    this.onTap,
    this.duration = const Duration(seconds: 5),
    this.type = NotificationType.general,
  }) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();

    // Auto-dismiss after duration
    _timer = Timer(widget.duration, () {
      _animationController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(_animation),
                child: FadeTransition(
                  opacity: _animation,
                  child: GestureDetector(
                    onTap: () {
                      _animationController.reverse().then((_) {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color,
                            widget.color.withAlpha(204), // 0.8 * 255 = 204
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color:
                                widget.color.withAlpha(102), // 0.4 * 255 = 102
                            blurRadius: 15.0,
                            spreadRadius: 2.0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _buildNotificationIcon(),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 3.0,
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      widget.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withAlpha(51), // 0.2 * 255 = 51
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    _animationController.reverse().then((_) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (widget.type == NotificationType.prayer)
                            _buildPrayerActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    switch (widget.type) {
      case NotificationType.prayer:
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Lottie.asset(
            'assets/animations/prayer.json',
            fit: BoxFit.contain,
          ),
        );
      case NotificationType.adkar:
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Lottie.asset(
            'assets/animations/adkar.json',
            fit: BoxFit.contain,
          ),
        );
      case NotificationType.ayah:
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Lottie.asset(
            'assets/animations/quran.json',
            fit: BoxFit.contain,
          ),
        );
      case NotificationType.general:
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 30.0,
          ),
        );
    }
  }

  Widget _buildPrayerActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.volume_off,
            label: 'إيقاف الأذان',
            onTap: () {
              // Stop adhan
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
          ),
          _buildActionButton(
            icon: Icons.check_circle,
            label: 'تم',
            onTap: () {
              _animationController.reverse().then((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum NotificationType {
  general,
  prayer,
  adkar,
  ayah,
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  void showNotification({
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color color = Colors.green,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    _showOverlayNotification(
      title: title,
      message: message,
      icon: icon,
      color: color,
      onTap: onTap,
      duration: duration,
      type: NotificationType.general,
    );
  }

  void showPrayerNotification({
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 10),
  }) {
    _showOverlayNotification(
      title: title,
      message: message,
      icon: Icons.mosque,
      color: Colors.green,
      onTap: onTap ??
          () {
            // Default action to stop adhan if no callback provided
            debugPrint('Stop adhan button pressed');
          },
      duration: duration,
      type: NotificationType.prayer,
    );
  }

  void showAdkarNotification({
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 7),
  }) {
    _showOverlayNotification(
      title: title,
      message: message,
      icon: Icons.auto_stories,
      color: Colors.blue,
      onTap: onTap,
      duration: duration,
      type: NotificationType.adkar,
    );
  }

  void showAyahNotification({
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 7),
  }) {
    _showOverlayNotification(
      title: title,
      message: message,
      icon: Icons.menu_book,
      color: Colors.purple,
      onTap: onTap,
      duration: duration,
      type: NotificationType.ayah,
    );
  }

  void _showOverlayNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required NotificationType type,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (navigatorKey.currentState == null) {
      debugPrint('Navigator key is null');
      return;
    }

    navigatorKey.currentState!.overlay?.insert(
      OverlayEntry(
        builder: (context) => NotificationWidget(
          title: title,
          message: message,
          icon: icon,
          color: color,
          onTap: onTap,
          duration: duration,
          type: type,
        ),
      ),
    );
  }
}
