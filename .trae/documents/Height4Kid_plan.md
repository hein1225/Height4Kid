
# 身高成长小助手（Height4Kid）项目开发计划

## 一、项目概述

身高成长小助手（Height4Kid）是一款用于记录小孩身高体重成长数据，并与国标数据对比分析的应用系统。项目分为**服务端**和**安卓客户端**两部分：

- **服务端**：基于 Spring Boot 构建的 RESTful API 服务，提供数据存储、业务逻辑处理和管理后台
- **安卓客户端**：基于 Kotlin + Jetpack Compose 开发的移动应用，供普通用户使用

### 1.1 项目架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        服务端 (Backend)                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Spring Boot 3.2 + SQLite + JWT认证                      │  │
│  │                                                           │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │ 用户管理 │  │ 小孩管理 │  │ 成长记录 │  │ 国标数据 │   │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │ 问题反馈 │  │ 运行日志 │  │ 备份管理 │  │ App配置  │   │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ REST API
┌─────────────────────────────────────────────────────────────────┐
│                        前端管理后台                            │
│              Vue 3 + Element Plus + 响应式设计                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  /admin        → 管理员登录页面                            │  │
│  │  /admin/users  → 用户管理页面                             │  │
│  │  /admin/feedback → 问题反馈页面                           │  │
│  │  /admin/app    → App配置页面                              │  │
│  │  /admin/standard → 国标数据管理                           │  │
│  │  /admin/logs   → 运行日志页面                             │  │
│  │  /admin/backup → 备份还原页面                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ APK下载
┌─────────────────────────────────────────────────────────────────┐
│                        安卓客户端 (Kotlin)                    │
│              Kotlin + Jetpack Compose + Room                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  登录模块          → 用户认证登录/持久化                   │  │
│  │  小孩信息管理      → 新增/修改/删除小孩信息               │  │
│  │  成长状态展示      → 身高体重评估与角色展示               │  │
│  │  成长曲线          → 身高体重趋势图表                     │  │
│  │  成长记录          → 添加/修改/删除成长数据               │  │
│  │  设置模块          → 问题反馈/备份还原/退出登录           │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 二、技术选型

### 2.1 服务端技术栈

| 分类 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 语言 | Java | 21 | LTS版本，性能稳定，生态成熟 |
| 框架 | Spring Boot | 3.2.x | 社区成熟，生态完善，便于快速构建RESTful服务 |
| 数据库 | SQLite | 3.x | 轻量级嵌入式数据库，无需独立服务，适合单机部署 |
| 认证 | JWT | - | 无状态认证，便于水平扩展，支持移动端 |
| ORM | Spring Data JPA | - | 简化数据访问层开发 |
| 文件上传 | Spring Multipart | - | 支持APK和图片文件上传 |
| 数据导出 | Apache POI | 5.2.x | Excel文件处理，支持国标数据导入导出 |

### 2.2 前端管理后台技术栈

| 分类 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 框架 | Vue | 3.x | 组合式API，性能优秀，学习曲线平缓 |
| UI组件 | Element Plus | 2.x | 企业级组件库，样式美观，组件丰富 |
| 图标 | Element Icons | - | 内置图标库，与Element Plus完美集成 |
| 路由 | Vue Router | 4.x | 单页应用路由管理 |
| 状态管理 | Pinia | 2.x | 轻量级状态管理，替代Vuex |
| HTTP客户端 | Axios | 1.x | Promise-based HTTP客户端，支持拦截器 |

### 2.3 安卓客户端技术栈

| 分类 | 技术 | 版本 | 说明 |
|------|------|------|------|
| **语言** | **Kotlin** | **1.9.x** | **官方推荐语言，简洁安全，与Java完全互操作** |
| UI框架 | Jetpack Compose | 1.5.x | 现代声明式UI框架，简化UI开发 |
| 数据库 | Room | 2.6.x | SQLite封装，提供类型安全的数据访问 |
| 网络 | Retrofit | 2.9.x | REST客户端，支持协程 |
| 图片加载 | Coil | 2.4.x | 现代图片加载库，支持协程 |
| 图表 | MPAndroidChart | 3.1.x | 强大的图表库，支持多种图表类型 |
| 持久化 | DataStore | 1.0.x | 偏好设置存储，替代SharedPreferences |
| 导航 | Jetpack Navigation | 2.7.x | 应用内导航管理 |

