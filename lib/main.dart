import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/history_screen.dart';
import 'screens/children_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/permission_wizard_screen.dart';
import 'utils/permission_manager.dart';
import 'utils/update_checker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeightKidApp());
}

class HeightKidApp extends StatefulWidget {
  const HeightKidApp({super.key});

  @override
  State<HeightKidApp> createState() => _HeightKidAppState();
}

class _HeightKidAppState extends State<HeightKidApp> {
  bool _permissionsChecked = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Web端不需要权限检查
    if (kIsWeb) {
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = true;
      });
      return;
    }
    
    if (Platform.isAndroid) {
      // 检查所有权限状态，不立即请求
      final permissions = await PermissionManager().checkAllPermissions();
      final allGranted = permissions.values.every((granted) => granted);
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = allGranted;
      });
    } else {
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = true;
      });
    }
  }

  void _onPermissionsComplete() {
    setState(() {
      _permissionsGranted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // 等待数据加载完成
          if (!appProvider.isInitialized || !_permissionsChecked) {
            return MaterialApp(
              title: '海因成长助手',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.pinkTheme,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh', 'CN'),
                Locale('en', 'US'),
              ],
              locale: const Locale('zh', 'CN'),
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          final isPink = appProvider.currentTheme == 'pink';
          final themeData = isPink ? AppTheme.pinkTheme : AppTheme.blueTheme;

          // 如果权限未授予，显示权限向导
          if (!_permissionsGranted) {
            return MaterialApp(
              title: '海因成长助手',
              debugShowCheckedModeBanner: false,
              theme: themeData,
              home: PermissionWizardScreen(onComplete: _onPermissionsComplete),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh', 'CN'),
                Locale('en', 'US'),
              ],
              locale: const Locale('zh', 'CN'),
            );
          }

          return MaterialApp(
            title: '海因成长助手',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: const MainScreen(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            locale: const Locale('zh', 'CN'),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟检查更新，等待页面加载完成
    Future.delayed(const Duration(seconds: 2), () {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    final updateInfo = await UpdateChecker.checkUpdate();
    if (updateInfo != null && updateInfo.hasUpdate && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    // 在Web端或非Android平台，显示简单的更新提示
    if (kIsWeb || !Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
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
              Text('当前版本: ${UpdateChecker.currentVersion}'),
              Text('最新版本: ${updateInfo.version}'),
              const SizedBox(height: 12),
              const Text(
                '请访问GitHub下载最新版本',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }

    // Android端显示自动更新对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdateDialog(updateInfo: updateInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';

        // 检查是否没有孩子，显示空状态
        if (appProvider.kids.isEmpty && appProvider.currentPage == 'home') {
          return _buildEmptyState(context, appProvider, isPink);
        }

        Widget body;
        switch (appProvider.currentPage) {
          case 'record':
            body = const RecordScreen();
            break;
          case 'history':
            body = const HistoryScreen();
            break;
          case 'kids':
            body = const ChildrenScreen();
            break;
          case 'settings':
            body = const SettingsScreen();
            break;
          default:
            body = const HomeScreen();
        }

        final showBottomNav = appProvider.currentPage != 'kids'
            && appProvider.currentPage != 'settings'
            && appProvider.currentPage != 'record';

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPink
                    ? [AppTheme.pinkBg, AppTheme.pinkHeroGradientStart]
                    : [AppTheme.blueBg, AppTheme.blueHeroGradientStart],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 80,
                        offset: const Offset(0, 30),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Column(
                      children: [
                        Expanded(child: body),
                        if (showBottomNav) _buildBottomNav(context, appProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建空状态页面（首次进入，没有孩子时）
  Widget _buildEmptyState(BuildContext context, AppProvider appProvider, bool isPink) {
    final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPink
                ? [AppTheme.pinkBg, AppTheme.pinkHeroGradientStart]
                : [AppTheme.blueBg, AppTheme.blueHeroGradientStart],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 80,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 图标
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPink
                                ? [AppTheme.pinkPrimary, AppTheme.pinkSecondary]
                                : [AppTheme.bluePrimary, AppTheme.blueSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 标题
                      Text(
                        '欢迎使用海因成长助手',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // 描述
                      Text(
                        '记录孩子成长的每一个瞬间\n请先添加孩子的基本信息',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // 添加孩子按钮
                      GestureDetector(
                        onTap: () => appProvider.setPage('kids'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPink
                                  ? [AppTheme.pinkPrimary, AppTheme.pinkSecondary]
                                  : [AppTheme.bluePrimary, AppTheme.blueSecondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '添加孩子信息',
                                style: TextStyle(
                                  fontSize: 18,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppProvider appProvider) {
    final isPink = appProvider.currentTheme == 'pink';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.navBg,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                label: '今日记录',
                isActive: appProvider.currentPage == 'home',
                onTap: () => appProvider.setPage('home'),
              ),
            ),
            const SizedBox(width: 8),
            _AddButton(
              onTap: () => appProvider.setPage('record'),
              isPink: isPink,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NavButton(
                label: '历史记录',
                isActive: appProvider.currentPage == 'history',
                onTap: () => appProvider.setPage('history'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPink;

  const _AddButton({
    required this.onTap,
    required this.isPink,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
    final secondaryColor = isPink ? AppTheme.pinkSecondary : AppTheme.blueSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// 自动更新对话框
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
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后更新'),
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
