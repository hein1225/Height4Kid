import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/child.dart';
import '../models/growth_record.dart';

class AppProvider extends ChangeNotifier {
  List<Child> _kids = [];
  Map<String, List<GrowthRecord>> _records = {};
  String? _currentKidId;
  String _currentTheme = 'pink';
  String _currentPage = 'home';
  String _currentChartType = 'height';
  bool _showFullscreenChart = false;
  bool _isInitialized = false;

  List<Child> get kids => _kids;
  String? get currentKidId => _currentKidId;
  Child? get currentKid => _currentKidId != null && _kids.isNotEmpty
      ? _kids.firstWhere((k) => k.id == _currentKidId, orElse: () => _kids.first)
      : null;
  String get currentTheme => _currentTheme;
  String get currentPage => _currentPage;
  String get currentChartType => _currentChartType;
  bool get showFullscreenChart => _showFullscreenChart;
  bool get isInitialized => _isInitialized;

  List<GrowthRecord> getCurrentKidRecords() {
    if (_currentKidId == null) return [];
    return _records[_currentKidId] ?? [];
  }

  List<GrowthRecord> getSortedRecords() {
    final records = getCurrentKidRecords();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final kidsJson = prefs.getString('kids');
    if (kidsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(kidsJson);
        _kids = list.map((item) => Child.fromJson(item)).toList();
      } catch (_) {}
    }

    _currentKidId = prefs.getString('currentKidId');
    _currentTheme = prefs.getString('currentTheme') ?? 'pink';

    final recordsJson = prefs.getString('records');
    if (recordsJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(recordsJson);
        map.forEach((childId, recordList) {
          _records[childId] = (recordList as List<dynamic>)
              .map((item) => GrowthRecord.fromJson(item))
              .toList();
        });
      } catch (_) {}
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('kids', jsonEncode(_kids.map((k) => k.toJson()).toList()));
    if (_currentKidId != null) {
      await prefs.setString('currentKidId', _currentKidId!);
    }
    await prefs.setString('currentTheme', _currentTheme);

