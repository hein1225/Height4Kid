# 身高成长小助手（Height4Kid）客户端构建教程

## 生成签名文件

### 步骤 1：生成 keystore 文件

1. 打开命令行工具（Windows 下为 Command Prompt 或 PowerShell）。
2. 导航到客户端目录：
   ```bash
   cd d:\code\Height4Kid\client
   ```
3. 运行以下命令生成 keystore 文件：
   ```bash
   keytool -genkey -v -keystore height4kid.keystore -alias height4kid -keyalg RSA -keysize 2048 -validity 10000
   ```
4. 按照提示输入以下信息：
   - 密钥库口令（例如：height4kid123）
   - 再次输入新口令
   - 您的名字与姓氏（例如：hyc5069）
   - 您的组织单位名称（可留空）
   - 您的组织名称（可留空）
   - 您所在的城市或区域名称（可留空）
   - 您所在的省/市/自治区名称（可留空）
   - 该单位的双字母国家/地区代码（可留空）
   - 确认信息是否正确（输入：是）
   - 输入密钥口令（与密钥库口令相同）

### 步骤 2：配置 build.gradle 文件

1. 打开 `android/app/build.gradle` 文件。
2. 在 `android` 块中添加签名配置：
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               storeFile file('height4kid.keystore')
               storePassword 'height4kid123'
               keyAlias 'height4kid'
               keyPassword 'height4kid123'
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               ...
           }
       }
       ...
   }
   ```

## 构建 Release 版本

### 步骤 1：构建 APK

1. 打开命令行工具，导航到客户端目录：
   ```bash
   cd d:\code\Height4Kid\client
   ```
2. 运行以下命令构建 release 版本：
   ```bash
   flutter build apk --release
   ```

### 步骤 2：获取 APK 文件

构建完成后，APK 文件将位于 `build/app/outputs/flutter-apk/app-release.apk` 目录中。

## 安装 APK

1. 将生成的 APK 文件复制到 Android 设备上。
2. 在设备上打开 APK 文件，按照提示安装应用。

## 本地开发

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run
```

## 功能说明

1. **首次登录**：需要输入服务端网址、用户名和密码。
2. **小孩信息管理**：添加、编辑、删除小孩信息。
3. **成长信息记录**：记录小孩的身高和体重。
4. **成长曲线**：查看小孩的成长记录。
5. **问题反馈**：提交问题反馈给管理员。