import React, { useState, useEffect } from 'react'

function RunningLogs() {
  const [logs, setLogs] = useState([]);
  const [message, setMessage] = useState('');

  useEffect(() => {
    // 模拟获取错误日志
    try {
      const errorLogs = [
        {
          time: new Date().toLocaleString(),
          level: 'ERROR',
          message: '测试错误日志 1',
          stack: 'Error: 测试错误 1\n    at Function.testError1 (app.js:10:15)\n    at main.js:5:20\n    at async Promise.all (index 0)'
        },
        {
          time: new Date().toLocaleString(),
          level: 'ERROR',
          message: '测试错误日志 2',
          stack: 'Error: 测试错误 2\n    at Function.testError2 (utils.js:25:10)\n    at app.js:20:12'
        },
        {
          time: new Date().toLocaleString(),
          level: 'ERROR',
          message: '测试错误日志 3',
          stack: 'Error: 测试错误 3\n    at Component.render (component.js:45:15)\n    at ReactDOM.render (react-dom.js:100:20)'
        }
      ];
      setLogs(errorLogs);
    } catch (error) {
      console.error('Error loading logs:', error);
      setMessage('加载日志失败');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    }
  }, []);

  // 导出日志功能
  const exportLogs = () => {
    try {
      const logData = JSON.stringify(logs, null, 2);
      const blob = new Blob([logData], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `height4kid-logs-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      
      setMessage('日志导出成功！');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    } catch (error) {
      console.error('Error exporting logs:', error);
      setMessage('导出日志失败');
      setTimeout(() => {
        setMessage('');
      }, 2000);
    }
  };

  // 清除日志功能
  const clearLogs = () => {
    if (window.confirm('确定要清除所有运行日志吗？此操作不可撤销。')) {
      try {
        // 模拟清除日志
        // 在实际应用中，这里应该调用后端API来清除日志
        setLogs([]);
        setMessage('日志清除成功！');
        setTimeout(() => {
          setMessage('');
        }, 2000);
      } catch (error) {
        console.error('Error clearing logs:', error);
        setMessage('清除日志失败');
        setTimeout(() => {
          setMessage('');
        }, 2000);
      }
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-blue-600">运行日志</h1>
        <div className="space-x-2">
          <button
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
            onClick={exportLogs}
          >
            导出日志
          </button>
          <button
            className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition-colors"
            onClick={clearLogs}
          >
            清除日志
          </button>
        </div>
      </div>
      
      {message && (
        <div className={`mb-4 p-3 rounded-md ${message.includes('成功') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
          {message}
        </div>
      )}
      
      <div className="space-y-4">
        {logs.length > 0 ? (
          logs.map((log, index) => (
            <div key={index} className="bg-gray-100 p-4 rounded-md">
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-semibold text-gray-700">{log.time}</span>
                <span className="text-sm font-semibold text-red-600">{log.level}</span>
              </div>
              <p className="text-gray-600 mb-2">{log.message}</p>
              {log.stack && (
                <div className="mt-2">
                  <h4 className="text-sm font-semibold text-gray-700 mb-1">错误堆栈：</h4>
                  <pre className="bg-gray-200 p-3 rounded-md text-sm text-gray-800 overflow-x-auto">
                    {log.stack}
                  </pre>
                </div>
              )}
            </div>
          ))
        ) : (
          <p className="text-gray-500 text-center py-4">暂无错误日志</p>
        )}
      </div>
      
      <div className="mt-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">日志说明</h2>
        <ul className="list-disc pl-5 text-gray-600">
          <li>本页面显示完整的错误日志，包括错误堆栈</li>
          <li>日志按时间倒序排列，最新的日志在最上方</li>
          <li>点击"导出日志"按钮可下载完整的运行日志</li>
          <li>刷新页面可更新日志列表</li>
        </ul>
      </div>
    </div>
  )
}

export default RunningLogs