---

## 三、服务端功能详细设计

### 3.1 用户认证模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 用户登录 | 验证用户名密码，返回JWT Token | POST /api/auth/login |
| Token刷新 | 使用Refresh Token获取新Token | POST /api/auth/refresh |
| 登录记录 | 记录用户登录IP和设备信息 | 自动记录 |

### 3.2 用户管理模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 管理员账户管理 | 创建、修改、删除管理员账号 | GET/POST/PUT/DELETE /api/users |
| 普通账户管理 | 创建、修改、删除普通用户账号 | GET/POST/PUT/DELETE /api/users |
| 权限设置 | 设置用户角色（ADMIN/USER） | PUT /api/users/{id}/role |
| 密码修改 | 修改用户密码 | PUT /api/users/{id}/password |

### 3.3 小孩管理模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 小孩信息创建 | 创建小孩基本信息（姓名、生日、性别、头像） | POST /api/children |
| 小孩信息查询 | 查询当前用户的所有小孩列表 | GET /api/children |
| 小孩信息更新 | 修改小孩信息 | PUT /api/children/{id} |
| 小孩信息删除 | 删除小孩及关联的成长记录 | DELETE /api/children/{id} |

### 3.4 成长记录模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 记录创建 | 添加身高体重记录 | POST /api/records |
| 记录查询 | 查询指定小孩的成长记录 | GET /api/records?childId=xxx |
| 记录更新 | 修改成长记录 | PUT /api/records/{id} |
| 记录删除 | 删除成长记录 | DELETE /api/records/{id} |

### 3.5 国标数据模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 国标数据查询 | 获取男孩/女孩各年龄段的身高体重标准 | GET /api/standard |
| 国标数据导入 | 批量导入Excel格式的国标数据 | POST /api/standard/import |
| 国标数据导出 | 导出国标数据为Excel文件 | GET /api/standard/export |
| 单条数据更新 | 更新指定年龄性别的国标数据 | PUT /api/standard/{id} |

### 3.6 问题反馈模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 反馈提交 | 用户提交问题反馈 | POST /api/feedback |
| 反馈查询（管理员） | 查询所有反馈列表 | GET /api/feedback |
| 反馈查询（用户） | 查询当前用户的反馈 | GET /api/feedback/user |
| 反馈回复 | 管理员回复反馈 | PUT /api/feedback/{id}/reply |
| 反馈删除 | 管理员删除反馈 | DELETE /api/feedback/{id} |

### 3.7 App配置模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 配置查询 | 获取App配置信息 | GET /api/app/config |
| 配置更新 | 更新App名称、服务器地址、版本号等 | PUT /api/app/config |
| APK上传 | 上传安卓APK安装包 | POST /api/app/apk/upload |
| APK下载 | 下载最新APK安装包 | GET /api/app/apk/download |

### 3.8 日志模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 日志查询 | 查询系统运行日志 | GET /api/logs |
| 日志分类 | 按级别筛选（INFO/ERROR） | GET /api/logs?level=ERROR |

### 3.9 备份模块

| 功能 | 说明 | API端点 |
|------|------|---------|
| 创建备份 | 备份所有数据库数据 | POST /api/backup/create |
| 下载备份 | 下载备份文件 | GET /api/backup/download |
| 还原备份 | 从备份文件恢复数据 | POST /api/backup/restore |
| 重置数据 | 清空所有数据，恢复初始状态 | POST /api/backup/reset |

---

## 四、安卓客户端功能详细设计

### 4.1 登录模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 账号密码登录 | 用户输入账号密码进行登录 | 必须联网 |
| 持久化登录 | 登录成功后保存Token，下次自动登录 | 支持 |
| 退出登录 | 清除本地Token和用户信息 | - |

### 4.2 小孩信息管理模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 新建小孩 | 首次登录时提示创建小孩信息 | 必须联网 |
| 小孩列表 | 显示当前用户的所有小孩 | 离线支持 |
| 切换小孩 | 切换当前显示的小孩 | 离线支持 |
| 修改小孩 | 修改小孩姓名、生日、性别、头像 | 联网同步 |
| 删除小孩 | 删除小孩及所有关联数据（二次确认） | 联网同步 |
| 头像上传 | 上传或自动生成卡通头像 | 离线缓存 |

