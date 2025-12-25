import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/app_theme.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime focusedDay;
  final List<DateTime> markedDates;
  final Function(DateTime) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.markedDates,
    required this.onDaySelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _selectedDay = widget.focusedDay;
  }

  bool _isMarkedDate(DateTime day) {
    return widget.markedDates.any((date) =>
        date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppTheme.stoneGrey),
          holidayTextStyle: TextStyle(color: AppTheme.stoneGrey),
          selectedDecoration: BoxDecoration(
            color: AppTheme.softBlue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.softBlue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          defaultTextStyle: TextStyle(color: AppTheme.stoneGrey),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: AppTheme.stoneGrey,
                fontWeight: FontWeight.bold,
              ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppTheme.forestGreen,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.forestGreen,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppTheme.sage,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppTheme.sage,
            fontWeight: FontWeight.w600,
          ),
        ),
        eventLoader: (day) {
          return _isMarkedDate(day) ? ['completed'] : [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDaySelected(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
