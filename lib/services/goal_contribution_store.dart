import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/goal_contribution_record.dart';

class GoalContributionStore {
  static const _fileName = 'goal_contributions.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<GoalContributionRecord>> loadRecords() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> data = jsonDecode(content);
      return data
          .map((item) =>
              GoalContributionRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecords(List<GoalContributionRecord> records) async {
    try {
      final file = await _getFile();
      final encoded = jsonEncode(records.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    } catch (_) {
      // ignore persistence errors for now
    }
  }
}




