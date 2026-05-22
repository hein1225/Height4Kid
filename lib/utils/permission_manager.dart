import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+: 请求照片权限（用于选择图片）
        final photosStatus = await Permission.photos.request();
        return photosStatus.isGranted || photosStatus.isLimited;
      } else if (sdkInt >= 30) {
        // Android 11-12: 请求存储权限
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<bool> requestCameraPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return true;
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      bool storageGranted;
      if (sdkInt >= 33) {
        final photosStatus = await Permission.photos.status;
        storageGranted = photosStatus.isGranted || photosStatus.isLimited;
      } else {
        storageGranted = await Permission.storage.isGranted;
      }

      return {
        'storage': storageGranted,
        'camera': await Permission.camera.isGranted,
      };
    }
    return {'storage': true, 'camera': true};
  }

  Future<bool> areAllPermissionsGranted() async {
    final permissions = await checkAllPermissions();
    return permissions.values.every((granted) => granted);
  }

  Future<bool> requestAllPermissions() async {
    final storage = await requestStoragePermission();
    final camera = await requestCameraPermission();
    return storage && camera;
  }
}
