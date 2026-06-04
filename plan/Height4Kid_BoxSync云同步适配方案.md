# Height4Kid BoxSync 云同步适配方案

> **项目名称**：Height4Kid BoxSync 云同步
> **版本**：v1.2.0
> **创建日期**：2026-05-30
> **关联文档**：BoxSync 开发方案（`e:\code\BoxSync\plan\开发方案.md`）

---

## 一、方案概述

本方案为 Height4Kid（海因成长助手）应用新增 BoxSync 云同步适配模块，使其能够通过自建的 BoxSync 服务器实现数据云同步，为用户提供私有化、可控的云端数据存储方案。

### 1.1 背景

Height4Kid v1.1.0 版本已实现 WebDAV、Nextcloud、百度云三种云同步方式。本方案在此基础上新增 BoxSync 作为第四种同步选项，满足以下需求：

- 用户希望自建私有云同步服务器
- 对数据隐私有更高要求的用户
- 不依赖第三方云服务，完全自主可控

### 1.2 BoxSync 服务器特性

| 特性 | 说明 |
|------|------|
| 数据库 | Redis |
| 部署方式 | Docker |
| 默认端口 | 9390 |
| 认证方式 | JWT Token |
| 数据隔离 | 每用户独立数据空间 |
| API 路径 | `/api/sync/*` |

### 1.3 技术栈

| 层级 | 技术选型 |
|------|---------|
| 网络请求 | `http` 或 `dio`（已有依赖） |
| JSON 处理 | `dart:convert`（内置） |
| Token 存储 | `shared_preferences`（已有） |
| 安全存储 | `flutter_secure_storage`（需新增） |

---

## 二、数据结构分析

### 2.1 Height4Kid 数据模型

#### Child（孩子信息）

```dart
class Child {
  final String id;          // UUID
  final String name;        // 姓名
  final String gender;      // 性别（pink/blue）
  final String birthday;    // 生日（YYYY-MM-DD）
  String? avatar;           // 头像路径（本地文件）
  double height;            // 当前身高
  double weight;            // 当前体重
}
```

#### GrowthRecord（成长记录）

```dart
class GrowthRecord {
  final String id;          // UUID
  final String childId;     // 关联孩子 ID
  final String date;        // 记录日期（YYYY-MM-DD）
  final double height;      // 身高
  final double weight;      // 体重
  final String? note;       // 备注
}
```

### 2.2 同步数据格式

Height4Kid 已有统一的同步数据包装器 `SyncDataWrapper`：

```json
{
  "version": "1.1.0",
  "exportTime": "2026-05-30T10:00:00Z",
  "lastSyncTime": "2026-05-29T18:30:00Z",
  "data": {
    "children": [
      { "id": "...", "name": "...", "gender": "pink", ... }
    ],
    "records": [
      { "id": "...", "childId": "...", "date": "...", ... }
    ],
    "theme": "pink"
  }
}
```

### 2.3 BoxSync 应用分区设计

#### 应用分区机制

BoxSync 使用 **appId** 机制实现多应用数据隔离：

1. 用户登录后，数据存储在 `boxsync:data:{userId}:` 命名空间下
2. 每个应用通过唯一的 `appId` 创建独立分区
3. Height4Kid 的 `appId` 固定为 `Height4Kid`

分区结构示意：

```
boxsync:data:{userId}:{appId}:{key}   # 应用数据存储格式

示例：
boxsync:data:user-xxx:Height4Kid:data  →  Height4Kid 数据
boxsync:data:user-xxx:OtherApp:data    →  其他应用数据（相互隔离）
```

#### 应用分区创建

首次同步前，Height4Kid 需要调用 `/api/sync/apps` 创建应用分区：

```http
POST /api/sync/apps
Authorization: Bearer {token}
Content-Type: application/json

{
  "appId": "Height4Kid",
  "appName": "海因成长助手"
}

响应：
{
  "success": true,
  "appId": "Height4Kid",
  "appName": "海因成长助手"
}
```

#### 数据存储方案

