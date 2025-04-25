import 'package:flutter/material.dart';
import 'package:al_moslim/core/services/prayer_times_service.dart';
import 'package:al_moslim/features/calendar/widgets/hijri_calendar.dart';
import 'package:al_moslim/features/calendar/widgets/islamic_event_card.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, dynamic>? _hijriDate;
  bool _isLoading = true;
  bool _hasError = false;
  DateTime _selectedDate = DateTime.now();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadHijriDate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHijriDate() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final hijriDate = await _prayerTimesService.getHijriDate();

      setState(() {
        _hijriDate = hijriDate;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadHijriDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقويم الهجري'), centerTitle: true),
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
              'حدث خطأ في تحميل التقويم',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHijriDate,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHijriDate,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentDateCard(),
            const SizedBox(height: 24),
            HijriCalendar(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ),
            const SizedBox(height: 24),
            const Text(
              'المناسبات الإسلامية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIslamicEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDateCard() {
    if (_hijriDate == null) {
      return const SizedBox.shrink();
    }

    final gregorianDate = DateFormat('dd MMMM yyyy').format(_selectedDate);
    final hijriDay = _hijriDate!['day'];
    final hijriMonth = _hijriDate!['month']['ar'];
    final hijriYear = _hijriDate!['year'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 8,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'التاريخ الحالي',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '$hijriDay $hijriMonth $hijriYear هـ',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    gregorianDate,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIslamicEvents() {
    // Sample Islamic events
    final events = [
      {
        'name': 'رمضان',
        'date': '1 رمضان',
        'description': 'شهر الصيام المبارك',
        'icon': Icons.nightlight_round,
        'color': Colors.purple,
      },
      {
        'name': 'عيد الفطر',
        'date': '1 شوال',
        'description': 'عيد الفطر المبارك',
        'icon': Icons.celebration,
        'color': Colors.orange,
      },
      {
        'name': 'يوم عرفة',
        'date': '9 ذو الحجة',
        'description': 'يوم الوقوف بعرفة',
        'icon': Icons.landscape,
        'color': Colors.blue,
      },
      {
        'name': 'عيد الأضحى',
        'date': '10 ذو الحجة',
        'description': 'عيد الأضحى المبارك',
        'icon': Icons.celebration,
        'color': Colors.green,
      },
      {
        'name': 'رأس السنة الهجرية',
        'date': '1 محرم',
        'description': 'بداية العام الهجري الجديد',
        'icon': Icons.calendar_today,
        'color': Colors.teal,
      },
      {
        'name': 'المولد النبوي',
        'date': '12 ربيع الأول',
        'description': 'ذكرى مولد النبي محمد ﷺ',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          // Add staggered animation for each card
          final itemAnimation = Tween<Offset>(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.2 + (index * 0.1), // Stagger the animations
                1.0,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          return SlideTransition(
            position: itemAnimation,
            child: IslamicEventCard(
              name: event['name'] as String,
              date: event['date'] as String,
              description: event['description'] as String,
              icon: event['icon'] as IconData,
              color: event['color'] as Color,
            ),
          );
        },
      ),
    );
  }
}
