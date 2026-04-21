import 'package:flutter/material.dart';
import 'package:planno/screens/new_task_screen.dart';
import 'package:provider/provider.dart';

import '../viewmodels/task_viewmodel.dart';
import 'focus_timer_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

class TaskHomeScreen extends StatelessWidget {
  const TaskHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskDashboard();
  }
}

class TaskDashboard extends StatefulWidget {
  const TaskDashboard({super.key});

  @override
  State<TaskDashboard> createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    if (!mounted) return;
    final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);
    final task = taskViewModel.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );
    await taskViewModel.toggleTaskStatus(taskId, !task.isCompleted);
  }

  String _getMotivationalMessage(double progress) {
    final percentage = (progress * 100).round();
    if (percentage == 100) return r'All tasks completed! 🎉';
    if (percentage >= 81) return r'Amazing work! Finish strong 💯';
    if (percentage >= 51) return r'Great job! You\re more than halfway 🔥';
    if (percentage >= 21) return r'Good progress, keep going 🚀';
    return r'Let\s get started 💪';
  }

  String _getSecondaryMessage(double progress) {
    final percentage = (progress * 100).round();
    if (percentage == 100) return r'You crushed today\s goals 👏';
    if (percentage >= 81) return r'One last push!';
    if (percentage >= 51) return r'Stay focused, almost there!';
    if (percentage >= 21) return r"You're building momentum!";
    return r'Every step counts!';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        final tasks = taskViewModel.tasks;
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((task) => task.isCompleted).length;
        final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        _progressAnimation =
            Tween<double>(begin: _currentProgress, end: progress).animate(
              CurvedAnimation(
                parent: _progressAnimationController,
                curve: Curves.easeInOut,
              ),
            );
        _progressAnimationController.forward(from: 0.0);
        _currentProgress = progress;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F7),
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tue, Oct 24',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Good Morning,\nMohamed',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF000000,
                                  ).withValues(alpha: 13 / 255),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Stack(
                              children: [
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 28,
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      DailyGoalsCard(
                        progress: _progressAnimation.value,
                        completedTasks: completedTasks,
                        totalTasks: totalTasks,
                        motivationalMessage: _getMotivationalMessage(
                          _progressAnimation.value,
                        ),
                        secondaryMessage: _getSecondaryMessage(
                          _progressAnimation.value,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Tasks",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (tasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No tasks for today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap + to add a new task',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...tasks.asMap().entries.map(
                          (entry) => TaskCard(
                            title: entry.value.title,
                            time: entry.value.time,
                            category: entry.value.category,
                            hasIndicator: entry.value.hasIndicator,
                            categoryIcon:
                                entry.value.categoryIcon ?? Icons.task_alt,
                            createdDate: entry.value.createdDate,
                            isCompleted: entry.value.isCompleted,
                            onToggle: () =>
                                _toggleTaskCompletion(entry.value.id),
                            onTap: () async {
                              if (!mounted) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewTaskScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewTaskScreen()),
              );
            },
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          bottomNavigationBar: _HomeBottomNavBar(),
        );
      },
    );
  }
}

class DailyGoalsCard extends StatelessWidget {
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final String motivationalMessage;
  final String secondaryMessage;

  const DailyGoalsCard({
    super.key,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.motivationalMessage,
    required this.secondaryMessage,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final progressColor = percentage == 100
        ? Colors.green
        : percentage >= 50
        ? Colors.blue
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 5 / 255),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Goals',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$completedTasks',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      TextSpan(
                        text: ' / $totalTasks',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(motivationalMessage),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motivationalMessage,
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        secondaryMessage,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$percentage%',
                  key: ValueKey(percentage),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String category;
  final bool hasIndicator;
  final IconData categoryIcon;
  final DateTime createdDate;
  final bool isCompleted;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.time,
    required this.category,
    this.hasIndicator = false,
    required this.categoryIcon,
    required this.createdDate,
    required this.isCompleted,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (hasIndicator)
              Positioned(
                left: -16,
                top: 4,
                bottom: 4,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isCompleted ? Colors.grey : Colors.black,
                              ),
                              child: Text(title),
                            ),
                          ),
                          const Icon(Icons.more_horiz, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  categoryIcon,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              key: ValueKey('checked'),
                              color: Colors.white,
                              size: 18,
                            )
                          : const SizedBox.shrink(key: ValueKey('unchecked')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_filled, 'Home', true, 0),
          _buildNavItem(context, Icons.assignment_outlined, 'Tasks', false, 1),
          _buildNavItem(context, Icons.timer_outlined, 'Focus', false, 2),
          _buildNavItem(context, Icons.bar_chart_outlined, 'Stats', false, 3),
          _buildNavItem(context, Icons.person_outline, 'Profile', false, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TasksScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FocusTimerScreen()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StatsScreen()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
