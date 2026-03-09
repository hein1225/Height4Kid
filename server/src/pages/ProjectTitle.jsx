import React, { useState, useEffect } from 'react'

function ProjectTitle() {
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
  const [newTitle, setNewTitle] = useState(projectTitle);
  const [message, setMessage] = useState('');

  useEffect(() => {
    // 从本地存储加载设置
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        setProjectTitle(settings.projectTitle || '身高成长小助手');
        setNewTitle(settings.projectTitle || '身高成长小助手');
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
  }, []);

  const handleChange = (e) => {
    setNewTitle(e.target.value);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      let settings = {};
      if (savedSettings) {
        settings = JSON.parse(savedSettings);
      }
      settings.projectTitle = newTitle;
      localStorage.setItem('adminSettings', JSON.stringify(settings));
      setProjectTitle(newTitle);
      setMessage('项目标题修改成功！');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    } catch (error) {
      console.error('Error saving project title:', error);
      setMessage('修改失败，请重试');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">项目标题修改</h1>
      
      {message && (
        <div className={`mb-4 p-3 rounded-md ${message.includes('成功') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 mb-2">当前标题</label>
          <input
            type="text"
            value={projectTitle}
            disabled
            className="w-full px-4 py-2 border rounded-md bg-gray-100"
          />
        </div>
        
        <div className="mb-4">
          <label className="block text-gray-700 mb-2">新标题</label>
          <input
            type="text"
            value={newTitle}
            onChange={handleChange}
            className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="请输入新的项目标题"
            required
          />
        </div>
        
        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
        >
          保存修改
        </button>
      </form>
      
      <div className="mt-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">修改说明</h2>
        <ul className="list-disc pl-5 text-gray-600">
          <li>修改项目标题后，将在整个应用中生效</li>
          <li>包括登录页面、首页和管理员后台的标题</li>
          <li>设置会保存在本地存储中，刷新页面后仍然生效</li>
        </ul>
      </div>
    </div>
  )
}

export default ProjectTitle