import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/daily_dhikr.dart';
import 'package:al_moslim/core/services/daily_dhikr_service.dart';
import 'package:provider/provider.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';
import 'package:share_plus/share_plus.dart';

/// شاشة الذكر اليومي
class DailyDhikrScreen extends StatefulWidget {
  const DailyDhikrScreen({Key? key}) : super(key: key);

  @override
  State<DailyDhikrScreen> createState() => _DailyDhikrScreenState();
}

class _DailyDhikrScreenState extends State<DailyDhikrScreen>
    with SingleTickerProviderStateMixin {
  final DailyDhikrService _dhikrService = DailyDhikrService();
  late Future<DailyDhikr> _dhikrFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _dhikrFuture = _dhikrService.getDailyDhikr();

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter(int? maxCount) {
    if (maxCount != null && _counter >= maxCount) {
      // عرض رسالة عند الوصول إلى العدد المطلوب
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أكملت العدد المطلوب: $maxCount'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _counter++;
    });

    // تشغيل الرسوم المتحركة عند النقر
    _animationController.reset();
    _animationController.forward();
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة تعيين العداد'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareDhikr(DailyDhikr dhikr) {
    final text = 'ذكر اليوم:\n${dhikr.text}\n\nالمصدر: ${dhikr.source}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<SettingsProvider>(context).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ذكر اليوم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الذكر',
            onPressed: () {
              setState(() {
                _dhikrFuture = _dhikrService.getDailyDhikr();
                _counter = 0;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DailyDhikr>(
        future: _dhikrFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في تحميل الذكر',
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dhikrFuture = _dhikrService.getDailyDhikr();
                      });
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('لا يوجد ذكر متاح حاليًا'),
            );
          }

          final dhikr = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة الذكر
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // نص الذكر
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Text(
                              dhikr.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // المصدر
                        Text(
                          'المصدر: ${dhikr.source}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        // الفضل
                        if (dhikr.virtue != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'الفضل:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dhikr.virtue!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // عداد التكرار
                if (dhikr.repetitionCount != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'عدد التكرار المطلوب: ${dhikr.repetitionCount}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // عداد التكرار الحالي
                          Text(
                            '$_counter',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _counter >= (dhikr.repetitionCount ?? 0)
                                  ? Colors.green
                                  : primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // شريط التقدم
                          LinearProgressIndicator(
                            value: dhikr.repetitionCount != null &&
                                    dhikr.repetitionCount! > 0
                                ? _counter / dhikr.repetitionCount!
                                : 0,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _counter >= (dhikr.repetitionCount ?? 0)
                                  ? Colors.green
                                  : primaryColor,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 16),

                          // أزرار التحكم
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _resetCounter(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة تعيين'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _incrementCounter(dhikr.repetitionCount),
                                icon: const Icon(Icons.add),
                                label: const Text('تسبيح'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // زر المشاركة
                ElevatedButton.icon(
                  onPressed: () => _shareDhikr(dhikr),
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة الذكر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // زر عرض المزيد من الأذكار
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DhikrCategoriesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('عرض المزيد من الأذكار'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// شاشة فئات الأذكار
class DhikrCategoriesScreen extends StatelessWidget {
  const DhikrCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dhikrService = DailyDhikrService();
    final categories = dhikrService.getDhikrCategories();
    final isDarkMode = Provider.of<SettingsProvider>(context).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('فئات الأذكار'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DhikrListScreen(
                      category: category,
                      dhikrs: dhikrService.getDhikrsByCategory(category),
                    ),
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

/// شاشة قائمة الأذكار
class DhikrListScreen extends StatelessWidget {
  final String category;
  final List<DailyDhikr> dhikrs;

  const DhikrListScreen({
    Key? key,
    required this.category,
    required this.dhikrs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<SettingsProvider>(context).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dhikrs.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrs[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dhikr.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المصدر: ${dhikr.source}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (dhikr.repetitionCount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'عدد التكرار: ${dhikr.repetitionCount}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                  if (dhikr.virtue != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'الفضل:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dhikr.virtue!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: 'مشاركة',
                        onPressed: () {
                          final text =
                              'ذكر:\n${dhikr.text}\n\nالمصدر: ${dhikr.source}';
                          Share.share(text);
                        },
                        color: primaryColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        tooltip: 'إضافة للمفضلة',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت الإضافة إلى المفضلة'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
