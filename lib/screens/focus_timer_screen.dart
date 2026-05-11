// نفس كل الـ imports زي ما هي
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planno/models/task.dart';
import 'package:planno/models/focus_session.dart';
import 'package:planno/viewmodels/focus_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import 'task_home_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import '../widgets/set_focus_time_modal.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const Color primaryAction = Color(0xFF1E293B);

  int _selectedMinutes = 25;
  int _secondsLeft = 25 * 60;
  int get _initialSeconds => _selectedMinutes * 60;
  Timer? _timer;
  bool _isActive = false;
  bool _isCompleted = false;
  DateTime? _startTime;

  bool get isTimerRunning => _isActive && _secondsLeft > 0;

  void _setMinutes(int minutes) {
    if (_isActive) return;
    setState(() {
      _selectedMinutes = minutes;
      _secondsLeft = minutes * 60;
      _isCompleted = false;
    });
  }

  // Modern focus-time modal (blurred background + Notion/iOS style card)
  void _showCustomTimeDialog() {
    if (_isActive) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: SetFocusTimeModal(
              initialMinutes: _selectedMinutes,
              onConfirm: (minutes) {
                _setMinutes(minutes);
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleTimer() async {
    if (_isActive) {
      final elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsedSeconds >= 60) {
        await Provider.of<FocusViewModel>(
          context,
          listen: false,
        ).addFocusSession(durationSeconds: elapsedSeconds);
        Provider.of<StatsViewModel>(context, listen: false).onNewFocusSession();
      }
      _timer?.cancel();
      _startTime = null;
    } else {
      _startTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _timer?.cancel();
            _isActive = false;
            _isCompleted = true;
            _showCompletionDialog();
          }
        });
      });
    }
    setState(() => _isActive = !_isActive);
  }

  void _resetTimer() async {
    _timer?.cancel();
    if (_initialSeconds >= 60) {
      await Provider.of<FocusViewModel>(
        context,
        listen: false,
      ).addFocusSession(durationSeconds: _initialSeconds);
      Provider.of<StatsViewModel>(context, listen: false).onNewFocusSession();
    }
    setState(() {
      _secondsLeft = _initialSeconds;
      _isActive = false;
      _isCompleted = false;
      _startTime = null;
    });
  }

  void _showCompletionDialog() async {
    await Provider.of<FocusViewModel>(
      context,
      listen: false,
    ).addFocusSession(durationSeconds: _initialSeconds);
    Provider.of<StatsViewModel>(context, listen: false).onNewFocusSession();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Great Job! 🎉'),
          ],
        ),
        content: const Text(
          "You've completed your focus session!\n\nTake a short break before your next session.",
        ),
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

  Future<bool> _onWillPop() async {
    if (isTimerRunning) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Timer Running'),
          content: const Text(
            'Your focus timer is still running. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_initialSeconds - _secondsLeft) / _initialSeconds;

    return PopScope(
      canPop: !isTimerRunning,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && isTimerRunning) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 👈 كل كودك زي ما هو بدون تغيير
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Focus Session',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          _isActive ? 'Stay focused...' : 'Stay productive',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: _showCustomTimeDialog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),

              // 🔥 الدايرة
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: Colors.white,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1 - progress),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOutCubic,
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          color: _isCompleted
                              ? Colors.green
                              : const Color(0xFF1E293B),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: Tween(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _formatTime(_secondsLeft),
                          key: ValueKey(_secondsLeft),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Text(
                        'POMODORO',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main CTA (Start/Pause)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          // Keep exact dominant color, but slightly brighten on hover/pressed.
                          if (states.contains(MaterialState.pressed)) {
                            return primaryAction.withOpacity(0.94);
                          }
                          if (states.contains(MaterialState.hovered)) {
                            return primaryAction.withOpacity(0.96);
                          }
                          return primaryAction;
                        }),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        elevation: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) return 4;
                          return 6;
                        }),
                        shadowColor: MaterialStateProperty.all<Color>(
                          primaryAction.withOpacity(0.35),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.white.withOpacity(0.12),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      // Subtle “glow” via icon/text container
                      icon: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isActive
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.92,
                              end: 1.0,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _isActive ? 'Pause' : 'Start',
                          key: ValueKey<bool>(_isActive),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Don't stop when you're tired. Stop when you're done.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),

        // 🔥🔥🔥 الإضافة الوحيدة
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskDashboard(),
                  ),
                );
              }),
              _buildNavItem(Icons.assignment_outlined, 'Tasks', false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()),
                );
              }),
              _buildNavItem(Icons.timer, 'Focus', true, () {}),
              _buildNavItem(Icons.bar_chart_outlined, 'Stats', false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 دالة البار
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF3B82F6) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
