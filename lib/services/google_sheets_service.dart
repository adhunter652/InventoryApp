import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/goal.dart';
import '../models/activity.dart';

class GoogleSheetsService {
  static const String _baseUrl =
      'https://sheets.googleapis.com/v4/spreadsheets';
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _spreadsheetId = 'YOUR_SPREADSHEET_ID';

  static const String _goalsSheet = 'Goals';
  static const String _activitiesSheet = 'Activities';

  Future<void> addGoal(Goal goal) async {
    try {
      final url =
          '$_baseUrl/$_spreadsheetId/values/$_goalsSheet!A:I:append?valueInputOption=RAW&key=$_apiKey';
      final values = [
        goal.id,
        goal.title,
        goal.description,
        goal.createdAt.toIso8601String(),
        goal.targetDate?.toIso8601String() ?? '',
        goal.category,
        goal.isCompleted ? 'Yes' : 'No',
        goal.progress.toString(),
        goal.notes ?? '',
      ];

      final body = {
        'values': [values],
      };
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add goal: ${response.body}');
      }
    } catch (e) {
      print('Error adding goal to Google Sheets: $e');
      rethrow;
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final url =
          '$_baseUrl/$_spreadsheetId/values/$_activitiesSheet!A:I:append?valueInputOption=RAW&key=$_apiKey';
      final values = [
        activity.id,
        activity.title,
        activity.description,
        activity.date.toIso8601String(),
        activity.goalId,
        activity.duration.toString(),
        activity.category,
        activity.notes ?? '',
        activity.isCompleted ? 'Yes' : 'No',
      ];

      final body = {
        'values': [values],
      };
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add activity: ${response.body}');
      }
    } catch (e) {
      print('Error adding activity to Google Sheets: $e');
      rethrow;
    }
  }

  Future<List<Goal>> getGoals() async {
    try {
      final url =
          '$_baseUrl/$_spreadsheetId/values/$_goalsSheet!A2:I?key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['values'] as List?;

        if (values == null || values.isEmpty) return [];

        return values
            .map(
              (row) => Goal(
                id: row[0],
                title: row[1],
                description: row[2],
                createdAt: DateTime.parse(row[3]),
                targetDate: row[4].isNotEmpty ? DateTime.parse(row[4]) : null,
                category: row[5],
                isCompleted: row[6] == 'Yes',
                progress: int.tryParse(row[7]) ?? 0,
                notes: row[8].isNotEmpty ? row[8] : null,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting goals from Google Sheets: $e');
      return [];
    }
  }

  Future<List<Activity>> getActivities() async {
    try {
      final url =
          '$_baseUrl/$_spreadsheetId/values/$_activitiesSheet!A2:I?key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['values'] as List?;

        if (values == null || values.isEmpty) return [];

        return values
            .map(
              (row) => Activity(
                id: row[0],
                title: row[1],
                description: row[2],
                date: DateTime.parse(row[3]),
                goalId: row[4],
                duration: int.tryParse(row[5]) ?? 0,
                category: row[6],
                notes: row[7].isNotEmpty ? row[7] : null,
                isCompleted: row[8] == 'Yes',
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting activities from Google Sheets: $e');
      return [];
    }
  }
}
