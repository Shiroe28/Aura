import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todos_provider.dart';
import '../../providers/goals_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_formatter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalsProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todosProvider = Provider.of<TodosProvider>(context, listen: false);
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await goalsProvider.loadGoals();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Achievements Section
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildAchievementsCard(goalsProvider),
              const SizedBox(height: 24),

              // Completed Goals
              Text(
                'Completed Goals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _buildCompletedGoals(goalsProvider),
              const SizedBox(height: 24),

              // Recent Completed Tasks
              Text(
                'Recent Completed Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              FutureBuilder(
                future: todosProvider.loadCompletedTodos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No completed tasks yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    );
                  }

                  final completedTodos = snapshot.data!.take(10).toList();
                  return Column(
                    children: completedTodos.map((todo) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: AppTheme.softBlue,
                          ),
                          title: Text(todo.task),
                          subtitle: Text(
                            'Completed ${DateFormatter.formatRelative(todo.completedAt ?? todo.createdAt)}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(GoalsProvider goalsProvider) {
    final totalGoals = goalsProvider.goals.length;
    final completedGoals =
        goalsProvider.goals.where((g) => g.isCompleted).length;
    final totalProgress = totalGoals > 0
        ? goalsProvider.goals
                .fold<int>(0, (sum, goal) => sum + goal.progress) ~/
            totalGoals
        : 0;
    final maxStreak = goalsProvider.goals.isEmpty
        ? 0
        : goalsProvider.goals
            .map((g) => g.streakCount)
            .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.flag,
                  '$completedGoals/$totalGoals',
                  'Goals Completed',
                ),
                _buildStatItem(
                  context,
                  Icons.trending_up,
                  '$totalProgress%',
                  'Avg Progress',
                ),
                _buildStatItem(
                  context,
                  Icons.local_fire_department,
                  '$maxStreak',
                  'Best Streak',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.softBlue),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletedGoals(GoalsProvider goalsProvider) {
    final completedGoals =
        goalsProvider.goals.where((g) => g.isCompleted).toList();

    if (completedGoals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No completed goals yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Column(
      children: completedGoals.map((goal) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(
              Icons.emoji_events,
              color: AppTheme.softBlue,
              size: 32,
            ),
            title: Text(goal.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal.description != null) Text(goal.description!),
                Text(
                  '${goal.category ?? 'General'} • ${goal.streakCount} day streak',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: const Icon(Icons.check_circle, color: AppTheme.softBlue),
          ),
        );
      }).toList(),
    );
  }
}
