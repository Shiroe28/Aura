import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StreakIndicator extends StatelessWidget {
  final int streakCount;
  final double size;
  final double? progress; // Add optional progress parameter for goal completion

  const StreakIndicator({
    super.key,
    required this.streakCount,
    this.size = 40,
    this.progress,
  });

  Color _getFireColor() {
    // If progress is provided, use it to determine color
    if (progress != null) {
      if (progress! >= 1.0) {
        return Colors.red; // 100% = red fire
      } else if (progress! >= 0.75) {
        return Colors.orange; // 75-99% = orange fire
      } else if (progress! >= 0.5) {
        return Colors.deepOrange; // 50-74% = deep orange
      } else if (progress! > 0) {
        return AppTheme.softBlue; // 1-49% = cool blue
      }
    }
    // If no progress, use streak count
    return streakCount > 0 ? AppTheme.softBlue : AppTheme.sage;
  }

  @override
  Widget build(BuildContext context) {
    final fireColor = _getFireColor();
    final isActive = (progress != null && progress! > 0) || streakCount > 0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fireColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: size * 0.6,
          ),
          if (streakCount > 0)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.stoneGrey,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: size * 0.4,
                  minHeight: size * 0.4,
                ),
                child: Center(
                  child: Text(
                    '$streakCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
