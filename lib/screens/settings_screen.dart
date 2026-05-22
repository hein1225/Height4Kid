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
                    _buildSectionTitle('主题设置'),
                    const SizedBox(height: 16),
                    _buildThemeSelector(appProvider, isPink),
                    const SizedBox(height: 32),
                    _buildSectionTitle('数据管理'),
                    const SizedBox(height: 16),
                    _buildDataActions(context, appProvider, primaryColor, secondaryColor),
                    const SizedBox(height: 32),
                    _buildSectionTitle('关于'),
                    const SizedBox(height: 16),
                    _buildAboutCard(),
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

  Widget _buildThemeSelector(AppProvider appProvider, bool isPink) {
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => appProvider.setTheme('pink'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: isPink
                      ? const LinearGradient(
                          colors: [AppTheme.pinkPrimary, AppTheme.pinkSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isPink ? null : AppTheme.formBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isPink
                      ? [
                          BoxShadow(
                            color: AppTheme.pinkPrimary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: isPink ? Colors.white : AppTheme.pinkPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '粉色主题',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPink ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => appProvider.setTheme('blue'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: !isPink
                      ? const LinearGradient(
                          colors: [AppTheme.bluePrimary, AppTheme.blueSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isPink ? null : AppTheme.formBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isPink
                      ? [
                          BoxShadow(
                            color: AppTheme.bluePrimary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: !isPink ? Colors.white : AppTheme.bluePrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '蓝色主题',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: !isPink ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildAboutCard() {
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
            '版本 1.0.0',
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
          const SizedBox(height: 12),
          // GitHub 地址 - 可点击
          GestureDetector(
            onTap: () => _launchUrl('https://github.com/hein1225/Height4Kid'),
            child: Container(
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
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.code,
                        size: 16,
                        color: Color(0xFF24292E),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'GitHub',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24292E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'https://github.com/hein1225/Height4Kid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0366D6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Star 提示 - 可点击
          GestureDetector(
            onTap: () => _launchUrl('https://github.com/hein1225/Height4Kid'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '请给予 Star 支持',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