### 4.3 成长状态展示模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 角色展示 | 根据年龄和性别显示卡通形象 | 离线支持 |
| 身高显示 | 显示当前身高及国标评估结果 | 离线支持 |
| 体重显示 | 显示当前体重及国标评估结果 | 离线支持 |
| 评估标准 | 身高：矮小/偏矮/标准/超高；体重：偏瘦/标准/超重/肥胖 | 离线支持 |

### 4.4 成长曲线模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 身高曲线 | 显示小孩身高成长趋势及国标曲线 | 离线支持 |
| 体重曲线 | 显示小孩体重成长趋势及国标曲线 | 离线支持 |
| 曲线切换 | 切换身高/体重曲线显示 | 离线支持 |
| 年龄轴 | 根据小孩出生日期自动计算年龄 | 离线支持 |

### 4.5 成长记录模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 添加记录 | 填写记录时间、身高、体重 | 离线缓存，联网同步 |
| 历史记录 | 查看所有成长记录列表 | 离线支持 |
| 修改记录 | 修改已有的成长记录 | 离线缓存，联网同步 |
| 删除记录 | 删除成长记录 | 离线缓存，联网同步 |

### 4.6 设置模块

| 功能 | 说明 | 状态要求 |
|------|------|----------|
| 问题反馈 | 提交问题反馈给管理员 | 必须联网 |
| 本地备份 | 备份当前账号数据到本地 | 离线支持 |
| 本地还原 | 从本地备份文件恢复数据 | 离线支持 |
| 退出登录 | 退出当前账号 | - |

### 4.7 离线支持功能

| 功能 | 说明 |
|------|------|
| 数据本地存储 | 使用Room数据库存储所有数据 |
| 离线操作 | 添加/修改/删除记录在离线时可正常进行 |
| 自动同步 | 联网时自动上传本地新增/修改的数据 |
| 冲突处理 | 根据时间戳处理服务端与本地数据冲突 |

---

## 五、项目目录结构

### 5.1 服务端目录结构 (`backend/`)

```
backend/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/height4kid/
│       │       ├── controller/     # REST API控制器
│       │       │   ├── AuthController.java      # 认证接口
│       │       │   ├── UserController.java      # 用户管理接口
│       │       │   ├── ChildController.java     # 小孩管理接口
│       │       │   ├── GrowthRecordController.java # 成长记录接口
│       │       │   ├── StandardDataController.java # 国标数据接口
│       │       │   ├── FeedbackController.java    # 问题反馈接口
│       │       │   ├── AppConfigController.java   # App配置接口
│       │       │   ├── LogController.java         # 日志接口
│       │       │   └── BackupController.java      # 备份接口
│       │       ├── service/        # 业务逻辑层
│       │       │   ├── AuthService.java
│       │       │   ├── UserService.java
│       │       │   ├── ChildService.java
│       │       │   ├── GrowthRecordService.java
│       │       │   ├── StandardDataService.java
│       │       │   ├── FeedbackService.java
│       │       │   ├── AppConfigService.java
│       │       │   └── LogService.java
│       │       ├── repository/     # 数据访问层
│       │       │   ├── UserRepository.java
│       │       │   ├── ChildRepository.java
│       │       │   ├── GrowthRecordRepository.java
│       │       │   ├── StandardDataRepository.java
│       │       │   ├── FeedbackRepository.java
│       │       │   ├── AppConfigRepository.java
│       │       │   ├── LogRepository.java
│       │       │   └── LoginRecordRepository.java
│       │       ├── entity/         # 数据库实体
│       │       │   ├── User.java
│       │       │   ├── Child.java
│       │       │   ├── GrowthRecord.java
│       │       │   ├── StandardData.java
│       │       │   ├── Feedback.java
│       │       │   ├── AppConfig.java
│       │       │   ├── LogEntry.java
│       │       │   └── LoginRecord.java
│       │       ├── dto/            # 数据传输对象
│       │       │   ├── request/    # 请求DTO
│       │       │   └── response/   # 响应DTO
│       │       ├── config/         # 配置类
│       │       │   ├── SecurityConfig.java   # 安全配置
│       │       │   ├── JwtConfig.java        # JWT配置
│       │       │   └── FileUploadConfig.java # 文件上传配置
│       │       ├── security/       # 安全相关
│       │       │   ├── JwtTokenProvider.java      # JWT生成验证
│       │       │   ├── CustomUserDetailsService.java # 用户详情服务
│       │       │   └── JwtAuthenticationFilter.java # JWT过滤器
│       │       ├── exception/      # 异常处理
│       │       │   ├── GlobalExceptionHandler.java # 全局异常处理
│       │       │   └── BusinessException.java     # 业务异常
│       │       ├── util/           # 工具类
│       │       │   ├── BackupUtil.java   # 备份工具
│       │       │   └── ExcelUtil.java    # Excel处理工具
│       │       └── Height4KidApplication.java # 启动类
│       └── resources/
│           ├── application.yml     # 应用配置
│           ├── schema.sql          # 数据库初始化DDL
│           └── data.sql            # 初始化数据（国标数据）
├── uploads/                        # 文件上传目录（APK、头像）
├── backups/                        # 备份文件目录
├── Dockerfile                      # Docker构建文件
├── docker-compose.yml              # Docker Compose配置
└── pom.xml                         # Maven依赖管理
```

