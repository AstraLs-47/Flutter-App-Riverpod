// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:gym_app/core/constants/route_constants.dart';
import 'package:gym_app/core/utils/navigation_helper.dart';
import 'package:gym_app/core/widgets/user_bottom_nav.dart';
import 'package:gym_app/features/progress/presentation/widgets/health_metrics_tab.dart';
import 'package:gym_app/features/progress/presentation/widgets/record_health_dialog.dart';
import 'package:gym_app/features/workout/data/models/workout_entry_model.dart';
import 'package:gym_app/features/workout/data/workout_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _selectedTab = 0; // 0 for Workout Log, 1 for Health Metrics
  final _workoutService = WorkoutService();
  late Future<List<WorkoutEntry>> _workoutLogsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    setState(() {
      _workoutLogsFuture = _workoutService.fetchWorkoutLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'DAILY ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Tracking',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_selectedTab == 0) {
                        await context.pushNamed(RouteConstants.trackingAddName);
                        _refreshLogs();
                      } else {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => const RecordHealthDialog(),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E6CF2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildToggleSwitch(),
            ),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: _selectedTab == 0
                  ? FutureBuilder<List<WorkoutEntry>>(
                      future: _workoutLogsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final logs = snapshot.data ?? [];
                        return logs.isEmpty
                            ? _buildEmptyWorkoutLog()
                            : _buildProgressList(logs);
                      },
                    )
                  : HealthMetricsTab(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(currentItem: BottomNavItem.tracking),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem('Workout Log', 0),
          _buildToggleItem('Health Metrics', 1),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0E6CF2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0E6CF2).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWorkoutLog() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.whatshot,
                        size: 56,
                        color: Color(0xFF0E6CF2),
                      ),
                    ),
                    const Spacer(flex: 3),
                    const Text(
                      'No entries yet. Start your journey!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Consistency is key. Log your first session today to begin visualizing your progress and performance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          await context.pushNamed(
                            RouteConstants.trackingAddName,
                          );
                          _refreshLogs();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E6CF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor: const Color(
                            0xFF0E6CF2,
                          ).withValues(alpha: 0.4),
                        ),
                        child: const Text(
                          'Log Your First Workout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressList(List<WorkoutEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildProgressItem(entry);
      },
    );
  }

  Widget _buildProgressItem(WorkoutEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 16,
            bottom: 16,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF0E6CF2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 10,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.duration,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () async {
                    await context.pushNamed(
                      RouteConstants.trackingEditName,
                      extra: entry,
                    );
                    _refreshLogs();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () => _showDeleteDialog(entry.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Progress',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove this progress?',
          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final currentContext = context;
                    await _workoutService.deleteWorkout(id);
                    _refreshLogs();
                    if (mounted) {
                      currentContext.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6CF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Color(0xFF4B5563)),
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
