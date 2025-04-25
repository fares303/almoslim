import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/adkar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:al_moslim/core/widgets/animated_islamic_card.dart';

class DhikrCard extends StatelessWidget {
  final Dhikr dhikr;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCompletedTap;

  const DhikrCard({
    super.key,
    required this.dhikr,
    required this.onFavoriteTap,
    required this.onCompletedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedIslamicCard(
        isFavorite: dhikr.isFavorite,
        onFavoriteToggle: onFavoriteTap,
        color:
            dhikr.isCompleted ? Colors.green : Theme.of(context).primaryColor,
        elevation: 3.0,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dhikr text with animated shimmer effect
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.5),
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.5),
                  ],
                  stops: const [0.1, 0.3, 0.4],
                  begin: const Alignment(-1.0, -0.3),
                  end: const Alignment(1.0, 0.3),
                  tileMode: TileMode.clamp,
                ).createShader(bounds);
              },
              blendMode: dhikr.isCompleted ? BlendMode.dst : BlendMode.srcATop,
              child: Text(
                dhikr.text,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color:
                      dhikr.isCompleted
                          ? Colors.grey
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                  decoration:
                      dhikr.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (dhikr.translation != null && dhikr.translation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                dhikr.translation!,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
            if (dhikr.count != null) ...[
              const SizedBox(height: 16),
              _buildCounterWidget(context),
            ],
            if (dhikr.reference != null && dhikr.reference!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                dhikr.reference!,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Completed button with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: dhikr.isCompleted ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.2),
                      child: IconButton(
                        icon: Icon(
                          dhikr.isCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: Color.lerp(Colors.grey, Colors.green, value),
                        ),
                        onPressed: onCompletedTap,
                        tooltip: 'تم',
                      ),
                    );
                  },
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    Share.share(dhikr.text, subject: 'ذكر من تطبيق المسلم');
                  },
                  tooltip: 'مشاركة',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterWidget(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withAlpha(40),
                  Theme.of(context).primaryColor.withAlpha(15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withAlpha(20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.repeat,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'التكرار: ${dhikr.count}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
