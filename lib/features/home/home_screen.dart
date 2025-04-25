import 'package:flutter/material.dart';
import 'package:al_moslim/core/constants/app_constants.dart';
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/services/prayer_times_service.dart';
import 'package:al_moslim/core/utils/time_utils.dart';
import 'package:al_moslim/features/home/widgets/feature_card.dart';
import 'package:al_moslim/features/home/widgets/prayer_time_card.dart';
import 'package:al_moslim/features/home/widgets/greeting_card.dart';
import 'package:al_moslim/features/home/widgets/daily_hadith_card.dart';
import 'package:al_moslim/features/home/widgets/daily_dhikr_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  String _nextPrayer = '';
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prayerTimes = await _prayerTimesService.getPrayerTimes();
      final now = DateTime.now();
      final nextPrayer = prayerTimes.getNextPrayer(now);

      setState(() {
        _prayerTimes = prayerTimes;
        _nextPrayer = nextPrayer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to the selected screen
          switch (index) {
            case 0:
              // Already on home screen
              break;
            case 1:
              Navigator.pushNamed(context, '/quran');
              break;
            case 2:
              Navigator.pushNamed(context, '/prayer-times');
              break;
            case 3:
              Navigator.pushNamed(context, '/adkar');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        destinations: AppConstants.navigationDestinations,
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadPrayerTimes,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('المسلم'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingCard(
                      greeting: TimeUtils.getGreeting(),
                      hijriDate: _prayerTimes?.hijriDate ?? '',
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_prayerTimes != null)
                      PrayerTimeCard(
                        prayerName: _nextPrayer,
                        prayerTime: _prayerTimes!.getTimeForPrayer(_nextPrayer),
                        timeRemaining: TimeUtils.getTimeRemaining(
                          _prayerTimes!.getTimeForPrayer(_nextPrayer),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      'الميزات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        FeatureCard(
                          title: 'القرآن الكريم',
                          icon: Icons.menu_book,
                          color: Colors.green.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/quran');
                          },
                        ),
                        FeatureCard(
                          title: 'مواقيت الصلاة',
                          icon: Icons.access_time,
                          color: Colors.blue.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/prayer-times');
                          },
                        ),
                        FeatureCard(
                          title: 'الأذكار',
                          icon: Icons.favorite,
                          color: Colors.orange.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/adkar');
                          },
                        ),
                        FeatureCard(
                          title: 'القبلة',
                          icon: Icons.explore,
                          color: Colors.purple.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/qibla');
                          },
                        ),
                        FeatureCard(
                          title: 'التقويم الهجري',
                          icon: Icons.calendar_today,
                          color: Colors.teal.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/calendar');
                          },
                        ),
                        FeatureCard(
                          title: 'الحديث اليومي',
                          icon: Icons.format_quote,
                          color: Colors.indigo.shade700,
                          onTap: () {
                            Navigator.pushNamed(context, '/daily-hadith');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/daily-hadith');
                      },
                      child: const DailyHadithCard(),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/daily-dhikr');
                      },
                      child: const DailyDhikrCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
