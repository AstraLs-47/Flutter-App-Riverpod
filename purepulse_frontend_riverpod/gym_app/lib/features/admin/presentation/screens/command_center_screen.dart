// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/graph_transformers.dart';
import '../../../../core/widgets/graphs/bar_graph_widget.dart';
import '../../../../core/widgets/graphs/graph_container.dart';
import '../../../../core/widgets/graphs/line_graph_widget.dart';
import '../../../../core/widgets/graphs/pie_chart_widget.dart';
import '../../data/admin_service.dart';
import '../widgets/admin_bottom_nav.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  final AdminService _adminService = AdminService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminService.fetchDashboardStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh stats whenever we navigate back to this screen
    _refreshStats();
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _adminService.fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Command Center',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: _refreshStats,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  context.goNamed(RouteConstants.signInName);
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshStats();
          await _statsFuture;
        },
        color: AppColors.primary,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final stats = snapshot.data!;
            final totalProducts = stats['totalProducts'] as int;
            final avgBmi = stats['avgBmi'] as double;
            final avgHr = stats['avgHr'] as double;
            final workoutsLogged = stats['totalActivities'] as int;
            final announcementsCount = stats['announcementsCount'] as int;

            final categoryData =
                stats['categoryDistribution'] as Map<String, double>;
            final productDistribution =
                stats['productDistribution'] as Map<String, double>;
            final engagementData = stats['engagementData'] as List<double>;

            return SafeArea(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(workoutsLogged, avgBmi, avgHr),
                      const SizedBox(height: 20),
                      _buildStatsGrid(
                        totalProducts,
                        workoutsLogged,
                        announcementsCount,
                      ),
                      const SizedBox(height: 20),
                      GraphContainer(
                        title: 'User Activity',
                        trailing: const Icon(
                          Icons.note_alt_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        child: LineGraphWidget(
                          datasets: [
                            GraphTransformers.adminUserEngagement(
                              engagementData,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GraphContainer(
                        title: 'By Category',
                        trailing: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        child: PieChartWidget(
                          dataset: GraphTransformers.adminCategoryDistribution(
                            categoryData,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GraphContainer(
                        title: 'Products by Type',
                        trailing: const Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        child: BarGraphWidget(
                          dataset: GraphTransformers.adminProductsByType(
                            productDistribution.values.toList(),
                            productDistribution.keys.toList(),
                          ),
                          height: 280,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 12),
                      _buildRecentActivity(stats['recentActivities']),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard(int workouts, double bmi, double hr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWelcomeStat('This Week', '$workouts', 'workouts logged'),
              _buildWelcomeStat(
                'Avg BMI',
                bmi.toStringAsFixed(1),
                'across users',
              ),
              _buildWelcomeStat('Avg HR', hr.toInt().toString(), 'bpm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String label, String value, String subLabel) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int products, int workouts, int announcements) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridStatCard(
                Icons.sync_alt,
                '$workouts',
                'ACTIVITIES',
                '+12%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGridStatCard(
                Icons.all_inbox,
                '$products',
                'PRODUCTS',
                '+5%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGridStatCard(
                Icons.campaign_outlined,
                '$announcements',
                'NEWS',
                '+2%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGridStatCard(
                Icons.timeline,
                '$workouts',
                'WORKOUTS LOGGED',
                '+15%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridStatCard(
    IconData icon,
    String value,
    String label,
    String percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentage,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<dynamic> recentActivities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...recentActivities.map(
          (activity) => _buildActivityItem(activity as Map<String, dynamic>),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? 'Activity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  activity['subtitle'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
