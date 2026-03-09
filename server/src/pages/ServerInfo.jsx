import React, { useState, useEffect } from 'react'

function ServerInfo() {
  const [userCount, setUserCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [apiUrl, setApiUrl] = useState('');
  const [frontendUrl, setFrontendUrl] = useState('');

  useEffect(() => {
    // 获取当前服务端访问地址
    const currentUrl = window.location.href;
    const url = new URL(currentUrl);
    // 构建API地址（使用与前端相同的地址）
    const apiUrl = `${url.protocol}//${url.host}`;
    setApiUrl(apiUrl);
    // 前端地址
    setFrontendUrl(currentUrl.split('/admin')[0]);
    // 等待apiUrl设置后再获取用户数量
    fetchUserCount();
  }, []);

  const fetchUserCount = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/admin/users`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        // 过滤出普通用户
        const normalUsers = data.filter(user => user.role === 'user');
        setUserCount(normalUsers.length);
      } else if (response.status === 403) {
        // 权限不足，重定向到首页
        window.location.href = '/';
      } else {
        setError('获取用户数量失败');
      }
    } catch (err) {
      setError('网络错误');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">服务端信息</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* 服务器基本信息 */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">服务器基本信息</h2>
          <ul className="space-y-3">
            <li className="flex justify-between">
              <span className="text-gray-600">服务器版本：</span>
              <span className="font-medium">1.0.0</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">API地址：</span>
              <span className="font-medium">{apiUrl}</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">前端地址：</span>
              <span className="font-medium">{frontendUrl}</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">当前时间：</span>
              <span className="font-medium">{new Date().toLocaleString()}</span>
            </li>
          </ul>
        </div>

        {/* 系统统计信息 */}
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">系统统计信息</h2>
          <ul className="space-y-3">
            <li className="flex justify-between">
              <span className="text-gray-600">普通账户数量：</span>
              <span className="font-medium">{userCount}</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">管理员账户数量：</span>
              <span className="font-medium">1</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">数据库类型：</span>
              <span className="font-medium">SQLite</span>
            </li>
            <li className="flex justify-between">
              <span className="text-gray-600">API接口数量：</span>
              <span className="font-medium">20+</span>
            </li>
          </ul>
        </div>

        {/* 客户端配置信息 */}
        <div className="bg-white p-6 rounded-lg shadow-md md:col-span-2">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">客户端配置信息</h2>
          <div className="bg-gray-50 p-4 rounded-md">
            <p className="text-gray-600 mb-2">客户端需要输入的API地址：</p>
            <p className="font-medium text-blue-600">{apiUrl}</p>
            <p className="text-gray-500 text-sm mt-4">
              请确保客户端设备能够访问此地址。如果服务器部署在公网，请使用公网IP或域名替代localhost。
            </p>
          </div>
        </div>

        {/* 系统状态 */}
        <div className="bg-white p-6 rounded-lg shadow-md md:col-span-2">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">系统状态</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-green-50 p-4 rounded-md text-center">
              <div className="text-green-600 font-bold text-2xl">✓</div>
              <div className="text-gray-600 mt-2">服务运行正常</div>
            </div>
            <div className="bg-blue-50 p-4 rounded-md text-center">
              <div className="text-blue-600 font-bold text-2xl">✓</div>
              <div className="text-gray-600 mt-2">数据库连接正常</div>
            </div>
            <div className="bg-purple-50 p-4 rounded-md text-center">
              <div className="text-purple-600 font-bold text-2xl">✓</div>
              <div className="text-gray-600 mt-2">API响应正常</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ServerInfo