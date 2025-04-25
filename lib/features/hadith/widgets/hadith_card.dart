import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:al_moslim/core/models/hadith.dart';
import 'package:al_moslim/core/widgets/animated_islamic_card.dart';
import 'package:al_moslim/core/services/hadith_favorites_service.dart';

class HadithCard extends StatefulWidget {
  final Hadith hadith;
  final VoidCallback onShare;

  const HadithCard({super.key, required this.hadith, required this.onShare});

  @override
  State<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<HadithCard>
    with SingleTickerProviderStateMixin {
  final HadithFavoritesService _favoritesService = HadithFavoritesService();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.hadith.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final result = await _favoritesService.toggleFavorite(widget.hadith);
    if (mounted && result) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'تمت إضافة الحديث إلى المفضلة'
                : 'تمت إزالة الحديث من المفضلة',
          ),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_animation),
          child: AnimatedIslamicCard(
            title:
                widget.hadith.title.isNotEmpty
                    ? widget.hadith.title
                    : 'حديث شريف',
            icon: Icons.format_quote,
            isFavorite: _isFavorite,
            onFavoriteToggle: _toggleFavorite,
            color:
                widget.hadith.grade != null
                    ? _getGradeColor(widget.hadith.grade!)
                    : Theme.of(context).primaryColor,
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hadith text with animated shimmer effect
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Theme.of(context).primaryColor.withOpacity(0.5),
                        Theme.of(context).primaryColor.withOpacity(0.3),
                      ],
                      stops: const [0.1, 0.5, 0.9],
                      begin: const Alignment(-1.0, -0.3),
                      end: const Alignment(1.0, 0.3),
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Text(
                    widget.hadith.text,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.hadith.grade != null &&
                    widget.hadith.grade!.isNotEmpty)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getGradeColor(
                                  widget.hadith.grade!,
                                ).withOpacity(0.2),
                                _getGradeColor(
                                  widget.hadith.grade!,
                                ).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getGradeColor(
                                  widget.hadith.grade!,
                                ).withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getGradeIcon(widget.hadith.grade!),
                                size: 18,
                                color: _getGradeColor(widget.hadith.grade!),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'الدرجة: ${widget.hadith.grade}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getGradeColor(widget.hadith.grade!),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                Text(
                  widget.hadith.source,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (widget.hadith.reference != null &&
                    widget.hadith.reference!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.hadith.reference!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: widget.onShare,
                      tooltip: 'مشاركة',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.hadith.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم نسخ الحديث'),
                            backgroundColor: Theme.of(context).primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      tooltip: 'نسخ',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    grade = grade.toLowerCase();
    if (grade.contains('صحيح')) {
      return Colors.green;
    } else if (grade.contains('حسن')) {
      return Colors.blue;
    } else if (grade.contains('ضعيف')) {
      return Colors.orange;
    } else if (grade.contains('موضوع')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  IconData _getGradeIcon(String grade) {
    grade = grade.toLowerCase();
    if (grade.contains('صحيح')) {
      return Icons.verified;
    } else if (grade.contains('حسن')) {
      return Icons.thumb_up;
    } else if (grade.contains('ضعيف')) {
      return Icons.warning;
    } else if (grade.contains('موضوع')) {
      return Icons.dangerous;
    } else {
      return Icons.info;
    }
  }
}
