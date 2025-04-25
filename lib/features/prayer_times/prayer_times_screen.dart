import 'package:flutter/material.dart';
import 'package:al_moslim/core/constants/app_constants.dart';
import 'package:al_moslim/core/models/prayer_times.dart';
import 'package:al_moslim/core/services/prayer_times_service.dart';
import 'package:al_moslim/core/services/notification_service.dart';
import 'package:al_moslim/core/utils/time_utils.dart';
import 'package:al_moslim/features/prayer_times/widgets/prayer_card.dart';
import 'package:provider/provider.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final NotificationService _notificationService = NotificationService();
  PrayerTimes? _prayerTimes;
  String _nextPrayer = '';
  bool _isLoading = true;
  bool _hasError = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        date: _selectedDate,
      );
      final now = DateTime.now();
      final nextPrayer = prayerTimes.getNextPrayer(now);

      setState(() {
        _prayerTimes = prayerTimes;
        _nextPrayer = nextPrayer;
        _isLoading = false;
      });

      // Schedule notifications if enabled and widget is still mounted
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        if (settings.notificationsEnabled &&
            settings.adhanNotificationsEnabled) {
          await _notificationService.schedulePrayerNotifications(prayerTimes);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'اختر تاريخ',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
            tooltip: 'تحديث',
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
              'حدث خطأ في تحميل مواقيت الصلاة',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPrayerTimes,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_prayerTimes == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التاريخ الميلادي',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _prayerTimes!.date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'التاريخ الهجري',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _prayerTimes!.hijriDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Next prayer card
            if (_nextPrayer.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withAlpha(179),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الصلاة القادمة',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.prayerNames[_nextPrayer] ?? _nextPrayer,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TimeUtils.formatTimeArabic(
                          _prayerTimes!.getTimeForPrayer(_nextPrayer),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'متبقي: ${TimeUtils.getTimeRemaining(_prayerTimes!.getTimeForPrayer(_nextPrayer))}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Prayer times list
            const Text(
              'مواقيت الصلاة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PrayerCard(
              prayerName: 'Fajr',
              prayerTime: _prayerTimes!.fajr,
              isNext: _nextPrayer == 'Fajr',
            ),
            const SizedBox(height: 8),
            PrayerCard(
              prayerName: 'Sunrise',
              prayerTime: _prayerTimes!.sunrise,
              isNext: _nextPrayer == 'Sunrise',
            ),
            const SizedBox(height: 8),
            PrayerCard(
              prayerName: 'Dhuhr',
              prayerTime: _prayerTimes!.dhuhr,
              isNext: _nextPrayer == 'Dhuhr',
            ),
            const SizedBox(height: 8),
            PrayerCard(
              prayerName: 'Asr',
              prayerTime: _prayerTimes!.asr,
              isNext: _nextPrayer == 'Asr',
            ),
            const SizedBox(height: 8),
            PrayerCard(
              prayerName: 'Maghrib',
              prayerTime: _prayerTimes!.maghrib,
              isNext: _nextPrayer == 'Maghrib',
            ),
            const SizedBox(height: 8),
            PrayerCard(
              prayerName: 'Isha',
              prayerTime: _prayerTimes!.isha,
              isNext: _nextPrayer == 'Isha',
            ),
          ],
        ),
      ),
    );
  }
}
