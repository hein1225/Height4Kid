const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const path = require('path');
const xlsx = require('xlsx');
const multer = require('multer');

// 配置multer用于文件上传
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// 加载环境变量
dotenv.config();

// 创建 Express 应用
const app = express();
const PORT = process.env.PORT || 8000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务
app.use(express.static(path.join(__dirname, 'dist')));

// 初始化数据库
// 从环境变量中读取database目录，默认使用当前目录下的database目录
const dbDir = process.env.DATABASE_DIR || path.join(__dirname, 'database');
const dbPath = path.join(dbDir, 'height4kid.db');

// 确保database目录存在
const fs = require('fs');
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
  console.log(`Created database directory: ${dbDir}`);
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to the SQLite database.');
    // 创建表
    createTables();
    
    // 启动服务器
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  }
});

// 创建表函数
function createTables() {
  // 用户表
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'user',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // 小孩信息表
  db.run(`
    CREATE TABLE IF NOT EXISTS children (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      birth_date TEXT NOT NULL,
      gender TEXT NOT NULL,
      avatar TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // 成长记录表
  db.run(`
    CREATE TABLE IF NOT EXISTS growth_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      child_id INTEGER NOT NULL,
      record_date TEXT NOT NULL,
      height REAL NOT NULL,
      weight REAL NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (child_id) REFERENCES children(id)
    )
  `);

  // 国标数据表
  db.run(`
    DROP TABLE IF EXISTS standard_data
  `, (err) => {
    if (err) {
      console.error('Error dropping standard_data table:', err.message);
    }
    db.run(`
      CREATE TABLE standard_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        age TEXT NOT NULL,
        gender TEXT NOT NULL,
        height_low REAL NOT NULL,
        height_normal_low REAL NOT NULL,
        height_normal_high REAL NOT NULL,
        height_high REAL NOT NULL,
        weight_low REAL NOT NULL,
        weight_normal_low REAL NOT NULL,
        weight_normal_high REAL NOT NULL,
        weight_overweight REAL NOT NULL,
        weight_high REAL NOT NULL
      )
    `, (err) => {
      if (err) {
        console.error('Error creating standard_data table:', err.message);
      } else {
        // 插入国标数据
        const standardData = [
          // 男孩数据
          { age: '1岁', gender: '男', height_low: 71.2, height_normal_low: 73.8, height_normal_high: 76.5, height_high: 79.3, weight_low: 9, weight_normal_low: 10.05, weight_normal_high: 11.23, weight_overweight: 11.23, weight_high: 12.54 },
          { age: '2岁', gender: '男', height_low: 81.6, height_normal_low: 85.1, height_normal_high: 88.5, height_high: 92.1, weight_low: 11.24, weight_normal_low: 12.54, weight_normal_high: 14.01, weight_overweight: 14.01, weight_high: 15.37 },
          { age: '3岁', gender: '男', height_low: 89.3, height_normal_low: 93.2, height_normal_high: 96.8, height_high: 100.7, weight_low: 13.13, weight_normal_low: 14.65, weight_normal_high: 16.39, weight_overweight: 16.39, weight_high: 18.37 },
          { age: '4岁', gender: '男', height_low: 96.3, height_normal_low: 100, height_normal_high: 104.1, height_high: 108.2, weight_low: 14.88, weight_normal_low: 16.64, weight_normal_high: 18.67, weight_overweight: 18.67, weight_high: 21.01 },
          { age: '5岁', gender: '男', height_low: 102.8, height_normal_low: 107, height_normal_high: 111.3, height_high: 115.7, weight_low: 16.87, weight_normal_low: 18.98, weight_normal_high: 21.46, weight_overweight: 21.46, weight_high: 24.38 },
          { age: '6岁', gender: '男', height_low: 108.6, height_normal_low: 113.1, height_normal_high: 117.7, height_high: 122.4, weight_low: 18.71, weight_normal_low: 21.26, weight_normal_high: 24.32, weight_overweight: 24.32, weight_high: 28.03 },
          { age: '7岁', gender: '男', height_low: 114, height_normal_low: 119, height_normal_high: 124, height_high: 129.1, weight_low: 20.83, weight_normal_low: 24.06, weight_normal_high: 28.05, weight_overweight: 28.05, weight_high: 33.08 },
          { age: '8岁', gender: '男', height_low: 119.3, height_normal_low: 124.6, height_normal_high: 130, height_high: 135.5, weight_low: 23.23, weight_normal_low: 27.33, weight_normal_high: 32.57, weight_overweight: 32.57, weight_high: 39.41 },
          { age: '9岁', gender: '男', height_low: 123.9, height_normal_low: 129.6, height_normal_high: 135.4, height_high: 141.2, weight_low: 25.5, weight_normal_low: 30.46, weight_normal_high: 36.92, weight_overweight: 36.92, weight_high: 45.52 },
          { age: '10岁', gender: '男', height_low: 127.9, height_normal_low: 134, height_normal_high: 140.2, height_high: 146.4, weight_low: 27.93, weight_normal_low: 33.74, weight_normal_high: 41.31, weight_overweight: 41.31, weight_high: 51.38 },
          { age: '11岁', gender: '男', height_low: 132.1, height_normal_low: 138.7, height_normal_high: 145.3, height_high: 152.1, weight_low: 30.95, weight_normal_low: 37.69, weight_normal_high: 46.33, weight_overweight: 46.33, weight_high: 57.58 },
          { age: '12岁', gender: '男', height_low: 137.2, height_normal_low: 144.6, height_normal_high: 151.9, height_high: 159.4, weight_low: 34.67, weight_normal_low: 42.49, weight_normal_high: 52.31, weight_overweight: 52.31, weight_high: 64.68 },
          { age: '13岁', gender: '男', height_low: 144, height_normal_low: 151.8, height_normal_high: 159.5, height_high: 167.3, weight_low: 39.22, weight_normal_low: 48.08, weight_normal_high: 59.04, weight_overweight: 59.04, weight_high: 72.6 },
          { age: '14岁', gender: '男', height_low: 151.5, height_normal_low: 158.7, height_normal_high: 165.9, height_high: 173.1, weight_low: 44.08, weight_normal_low: 53.37, weight_normal_high: 64.84, weight_overweight: 64.84, weight_high: 79.07 },
          { age: '15岁', gender: '男', height_low: 156.7, height_normal_low: 163.3, height_normal_high: 169.8, height_high: 176.3, weight_low: 48, weight_normal_low: 57.08, weight_normal_high: 68.35, weight_overweight: 68.35, weight_high: 82.45 },
          { age: '16岁', gender: '男', height_low: 159.1, height_normal_low: 165.4, height_normal_high: 171.6, height_high: 177.8, weight_low: 50.62, weight_normal_low: 59.35, weight_normal_high: 70.2, weight_overweight: 70.2, weight_high: 83.85 },
          { age: '17岁', gender: '男', height_low: 160.1, height_normal_low: 166.3, height_normal_high: 172.3, height_high: 178.4, weight_low: 52.2, weight_normal_low: 60.68, weight_normal_high: 71.2, weight_overweight: 71.2, weight_high: 84.45 },
          { age: '18岁', gender: '男', height_low: 160.5, height_normal_low: 166.6, height_normal_high: 172.7, height_high: 178.7, weight_low: 53.08, weight_normal_low: 61.4, weight_normal_high: 71.73, weight_overweight: 71.73, weight_high: 84.72 },
          // 女孩数据
          { age: '1岁', gender: '女', height_low: 69.7, height_normal_low: 72.3, height_normal_high: 75, height_high: 77.7, weight_low: 8.45, weight_normal_low: 9.4, weight_normal_high: 10.48, weight_overweight: 10.48, weight_high: 11.73 },
          { age: '2岁', gender: '女', height_low: 80.5, height_normal_low: 83.8, height_normal_high: 87.2, height_high: 90.7, weight_low: 10.7, weight_normal_low: 11.92, weight_normal_high: 13.31, weight_overweight: 13.31, weight_high: 14.92 },
          { age: '3岁', gender: '女', height_low: 88.2, height_normal_low: 91.8, height_normal_high: 95.6, height_high: 99.4, weight_low: 12.65, weight_normal_low: 14.13, weight_normal_high: 15.83, weight_overweight: 15.83, weight_high: 17.81 },
          { age: '4岁', gender: '女', height_low: 95.4, height_normal_low: 99.2, height_normal_high: 103.1, height_high: 107, weight_low: 14.64, weight_normal_low: 16.17, weight_normal_high: 18.19, weight_overweight: 18.19, weight_high: 20.54 },
          { age: '5岁', gender: '女', height_low: 101.8, height_normal_low: 106, height_normal_high: 110.2, height_high: 114.5, weight_low: 16.2, weight_normal_low: 18.26, weight_normal_high: 20.66, weight_overweight: 20.66, weight_high: 23.5 },
          { age: '6岁', gender: '女', height_low: 107.6, height_normal_low: 112, height_normal_high: 116.6, height_high: 121.2, weight_low: 17.94, weight_normal_low: 20.37, weight_normal_high: 23.27, weight_overweight: 23.27, weight_high: 26.74 },
          { age: '7岁', gender: '女', height_low: 112.7, height_normal_low: 117.6, height_normal_high: 122.5, height_high: 127.6, weight_low: 19.74, weight_normal_low: 22.64, weight_normal_high: 26.16, weight_overweight: 26.16, weight_high: 30.45 },
          { age: '8岁', gender: '女', height_low: 117.9, height_normal_low: 123.1, height_normal_high: 128.5, height_high: 133.9, weight_low: 21.75, weight_normal_low: 25.25, weight_normal_high: 29.56, weight_overweight: 29.56, weight_high: 34.94 },
          { age: '9岁', gender: '女', height_low: 122.6, height_normal_low: 128.3, height_normal_high: 134.1, height_high: 139.9, weight_low: 23.96, weight_normal_low: 28.19, weight_normal_high: 33.51, weight_overweight: 33.51, weight_high: 40.32 },
          { age: '10岁', gender: '女', height_low: 127.6, height_normal_low: 133.8, height_normal_high: 140.1, height_high: 146.4, weight_low: 26.6, weight_normal_low: 31.76, weight_normal_high: 38.41, weight_overweight: 38.41, weight_high: 47.15 },
          { age: '11岁', gender: '女', height_low: 133.4, height_normal_low: 140, height_normal_high: 146.6, height_high: 153.3, weight_low: 29.99, weight_normal_low: 36.1, weight_normal_high: 44.09, weight_overweight: 44.09, weight_high: 54.78 },
          { age: '12岁', gender: '女', height_low: 135.4, height_normal_low: 143, height_normal_high: 148.9, height_high: 156.4, weight_low: 31.48, weight_normal_low: 38.6, weight_normal_high: 46.7, weight_overweight: 46.7, weight_high: 58.59 },
          { age: '13岁', gender: '女', height_low: 139.5, height_normal_low: 145.9, height_normal_high: 152.4, height_high: 158.8, weight_low: 34.04, weight_normal_low: 40.77, weight_normal_high: 49.54, weight_overweight: 49.54, weight_high: 61.22 },
          { age: '14岁', gender: '女', height_low: 147.2, height_normal_low: 152.9, height_normal_high: 158.6, height_high: 164.3, weight_low: 41.18, weight_normal_low: 47.83, weight_normal_high: 56.61, weight_overweight: 56.61, weight_high: 66.77 },
          { age: '15岁', gender: '女', height_low: 148.8, height_normal_low: 154.3, height_normal_high: 159.8, height_high: 165.3, weight_low: 43.42, weight_normal_low: 49.82, weight_normal_high: 57.72, weight_overweight: 57.72, weight_high: 67.61 },
          { age: '16岁', gender: '女', height_low: 149.2, height_normal_low: 154.7, height_normal_high: 160.1, height_high: 165.5, weight_low: 44.56, weight_normal_low: 50.81, weight_normal_high: 58.45, weight_overweight: 58.45, weight_high: 67.93 },
          { age: '17岁', gender: '女', height_low: 149.5, height_normal_low: 154.9, height_normal_high: 160.3, height_high: 165.7, weight_low: 45.01, weight_normal_low: 51.2, weight_normal_high: 58.73, weight_overweight: 58.73, weight_high: 68.04 },
          { age: '18岁', gender: '女', height_low: 149.8, height_normal_low: 155.2, height_normal_high: 160.6, height_high: 165.9, weight_low: 45.26, weight_normal_low: 51.41, weight_normal_high: 58.88, weight_overweight: 58.88, weight_high: 68.1 }
        ];
        
        standardData.forEach(data => {
          db.run(
            `INSERT INTO standard_data (age, gender, height_low, height_normal_low, height_normal_high, height_high, weight_low, weight_normal_low, weight_normal_high, weight_overweight, weight_high) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [data.age, data.gender, data.height_low, data.height_normal_low, data.height_normal_high, data.height_high, data.weight_low, data.weight_normal_low, data.weight_normal_high, data.weight_overweight, data.weight_high],
            (err) => {
              if (err) {
                console.error('Error inserting standard data:', err.message);
              }
            }
          );
        });
        console.log('Standard data initialized.');
      }
    });
  });

  // 问题反馈表
  db.run(`
    CREATE TABLE IF NOT EXISTS feedback (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      reply TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // 登录记录表
  db.run(`
    CREATE TABLE IF NOT EXISTS login_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      ip TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // 初始化管理员账号
  db.run(
    `INSERT OR IGNORE INTO users (username, password, role) VALUES (?, ?, ?)`,
    ['admin', 'admin123', 'admin'],
    (err) => {
      if (err) {
        console.error('Error initializing admin user:', err.message);
      } else {
        console.log('Admin user initialized.');
      }
    }
  );


}