### 5.2 前端管理后台目录结构 (`frontend/`)

```
frontend/
├── src/
│   ├── components/                 # 公共组件
│   │   ├── Sidebar.vue            # 侧边导航栏
│   │   ├── Header.vue             # 顶部导航栏
│   │   └── Breadcrumb.vue         # 面包屑导航
│   ├── views/                     # 页面视图
│   │   ├── Login.vue              # 管理员登录页面
│   │   ├── UserManagement.vue     # 用户管理页面
│   │   ├── Feedback.vue           # 问题反馈管理页面
│   │   ├── AppConfig.vue          # App配置页面
│   │   ├── StandardData.vue       # 国标数据管理页面
│   │   ├── Logs.vue               # 运行日志页面
│   │   ├── LoginRecords.vue       # 登录记录页面
│   │   └── Backup.vue             # 备份还原页面
│   ├── store/                     # 状态管理
│   │   └── auth.js                # 认证状态管理
│   ├── utils/                     # 工具函数
│   │   ├── request.js             # HTTP请求封装（Axios）
│   │   └── auth.js                # 认证工具函数
│   ├── router/                    # 路由配置
│   │   └── index.js               # 路由定义与守卫
│   ├── App.vue                    # 根组件
│   └── main.js                    # 入口文件
├── public/                        # 静态资源
├── index.html                     # HTML模板
├── package.json                   # 依赖配置
├── vite.config.js                 # Vite构建配置
└── tailwind.config.js             # Tailwind CSS配置
```

### 5.3 安卓客户端目录结构 (`android/`)

```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/example/height4kid/
│   │       │       ├── ui/                    # UI组件
│   │       │       │   ├── LoginActivity.kt   # 登录页面
│   │       │       │   ├── MainActivity.kt    # 主页面
│   │       │       │   ├── ChildInfoActivity.kt    # 小孩信息页面
│   │       │       │   ├── GrowthRecordActivity.kt # 成长记录页面
│   │       │       │   └── SettingsActivity.kt     # 设置页面
│   │       │       ├── data/                  # 数据层
│   │       │       │   ├── repository/        # 仓库层
│   │       │       │   │   ├── LocalRepository.kt    # 本地数据仓库
│   │       │       │   │   └── RemoteRepository.kt   # 远程数据仓库
│   │       │       │   ├── dao/               # Room DAO接口
│   │       │       │   │   ├── UserDao.kt
│   │       │       │   │   ├── ChildDao.kt
│   │       │       │   │   └── GrowthRecordDao.kt
│   │       │       │   ├── entity/            # Room实体
│   │       │       │   │   ├── User.kt
│   │       │       │   │   ├── Child.kt
│   │       │       │   │   └── GrowthRecord.kt
│   │       │       │   └── remote/            # 远程数据
│   │       │       │       ├── ApiService.kt      # Retrofit接口
│   │       │       │       └── ApiClient.kt       # Retrofit客户端
│   │       │       ├── viewmodel/             # ViewModel
│   │       │       │   ├── MainViewModel.kt
│   │       │       │   ├── ChildViewModel.kt
│   │       │       │   └── GrowthRecordViewModel.kt
│   │       │       ├── util/                  # 工具类
│   │       │       │   ├── ImageCompressor.kt    # 图片压缩
│   │       │       │   ├── DateUtils.kt          # 日期工具
│   │       │       │   └── StandardEvaluator.kt  # 国标评估
│   │       │       ├── di/                    # 依赖注入
│   │       │       │   └── AppModule.kt
│   │       │       └── Height4KidApplication.kt  # 应用类
│   │       └── res/
│   │           ├── drawable/                  # 图片资源（男孩/女孩卡通形象）
│   │           ├── layout/                    # XML布局文件
│   │           ├── values/                    # 资源配置（颜色、字符串、尺寸）
│   │           └── navigation/                # 导航配置
│   ├── build.gradle                          # 模块构建配置
│   └── proguard-rules.pro                    # 混淆规则
├── build.gradle                              # 项目构建配置
├── gradle.properties                         # Gradle配置
└── settings.gradle                           # 项目设置
```

