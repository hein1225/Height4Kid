package com.heinci.height4kid

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/**
 * 百度网盘 OAuth2 授权 Flutter 插件
 * 使用网页授权方式（因为百度网盘官方 SDK 需要手动下载）
 */
class BaiduSDKPlugin(private val context: Context) : MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.heinci.height4kid/baidu_sdk"
        const val TAG = "BaiduSDKPlugin"
        const val BAIDU_OAUTH_URL = "https://openapi.baidu.com/oauth/2.0/authorize"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            channel.setMethodCallHandler(BaiduSDKPlugin(context))
        }
    }

    private val mainScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val appKey = call.argument<String>("appKey") ?: ""
                val secretKey = call.argument<String>("secretKey") ?: ""
                initialize(appKey, secretKey, result)
            }
            "isAuthorized" -> {
                isAuthorized(result)
            }
            "authorize" -> {
                authorize(result)
            }
            "refreshToken" -> {
                val refreshToken = call.argument<String>("refreshToken") ?: ""
                refreshToken(refreshToken, result)
            }
            "logout" -> {
                logout(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 初始化（网页授权方式不需要 SDK 初始化）
     */
    private fun initialize(appKey: String, secretKey: String, result: Result) {
        // 网页授权方式不需要初始化 SDK
        // 只需要检查是否配置了 App Key
        if (appKey.isEmpty()) {
            result.success(false)
            return
        }
        result.success(true)
    }

    /**
     * 检查是否已授权（需要 Flutter 端保存 token 状态）
     */
    private fun isAuthorized(result: Result) {
        // 网页授权方式下，授权状态由 Flutter 端管理
        result.success(false)
    }

    /**
     * 启动网页授权
     */
    private fun authorize(result: Result) {
        mainScope.launch {
            try {
                // 网页授权方式：打开浏览器让用户登录
                // 实际实现需要配合后端服务处理回调
                // 当前返回提示信息，引导用户使用手动输入方式
                
                result.error(
                    "WEB_AUTH_REQUIRED",
                    "百度网盘网页授权需要在百度开放平台注册应用并配置回调地址。\n" +
                    "由于配置复杂，建议使用手动输入 Access Token 方式。\n" +
                    "您可以在百度网盘开放平台获取 Token 后手动输入。",
                    null
                )
            } catch (e: Exception) {
                result.error("AUTH_ERROR", e.message, null)
            }
        }
    }

    /**
     * 刷新 Access Token
     */
    private fun refreshToken(refreshToken: String, result: Result) {
        mainScope.launch {
            try {
                // 网页授权方式下，刷新 token 需要通过 HTTP 请求
                // 这里返回未实现，由 Flutter 端处理
                result.error("NOT_IMPLEMENTED", "请在 Flutter 端实现 Token 刷新", null)
            } catch (e: Exception) {
                result.error("REFRESH_ERROR", e.message, null)
            }
        }
    }

    /**
     * 取消授权
     */
    private fun logout(result: Result) {
        mainScope.launch {
            try {
                // 网页授权方式下，登出只需清除本地 token
                result.success(true)
            } catch (e: Exception) {
                result.error("LOGOUT_ERROR", e.message, null)
            }
        }
    }

    fun dispose() {
        mainScope.cancel()
    }
}
