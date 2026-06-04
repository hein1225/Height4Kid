import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/sync_config.dart';
import '../services/sync_service.dart';
import '../services/webdav_sync_service.dart';
import '../services/nextcloud_sync_service.dart';
import '../services/boxsync_sync_service.dart';
import '../services/boxsync_public_sync_service.dart';
import '../utils/sync_utils.dart';
import '../utils/image_compressor.dart';
import '../utils/secure_storage.dart';

class AppProvider extends ChangeNotifier {
  List<Child> _kids = [];
  Map<String, List<GrowthRecord>> _records = {};
  String? _currentKidId;
  String _currentTheme = 'pink';
  String _currentPage = 'home';
  String _currentChartType = 'height';
  bool _showFullscreenChart = false;
  bool _isInitialized = false;

  // 同步配置
  SyncConfig _syncConfig = SyncConfig();
  bool _isSyncing = false;
  List<SyncLogEntry> _syncLogs = [];
  Timer? _syncTimer;

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

  // 同步相关 getter
  SyncConfig get syncConfig => _syncConfig;
  bool get isSyncing => _isSyncing;
  List<SyncLogEntry> get syncLogs => _syncLogs;
  bool get autoSyncEnabled => _syncConfig.autoSyncEnabled;

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

    // 加载同步配置
    final syncConfigJson = prefs.getString('syncConfig');
    if (syncConfigJson != null) {
      try {
        _syncConfig = SyncConfig.fromJsonString(syncConfigJson);
        // 从安全存储加载敏感信息（密码、Token）
        await _loadSecureCredentials();
      } catch (_) {}
    }

    _isInitialized = true;
    notifyListeners();

    // 检查并执行图片压缩迁移（版本更新时）
    await _checkAndMigrateImageCompression();

