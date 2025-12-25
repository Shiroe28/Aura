import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/todos_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goals_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/todo_card.dart';
import '../../widgets/reflection_card.dart';
import '../../widgets/stats_dashboard.dart';
import '../../widgets/focus_timer.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodosProvider>(context, listen: false).loadTodayTodos();
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: _todoController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What needs to be done?',
          ),
          onSubmitted: (_) => _addTodo(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _todoController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTodo() {
    if (_todoController.text.trim().isNotEmpty) {
      Provider.of<TodosProvider>(context, listen: false)
          .createTodo(_todoController.text.trim());
      Navigator.pop(context);
      _todoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosProvider = Provider.of<TodosProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final goalsProvider = Provider.of<GoalsProvider>(context);

    // Calculate stats for dashboard
    final activeGoals = goalsProvider.goals.where((g) => !g.isCompleted).length;
    final maxStreak = goalsProvider.goals.isEmpty
        ? 0
        : goalsProvider.goals
            .map((g) => g.streakCount)
            .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => todosProvider.loadTodayTodos(),
        child: todosProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // Stats Dashboard
                    StatsDashboard(
                      streakDays: maxStreak,
                      completionPercentage: todosProvider.completionPercentage,
                      activeGoals: activeGoals,
                    ),
                    const SizedBox(height: 24),

                    // Progress Indicator
                    if (todosProvider.todos.isNotEmpty)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: todosProvider.completionPercentage / 100,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.softBlue,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${todosProvider.completionPercentage}% Complete',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Morning Intention
                    ReflectionCard(
                      title: '🌅 Morning Intention',
                      hint: 'What do you want to focus on today?',
                      initialValue: todosProvider.todayReflection?.morningIntention,
                      onSave: (value) {
                        todosProvider.updateMorningIntention(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Todo List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: _showAddTodoDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (todosProvider.todos.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todosProvider.todos.length,
                        itemBuilder: (context, index) {
                          final todo = todosProvider.todos[index];
                          return TodoCard(
                            todo: todo,
                            onToggle: (value) {
                              todosProvider.toggleTodo(todo.id, value);
                            },
                            onDelete: () {
                              todosProvider.deleteTodo(todo.id);
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Evening Reflection
                    ReflectionCard(
                      title: '🌙 Evening Reflection',
                      hint: 'What went well today? What did you learn?',
                      initialValue: todosProvider.todayReflection?.eveningReflection,
                      onSave: (value) {
                        todosProvider.updateEveningReflection(value);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Focus Timer
                    const FocusTimer(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
