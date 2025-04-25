import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/adkar.dart';
import 'package:al_moslim/core/services/adkar_service.dart';
import 'package:al_moslim/features/adkar/widgets/dhikr_card.dart';
import 'package:share_plus/share_plus.dart';

class AdkarCategoryScreen extends StatefulWidget {
  final AdkarCategory category;
  final String categoryName;

  const AdkarCategoryScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<AdkarCategoryScreen> createState() => _AdkarCategoryScreenState();
}

class _AdkarCategoryScreenState extends State<AdkarCategoryScreen> {
  final AdkarService _adkarService = AdkarService();
  List<Dhikr> _adkar = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAdkar();
  }

  Future<void> _loadAdkar() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final adkar = await _adkarService.getAdkarByCategory(widget.category.id);

      setState(() {
        _adkar = adkar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _toggleFavorite(Dhikr dhikr) async {
    try {
      final updatedDhikr = dhikr.copyWith(isFavorite: !dhikr.isFavorite);
      await _adkarService.toggleFavorite(updatedDhikr);

      setState(() {
        final index = _adkar.indexWhere((item) => item.id == dhikr.id);
        if (index != -1) {
          _adkar[index] = updatedDhikr;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleCompleted(Dhikr dhikr) async {
    try {
      final updatedDhikr = dhikr.copyWith(isCompleted: !dhikr.isCompleted);
      await _adkarService.toggleCompleted(updatedDhikr);

      setState(() {
        final index = _adkar.indexWhere((item) => item.id == dhikr.id);
        if (index != -1) {
          _adkar[index] = updatedDhikr;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _shareAdkar() {
    final text = _adkar.map((dhikr) => dhikr.text).join('\n\n');
    Share.share(
      '$text\n\nمن تطبيق المسلم - ${widget.categoryName}',
      subject: widget.categoryName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAdkar,
            tooltip: 'مشاركة',
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
              'حدث خطأ في تحميل الأذكار',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAdkar,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_adkar.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أذكار في هذا القسم',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAdkar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _adkar.length,
        itemBuilder: (context, index) {
          final dhikr = _adkar[index];
          return DhikrCard(
            dhikr: dhikr,
            onFavoriteTap: () => _toggleFavorite(dhikr),
            onCompletedTap: () => _toggleCompleted(dhikr),
          );
        },
      ),
    );
  }
}