---

## 六、数据库设计

### 6.1 用户表 (`users`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 用户ID |
| username | VARCHAR(50) | UNIQUE NOT NULL | 用户名 |
| password | VARCHAR(255) | NOT NULL | 密码（BCrypt加密） |
| role | VARCHAR(20) | NOT NULL DEFAULT 'USER' | 角色：ADMIN/USER |
| nickname | VARCHAR(50) | | 昵称 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 更新时间 |

### 6.2 小孩信息表 (`children`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 小孩ID |
| user_id | INTEGER | FOREIGN KEY REFERENCES users(id) | 所属用户ID |
| name | VARCHAR(50) | NOT NULL | 小孩姓名 |
| birthday | DATE | NOT NULL | 出生日期 |
| gender | VARCHAR(10) | NOT NULL | 性别：MALE/FEMALE |
| avatar | BLOB | | 头像图片 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 更新时间 |

### 6.3 成长记录表 (`growth_records`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 记录ID |
| child_id | INTEGER | FOREIGN KEY REFERENCES children(id) | 所属小孩ID |
| record_date | DATE | NOT NULL | 记录日期 |
| height | DECIMAL(5,2) | NOT NULL | 身高（cm） |
| weight | DECIMAL(5,2) | NOT NULL | 体重（kg） |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 更新时间 |

### 6.4 国标数据表 (`standard_data`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 数据ID |
| age | INTEGER | NOT NULL | 年龄（岁） |
| gender | VARCHAR(10) | NOT NULL | 性别：MALE/FEMALE |
| height_short | DECIMAL(5,2) | NOT NULL | 身高矮小阈值 |
| height_low | DECIMAL(5,2) | NOT NULL | 身高偏矮阈值 |
| height_normal | DECIMAL(5,2) | NOT NULL | 身高标准阈值 |
| height_high | DECIMAL(5,2) | NOT NULL | 身高超高阈值 |
| weight_thin | DECIMAL(5,2) | NOT NULL | 体重偏瘦阈值 |
| weight_normal | DECIMAL(5,2) | NOT NULL | 体重标准阈值 |
| weight_over | DECIMAL(5,2) | NOT NULL | 体重超重阈值 |
| weight_fat | DECIMAL(5,2) | NOT NULL | 体重肥胖阈值 |

### 6.5 问题反馈表 (`feedback`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 反馈ID |
| user_id | INTEGER | FOREIGN KEY REFERENCES users(id) | 反馈用户ID |
| title | VARCHAR(100) | NOT NULL | 问题标题 |
| content | TEXT | NOT NULL | 问题内容 |
| reply | TEXT | | 回复内容 |
| status | VARCHAR(20) | DEFAULT 'PENDING' | 状态：PENDING/REPLIED |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| replied_at | TIMESTAMP | | 回复时间 |

### 6.6 App配置表 (`app_config`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 配置ID |
| app_name | VARCHAR(100) | DEFAULT '身高成长小助手' | 应用名称 |
| display_name | VARCHAR(100) | DEFAULT '身高成长小助手' | 内部显示名称 |
| server_url | VARCHAR(255) | | 服务器地址 |
| apk_version | VARCHAR(20) | DEFAULT '1.0.0' | APK版本 |
| apk_update_url | VARCHAR(255) | | APK更新地址 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 更新时间 |

### 6.7 运行日志表 (`logs`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 日志ID |
| level | VARCHAR(20) | NOT NULL | 日志级别：INFO/ERROR |
| message | TEXT | NOT NULL | 日志消息 |
| stack_trace | TEXT | | 异常堆栈 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

### 6.8 登录记录表 (`login_records`)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 记录ID |
| user_id | INTEGER | FOREIGN KEY REFERENCES users(id) | 用户ID |
| ip_address | VARCHAR(50) | | 登录IP |
| device_info | VARCHAR(255) | | 设备信息 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 登录时间 |

