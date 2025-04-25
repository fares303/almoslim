import 'package:flutter/material.dart';
import 'package:al_moslim/core/constants/app_constants.dart';
import 'package:al_moslim/core/utils/time_utils.dart';

class PrayerCard extends StatefulWidget {
  final String prayerName;
  final String prayerTime;
  final bool isNext;

  const PrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.isNext = false,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: widget.isNext ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                widget.isNext
                    ? BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        widget.isNext
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppConstants.prayerIcons[widget.prayerName] ??
                        Icons.access_time,
                    color:
                        widget.isNext
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.prayerNames[widget.prayerName] ??
                          widget.prayerName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            widget.isNext ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (widget.prayerName == 'Sunrise')
                      Text(
                        'وقت الشروق',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatTimeArabic(widget.prayerTime),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        widget.isNext ? FontWeight.bold : FontWeight.normal,
                    color:
                        widget.isNext ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