Height4Kid 采用单 Key 存储完整数据：

| 参数 | 值 | 说明 |
|------|-----|------|
| appId | `Height4Kid` | 应用标识 |
| key | `data` | 数据键名 |
| value | JSON 字符串 | 完整 SyncDataWrapper |

**存储示例**：

```http
POST /api/sync/write
Authorization: Bearer {token}
Content-Type: application/json

{
  "appId": "Height4Kid",
  "key": "data",
  "value": "{完整JSON数据}",
  "timestamp": 1717000000000
}
```

---

## 三、适配架构设计

### 3.1 文件结构

在现有同步架构基础上新增 BoxSync 模块：

```
lib/
├── models/
│   └── sync_config.dart              # 新增 BoxSync 配置项
├── services/
│   ├── sync_service.dart             # 现有抽象接口（不变）
│   ├── boxsync_sync_service.dart     # 新增：BoxSync 同步实现
│   ├── webdav_sync_service.dart      # 现有
│   ├── nextcloud_sync_service.dart   # 现有
│   └── baidu_sync_service.dart       # 现有
├── screens/
│   ├── settings_screen.dart          # 改造：新增 BoxSync 入口
│   └── boxsync_config_screen.dart    # 新增：BoxSync 配置页面
└── utils/
    └── sync_utils.dart               # 现有（可能扩展）
```

### 3.2 SyncConfig 扩展

在 `sync_config.dart` 中新增 BoxSync 配置：

```dart
enum SyncServiceType {
  webdav,
  nextcloud,
  baidu,
  boxsync,  // 新增
}

class BoxSyncConfig {
  final String serverUrl;     // 服务器地址（如 http://192.168.1.100:9390）
  final String username;      // 用户名
  final String password;      // 密码
  final String? token;        // JWT Token（登录后获取）
  final bool enabled;         // 是否启用
  final DateTime? lastSyncTime;
  final String? lastSyncStatus;

  BoxSyncConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
    this.enabled = false,
    this.lastSyncTime,
    this.lastSyncStatus,
  });

  // toJson / fromJson 方法
}
```

### 3.3 BoxSyncSyncService 实现

实现 `SyncService` 抽象接口：

```dart
class BoxSyncSyncService implements SyncService {
  @override
  SyncServiceType get serviceType => SyncServiceType.boxsync;

  @override
  String get serviceName => 'BoxSync';

  final BoxSyncConfig config;
  final Dio _client;
  String? _token;

  BoxSyncSyncService({required this.config}) {
    _client = Dio(BaseOptions(
      baseUrl: config.serverUrl,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    ));
  }

  // 实现所有抽象方法...
}
```

---

## 四、API 对接设计

### 4.1 认证流程

```
Height4Kid → POST /api/auth/login
           ← { "token": "jwt-token-string", "userId": "user-xxx", "username": "user1" }

后续请求 → Header: Authorization: Bearer {token}
```

**登录实现**：

```dart
Future<bool> login() async {
  try {
    final response = await _client.post(
      '/auth/login',
      data: {
        'username': config.username,
        'password': config.password,
      },
    );

    if (response.statusCode == 200) {
      _token = response.data['token'];
      _userId = response.data['userId'];  // 保存 userId
      // 存储 Token
      await _saveToken(_token!);
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}
```

### 4.2 应用分区创建

BoxSync 使用 `appId` 区分不同应用的数据分区。Height4Kid 首次同步前需要创建应用分区：

**API 路径**：`POST /api/sync/apps`

```dart
/// 创建 Height4Kid 应用分区
Future<bool> _createAppPartition() async {
  try {
    final response = await _client.post(
      '/sync/apps',
      data: {
        'appId': 'Height4Kid',
        'appName': '海因成长助手',
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    return false;
  } on DioException {
    return false;
  }
}

/// 列出已有应用分区
Future<List<Map<String, dynamic>>?> _listApps() async {
  try {
    final response = await _client.get('/sync/apps');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['apps'] as List<Map<String, dynamic>>?;
    }
    return null;
  } on DioException {
    return null;
  }
}
```

