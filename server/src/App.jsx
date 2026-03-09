import React, { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Admin from './Admin'
import AccountManagement from './pages/AccountManagement'
import Feedback from './pages/Feedback'
import StandardData from './pages/StandardData'
import LoginRecords from './pages/LoginRecords'
import Settings from './pages/Settings'

function Login() {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('http://localhost:8080/api/login', {
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
        // 跳转到管理员页面
        window.location.href = '/admin';
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
        <h1 className="text-4xl font-bold text-blue-600 mb-4">身高成长小助手</h1>
        <p className="text-gray-600 mb-8">管理员登录</p>
        <div className="bg-white p-8 rounded-lg shadow-md w-96">
          {error && <div className="text-red-500 mb-4">{error}</div>}
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-gray-700 mb-2">用户名</label>
              <input 
                type="text" 
                className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="admin"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
            </div>
            <div className="mb-6">
              <label className="block text-gray-700 mb-2">密码</label>
              <input 
                type="password" 
                className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="admin123"
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

function HomePage() {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="text-center p-8 max-w-2xl">
        <h1 className="text-4xl font-bold text-blue-600 mb-4">身高成长小助手</h1>
        <p className="text-gray-600 mb-8 text-lg">
          这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。
        </p>
        
        <div className="bg-white p-6 rounded-lg shadow-md mb-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">项目信息</h2>
          <p className="text-gray-600 mb-4">
            GitHub仓库地址: <a href="https://github.com/hein1225/Height4Kid" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://github.com/hein1225/Height4Kid</a>
          </p>
          <p className="text-gray-600 mb-4">
            安卓客户端下载: <a href="https://github.com/hein1225/Height4Kid/releases" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://github.com/hein1225/Height4Kid/releases</a>
          </p>
        </div>
        
        <div className="text-gray-500 text-sm">
          <p>© 2026 身高成长小助手</p>
        </div>
      </div>
    </div>
  )
}

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/admin" element={<Admin />}>
          <Route path="login" element={<Login />} />
          <Route path="account-management" element={<AccountManagement />} />
          <Route path="feedback" element={<Feedback />} />
          <Route path="standard-data" element={<StandardData />} />
          <Route path="login-records" element={<LoginRecords />} />
          <Route path="settings" element={<Settings />} />
        </Route>
        <Route path="*" element={<HomePage />} />
      </Routes>
    </Router>
  )
}

export default App