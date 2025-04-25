import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/ayah.dart';
import 'package:share_plus/share_plus.dart';

class AyahItem extends StatefulWidget {
  final Ayah ayah;
  final bool isBookmarked;
  final bool showTranslation;
  final VoidCallback onBookmarkTap;

  const AyahItem({
    super.key,
    required this.ayah,
    required this.isBookmarked,
    required this.showTranslation,
    required this.onBookmarkTap,
  });

  @override
  State<AyahItem> createState() => _AyahItemState();
}

class _AyahItemState extends State<AyahItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.ayah.numberInSurah}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      widget.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: widget.onBookmarkTap,
                    tooltip: 'إضافة إلى العلامات المرجعية',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Share.share(
                        '${widget.ayah.text}\n\n${widget.ayah.translation ?? ''}',
                        subject: 'آية من القرآن الكريم',
                      );
                    },
                    tooltip: 'مشاركة',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.ayah.text} ﴿${widget.ayah.numberInSurah}﴾',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.8,
                      fontFamily: 'Amiri',
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  if (widget.showTranslation &&
                      widget.ayah.translation != null) ...[
                    const Divider(height: 24),
                    Text(
                      widget.ayah.translation!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
