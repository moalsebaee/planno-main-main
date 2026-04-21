import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planno/models/focus_session.dart';
import '../viewmodels/stats_viewmodel.dart';
import 'task_home_screen.dart';
import 'focus_timer_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<StatsViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TaskDashboard(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Statistics',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Weekly Overview',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'This Week',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ProductivityScoreCard(
                    viewModel: context.watch<StatsViewModel>(),
                  ),
                  const SizedBox(height: 24),
                  WeeklyActivityCard(
                    viewModel: context.watch<StatsViewModel>(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TaskStatusCard(
                          viewModel: context.watch<StatsViewModel>(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            StreamBuilder<List<FocusSession>>(
                              stream: context.read<StatsViewModel>().sessions,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return StatSmallCard(
                                    icon: Icons.access_time,
                                    label: 'Total Focus',
                                    value: '0m',
                                  );
                                }
                                final viewModel = context
                                    .read<StatsViewModel>();
                                viewModel.calculate(snapshot.data!);
                                return StatSmallCard(
                                  icon: Icons.access_time,
                                  label: 'Total Focus',
                                  value: viewModel.formattedTime,
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            StatSmallCard(
                              icon: Icons.task_alt,
                              label: 'Tasks Done',
                              value:
                                  '${context.watch<StatsViewModel>().completedTasks}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _StatsBottomNavBar(),
    );
  }
}

// Update card classes to accept viewModel
class ProductivityScoreCard extends StatelessWidget {
  final StatsViewModel viewModel;
  const ProductivityScoreCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final score = viewModel.productivityScore.round();
    final isExcellent = score >= 80;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0084FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF0084FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isExcellent ? 'EXCELLENT' : 'GOOD',
                    style: TextStyle(
                      color: Color(0xFF0084FF),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Productivity Score',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              Text(
                '${score}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_circle_up,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.weeklyTrend,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' vs last week',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      color: const Color(0xFFF1F5F9),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: viewModel.productivityScore / 100,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      color: const Color(0xFF0084FF),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0084FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF0084FF),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyActivityCard extends StatelessWidget {
  final StatsViewModel viewModel;
  const WeeklyActivityCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final weeklyData = viewModel.weeklyTaskCounts(
      viewModel.taskViewModel.tasks,
    );
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxTasks = weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weekly Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final dayName = days[index];
                final tasks = weeklyData[dayName] ?? 0;
                final heightFraction = maxTasks > 0 ? tasks / maxTasks : 0.0;
                final isMax = tasks == maxTasks;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 39 * heightFraction,
                      child: Container(
                        width: 24,
                        decoration: BoxDecoration(
                          color: isMax
                              ? const Color(0xFF0084FF)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$tasks',
                      style: TextStyle(
                        color: isMax
                            ? const Color(0xFF1E293B)
                            : Colors.grey[400],
                        fontWeight: isMax ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dayName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskStatusCard extends StatelessWidget {
  final StatsViewModel viewModel;
  const TaskStatusCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final total = viewModel.totalTasks;
    final doneRatio = total > 0 ? viewModel.completedTasks / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 10,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: doneRatio,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        color: const Color(0xFF0084FF),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF0084FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Done',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Left',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatSmallCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const StatSmallCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatsBottomNavBar extends StatelessWidget {
  const _StatsBottomNavBar({super.key});

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
          _buildNavItem(context, Icons.home_filled, 'Home', false, 0),
          _buildNavItem(context, Icons.assignment_outlined, 'Tasks', false, 1),
          _buildNavItem(context, Icons.timer_outlined, 'Focus', false, 2),
          _buildNavItem(context, Icons.bar_chart_outlined, 'Stats', true, 3),
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
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TaskDashboard()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TasksScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FocusTimerScreen()),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
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