### 4.3 数据读写 API

| 操作 | BoxSync API | Height4Kid 调用 |
|------|------------|----------------|
| 写入数据 | `POST /api/sync/write` | 上传完整数据（含 appId） |
| 读取数据 | `GET /api/sync/read?appId=Height4Kid&key=data` | 下载完整数据 |
| 批量同步 | `POST /api/sync/batch` | 批量上传变更 |
| 获取变更 | `GET /api/sync/changes?appId=Height4Kid&since=timestamp` | 增量同步 |
| 删除数据 | `DELETE /api/sync/delete?appId=Height4Kid&key=data` | 删除云端数据 |
| 创建分区 | `POST /api/sync/apps` | 创建 Height4Kid 分区 |
| 列出分区 | `GET /api/sync/apps` | 检查 Height4Kid 分区是否存在 |

### 4.4 同步流程

```
┌─────────────────────────────────────────────────────────────┐
│                     Height4Kid 同步流程                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 检查本地 Token                                           │
│     ├─→ 有 Token → 验证有效性（GET /api/sync/apps）           │
│     │     ├─→ 200 OK → Token 有效，进入同步                   │
│     │     └─→ 401 → Token 过期，重新登录                      │
│     └─→ 无 Token → 调用登录接口获取 Token                      │
│                                                             │
│  2. 检查/创建应用分区                                         │
│     └─→ POST /api/sync/apps (appId=Height4Kid)               │
│         服务器自动建立 boxsync:data:{userId}:Height4Kid:*     │
│                                                             │
│  3. 获取云端变更                                              │
│     └─→ GET /api/sync/changes?appId=Height4Kid&since=xxx     │
│                                                             │
│  4. 对比本地与云端数据                                         │
│     ├─→ 云端无数据 → 上传本地数据                              │
│     ├─→ 本地无数据 → 下载云端数据                              │
│     └─→ 两边都有 → 比较 lastSyncTime，取较新版本               │
│                                                             │
│  5. 执行同步                                                  │
│     ├─→ 上传：POST /api/sync/batch (appId=Height4Kid)         │
│     │        存储到 boxsync:data:{userId}:Height4Kid:*        │
│     └─→ 下载：解析 JSON，更新本地数据库                         │
│                                                             │
│  6. 更新同步状态                                              │
│     └─→ 记录 lastSyncTime，更新 UI 状态                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 五、核心代码实现

### 5.1 BoxSyncSyncService 完整实现

```dart
// lib/services/boxsync_sync_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/sync_config.dart';
import 'sync_service.dart';

class BoxSyncSyncService implements SyncService {
  @override
  SyncServiceType get serviceType => SyncServiceType.boxsync;

  @override
  String get serviceName => 'BoxSync 私有云';

  final BoxSyncConfig config;
  late final Dio _client;
  String? _token;
  String? _userId;

  // 应用 ID，固定为 Height4Kid
  static const String _appId = 'Height4Kid';

  BoxSyncSyncService({required this.config}) {
    _client = Dio(BaseOptions(
      baseUrl: '${config.serverUrl}/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    if (config.token != null) {
      _token = config.token;
      _client.options.headers['Authorization'] = 'Bearer $_token';
    }
  }

  @override
  bool get isConfigured {
    return config.serverUrl.isNotEmpty &&
           config.username.isNotEmpty &&
           config.password.isNotEmpty;
  }

  /// 登录获取 Token
  Future<bool> _login() async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {
          'username': config.username,
          'password': config.password,
        },
      );

