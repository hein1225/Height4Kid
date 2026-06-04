import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sync_config.dart';
import 'sync_service.dart';

/// BoxSync 公共服务区同步服务实现
/// 使用固定的公共服务器: https://sync.hyc5069.top/
/// 项目地址: https://github.com/hein1225/BoxSync
///
/// API 规范（根据官方文档）:
/// - 登录: POST /api/auth/login
/// - 写入数据: POST /api/sync/write (body: appId, key, value, timestamp)
/// - 读取数据: GET /api/sync/read?appId=xxx&key=xxx
/// - 批量同步: POST /api/sync/batch (body: appId, changes)
/// - 获取变更: GET /api/sync/changes?appId=xxx&since=xxx
/// - 删除数据: DELETE /api/sync/delete?appId=xxx&key=xxx
///
/// 同步原则（与 WebDAV 保持一致）:
/// 1. 版本轮询策略: 保存最近 3 个版本
/// 2. 冲突处理: 最后修改时间优先
/// 3. 自动同步: 默认关闭，数据变更后延迟 3 秒触发
class BoxSyncPublicSyncService implements SyncService {
  @override
  SyncServiceType get serviceType => SyncServiceType.boxsyncPublic;

  @override
  String get serviceName => 'BoxSync（公共服务区）';

  final BoxSyncPublicConfig config;
  String? _token;

  BoxSyncPublicSyncService({required this.config}) {
    _token = config.token;
  }

  @override
  bool get isConfigured {
    return config.username.isNotEmpty && config.password.isNotEmpty;
  }

  /// 获取完整的 API 基础 URL（固定服务器）
  String get _baseUrl {
    var url = BoxSyncPublicConfig.defaultServerUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// 登录获取 Token
  /// POST /api/auth/login
  Future<bool> _login() async {
    try {
      print('BoxSyncPublic - Logging in with username: ${config.username}');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': config.username,
          'password': config.password,
        }),
      );

      print('BoxSyncPublic login - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          _token = data['token'];
          print('BoxSyncPublic login - Token obtained successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('BoxSyncPublic login - Error: $e');
      return false;
    }
  }