// 认证中间件
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) return res.status(401).json({ message: 'Access token required' });

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user;
    next();
  });
}

// 管理员权限中间件
function requireAdmin(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
}

// 登录路由
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;

  db.get('SELECT * FROM users WHERE username = ?', [username], (err, user) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }

    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    // 简单密码验证（实际项目中应使用加密）
    if (user.password !== password) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    // 生成 JWT token
    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    // 记录登录
    db.run('INSERT INTO login_records (user_id, ip) VALUES (?, ?)', [user.id, req.ip]);

    res.json({ token, user: { id: user.id, username: user.username, role: user.role } });
  });
});

// 健康检查路由
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// 管理员路由
app.use('/api/admin', authenticateToken, requireAdmin);

// 账户管理路由
app.get('/api/admin/users', (req, res) => {
  db.all('SELECT * FROM users', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

app.post('/api/admin/users', (req, res) => {
  const { username, password, role } = req.body;
  db.run(
    'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
    [username, password, role],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'User created successfully' });
    }
  );
});

app.put('/api/admin/users/:id', (req, res) => {
  const { id } = req.params;
  const { username, password, role } = req.body;
  db.run(
    'UPDATE users SET username = ?, password = ?, role = ? WHERE id = ?',
    [username, password, role, id],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'User updated successfully' });
    }
  );
});