      // BoxSync 响应格式: { "success": true, "token": "...", "userId": "...", ... }
      if (response.statusCode == 200 && 
          response.data['success'] == true && 
          response.data['token'] != null) {
        _token = response.data['token'];
        _userId = response.data['userId'];
        _client.options.headers['Authorization'] = 'Bearer $_token';
        return true;
      }
      return false;
    } on DioException {
      return false;
    }
  }

  /// 创建应用分区
  Future<bool> _createAppPartition() async {
    try {
      final response = await _client.post(
        '/sync/apps',
        data: {
          'appId': _appId,
          'appName': '海因成长助手',
        },
      );
      // 响应格式: { "success": true, ... }
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException {
      return false;
    }
  }

  /// 确保 Token 有效并创建应用分区
  Future<bool> _ensureAuthenticated() async {
    if (_token != null) {
      // 验证 Token 是否有效
      try {
        final response = await _client.get('/sync/apps');
        if (response.statusCode == 200 && response.data['success'] == true) {
          // 检查 Height4Kid 分区是否存在
          final apps = response.data['apps'] as List?;
          final hasHeight4Kid = apps?.any((app) => app['appId'] == _appId) ?? false;
          if (!hasHeight4Kid) {
            await _createAppPartition();
          }
          return true;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          // Token 过期，重新登录
          final success = await _login();
          if (success) {
            await _createAppPartition();
          }
          return success;
        }
      }
    }
    final success = await _login();
    if (success) {
      await _createAppPartition();
    }
    return success;
  }

  @override
  Future<SyncResult> testConnection() async {
    if (!isConfigured) {
      return SyncResult.failure(message: '配置不完整');
    }

    try {
      final success = await _login();
      if (success) {
        // 尝试创建应用分区
        await _createAppPartition();
        return SyncResult.success(message: '连接成功');
      }
      return SyncResult.failure(message: '登录失败，请检查用户名密码');
    } on DioException catch (e) {
      return SyncResult.failure(
        message: '连接失败',
        details: e.message,
      );
    }
  }

  @override
  Future<SyncResult> uploadData(String data, String filename) async {
    if (!await _ensureAuthenticated()) {
      return SyncResult.failure(message: '认证失败');
    }

    try {
      // 使用批量同步接口上传完整数据
      final response = await _client.post(
        '/sync/batch',
        data: {
          'appId': _appId,
          'changes': [
            {
              'key': 'data',
              'value': data,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ],
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SyncResult.success(
          message: '上传成功',
          syncTime: DateTime.now(),
        );
      }
      return SyncResult.failure(message: '上传失败');
    } on DioException catch (e) {
      return SyncResult.failure(
        message: '上传失败',
        details: e.message,
      );
    }
  }

  @override
  Future<String?> downloadData(String filename) async {
    if (!await _ensureAuthenticated()) {
      return null;
    }

    try {
      final response = await _client.get(
        '/sync/read',
        queryParameters: {
          'appId': _appId,
          'key': 'data',
        },
      );

      // BoxSync 响应格式: { "success": true, "value": "...", "timestamp": ..., "version": ... }
      if (response.statusCode == 200 && 
          response.data['success'] == true && 
          response.data['value'] != null) {
        return response.data['value'] as String;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // 数据不存在
      }
      return null;
    }
  }

  /// 获取云端变更列表（用于增量同步）
  Future<List<Map<String, dynamic>>?> fetchChanges(int since) async {
    if (!await _ensureAuthenticated()) {
      return null;
    }

    try {
      final response = await _client.get(
        '/sync/changes',
        queryParameters: {
          'appId': _appId,
          'since': since.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final changes = response.data['changes'] as List?;
        return changes?.cast<Map<String, dynamic>>();
      }
      return null;
    } on DioException {
      return null;
    }
  }

  @override
  Future<CloudFileInfo?> getFileInfo(String filename) async {
    if (!await _ensureAuthenticated()) {
      return null;
    }

    try {
      final response = await _client.get(
        '/sync/read',
        queryParameters: {
          'appId': _appId,
          'key': 'data',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // 解析数据获取 lastSyncTime
        final data = response.data['value'] as String?;
        if (data == null) return null;
        final timestamp = response.data['timestamp'] as int?;
        final wrapper = SyncDataWrapper.fromJsonString(data);
        return CloudFileInfo(
          path: '$_appId:data',
          modifiedTime: timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : (wrapper.lastSyncTime ?? wrapper.exportTime),
          size: data.length,
        );
      }
      return null;
    } on DioException {
      return null;
    }
  }

  @override
  Future<List<CloudFileInfo>> listFiles(String directory) async {
    // BoxSync 使用 appId 分区，返回单个应用数据信息
    final info = await getFileInfo('data');
    return info != null ? [info] : [];
  }

  @override
  Future<SyncResult> deleteFile(String filename) async {
    if (!await _ensureAuthenticated()) {
      return SyncResult.failure(message: '认证失败');
    }

    try {
      final response = await _client.delete(
        '/sync/delete',
        queryParameters: {
          'appId': _appId,
          'key': 'data',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SyncResult.success(message: '删除成功');
      }
      return SyncResult.failure(message: '删除失败');
    } on DioException catch (e) {
      return SyncResult.failure(
        message: '删除失败',
        details: e.message,
      );
    }
  }
}
```

### 5.2 配置页面 UI 设计

#### 5.2.1 页面线框图

```
┌─────────────────────────────────────┐
│  ←  BoxSync 私有云配置               │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📡 服务器地址                 │   │
│  │                             │   │
│  │ ┌─────────────────────────┐│   │
│  │ │ http://192.168.1.100:9390││   │
│  │ └─────────────────────────┘│   │
│  │ 请输入 BoxSync 服务器完整地址   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 用户名                     │   │
│  │                             │   │
│  │ ┌─────────────────────────┐│   │
│  │ │ user1                    ││   │
│  │ └─────────────────────────┘│   │
│  │ 服务器管理员创建的账户名       │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🔒 密码                      │   │
│  │                             │   │
│  │ ┌─────────────────────────┐│   │
│  │ │ ••••••••                  ││   │
│  │ └─────────────────────────┘│   │
│  │                              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌──────────┐  ┌──────────────────┐ │
│  │  测试连接  │  │    保存配置       │ │
│  └──────────┘  └──────────────────┘ │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ✅ 连接成功                    │   │
│  │ 上次同步: 2026-05-30 10:30    │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

#### 5.2.2 表单字段说明

| 字段 | 标签 | 输入类型 | 占位提示 | 校验规则 |
|------|------|---------|---------|---------|
| 服务器地址 | 📡 服务器地址 | 文本输入 | `http://192.168.1.100:9390` | 必填，需符合 URL 格式 |
| 用户名 | 👤 用户名 | 文本输入 | `请输入用户名` | 必填，非空 |
| 密码 | 🔒 密码 | 密码输入（密文显示） | `请输入密码` | 必填，非空 |

#### 5.2.3 交互行为

| 操作 | 行为 |
|------|------|
| 页面打开 | 自动加载已保存的配置（如有），填充表单 |
| 输入服务器地址 | 自动去除首尾空格，末尾自动去除 `/` |
| 点击测试连接 | 按钮显示加载动画，调用登录接口验证 |
| 连接成功 | 显示绿色成功提示，启用"保存配置"按钮 |
| 连接失败 | 显示红色错误提示（如"用户名或密码错误"），"保存配置"按钮保持禁用 |
| 点击保存配置 | 保存服务器地址、用户名、密码到本地，返回上一页 |
| 密码显示切换 | 密码输入框右侧提供显示/隐藏切换图标 |

#### 5.2.4 状态展示

连接成功后，页面底部显示同步状态卡片：

| 状态 | 显示内容 |
|------|---------|
| 未配置 | 灰色提示："尚未配置 BoxSync 云同步" |
| 已配置未同步 | 蓝色提示："已连接，尚未同步数据" |
| 同步成功 | 绿色提示："✅ 连接成功" + 上次同步时间 |
| 同步失败 | 红色提示："❌ 同步失败" + 失败原因 |

### 5.3 配置页面代码实现

```dart
// lib/screens/boxsync_config_screen.dart

import 'package:flutter/material.dart';
import '../models/sync_config.dart';
import '../services/boxsync_sync_service.dart';

class BoxSyncConfigScreen extends StatefulWidget {
  const BoxSyncConfigScreen({super.key});

  @override
  State<BoxSyncConfigScreen> createState() => _BoxSyncConfigScreenState();
}

class _BoxSyncConfigScreenState extends State<BoxSyncConfigScreen> {
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // 从 SharedPreferences 加载已保存的配置
    // ...
  }

  Future<void> _testConnection() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = null;
    });

    final service = BoxSyncSyncService(
      config: BoxSyncConfig(
        serverUrl: _serverUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );

    final result = await service.testConnection();

    setState(() {
      _isConnecting = false;
      _isConnected = result.success;
      _statusMessage = result.message;
    });
  }

  Future<void> _saveConfig() async {
    // 保存配置到 SharedPreferences
    // ...
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BoxSync 私有云配置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'http://192.168.1.100:9390',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnecting ? null : _testConnection,
                    child: _isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _saveConfig : null,
                    child: const Text('保存配置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 六、设置页面集成

### 6.1 设置页面改造

在现有设置页面的云同步区域新增 BoxSync 入口：

```dart
// settings_screen.dart 改造

// 数据管理区域
ListTile(
  leading: Icon(Icons.cloud_sync),
  title: const Text('云同步'),
  subtitle: Text(_getSyncStatus()),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => _showSyncOptions(),
),

void _showSyncOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.storage),
          title: const Text('WebDAV'),
          subtitle: Text(_webdavStatus),
          onTap: () => Navigator.pushNamed(context, '/webdav-config'),
        ),
        ListTile(
          leading: Icon(Icons.cloud),
          title: const Text('Nextcloud'),
          subtitle: Text(_nextcloudStatus),
          onTap: () => Navigator.pushNamed(context, '/nextcloud-config'),
        ),
        ListTile(
          leading: Icon(Icons.cloud_upload),
          title: const Text('百度云'),
          subtitle: Text(_baiduStatus),
          onTap: () => Navigator.pushNamed(context, '/baidu-config'),
        ),
        // 新增 BoxSync 入口
        ListTile(
          leading: Icon(Icons.dns),
          title: const Text('BoxSync 私有云'),
          subtitle: Text(_boxsyncStatus),
          onTap: () => Navigator.pushNamed(context, '/boxsync-config'),
        ),
      ],
    ),
  );
}
```

### 6.2 路由配置

```dart
// main.dart 路由扩展

