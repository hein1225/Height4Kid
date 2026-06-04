import 'dart:convert';

/// 同步服务类型
enum SyncServiceType {
  boxsyncPublic,
  webdav,
  nextcloud,
  boxsync,
}

/// 同步服务类型扩展
extension SyncServiceTypeExtension on SyncServiceType {
  String get serviceName {
    switch (this) {
      case SyncServiceType.boxsyncPublic:
        return 'BoxSync（公共服务区）';
      case SyncServiceType.webdav:
        return 'WebDAV';
      case SyncServiceType.nextcloud:
        return 'Nextcloud';
      case SyncServiceType.boxsync:
        return 'BoxSync（私有服务器）';
    }
  }
}

/// 同步状态
enum SyncStatus {
  success,
  failed,
  syncing,
  notConfigured,
}

/// 自动同步时间间隔（小时）
enum AutoSyncInterval {
  hourly,    // 1小时
  twoHours,  // 2小时
  sixHours,  // 6小时
  twelveHours, // 12小时
  daily,     // 24小时
}

/// 自动同步时间间隔扩展
extension AutoSyncIntervalExtension on AutoSyncInterval {
  String get displayName {
    switch (this) {
      case AutoSyncInterval.hourly:
        return '1小时';
      case AutoSyncInterval.twoHours:
        return '2小时';
      case AutoSyncInterval.sixHours:
        return '6小时';
      case AutoSyncInterval.twelveHours:
        return '12小时';
      case AutoSyncInterval.daily:
        return '24小时';
    }
  }

  int get hours {
    switch (this) {
      case AutoSyncInterval.hourly:
        return 1;
      case AutoSyncInterval.twoHours:
        return 2;
      case AutoSyncInterval.sixHours:
        return 6;
      case AutoSyncInterval.twelveHours:
        return 12;
      case AutoSyncInterval.daily:
        return 24;
    }
  }
}

/// WebDAV 配置
class WebDAVConfig {
  String serverUrl;
  String username;
  String password;
  String remotePath;
  bool enabled;
  DateTime? lastSyncTime;
  SyncStatus lastSyncStatus;

  WebDAVConfig({
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.remotePath = '/height4kid/',
    this.enabled = false,
    this.lastSyncTime,
    this.lastSyncStatus = SyncStatus.notConfigured,
  });

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'remotePath': remotePath,
      'enabled': enabled,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'lastSyncStatus': lastSyncStatus.name,
    };
  }

  factory WebDAVConfig.fromJson(Map<String, dynamic> json) {
    return WebDAVConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      remotePath: json['remotePath'] as String? ?? '/height4kid/',
      enabled: json['enabled'] as bool? ?? false,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      lastSyncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['lastSyncStatus'] as String? ?? 'notConfigured'),
        orElse: () => SyncStatus.notConfigured,
      ),
    );
  }

  WebDAVConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? remotePath,
    bool? enabled,
    DateTime? lastSyncTime,
    SyncStatus? lastSyncStatus,
  }) {
    return WebDAVConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      remotePath: remotePath ?? this.remotePath,
      enabled: enabled ?? this.enabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  bool get isConfigured =>
      serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}

/// Nextcloud 配置
class NextcloudConfig {
  String serverUrl;
  String username;
  String password;
  String remotePath;
  bool enabled;
  DateTime? lastSyncTime;
  SyncStatus lastSyncStatus;

  NextcloudConfig({
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.remotePath = '/Apps/Height4Kid/',
    this.enabled = false,
    this.lastSyncTime,
    this.lastSyncStatus = SyncStatus.notConfigured,
  });

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'remotePath': remotePath,
      'enabled': enabled,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'lastSyncStatus': lastSyncStatus.name,
    };
  }

  factory NextcloudConfig.fromJson(Map<String, dynamic> json) {
    return NextcloudConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      remotePath: json['remotePath'] as String? ?? '/Apps/Height4Kid/',
      enabled: json['enabled'] as bool? ?? false,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      lastSyncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['lastSyncStatus'] as String? ?? 'notConfigured'),
        orElse: () => SyncStatus.notConfigured,
      ),
    );
  }

  NextcloudConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? remotePath,
    bool? enabled,
    DateTime? lastSyncTime,
    SyncStatus? lastSyncStatus,
  }) {
    return NextcloudConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      remotePath: remotePath ?? this.remotePath,
      enabled: enabled ?? this.enabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  bool get isConfigured =>
      serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}

/// BoxSync 配置
class BoxSyncConfig {
  String serverUrl;
  String username;
  String password;
  String? token;
  bool enabled;
  DateTime? lastSyncTime;
  SyncStatus lastSyncStatus;

  BoxSyncConfig({
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.token,
    this.enabled = false,
    this.lastSyncTime,
    this.lastSyncStatus = SyncStatus.notConfigured,
  });

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'token': token,
      'enabled': enabled,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'lastSyncStatus': lastSyncStatus.name,
    };
  }

  factory BoxSyncConfig.fromJson(Map<String, dynamic> json) {
    return BoxSyncConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      token: json['token'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      lastSyncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['lastSyncStatus'] as String? ?? 'notConfigured'),
        orElse: () => SyncStatus.notConfigured,
      ),
    );
  }

  BoxSyncConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? token,
    bool? enabled,
    DateTime? lastSyncTime,
    SyncStatus? lastSyncStatus,
  }) {
    return BoxSyncConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      enabled: enabled ?? this.enabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  bool get isConfigured =>
      serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}

/// BoxSync 公共服务区配置
class BoxSyncPublicConfig {
  static const String defaultServerUrl = 'https://sync.hyc5069.top/';
  static const String registrationUrl = 'https://sync.hyc5069.top/register';

