import 'dart:convert';
import '../models/sync_config.dart';

/// 同步结果
class SyncResult {
  final bool success;
  final String message;
  final DateTime? syncTime;
  final String? details;

  SyncResult({
    required this.success,
    required this.message,
    this.syncTime,
    this.details,
  });

  factory SyncResult.success({
    required String message,
    DateTime? syncTime,
    String? details,
  }) {
    return SyncResult(
      success: true,
      message: message,
      syncTime: syncTime ?? DateTime.now(),
      details: details,
    );
  }

  factory SyncResult.failure({
    required String message,
    String? details,
  }) {
    return SyncResult(
      success: false,
      message: message,
      details: details,
    );
  }
}

/// 云端文件信息
class CloudFileInfo {
  final String path;
  final DateTime? modifiedTime;
  final int? size;

  CloudFileInfo({
    required this.path,
    this.modifiedTime,
    this.size,
  });
}

/// 同步服务抽象接口
abstract class SyncService {
  /// 服务类型
  SyncServiceType get serviceType;

  /// 服务名称
  String get serviceName;

  /// 检查服务是否已配置
  bool get isConfigured;

  /// 测试连接
  Future<SyncResult> testConnection();

  /// 上传数据到云端
  /// [data] 要上传的数据（JSON字符串）
  /// [filename] 云端文件名
  Future<SyncResult> uploadData(String data, String filename);

  /// 从云端下载数据
  /// [filename] 云端文件名
  /// 返回下载的数据（JSON字符串），如果文件不存在返回 null
  Future<String?> downloadData(String filename);

  /// 检查云端文件是否存在并获取信息
  /// [filename] 云端文件名
  Future<CloudFileInfo?> getFileInfo(String filename);

  /// 列出云端目录中的文件
  /// [directory] 云端目录路径
  Future<List<CloudFileInfo>> listFiles(String directory);

  /// 删除云端文件
  /// [filename] 云端文件名
  Future<SyncResult> deleteFile(String filename);
}

/// 同步数据包装器
class SyncDataWrapper {
  final String version;
  final DateTime exportTime;
  final DateTime? lastSyncTime;
  final Map<String, dynamic> data;

  SyncDataWrapper({
    required this.version,
    required this.exportTime,
    this.lastSyncTime,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportTime': exportTime.toIso8601String(),
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'data': data,
    };
  }

  factory SyncDataWrapper.fromJson(Map<String, dynamic> json) {
    return SyncDataWrapper(
      version: json['version'] as String,
      exportTime: DateTime.parse(json['exportTime'] as String),
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SyncDataWrapper.fromJsonString(String jsonString) {
    return SyncDataWrapper.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
