import 'package:flutter/material.dart';
import 'package:al_moslim/core/constants/app_constants.dart';
import 'package:al_moslim/core/models/adkar.dart';
import 'package:al_moslim/core/services/adkar_service.dart';
import 'package:al_moslim/features/adkar/widgets/adkar_category_card.dart';
import 'package:al_moslim/features/adkar/adkar_category_screen.dart';

class AdkarScreen extends StatefulWidget {
  const AdkarScreen({super.key});

  @override
  State<AdkarScreen> createState() => _AdkarScreenState();
}

class _AdkarScreenState extends State<AdkarScreen>
    with SingleTickerProviderStateMixin {
  final AdkarService _adkarService = AdkarService();
  List<AdkarCategory> _categories = [];
  List<Dhikr> _favoriteAdkar = [];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final categories = await _adkarService.getCategories();
      final favoriteAdkar = await _adkarService.getFavoriteAdkar();

      setState(() {
        _categories = categories;
        _favoriteAdkar = favoriteAdkar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'ذكر اليوم',
            onPressed: () {
              Navigator.pushNamed(context, '/daily-dhikr');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'الأقسام'), Tab(text: 'المفضلة')],
        ),
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
              onPressed: _loadData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildCategoriesTab(), _buildFavoritesTab()],
    );
  }

  Widget _buildCategoriesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final categoryName =
              AppConstants.adkarCategories[category.name] ?? category.name;

          return AdkarCategoryCard(
            title: categoryName,
            count: category.count,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdkarCategoryScreen(
                    category: category,
                    categoryName: categoryName,
                  ),
                ),
              ).then((_) => _loadData());
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteAdkar.isEmpty) {
      return const Center(
        child: Text('لا توجد أذكار مفضلة', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteAdkar.length,
        itemBuilder: (context, index) {
          final dhikr = _favoriteAdkar[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dhikr.text,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                  if (dhikr.count != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'التكرار: ${dhikr.count}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          dhikr.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          await _adkarService.toggleFavorite(dhikr);
                          _loadData();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          dhikr.isCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: dhikr.isCompleted ? Colors.green : null,
                        ),
                        onPressed: () async {
                          await _adkarService.toggleCompleted(dhikr);
                          _loadData();
                        },
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
