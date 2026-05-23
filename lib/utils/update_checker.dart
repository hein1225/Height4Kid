import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? apkDownloadUrl;
  final String releaseNotes;
  final bool hasUpdate;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.apkDownloadUrl,
    required this.releaseNotes,
    required this.hasUpdate,
  });
}

class UpdateChecker {
  static const String _currentVersion = '1.0.2';
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

      // 查找APK下载链接
      String? apkDownloadUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = asset['name'] as String;
          if (name.endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'] as String;
            break;
          }
        }
      }

      // 比较版本号
      final hasUpdate = _compareVersions(latestVersion, _currentVersion) > 0;

      // 检查用户是否跳过了这个版本
      if (hasUpdate) {
        final skippedVersion = await _getSkippedVersion();
        if (skippedVersion == latestVersion) {
          return UpdateInfo(
            version: latestVersion,
            downloadUrl: downloadUrl,
            apkDownloadUrl: apkDownloadUrl,
            releaseNotes: releaseNotes,
            hasUpdate: false,
          );
        }
      }

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        apkDownloadUrl: apkDownloadUrl,
        releaseNotes: releaseNotes,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      return null;
    }
  }

  /// 下载APK
  /// 返回下载的文件路径，下载失败返回null
  static Future<String?> downloadApk(
    String apkUrl,
    String version,
    void Function(double progress) onProgress,
  ) async {
    // Web端不支持下载APK
    if (kIsWeb) {
      debugPrint('Web端不支持下载APK');
      return null;
    }

    try {
      // 获取下载目录 - 使用应用私有缓存目录，避免权限问题
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // 优先使用应用私有外部存储目录，不需要额外权限
        downloadDir = await getExternalCacheDirectories().then((dirs) => dirs?.first);
        // 如果获取失败，使用应用缓存目录
        downloadDir ??= await getTemporaryDirectory();
      } else {
        downloadDir = await getTemporaryDirectory();
      }

      if (downloadDir == null) {
        debugPrint('无法获取下载目录');
        return null;
      }

      // 使用最新版本号作为文件名
      final filePath = '${downloadDir.path}/Height4Kid_v${version}.apk';
      debugPrint('APK下载路径: $filePath');

      // 使用Dio下载文件
      final dio = Dio();
      await dio.download(
        apkUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      debugPrint('APK下载完成: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('APK下载失败: $e');
      return null;
    }
  }

  /// 安装APK
  /// 在安装时请求安装权限
  static Future<bool> installApk(String filePath) async {
    // Web端不支持安装APK
    if (kIsWeb) {
      debugPrint('Web端不支持安装APK');
      return false;
    }

    try {
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('APK文件不存在: $filePath');
        return false;
      }

      // Android 8.0+ 需要请求安装未知应用的权限
      if (Platform.isAndroid) {
        final canInstall = await Permission.requestInstallPackages.isGranted;
        if (!canInstall) {
          debugPrint('请求安装权限');
          final status = await Permission.requestInstallPackages.request();
          if (!status.isGranted) {
            debugPrint('安装权限被拒绝');
            return false;
          }
        }
      }

      debugPrint('开始安装APK: $filePath');
      // 安装APK
      final result = await OpenFile.open(filePath, type: 'application/vnd.android.package-archive');
      debugPrint('安装结果: ${result.type}, ${result.message}');
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('APK安装失败: $e');
      return false;
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