---

## 七、API接口设计

### 7.1 认证接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/auth/login` | POST | 用户登录，返回JWT Token | 否 |
| `/api/auth/refresh` | POST | 使用Refresh Token刷新Token | 是 |

### 7.2 用户管理接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/users` | GET | 获取用户列表（管理员） | 是(ADMIN) |
| `/api/users/{id}` | GET | 获取用户详情（管理员） | 是(ADMIN) |
| `/api/users` | POST | 创建用户 | 是(ADMIN) |
| `/api/users/{id}` | PUT | 更新用户信息 | 是(ADMIN) |
| `/api/users/{id}` | DELETE | 删除用户 | 是(ADMIN) |
| `/api/users/profile` | GET | 获取当前用户信息 | 是 |
| `/api/users/profile` | PUT | 更新当前用户信息 | 是 |

### 7.3 小孩管理接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/children` | GET | 获取当前用户的小孩列表 | 是 |
| `/api/children/{id}` | GET | 获取小孩详情 | 是 |
| `/api/children` | POST | 创建小孩 | 是 |
| `/api/children/{id}` | PUT | 更新小孩信息 | 是 |
| `/api/children/{id}` | DELETE | 删除小孩及关联数据 | 是 |

### 7.4 成长记录接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/records` | GET | 获取成长记录（支持childId筛选） | 是 |
| `/api/records/{id}` | GET | 获取记录详情 | 是 |
| `/api/records` | POST | 创建成长记录 | 是 |
| `/api/records/{id}` | PUT | 更新成长记录 | 是 |
| `/api/records/{id}` | DELETE | 删除成长记录 | 是 |

### 7.5 国标数据接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/standard` | GET | 获取国标数据列表 | 是 |
| `/api/standard` | POST | 批量导入国标数据 | 是(ADMIN) |
| `/api/standard/{id}` | PUT | 更新单条国标数据 | 是(ADMIN) |
| `/api/standard/export` | GET | 导出国标数据（Excel） | 是(ADMIN) |

### 7.6 问题反馈接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/feedback` | GET | 获取所有反馈（管理员） | 是(ADMIN) |
| `/api/feedback/user` | GET | 获取当前用户反馈 | 是 |
| `/api/feedback` | POST | 创建反馈 | 是 |
| `/api/feedback/{id}/reply` | PUT | 回复反馈 | 是(ADMIN) |
| `/api/feedback/{id}` | DELETE | 删除反馈 | 是(ADMIN) |

### 7.7 App配置接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/app/config` | GET | 获取App配置 | 是 |
| `/api/app/config` | PUT | 更新App配置 | 是(ADMIN) |
| `/api/app/apk/upload` | POST | 上传APK文件 | 是(ADMIN) |
| `/api/app/apk/download` | GET | 下载APK文件 | 否 |

### 7.8 日志接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/logs` | GET | 获取日志列表（支持level筛选） | 是(ADMIN) |
| `/api/logs/{id}` | GET | 获取日志详情 | 是(ADMIN) |

### 7.9 登录记录接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/login-records` | GET | 获取登录记录列表 | 是(ADMIN) |

### 7.10 备份接口

| API路径 | HTTP方法 | 功能描述 | 需要认证 |
|---------|----------|----------|----------|
| `/api/backup/create` | POST | 创建数据备份 | 是(ADMIN) |
| `/api/backup/download` | GET | 下载备份文件 | 是(ADMIN) |
| `/api/backup/restore` | POST | 还原备份数据 | 是(ADMIN) |
| `/api/backup/reset` | POST | 重置所有数据 | 是(ADMIN) |

---

## 八、国标数据初始化

### 8.1 男孩国标数据（1-18岁）

