# 海因成长助手 (Height4Kid)

一个专为家长设计的儿童成长记录应用，帮助您轻松记录和跟踪孩子的身高、体重发育情况，并与国家标准数据进行对比分析。

## 软件介绍

海因成长助手是一款跨平台的儿童成长记录工具，支持 Web 端和 Android 端。应用采用 Flutter 框架开发，具有精美的界面设计和流畅的用户体验。

### 核心功能

**☁️ 云同步功能（NEW）**

- **BoxSync** - 支持自建 BoxSync 私有云，数据完全自主掌控
- **WebDAV 同步** - 支持坚果云、ownCloud 等 WebDAV 服务
- **Nextcloud 同步** - 支持 Nextcloud 私有云同步
- **自动同步** - 数据修改后自动备份到云端，多设备实时同步
- **定时同步** - 支持 1小时/2小时/6小时/12小时/24小时 多种同步间隔
- **版本管理** - 云端保留最近 3 个版本，可随时回滚

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
- 云端同步加密传输，保障数据安全

**🎨 个性化主题**

- 粉色主题（女孩）/ 蓝色主题（男孩）
- 根据孩子性别自动切换

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

在构建发布版本前，需要配置签名密钥。

**当前项目签名配置：**

本项目已在 `android/app/build.gradle.kts` 中配置了发布签名，需要创建对应的密钥文件：

**密钥文件存放位置：**

```
android/
└── app/
    ├── build.gradle.kts
    └── height4kid-release-key.jks    # 密钥文件（需要创建）
```

**创建密钥文件：**

```bash
# 进入 android/app 目录
cd android/app

# 生成密钥（使用 keytool）
keytool -genkey -v -keystore height4kid-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias height4kid

# 按提示输入信息：
# - 密钥库密码: 
# - 密钥密码: 
# - 姓名、组织等信息可随意填写
```

**⚠️ 重要安全提示：**

**必须妥善备份以下文件，否则将无法更新已发布的应用：**

1. **JKS 密钥文件** (`android/app/height4kid-release-key.jks`)
   - 这是应用签名的核心文件
   - 丢失后将无法发布应用更新
   - 建议备份到多个安全位置（如加密U盘、云存储、离线硬盘）
2. **密钥信息记录**
   - 密钥别名: `height4kid`
   - 密钥库密码: `height4kid2024`
   - 密钥密码: `height4kid2024`
   - 有效期: 10000 天

**安全注意事项：**

- 不要将密钥文件提交到 Git 仓库（已添加到 .gitignore）
- 不要将密钥文件上传到公共云盘或代码托管平台
- 定期验证备份文件的可用性
- 建议每年检查一次密钥的有效期

**自定义签名配置（可选）：**

如需使用不同的密钥配置，请修改 `android/app/build.gradle.kts` 文件中的 `signingConfigs` 部分：

```kotlin
signingConfigs {
    create("release") {
        keyAlias = "您的密钥别名"
        keyPassword = "您的密钥密码"
        storeFile = file("您的密钥文件名.jks")
        storePassword = "您的密钥库密码"
    }
}
```

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
- **file\_picker** - 文件选择功能
- **file\_saver** - 文件保存功能
- **permission\_handler** - 权限管理
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

A: 请确保已创建密钥文件 `android/app/height4kid-release-key.jks`，密码为 `height4kid2024`。如使用自定义密钥，请修改 `android/app/build.gradle.kts` 中的签名配置。

### Q: Web 端无法选择文件？

A: 某些浏览器可能限制文件选择功能，建议使用 Chrome 或 Edge 浏览器。

### Q: Android 端导入/导出失败？

A: 请确保已授予存储权限。首次使用时会弹出权限请求，也可以在系统设置中手动开启。

## 更新日志

<details>
<summary><h3 style="display: inline;">v1.1.0 (2026-06-16) - 云同步版本</h3></summary>

#### v1.1.2 (2026-06-16)
- 🔒 **安全优化** - 云同步配置完成后隐藏用户名和密码，保护用户隐私
- ♻️ **代码优化** - 优化云同步配置代码结构，提升可维护性

