import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/hadith.dart';
import 'package:al_moslim/core/services/hadith_service.dart';
import 'package:al_moslim/features/hadith/widgets/hadith_card.dart';
import 'package:share_plus/share_plus.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final HadithService _hadithService = HadithService();
  List<Hadith> _hadiths = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHadiths();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreHadiths();
      }
    }
  }

  Future<void> _loadHadiths() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
      });

      final hadiths = await _hadithService.getHadithsByBook(
        'muslim',
        page: _currentPage,
      );

      setState(() {
        _hadiths = hadiths;
        _isLoading = false;
        _hasMoreData = hadiths.length == 20; // Assuming 20 is the page size
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreHadiths() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final nextPage = _currentPage + 1;
      final moreHadiths = await _hadithService.getHadithsByBook(
        'muslim',
        page: nextPage,
      );

      if (moreHadiths.isNotEmpty) {
        setState(() {
          _hadiths.addAll(moreHadiths);
          _currentPage = nextPage;
          _hasMoreData =
              moreHadiths.length == 20; // Assuming 20 is the page size
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _getRandomHadith() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final hadith = await _hadithService.getRandomHadith();

      setState(() {
        _hadiths = [hadith];
        _isLoading = false;
        _hasMoreData = false;
      });
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
      subject: 'حديث من تطبيق المسلم',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأحاديث النبوية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _getRandomHadith,
            tooltip: 'حديث عشوائي',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _hadiths.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _hadiths.isEmpty) {
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
              onPressed: _loadHadiths,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_hadiths.isEmpty) {
      return const Center(
        child: Text('لا توجد أحاديث', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHadiths,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _hadiths.length) {
            return _isLoadingMore
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _loadMoreHadiths,
                      child: const Text('تحميل المزيد'),
                    ),
                  ),
                );
          }

          final hadith = _hadiths[index];
          return HadithCard(
            hadith: hadith,
            onShare: () => _shareHadith(hadith),
          );
        },
      ),
    );
  }
}
