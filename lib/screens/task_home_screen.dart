import 'package:flutter/material.dart';
import 'package:planno/screens/new_task_screen.dart';
import 'package:provider/provider.dart';

import 'package:planno/viewmodels/profile_viewmodel.dart';
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

  String getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 11) return 'Good Morning';
    if (hour >= 12 && hour <= 16) return 'Good Afternoon';
    if (hour >= 17 && hour <= 23) return 'Good Evening';
    return 'Good Night';
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
    if (percentage == 100) return 'All tasks completed! \u{1F389}';
    if (percentage >= 81) return 'Amazing work! Finish strong \u{1F4AF}';
    if (percentage >= 51) return "Great job! You're more than halfway \u{1F525}";
    if (percentage >= 21) return 'Good progress, keep going \u{1F680}';
    return "Let's get started \u{1F4AA}";
  }

  String _getSecondaryMessage(double progress) {
    final percentage = (progress * 100).round();
    if (percentage == 100) return "You crushed today's goals \u{1F44F}";
    if (percentage >= 81) return 'One last push!';
    if (percentage >= 51) return 'Stay focused, almost there!';
    if (percentage >= 21) return "You're building momentum!";
    return 'Every step counts!';
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tue, Oct 24',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Consumer<ProfileViewModel>(
                                builder: (context, profileViewModel, child) {
                                  final rawName =
                                      profileViewModel.user?.name?.trim();
                                  final safeName =
                                      (rawName == null || rawName.isEmpty)
                                          ? 'User'
                                          : rawName;
                                  final greeting = getGreetingByTime();
                                  return Text(
                                    '$greeting,\n$safeName',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                      color: Color(0xFF1E293B),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              final pendingTasks = taskViewModel
                                  .getPendingTasks();
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (sheetContext) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        Navigator.of(sheetContext).pop(),
                                    child: SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          0,
                                          20,
                                          16,
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x1A000000),
                                                    blurRadius: 20,
                                                    offset: Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Notifications',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                            0xFF1E293B,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFF1F5F9,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            999,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          '${pendingTasks.length}',
                                                          style: const TextStyle(
                                                            color: Color(
                                                              0xFF64748B,
                                                            ),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  if (pendingTasks.isEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 28,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'No pending tasks 🎉',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFF94A3B8,
                                                            ),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    ...pendingTasks.map((t) {
                                                      final deadline = t.deadline;
                                                      final timeText =
                                                          deadline == null
                                                              ? ''
                                                              : '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
                                                      final dateText =
                                                          deadline == null
                                                              ? ''
                                                              : '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
                                                      final whenText =
                                                          deadline == null
                                                              ? ''
                                                              : '$dateText  •  $timeText';

                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10),
                                                        padding:
                                                            const EdgeInsets.all(
                                                          12,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFF8FAFC,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            16,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 10,
                                                              height: 10,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                  0xFFEF4444,
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    t.title,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: const Color(
                                                                        0xFF1E293B,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (whenText
                                                                      .isNotEmpty)
                                                                    ...[
                                                                      const SizedBox(
                                                                        height: 6,
                                                                      ),
                                                                      Text(
                                                                        whenText,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Color(
                                                                            0xFF94A3B8,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: const Color(
                                                                  0xFFFFF2F2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  999,
                                                                ),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                    0xFFFFCDD2,
                                                                  ),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Pending',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Color(
                                                                    0xFFDC2626,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_none_outlined,
                                    size: 28,
                                    color: Color(0xFF64748B),
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: taskViewModel
                                            .getPendingTasks()
                                            .isEmpty
                                        ? const SizedBox.shrink()
                                        : Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${taskViewModel.getPendingTasks().length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 7,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
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
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '$totalTasks Tasks',
                              style: const TextStyle(
                                color: Color(0xFF0EA5E9),
                              ),
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
                                  color: Color(0xFFCBD5E1),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No tasks for today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap + to add a new task',
                                  style: TextStyle(color: Color(0xFF94A3B8)),
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
                                  builder: (context) =>
                                      NewTaskScreen(task: entry.value),
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
            backgroundColor: const Color(0xFF475569),
            onPressed: () async {
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewTaskScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, size: 30, color: Colors.white),
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
        ? const Color(0xFF22C55E)
        : percentage >= 50
            ? const Color(0xFF0EA5E9)
            : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
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
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                          color: Color(0xFF94A3B8),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        secondaryMessage,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
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
                  builder: (context, value, child) =>
                      CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFF1F5F9),
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
                    color: Color(0xFF1E293B),
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
          color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
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
                    color: isCompleted
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFEF4444),
                    borderRadius: const BorderRadius.horizontal(
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
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isCompleted
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF1E293B),
                              ),
                              child: Text(title),
                            ),
                          ),
                          const Icon(
                            Icons.more_horiz,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
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
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  categoryIcon,
                                  size: 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
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
                      color: isCompleted
                          ? const Color(0xFF22C55E)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE2E8F0),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_filled, 'Home', true, 0),
          _buildNavItem(
              context, Icons.assignment_outlined, 'Tasks', false, 1),
          _buildNavItem(context, Icons.timer_outlined, 'Focus', false, 2),
          _buildNavItem(
              context, Icons.bar_chart_outlined, 'Stats', false, 3),
          _buildNavItem(
              context, Icons.person_outline, 'Profile', false, 4),
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
              MaterialPageRoute(
                  builder: (context) => const FocusTimerScreen()),
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
          Icon(
            icon,
            color: isActive ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

