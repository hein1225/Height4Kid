import 'dart:async';
import 'package:flutter/services.dart';

/// 百度网盘 SDK 服务
/// 通过 Method Channel 调用原生 Android SDK
class BaiduSDKService {
  static const MethodChannel _channel = MethodChannel(
    'com.heinci.height4kid/baidu_sdk',
  );

  static final BaiduSDKService _instance = BaiduSDKService._internal();
  factory BaiduSDKService() => _instance;
  BaiduSDKService._internal();

  /// 初始化百度 SDK
  /// [appKey] - 百度开放平台 App Key
  /// [secretKey] - 百度开放平台 Secret Key
  Future<bool> initialize(String appKey, String secretKey) async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize', {
        'appKey': appKey,
        'secretKey': secretKey,
      });
      return result ?? false;
    } catch (e) {
      print('百度 SDK 初始化失败: $e');
      return false;
    }
  }

  /// 检查是否已授权
  Future<bool> isAuthorized() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAuthorized');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 启动授权登录
  /// 返回授权结果，包含 accessToken 和 refreshToken
  Future<Map<String, dynamic>?> authorize() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'authorize',
      );
      if (result != null) {
        return {
          'accessToken': result['accessToken'],
          'refreshToken': result['refreshToken'],
          'expiresIn': result['expiresIn'],
          'scope': result['scope'],
        };
      }
      return null;
    } catch (e) {
      print('百度授权失败: $e');
      return null;
    }
  }

  /// 刷新 Access Token
  Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'refreshToken',
        {'refreshToken': refreshToken},
      );
      if (result != null) {
        return {
          'accessToken': result['accessToken'],
          'refreshToken': result['refreshToken'],
          'expiresIn': result['expiresIn'],
        };
      }
      return null;
    } catch (e) {
      print('刷新 Token 失败: $e');
      return null;
    }
  }

  /// 取消授权
  Future<bool> logout() async {
    try {
      final result = await _channel.invokeMethod<bool>('logout');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