  String username;
  String password;
  String? token;
  bool enabled;
  DateTime? lastSyncTime;
  SyncStatus lastSyncStatus;

  BoxSyncPublicConfig({
    this.username = '',
    this.password = '',
    this.token,
    this.enabled = false,
    this.lastSyncTime,
    this.lastSyncStatus = SyncStatus.notConfigured,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'token': token,
      'enabled': enabled,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'lastSyncStatus': lastSyncStatus.name,
    };
  }

  factory BoxSyncPublicConfig.fromJson(Map<String, dynamic> json) {
    return BoxSyncPublicConfig(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      token: json['token'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      lastSyncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['lastSyncStatus'] as String? ?? 'notConfigured'),
        orElse: () => SyncStatus.notConfigured,
      ),
    );
  }

  BoxSyncPublicConfig copyWith({
    String? username,
    String? password,
    String? token,
    bool? enabled,
    DateTime? lastSyncTime,
    SyncStatus? lastSyncStatus,
  }) {
    return BoxSyncPublicConfig(
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      enabled: enabled ?? this.enabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  bool get isConfigured => username.isNotEmpty && password.isNotEmpty;
}

/// 同步配置管理
class SyncConfig {
  bool autoSyncEnabled;
  AutoSyncInterval autoSyncInterval;
  WebDAVConfig webdav;
  NextcloudConfig nextcloud;
  BoxSyncConfig boxsync;
  BoxSyncPublicConfig boxsyncPublic;

  SyncConfig({
    this.autoSyncEnabled = false,
    this.autoSyncInterval = AutoSyncInterval.daily,
    WebDAVConfig? webdav,
    NextcloudConfig? nextcloud,
    BoxSyncConfig? boxsync,
    BoxSyncPublicConfig? boxsyncPublic,
  })  : webdav = webdav ?? WebDAVConfig(),
        nextcloud = nextcloud ?? NextcloudConfig(),
        boxsync = boxsync ?? BoxSyncConfig(),
        boxsyncPublic = boxsyncPublic ?? BoxSyncPublicConfig();

  Map<String, dynamic> toJson() {
    return {
      'autoSyncEnabled': autoSyncEnabled,
      'autoSyncInterval': autoSyncInterval.name,
      'webdav': webdav.toJson(),
      'nextcloud': nextcloud.toJson(),
      'boxsync': boxsync.toJson(),
      'boxsyncPublic': boxsyncPublic.toJson(),
    };
  }

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    return SyncConfig(
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? false,
      autoSyncInterval: AutoSyncInterval.values.firstWhere(
        (e) => e.name == (json['autoSyncInterval'] as String? ?? 'daily'),
        orElse: () => AutoSyncInterval.daily,
      ),
      webdav: json['webdav'] != null
          ? WebDAVConfig.fromJson(json['webdav'] as Map<String, dynamic>)
          : WebDAVConfig(),
      nextcloud: json['nextcloud'] != null
          ? NextcloudConfig.fromJson(json['nextcloud'] as Map<String, dynamic>)
          : NextcloudConfig(),
      boxsync: json['boxsync'] != null
          ? BoxSyncConfig.fromJson(json['boxsync'] as Map<String, dynamic>)
          : BoxSyncConfig(),
      boxsyncPublic: json['boxsyncPublic'] != null
          ? BoxSyncPublicConfig.fromJson(json['boxsyncPublic'] as Map<String, dynamic>)
          : BoxSyncPublicConfig(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SyncConfig.fromJsonString(String jsonString) {
    return SyncConfig.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  SyncConfig copyWith({
    bool? autoSyncEnabled,
    AutoSyncInterval? autoSyncInterval,
    WebDAVConfig? webdav,
    NextcloudConfig? nextcloud,
    BoxSyncConfig? boxsync,
    BoxSyncPublicConfig? boxsyncPublic,
  }) {
    return SyncConfig(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      webdav: webdav ?? this.webdav,
      nextcloud: nextcloud ?? this.nextcloud,
      boxsync: boxsync ?? this.boxsync,
      boxsyncPublic: boxsyncPublic ?? this.boxsyncPublic,
    );
  }

  /// 获取已启用的同步服务列表
  List<SyncServiceType> get enabledServices {
    final services = <SyncServiceType>[];
    if (boxsyncPublic.enabled && boxsyncPublic.isConfigured) services.add(SyncServiceType.boxsyncPublic);
    if (webdav.enabled && webdav.isConfigured) services.add(SyncServiceType.webdav);
    if (nextcloud.enabled && nextcloud.isConfigured) services.add(SyncServiceType.nextcloud);
    if (boxsync.enabled && boxsync.isConfigured) services.add(SyncServiceType.boxsync);
    return services;
  }

  /// 检查是否有任何同步服务已配置
  bool get hasAnyServiceConfigured {
    return boxsyncPublic.isConfigured || webdav.isConfigured || nextcloud.isConfigured || boxsync.isConfigured;
  }
}

/// 云端数据版本信息
class CloudVersionInfo {
  final String version;
  final DateTime syncTime;
  final int dataSize;
  final bool isLatest;

  CloudVersionInfo({
    required this.version,
    required this.syncTime,
    required this.dataSize,
    this.isLatest = false,
  });
}

/// 同步日志条目
class SyncLogEntry {
  final DateTime timestamp;
  final SyncServiceType service;
  final SyncStatus status;
  final String message;
  final String? details;

  SyncLogEntry({
    required this.timestamp,
    required this.service,
    required this.status,
    required this.message,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'service': service.name,
      'status': status.name,
      'message': message,
      'details': details,
    };
  }
}
