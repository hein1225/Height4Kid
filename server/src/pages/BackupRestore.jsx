import React, { useState } from 'react'

function BackupRestore() {
  const [message, setMessage] = useState('');

  // 处理备份数据
  const handleBackup = () => {
    try {
      // 模拟备份数据
      const backupData = {
        users: [],
        feedback: [],
        standardData: [],
        loginRecords: [],
        settings: JSON.parse(localStorage.getItem('adminSettings') || '{}'),
        timestamp: new Date().toISOString()
      };
      
      // 创建备份文件并下载
      const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `height4kid-backup-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      
      setMessage('备份成功！');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    } catch (error) {
      console.error('Error backing up data:', error);
      setMessage('备份失败，请重试');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    }
  };

  // 处理还原数据
  const handleRestore = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const backupData = JSON.parse(event.target.result);
        // 模拟还原数据
        if (backupData.settings) {
          localStorage.setItem('adminSettings', JSON.stringify(backupData.settings));
        }
        setMessage('还原成功！');
        setTimeout(() => {
          setMessage('');
          // 刷新页面以应用新设置
          window.location.reload();
        }, 2000);
      } catch (error) {
        console.error('Error restoring data:', error);
        setMessage('还原失败，请检查备份文件格式');
        setTimeout(() => {
          setMessage('');
        }, 2000);
      }
    };
    reader.readAsText(file);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">备份与还原</h1>
      
      {message && (
        <div className={`mb-4 p-3 rounded-md ${message.includes('成功') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message}
        </div>
      )}
      
      <div className="space-y-8">
        <div>
          <h2 className="text-xl font-semibold text-gray-700 mb-4">备份数据</h2>
          <p className="text-gray-600 mb-4">点击下方按钮下载备份文件，包含网站所有数据</p>
          <button
            className="bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors"
            onClick={handleBackup}
          >
            备份数据
          </button>
        </div>
        
        <div className="border-t pt-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">还原数据</h2>
          <p className="text-gray-600 mb-4">选择备份文件进行还原，还原后将覆盖当前数据</p>
          <input
            type="file"
            accept=".json"
            className="w-full border rounded-md p-3"
            onChange={handleRestore}
          />
        </div>
      </div>
      
      <div className="mt-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">操作说明</h2>
        <ul className="list-disc pl-5 text-gray-600">
          <li>备份文件包含网站所有数据，包括用户、反馈、标准数据和登录记录</li>
          <li>还原数据会覆盖当前所有数据，请谨慎操作</li>
          <li>建议在进行重要操作前先备份数据</li>
          <li>备份文件为JSON格式，可以用文本编辑器查看</li>
        </ul>
      </div>
    </div>
  )
}

export default BackupRestore