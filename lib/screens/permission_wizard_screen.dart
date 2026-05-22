import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../utils/permission_manager.dart';

class PermissionWizardScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionWizardScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<PermissionWizardScreen> createState() => _PermissionWizardScreenState();
}

class _PermissionWizardScreenState extends State<PermissionWizardScreen> {
  final PermissionManager _permissionManager = PermissionManager();
  bool _storageGranted = false;
  bool _cameraGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = await _permissionManager.checkAllPermissions();
    setState(() {
      _storageGranted = permissions['storage'] ?? false;
      _cameraGranted = permissions['camera'] ?? false;
      _isLoading = false;
    });

    if (_storageGranted && _cameraGranted) {
      widget.onComplete();
    }
  }

  Future<void> _requestStoragePermission() async {
    setState(() => _isLoading = true);
    final granted = await _permissionManager.requestStoragePermission();
    setState(() {
      _storageGranted = granted;
      _isLoading = false;
    });
    _checkAllGranted();
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _isLoading = true);
    final granted = await _permissionManager.requestCameraPermission();
    setState(() {
      _cameraGranted = granted;
      _isLoading = false;
    });
    _checkAllGranted();
  }

  void _checkAllGranted() {
    if (_storageGranted && _cameraGranted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.pinkBg, AppTheme.pinkHeroGradientStart],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.pinkPrimary, AppTheme.pinkSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.pinkPrimary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '权限设置',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '为了正常使用应用功能，需要获取以下权限',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textLight.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildPermissionItem(
                        icon: Icons.folder_open,
                        title: '存储权限',
                        description: '用于导入/导出数据、选择头像图片',
                        granted: _storageGranted,
                        onRequest: _requestStoragePermission,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.camera_alt,
                        title: '相机权限',
                        description: '用于拍照上传孩子头像',
                        granted: _cameraGranted,
                        onRequest: _requestCameraPermission,
                      ),
                      const SizedBox(height: 32),
                      if (!_storageGranted || !_cameraGranted)
                        Text(
                          '请点击上方按钮授予权限，或前往系统设置开启',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (!_storageGranted || !_cameraGranted)
                        const SizedBox(height: 16),
                      if (!_storageGranted || !_cameraGranted)
                        GestureDetector(
                          onTap: _openAppSettings,
                          child: Text(
                            '前往系统设置',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.pinkPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: CircularProgressIndicator(),
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

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: granted ? Colors.green.withValues(alpha: 0.05) : AppTheme.formBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: granted ? Colors.green.withValues(alpha: 0.3) : AppTheme.formBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: granted
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppTheme.pinkPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              granted ? Icons.check_circle : icon,
              color: granted ? Colors.green : AppTheme.pinkPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: granted ? Colors.green : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!granted)
            GestureDetector(
              onTap: onRequest,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.pinkPrimary, AppTheme.pinkSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '授权',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
