import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sync_config.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'webdav_config_screen.dart';
import 'nextcloud_config_screen.dart';
import 'boxsync_config_screen.dart';

/// 云同步管理页面
/// 集中管理所有云同步服务（WebDAV、Nextcloud、BoxSync）
class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final syncConfig = appProvider.syncConfig;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '云同步管理',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 重要提醒
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '云同步主要用于跨设备数据同步，无法代替本地备份。请仍然定期将数据导出备份到本地，防止云同步服务器异常导致数据丢失。',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 自动同步开关
            _buildAutoSyncCard(appProvider),
            const SizedBox(height: 24),

            // 云同步服务列表
            const Text(
              '选择云同步服务',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '只能启用一种云同步服务，启用新服务会自动禁用其他服务',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // BoxSync
            _buildServiceCard(
              type: SyncServiceType.boxsync,
              title: 'BoxSync',
              subtitle: '私有云同步服务器',
              icon: Icons.dns,
              color: Colors.purple,
              config: syncConfig.boxsync,
              onTap: () => _openConfigScreen(SyncServiceType.boxsync),
              onToggle: (enabled) => _toggleService(SyncServiceType.boxsync, enabled),
              onDelete: syncConfig.boxsync.isConfigured
                  ? () => _deleteService(SyncServiceType.boxsync)
                  : null,
            ),
            const SizedBox(height: 12),

            // WebDAV
            _buildServiceCard(
              type: SyncServiceType.webdav,
              title: 'WebDAV',
              subtitle: '支持坚果云、OwnCloud 等',
              icon: Icons.storage,
              color: Colors.blue,
              config: syncConfig.webdav,
              onTap: () => _openConfigScreen(SyncServiceType.webdav),
              onToggle: (enabled) => _toggleService(SyncServiceType.webdav, enabled),
              onDelete: syncConfig.webdav.isConfigured
                  ? () => _deleteService(SyncServiceType.webdav)
                  : null,
            ),
            const SizedBox(height: 12),

            // Nextcloud
            _buildServiceCard(
              type: SyncServiceType.nextcloud,
              title: 'Nextcloud',
              subtitle: '私有云存储服务',
              icon: Icons.cloud,
              color: Colors.teal,
              config: syncConfig.nextcloud,
              onTap: () => _openConfigScreen(SyncServiceType.nextcloud),
              onToggle: (enabled) => _toggleService(SyncServiceType.nextcloud, enabled),
              onDelete: syncConfig.nextcloud.isConfigured
                  ? () => _deleteService(SyncServiceType.nextcloud)
                  : null,
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildAutoSyncCard(AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.sync,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '自动同步',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '启动时及按设定间隔自动同步',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: appProvider.syncConfig.autoSyncEnabled,
                onChanged: (value) => appProvider.setAutoSyncEnabled(value),
                activeColor: AppTheme.primary,
              ),
            ],
          ),
          if (appProvider.syncConfig.autoSyncEnabled) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: AppTheme.textLight.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '检查间隔',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.textLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AutoSyncInterval>(
                        value: appProvider.syncConfig.autoSyncInterval,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.textLight.withValues(alpha: 0.7),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AutoSyncInterval.hourly,
                            child: Text('1小时'),
                          ),
                          DropdownMenuItem(
                            value: AutoSyncInterval.twoHours,
                            child: Text('2小时'),
                          ),
                          DropdownMenuItem(
                            value: AutoSyncInterval.sixHours,
                            child: Text('6小时'),
                          ),
                          DropdownMenuItem(
                            value: AutoSyncInterval.twelveHours,
                            child: Text('12小时'),
                          ),
                          DropdownMenuItem(
                            value: AutoSyncInterval.daily,
                            child: Text('24小时'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appProvider.setAutoSyncInterval(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required SyncServiceType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required dynamic config,
    required VoidCallback onTap,
    required Function(bool) onToggle,
    VoidCallback? onDelete,
  }) {
    final isConfigured = config.isConfigured;
    final isEnabled = config.enabled;

    // 检查是否有其他服务已启用
    final appProvider = context.read<AppProvider>();
    final syncConfig = appProvider.syncConfig;
    final hasOtherServiceEnabled = syncConfig.enabledServices.isNotEmpty &&
        !syncConfig.enabledServices.contains(type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              isConfigured ? subtitle : '点击配置',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 状态指示灯
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnabled
                        ? Colors.green
                        : (isConfigured ? Colors.orange : Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
              ],
            ),
            onTap: onTap,
          ),
          if (isConfigured) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnabled ? '已启用' : '已配置（未启用）',
                          style: TextStyle(
                            fontSize: 12,
                            color: isEnabled ? Colors.green : Colors.orange,
                          ),
                        ),
                        if (config.lastSyncTime != null)
                          Text(
                            '上次同步: ${_formatLastSyncTime(config.lastSyncTime)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 启用/禁用开关
                  Switch(
                    value: isEnabled,
                    onChanged: hasOtherServiceEnabled
                        ? null
                        : (value) => onToggle(value),
                    activeColor: color,
                  ),
                  // 删除按钮
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: '删除配置',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastSyncTime(DateTime? time) {
    if (time == null) return '从未';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${time.month}月${time.day}日';
  }

  Widget _buildDeployInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'BoxSync 私有服务器部署',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'BoxSync 是一个开源的私有云同步服务器，您可以在自己的服务器上部署，实现完全自主可控的数据同步。',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildDeployStep('1', '准备服务器', '需要一台可以访问的服务器（云服务器或本地服务器）'),
          _buildDeployStep('2', '安装 Docker', '在服务器上安装 Docker 和 Docker Compose'),
          _buildDeployStep('3', '部署 BoxSync', '克隆项目并启动服务'),
          _buildDeployStep('4', '配置用户', '在管理后台创建同步账户'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '快速部署命令：',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'git clone https://github.com/hein1225/BoxSync.git\n'
                  'cd BoxSync\n'
                  'docker-compose up -d',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 可以打开项目地址
            },
            child: Text(
              '项目地址: https://github.com/hein1225/BoxSync',
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeployStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openConfigScreen(SyncServiceType type) {
    Widget screen;
    switch (type) {
      case SyncServiceType.boxsync:
        screen = const BoxSyncConfigScreen();
        break;
      case SyncServiceType.webdav:
        screen = const WebDAVConfigScreen();
        break;
      case SyncServiceType.nextcloud:
        screen = const NextcloudConfigScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      // 返回后刷新页面
      setState(() {});
    });
  }

  Future<void> _toggleService(SyncServiceType type, bool enabled) async {
    final appProvider = context.read<AppProvider>();

    if (enabled) {
      // 启用服务
      switch (type) {
        case SyncServiceType.boxsync:
          final config = appProvider.syncConfig.boxsync.copyWith(enabled: true);
          await appProvider.updateBoxSyncConfig(
            serverUrl: config.serverUrl,
            username: config.username,
            password: config.password,
            enabled: true,
          );
          break;
        case SyncServiceType.webdav:
          final config = appProvider.syncConfig.webdav.copyWith(enabled: true);
          await appProvider.updateWebDAVConfig(config);
          break;
        case SyncServiceType.nextcloud:
          final config = appProvider.syncConfig.nextcloud.copyWith(enabled: true);
          await appProvider.updateNextcloudConfig(config);
          break;
      }
    } else {
      // 禁用服务
      switch (type) {
        case SyncServiceType.boxsync:
          final config = appProvider.syncConfig.boxsync.copyWith(enabled: false);
          await appProvider.updateBoxSyncConfig(
            serverUrl: config.serverUrl,
            username: config.username,
            password: config.password,
            enabled: false,
          );
          break;
        case SyncServiceType.webdav:
          final config = appProvider.syncConfig.webdav.copyWith(enabled: false);
          await appProvider.updateWebDAVConfig(config);
          break;
        case SyncServiceType.nextcloud:
          final config = appProvider.syncConfig.nextcloud.copyWith(enabled: false);
          await appProvider.updateNextcloudConfig(config);
          break;
      }
    }
  }

  Future<void> _deleteService(SyncServiceType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后将清除该云同步的所有配置信息，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appProvider = context.read<AppProvider>();
      switch (type) {
        case SyncServiceType.boxsync:
          await appProvider.clearBoxSyncConfig();
          break;
        case SyncServiceType.webdav:
          await appProvider.clearWebDAVConfig();
          break;
        case SyncServiceType.nextcloud:
          await appProvider.clearNextcloudConfig();
          break;
      }
    }
  }
}
