import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';
import '../providers/goals_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/journal_provider.dart';
import 'today/today_screen.dart';
import 'goals/goals_screen.dart';
import 'calendar/calendar_screen.dart';
import 'history/history_screen.dart';
import 'journal/journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    super.initState();
    // Load initial data for all providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    try {
      final todosProvider = Provider.of<TodosProvider>(context, listen: false);
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final now = DateTime.now();

      // Load data in parallel
      await Future.wait([
        todosProvider.loadTodayTodos(),
        goalsProvider.loadGoals(),
        calendarProvider.loadEventsForMonth(now.year, now.month),
        journalProvider.loadEntries(),
      ]);
      
      print('✅ All data loaded successfully');
    } catch (e) {
      print('❌ Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const TodayScreen(),
    const GoalsScreen(),
    const CalendarScreen(),
    const JournalScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.9 + (_animationController.value * 0.1),
            child: Opacity(
              opacity: _animationController.value,
              child: child,
            ),
          );
        },
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _animationController.forward(from: 0.8);
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            _buildAnimatedNavItem(
              Icons.today_outlined,
              Icons.today,
              'Today',
              0,
            ),
            _buildAnimatedNavItem(
              Icons.flag_outlined,
              Icons.flag,
              'Goals',
              1,
            ),
            _buildAnimatedNavItem(
              Icons.calendar_today_outlined,
              Icons.calendar_today,
              'Calendar',
              2,
            ),
            _buildAnimatedNavItem(
              Icons.book_outlined,
              Icons.book,
              'Journal',
              3,
            ),
            _buildAnimatedNavItem(
              Icons.history_outlined,
              Icons.history,
              'History',
              4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.2 : 1.0),
        child: Icon(icon),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(1.2)
          ..rotateZ(0.1),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