MaterialApp(
  routes: {
    '/webdav-config': (context) => const WebDavConfigScreen(),
    '/nextcloud-config': (context) => const NextcloudConfigScreen(),
    '/baidu-config': (context) => const BaiduConfigScreen(),
    '/boxsync-config': (context) => const BoxSyncConfigScreen(),  // 新增
  },
);
```

---

## 七、同步策略

### 7.1 自动同步

沿用 v1.1.0 版本计划的自动同步策略：

| 触发时机 | 行为 |
|---------|------|
| 打开 App 时 | 若自动同步已开启且 BoxSync 已配置，自动同步 |
| 数据变更时 | 若自动同步已开启，自动上传变更 |
| 手动触发 | 提供上传/下载按钮 |

### 7.2 冲突处理

采用 **最后修改时间优先** 策略：

```dart
SyncDataWrapper? resolveConflict(
  SyncDataWrapper? local,
  SyncDataWrapper? cloud,
) {
  if (local == null) return cloud;
  if (cloud == null) return local;

  // 比较 lastSyncTime，取较新的
  final localTime = local.lastSyncTime ?? local.exportTime;
  final cloudTime = cloud.lastSyncTime ?? cloud.exportTime;

  if (localTime.isAfter(cloudTime)) {
    return local;
  } else if (cloudTime.isAfter(localTime)) {
    return cloud;
  } else {
    // 时间相同，提示用户选择
    return null; // 需要用户手动选择
  }
}
```

### 7.3 首次同步提醒

当用户在新设备首次配置 BoxSync 时：

```dart
void _showFirstSyncDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('首次云同步'),
      content: const Text('检测到这是首次使用 BoxSync 云同步。\n是否从云端下载数据？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('跳过'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _downloadFromCloud();
          },
          child: const Text('下载'),
        ),
      ],
    ),
  );
}
```

---

## 八、数据存储

### 8.1 SharedPreferences 存储

BoxSync 配置信息存储结构：

```json
{
  "sync_services": {
    "boxsync": {
      "enabled": false,
      "server_url": "",
      "username": "",
      "password": "",
      "token": "",
      "last_sync_time": null,
      "last_sync_status": "success"
    }
  }
}
```

### 8.2 安全存储建议

密码和 Token 建议使用 `flutter_secure_storage` 加密存储：

```yaml
# pubspec.yaml 新增依赖
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = FlutterSecureStorage();

