# 海因成长助手 (Height4Kid)

一个帮助家长记录和跟踪孩子身高体重成长的跨平台应用，支持 Web 和 Android。

## 功能特点

- 👶 **孩子管理**：添加、编辑、删除和切换孩子信息
- 📏 **成长记录**：记录身高和体重数据
- 📊 **图表展示**：可视化的成长曲线
- 📈 **国标数据**：与中国儿童标准数据对比
- 🎨 **主题切换**：粉色/蓝色主题
- 💾 **数据备份**：支持导入/导出 JSON 备份
- 🌐 **跨平台**：支持 Web 和 Android

## 应用截图

### Web 端界面
> 截图将在此处添加，请运行 `flutter run -d chrome` 后截图替换

### Android 端界面
> 截图将在此处添加

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── child.dart
│   ├── growth_record.dart
│   └── national_standard.dart
├── providers/                # 状态管理
│   └── app_provider.dart
├── screens/                  # 页面
│   ├── home_screen.dart
│   ├── record_screen.dart
│   ├── history_screen.dart
│   ├── children_screen.dart
│   ├── settings_screen.dart
│   └── permission_wizard_screen.dart
├── theme/                    # 主题
│   └── app_theme.dart
├── utils/                    # 工具类
│   └── permission_manager.dart
└── widgets/                  # 组件
    ├── growth_chart.dart
    └── character_display.dart
```

## 运行方式

### 前置要求
- Flutter SDK (>=3.0.0)
- 浏览器 (Chrome/Edge) 或 Android 设备/模拟器

### 运行 Web 版本

```bash
# 安装依赖
flutter pub get

# 运行 Web 版本（Chrome）
flutter run -d chrome

# 或运行 Web 版本（Edge）
flutter run -d edge
```

### 运行 Android 版本

```bash
# 连接 Android 设备或启动模拟器
flutter devices

# 运行调试版本
flutter run

# 构建发布版本
flutter build apk --release
```

## 构建发布版本

### Android APK
```bash
flutter build apk --release
```
APK 文件位于：`build/app/outputs/flutter-apk/app-release.apk`

### Web 版本
```bash
flutter build web --release
```
构建输出位于：`build/web/`

## 开发说明

本项目使用：
- **Provider** 状态管理
- **SharedPreferences** 本地存储
- **file_picker** 文件选择
- **file_saver** 文件保存
- **permission_handler** 权限管理
- **Material Design 3** 设计规范

## 作者

海因茨

## 许可证

MIT License