| 年龄 | 身高矮小(cm) | 身高偏矮(cm) | 身高标准(cm) | 身高超高(cm) | 体重偏瘦(kg) | 体重标准(kg) | 体重超重(kg) | 体重肥胖(kg) |
|------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|
| 1 | 71.2 | 73.8 | 76.5 | 79.3 | 9 | 10.05 | 11.23 | 12.54 |
| 2 | 81.6 | 85.1 | 88.5 | 92.1 | 11.24 | 12.54 | 14.01 | 15.37 |
| 3 | 89.3 | 93 | 96.8 | 100.7 | 13.13 | 14.65 | 16.39 | 18.37 |
| 4 | 96.3 | 100.2 | 104.1 | 108.2 | 14.88 | 16.64 | 18.67 | 21.01 |
| 5 | 102.8 | 107 | 111.3 | 115.7 | 16.87 | 18.98 | 21.46 | 24.38 |
| 6 | 108.6 | 113.1 | 117.7 | 122.4 | 18.71 | 21.26 | 24.32 | 28.03 |
| 7 | 114 | 119 | 124 | 129.1 | 20.83 | 24.06 | 28.05 | 33.08 |
| 8 | 119.3 | 124.6 | 130 | 135.5 | 23.23 | 27.33 | 32.57 | 39.41 |
| 9 | 123.9 | 129.6 | 135.4 | 141.2 | 25.5 | 30.46 | 36.92 | 45.52 |
| 10 | 127.9 | 134 | 140.2 | 146.1 | 27.93 | 33.74 | 41.31 | 51.38 |
| 11 | 132.1 | 138.7 | 145.3 | 152.1 | 30.95 | 37.69 | 46.33 | 57.58 |
| 12 | 137.2 | 144.6 | 151.9 | 159.4 | 34.67 | 42.49 | 52.31 | 64.68 |
| 13 | 144 | 151.8 | 159.5 | 167.3 | 39.22 | 48.08 | 59.04 | 72.6 |
| 14 | 151.5 | 158.7 | 165.9 | 173.1 | 44.08 | 53.37 | 64.84 | 79.07 |
| 15 | 156.7 | 163.3 | 169.8 | 176.3 | 48 | 57.08 | 68.35 | 82.45 |
| 16 | 159.1 | 165.4 | 171.6 | 177.8 | 50.62 | 59.35 | 70.2 | 83.85 |
| 17 | 160.1 | 166.3 | 172.3 | 178.4 | 52.2 | 60.68 | 71.2 | 84.45 |
| 18 | 160.5 | 166.6 | 172.7 | 178.7 | 53.08 | 61.4 | 71.73 | 84.72 |

### 8.2 女孩国标数据（1-18岁）

| 年龄 | 身高矮小(cm) | 身高偏矮(cm) | 身高标准(cm) | 身高超高(cm) | 体重偏瘦(kg) | 体重标准(kg) | 体重超重(kg) | 体重肥胖(kg) |
|------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|
| 1 | 69.7 | 72.3 | 75 | 77.7 | 8.45 | 9.4 | 10.48 | 11.73 |
| 2 | 80.5 | 83.8 | 87.2 | 90.7 | 10.7 | 11.92 | 13.31 | 14.92 |
| 3 | 88.2 | 91.8 | 95.6 | 99.4 | 12.65 | 14.13 | 15.83 | 17.81 |
| 4 | 95.4 | 99.2 | 103.1 | 107 | 14.44 | 16.17 | 18.19 | 20.54 |
| 5 | 101.8 | 106 | 110.2 | 114.5 | 16.2 | 18.26 | 20.66 | 23.5 |
| 6 | 107.6 | 112 | 116.6 | 121.2 | 17.94 | 20.37 | 23.27 | 26.74 |
| 7 | 112.7 | 117.6 | 122.5 | 127.6 | 19.74 | 22.64 | 26.16 | 30.45 |
| 8 | 117.9 | 123.1 | 128.5 | 133.9 | 21.75 | 25.25 | 29.56 | 34.94 |
| 9 | 122.6 | 128.3 | 134.1 | 139.9 | 23.96 | 28.19 | 33.51 | 40.32 |
| 10 | 127.6 | 133.8 | 140.1 | 146.4 | 26.6 | 31.76 | 38.41 | 47.15 |
| 11 | 133.4 | 140 | 146.6 | 153.3 | 29.99 | 36.1 | 44.09 | 54.78 |
| 12 | 135.4 | 143 | 148.9 | 156.4 | 31.48 | 38.6 | 46.7 | 58.59 |
| 13 | 139.5 | 145.9 | 152.4 | 158.8 | 34.04 | 40.77 | 49.54 | 61.22 |
| 14 | 147.2 | 152.9 | 158.6 | 164.3 | 41.18 | 47.83 | 56.61 | 66.77 |
| 15 | 148.8 | 154.3 | 159.8 | 165.3 | 43.42 | 49.82 | 57.72 | 67.61 |
| 16 | 149.2 | 154.7 | 160.1 | 165.5 | 44.56 | 50.81 | 58.45 | 67.93 |
| 17 | 149.5 | 154.9 | 160.3 | 165.7 | 45.01 | 51.2 | 58.73 | 68.04 |
| 18 | 149.8 | 155.2 | 160.6 | 165.9 | 45.26 | 51.41 | 58.88 | 68.1 |

