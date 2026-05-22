# 海因成长助手 (Height4Kid)

一个专为家长设计的儿童成长记录应用，帮助您轻松记录和跟踪孩子的身高、体重发育情况，并与国家标准数据进行对比分析。

## 软件介绍

海因成长助手是一款跨平台的儿童成长记录工具，支持 Web 端和 Android 端。应用采用 Flutter 框架开发，具有精美的界面设计和流畅的用户体验。

### 核心功能

**👶 孩子管理**
- 添加多个孩子的基本信息（姓名、性别、出生日期、头像）
- 快速切换不同孩子的数据视图
- 支持自定义头像上传

**📏 成长记录**
- 记录每次测量的身高和体重数据
- 自动计算年龄和生长速度
- 支持添加备注信息

**📊 数据可视化**
- 使用专业图表库展示成长曲线
- 身高、体重趋势一目了然
- 支持时间范围筛选

**📈 国标对比**
- 内置中国儿童生长发育标准数据
- 实时对比孩子的生长百分位
- 帮助家长了解孩子的发育状况

**💾 数据安全**
- 支持导出 JSON 格式备份
- 支持从备份文件导入恢复
- 数据本地存储，隐私安全

**🎨 个性化主题**
- 粉色主题（适合女孩）
- 蓝色主题（适合男孩）
- 一键切换，界面美观

**🌐 跨平台支持**
- Web 端：无需安装，浏览器即可使用
- Android 端：原生应用体验，支持离线使用

## 应用截图

### Android 端界面
<img width="486" height="1030" alt="{D1DFDC68-116F-4A32-A306-3A7C1733CA97}" src="https://github.com/user-attachments/assets/cb22cc6c-c006-4d42-9f54-ac3d4b31eae5" /><img width="487" height="1030" alt="{E7472E60-ACC7-4E0B-BEB8-566FA690D7E5}" src="https://github.com/user-attachments/assets/a9f0ac0b-97e5-4d89-af75-d3ecdf22864b" />



## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── child.dart           # 孩子信息模型
│   ├── growth_record.dart   # 成长记录模型
│   └── national_standard.dart # 国标数据模型
├── providers/               # 状态管理
│   └── app_provider.dart    # 全局状态管理
├── screens/                 # 页面
│   ├── home_screen.dart     # 首页（成长曲线）
│   ├── record_screen.dart   # 记录页面
│   ├── history_screen.dart  # 历史记录页面
│   ├── children_screen.dart # 孩子管理页面
│   ├── settings_screen.dart # 设置页面
│   └── permission_wizard_screen.dart # 权限向导页面
├── theme/                   # 主题
│   └── app_theme.dart       # 主题配置
├── utils/                   # 工具类
│   └── permission_manager.dart # 权限管理
└── widgets/                 # 组件
    ├── growth_chart.dart    # 成长图表组件
    └── character_display.dart # 角色展示组件
```

## 运行方式

### 前置要求
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- 浏览器 (Chrome/Edge) 或 Android 设备/模拟器
- Android Studio（可选，用于 Android 开发）

### 环境配置

1. **安装 Flutter SDK**
   访问 [Flutter 官网](https://flutter.dev/docs/get-started/install) 下载并安装

2. **配置环境变量**
   确保 `flutter` 命令可在终端中使用

3. **验证安装**
   ```bash
   flutter doctor
   ```

### 运行 Web 版本

```bash
# 克隆项目
git clone https://github.com/hein1225/Height4Kid.git
cd Height4Kid

# 安装依赖
flutter pub get

# 运行 Web 版本（Chrome）
flutter run -d chrome

# 或运行 Web 版本（Edge）
flutter run -d edge
```

Web 应用将在浏览器中打开，默认端口为 8080。

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

### Android APK 构建

#### 1. 配置签名密钥

在构建发布版本前，需要配置签名密钥。请在 `android/app/` 目录下创建 `key.properties` 文件：

```properties
storePassword=您的密钥库密码
keyPassword=您的密钥密码
keyAlias=您的密钥别名
storeFile=../keystore/您的密钥文件名.jks
```

**密钥文件存放目录结构：**
```
android/
├── app/
│   ├── build.gradle.kts
│   └── key.properties          # 密钥配置文件
└── keystore/
    └── your_key.jks            # 密钥文件（请自行创建）
```

**创建密钥的方法：**
```bash
# 进入 android 目录
cd android

# 创建 keystore 目录
mkdir keystore

# 生成密钥（使用 keytool）
keytool -genkey -v -keystore keystore/your_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your_alias

# 按提示输入密钥库密码、密钥密码和个人信息
```

**重要提示：**
- 请妥善保管密钥文件和密码
- 不要将 `key.properties` 和 `.jks` 文件提交到 Git 仓库（已添加到 .gitignore）
- 密钥丢失后将无法更新已发布的应用

#### 2. 构建 APK

```bash
# 清理构建缓存
flutter clean

# 获取依赖
flutter pub get

# 构建发布版本
flutter build apk --release
```

构建完成后，APK 文件位于：
```
build/app/outputs/flutter-apk/app-release.apk
```

#### 3. 构建 App Bundle（Google Play 上架）

```bash
flutter build appbundle --release
```

构建输出位于：
```
build/app/outputs/bundle/release/app-release.aab
```

### Web 版本构建

```bash
# 构建 Web 版本
flutter build web --release

# 构建输出位于
build/web/
```

构建完成后，可以将 `build/web/` 目录的内容部署到任何 Web 服务器。

## 开发说明

### 技术栈
- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言
- **Provider** - 状态管理
- **SharedPreferences** - 本地数据持久化
- **file_picker** - 文件选择功能
- **file_saver** - 文件保存功能
- **permission_handler** - 权限管理
- **Material Design 3** - 设计规范

### 代码规范
- 遵循 Flutter 官方代码风格指南
- 使用有意义的变量和函数命名
- 添加必要的注释说明
- 保持代码简洁可读

### 调试技巧
```bash
# 查看日志
flutter logs

# 性能分析
flutter run --profile

# 内存分析
flutter run --verbose
```

## 常见问题

### Q: 构建失败提示签名问题？
A: 请确保已正确配置 `key.properties` 文件，并将密钥文件放在 `android/keystore/` 目录下。

### Q: Web 端无法选择文件？
A: 某些浏览器可能限制文件选择功能，建议使用 Chrome 或 Edge 浏览器。

### Q: Android 端导入/导出失败？
A: 请确保已授予存储权限。首次使用时会弹出权限请求，也可以在系统设置中手动开启。

## 更新日志

### v1.0.0
- 初始版本发布
- 支持孩子信息管理
- 支持成长记录功能
- 支持数据导入/导出
- 支持主题切换
- 支持 Web 和 Android 双平台

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 作者

**海因茨**

- GitHub: [@hein1225](https://github.com/hein1225)

## 许可证

本项目采用 MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件

## 致谢

- 中国儿童生长发育标准数据来源：国家卫生健康委员会
- 图标设计：Material Design Icons
- UI 灵感：Material Design 3

---

**温馨提示**：本应用仅供参考，如有健康问题请咨询专业医生。
