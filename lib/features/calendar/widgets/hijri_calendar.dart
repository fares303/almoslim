import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HijriCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HijriCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<HijriCalendar> createState() => _HijriCalendarState();
}

class _HijriCalendarState extends State<HijriCalendar> {
  late DateTime _currentMonth;
  late List<DateTime> _daysInMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    _daysInMonth = _getDaysInMonth(_currentMonth);
  }

  @override
  void didUpdateWidget(HijriCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate.month != _currentMonth.month ||
        widget.selectedDate.year != _currentMonth.year) {
      _currentMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        1,
      );
      _daysInMonth = _getDaysInMonth(_currentMonth);
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    // Get the first day of the week (Sunday = 0, Monday = 1, etc.)
    final firstWeekday = firstDayOfMonth.weekday;

    // Calculate how many days from the previous month to show
    final daysFromPreviousMonth = (firstWeekday == 7) ? 0 : firstWeekday;

    // Calculate the start date (may be from the previous month)
    final startDate = firstDayOfMonth.subtract(
      Duration(days: daysFromPreviousMonth),
    );

    // Generate 42 days (6 weeks)
    return List.generate(42, (index) => startDate.add(Duration(days: index)));
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _daysInMonth = _getDaysInMonth(_currentMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _daysInMonth = _getDaysInMonth(_currentMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildWeekdayHeader(),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          weekdays.map((day) {
            return SizedBox(
              width: 40,
              child: Text(
                day.substring(0, 1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      day == 'الجمعة' ? Theme.of(context).primaryColor : null,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: _daysInMonth.length,
      itemBuilder: (context, index) {
        final date = _daysInMonth[index];
        final isCurrentMonth = date.month == _currentMonth.month;
        final isSelected =
            date.year == widget.selectedDate.year &&
            date.month == widget.selectedDate.month &&
            date.day == widget.selectedDate.day;
        final isToday =
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        final isFriday = date.weekday == 5; // Friday is weekday 5

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : isToday
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : null,
            borderRadius: BorderRadius.circular(isSelected || isToday ? 12 : 8),
            border:
                isToday && !isSelected
                    ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                    : isCurrentMonth && !isSelected
                    ? Border.all(color: Colors.grey.withOpacity(0.2))
                    : null,
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                isSelected || isToday ? 12 : 8,
              ),
              onTap: () => widget.onDateSelected(date),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : !isCurrentMonth
                            ? Colors.grey.withOpacity(0.5)
                            : isFriday
                            ? Theme.of(context).primaryColor
                            : null,
                    fontWeight:
                        isToday || isSelected || isFriday
                            ? FontWeight.bold
                            : null,
                    fontSize: isSelected || isToday ? 16 : 14,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
