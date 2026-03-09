# 身高成长小助手（Height4Kid）服务端部署教程

## 部署到 Zeabur

### 步骤 1：准备工作

1. 确保你已经在 GitHub 上创建了仓库，并将代码推送到仓库中。
2. 访问 [Zeabur](https://zeabur.com/) 官网，注册并登录账号。

### 步骤 2：创建项目

1. 在 Zeabur 控制台中，点击 "Create Project" 按钮。
2. 输入项目名称，例如 "Height4Kid"，然后点击 "Create"。

### 步骤 3：添加服务

1. 在项目页面中，点击 "Add Service" 按钮。
2. 选择 "GitHub" 作为服务来源。
3. 选择你的 GitHub 仓库，然后点击 "Import"。
4. 在服务配置页面，选择 "Node.js" 作为构建方式。
5. 设置构建命令为 `npm install && npm run build`。
6. 设置启动命令为 `npm run backend`。
7. 点击 "Deploy" 按钮开始部署。

### 步骤 4：配置环境变量

1. 在服务页面中，点击 "Settings" 选项卡。
2. 点击 "Environment Variables" 部分的 "Add Variable" 按钮。
3. 添加以下环境变量：
   - `PORT`: 8000
   - `JWT_SECRET`: 一个安全的密钥，用于生成 JWT token
4. 点击 "Save" 按钮保存环境变量。

### 步骤 5：配置网络

1. 在服务页面中，点击 "Settings" 选项卡。
2. 点击 "Network" 部分。
3. 确保服务的端口设置为 8000。
4. 点击 "Save" 按钮保存网络配置。

### 步骤 6：配置硬盘

1. 在服务页面中，点击 "Settings" 选项卡。
2. 点击 "Storage" 部分。
3. 添加一个存储卷，路径设置为 `/app/database`，用于存储 SQLite 数据库文件。
4. 点击 "Save" 按钮保存存储配置。

### 步骤 7：访问服务

1. 部署完成后，Zeabur 会为服务分配一个域名。
2. 你可以通过该域名访问服务，例如 `https://height4kid.zeabur.app`。

## 本地开发

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

## API 文档

### 认证

- **登录**: POST /api/login
  - 输入: `{"username": "admin", "password": "admin123"}`
  - 输出: `{"token": "...", "user": {...}}`

### 管理员功能

- **获取用户列表**: GET /api/admin/users
- **添加用户**: POST /api/admin/users
- **更新用户**: PUT /api/admin/users/:id
- **删除用户**: DELETE /api/admin/users/:id
- **获取反馈列表**: GET /api/admin/feedback
- **回复反馈**: PUT /api/admin/feedback/:id
- **删除反馈**: DELETE /api/admin/feedback/:id
- **获取国标数据**: GET /api/admin/standard-data
- **添加国标数据**: POST /api/admin/standard-data
- **获取登录记录**: GET /api/admin/login-records

### 普通用户功能

- **获取小孩列表**: GET /api/user/children
- **添加小孩**: POST /api/user/children
- **更新小孩**: PUT /api/user/children/:id
- **删除小孩**: DELETE /api/user/children/:id
- **获取成长记录**: GET /api/user/growth-records/:childId
- **添加成长记录**: POST /api/user/growth-records
- **提交反馈**: POST /api/user/feedback
- **获取国标数据**: GET /api/user/standard-data
- **分析成长状态**: POST /api/user/analyze-growth