import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EnhancedNotification extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final String? lottieAsset;
  final Duration duration;

  const EnhancedNotification({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    this.onTap,
    this.onDismiss,
    this.lottieAsset,
    this.duration = const Duration(seconds: 10),
  }) : super(key: key);

  @override
  State<EnhancedNotification> createState() => _EnhancedNotificationState();
}

class _EnhancedNotificationState extends State<EnhancedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (widget.onDismiss != null) {
            widget.onDismiss!();
          }
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _animation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (widget.lottieAsset != null)
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Lottie.asset(
                              widget.lottieAsset!,
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForNotification(),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _animationController.reverse().then((_) {
                              if (widget.onDismiss != null) {
                                widget.onDismiss!();
                              }
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (widget.onTap != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: TextButton(
                        onPressed: widget.onTap,
                        child: const Text(
                          'اضغط هنا',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForNotification() {
    if (widget.color == Colors.green) {
      return Icons.access_time;
    } else if (widget.color == Colors.blue) {
      return Icons.book;
    } else if (widget.color == Colors.purple) {
      return Icons.menu_book;
    } else {
      return Icons.notifications;
    }
  }
}

class EnhancedNotificationService {
  static void showPrayerNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    _showNotification(
      context,
      title: title,
      message: message,
      color: Colors.green,
      lottieAsset: 'assets/animations/prayer.json',
      onTap: onTap,
      onDismiss: onDismiss,
    );
  }

  static void showAdkarNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    _showNotification(
      context,
      title: title,
      message: message,
      color: Colors.blue,
      lottieAsset: 'assets/animations/adkar.json',
      onTap: onTap,
      onDismiss: onDismiss,
    );
  }

  static void showAyahNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    _showNotification(
      context,
      title: title,
      message: message,
      color: Colors.purple,
      lottieAsset: 'assets/animations/quran.json',
      onTap: onTap,
      onDismiss: onDismiss,
    );
  }

  static void _showNotification(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
    String? lottieAsset,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: EnhancedNotification(
          title: title,
          message: message,
          color: color,
          lottieAsset: lottieAsset,
          onTap: onTap,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}