  /// 确保 Token 有效
  Future<bool> _ensureAuthenticated() async {
    if (_token != null) {
      // 验证 Token 是否有效，尝试读取数据
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/sync/read'),
          headers: {'Authorization': 'Bearer $_token'},
        );

        if (response.statusCode == 200) {
          return true;
        } else if (response.statusCode == 401) {
          // Token 过期，重新登录
          print('BoxSyncPublic - Token expired, re-login');
          final loginSuccess = await _login();
          if (loginSuccess) {
            // 登录成功后创建应用分区
            await _createAppPartition();
          }
          return loginSuccess;
        }
      } catch (e) {
        print('BoxSyncPublic - Token validation error: $e');
        // 网络错误，尝试重新登录
        final loginSuccess = await _login();
        if (loginSuccess) {
          // 登录成功后创建应用分区
          await _createAppPartition();
        }
        return loginSuccess;
      }
    }

    final loginSuccess = await _login();
    if (loginSuccess) {
      // 登录成功后创建应用分区
      await _createAppPartition();
    }
    return loginSuccess;
  }

  /// 创建应用分区
  /// POST /api/sync/apps
  Future<bool> _createAppPartition() async {
    try {
      print('BoxSyncPublic - Creating app partition for Height4Kid');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sync/apps'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'appId': 'Height4Kid',
          'appName': 'Height4Kid 身高记录',
        }),
      );

      print('BoxSyncPublic createApp - Response status: ${response.statusCode}');
      print('BoxSyncPublic createApp - Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // 200 表示创建成功，409 表示应用已存在
        if (data['success'] == true || response.statusCode == 409) {
          print('BoxSyncPublic - App partition ready');
          return true;
        }
      } else if (response.statusCode == 409) {
        // 应用分区已存在，也算成功
        print('BoxSyncPublic - App partition already exists');
        return true;
      }
      return false;
    } catch (e) {
      print('BoxSyncPublic createApp - Error: $e');
      // 创建应用分区失败不阻断流程，继续尝试上传
      return true;
    }
  }

  @override
  Future<SyncResult> testConnection() async {
    if (!isConfigured) {
      return SyncResult.failure(message: '配置不完整');
    }

    try {
      print('BoxSyncPublic - Testing connection to public server');
      final success = await _login();
      if (success) {
        return SyncResult.success(message: '连接成功');
      }
      return SyncResult.failure(message: '登录失败，请检查用户名密码');
    } catch (e) {
      return SyncResult.failure(
        message: '连接失败',
        details: e.toString(),
      );
    }
  }

  @override
  Future<SyncResult> uploadData(String data, String filename) async {
    if (!await _ensureAuthenticated()) {
      return SyncResult.failure(message: '认证失败');
    }

    try {
      // 使用 POST /api/sync/write 写入数据
      // 根据服务器要求，使用 appId, key, value, timestamp 格式
      // filename 作为 key，用于版本管理（如 height4kid_sync_v1.json）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final requestBody = jsonEncode({
        'appId': 'Height4Kid',
        'key': filename,
        'value': data,
        'timestamp': timestamp,
      });

      print('BoxSyncPublic upload - URL: $_baseUrl/api/sync/write');
      print('BoxSyncPublic upload - Filename: $filename');
      print('BoxSyncPublic upload - Data size: ${data.length} bytes');
      print('BoxSyncPublic upload - Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/sync/write'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: requestBody,
      );

      print('BoxSyncPublic upload - Response status: ${response.statusCode}');
      print('BoxSyncPublic upload - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return SyncResult.success(
            message: '上传成功',
            syncTime: DateTime.now(),
          );
        } else {
          return SyncResult.failure(
            message: '上传失败: ${responseData['message'] ?? '未知错误'}',
          );
        }
      } else if (response.statusCode == 400) {
        return SyncResult.failure(
          message: '上传失败: 请求格式错误 (400)',
          details: '服务器返回: ${response.body}',
        );
      } else if (response.statusCode == 413) {
        return SyncResult.failure(
          message: '上传失败: 数据太大 (413)',
          details: '请尝试压缩数据或分批上传',
        );
      }
      return SyncResult.failure(
        message: '上传失败: HTTP ${response.statusCode}',
        details: response.body,
      );
    } catch (e) {
      print('BoxSyncPublic upload - Error: $e');
      return SyncResult.failure(
        message: '上传失败',
        details: e.toString(),
      );
    }
  }

  @override
  Future<String?> downloadData(String filename) async {
    if (!await _ensureAuthenticated()) {
      return null;
    }

    try {
      // 使用 GET /api/sync/read 读取数据
      // 根据服务器要求，使用 appId 和 key 参数
      print('BoxSyncPublic download - Filename: $filename');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sync/read?appId=Height4Kid&key=$filename'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      print('BoxSyncPublic download - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['value'] != null) {
          return data['value'] as String;
        }
      }
      return null;
    } catch (e) {
      print('BoxSyncPublic download - Error: $e');
      return null;
    }
  }

  @override
  Future<CloudFileInfo?> getFileInfo(String filename) async {
    if (!await _ensureAuthenticated()) {
      return null;
    }

    try {
      // 使用 GET /api/sync/read 获取文件信息
      // 根据服务器要求，使用 appId 和 key 参数
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sync/read?appId=Height4Kid&key=$filename'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['value'] != null) {
          final timestamp = data['timestamp'] as int?;
          final value = data['value'] as String;
          return CloudFileInfo(
            path: filename,
            modifiedTime: timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                : DateTime.now(),
            size: value.length,
          );
        }
      }
      return null;
    } catch (e) {
      print('BoxSyncPublic getFileInfo - Error: $e');
      return null;
    }
  }

  @override
  Future<List<CloudFileInfo>> listFiles(String directory) async {
    if (!await _ensureAuthenticated()) {
      print('BoxSyncPublic listFiles - 认证失败');
      return [];
    }

    try {
      // 使用 GET /api/sync/changes 获取变更列表
      // since=0 表示获取所有历史数据
      final url = '$_baseUrl/api/sync/changes?appId=Height4Kid&since=0';
      print('BoxSyncPublic listFiles - URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'},
      );

      print('BoxSyncPublic listFiles - Response status: ${response.statusCode}');
      print('BoxSyncPublic listFiles - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final changes = data['changes'] as List?;
          final result = changes?.map((change) => CloudFileInfo(
            path: change['key'] as String,
            modifiedTime: change['timestamp'] != null
                ? DateTime.fromMillisecondsSinceEpoch(change['timestamp'] as int)
                : DateTime.now(),
            size: (change['value'] as String?)?.length ?? 0,
          )).toList() ?? [];
          print('BoxSyncPublic listFiles - Found ${result.length} files');
          return result;
        } else {
          print('BoxSyncPublic listFiles - Server returned success: false');
        }
      } else {
        print('BoxSyncPublic listFiles - HTTP error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('BoxSyncPublic listFiles - Error: $e');
      return [];
    }
  }

  @override
  Future<SyncResult> deleteFile(String filename) async {
    if (!await _ensureAuthenticated()) {
      return SyncResult.failure(message: '认证失败');
    }

    try {
      // 使用 DELETE /api/sync/delete 删除数据
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/sync/delete?appId=Height4Kid&key=$filename'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return SyncResult.success(message: '删除成功');
        }
      }
      return SyncResult.failure(message: '删除失败');
    } catch (e) {
      return SyncResult.failure(
        message: '删除失败',
        details: e.toString(),
      );
    }
  }

  /// 批量同步（增量同步）
  /// POST /api/sync/batch
  Future<SyncResult> batchSync(List<Map<String, dynamic>> changes) async {
    if (!await _ensureAuthenticated()) {
      return SyncResult.failure(message: '认证失败');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sync/batch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'appId': 'Height4Kid',
          'changes': changes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return SyncResult.success(
            message: '批量同步成功',
            syncTime: DateTime.now(),
          );
        }
      }
      return SyncResult.failure(message: '批量同步失败: ${response.statusCode}');
    } catch (e) {
      return SyncResult.failure(
        message: '批量同步失败',
        details: e.toString(),
      );
    }
  }
}
