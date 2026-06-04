import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sync_config.dart';
import 'sync_service.dart';

/// WebDAV 同步服务实现
class WebDAVSyncService implements SyncService {
  final WebDAVConfig config;
  http.Client? _client;

  WebDAVSyncService({required this.config});

  @override
  SyncServiceType get serviceType => SyncServiceType.webdav;

  @override
  String get serviceName => 'WebDAV';

  @override
  bool get isConfigured => config.isConfigured;

  /// 获取 HTTP 客户端
  http.Client _getClient() {
    _client ??= http.Client();
    return _client!;
  }

  /// 构建完整 URL
  String _buildUrl(String path) {
    String baseUrl = config.serverUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    String remotePath = config.remotePath;
    if (remotePath.startsWith('/')) {
      remotePath = remotePath.substring(1);
    }
    if (!remotePath.endsWith('/')) {
      remotePath += '/';
    }

    // 移除路径开头的斜杠
    String cleanPath = path;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$baseUrl$remotePath$cleanPath';
  }

  /// 获取认证头
  Map<String, String> _getAuthHeaders() {
    final auth = base64Encode(utf8.encode('${config.username}:${config.password}'));
    return {
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/json; charset=utf-8',
    };
  }

  @override
  Future<SyncResult> testConnection() async {
    try {
      if (!isConfigured) {
        return SyncResult.failure(message: '请先配置 WebDAV 服务器信息');
      }

      final url = _buildUrl('');
      final response = await _getClient()
          .send(
            http.Request('PROPFIND', Uri.parse(url))
              ..headers.addAll(_getAuthHeaders())
              ..headers['Depth'] = '0'
              ..body = '''<?xml version="1.0" encoding="utf-8"?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:resourcetype/>
  </D:prop>
</D:propfind>''',
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 207 || response.statusCode == 200) {
        return SyncResult.success(message: '连接成功');
      } else if (response.statusCode == 401) {
        return SyncResult.failure(message: '认证失败，请检查用户名和密码');
      } else if (response.statusCode == 404) {
        // 目录不存在，尝试创建
        final createResult = await _createDirectory();
        if (createResult.success) {
          return SyncResult.success(message: '连接成功（已创建目录）');
        }
        return createResult;
      } else {
        return SyncResult.failure(
          message: '连接失败：HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('Connection timed out')) {
        return SyncResult.failure(
          message: '网络连接失败，请检查服务器地址',
          details: errorMsg,
        );
      } else if (errorMsg.contains('FormatException')) {
        return SyncResult.failure(
          message: '服务器地址格式错误',
          details: errorMsg,
        );
      }
      return SyncResult.failure(
        message: '连接失败：$e',
        details: errorMsg,
      );
    }
  }

  /// 创建远程目录
  Future<SyncResult> _createDirectory() async {
    try {
      final url = _buildUrl('');
      final response = await _getClient()
          .send(
            http.Request('MKCOL', Uri.parse(url))
              ..headers.addAll(_getAuthHeaders()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SyncResult.success(message: '目录创建成功');
      } else {
        return SyncResult.failure(
          message: '创建目录失败：HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return SyncResult.failure(
        message: '创建目录失败：$e',
        details: e.toString(),
      );
    }
  }

  @override
  Future<SyncResult> uploadData(String data, String filename) async {
    try {
      if (!isConfigured) {
        return SyncResult.failure(message: 'WebDAV 未配置');
      }

      final url = _buildUrl(filename);
      final response = await _getClient()
          .put(
            Uri.parse(url),
            headers: _getAuthHeaders(),
            body: utf8.encode(data),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
        return SyncResult.success(
          message: '上传成功',
          syncTime: DateTime.now(),
        );
      } else if (response.statusCode == 401) {
        return SyncResult.failure(message: '认证失败');
      } else {
        return SyncResult.failure(
          message: '上传失败：HTTP ${response.statusCode}',
          details: response.body,
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Connection refused')) {
        return SyncResult.failure(
          message: '网络连接失败',
          details: errorMsg,
        );
      }
      return SyncResult.failure(
        message: '上传失败：$e',
        details: errorMsg,
      );
    }
  }

  @override
  Future<String?> downloadData(String filename) async {
    try {
      if (!isConfigured) {
        return null;
      }

      final url = _buildUrl(filename);
      final response = await _getClient()
          .get(
            Uri.parse(url),
            headers: _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else if (response.statusCode == 404) {
        return null; // 文件不存在
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException')) {
        throw Exception('网络连接失败');
      }
      throw Exception('下载失败：$e');
    }
  }

  @override
  Future<CloudFileInfo?> getFileInfo(String filename) async {
    try {
      if (!isConfigured) {
        return null;
      }

      final url = _buildUrl(filename);
      final response = await _getClient()
          .send(
            http.Request('PROPFIND', Uri.parse(url))
              ..headers.addAll(_getAuthHeaders())
              ..headers['Depth'] = '0'
              ..body = '''<?xml version="1.0" encoding="utf-8"?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:getlastmodified/>
    <D:getcontentlength/>
  </D:prop>
</D:propfind>''',
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 207) {
        final body = await response.stream.bytesToString();
        return _parsePropFindResponse(body, filename);
      } else if (response.statusCode == 404) {
        return null; // 文件不存在
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get file info error: $e');
      }
      return null;
    }
  }

  @override
  Future<List<CloudFileInfo>> listFiles(String directory) async {
    final files = <CloudFileInfo>[];

    try {
      if (!isConfigured) {
        return files;
      }

      final url = _buildUrl(directory);
      final response = await _getClient()
          .send(
            http.Request('PROPFIND', Uri.parse(url))
              ..headers.addAll(_getAuthHeaders())
              ..headers['Depth'] = '1'
              ..body = '''<?xml version="1.0" encoding="utf-8"?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:getlastmodified/>
    <D:getcontentlength/>
    <D:resourcetype/>
  </D:prop>
</D:propfind>''',
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 207) {
        final body = await response.stream.bytesToString();
        return _parsePropFindListResponse(body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('List files error: $e');
      }
    }

    return files;
  }

  @override
  Future<SyncResult> deleteFile(String filename) async {
    try {
      if (!isConfigured) {
        return SyncResult.failure(message: 'WebDAV 未配置');
      }

      final url = _buildUrl(filename);
      final response = await _getClient()
          .delete(
            Uri.parse(url),
            headers: _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 204 ||
          response.statusCode == 200 ||
          response.statusCode == 404) {
        return SyncResult.success(message: '删除成功');
      } else {
        return SyncResult.failure(
          message: '删除失败：HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return SyncResult.failure(
        message: '删除失败：$e',
        details: e.toString(),
      );
    }
  }

  /// 解析 PROPFIND 响应（单个文件）
  CloudFileInfo? _parsePropFindResponse(String xmlBody, String filename) {
    try {
      // 解析 getlastmodified
      final modifiedMatch = RegExp(
        r'<D:getlastmodified[^>]*>([^<]+)</D:getlastmodified>',
        caseSensitive: false,
      ).firstMatch(xmlBody);

      DateTime? modifiedTime;
      if (modifiedMatch != null) {
        modifiedTime = _parseHttpDate(modifiedMatch.group(1)!);
      }

      // 解析 getcontentlength
      final sizeMatch = RegExp(
        r'<D:getcontentlength[^>]*>([^<]+)</D:getcontentlength>',
        caseSensitive: false,
      ).firstMatch(xmlBody);

      int? size;
      if (sizeMatch != null) {
        size = int.tryParse(sizeMatch.group(1)!);
      }

      return CloudFileInfo(
        path: filename,
        modifiedTime: modifiedTime,
        size: size,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Parse PROPFIND response error: $e');
      }
      return null;
    }
  }

  /// 解析 PROPFIND 响应（文件列表）
  List<CloudFileInfo> _parsePropFindListResponse(String xmlBody) {
    final files = <CloudFileInfo>[];

    try {
      // 匹配每个响应项
      final responseMatches = RegExp(
        r'<D:response[^>]*>(.*?)</D:response>',
        caseSensitive: false,
        dotAll: true,
      ).allMatches(xmlBody);

      for (final match in responseMatches) {
        final responseXml = match.group(1)!;

        // 解析 href（文件路径）
        final hrefMatch = RegExp(
          r'<D:href[^>]*>([^<]+)</D:href>',
          caseSensitive: false,
        ).firstMatch(responseXml);

        if (hrefMatch == null) continue;

        final href = hrefMatch.group(1)!;

        // 跳过目录本身
        if (href.endsWith('/')) continue;

        // 提取文件名
        final filename = href.split('/').last;
        if (filename.isEmpty) continue;

        // 解析 getlastmodified
        final modifiedMatch = RegExp(
          r'<D:getlastmodified[^>]*>([^<]+)</D:getlastmodified>',
          caseSensitive: false,
        ).firstMatch(responseXml);

        DateTime? modifiedTime;
        if (modifiedMatch != null) {
          modifiedTime = _parseHttpDate(modifiedMatch.group(1)!);
        }

        // 解析 getcontentlength
        final sizeMatch = RegExp(
          r'<D:getcontentlength[^>]*>([^<]+)</D:getcontentlength>',
          caseSensitive: false,
        ).firstMatch(responseXml);

        int? size;
        if (sizeMatch != null) {
          size = int.tryParse(sizeMatch.group(1)!);
        }

        files.add(CloudFileInfo(
          path: filename,
          modifiedTime: modifiedTime,
          size: size,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Parse PROPFIND list response error: $e');
      }
    }

    return files;
  }

  /// 解析 HTTP 日期格式（兼容 Web 平台）
  DateTime? _parseHttpDate(String dateStr) {
    try {
      // 尝试多种常见格式
      // RFC 1123: Sun, 06 Nov 1994 08:49:37 GMT
      // RFC 1036: Sunday, 06-Nov-94 08:49:37 GMT
      // ANSI C: Sun Nov  6 08:49:37 1994
      // ISO 8601: 2024-01-15T08:30:00Z

      // 先尝试直接解析 ISO 8601
      if (dateStr.contains('T')) {
        return DateTime.tryParse(dateStr);
      }

      // 解析 RFC 1123 格式
      final regex = RegExp(
        r'^(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun),?\s+(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})',
        caseSensitive: false,
      );
      final match = regex.firstMatch(dateStr);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final monthStr = match.group(2)!.toLowerCase();
        final year = int.parse(match.group(3)!);
        final hour = int.parse(match.group(4)!);
        final minute = int.parse(match.group(5)!);
        final second = int.parse(match.group(6)!);

        final months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };
        final month = months[monthStr] ?? 1;

        return DateTime.utc(year, month, day, hour, minute, second);
      }

      // 最后尝试直接解析
      return DateTime.tryParse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    _client?.close();
    _client = null;
  }
}
