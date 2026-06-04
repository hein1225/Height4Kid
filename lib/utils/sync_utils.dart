import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/sync_config.dart';
import '../services/sync_service.dart';

/// 同步工具类
class SyncUtils {
  /// 云端版本文件名格式
  static const String cloudFileNameV1 = 'height4kid_sync_v1.json';
  static const String cloudFileNameV2 = 'height4kid_sync_v2.json';
  static const String cloudFileNameV3 = 'height4kid_sync_v3.json';

  /// 获取所有云端版本文件名
  static List<String> get cloudFileNames => [
        cloudFileNameV1,
        cloudFileNameV2,
        cloudFileNameV3,
      ];

  /// 生成带时间戳的本地备份文件名
  static String generateBackupFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'height4kid_backup_$timestamp.json';
  }

  /// 比较两个同步时间戳
  /// 返回值：
  /// - 正数：local 更新
  /// - 负数：remote 更新
  /// - 0：相同或无法比较
  static int compareSyncTime(DateTime? localTime, DateTime? remoteTime) {
    if (localTime == null && remoteTime == null) return 0;
    if (localTime == null) return -1;
    if (remoteTime == null) return 1;
    return localTime.compareTo(remoteTime);
  }

  /// 判断是否需要同步（基于最后修改时间）
  static bool needSync(DateTime? localTime, DateTime? remoteTime) {
    return compareSyncTime(localTime, remoteTime) != 0;
  }

  /// 格式化同步时间显示
  static String formatSyncTime(DateTime? time) {
    if (time == null) return '从未同步';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// 带重试机制的同步操作
  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    List<int> retryDelays = const [5, 15, 45], // 秒
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        // 检查是否应该重试
        if (shouldRetry != null && e is Exception && !shouldRetry(e)) {
          rethrow;
        }

        // 等待后重试
        final delaySeconds = retryDelays[min(attempts - 1, retryDelays.length - 1)];
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    throw Exception('重试次数已用完');
  }

  /// 检查是否为网络错误（应该重试）
  static bool isNetworkError(Exception e) {
    final errorString = e.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('unreachable');
  }

  /// 检查是否为认证错误（不应该重试）
  static bool isAuthError(Exception e) {
    final errorString = e.toString().toLowerCase();
    return errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('401') ||
        errorString.contains('403');
  }

  /// 合并本地和云端数据（最后修改时间优先策略）
  /// 返回合并后的数据和冲突信息
  static Map<String, dynamic> mergeData({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> cloudData,
    required DateTime? localSyncTime,
    required DateTime? cloudSyncTime,
  }) {
    // 如果云端数据更新，使用云端数据
    if (cloudSyncTime != null &&
        (localSyncTime == null || cloudSyncTime.isAfter(localSyncTime))) {
      return cloudData;
    }

    // 如果本地数据更新，使用本地数据
    if (localSyncTime != null &&
        (cloudSyncTime == null || localSyncTime.isAfter(cloudSyncTime))) {
      return localData;
    }

    // 如果时间相同，使用本地数据（避免不必要的覆盖）
    return localData;
  }

  /// 检测数据冲突
  /// 返回冲突的字段列表
  static List<String> detectConflicts({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> cloudData,
    required DateTime? localSyncTime,
    required DateTime? cloudSyncTime,
  }) {
    final conflicts = <String>[];

    // 如果一方没有同步时间，认为没有冲突
    if (localSyncTime == null || cloudSyncTime == null) {
      return conflicts;
    }

    // 如果时间差在1秒内，认为可能冲突
    final timeDiff = localSyncTime.difference(cloudSyncTime).abs();
    if (timeDiff.inSeconds > 1) {
      return conflicts;
    }

    // 比较关键字段
    final keysToCheck = ['kids', 'records'];
    for (final key in keysToCheck) {
      final localValue = jsonEncode(localData[key]);
      final cloudValue = jsonEncode(cloudData[key]);
      if (localValue != cloudValue) {
        conflicts.add(key);
      }
    }

    return conflicts;
  }

  /// 创建同步日志
  static SyncLogEntry createLogEntry({
    required SyncServiceType service,
    required SyncStatus status,
    required String message,
    String? details,
  }) {
    return SyncLogEntry(
      timestamp: DateTime.now(),
      service: service,
      status: status,
      message: message,
      details: details,
    );
  }

  /// 验证备份数据格式
  static bool validateBackupData(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 检查必要字段
      if (!data.containsKey('kids')) return false;
      if (!data.containsKey('records')) return false;

      // 检查 kids 是否为列表
      final kids = data['kids'];
      if (kids is! List) return false;

      // 检查 records 是否为 Map
      final records = data['records'];
      if (records is! Map) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 从备份数据中提取同步时间
  static DateTime? extractSyncTime(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 尝试获取 exportTime
      if (data.containsKey('exportTime')) {
        return DateTime.tryParse(data['exportTime'] as String);
      }

      // 尝试获取 lastSyncTime
      if (data.containsKey('lastSyncTime')) {
        return DateTime.tryParse(data['lastSyncTime'] as String);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取下一个云端版本文件名（轮询策略）
  static String getNextVersionFileName(List<String> existingFiles) {
    final files = cloudFileNames;

    // 找到第一个不存在的版本
    for (final file in files) {
      if (!existingFiles.contains(file)) {
        return file;
      }
    }

    // 如果都存在，返回第一个（最旧的）
    return files.first;
  }

  /// 解析云端版本文件列表
  static List<CloudVersionInfo> parseCloudVersions(
    List<CloudFileInfo> files, {
    String? latestVersion,
  }) {
    final versions = <CloudVersionInfo>[];

    for (final file in files) {
      // 检查是否是有效的版本文件
      final versionMatch = RegExp(r'height4kid_sync_v(\d+)\.json')
          .firstMatch(file.path);
      if (versionMatch == null) continue;

      final version = versionMatch.group(1)!;
      versions.add(CloudVersionInfo(
        version: version,
        syncTime: file.modifiedTime ?? DateTime.now(),
        dataSize: file.size ?? 0,
        isLatest: file.path.contains(latestVersion ?? ''),
      ));
    }

    // 按版本号排序
    versions.sort((a, b) => a.version.compareTo(b.version));

    return versions;
  }
}
