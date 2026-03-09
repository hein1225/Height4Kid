import React, { useState, useEffect } from 'react'

function WebsiteInfo() {
  // 从本地存储加载网站信息
  const [websiteInfo, setWebsiteInfo] = useState(() => {
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        return {
          projectTitle: settings.projectTitle || '身高成长小助手',
          homePageInfo: settings.homePageInfo || '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。'
        };
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
    return {
      projectTitle: '身高成长小助手',
      homePageInfo: '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。'
    };
  });
  const [newTitle, setNewTitle] = useState(websiteInfo.projectTitle);
  const [newHomePageInfo, setNewHomePageInfo] = useState(websiteInfo.homePageInfo);
  const [message, setMessage] = useState('');

  useEffect(() => {
    // 从本地存储加载设置
    try {
      const savedSettings = localStorage.getItem('adminSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        setWebsiteInfo({
          projectTitle: settings.projectTitle || '身高成长小助手',
          homePageInfo: settings.homePageInfo || '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。'
        });
        setNewTitle(settings.projectTitle || '身高成长小助手');
        setNewHomePageInfo(settings.homePageInfo || '这是一个帮助家长记录和分析孩子身高成长的工具，通过与国家标准数据对比，评估孩子的生长发育状况。');
      }
    } catch (error) {
      console.error('Error parsing adminSettings:', error);
    }
  }, []);

  const handleTitleChange = (e) => {
    setNewTitle(e.target.value);
  };

  const handleHomePageInfoChange = (e) => {
    setNewHomePageInfo(e.target.value);
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
      settings.homePageInfo = newHomePageInfo;
      localStorage.setItem('adminSettings', JSON.stringify(settings));
      setWebsiteInfo({
        projectTitle: newTitle,
        homePageInfo: newHomePageInfo
      });
      setMessage('网站信息修改成功！');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    } catch (error) {
      console.error('Error saving website info:', error);
      setMessage('修改失败，请重试');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">网站信息修改</h1>
      
      {message && (
        <div className={`mb-4 p-3 rounded-md ${message.includes('成功') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">网站标题</h2>
          <div className="mb-4">
            <label className="block text-gray-700 mb-2">当前标题</label>
            <input
              type="text"
              value={websiteInfo.projectTitle}
              disabled
              className="w-full px-4 py-2 border rounded-md bg-gray-100"
            />
          </div>
          
          <div className="mb-4">
            <label className="block text-gray-700 mb-2">新标题</label>
            <input
              type="text"
              value={newTitle}
              onChange={handleTitleChange}
              className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="请输入新的网站标题"
              required
            />
          </div>
        </div>
        
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">首页显示信息</h2>
          <div className="mb-4">
            <label className="block text-gray-700 mb-2">当前首页信息</label>
            <textarea
              value={websiteInfo.homePageInfo}
              disabled
              className="w-full px-4 py-2 border rounded-md bg-gray-100"
              rows={4}
            />
          </div>
          
          <div className="mb-4">
            <label className="block text-gray-700 mb-2">新首页信息</label>
            <textarea
              value={newHomePageInfo}
              onChange={handleHomePageInfoChange}
              className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="请输入新的首页显示信息"
              rows={4}
              required
            />
          </div>
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
          <li>修改网站标题后，将在整个应用中生效，包括登录页面、首页和管理员后台</li>
          <li>修改首页显示信息后，将在首页的项目介绍部分显示</li>
          <li>首页显示信息会显示在项目信息框的上面</li>
          <li>设置会保存在本地存储中，刷新页面后仍然生效</li>
        </ul>
      </div>
    </div>
  )
}

export default WebsiteInfo