app.delete('/api/admin/users/:id', (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM users WHERE id = ?', [id], (err) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json({ message: 'User deleted successfully' });
  });
});

// 问题反馈路由
app.get('/api/admin/feedback', (req, res) => {
  db.all('SELECT * FROM feedback', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

app.put('/api/admin/feedback/:id', (req, res) => {
  const { id } = req.params;
  const { reply } = req.body;
  db.run(
    'UPDATE feedback SET status = ?, reply = ? WHERE id = ?',
    ['resolved', reply, id],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Feedback replied successfully' });
    }
  );
});

app.delete('/api/admin/feedback/:id', (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM feedback WHERE id = ?', [id], (err) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json({ message: 'Feedback deleted successfully' });
  });
});

// 国标数据路由
app.get('/api/admin/standard-data', (req, res) => {
  db.all('SELECT * FROM standard_data', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

app.post('/api/admin/standard-data', (req, res) => {
  const data = req.body;
  db.run(
    'INSERT INTO standard_data (age, gender, height_low, height_normal_low, height_normal_high, height_high, weight_low, weight_normal_low, weight_normal_high, weight_high) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [data.age, data.gender, data.height_low, data.height_normal_low, data.height_normal_high, data.height_high, data.weight_low, data.weight_normal_low, data.weight_normal_high, data.weight_high],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Standard data added successfully' });
    }
  );
});

