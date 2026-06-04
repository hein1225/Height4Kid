package com.heinci.height4kid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var baiduSDKPlugin: BaiduSDKPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册百度网盘 SDK 插件
        // 使用同一个实例进行注册和保存，确保 dispose() 能正确释放资源
        baiduSDKPlugin = BaiduSDKPlugin(this).also { plugin ->
            val channel = io.flutter.plugin.common.MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger, 
                BaiduSDKPlugin.CHANNEL_NAME
            )
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onDestroy() {
        baiduSDKPlugin?.dispose()
        super.onDestroy()
    }
}