    final recordsToSave = <String, dynamic>{};
    _records.forEach((kidId, recordList) {
      recordsToSave[kidId] = recordList.map((r) => r.toJson()).toList();
    });
    await prefs.setString('records', jsonEncode(recordsToSave));
  }

  void setCurrentKid(String kidId) {
    _currentKidId = kidId;
    final kid = _kids.firstWhere((k) => k.id == kidId, orElse: () => _kids.first);
    _currentTheme = kid.gender == 'girl' ? 'pink' : 'blue';
    _saveData();
    notifyListeners();
  }

  void addKid({required String name, required String birthDate, required String gender, String? avatar}) {
    final kid = Child(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      gender: gender,
      birthday: birthDate,
      avatar: avatar,
      height: 0,
      weight: 0,
    );
    _kids.add(kid);
    if (_kids.length == 1) {
      _currentKidId = kid.id;
      _currentTheme = gender == 'girl' ? 'pink' : 'blue';
    }
    _records[kid.id] = [];
    _saveData();
    notifyListeners();
  }

  void updateKid(Child kid) {
    final index = _kids.indexWhere((k) => k.id == kid.id);
    if (index != -1) {
      _kids[index] = kid;
      if (_currentKidId == kid.id) {
        _currentTheme = kid.gender == 'girl' ? 'pink' : 'blue';
      }
      _saveData();
      notifyListeners();
    }
  }

  void deleteKid(String kidId) {
    _kids.removeWhere((k) => k.id == kidId);
    _records.remove(kidId);

    if (_currentKidId == kidId) {
      _currentKidId = _kids.isNotEmpty ? _kids.first.id : null;
      if (_currentKidId != null) {
        _currentTheme = _kids.first.gender == 'girl' ? 'pink' : 'blue';
      }
    }
    _saveData();
    notifyListeners();
  }

  void addRecord({required String date, required double height, required double weight}) {
    final childId = _currentKidId ?? _kids.first.id;
    if (!_records.containsKey(childId)) {
      _records[childId] = [];
    }
    final record = GrowthRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: childId,
      date: date,
      height: height,
      weight: weight,
    );
    _records[childId]!.insert(0, record);
    _updateKidLatestValues(childId);
    _saveData();
    notifyListeners();
  }

  void updateRecord(String recordId, {required String date, required double height, required double weight}) {
    final childId = _currentKidId;
    if (childId == null || !_records.containsKey(childId)) return;

    final records = _records[childId]!;
    final index = records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      records[index] = records[index].copyWith(
        date: date,
        height: height,
        weight: weight,
      );
      _updateKidLatestValues(childId);
      _saveData();
      notifyListeners();
    }
  }

  void deleteRecord(String recordId) {
    final childId = _currentKidId;
    if (childId == null || !_records.containsKey(childId)) return;

    _records[childId]!.removeWhere((r) => r.id == recordId);
    _updateKidLatestValues(childId);
    _saveData();
    notifyListeners();
  }

  void _updateKidLatestValues(String kidId) {
    final records = _records[kidId] ?? [];
    if (records.isNotEmpty) {
      final latest = records.first;
      final index = _kids.indexWhere((k) => k.id == kidId);
      if (index != -1) {
        _kids[index] = _kids[index].copyWith(
          height: latest.height,
          weight: latest.weight,
        );
      }
    }
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == 'pink' ? 'blue' : 'pink';
    if (_currentKidId != null) {
      final index = _kids.indexWhere((k) => k.id == _currentKidId);
      if (index != -1) {
        _kids[index] = _kids[index].copyWith(
          gender: _currentTheme == 'pink' ? 'girl' : 'boy',
        );
      }
    }
    _saveData();
    notifyListeners();
  }

  void setTheme(String theme) {
    _currentTheme = theme;
    if (_currentKidId != null) {
      final index = _kids.indexWhere((k) => k.id == _currentKidId);
      if (index != -1) {
        _kids[index] = _kids[index].copyWith(
          gender: theme == 'pink' ? 'girl' : 'boy',
        );
      }
    }
    _saveData();
    notifyListeners();
  }

  void setPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void setChartType(String type) {
    _currentChartType = type;
    notifyListeners();
  }

  void toggleFullscreenChart() {
    _showFullscreenChart = !_showFullscreenChart;
    notifyListeners();
  }

  // Export data to JSON file
  Future<String?> exportData() async {
    try {
      final exportData = {
        'version': '1.0.2',
        'exportTime': DateTime.now().toIso8601String(),
        'kids': _kids.map((k) => k.toJson()).toList(),
        'records': _records.map((kidId, records) => 
          MapEntry(kidId, records.map((r) => r.toJson()).toList())
        ),
        'currentKidId': _currentKidId,
        'currentTheme': _currentTheme,
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      if (kDebugMode) {
        print('Export error: $e');
      }
      return null;
    }
  }

  // Import data from JSON string
  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      
      // Validate version (兼容旧数据，version 为 null 也允许导入)
      final version = data['version'] as String?;
      
      // Import kids
      final kidsList = data['kids'] as List<dynamic>?;
      if (kidsList != null) {
        _kids = kidsList.map((item) => Child.fromJson(item)).toList();
      }
      
      // Import records
      final recordsMap = data['records'] as Map<String, dynamic>?;
      if (recordsMap != null) {
        _records = {};
        recordsMap.forEach((kidId, recordsList) {
          if (recordsList is List) {
            _records[kidId] = recordsList
                .map((item) => GrowthRecord.fromJson(item))
                .toList();
          }
        });
      }
      
      // Import current kid ID
      _currentKidId = data['currentKidId'] as String?;
      
      // Import theme
      _currentTheme = data['currentTheme'] as String? ?? 'pink';
      
      // Save to SharedPreferences
      try {
        await _saveData();
      } catch (saveError) {
        if (kDebugMode) {
          print('Save error during import: $saveError');
        }
        // 即使保存失败，数据已加载到内存中，仍然返回成功
        // 但会丢失刷新后的数据，所以提醒用户
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Import error: $e');
      }
      return false;
    }
  }

  void clearAllData() {
    _kids.clear();
    _records.clear();
    _currentKidId = null;
    _saveData();
    notifyListeners();
  }
}
