import React, { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Admin from './Admin'
import AccountManagement from './pages/AccountManagement'
import Feedback from './pages/Feedback'
import StandardData from './pages/StandardData'
import LoginRecords from './pages/LoginRecords'
import Settings from './pages/Settings'
import ServerInfo from './pages/ServerInfo'
import WebsiteInfo from './pages/WebsiteInfo'
import RunningLogs from './pages/RunningLogs'
import BackupRestore from './pages/BackupRestore'
import ResetData from './pages/ResetData'
import UserHomePage from './pages/UserHomePage'
import UserChildManagement from './pages/UserChildManagement'
import UserGrowthRecord from './pages/UserGrowthRecord'
import UserGrowthAnalysis from './pages/UserGrowthAnalysis'
import UserFeedback from './pages/UserFeedback'
import UserBackup from './pages/UserBackup'

function Login() {
  // 从本地存储加载项目标题
  const [projectTitle, setProjectTitle] = useState(() => {
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        return settings.projectTitle || '身高成长小助手';
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
    return '身高成长小助手';
  });
  
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('/api/admin/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();

      if (response.ok) {
        // 保存 token 到本地存储
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        // 管理员跳转到管理员页面
        // 从本地存储获取管理员路径设置
        try {
          const savedSettings = localStorage.getItem('adminSettings');
          if (savedSettings) {
            const settings = JSON.parse(savedSettings);
            const adminPath = settings.adminPath || '/admin';
            window.location.href = adminPath;
          } else {
            window.location.href = '/admin';
          }
        } catch (error) {
          console.error('Error parsing adminSettings:', error);
          window.location.href = '/admin';
        }
      } else {
        setError(data.message || '登录失败');
      }
    } catch (err) {
      setError('网络错误，请稍后重试');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-blue-600 mb-4">{projectTitle}</h1>
        <p className="text-gray-600 mb-8">管理员登录</p>
        <div className="bg-white p-8 rounded-lg shadow-md w-96">
          {error && <div className="text-red-500 mb-4">{error}</div>}
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-gray-700 mb-2">用户名</label>
              <input 
                type="text" 
                className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="请输入用户名"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
            </div>
            <div className="mb-6">
              <label className="block text-gray-700 mb-2">密码</label>
              <input 
                type="password" 
                className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="请输入密码"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <button 
              type="submit" 
              className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 transition-colors"
              disabled={loading}
            >
              {loading ? '登录中...' : '登录'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}

function UserLogin() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();

      if (response.ok) {
        // 保存 token 到本地存储
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        // 普通用户登录后跳转到用户页面
        window.location.href = '/user';
      } else {
        setError(data.message || '登录失败');
      }
    } catch (err) {
      setError('网络错误，请稍后重试');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-white p-8 rounded-lg shadow-md w-96 mx-auto">
      <h2 className="text-xl font-semibold text-gray-700 mb-4">用户登录</h2>
      {error && <div className="text-red-500 mb-4">{error}</div>}
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 mb-2">用户名</label>
          <input 
            type="text" 
            className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="请输入用户名"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
        </div>
        <div className="mb-6">
          <label className="block text-gray-700 mb-2">密码</label>
          <input 
            type="password" 
            className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="请输入密码"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button 
          type="submit" 
          className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 transition-colors"
          disabled={loading}
        >
          {loading ? '登录中...' : '登录'}
        </button>
      </form>
    </div>
  );
}



function HomePage() {
  // 从本地存储加载项目标题和首页信息
  const [projectTitle, setProjectTitle] = useState(() => {
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        return settings.projectTitle || '身高成长小助手';
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
    return '身高成长小助手';
  });
  
  const [homePageInfo, setHomePageInfo] = useState(() => {
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        return settings.homePageInfo || '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。';
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
    return '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。';
  });

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="text-center p-8 max-w-2xl">
        <h1 className="text-4xl font-bold text-blue-600 mb-4">{projectTitle}</h1>
        <p className="text-gray-600 mb-8 text-lg">
          {homePageInfo}
        </p>
        
        <div className="mb-8">
          <UserLogin />
        </div>
        
        <div className="mt-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">项目信息</h2>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <p className="text-gray-600 mb-4">
              GitHub仓库地址: <a href="https://github.com/hein1225/Height4Kid" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://github.com/hein1225/Height4Kid</a>
            </p>
            <p className="text-gray-600 mb-4">
              安卓客户端下载: <a href="https://github.com/hein1225/Height4Kid/releases" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://github.com/hein1225/Height4Kid/releases</a>
            </p>
            <p className="text-gray-600">
              管理员入口: <a href="/admin/login" className="text-blue-600 hover:underline">点击进入</a>
            </p>
          </div>
        </div>
        
        <div className="text-gray-500 text-sm mt-8">
          <p>© 2026 身高成长小助手</p>
        </div>
      </div>
    </div>
  )
}

function App() {
  // 从本地存储加载管理员路径设置
  const [adminPath, setAdminPath] = useState(() => {
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        return settings.adminPath || '/admin';
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
    return '/admin';
  });

  // 监听设置变化
  useEffect(() => {
    const handleStorageChange = (e) => {
      if (e.key === 'adminSettings') {
        try {
          if (e.newValue) {
            const settings = JSON.parse(e.newValue);
            setAdminPath(settings.adminPath || '/admin');
          } else {
            setAdminPath('/admin');
          }
        } catch (error) {
          console.error('Error parsing adminSettings:', error);
          setAdminPath('/admin');
        }
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, []);

  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/user" element={<UserHomePage />} />
        <Route path="/user/children" element={<UserChildManagement />} />
        <Route path="/user/growth-records" element={<UserGrowthRecord />} />
        <Route path="/user/growth-analysis" element={<UserGrowthAnalysis />} />
        <Route path="/user/feedback" element={<UserFeedback />} />
        <Route path="/user/backup" element={<UserBackup />} />
        <Route path={adminPath} element={<Admin />}>
          <Route index element={<ServerInfo />} />
          <Route path="login" element={<Login />} />
          <Route path="account-management" element={<AccountManagement />} />
          <Route path="feedback" element={<Feedback />} />
          <Route path="standard-data" element={<StandardData />} />
          <Route path="login-records" element={<LoginRecords />} />
          <Route path="server-info" element={<ServerInfo />} />
          <Route path="settings" element={<Settings />} />
          <Route path="website-info" element={<WebsiteInfo />} />
          <Route path="running-logs" element={<RunningLogs />} />
          <Route path="backup-restore" element={<BackupRestore />} />
          <Route path="reset-data" element={<ResetData />} />
        </Route>
        {/* 始终添加默认的/admin路径作为备选 */}
        <Route path="/admin" element={<Admin />}>
          <Route index element={<ServerInfo />} />
          <Route path="login" element={<Login />} />
          <Route path="account-management" element={<AccountManagement />} />
          <Route path="feedback" element={<Feedback />} />
          <Route path="standard-data" element={<StandardData />} />
          <Route path="login-records" element={<LoginRecords />} />
          <Route path="server-info" element={<ServerInfo />} />
          <Route path="settings" element={<Settings />} />
          <Route path="website-info" element={<WebsiteInfo />} />
          <Route path="running-logs" element={<RunningLogs />} />
          <Route path="backup-restore" element={<BackupRestore />} />
          <Route path="reset-data" element={<ResetData />} />
        </Route>
        <Route path="*" element={<HomePage />} />
      </Routes>
    </Router>
  )
}

export default App