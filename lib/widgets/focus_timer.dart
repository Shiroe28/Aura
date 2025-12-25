import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // Default 25 minutes
  bool _isRunning = false;
  final List<int> _presetMinutes = [15, 25, 45, 60];
  int _selectedPreset = 25;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopTimer();
          // Optional: Show completion dialog
          _showCompletionDialog();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedPreset * 60;
    });
  }

  void _setPreset(int minutes) {
    if (!_isRunning) {
      setState(() {
        _selectedPreset = minutes;
        _secondsRemaining = minutes * 60;
      });
    }
  }

  void _showCustomTimeDialog() {
    final minutesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Time'),
        content: TextField(
          controller: minutesController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter minutes',
            suffixText: 'min',
          ),
          onSubmitted: (value) {
            final minutes = int.tryParse(value);
            if (minutes != null && minutes > 0 && minutes <= 180) {
              setState(() {
                _selectedPreset = minutes;
                _secondsRemaining = minutes * 60;
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text);
              if (minutes != null && minutes > 0 && minutes <= 180) {
                setState(() {
                  _selectedPreset = minutes;
                  _secondsRemaining = minutes * 60;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid time (1-180 minutes)'),
                  ),
                );
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Focus Session Complete!'),
        content: const Text('Great work! Take a short break.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_selectedPreset * 60 - _secondsRemaining) / (_selectedPreset * 60);

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Text(
            'Focus Timer',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppTheme.stoneGrey,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          
          // Circular timer display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.sage.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isRunning ? AppTheme.softBlue : AppTheme.forestGreen,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: AppTheme.stoneGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                  ),
                  Text(
                    _isRunning ? 'In Progress' : 'Ready',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.sage,
                        ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Preset buttons
          if (!_isRunning) ...[
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ..._presetMinutes.map((minutes) {
                  final isSelected = minutes == _selectedPreset;
                  return ChoiceChip(
                    label: Text('${minutes}m'),
                    selected: isSelected,
                    onSelected: (_) => _setPreset(minutes),
                    selectedColor: AppTheme.softBlue,
                    backgroundColor: AppTheme.calmSand,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.stoneGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
                // Custom time button
                ActionChip(
                  label: const Icon(Icons.edit, size: 18),
                  tooltip: 'Custom time',
                  onPressed: _showCustomTimeDialog,
                  backgroundColor: AppTheme.sage,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: _stopTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
