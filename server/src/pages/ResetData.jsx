import React, { useState } from 'react'

function ResetData() {
  const [message, setMessage] = useState('');

  // 处理重置所有数据
  const handleResetData = () => {
    // 第一次警告
    if (!window.confirm('警告：此操作将重置所有网站数据，包括用户、反馈、标准数据和登录记录！\n\n此操作不可撤销，是否继续？')) {
      return;
    }
    
    // 第二次警告
    if (!window.confirm('再次警告：所有数据将被永久删除！\n\n请确保您已经备份了重要数据，是否继续？')) {
      return;
    }
    
    // 第三次确认，要求输入特定文本
    const confirmation = prompt('为了确认您确实要重置所有数据，请输入 "RESET"（大写）：');
    if (confirmation !== 'RESET') {
      setMessage('确认信息不正确，操作已取消。');
      setTimeout(() => {
        setMessage('');
      }, 3000);
      return;
    }
    
    // 执行重置操作
    try {
      // 模拟重置数据
      // 在实际应用中，这里应该调用后端API来重置数据
      
      // 清除本地存储中的设置
      localStorage.removeItem('adminSettings');
      
      // 重新加载页面
      setMessage('数据重置成功！页面将重新加载。');
      setTimeout(() => {
        window.location.reload();
      }, 2000);
    } catch (error) {
      console.error('Error resetting data:', error);
      setMessage('重置数据失败，请重试。');
      setTimeout(() => {
        setMessage('');
      }, 3000);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">重置所有数据</h1>
      
      {message && (
        <div className={`mb-4 p-3 rounded-md ${message.includes('成功') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message}
        </div>
      )}
      
      <div className="bg-red-100 border-l-4 border-red-500 p-4 mb-6">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700">
              警告：此操作将永久删除所有网站数据，包括用户、反馈、标准数据和登录记录。
              此操作不可撤销，请谨慎执行。
            </p>
          </div>
        </div>
      </div>
      
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-gray-700 mb-2">操作步骤</h2>
        <ol className="list-decimal pl-5 text-gray-600 space-y-2">
          <li>确认您已经备份了所有重要数据</li>
          <li>点击下方的"重置所有数据"按钮</li>
          <li>按照提示完成多次确认</li>
          <li>等待操作完成并自动重新加载页面</li>
        </ol>
      </div>
      
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-gray-700 mb-2">重置内容</h2>
        <ul className="list-disc pl-5 text-gray-600 space-y-1">
          <li>所有用户账户数据</li>
          <li>所有问题反馈数据</li>
          <li>所有标准身高数据</li>
          <li>所有登录记录</li>
          <li>所有系统设置</li>
        </ul>
      </div>
      
      <button
        className="bg-red-600 text-white px-6 py-3 rounded-md hover:bg-red-700 transition-colors"
        onClick={handleResetData}
      >
        重置所有数据
      </button>
    </div>
  )
}

export default ResetData