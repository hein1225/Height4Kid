# 身高成长小助手（Height4Kid）- 实施计划

## 项目概述
身高成长小助手（Height4Kid）是一个用于记录和分析小孩身高成长的项目，分为服务端和安卓客户端两部分。服务端通过 Zeabur 部署，客户端通过 Flutter 开发。

### 登录方式限制
- **普通用户**：仅能通过客户端软件登录，无法通过网址登录
- **管理员**：仅能通过网址登录
- **客户端首次登录**：需要输入服务端网址

### GitHub仓库地址
- **服务端**：https://github.com/hein1225/Height4Kid
- **客户端**：https://github.com/hein1225/Height4Kid

## 技术栈选择

### 服务端
- **后端框架**：Express.js (Node.js)
- **数据库**：SQLite (满足项目需求，轻量级且适合中小规模应用，支持数据持久化)
- **认证**：JWT
- **前端**：React + Vite
- **样式**：Tailwind CSS

### 客户端
- **框架**：Flutter
- **状态管理**：Provider
- **网络请求**：Dio

## 项目结构

### 服务端 (`server/`)
- `src/`
  - `controllers/` - 控制器
  - `models/` - 数据模型
  - `routes/` - 路由
  - `middleware/` - 中间件
  - `config/` - 配置
  - `utils/` - 工具函数
  - `public/` - 静态文件
- `database/` - 数据库文件
- `package.json` - 依赖管理
- `vite.config.js` - Vite 配置

### 客户端 (`client/`)
- `lib/`
  - `src/`
    - `pages/` - 页面
    - `components/` - 组件
    - `services/` - 服务
    - `models/` - 数据模型
    - `utils/` - 工具函数
    - `providers/` - 状态管理
  - `main.dart` - 入口文件
- `pubspec.yaml` - 依赖管理

## 实施任务

### 1. 项目初始化

#### [x] 任务 1.1: 创建项目目录结构
- **Priority**: P0
- **Depends On**: None
- **Description**: 创建服务端和客户端的目录结构
- **Success Criteria**: 目录结构完整，包含所有必要的文件夹
- **Test Requirements**:
  - `programmatic` TR-1.1: 所有必要目录存在
  - `human-judgement` TR-1.2: 目录结构清晰合理

#### [x] 任务 1.2: 初始化服务端项目
- **Priority**: P0
- **Depends On**: 任务 1.1
- **Description**: 初始化 Express.js + React 项目，安装必要依赖
- **Success Criteria**: 服务端项目能够正常启动
- **Test Requirements**:
  - `programmatic` TR-1.2.1: 项目能够通过 `npm run dev` 启动
  - `programmatic` TR-1.2.2: 所有依赖正确安装

#### [x] 任务 1.3: 初始化客户端项目
- **Priority**: P0
- **Depends On**: 任务 1.1
- **Description**: 初始化 Flutter 项目，安装必要依赖
- **Success Criteria**: 客户端项目能够正常构建
- **Test Requirements**:
  - `programmatic` TR-1.3.1: 项目能够通过 `flutter run` 运行
  - `programmatic` TR-1.3.2: 所有依赖正确安装

### 2. 核心功能开发

#### [x] 任务 2.1: 数据库设计与初始化
- **Priority**: P0
- **Depends On**: 任务 1.2
- **Description**: 设计数据库表结构，初始化 SQLite 数据库
- **Success Criteria**: 数据库结构完整，包含所有必要的表
- **Test Requirements**:
  - `programmatic` TR-2.1.1: 数据库文件创建成功
  - `programmatic` TR-2.1.2: 所有表结构正确创建

#### [x] 任务 2.2: 认证系统开发
- **Priority**: P0
- **Depends On**: 任务 2.1
- **Description**: 开发管理员和普通用户的认证系统
- **Success Criteria**: 能够实现登录、注册、权限验证
- **Test Requirements**:
  - `programmatic` TR-2.2.1: 管理员能够使用默认账号登录
  - `programmatic` TR-2.2.2: 普通用户能够登录
  - `programmatic` TR-2.2.3: 权限验证正确

