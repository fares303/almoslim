import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/hadith.dart';
import 'package:al_moslim/core/services/hadith_service.dart';
import 'package:al_moslim/features/hadith/widgets/hadith_card.dart';
import 'package:share_plus/share_plus.dart';

class DailyHadithScreen extends StatefulWidget {
  const DailyHadithScreen({super.key});

  @override
  State<DailyHadithScreen> createState() => _DailyHadithScreenState();
}

class _DailyHadithScreenState extends State<DailyHadithScreen> with SingleTickerProviderStateMixin {
  final HadithService _hadithService = HadithService();
  List<Hadith> _hadiths = [];
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadDailyHadiths();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDailyHadiths() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final hadiths = await _hadithService.getDailyHadiths();

      setState(() {
        _hadiths = hadiths;
        _isLoading = false;
      });
      
      _controller.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _shareHadith(Hadith hadith) {
    Share.share(
      '${hadith.text}\n\n${hadith.source}',
      subject: 'حديث اليوم من تطبيق المسلم',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حديث اليوم'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'حدث خطأ في تحميل الأحاديث',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyHadiths,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_hadiths.isEmpty) {
      return const Center(
        child: Text('لا توجد أحاديث لليوم', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDailyHadiths,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length,
        itemBuilder: (context, index) {
          final hadith = _hadiths[index];
          return FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_animation),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: HadithCard(
                  hadith: hadith,
                  onShare: () => _shareHadith(hadith),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
