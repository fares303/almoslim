import 'package:flutter/material.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/services/notification_manager.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  final NotificationManager _notificationManager = NotificationManager();
  bool _isTestingPrayer = false;
  bool _isTestingAdkar = false;
  bool _isTestingAyah = false;
  bool _isTestingInAppPrayer = false;
  bool _isTestingInAppAdkar = false;
  bool _isTestingInAppAyah = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار الإشعارات'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'استخدم هذه الأزرار لاختبار الإشعارات المختلفة في التطبيق. ستظهر الإشعارات داخل التطبيق وكإشعارات نظام.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('إشعارات النظام'),
              const Text(
                'هذه الإشعارات ستظهر حتى عندما يكون التطبيق مغلقًا',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // System Prayer notification test button
              _buildTestButton(
                title: 'اختبار إشعار الصلاة',
                subtitle: 'سيتم إرسال إشعار نظام وتشغيل صوت الأذان',
                icon: Icons.mosque,
                isLoading: _isTestingPrayer,
                onPressed: _testPrayerNotification,
              ),

              const SizedBox(height: 16),

              // System Adkar notification test button
              _buildTestButton(
                title: 'اختبار إشعار الأذكار',
                subtitle: 'سيتم إرسال إشعار نظام للأذكار',
                icon: Icons.auto_stories,
                isLoading: _isTestingAdkar,
                onPressed: _testAdkarNotification,
              ),

              const SizedBox(height: 16),

              // System Ayah notification test button
              _buildTestButton(
                title: 'اختبار إشعار الآية اليومية',
                subtitle: 'سيتم إرسال إشعار نظام للآية اليومية',
                icon: Icons.menu_book,
                isLoading: _isTestingAyah,
                onPressed: _testAyahNotification,
              ),

              const SizedBox(height: 32),

              _buildSectionHeader('إشعارات داخل التطبيق'),
              const Text(
                'هذه الإشعارات ستظهر فقط عندما يكون التطبيق مفتوحًا',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // In-app Prayer notification test button
              _buildTestButton(
                title: 'اختبار إشعار الصلاة داخل التطبيق',
                subtitle: 'سيتم إظهار إشعار منبثق داخل التطبيق',
                icon: Icons.mosque,
                isLoading: _isTestingInAppPrayer,
                onPressed: _testInAppPrayerNotification,
              ),

              const SizedBox(height: 16),

              // In-app Adkar notification test button
              _buildTestButton(
                title: 'اختبار إشعار الأذكار داخل التطبيق',
                subtitle: 'سيتم إظهار إشعار منبثق داخل التطبيق',
                icon: Icons.auto_stories,
                isLoading: _isTestingInAppAdkar,
                onPressed: _testInAppAdkarNotification,
              ),

              const SizedBox(height: 16),

              // In-app Ayah notification test button
              _buildTestButton(
                title: 'اختبار إشعار الآية داخل التطبيق',
                subtitle: 'سيتم إظهار إشعار منبثق داخل التطبيق',
                icon: Icons.menu_book,
                isLoading: _isTestingInAppAyah,
                onPressed: _testInAppAyahNotification,
              ),

              const SizedBox(height: 32),

              const Text(
                'ملاحظة: تأكد من منح التطبيق إذن الإشعارات والسماح له بالعمل في الخلفية للحصول على الإشعارات حتى عندما يكون التطبيق مغلقًا.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testPrayerNotification() async {
    if (_isTestingPrayer) return;

    setState(() {
      _isTestingPrayer = true;
    });

    try {
      // Request notification permissions
      await _notificationService.requestPermissions();

      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إرسال إشعار الصلاة خلال 2 ثوانٍ'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Test prayer notification
      await _notificationService.testPrayerNotification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال إشعار الصلاة بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingPrayer = false;
        });
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _testAdkarNotification() async {
    if (_isTestingAdkar) return;

    setState(() {
      _isTestingAdkar = true;
    });

    try {
      // Request notification permissions
      await _notificationService.requestPermissions();

      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إرسال إشعار الأذكار خلال 2 ثوانية'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Test adkar notification
      await _notificationService.testAdkarNotification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال إشعار الأذكار بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingAdkar = false;
        });
      }
    }
  }

  Future<void> _testAyahNotification() async {
    if (_isTestingAyah) return;

    setState(() {
      _isTestingAyah = true;
    });

    try {
      // Request notification permissions
      await _notificationService.requestPermissions();

      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إرسال إشعار الآية اليومية خلال 2 ثوانية'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Test ayah notification
      await _notificationService.testAyahNotification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال إشعار الآية اليومية بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingAyah = false;
        });
      }
    }
  }

  // In-app notification test methods
  Future<void> _testInAppPrayerNotification() async {
    if (_isTestingInAppPrayer) return;

    setState(() {
      _isTestingInAppPrayer = true;
    });

    try {
      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إظهار إشعار الصلاة داخل التطبيق خلال 2 ثوانية'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Show in-app notification
      _notificationManager.showPrayerNotification(
        title: 'حان وقت صلاة الظهر',
        message: 'حان الآن وقت صلاة الظهر - 12:00',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إظهار إشعار الصلاة داخل التطبيق بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingInAppPrayer = false;
        });
      }
    }
  }

  Future<void> _testInAppAdkarNotification() async {
    if (_isTestingInAppAdkar) return;

    setState(() {
      _isTestingInAppAdkar = true;
    });

    try {
      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إظهار إشعار الأذكار داخل التطبيق خلال 2 ثوانية'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Show in-app notification
      _notificationManager.showAdkarNotification(
        title: 'أذكار الصباح',
        message:
            'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إظهار إشعار الأذكار داخل التطبيق بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingInAppAdkar = false;
        });
      }
    }
  }

  Future<void> _testInAppAyahNotification() async {
    if (_isTestingInAppAyah) return;

    setState(() {
      _isTestingInAppAyah = true;
    });

    try {
      // Show a toast notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إظهار إشعار الآية داخل التطبيق خلال 2 ثوانية'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Show in-app notification
      _notificationManager.showAyahNotification(
        title: 'آية اليوم',
        message:
            'الحجرات: 10 - إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُرْحَمُونَ',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إظهار إشعار الآية داخل التطبيق بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingInAppAyah = false;
        });
      }
    }
  }
}