#### [x] 任务 2.3: 管理员功能开发
- **Priority**: P1
- **Depends On**: 任务 2.2
- **Description**: 开发管理员的各项功能，包括账户管理、问题反馈、项目标题修改等
- **Success Criteria**: 所有管理员功能正常工作
- **Test Requirements**:
  - `programmatic` TR-2.3.1: 能够管理账户
  - `programmatic` TR-2.3.2: 能够查看和回复问题反馈
  - `programmatic` TR-2.3.3: 能够修改项目标题
  - `programmatic` TR-2.3.4: 能够导入国标数据
  - `programmatic` TR-2.3.5: 能够查看运行日志
  - `programmatic` TR-2.3.6: 能够查看普通账户登录记录
  - `programmatic` TR-2.3.7: 能够备份和还原数据
  - `programmatic` TR-2.3.8: 能够重置所有数据

#### [x] 任务 2.4: 普通用户功能开发
- **Priority**: P1
- **Depends On**: 任务 2.2
- **Description**: 开发普通用户的各项功能，包括小孩信息管理、成长状态分析、成长曲线等
- **Success Criteria**: 所有普通用户功能正常工作
- **Test Requirements**:
  - `programmatic` TR-2.4.1: 能够管理小孩信息
  - `programmatic` TR-2.4.2: 能够记录成长信息
  - `programmatic` TR-2.4.3: 能够查看成长曲线
  - `programmatic` TR-2.4.4: 能够反馈问题
  - `programmatic` TR-2.4.5: 能够备份和还原数据
  - `programmatic` TR-2.4.6: 能够通过GitHub API (https://api.github.com/repos/hein1225/Height4Kid/releases) 检查软件更新

#### [x] 任务 2.5: 国标数据管理
- **Priority**: P1
- **Depends On**: 任务 2.1
- **Description**: 实现国标数据的导入、导出和分析功能
- **Success Criteria**: 能够正确分析小孩身高体重是否符合国标
- **Test Requirements**:
  - `programmatic` TR-2.5.1: 能够导入国标数据
  - `programmatic` TR-2.5.2: 能够导出国标数据
  - `programmatic` TR-2.5.3: 能够根据国标数据分析小孩成长状态

### 3. 界面开发

#### [x] 任务 3.1: 管理员界面开发
- **Priority**: P1
- **Depends On**: 任务 2.3
- **Description**: 开发管理员界面，使用明亮的蓝色和绿色作为主色调
- **Success Criteria**: 界面美观，功能齐全，响应式设计
- **Test Requirements**:
  - `human-judgement` TR-3.1.1: 界面美观，色调符合要求
  - `programmatic` TR-3.1.2: 所有功能按钮正常工作
  - `programmatic` TR-3.1.3: 响应式设计，适合手机浏览

#### [x] 任务 3.2: 普通用户界面开发
- **Priority**: P1
- **Depends On**: 任务 2.4
- **Description**: 开发普通用户界面，男孩使用明亮的蓝色和绿色，女孩使用明亮的粉色和黄色
- **Success Criteria**: 界面美观，功能齐全，响应式设计
- **Test Requirements**:
  - `human-judgement` TR-3.2.1: 界面美观，色调符合要求
  - `programmatic` TR-3.2.2: 所有功能按钮正常工作
  - `programmatic` TR-3.2.3: 响应式设计，适合手机浏览

#### [x] 任务 3.3: 客户端界面开发
- **Priority**: P1
- **Depends On**: 任务 1.3, 任务 2.4
- **Description**: 开发 Flutter 客户端界面，实现与服务端相同的功能
- **Success Criteria**: 界面美观，功能齐全，响应式设计
- **Test Requirements**:
  - `human-judgement` TR-3.3.1: 界面美观，符合 Flutter 设计规范
  - `programmatic` TR-3.3.2: 所有功能正常工作
  - `programmatic` TR-3.3.3: 能够正常连接服务端

### 4. 部署与测试

#### [x] 任务 4.1: 服务端部署到 Zeabur
- **Priority**: P1
- **Depends On**: 任务 2.3, 任务 2.4, 任务 2.5, 任务 3.1, 任务 3.2
- **Description**: 配置 Zeabur 部署，包括环境变量、网络设置等。需要上传 `server/` 文件夹到 Zeabur
- **Success Criteria**: 服务端成功部署到 Zeabur，能够正常访问
- **Test Requirements**:
  - `programmatic` TR-4.1.1: 服务端能够通过 Zeabur 访问
  - `programmatic` TR-4.1.2: 所有功能正常工作

#### [x] 任务 4.2: 客户端构建与签名
- **Priority**: P1
- **Depends On**: 任务 3.3
- **Description**: 构建 Flutter 客户端，生成签名文件，构建 release 版本
- **Success Criteria**: 生成可安装的 APK 文件
- **Test Requirements**:
  - `programmatic` TR-4.2.1: 能够生成签名文件
  - `programmatic` TR-4.2.2: 能够构建 release 版本
  - `programmatic` TR-4.2.3: APK 文件能够正常安装

#### [x] 任务 4.3: 系统测试
- **Priority**: P1
- **Depends On**: 任务 4.1, 任务 4.2
- **Description**: 测试整个系统的功能，包括服务端和客户端
- **Success Criteria**: 所有功能正常工作，无明显 bug
- **Test Requirements**:
  - `programmatic` TR-4.3.1: 所有 API 接口正常工作
  - `programmatic` TR-4.3.2: 客户端能够正常连接服务端
  - `human-judgement` TR-4.3.3: 界面美观，用户体验良好

### 5. 文档与教程

#### [x] 任务 5.1: 编写部署教程
- **Priority**: P2
- **Depends On**: 任务 4.1
- **Description**: 编写 Zeabur 部署的详细教程，适合新手
- **Success Criteria**: 教程详细，步骤清晰，新手能够按照教程成功部署
- **Test Requirements**:
  - `human-judgement` TR-5.1.1: 教程内容完整
  - `human-judgement` TR-5.1.2: 步骤清晰易懂

#### [ ] 任务 5.2: 编写使用文档
- **Priority**: P2
- **Depends On**: 任务 4.3
- **Description**: 编写系统的使用文档，包括管理员和普通用户的使用方法
- **Success Criteria**: 文档完整，能够指导用户使用系统的所有功能
- **Test Requirements**:
  - `human-judgement` TR-5.2.1: 文档内容完整
  - `human-judgement` TR-5.2.2: 说明清晰易懂

## 时间线

| 阶段 | 任务 | 预计时间 |
|------|------|----------|
| 准备阶段 | 项目初始化 | 2 天 |
| 核心开发 | 数据库设计与认证系统 | 3 天 |
| 核心开发 | 管理员功能 | 3 天 |
| 核心开发 | 普通用户功能 | 3 天 |
| 核心开发 | 国标数据管理 | 2 天 |
| 界面开发 | 管理员界面 | 2 天 |
| 界面开发 | 普通用户界面 | 2 天 |
| 界面开发 | 客户端界面 | 3 天 |
| 部署测试 | 服务端部署 | 1 天 |
| 部署测试 | 客户端构建 | 1 天 |
| 部署测试 | 系统测试 | 2 天 |
| 文档编写 | 部署教程与使用文档 | 2 天 |

## 总计
- **总任务数**: 20
- **预计总时间**: 26 天

## 注意事项
1. 数据库使用 SQLite，确保数据持久化
2. 界面设计要注重用户体验，特别是手机浏览体验
3. 确保系统安全性，特别是认证和授权部分
4. 提供详细的部署教程，确保新手能够成功部署
5. 测试要全面，确保所有功能正常工作