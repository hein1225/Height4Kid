# 身高成长小助手 (Height4Kid)

一款专为家长设计的儿童身高成长记录与管理应用，帮助您轻松记录孩子的成长历程。

## 🌟 功能特性

### 核心功能
- **儿童管理** - 支持添加多个孩子的信息，记录姓名、性别、出生日期
- **成长记录** - 记录孩子的身高和体重数据，追踪成长变化
- **历史记录** - 查看和管理所有成长记录，支持编辑和删除
- **数据备份** - 将数据导出为JSON文件，确保数据安全
- **数据还原** - 从备份文件恢复数据

### 设计理念
- 简洁直观的用户界面
- 纯本地应用，无需网络连接
- 数据安全存储在设备本地

## 🛠️ 技术栈

### 前端框架
- **Android** - 原生Android应用
- **Kotlin** - 主要开发语言
- **Jetpack Compose** - UI框架
- **Room Database** - 本地数据库

### 构建工具
- **Gradle** - 项目构建工具

## 📱 安装与使用

### 直接安装APK
下载最新版本的APK文件，在Android设备上安装即可使用。

### 手动构建

#### 环境要求
- Android Studio Hedgehog (2023.1.1) 或更高版本
- Android SDK Platform 34
- JDK 17

#### 构建步骤

1. **克隆项目**
```bash
git clone https://github.com/your-repo/height4kid.git
cd height4kid/android
```

2. **创建签名密钥**
```bash
keytool -genkey -v -keystore height4kid.jks -keyalg RSA -keysize 2048 -validity 10000 -alias height4kid
```

3. **创建签名配置文件**
在项目根目录创建 `keystore.properties` 文件：
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=height4kid
storeFile=height4kid.jks
```

4. **构建APK**
```bash
# 构建Debug版本
./gradlew assembleDebug

# 构建Release版本
./gradlew assembleRelease
```

## 🔐 签名配置说明

### 签名文件要求

**密钥库文件**
- 文件名：`height4kid.jks`
- 位置：项目根目录（与 `keystore.properties` 同级）
- 别名：`height4kid`
- 算法：RSA 2048位

**配置文件**
- 文件名：`keystore.properties`
- 位置：项目根目录
- 内容：
```properties
storePassword=您的存储密码
keyPassword=您的密钥密码
keyAlias=height4kid
storeFile=height4kid.jks
```

### 重要提示
- 签名文件包含敏感信息，**绝对不要上传到GitHub或其他公共仓库**
- 妥善保管签名文件，丢失后将无法更新已发布的应用
- Debug和Release版本使用相同签名，确保更新兼容性

## 📁 项目结构

```
height4kid/
├── android/                      # Android应用目录
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── java/com/example/height4kid/
│   │   │   │   ├── MainActivity.kt       # 主入口
│   │   │   │   ├── repository/           # 数据仓库
│   │   │   │   │   ├── ChildRepository.kt
│   │   │   │   │   ├── GrowthRecordRepository.kt
│   │   │   │   │   ├── StandardDataRepository.kt
│   │   │   │   │   └── BackupRepository.kt
│   │   │   │   ├── database/             # 数据库层
│   │   │   │   │   ├── AppDatabase.kt
│   │   │   │   │   ├── dao/              # 数据访问对象
│   │   │   │   │   └── entity/           # 实体类
│   │   │   │   └── ui/screen/           # 界面组件
│   │   │   │       ├── HomeScreen.kt
│   │   │   │       ├── ChildManageScreen.kt
│   │   │   │       ├── GrowthRecordScreen.kt
│   │   │   │       ├── HistoryScreen.kt
│   │   │   │       └── SettingsScreen.kt
│   │   │   └── res/                      # 资源文件
│   │   └── build.gradle                  # 模块构建配置
│   ├── build.gradle                      # 项目构建配置
│   └── gradle.properties                 # Gradle属性
├── height4kid.jks                        # 签名密钥库（不上传）
├── keystore.properties                   # 签名配置（不上传）
└── README.md                             # 项目说明文档
```

## 🙅‍♂️ 不应上传到GitHub的文件

以下文件包含敏感信息或构建产物，不应提交到版本控制：

```gitignore
# 签名文件
height4kid.jks
keystore.properties

# 构建产物
*.apk
*.aab
build/
app/build/

# Gradle缓存
.gradle/
gradle-wrapper.jar
gradle-wrapper.properties

# IDE配置
.idea/
*.iml
*.ipr
*.iws

# 操作系统文件
.DS_Store
Thumbs.db

# 日志文件
*.log

# 备份文件
*.bak
*.backup
```

## 📊 数据存储

应用数据存储在设备的本地数据库中：
- 数据库类型：SQLite (Room)
- 备份格式：JSON
- 备份位置：`Android/data/com.growthassistant.height4kid/files/Documents/backups/`

## 📄 许可证

MIT License - 详见 LICENSE 文件

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📧 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱：support@height4kid.example.com
- GitHub Issues：https://github.com/your-repo/height4kid/issues

---

**注意**：本应用为纯本地应用，所有数据仅存储在用户设备上，不会上传到任何服务器。