// 清空国标数据路由
app.delete('/api/admin/standard-data/clear', (req, res) => {
  db.run('DELETE FROM standard_data', (err) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json({ message: 'Standard data cleared successfully' });
  });
});

// 导出国标数据为xlsx
app.get('/api/admin/standard-data/export/xlsx', (req, res) => {
  db.all('SELECT * FROM standard_data', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    
    // 转换数据格式
    const data = rows.map(row => ({
      年龄: row.age,
      性别: row.gender,
      身高矮小: row.height_low,
      身高偏矮: row.height_normal_low,
      身高标准: row.height_normal_high,
      身高超高: row.height_high,
      体重偏瘦: row.weight_low,
      体重标准下限: row.weight_normal_low,
      体重标准上限: row.weight_normal_high,
      体重超重: row.weight_overweight,
      体重肥胖: row.weight_high
    }));
    
    // 按性别分组
    const maleData = data.filter(row => row.性别 === '男').sort((a, b) => {
      // 提取年龄数字并排序
      const ageA = parseInt(a.年龄);
      const ageB = parseInt(b.年龄);
      return ageA - ageB;
    });
    const femaleData = data.filter(row => row.性别 === '女').sort((a, b) => {
      // 提取年龄数字并排序
      const ageA = parseInt(a.年龄);
      const ageB = parseInt(b.年龄);
      return ageA - ageB;
    });
    
    // 创建工作簿
    const wb = xlsx.utils.book_new();
    
    // 创建男性数据工作表
    const maleWs = xlsx.utils.json_to_sheet(maleData);
    xlsx.utils.book_append_sheet(wb, maleWs, '男性数据');
    
    // 创建女性数据工作表
    const femaleWs = xlsx.utils.json_to_sheet(femaleData);
    xlsx.utils.book_append_sheet(wb, femaleWs, '女性数据');
    
    // 生成Excel文件
    const excelBuffer = xlsx.write(wb, { bookType: 'xlsx', type: 'buffer' });
    
    // 设置响应头
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=standard_data.xlsx');
    
    // 发送文件
    res.send(excelBuffer);
  });
});

