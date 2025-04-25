import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/surah.dart';
import 'package:al_moslim/core/services/quran_service.dart';
import 'package:al_moslim/features/quran/widgets/surah_list_item.dart';
import 'package:al_moslim/features/quran/quran_reader_screen.dart';
import 'package:al_moslim/features/quran/tafsir_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  List<Surah> _surahs = [];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurahs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final surahs = await _quranService.getSurahs();

      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahs = _surahs;
      });
      return;
    }

    final filtered = _surahs.where((surah) {
      return surah.name.contains(query) ||
          surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
          surah.number.toString() == query;
    }).toList();

    setState(() {
      _filteredSurahs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'قراءة'), Tab(text: 'تفسير')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن سورة',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _filterSurahs,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSurahsList(mode: 'reader'),
                _buildSurahsList(mode: 'tafsir'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahsList({required String mode}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'حدث خطأ في تحميل السور',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSurahs,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_filteredSurahs.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSurahs,
      child: ListView.separated(
        itemCount: _filteredSurahs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final surah = _filteredSurahs[index];
          return SurahListItem(
            surah: surah,
            onTap: () {
              if (mode == 'reader') {
                // وضع القراءة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranReaderScreen(surah: surah),
                  ),
                );
              } else if (mode == 'tafsir') {
                // وضع التفسير
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TafsirScreen(surah: surah),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
