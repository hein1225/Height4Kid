import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储工具类
/// 用于加密存储敏感信息（密码、Token等）
/// 使用 flutter_secure_storage 库，数据存储在 Keychain(iOS) 或 Keystore(Android)
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accountName: 'height4kid_secure_storage',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ==================== WebDAV ====================
  static const String _webdavPasswordKey = 'webdav_password';

  static Future<void> saveWebDAVPassword(String password) async {
    await _storage.write(key: _webdavPasswordKey, value: password);
  }

  static Future<String?> getWebDAVPassword() async {
    return await _storage.read(key: _webdavPasswordKey);
  }

  static Future<void> deleteWebDAVPassword() async {
    await _storage.delete(key: _webdavPasswordKey);
  }

  // ==================== Nextcloud ====================
  static const String _nextcloudPasswordKey = 'nextcloud_password';

  static Future<void> saveNextcloudPassword(String password) async {
    await _storage.write(key: _nextcloudPasswordKey, value: password);
  }

  static Future<String?> getNextcloudPassword() async {
    return await _storage.read(key: _nextcloudPasswordKey);
  }

  static Future<void> deleteNextcloudPassword() async {
    await _storage.delete(key: _nextcloudPasswordKey);
  }

  // ==================== BoxSync ====================
  static const String _boxsyncPasswordKey = 'boxsync_password';
  static const String _boxsyncTokenKey = 'boxsync_token';

  static Future<void> saveBoxSyncPassword(String password) async {
    await _storage.write(key: _boxsyncPasswordKey, value: password);
  }

  static Future<String?> getBoxSyncPassword() async {
    return await _storage.read(key: _boxsyncPasswordKey);
  }

  static Future<void> deleteBoxSyncPassword() async {
    await _storage.delete(key: _boxsyncPasswordKey);
  }

  static Future<void> saveBoxSyncToken(String token) async {
    await _storage.write(key: _boxsyncTokenKey, value: token);
  }

  static Future<String?> getBoxSyncToken() async {
    return await _storage.read(key: _boxsyncTokenKey);
  }

  static Future<void> deleteBoxSyncToken() async {
    await _storage.delete(key: _boxsyncTokenKey);
  }

  // ==================== BoxSync Public ====================
  static const String _boxsyncPublicPasswordKey = 'boxsync_public_password';
  static const String _boxsyncPublicTokenKey = 'boxsync_public_token';

  static Future<void> saveBoxSyncPublicPassword(String password) async {
    await _storage.write(key: _boxsyncPublicPasswordKey, value: password);
  }

  static Future<String?> getBoxSyncPublicPassword() async {
    return await _storage.read(key: _boxsyncPublicPasswordKey);
  }

  static Future<void> deleteBoxSyncPublicPassword() async {
    await _storage.delete(key: _boxsyncPublicPasswordKey);
  }

  static Future<void> saveBoxSyncPublicToken(String token) async {
    await _storage.write(key: _boxsyncPublicTokenKey, value: token);
  }

  static Future<String?> getBoxSyncPublicToken() async {
    return await _storage.read(key: _boxsyncPublicTokenKey);
  }

  static Future<void> deleteBoxSyncPublicToken() async {
    await _storage.delete(key: _boxsyncPublicTokenKey);
  }

  // ==================== 通用方法 ====================
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