// 导入国标数据从xlsx
app.post('/api/admin/standard-data/import/xlsx', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }
  
  try {
    // 读取Excel文件
    const workbook = xlsx.read(req.file.buffer, { type: 'buffer' });
    let allData = [];
    
    // 读取所有工作表
    workbook.SheetNames.forEach(sheetName => {
      const worksheet = workbook.Sheets[sheetName];
      const sheetData = xlsx.utils.sheet_to_json(worksheet);
      allData = allData.concat(sheetData);
    });
    
    // 按年龄排序
    allData.sort((a, b) => {
      const ageA = parseInt(a.年龄);
      const ageB = parseInt(b.年龄);
      return ageA - ageB;
    });
    
    // 清空现有数据
    db.run('DELETE FROM standard_data', (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      
      // 导入新数据
      let count = 0;
      allData.forEach(row => {
        db.run(
          'INSERT INTO standard_data (age, gender, height_low, height_normal_low, height_normal_high, height_high, weight_low, weight_normal_low, weight_normal_high, weight_overweight, weight_high) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            row.年龄,
            row.性别,
            row.身高矮小,
            row.身高偏矮,
            row.身高标准,
            row.身高超高,
            row.体重偏瘦,
            row.体重标准下限,
            row.体重标准上限,
            row.体重超重,
            row.体重肥胖
          ],
          (err) => {
            if (err) {
              console.error('Error inserting standard data:', err.message);
            }
            count++;
            if (count === allData.length) {
              res.json({ message: 'Standard data imported successfully' });
            }
          }
        );
      });
    });
  } catch (err) {
    console.error('Error importing Excel file:', err);
    res.status(500).json({ message: 'Error importing Excel file' });
  }
});

