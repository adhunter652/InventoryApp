import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../models/goal.dart';
import '../../services/local_storage_service.dart';
import '../widgets/universal_card.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  List<Goal> _goals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGoalId = 'All';
  DateTime? _selectedDate;

  final LocalStorageService _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activities = await _localStorage.getActivities();
      final goals = await _localStorage.getGoals();

      setState(() {
        _activities = activities;
        _goals = goals;
        _filterActivities();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading activities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterActivities() {
    _filteredActivities = _activities.where((activity) {
      final matchesSearch =
          activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesGoal =
          _selectedGoalId == 'All' || activity.goalId == _selectedGoalId;
      final matchesDate =
          _selectedDate == null ||
          (activity.date.year == _selectedDate!.year &&
              activity.date.month == _selectedDate!.month &&
              activity.date.day == _selectedDate!.day);
      return matchesSearch && matchesGoal && matchesDate;
    }).toList();

    // Sort by date (newest first)
    _filteredActivities.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterActivities();
      });
    }
  }

  Future<void> _deleteActivity(Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _localStorage.deleteActivity(activity.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting activity: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showActivityDetails(Activity activity) {
    final goal = _goals.firstWhere(
      (g) => g.id == activity.goalId,
      orElse: () => Goal(
        id: 'unknown',
        title: 'Unknown Goal',
        description: 'Goal not found',
        createdAt: DateTime.now(),
        category: 'Unknown',
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${activity.description}'),
              const SizedBox(height: 8),
              Text('Goal: ${goal.title}'),
              const SizedBox(height: 8),
              Text('Category: ${activity.category}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(activity.date)}'),
              if (activity.duration > 0) ...[
                const SizedBox(height: 8),
                Text('Duration: ${activity.duration} minutes'),
              ],
              const SizedBox(height: 8),
              Text('Status: ${activity.isCompleted ? 'Completed' : 'Pending'}'),
              if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${activity.notes}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedGoalId = 'All';
      _selectedDate = null;
      _filterActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search activities...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterActivities();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filters Row
                Row(
                  children: [
                    // Goal Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGoalId,
                        decoration: const InputDecoration(
                          labelText: 'Goal',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'All',
                            child: Text('All Goals'),
                          ),
                          ..._goals.map((Goal goal) {
                            return DropdownMenuItem<String>(
                              value: goal.id,
                              child: Text(goal.title),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGoalId = newValue!;
                            _filterActivities();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date Filter
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'All Dates'
                                    : DateFormat(
                                        'MMM dd',
                                      ).format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey[600]
                                      : null,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Clear Filters Button
                if (_searchQuery.isNotEmpty ||
                    _selectedGoalId != 'All' ||
                    _selectedDate != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Activities List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActivities.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Add your first activity to get started!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _filteredActivities[index];
                      return UniversalCard(
                        item: activity,
                        onTap: () => _showActivityDetails(activity),
                        onDelete: () => _deleteActivity(activity),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-activity');
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

