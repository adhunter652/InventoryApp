import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';
import '../../models/activity.dart';
import '../../services/local_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Goal> _goals = [];
  List<Activity> _recentActivities = [];
  bool _isLoading = true;

  final LocalStorageService _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await _localStorage.getGoals();
      final allActivities = await _localStorage.getActivities();

      // Get recent activities (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentActivities =
          allActivities
              .where((activity) => activity.date.isAfter(sevenDaysAgo))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _goals = goals;
        _recentActivities = recentActivities
            .take(5)
            .toList(); // Show only 5 most recent
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getCompletedGoalsCount() {
    return _goals.where((goal) => goal.isCompleted).length;
  }

  int _getTotalProgress() {
    if (_goals.isEmpty) return 0;
    final totalProgress = _goals.fold<int>(
      0,
      (sum, goal) => sum + goal.progress,
    );
    return totalProgress ~/ _goals.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),

                    // Stats Cards
                    _buildStatsSection(),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActionsSection(),
                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildRecentActivitiesSection(),
                    const SizedBox(height: 24),

                    // Active Goals
                    _buildActiveGoalsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Your Goal Tracker!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep track of your progress and stay motivated on your journey to success.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final completedGoals = _getCompletedGoalsCount();
    final totalProgress = _getTotalProgress();
    final todayActivities = _recentActivities
        .where((activity) => activity.date.day == DateTime.now().day)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Goals',
            '${completedGoals}/${_goals.length}',
            'Completed',
            Icons.flag,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Progress',
            '$totalProgress%',
            'Average',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Today',
            '$todayActivities',
            'Activities',
            Icons.today,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add-goal'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Goal'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/add-activity'),
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add Activity'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildRecentActivitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/activities'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No recent activities',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: _recentActivities.map((activity) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(activity.category),
                      child: Text(
                        activity.title[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(activity.title),
                    subtitle: Text(
                      '${DateFormat('MMM dd').format(activity.date)} • ${activity.category}',
                    ),
                    trailing: activity.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.pending, color: Colors.orange),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGoalsSection() {
    final activeGoals = _goals.where((goal) => !goal.isCompleted).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Goals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/goals'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeGoals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No active goals',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: activeGoals.take(3).map((goal) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(goal.category),
                      child: Text(
                        goal.title[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(goal.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.category),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: goal.progress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(goal.category),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${goal.progress}% complete'),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Colors.red;
      case 'work':
        return Colors.blue;
      case 'learning':
        return Colors.green;
      case 'personal':
        return Colors.purple;
      case 'health':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