// 登录记录路由
app.get('/api/admin/login-records', (req, res) => {
  db.all('SELECT * FROM login_records', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

// 普通用户路由
app.use('/api/user', authenticateToken);

// 小孩信息管理路由
app.get('/api/user/children', (req, res) => {
  const userId = req.user.id;
  db.all('SELECT * FROM children WHERE user_id = ?', [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

app.post('/api/user/children', (req, res) => {
  const userId = req.user.id;
  const { name, birth_date, gender, avatar } = req.body;
  db.run(
    'INSERT INTO children (user_id, name, birth_date, gender, avatar) VALUES (?, ?, ?, ?, ?)',
    [userId, name, birth_date, gender, avatar],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Child added successfully' });
    }
  );
});

app.put('/api/user/children/:id', (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  const { name, birth_date, gender, avatar } = req.body;
  db.run(
    'UPDATE children SET name = ?, birth_date = ?, gender = ?, avatar = ? WHERE id = ? AND user_id = ?',
    [name, birth_date, gender, avatar, id, userId],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Child updated successfully' });
    }
  );
});

app.delete('/api/user/children/:id', (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  // 先删除该小孩的所有成长记录
  db.run('DELETE FROM growth_records WHERE child_id = ?', [id], (err) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    // 再删除小孩信息
    db.run('DELETE FROM children WHERE id = ? AND user_id = ?', [id, userId], (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Child deleted successfully' });
    });
  });
});

// 成长记录路由
app.get('/api/user/growth-records/:childId', (req, res) => {
  const userId = req.user.id;
  const { childId } = req.params;
  // 验证小孩是否属于该用户
  db.get('SELECT * FROM children WHERE id = ? AND user_id = ?', [childId, userId], (err, child) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    // 获取该小孩的成长记录
    db.all('SELECT * FROM growth_records WHERE child_id = ? ORDER BY record_date DESC', [childId], (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json(rows);
    });
  });
});

app.post('/api/user/growth-records', (req, res) => {
  const userId = req.user.id;
  const { child_id, record_date, height, weight } = req.body;
  // 验证小孩是否属于该用户
  db.get('SELECT * FROM children WHERE id = ? AND user_id = ?', [child_id, userId], (err, child) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }
    // 添加成长记录
    db.run(
      'INSERT INTO growth_records (child_id, record_date, height, weight) VALUES (?, ?, ?, ?)',
      [child_id, record_date, height, weight],
      (err) => {
        if (err) {
          return res.status(500).json({ message: 'Database error' });
        }
        res.json({ message: 'Growth record added successfully' });
      }
    );
  });
});

// 问题反馈路由
app.post('/api/user/feedback', (req, res) => {
  const userId = req.user.id;
  const { title, content } = req.body;
  db.run(
    'INSERT INTO feedback (user_id, title, content) VALUES (?, ?, ?)',
    [userId, title, content],
    (err) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      res.json({ message: 'Feedback submitted successfully' });
    }
  );
});

// 国标数据查询路由
app.get('/api/user/standard-data', (req, res) => {
  db.all('SELECT * FROM standard_data', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    res.json(rows);
  });
});

// 成长状态分析路由
app.post('/api/user/analyze-growth', (req, res) => {
  const { age, gender, height, weight } = req.body;
  
  db.get('SELECT * FROM standard_data WHERE age = ? AND gender = ?', [age, gender], (err, standard) => {
    if (err) {
      return res.status(500).json({ message: 'Database error' });
    }
    
    if (!standard) {
      return res.status(404).json({ message: 'Standard data not found for this age and gender' });
    }
    
    // 分析身高状态
    let heightStatus;
    if (height < standard.height_low) {
      heightStatus = '身高矮小';
    } else if (height < standard.height_normal_low) {
      heightStatus = '身高偏矮';
    } else if (height < standard.height_normal_high) {
      heightStatus = '身高标准';
    } else {
      heightStatus = '身高超高';
    }
    
    // 分析体重状态
    let weightStatus;
    if (weight < standard.weight_low) {
      weightStatus = '体重偏瘦';
    } else if (weight < standard.weight_normal_low) {
      weightStatus = '体重标准';
    } else if (weight < standard.weight_normal_high) {
      weightStatus = '体重标准';
    } else if (weight < standard.weight_high) {
      weightStatus = '体重超重';
    } else {
      weightStatus = '体重肥胖';
    }
    
    res.json({
      heightStatus,
      weightStatus,
      standard
    });
  });
});

// 处理所有其他请求，返回index.html（用于客户端路由）
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

