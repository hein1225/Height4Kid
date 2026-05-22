import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool hasUpdate;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.hasUpdate,
  });
}

class UpdateChecker {
  static const String _currentVersion = '1.0.0';
  static const String _githubApiUrl = 'https://api.github.com/repos/hein1225/Height4Kid/releases/latest';
  static const String _lastCheckKey = 'last_update_check';
  static const String _skippedVersionKey = 'skipped_update_version';

  static String get currentVersion => _currentVersion;

  /// 检查更新
  /// [force] 为 true 时忽略时间间隔强制检查
  static Future<UpdateInfo?> checkUpdate({bool force = false}) async {
    try {
      // 如果不是强制检查，检查是否需要检查（每天一次）
      if (!force) {
        final shouldCheck = await _shouldCheckUpdate();
        if (!shouldCheck) return null;
      }

      // 记录检查时间
      await _recordCheckTime();

      // 调用 GitHub API 获取最新 release
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
      final downloadUrl = data['html_url'] as String;
      final releaseNotes = data['body'] as String? ?? '';

      // 比较版本号
      final hasUpdate = _compareVersions(latestVersion, _currentVersion) > 0;

      // 检查用户是否跳过了这个版本
      if (hasUpdate) {
        final skippedVersion = await _getSkippedVersion();
        if (skippedVersion == latestVersion) {
          return UpdateInfo(
            version: latestVersion,
            downloadUrl: downloadUrl,
            releaseNotes: releaseNotes,
            hasUpdate: false,
          );
        }
      }

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      return null;
    }
  }

  /// 比较版本号
  /// 返回：1 表示 v1 > v2，0 表示相等，-1 表示 v1 < v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }

    return parts1.length.compareTo(parts2.length);
  }

  /// 是否应该检查更新（每天一次）
  static Future<bool> _shouldCheckUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);

    if (lastCheck == null) return true;

    final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final now = DateTime.now();

    // 检查是否是同一天
    return lastCheckDate.year != now.year ||
        lastCheckDate.month != now.month ||
        lastCheckDate.day != now.day;
  }

  /// 记录检查时间
  static Future<void> _recordCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 获取跳过的版本
  static Future<String?> _getSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skippedVersionKey);
  }

  /// 跳过当前版本
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skippedVersionKey, version);
  }

  /// 清除跳过的版本（用于重新检查）
  static Future<void> clearSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skippedVersionKey);
  }
}