Future<void> _saveToken(String token) async {
  await _secureStorage.write(key: 'boxsync_token', value: token);
}

Future<String?> _readToken() async {
  return await _secureStorage.read(key: 'boxsync_token');
}
```

---

## 九、依赖包

| 包名 | 用途 | 状态 |
|------|------|------|
| `http` 或 `dio` | HTTP 请求 | 已有 |
| `shared_preferences` | 配置存储 | 已有 |
| `flutter_secure_storage` | 安全存储 Token | **需新增** |

---

## 十、开发排期

| 阶段 | 内容 | 预计工时 |
|------|------|---------|
| P0 | SyncConfig 扩展 + BoxSyncConfig 模型 | 0.5 天 |
| P0 | BoxSyncSyncService 核心实现 | 1 天 |
| P1 | BoxSyncConfigScreen 配置页面 | 0.5 天 |
| P1 | 设置页面集成 + 路由配置 | 0.5 天 |
| P2 | 自动同步集成 + 冲突处理 | 1 天 |
| P2 | 安全存储集成（flutter_secure_storage） | 0.5 天 |
| P3 | 测试与修复 | 1 天 |

**总计预估：约 4.5 天**

---

## 十一、注意事项

1. **服务器地址格式**：用户输入的服务器地址需包含端口（如 `http://192.168.1.100:9390`）
2. **HTTPS 建议**：生产环境建议 BoxSync 服务器配置 HTTPS，客户端使用 HTTPS 地址
3. **Token 过期**：JWT Token 默认 24h 过期，需实现自动重新登录逻辑
4. **网络环境**：确保手机与 BoxSync 服务器在同一网络或服务器有公网访问能力
5. **数据大小**：Height4Kid 数据通常较小（< 100KB），适合 BoxSync 存储
6. **头像处理**：头像为本地文件路径，云同步时不包含头像文件本身，仅同步路径引用
7. **向后兼容**：保持与现有 WebDAV/Nextcloud/百度云同步架构一致，复用 SyncService 接口

