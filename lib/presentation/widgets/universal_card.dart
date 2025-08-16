import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/goal.dart';
import '../../models/activity.dart';
import 'package:intl/intl.dart';

class UniversalCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UniversalCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildContent(),
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (item is Goal) {
      final goal = item as Goal;
      return Row(
        children: [
          Expanded(
            child: Text(
              goal.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(goal.category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              goal.category,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      );
    } else if (item is Activity) {
      final activity = item as Activity;
      return Row(
        children: [
          Expanded(
            child: Text(
              activity.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(activity.category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activity.category,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent() {
    if (item is Goal) {
      final goal = item as Goal;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${goal.progress}% Complete',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      );
    } else if (item is Activity) {
      final activity = item as Activity;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (activity.duration > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${activity.duration} minutes',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFooter() {
    if (item is Goal) {
      final goal = item as Goal;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Created: ${DateFormat('MMM dd, yyyy').format(goal.createdAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (goal.targetDate != null)
            Text(
              'Target: ${DateFormat('MMM dd, yyyy').format(goal.targetDate!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      );
    } else if (item is Activity) {
      final activity = item as Activity;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(activity.date),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            children: [
              Icon(
                activity.isCompleted ? Icons.check_circle : Icons.pending,
                size: 16,
                color: activity.isCompleted ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                activity.isCompleted ? 'Completed' : 'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: activity.isCompleted ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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
