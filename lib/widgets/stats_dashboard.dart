import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatsDashboard extends StatelessWidget {
  final int streakDays;
  final int completionPercentage;
  final int activeGoals;

  const StatsDashboard({
    super.key,
    required this.streakDays,
    required this.completionPercentage,
    required this.activeGoals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            context,
            icon: Icons.local_fire_department,
            value: streakDays.toString(),
            label: 'Day Streak',
            color: Colors.orange,
          ),
          _buildDivider(),
          _buildStat(
            context,
            icon: Icons.check_circle,
            value: '$completionPercentage%',
            label: 'Complete',
            color: AppTheme.softBlue,
          ),
          _buildDivider(),
          _buildStat(
            context,
            icon: Icons.flag,
            value: activeGoals.toString(),
            label: 'Active Goals',
            color: AppTheme.forestGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.stoneGrey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.sage,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.sage.withOpacity(0.3),
    );
  }
}
