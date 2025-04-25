import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/surah.dart';
import 'package:al_moslim/core/models/ayah.dart';
import 'package:al_moslim/core/services/quran_service.dart';
import 'package:al_moslim/features/quran/widgets/ayah_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final QuranService _quranService = QuranService();
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _showTranslation = false;
  Set<int> _bookmarkedAyahs = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _loadBookmarks();
    _saveLastRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAyahs() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final ayahs =
          _showTranslation
              ? await _quranService.getAyahsWithTranslation(widget.surah.number)
              : await _quranService.getAyahsForSurah(widget.surah.number);

      setState(() {
        _ayahs = ayahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_ayahs') ?? [];

    setState(() {
      _bookmarkedAyahs =
          bookmarks
              .map((bookmark) => int.tryParse(bookmark) ?? 0)
              .where((id) => id > 0)
              .toSet();
    });
  }

  Future<void> _saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', widget.surah.number);
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_ayahs') ?? [];

    setState(() {
      if (_bookmarkedAyahs.contains(ayahNumber)) {
        _bookmarkedAyahs.remove(ayahNumber);
        bookmarks.remove(ayahNumber.toString());
      } else {
        _bookmarkedAyahs.add(ayahNumber);
        bookmarks.add(ayahNumber.toString());
      }
    });

    await prefs.setStringList('bookmarked_ayahs', bookmarks);
  }

  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
    _loadAyahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.translate_outlined,
            ),
            onPressed: _toggleTranslation,
            tooltip: 'إظهار الترجمة',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              // TODO: Show bookmarks
            },
            tooltip: 'العلامات المرجعية',
          ),
        ],
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
              'حدث خطأ في تحميل الآيات',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAyahs,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(25),
          ),
          child: Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.surah.englishName} - ${widget.surah.numberOfAyahs} آية',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _ayahs.length,
            itemBuilder: (context, index) {
              final ayah = _ayahs[index];
              return AyahItem(
                ayah: ayah,
                isBookmarked: _bookmarkedAyahs.contains(ayah.number),
                showTranslation: _showTranslation,
                onBookmarkTap: () => _toggleBookmark(ayah.number),
              );
            },
          ),
        ),
      ],
    );
  }
}