#### v1.1.1 (2026-06-15)
- 🎨 **UI优化** - 优化云同步配置页面交互体验

#### v1.1.0 (2026-06-04)
- ☁️ **重磅功能：云同步** - 支持多设备数据实时同步
  - **BoxSync** - 支持自建 BoxSync 私有云，数据完全自主掌控
  - **WebDAV 同步** - 支持坚果云、ownCloud 等兼容 WebDAV 的网盘
  - **Nextcloud 同步** - 支持 Nextcloud 私有云部署
- 🔄 **智能同步策略** -
  - 数据修改时自动备份到云端
  - 启动时自动对比线上线下数据，按最新版本同步
  - 支持 1小时/2小时/6小时/12小时/24小时 定时同步
- 📦 **云端版本管理** - 自动保留最近 3 个版本，可随时选择历史版本还原
- 🔐 **安全传输** - 所有云端同步均采用加密传输，保障数据安全
</details>

<details>
<summary><h3 style="display: inline;">v1.0.3 (2026-05-26)</h3></summary>

- 🎨 **移除主题切换** - 主题色根据孩子性别自动切换（女孩粉色/男孩蓝色）
- 📊 **优化成长曲线** - 精确到日龄计算，重叠数据点自动错开显示
- 📱 **优化全屏显示** - 安卓端沉浸式全屏，状态栏融入应用
- 📈 **优化全屏曲线交互** -
  - 4岁固定范围显示，左右拖动查看完整曲线（0-18岁）
  - Y轴根据当前显示范围动态调整，曲线更清晰
  - 点击数据点查看详情
- 🔄 **双渠道更新** - 支持国内渠道(GitCode)和GitHub渠道检查更新
- 🚀 **国内渠道优先** - 应用启动时优先使用国内渠道检查更新
- 🐛 **修复头像加载** - 切换孩子时显示加载指示器，避免闪烁
</details>

<details>
<summary><h3 style="display: inline;">v1.0.2 (2026-05-23)</h3></summary>

- ✨ **新增国标数据支持** - 身高体重成长曲线支持非整数月龄查看
- 📊 **更新国标数据** - 更新最新的国标数据（涵盖0-1岁）
- 📈 **更新BMI评估标准** - 更新BMI评估标准
- 🎨 **全新应用图标** - 更换为可爱的小狮子主题图标
- 📝 **统一应用名称** - 统一更名为"海因成长助手"
- 🐛 **修复删除功能** - 修复删除孩子无法生效的问题
- 🐛 **修复导入提示** - 修复导入成功却显示失败的问题
- 🔄 **优化切换逻辑** - 切换孩子后自动返回主页
- 📊 **优化图表显示** - 修复全屏模式竖轴显示不全的问题
- 📱 **界面优化** - 孩子管理页面添加更醒目的添加按钮
</details>

<details>
<summary><h3 style="display: inline;">v1.0.1</h3></summary>

- 修复已知问题
- 优化用户体验
</details>

<details>
<summary><h3 style="display: inline;">v1.0.0</h3></summary>

- 初始版本发布
- 支持孩子信息管理
- 支持成长记录功能
- 支持数据导入/导出
- 支持主题切换
- 支持 Web 和 Android 双平台
</details>

## 下一步计划

### v1.2.0 - 智能分析与提醒

- 🤖 **AI生长预测** - 基于历史数据预测未来生长趋势
- 📊 **智能分析报告** - 自动生成生长发育分析报告
- 🔔 **测量提醒** - 定期提醒记录孩子身高体重
- 📈 **生长速度预警** - 生长异常时及时提醒家长

### v1.3.0 - 家庭共享与社交

- 👨‍👩‍👧 **家庭共享** - 支持家庭成员共享孩子数据
- 🔔 **数据变更提醒** - 其他设备修改数据时实时通知
- 📊 **成长报告生成** - 自动生成月度/年度成长报告
- 📤 **分享功能** - 支持分享成长曲线到社交媒体

***

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

***

**温馨提示**：本应用仅供参考，如有健康问题请咨询专业医生。