---

## 十二、用户使用流程

### 12.1 服务器部署（管理员）

1. 部署 BoxSync 服务器（参考 BoxSync 开发方案）
2. 在管理后台创建 Height4Kid 用户账户
3. 将服务器地址和账户信息告知用户

### 12.2 客户端配置（用户）

1. 打开 Height4Kid 应用
2. 进入 设置 → 数据管理 → 云同步
3. 选择 "BoxSync 私有云"
4. 输入服务器地址、用户名、密码
5. 点击 "测试连接" 验证配置
6. 连接成功后点击 "保存配置"
7. 可选：开启自动同步

### 12.3 数据同步

- **自动同步**：开启后，每次打开 App 或数据变更时自动同步
- **手动上传**：点击 "上传数据到云端"
- **手动下载**：点击 "从云端下载数据"

---

## 十三、测试要点

| 测试项 | 验证内容 |
|--------|---------|
| 连接测试 | 正确/错误地址、正确/错误密码 |
| 登录流程 | Token 获取、Token 过期重新登录 |
| 数据上传 | 完整数据上传、覆盖更新 |
| 数据下载 | 下载解析、空数据处理 |
| 冲突处理 | 本地较新、云端较新、时间相同 |
| 网络异常 | 断网重试、超时处理 |
| Token 存储 | 安全存储、重启恢复 |
| 多设备同步 | 新设备首次下载、数据一致性 |