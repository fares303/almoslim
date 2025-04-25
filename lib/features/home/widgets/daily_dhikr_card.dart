import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/daily_dhikr.dart';
import 'package:al_moslim/core/services/daily_dhikr_service.dart';

/// بطاقة الذكر اليومي
class DailyDhikrCard extends StatefulWidget {
  const DailyDhikrCard({Key? key}) : super(key: key);

  @override
  State<DailyDhikrCard> createState() => _DailyDhikrCardState();
}

class _DailyDhikrCardState extends State<DailyDhikrCard> with SingleTickerProviderStateMixin {
  final DailyDhikrService _dhikrService = DailyDhikrService();
  late Future<DailyDhikr> _dhikrFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _dhikrFuture = _dhikrService.getDailyDhikr();
    
    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FutureBuilder<DailyDhikr>(
      future: _dhikrFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('لا يوجد ذكر متاح حاليًا'),
              ),
            ),
          );
        }
        
        final dhikr = snapshot.data!;
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ذكر اليوم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    dhikr.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المصدر: ${dhikr.source}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/daily-dhikr');
                      },
                      child: const Text('عرض المزيد'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
