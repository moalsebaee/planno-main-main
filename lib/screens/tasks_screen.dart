import 'package:flutter/material.dart';
import 'package:planno/screens/new_task_screen.dart';
import 'package:provider/provider.dart';
import 'package:planno/models/task.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import 'task_home_screen.dart';
import 'focus_timer_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

// Task model moved to main.dart

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _activeTab = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when navigating back with new tasks
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildBentoStats(),
              const SizedBox(height: 40),
              _buildTaskAccordion(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewTaskScreen()),
          );
          setState(() {});
        },
        backgroundColor: const Color(0xFF0EA5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFormattedDate(),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              "Good Morning,\nMohamed",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none, color: Colors.grey),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoStats() {
    return Column(
      children: [
        // Next Task Spotlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "NEXT TASK",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<TaskViewModel>(
                builder: (context, taskViewModel, child) {
                  final tasks = taskViewModel.todayTasks;
                  if (tasks.isEmpty) {
                    return const Text(
                      "No pending tasks",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  final nextTask = tasks.firstWhere(
                    (t) => !t.isCompleted,
                    orElse: () => Task(
                      id: '',
                      title: "No pending tasks",
                      status: 'pending',
                      progress: 0.0,
                      assignedTo: '',
                      createdAt: DateTime.now(),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextTask.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${nextTask.time} • ${nextTask.category}",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Consumer<TaskViewModel>(
              builder: (context, tasksProvider, child) {
                final remaining = tasksProvider.tasks
                    .where((t) => !t.isCompleted)
                    .length;
                return Expanded(
                  child: _buildSmallStatCard(
                    "REMAINING",
                    '$remaining',
                    "Tasks",
                    Colors.white,
                    Colors.black87,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildEfficiencyCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    String unit,
    Color bg,
    Color text,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: text,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EFFICIENCY",
            style: const TextStyle(
              color: Color(0xFF059669),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<TaskViewModel>(
            builder: (context, tasksProvider, child) {
              final tasks = tasksProvider.tasks;
              final completed = tasks.where((t) => t.isCompleted).length;
              final total = tasks.isEmpty ? 1 : tasks.length;
              return Text(
                '${((completed / total) * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Consumer<TaskViewModel>(
            builder: (context, tasksProvider, child) {
              final tasks = tasksProvider.tasks;
              final completed = tasks.where((t) => t.isCompleted).length;
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: tasks.isEmpty ? 0.0 : completed / tasks.length,
                  backgroundColor: const Color(0xFFD1FAE5),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                  minHeight: 6,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(Task task) {
    Provider.of<TaskViewModel>(
      context,
      listen: false,
    ).toggleTaskStatus(task.id, !task.isCompleted);
    Provider.of<StatsViewModel>(context, listen: false).onTaskChanged();
  }

  Widget _buildTaskAccordion() {
    return Consumer<TaskViewModel>(
      builder: (context, tasksProvider, child) {
        final todayTasks = tasksProvider.todayTasks;
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${todayTasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "${todayTasks.length} Tasks",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: todayTasks
                .map(
                  (task) => _buildTaskCard(
                    task,
                    onToggle: () => _toggleTaskCompletion(task),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, {required VoidCallback onToggle}) {
    Color priorityColor = task.hasIndicator ? Colors.red : Colors.blue;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16, top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            if (task.hasIndicator)
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: task.isCompleted ? Colors.grey : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            if (task.hasIndicator) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted
                          ? Colors.grey
                          : const Color(0xFF1E293B),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.time,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Interactive Checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? Colors.green : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.green
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: task.isCompleted
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
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home", 0),
          _navItem(Icons.assignment_outlined, "Tasks", 1),
          _navItem(Icons.timer_outlined, "Focus", 2),
          _navItem(Icons.bar_chart_outlined, "Stats", 3),
          _navItem(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = index);
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TaskDashboard()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FocusTimerScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StatsScreen()),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
