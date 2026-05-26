import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

/// 更新渠道类型
enum UpdateChannel {
  gitcode, // 国内渠道
  github,  // GitHub渠道
}

/// 更新渠道信息
class UpdateChannelInfo {
  final UpdateChannel channel;
  final String name;
  final String apiUrl;
  final String releasePageUrl;
  final String starUrl;
  final String description;

  const UpdateChannelInfo({
    required this.channel,
    required this.name,
    required this.apiUrl,
    required this.releasePageUrl,
    required this.starUrl,
    required this.description,
  });
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? apkDownloadUrl;
  final String releaseNotes;
  final bool hasUpdate;
  final UpdateChannel channel;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.apkDownloadUrl,
    required this.releaseNotes,
    required this.hasUpdate,
    required this.channel,
  });
}

class UpdateChecker {
  static const String _currentVersion = '1.0.3';
  static const String _lastCheckKey = 'last_update_check';
  static const String _skippedVersionKey = 'skipped_update_version';

  // 国内渠道 - GitCode
  static const String _gitcodeApiUrl = 'https://gitcode.com/api/v5/repos/gcw_QbmhmbO8/Height4Kid/releases/latest';
  static const String _gitcodeReleasePageUrl = 'https://gitcode.com/gcw_QbmhmbO8/Height4Kid/releases/';
  static const String _gitcodeStarUrl = 'https://gitcode.com/gcw_QbmhmbO8/Height4Kid';

  // GitHub渠道
  static const String _githubApiUrl = 'https://api.github.com/repos/hein1225/Height4Kid/releases/latest';
  static const String _githubReleasePageUrl = 'https://github.com/hein1225/Height4Kid/releases/';
  static const String _githubStarUrl = 'https://github.com/hein1225/Height4Kid';

  static String get currentVersion => _currentVersion;

  /// 获取所有更新渠道信息
  static List<UpdateChannelInfo> get updateChannels => [
    const UpdateChannelInfo(
      channel: UpdateChannel.gitcode,
      name: '国内渠道 (GitCode)',
      apiUrl: _gitcodeApiUrl,
      releasePageUrl: _gitcodeReleasePageUrl,
      starUrl: _gitcodeStarUrl,
      description: '国内访问速度快，推荐国内用户使用',
    ),
    const UpdateChannelInfo(
      channel: UpdateChannel.github,
      name: 'GitHub渠道',
      apiUrl: _githubApiUrl,
      releasePageUrl: _githubReleasePageUrl,
      starUrl: _githubStarUrl,
      description: '国际访问，适合海外用户',
    ),
  ];

  /// 检查所有渠道的更新
  /// [force] 为 true 时忽略时间间隔强制检查
  static Future<Map<UpdateChannel, UpdateInfo?>> checkAllChannels({bool force = false}) async {
    final results = <UpdateChannel, UpdateInfo?>{};

    // 如果不是强制检查，检查是否需要检查（每天一次）
    if (!force) {
      final shouldCheck = await _shouldCheckUpdate();
      if (!shouldCheck) return results;
    }

    // 记录检查时间
    await _recordCheckTime();

    // 检查国内渠道（GitCode）
    results[UpdateChannel.gitcode] = await checkGitCodeUpdate();

    // 检查GitHub渠道
    results[UpdateChannel.github] = await checkGitHubUpdate();

    return results;
  }

  /// 检查更新（默认优先检查国内渠道）
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

      // 优先检查国内渠道（GitCode）
      UpdateInfo? updateInfo = await checkGitCodeUpdate();

      // 如果国内渠道检查失败或没有更新，检查GitHub渠道
      if (updateInfo == null || !updateInfo.hasUpdate) {
        final githubUpdate = await checkGitHubUpdate();
        if (githubUpdate != null && githubUpdate.hasUpdate) {
          updateInfo = githubUpdate;
        }
      }

      return updateInfo;
    } catch (e) {
      return null;
    }
  }

  /// 检查 GitCode 国内渠道更新
  static Future<UpdateInfo?> checkGitCodeUpdate() async {
    try {
      // Web 环境有 CORS 限制，直接返回模拟数据用于测试
      if (kIsWeb) {
        debugPrint('Web环境：模拟GitCode更新检查');
        return _getMockUpdateInfo(UpdateChannel.gitcode);
      }

      final response = await http.get(
        Uri.parse(_gitcodeApiUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('GitCode API 请求失败: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      
      // GitCode 的 tag_name 可能没有 v 前缀
      final tagName = data['tag_name'] as String;
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;
      
      // GitCode API 没有 html_url，需要手动构建
      final downloadUrl = '$_gitcodeReleasePageUrl$tagName';
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
      final bool shouldShowUpdate;
      if (hasUpdate) {
        final skippedVersion = await _getSkippedVersion();
        shouldShowUpdate = skippedVersion != latestVersion;
      } else {
        shouldShowUpdate = false;
      }

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        apkDownloadUrl: apkDownloadUrl,
        releaseNotes: releaseNotes,
        hasUpdate: hasUpdate && shouldShowUpdate,
        channel: UpdateChannel.gitcode,
      );
    } catch (e) {
      debugPrint('GitCode 检查更新失败: $e');
      // Web环境返回模拟数据，Android环境返回null
      if (kIsWeb) {
        return _getMockUpdateInfo(UpdateChannel.gitcode);
      }
      return null;
    }
  }

  /// 获取模拟更新信息（用于Web测试）
  static UpdateInfo _getMockUpdateInfo(UpdateChannel channel) {
    final isGitCode = channel == UpdateChannel.gitcode;
    return UpdateInfo(
      version: '1.0.3',
      downloadUrl: isGitCode ? _gitcodeReleasePageUrl : _githubReleasePageUrl,
      apkDownloadUrl: null,
      releaseNotes: 'Web环境模拟数据\n\n在真实Android设备上可以正常检查更新',
      hasUpdate: false, // 模拟没有更新
      channel: channel,
    );
  }

  /// 检查 GitHub 渠道更新
  static Future<UpdateInfo?> checkGitHubUpdate() async {
    try {
      // Web 环境有 CORS 限制，直接返回模拟数据用于测试
      if (kIsWeb) {
        debugPrint('Web环境：模拟GitHub更新检查');
        return _getMockUpdateInfo(UpdateChannel.github);
      }

      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 15));

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
      final bool shouldShowUpdate;
      if (hasUpdate) {
        final skippedVersion = await _getSkippedVersion();
        shouldShowUpdate = skippedVersion != latestVersion;
      } else {
        shouldShowUpdate = false;
      }

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        apkDownloadUrl: apkDownloadUrl,
        releaseNotes: releaseNotes,
        hasUpdate: hasUpdate && shouldShowUpdate,
        channel: UpdateChannel.github,
      );
    } catch (e) {
      // Web环境返回模拟数据，其他环境返回null
      if (kIsWeb) {
        return _getMockUpdateInfo(UpdateChannel.github);
      }
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
