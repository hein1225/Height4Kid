import React, { useState, useEffect } from 'react'

function Settings() {
  const [settings, setSettings] = useState({
    adminPath: '/admin'
  });
  const [message, setMessage] = useState('');

  useEffect(() => {
    // 从本地存储加载设置
    const savedSettings = localStorage.getItem('adminSettings');
    if (savedSettings) {
      setSettings(JSON.parse(savedSettings));
    }
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setSettings(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // 保存设置到本地存储
    localStorage.setItem('adminSettings', JSON.stringify(settings));
    setMessage('设置保存成功！');
    
    // 3秒后清除消息
    setTimeout(() => {
      setMessage('');
    }, 3000);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">系统设置</h1>
      
      {message && (
        <div className="bg-green-100 text-green-700 p-4 rounded-md mb-4">
          {message}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 mb-2">管理员入口路径</label>
          <input
            type="text"
            name="adminPath"
            value={settings.adminPath}
            onChange={handleChange}
            className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="例如: /admin"
            required
          />
          <p className="text-sm text-gray-500 mt-2">
            请输入管理员后台的访问路径，默认为 /admin
          </p>
        </div>

        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
        >
          保存设置
        </button>
      </form>

      <div className="mt-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">设置说明</h2>
        <ul className="list-disc pl-5 text-gray-600">
          <li>管理员入口路径用于访问管理员登录页面</li>
          <li>默认路径为 /admin，您可以根据需要修改</li>
          <li>修改后请使用新的路径访问管理员后台</li>
          <li>设置会保存在本地存储中，刷新页面后仍然生效</li>
        </ul>
      </div>
    </div>
  )
}

export default Settings