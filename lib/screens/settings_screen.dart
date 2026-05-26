import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/permission_manager.dart';
import '../utils/update_checker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
        final secondaryColor = isPink ? AppTheme.pinkSecondary : AppTheme.blueSecondary;

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_ios,
                    onTap: () => appProvider.setPage('home'),
                  ),
                  const Text(
                    '设置',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('数据管理'),
                    const SizedBox(height: 16),
                    _buildDataActions(context, appProvider, primaryColor, secondaryColor),
                    const SizedBox(height: 32),
                    _buildSectionTitle('关于'),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }

  // Launch URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Export data to local file
  Future<void> _exportData(BuildContext context, AppProvider appProvider) async {
    try {
      if (Platform.isAndroid) {
        final granted = await PermissionManager().requestStoragePermission();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('需要存储权限才能导出数据'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final jsonData = await appProvider.exportData();
      if (jsonData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('导出数据失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Use file_saver to save with directory selection
      final bytes = Uint8List.fromList(utf8.encode(jsonData));
      final fileName = 'height4kid_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final String? filePath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.json,
      );

      if (filePath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据已保存到: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Import data from local file
  Future<void> _importData(BuildContext context, AppProvider appProvider) async {
    try {
      if (Platform.isAndroid) {
        final granted = await PermissionManager().requestStoragePermission();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('需要存储权限才能导入数据'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final jsonString = utf8.decode(file.bytes!);
          
          if (context.mounted) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('确认导入'),
                content: const Text('导入数据将覆盖当前所有数据，确定要继续吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              final success = await appProvider.importData(jsonString);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '数据导入成功' : '数据导入失败，请检查文件格式'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDataActions(
    BuildContext context,
    AppProvider appProvider,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.file_upload,
            label: '导出数据',
            color: primaryColor,
            onTap: () => _exportData(context, appProvider),
          ),
          Divider(height: 1, color: AppTheme.formBorder),
          _buildActionItem(
            icon: Icons.file_download,
            label: '导入数据',
            color: AppTheme.weightColor,
            onTap: () => _importData(context, appProvider),
          ),
          Divider(height: 1, color: AppTheme.formBorder),
          _buildActionItem(
            icon: Icons.delete_outline,
            label: '清除所有数据',
            color: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认清除'),
                  content: const Text('确定要清除所有数据吗？此操作不可恢复。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        appProvider.clearAllData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('数据已清除'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.pinkPrimary, AppTheme.pinkSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.pinkPrimary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.child_care,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '海因成长助手',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '版本 ${UpdateChecker.currentVersion}',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '记录孩子成长的每一个瞬间',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textLight.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          // 检查更新按钮区域
          Row(
            children: [
              // 国内渠道检查更新
              Expanded(
                child: _buildChannelUpdateButton(
                  context,
                  channel: UpdateChannel.gitcode,
                  label: '国内渠道检查',
                  icon: Icons.speed,
                  color: const Color(0xFF2E8B57),
                ),
              ),
              const SizedBox(width: 12),
              // GitHub渠道检查更新
              Expanded(
                child: _buildChannelUpdateButton(
                  context,
                  channel: UpdateChannel.github,
                  label: 'GitHub检查',
                  icon: Icons.public,
                  color: const Color(0xFF24292E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          // 作者信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppTheme.textLight.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                '作者：海因茨',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 给星支持提示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: const Color(0xFFFFA500).withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '给星支持',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLight.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 国内渠道 - GitCode
          GestureDetector(
            onTap: () => _launchUrl(UpdateChecker.updateChannels[0].starUrl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.code,
                        size: 16,
                        color: Color(0xFF2E8B57),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '国内渠道 (GitCode)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UpdateChecker.updateChannels[0].starUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E8B57),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // GitHub 渠道
          GestureDetector(
            onTap: () => _launchUrl(UpdateChecker.updateChannels[1].starUrl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF24292E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0366D6).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.code,
                        size: 16,
                        color: Color(0xFF24292E),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'GitHub渠道',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24292E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UpdateChecker.updateChannels[1].starUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0366D6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建指定渠道的检查更新按钮
  Widget _buildChannelUpdateButton(
    BuildContext context, {
    required UpdateChannel channel,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecking = false;

        return GestureDetector(
          onTap: isChecking
              ? null
              : () async {
                  setState(() => isChecking = true);

                  UpdateInfo? updateInfo;
                  if (channel == UpdateChannel.gitcode) {
                    updateInfo = await UpdateChecker.checkGitCodeUpdate();
                  } else {
                    updateInfo = await UpdateChecker.checkGitHubUpdate();
                  }

                  if (context.mounted) {
                    setState(() => isChecking = false);

                    if (updateInfo == null) {
                      // 检查失败
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label失败，请检查网络连接'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (updateInfo.hasUpdate) {
                      // 有新版本
                      _showUpdateDialog(context, updateInfo);
                    } else {
                      // 已经是最新版本
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('当前已是最新版本 (${UpdateChecker.currentVersion})'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isChecking)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                const SizedBox(width: 6),
                Text(
                  isChecking ? '检查中' : label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示更新对话框
  void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdateDialog(updateInfo: updateInfo),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const _UpdateDialog({required this.updateInfo});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _downloadProgress = 0;
  String? _errorMessage;
  String? _downloadedFilePath;

  /// 第一步：下载APK
  Future<void> _downloadApk() async {
    if (widget.updateInfo.apkDownloadUrl == null) {
      setState(() {
        _errorMessage = '未找到APK下载链接';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    final filePath = await UpdateChecker.downloadApk(
      widget.updateInfo.apkDownloadUrl!,
      widget.updateInfo.version,
      (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
    );

    if (filePath == null) {
      setState(() {
        _isDownloading = false;
        _errorMessage = '下载失败，请检查网络后重试';
      });
    } else {
      setState(() {
        _isDownloading = false;
        _downloadedFilePath = filePath;
      });
      // 下载成功，自动进入安装步骤
      await _installApk();
    }
  }

  /// 第二步：安装APK
  Future<void> _installApk() async {
    if (_downloadedFilePath == null) {
      setState(() {
        _errorMessage = '安装文件不存在，请重新下载';
      });
      return;
    }

    setState(() {
      _isInstalling = true;
      _errorMessage = null;
    });

    final success = await UpdateChecker.installApk(_downloadedFilePath!);

    setState(() {
      _isInstalling = false;
    });

    if (!success) {
      setState(() {
        _errorMessage = '安装失败，请检查是否允许安装未知应用后重试';
      });
    } else {
      // 安装成功，关闭对话框
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: Colors.green, size: 28),
          const SizedBox(width: 8),
          const Text('发现新版本'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.updateInfo.channel == UpdateChannel.gitcode
                      ? const Color(0xFF2E8B57).withValues(alpha: 0.1)
                      : const Color(0xFF24292E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.updateInfo.channel == UpdateChannel.gitcode
                        ? const Color(0xFF2E8B57)
                        : const Color(0xFF24292E),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.updateInfo.channel == UpdateChannel.gitcode
                          ? Icons.speed
                          : Icons.public,
                      size: 14,
                      color: widget.updateInfo.channel == UpdateChannel.gitcode
                          ? const Color(0xFF2E8B57)
                          : const Color(0xFF24292E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.updateInfo.channel == UpdateChannel.gitcode
                          ? '国内渠道'
                          : 'GitHub渠道',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.updateInfo.channel == UpdateChannel.gitcode
                            ? const Color(0xFF2E8B57)
                            : const Color(0xFF24292E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('当前版本: ${UpdateChecker.currentVersion}'),
          Text('最新版本: ${widget.updateInfo.version}'),
          const SizedBox(height: 12),
          const Text(
            '💡 建议先备份数据后再更新',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.updateInfo.releaseNotes.isNotEmpty) ...[
            const Text(
              '更新内容:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: Text(
                  widget.updateInfo.releaseNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _downloadProgress),
            const SizedBox(height: 8),
            Text(
              '下载中: ${(_downloadProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (_isInstalling) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              '正在安装，请允许安装权限...',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading && !_isInstalling) ...[
          TextButton(
            onPressed: () {
              UpdateChecker.skipVersion(widget.updateInfo.version);
              Navigator.pop(context);
            },
            child: const Text('跳过此版本'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后提醒'),
          ),
          if (_downloadedFilePath == null)
            ElevatedButton(
              onPressed: _downloadApk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 40),
              ),
              child: const Text('立即更新'),
            )
          else
            ElevatedButton(
              onPressed: _installApk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 40),
              ),
              child: const Text('立即安装'),
            ),
        ] else if (_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('后台下载'),
          ),
        ] else if (_isInstalling) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('后台安装'),
          ),
        ],
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}