    // 应用启动后尝试自动同步（如果启用）
    if (_syncConfig.autoSyncEnabled && _syncConfig.hasAnyServiceConfigured) {
      _performAutoSyncOnStartup();
    }
  }

  /// 检查并执行图片压缩迁移
  /// 在版本更新时自动压缩已保存的头像图片
  Future<void> _checkAndMigrateImageCompression() async {
    final prefs = await SharedPreferences.getInstance();
    const String migrationKey = 'image_compression_migrated_v1.1.0';

    // 检查是否已经迁移过
    final bool hasMigrated = prefs.getBool(migrationKey) ?? false;
    if (hasMigrated) {
      return;
    }

    // 检查是否有需要压缩的图片
    final imagesToCompress = <Map<String, dynamic>>[];
    for (final kid in _kids) {
      if (kid.avatar != null && kid.avatar!.isNotEmpty) {
        if (ImageCompressor.needsCompression(kid.avatar!)) {
          imagesToCompress.add({
            'id': kid.id,
            'imageData': kid.avatar!,
          });
        }
      }
    }

    if (imagesToCompress.isEmpty) {
      // 没有需要压缩的图片，标记为已迁移
      await prefs.setBool(migrationKey, true);
      return;
    }

    // 执行批量压缩
    if (kDebugMode) {
      print('开始压缩 ${imagesToCompress.length} 张头像图片...');
    }

    final compressedResults = await ImageCompressor.batchCompress(imagesToCompress);

    // 更新压缩后的图片
    var compressedCount = 0;
    for (final result in compressedResults) {
      final id = result['id'] as String;
      final imageData = result['imageData'] as String;
      final compressed = result['compressed'] as bool;

      if (compressed) {
        final index = _kids.indexWhere((k) => k.id == id);
        if (index != -1) {
          _kids[index] = _kids[index].copyWith(avatar: imageData);
          compressedCount++;
        }
      }
    }

    // 保存更新后的数据
    if (compressedCount > 0) {
      await _saveData();
      notifyListeners();

      if (kDebugMode) {
        print('图片压缩迁移完成: $compressedCount 张图片已压缩');
      }
    }

    // 标记为已迁移
    await prefs.setBool(migrationKey, true);
  }

  /// 从安全存储加载敏感信息
  Future<void> _loadSecureCredentials() async {
    // WebDAV
    final webdavPassword = await SecureStorage.getWebDAVPassword();
    if (webdavPassword != null) {
      _syncConfig = _syncConfig.copyWith(
        webdav: _syncConfig.webdav.copyWith(password: webdavPassword),
      );
    }

    // Nextcloud
    final nextcloudPassword = await SecureStorage.getNextcloudPassword();
    if (nextcloudPassword != null) {
      _syncConfig = _syncConfig.copyWith(
        nextcloud: _syncConfig.nextcloud.copyWith(password: nextcloudPassword),
      );
    }

    // BoxSync
    final boxsyncPassword = await SecureStorage.getBoxSyncPassword();
    final boxsyncToken = await SecureStorage.getBoxSyncToken();
    if (boxsyncPassword != null || boxsyncToken != null) {
      _syncConfig = _syncConfig.copyWith(
        boxsync: _syncConfig.boxsync.copyWith(
          password: boxsyncPassword ?? _syncConfig.boxsync.password,
          token: boxsyncToken ?? _syncConfig.boxsync.token,
        ),
      );
    }

    // BoxSync Public
    final boxsyncPublicPassword = await SecureStorage.getBoxSyncPublicPassword();
    final boxsyncPublicToken = await SecureStorage.getBoxSyncPublicToken();
    if (boxsyncPublicPassword != null || boxsyncPublicToken != null) {
      _syncConfig = _syncConfig.copyWith(
        boxsyncPublic: _syncConfig.boxsyncPublic.copyWith(
          password: boxsyncPublicPassword ?? _syncConfig.boxsyncPublic.password,
          token: boxsyncPublicToken ?? _syncConfig.boxsyncPublic.token,
        ),
      );
    }
  }

  /// 保存敏感信息到安全存储
  Future<void> _saveSecureCredentials() async {
    // WebDAV
    if (_syncConfig.webdav.password.isNotEmpty) {
      await SecureStorage.saveWebDAVPassword(_syncConfig.webdav.password);
    }

    // Nextcloud
    if (_syncConfig.nextcloud.password.isNotEmpty) {
      await SecureStorage.saveNextcloudPassword(_syncConfig.nextcloud.password);
    }

    // BoxSync
    if (_syncConfig.boxsync.password.isNotEmpty) {
      await SecureStorage.saveBoxSyncPassword(_syncConfig.boxsync.password);
    }
    if (_syncConfig.boxsync.token != null && _syncConfig.boxsync.token!.isNotEmpty) {
      await SecureStorage.saveBoxSyncToken(_syncConfig.boxsync.token!);
    }

    // BoxSync Public
    if (_syncConfig.boxsyncPublic.password.isNotEmpty) {
      await SecureStorage.saveBoxSyncPublicPassword(_syncConfig.boxsyncPublic.password);
    }
    if (_syncConfig.boxsyncPublic.token != null && _syncConfig.boxsyncPublic.token!.isNotEmpty) {
      await SecureStorage.saveBoxSyncPublicToken(_syncConfig.boxsyncPublic.token!);
    }
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

  Future<void> _saveSyncConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存敏感信息到安全存储
    await _saveSecureCredentials();

    // 创建不包含敏感信息的配置副本用于存储
    final configForStorage = _syncConfig.copyWith(
      webdav: _syncConfig.webdav.copyWith(password: ''),
      nextcloud: _syncConfig.nextcloud.copyWith(password: ''),
      boxsync: _syncConfig.boxsync.copyWith(password: '', token: null),
      boxsyncPublic: _syncConfig.boxsyncPublic.copyWith(password: '', token: null),
    );

    await prefs.setString('syncConfig', configForStorage.toJsonString());
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

    // 自动同步（如果启用）
    _triggerAutoSync();
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

      // 自动同步（如果启用）
      _triggerAutoSync();
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

    // 自动同步（如果启用）
    _triggerAutoSync();
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

    // 自动同步（如果启用）
    _triggerAutoSync();
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

      // 自动同步（如果启用）
      _triggerAutoSync();
    }
  }

  void deleteRecord(String recordId) {
    final childId = _currentKidId;
    if (childId == null || !_records.containsKey(childId)) return;

    _records[childId]!.removeWhere((r) => r.id == recordId);
    _updateKidLatestValues(childId);
    _saveData();
    notifyListeners();

    // 自动同步（如果启用）
    _triggerAutoSync();
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

  // ==================== 同步配置管理 ====================

  /// 更新同步配置
  Future<void> updateSyncConfig(SyncConfig config) async {
    _syncConfig = config;
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 设置自动同步开关
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _syncConfig = _syncConfig.copyWith(autoSyncEnabled: enabled);
    await _saveSyncConfig();
    notifyListeners();

    // 根据开关状态设置或取消定时同步
    if (enabled && _syncConfig.hasAnyServiceConfigured) {
      // 打开自动同步时，立即执行一次备份同步（上传本地数据）
      _performBackupSync();
      _setupPeriodicSync();
    } else {
      _syncTimer?.cancel();
      _syncTimer = null;
    }
  }

  /// 设置自动同步时间间隔
  Future<void> setAutoSyncInterval(AutoSyncInterval interval) async {
    _syncConfig = _syncConfig.copyWith(autoSyncInterval: interval);
    await _saveSyncConfig();
    notifyListeners();

    // 如果启用了自动同步，重新设置定时器以应用新的间隔
    if (_syncConfig.autoSyncEnabled && _syncConfig.hasAnyServiceConfigured) {
      _setupPeriodicSync();
    }
  }

  /// 更新 WebDAV 配置（启用时会自动禁用其他服务）
  Future<void> updateWebDAVConfig(WebDAVConfig config) async {
    if (config.enabled) {
      // 启用 WebDAV 时，禁用其他云同步服务
      _syncConfig = _syncConfig.copyWith(
        webdav: config,
        nextcloud: _syncConfig.nextcloud.copyWith(enabled: false),
        boxsync: _syncConfig.boxsync.copyWith(enabled: false),
      );
    } else {
      _syncConfig = _syncConfig.copyWith(webdav: config);
    }
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 更新 Nextcloud 配置（启用时会自动禁用其他服务）
  Future<void> updateNextcloudConfig(NextcloudConfig config) async {
    if (config.enabled) {
      // 启用 Nextcloud 时，禁用其他云同步服务
      _syncConfig = _syncConfig.copyWith(
        webdav: _syncConfig.webdav.copyWith(enabled: false),
        nextcloud: config,
        boxsync: _syncConfig.boxsync.copyWith(enabled: false),
      );
    } else {
      _syncConfig = _syncConfig.copyWith(nextcloud: config);
    }
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 更新 BoxSync 配置（启用时会自动禁用其他服务）
  Future<void> updateBoxSyncConfig({
    required String serverUrl,
    required String username,
    required String password,
    bool enabled = true,
  }) async {
    final config = BoxSyncConfig(
      serverUrl: serverUrl,
      username: username,
      password: password,
      enabled: enabled,
    );

    if (config.enabled) {
      // 启用 BoxSync 时，禁用其他云同步服务
      _syncConfig = _syncConfig.copyWith(
        webdav: _syncConfig.webdav.copyWith(enabled: false),
        nextcloud: _syncConfig.nextcloud.copyWith(enabled: false),
        boxsync: config,
      );
    } else {
      _syncConfig = _syncConfig.copyWith(boxsync: config);
    }
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 清除 WebDAV 配置
  Future<void> clearWebDAVConfig() async {
    _syncConfig = _syncConfig.copyWith(
      webdav: WebDAVConfig(),
    );
    await SecureStorage.deleteWebDAVPassword();
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 清除 Nextcloud 配置
  Future<void> clearNextcloudConfig() async {
    _syncConfig = _syncConfig.copyWith(
      nextcloud: NextcloudConfig(),
    );
    await SecureStorage.deleteNextcloudPassword();
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 清除 BoxSync 配置
  Future<void> clearBoxSyncConfig() async {
    _syncConfig = _syncConfig.copyWith(
      boxsync: BoxSyncConfig(),
    );
    await SecureStorage.deleteBoxSyncPassword();
    await SecureStorage.deleteBoxSyncToken();
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 更新 BoxSync 公共服务区配置（启用时会自动禁用其他服务）
  Future<void> updateBoxSyncPublicConfig({
    required String username,
    required String password,
    bool enabled = true,
  }) async {
    final config = BoxSyncPublicConfig(
      username: username,
      password: password,
      enabled: enabled,
    );

    if (config.enabled) {
      // 启用 BoxSync 公共服务区时，禁用其他云同步服务
      _syncConfig = _syncConfig.copyWith(
        webdav: _syncConfig.webdav.copyWith(enabled: false),
        nextcloud: _syncConfig.nextcloud.copyWith(enabled: false),
        boxsync: _syncConfig.boxsync.copyWith(enabled: false),
        boxsyncPublic: config,
      );
    } else {
      _syncConfig = _syncConfig.copyWith(boxsyncPublic: config);
    }
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 清除 BoxSync 公共服务区配置
  Future<void> clearBoxSyncPublicConfig() async {
    _syncConfig = _syncConfig.copyWith(
      boxsyncPublic: BoxSyncPublicConfig(),
    );
    await SecureStorage.deleteBoxSyncPublicPassword();
    await SecureStorage.deleteBoxSyncPublicToken();
    await _saveSyncConfig();
    notifyListeners();
  }

  // ==================== 同步服务创建 ====================

  SyncService? _createSyncService(SyncServiceType type) {
    switch (type) {
      case SyncServiceType.boxsyncPublic:
        if (!_syncConfig.boxsyncPublic.isConfigured) return null;
        return BoxSyncPublicSyncService(config: _syncConfig.boxsyncPublic);
      case SyncServiceType.webdav:
        if (!_syncConfig.webdav.isConfigured) return null;
        return WebDAVSyncService(config: _syncConfig.webdav);
      case SyncServiceType.nextcloud:
        if (!_syncConfig.nextcloud.isConfigured) return null;
        return NextcloudSyncService(config: _syncConfig.nextcloud);
      case SyncServiceType.boxsync:
        if (!_syncConfig.boxsync.isConfigured) return null;
        return BoxSyncSyncService(config: _syncConfig.boxsync);
    }
  }

  // ==================== 自动同步 ====================

  /// 应用启动时自动同步
  Future<void> _performAutoSyncOnStartup() async {
    // 延迟执行，确保应用完全加载
    await Future.delayed(const Duration(seconds: 2));
    await performAutoSync();

    // 如果启用了自动同步，设置定时检查
    if (_syncConfig.autoSyncEnabled) {
      _setupPeriodicSync();
    }
  }

  /// 设置周期性同步检查
  void _setupPeriodicSync() {
    // 取消之前的定时器
    _syncTimer?.cancel();

    // 根据间隔设置定时器
    final duration = _getIntervalDuration(_syncConfig.autoSyncInterval);
    _syncTimer = Timer.periodic(duration, (timer) async {
      await performAutoSync();
    });
  }

  /// 将 AutoSyncInterval 转换为 Duration
  Duration _getIntervalDuration(AutoSyncInterval interval) {
    switch (interval) {
      case AutoSyncInterval.hourly:
        return const Duration(hours: 1);
      case AutoSyncInterval.twoHours:
        return const Duration(hours: 2);
      case AutoSyncInterval.sixHours:
        return const Duration(hours: 6);
      case AutoSyncInterval.twelveHours:
        return const Duration(hours: 12);
      case AutoSyncInterval.daily:
        return const Duration(hours: 24);
    }
  }

  /// 触发自动同步（数据变更时）- 只执行备份（上传）
  Future<void> _triggerAutoSync() async {
    if (!_syncConfig.autoSyncEnabled) return;
    if (_isSyncing) return;

    // 延迟执行，避免频繁同步
    await Future.delayed(const Duration(seconds: 3));
    await _performBackupSync();
  }

  /// 执行备份同步（只上传，不下载）
  Future<void> _performBackupSync() async {
    if (_isSyncing) return;
    if (!_syncConfig.hasAnyServiceConfigured) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final localData = await exportData();
      if (localData == null) {
        print('Backup sync - Failed to export local data');
        return;
      }

      for (final serviceType in _syncConfig.enabledServices) {
        final service = _createSyncService(serviceType);
        if (service == null) continue;

        print('Backup sync - Uploading to $serviceType');
        final result = await _uploadToCloud(service, localData, serviceType);
        print('Backup sync - Upload result: ${result.message}');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 执行自动同步
  Future<void> performAutoSync() async {
    if (_isSyncing) return;
    if (!_syncConfig.hasAnyServiceConfigured) return;

    _isSyncing = true;
    notifyListeners();

    try {
      for (final serviceType in _syncConfig.enabledServices) {
        await _syncWithService(serviceType);
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 与指定服务同步
  Future<SyncResult> _syncWithService(SyncServiceType type) async {
    final service = _createSyncService(type);
    if (service == null) {
      return SyncResult.failure(message: '服务未配置');
    }

    try {
      // 1. 获取云端文件列表
      final cloudFiles = await service.listFiles('');

      // 2. 获取最新的云端文件
      CloudFileInfo? latestCloudFile;
      if (cloudFiles.isNotEmpty) {
        latestCloudFile = cloudFiles.reduce((a, b) {
          final aTime = a.modifiedTime ?? DateTime(1970);
          final bTime = b.modifiedTime ?? DateTime(1970);
          return aTime.isAfter(bTime) ? a : b;
        });
      }

      // 3. 获取本地数据
      final localData = await exportData();
      if (localData == null) {
        return SyncResult.failure(message: '导出本地数据失败');
      }

      final localSyncTime = _getServiceLastSyncTime(type);
      final cloudSyncTime = latestCloudFile?.modifiedTime;

      // 4. 判断同步方向
      final compareResult = SyncUtils.compareSyncTime(localSyncTime, cloudSyncTime);

      if (compareResult > 0) {
        // 本地更新，上传到云端
        return await _uploadToCloud(service, localData, type);
      } else if (compareResult < 0) {
        // 云端更新，下载到本地并自动导入（自动同步场景）
        return await _downloadFromCloud(service, latestCloudFile!.path, type, autoImport: true);
      } else {
        // 时间相同，无需同步
        return SyncResult.success(message: '数据已是最新');
      }
    } catch (e) {
      final logEntry = SyncUtils.createLogEntry(
        service: type,
        status: SyncStatus.failed,
        message: '同步失败',
        details: e.toString(),
      );
      _syncLogs.add(logEntry);

      return SyncResult.failure(
        message: '同步失败：$e',
        details: e.toString(),
      );
    }
  }

  /// 获取服务的最后同步时间
  DateTime? _getServiceLastSyncTime(SyncServiceType type) {
    switch (type) {
      case SyncServiceType.boxsyncPublic:
        return _syncConfig.boxsyncPublic.lastSyncTime;
      case SyncServiceType.webdav:
        return _syncConfig.webdav.lastSyncTime;
      case SyncServiceType.nextcloud:
        return _syncConfig.nextcloud.lastSyncTime;
      case SyncServiceType.boxsync:
        return _syncConfig.boxsync.lastSyncTime;
    }
  }

  /// 更新服务的最后同步时间
  Future<void> _updateServiceLastSyncTime(SyncServiceType type, DateTime time, SyncStatus status) async {
    switch (type) {
      case SyncServiceType.boxsyncPublic:
        _syncConfig = _syncConfig.copyWith(
          boxsyncPublic: _syncConfig.boxsyncPublic.copyWith(lastSyncTime: time, lastSyncStatus: status),
        );
        break;
      case SyncServiceType.webdav:
        _syncConfig = _syncConfig.copyWith(
          webdav: _syncConfig.webdav.copyWith(lastSyncTime: time, lastSyncStatus: status),
        );
        break;
      case SyncServiceType.nextcloud:
        _syncConfig = _syncConfig.copyWith(
          nextcloud: _syncConfig.nextcloud.copyWith(lastSyncTime: time, lastSyncStatus: status),
        );
        break;
      case SyncServiceType.boxsync:
        _syncConfig = _syncConfig.copyWith(
          boxsync: _syncConfig.boxsync.copyWith(lastSyncTime: time, lastSyncStatus: status),
        );
        break;
    }
    await _saveSyncConfig();
    notifyListeners();
  }

  /// 上传数据到云端
  Future<SyncResult> _uploadToCloud(SyncService service, String data, SyncServiceType type) async {
    try {
      // 使用版本轮询策略
      final cloudFiles = await service.listFiles('');
      final existingFiles = cloudFiles.map((f) => f.path).toList();
      final targetFile = SyncUtils.getNextVersionFileName(existingFiles);

      final result = await service.uploadData(data, targetFile);

      if (result.success) {
        await _updateServiceLastSyncTime(type, DateTime.now(), SyncStatus.success);

        final logEntry = SyncUtils.createLogEntry(
          service: type,
          status: SyncStatus.success,
          message: '上传成功',
          details: targetFile,
        );
        _syncLogs.add(logEntry);
      } else {
        await _updateServiceLastSyncTime(type, DateTime.now(), SyncStatus.failed);

        final logEntry = SyncUtils.createLogEntry(
          service: type,
          status: SyncStatus.failed,
          message: '上传失败',
          details: result.message,
        );
        _syncLogs.add(logEntry);
      }

      return result;
    } catch (e) {
      await _updateServiceLastSyncTime(type, DateTime.now(), SyncStatus.failed);
      rethrow;
    }
  }

  /// 从云端下载数据
  /// [autoImport] 是否自动导入数据（自动同步时使用）
  Future<SyncResult> _downloadFromCloud(SyncService service, String filename, SyncServiceType type, {bool autoImport = false}) async {
    try {
      final data = await service.downloadData(filename);
      if (data == null) {
        return SyncResult.failure(message: '下载数据为空');
      }

      // 验证数据格式
      if (!SyncUtils.validateBackupData(data)) {
        return SyncResult.failure(message: '数据格式无效');
      }

      // 如果是自动同步，自动导入数据
      if (autoImport) {
        final importSuccess = await importData(data);
        if (!importSuccess) {
          return SyncResult.failure(message: '数据导入失败');
        }
      }

      await _updateServiceLastSyncTime(type, DateTime.now(), SyncStatus.success);

      final logEntry = SyncUtils.createLogEntry(
        service: type,
        status: SyncStatus.success,
        message: autoImport ? '自动同步成功' : '下载成功',
        details: filename,
      );
      _syncLogs.add(logEntry);

      return SyncResult.success(
        message: autoImport ? '自动同步成功' : '下载成功',
        details: data,
      );
    } catch (e) {
      await _updateServiceLastSyncTime(type, DateTime.now(), SyncStatus.failed);

      final logEntry = SyncUtils.createLogEntry(
        service: type,
        status: SyncStatus.failed,
        message: '下载失败',
        details: e.toString(),
      );
      _syncLogs.add(logEntry);

      return SyncResult.failure(
        message: '下载失败：$e',
        details: e.toString(),
      );
    }
  }

  // ==================== 手动同步 ====================

  /// 手动上传数据到指定服务
  Future<SyncResult> manualUploadToService(SyncServiceType type) async {
    if (_isSyncing) {
      return SyncResult.failure(message: '正在同步中，请稍后再试');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final service = _createSyncService(type);
      if (service == null) {
        return SyncResult.failure(message: '服务未配置');
      }

      final localData = await exportData();
      if (localData == null) {
        return SyncResult.failure(message: '导出本地数据失败');
      }

      return await _uploadToCloud(service, localData, type);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 手动从指定服务下载数据
  Future<SyncResult> manualDownloadFromService(SyncServiceType type) async {
    if (_isSyncing) {
      return SyncResult.failure(message: '正在同步中，请稍后再试');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final service = _createSyncService(type);
      if (service == null) {
        return SyncResult.failure(message: '服务未配置');
      }

      // 获取云端文件列表
      final cloudFiles = await service.listFiles('');
      if (cloudFiles.isEmpty) {
        return SyncResult.failure(message: '云端没有数据');
      }

      // 获取最新的文件
      final latestFile = cloudFiles.reduce((a, b) {
        final aTime = a.modifiedTime ?? DateTime(1970);
        final bTime = b.modifiedTime ?? DateTime(1970);
        return aTime.isAfter(bTime) ? a : b;
      });

      return await _downloadFromCloud(service, latestFile.path, type);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 同步数据到云端（别名方法）
  Future<SyncResult> syncToCloud(SyncServiceType type) async {
    return manualUploadToService(type);
  }

  /// 从云端同步数据（别名方法）
  Future<SyncResult> syncFromCloud(SyncServiceType type) async {
    return manualDownloadFromService(type);
  }

  /// 获取云端版本列表
  Future<List<CloudVersionInfo>> getCloudVersions(SyncServiceType type) async {
    final service = _createSyncService(type);
    if (service == null) return [];

    try {
      final cloudFiles = await service.listFiles('');
      return SyncUtils.parseCloudVersions(cloudFiles);
    } catch (e) {
      return [];
    }
  }

  /// 从云端下载指定版本
  Future<SyncResult> downloadSpecificVersion(SyncServiceType type, String filename) async {
    if (_isSyncing) {
      return SyncResult.failure(message: '正在同步中，请稍后再试');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final service = _createSyncService(type);
      if (service == null) {
        return SyncResult.failure(message: '服务未配置');
      }

      return await _downloadFromCloud(service, filename, type);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 测试服务连接
  Future<SyncResult> testServiceConnection(SyncServiceType type) async {
    final service = _createSyncService(type);
    if (service == null) {
      return SyncResult.failure(message: '服务未配置');
    }

    return await service.testConnection();
  }

  // ==================== 导出导入 ====================

  // Export data to JSON file
  Future<String?> exportData() async {
    try {
      final exportData = {
        'version': '1.1.0',
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

      // 压缩导入的头像图片
      await _compressImportedAvatars();

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

  /// 压缩导入的头像图片
  Future<void> _compressImportedAvatars() async {
    if (_kids.isEmpty) return;

    // 收集需要压缩的图片
    final imagesToCompress = <Map<String, dynamic>>[];
    for (final kid in _kids) {
      if (kid.avatar != null && kid.avatar!.isNotEmpty) {
        if (ImageCompressor.needsCompression(kid.avatar!)) {
          imagesToCompress.add({
            'id': kid.id,
            'imageData': kid.avatar!,
          });
        }
      }
    }

    if (imagesToCompress.isEmpty) return;

    if (kDebugMode) {
      print('导入数据：开始压缩 ${imagesToCompress.length} 张头像图片...');
    }

    // 批量压缩
    final compressedResults = await ImageCompressor.batchCompress(imagesToCompress);

    // 更新压缩后的图片
    var compressedCount = 0;
    for (final result in compressedResults) {
      final id = result['id'] as String;
      final imageData = result['imageData'] as String;
      final compressed = result['compressed'] as bool;

      if (compressed) {
        final index = _kids.indexWhere((k) => k.id == id);
        if (index != -1) {
          _kids[index] = _kids[index].copyWith(avatar: imageData);
          compressedCount++;
        }
      }
    }

    if (kDebugMode && compressedCount > 0) {
      print('导入数据：$compressedCount 张头像图片已压缩');
    }
  }

  void clearAllData() {
    _kids.clear();
    _records.clear();
    _currentKidId = null;

    // 清除同步配置
    _syncConfig = SyncConfig();
    _saveSyncConfig();

    _saveData();
    notifyListeners();
  }

  /// 清除所有数据（包括同步配置）
  Future<void> clearAllDataWithSync() async {
    _kids.clear();
    _records.clear();
    _currentKidId = null;

    // 清除同步配置
    _syncConfig = SyncConfig();
    await _saveSyncConfig();

    await _saveData();
    notifyListeners();
  }
}