---

## 九、开发计划

### 9.1 阶段一：服务端基础框架搭建（5天）

| 序号 | 任务 | 预估时间 |
|------|------|----------|
| 1 | 初始化Spring Boot项目，配置Maven依赖 | 1天 |
| 2 | 配置SQLite数据源和JPA | 0.5天 |
| 3 | 创建所有数据库实体类和Repository | 1天 |
| 4 | 实现JWT认证（Token生成、验证、过滤器） | 1.5天 |
| 5 | 创建用户管理API（管理员账户管理） | 1天 |

### 9.2 阶段二：服务端业务功能开发（5天）

| 序号 | 任务 | 预估时间 |
|------|------|----------|
| 6 | 小孩管理API（增删改查） | 1天 |
| 7 | 成长记录API（增删改查） | 1天 |
| 8 | 国标数据API（导入导出） | 1天 |
| 9 | 问题反馈API和App配置API | 1天 |
| 10 | 日志API、登录记录API、备份还原API | 1天 |

### 9.3 阶段三：前端管理后台开发（5天）

| 序号 | 任务 | 预估时间 |
|------|------|----------|
| 11 | 初始化Vue项目，配置Element Plus | 0.5天 |
| 12 | 登录页面和权限路由配置 | 0.5天 |
| 13 | 用户管理页面和问题反馈页面 | 1天 |
| 14 | App配置页面和国标数据页面 | 1天 |
| 15 | 日志页面、登录记录页面、备份还原页面 | 2天 |

### 9.4 阶段四：安卓客户端开发（10天）

| 序号 | 任务 | 预估时间 |
|------|------|----------|
| 16 | 初始化Android项目，配置Gradle依赖 | 1天 |
| 17 | 配置Room数据库和Retrofit | 1天 |
| 18 | 登录模块（登录、持久化、退出） | 1天 |
| 19 | 小孩信息管理模块 | 2天 |
| 20 | 成长状态展示模块（卡通形象、评估显示） | 2天 |
| 21 | 成长曲线模块（图表展示） | 1天 |
| 22 | 成长记录模块（添加、修改、删除） | 1天 |
| 23 | 设置模块（反馈、备份还原）和离线同步 | 1天 |

### 9.5 阶段五：部署与测试（4天）

| 序号 | 任务 | 预估时间 |
|------|------|----------|
| 24 | Docker配置和Dockerfile编写 | 1天 |
| 25 | 部署文档编写 | 1天 |
| 26 | 功能测试和Bug修复 | 1.5天 |
| 27 | 项目发布 | 0.5天 |

---

## 十、部署说明

### 10.1 Docker部署

服务端使用Docker部署，需要打包以下内容：

- `backend/` 目录下的所有代码
- `Dockerfile`
- `docker-compose.yml`
- `pom.xml`

### 10.2 Dockerfile示例

```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY target/height4kid-1.0.0.jar app.jar
EXPOSE 8080
VOLUME /app/uploads
VOLUME /app/backups
VOLUME /app/data
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 10.3 docker-compose.yml示例

```yaml
version: '3.8'
services:
  height4kid:
    build: .
    container_name: height4kid
    ports:
      - "8080:8080"
    volumes:
      - ./uploads:/app/uploads
      - ./backups:/app/backups
      - ./data:/app/data
    environment:
      - SERVER_PORT=8080
      - JWT_SECRET=your-secret-key-here
      - JWT_EXPIRE=86400
    restart: always
```

### 10.4 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| SERVER_PORT | 服务端口 | 8080 |
| JWT_SECRET | JWT密钥 | 自动生成 |
| JWT_EXPIRE | Token过期时间(秒) | 86400 |
| UPLOAD_DIR | 文件上传目录 | ./uploads |
| BACKUP_DIR | 备份目录 | ./backups |

---

**文档版本**: 1.1  
**创建时间**: 2026-04-29  
**作者**: Height4Kid开发团队
