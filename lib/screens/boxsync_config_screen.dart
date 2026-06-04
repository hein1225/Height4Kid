import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sync_config.dart';
import '../providers/app_provider.dart';
import '../services/boxsync_sync_service.dart';
import '../theme/app_theme.dart';

// 导出 CloudVersionInfo 供本文件使用
export '../models/sync_config.dart' show CloudVersionInfo;

/// BoxSync 配置页面
/// 配置自建的 BoxSync 私有云服务器
/// 项目地址: https://github.com/hein1225/BoxSync
class BoxSyncConfigScreen extends StatefulWidget {
  const BoxSyncConfigScreen({super.key});

  @override
  State<BoxSyncConfigScreen> createState() => _BoxSyncConfigScreenState();
}

class _BoxSyncConfigScreenState extends State<BoxSyncConfigScreen> {
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    final appProvider = context.read<AppProvider>();
    final config = appProvider.syncConfig.boxsync;

    _serverUrlController.text = config.serverUrl;
    _usernameController.text = config.username;
    _passwordController.text = config.password;

    if (config.isConfigured) {
      setState(() {
        _isConnected = true;
        _statusMessage = '上次同步: ${_formatLastSyncTime(config.lastSyncTime)}';
        _statusIsError = config.lastSyncStatus == SyncStatus.failed;
      });
    }
  }

  String _formatLastSyncTime(DateTime? time) {
    if (time == null) return '从未同步';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${time.month}月${time.day}日';
  }

  Future<void> _testConnection() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    final config = BoxSyncConfig(
      serverUrl: _serverUrlController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    final service = BoxSyncSyncService(config: config);
    final result = await service.testConnection();

    setState(() {
      _isConnecting = false;
      _isConnected = result.success;
      _statusMessage = result.message;
      _statusIsError = !result.success;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveConfig() async {
    final appProvider = context.read<AppProvider>();

    await appProvider.updateBoxSyncConfig(
      serverUrl: _serverUrlController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置已保存'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _performSync({required bool upload}) async {
    final appProvider = context.read<AppProvider>();

    if (upload) {
      // 上传到云端
      final result = await appProvider.syncToCloud(SyncServiceType.boxsync);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
        if (result.success) {
          setState(() {
            _statusMessage = '上次同步: 刚刚';
            _statusIsError = false;
          });
        }
      }
    } else {
      // 从云端下载 - 显示版本列表供选择
      await _showVersionSelectionDialog(appProvider);
    }
  }

  /// 显示云端版本列表供用户选择
  Future<void> _showVersionSelectionDialog(AppProvider appProvider) async {
    // 获取云端版本列表
    final versions = await appProvider.getCloudVersions(SyncServiceType.boxsync);

    if (!mounted) return;

    if (versions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('云端没有数据'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 显示版本选择对话框
    final selectedVersion = await showDialog<CloudVersionInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择要下载的版本'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return ListTile(
                title: Text('版本 ${version.version}'),
                subtitle: Text(
                  '同步时间: ${_formatDateTime(version.syncTime)}\n'
                  '数据大小: ${(version.dataSize / 1024).toStringAsFixed(1)} KB',
                ),
                trailing: version.isLatest
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '最新',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                onTap: () => Navigator.pop(context, version),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (selectedVersion == null || !mounted) return;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认下载'),
        content: Text(
          '您选择了版本 ${selectedVersion.version}，\n'
          '下载数据将覆盖当前所有数据，确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 下载选中的版本
    final result = await appProvider.downloadSpecificVersion(
      SyncServiceType.boxsync,
      'height4kid_sync_v${selectedVersion.version}.json',
    );

    if (!mounted) return;

    if (result.success && result.details != null) {
      // 导入数据
      final importSuccess = await appProvider.importData(result.details!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importSuccess ? '数据导入成功' : '数据导入失败'),
            backgroundColor: importSuccess ? Colors.green : Colors.red,
          ),
        );
        if (importSuccess) {
          setState(() {
            _statusMessage = '上次同步: 刚刚';
            _statusIsError = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final config = appProvider.syncConfig.boxsync;

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
          'BoxSync 私有云配置',
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
            // 配置说明
            _buildInfoCard(),
            const SizedBox(height: 24),

            // 服务器地址
            _buildTextField(
              controller: _serverUrlController,
              label: '服务器地址',
              hint: 'http://192.168.1.100:9390',
              icon: Icons.dns,
              helperText: '请输入 BoxSync 服务器完整地址，包含端口号',
            ),
            const SizedBox(height: 16),

            // 用户名
            _buildTextField(
              controller: _usernameController,
              label: '用户名',
              hint: '请输入用户名',
              icon: Icons.person,
              helperText: '服务器管理员创建的账户名',
            ),
            const SizedBox(height: 16),

            // 密码
            _buildTextField(
              controller: _passwordController,
              label: '密码',
              hint: '请输入密码',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textLight,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // 状态显示
            if (_statusMessage != null) _buildStatusCard(),
            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(),
            const SizedBox(height: 32),

            // 手动同步
            if (config.enabled && config.isConfigured) _buildSyncSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '配置说明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'BoxSync 是一个自建的私有云同步服务器，适合对数据隐私有更高要求的用户。'
            '您需要在服务器上部署 BoxSync 服务，然后在此处配置连接信息。',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
              height: 1.5,
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
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppTheme.textLight),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusIsError ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusIsError ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
            color: _statusIsError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: _statusIsError ? Colors.red[700] : Colors.green[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isConnecting ? null : _testConnection,
            icon: _isConnecting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering),
            label: Text(_isConnecting ? '连接中...' : '测试连接'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConnected ? _saveConfig : null,
            icon: const Icon(Icons.save),
            label: const Text('保存配置'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          '手动同步',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _performSync(upload: true),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('上传到云端'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _performSync(upload: false),
                icon: const Icon(Icons.cloud_download),
                label: const Text('从云端下载'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
