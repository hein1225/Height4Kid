import '../models/sync_config.dart';
import 'sync_service.dart';
import 'webdav_sync_service.dart';

/// Nextcloud 同步服务实现
/// Nextcloud 底层基于 WebDAV 协议，复用 WebDAV 同步引擎
class NextcloudSyncService implements SyncService {
  final NextcloudConfig config;
  late final WebDAVSyncService _webdavService;

  NextcloudSyncService({required this.config}) {
    // 将 Nextcloud 配置转换为 WebDAV 配置
    final webdavConfig = WebDAVConfig(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
      remotePath: config.remotePath,
      enabled: config.enabled,
      lastSyncTime: config.lastSyncTime,
      lastSyncStatus: config.lastSyncStatus,
    );
    _webdavService = WebDAVSyncService(config: webdavConfig);
  }

  @override
  SyncServiceType get serviceType => SyncServiceType.nextcloud;

  @override
  String get serviceName => 'Nextcloud';

  @override
  bool get isConfigured => config.isConfigured;

  @override
  Future<SyncResult> testConnection() async {
    // Nextcloud 特定的连接测试，可以添加额外的验证
    final result = await _webdavService.testConnection();

    if (result.success) {
      // 可以尝试获取 Nextcloud 特定信息
      // 例如检查服务器是否为 Nextcloud
      return SyncResult.success(
        message: 'Nextcloud 连接成功',
        syncTime: result.syncTime,
      );
    }

    return result;
  }

  @override
  Future<SyncResult> uploadData(String data, String filename) {
    return _webdavService.uploadData(data, filename);
  }

  @override
  Future<String?> downloadData(String filename) {
    return _webdavService.downloadData(filename);
  }

  @override
  Future<CloudFileInfo?> getFileInfo(String filename) {
    return _webdavService.getFileInfo(filename);
  }

  @override
  Future<List<CloudFileInfo>> listFiles(String directory) {
    return _webdavService.listFiles(directory);
  }

  @override
  Future<SyncResult> deleteFile(String filename) {
    return _webdavService.deleteFile(filename);
  }

  /// 释放资源
  void dispose() {
    _webdavService.dispose();
  }
}
