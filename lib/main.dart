import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'models/child.dart';

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
              '💡 建议先备份数据后再更新',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const Text(
                '更新内容:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              UpdateChecker.skipVersion(updateInfo.version);
              Navigator.pop(context);
            },
            child: const Text('跳过此版本'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后提醒'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(updateInfo.downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('前往更新'),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.navBg,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    label: '今日记录',
                    isActive: appProvider.currentPage == 'home',
                    onTap: () => appProvider.setPage('home'),
                  ),
                ),
                const SizedBox(width: 12),
                _AddButton(
                  onTap: () => appProvider.setPage('record'),
                  isPink: isPink,
                ),
                const SizedBox(width: 12),
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
          const SizedBox(height: 8),
          Container(
            width: 134,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
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
