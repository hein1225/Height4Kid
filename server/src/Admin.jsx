import React from 'react'
import { Link, Outlet, useLocation } from 'react-router-dom'

function Admin() {
  const location = useLocation();
  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/';
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="min-h-screen bg-gray-100 flex">
      {/* 侧边栏导航 */}
      <div className="w-64 bg-white shadow-md h-screen fixed left-0 top-0 overflow-y-auto">
        <div className="p-4 border-b">
          <h1 className="text-xl font-bold text-blue-600">身高成长小助手</h1>
          <p className="text-sm text-gray-500">管理员后台</p>
        </div>
        <nav className="p-4">
          <div className="mb-6">
            <h2 className="text-sm font-semibold text-gray-500 uppercase mb-2">管理功能</h2>
            <ul className="space-y-1">
              <li>
                <Link 
                  to="/admin/account-management" 
                  className={`flex items-center px-3 py-2 rounded-md ${isActive('/admin/account-management') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'}`}
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                  </svg>
                  账户管理
                </Link>
              </li>
              <li>
                <Link 
                  to="/admin/feedback" 
                  className={`flex items-center px-3 py-2 rounded-md ${isActive('/admin/feedback') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'}`}
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                  </svg>
                  问题反馈
                </Link>
              </li>
              <li>
                <Link 
                  to="/admin/standard-data" 
                  className={`flex items-center px-3 py-2 rounded-md ${isActive('/admin/standard-data') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'}`}
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  国标数据管理
                </Link>
              </li>
              <li>
                <Link 
                  to="/admin/login-records" 
                  className={`flex items-center px-3 py-2 rounded-md ${isActive('/admin/login-records') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'}`}
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  登录记录
                </Link>
              </li>
            </ul>
          </div>
          <div className="mb-6">
            <h2 className="text-sm font-semibold text-gray-500 uppercase mb-2">系统设置</h2>
            <ul className="space-y-1">
              <li>
                <a 
                  href="#" 
                  className="flex items-center px-3 py-2 rounded-md text-gray-700 hover:bg-gray-100"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                  </svg>
                  项目标题修改
                </a>
              </li>
              <li>
                <a 
                  href="#" 
                  className="flex items-center px-3 py-2 rounded-md text-gray-700 hover:bg-gray-100"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  运行日志
                </a>
              </li>
              <li>
                <a 
                  href="#" 
                  className="flex items-center px-3 py-2 rounded-md text-gray-700 hover:bg-gray-100"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                  备份与还原
                </a>
              </li>
              <li>
                <a 
                  href="#" 
                  className="flex items-center px-3 py-2 rounded-md text-gray-700 hover:bg-gray-100"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                  重置所有数据
                </a>
              </li>
            </ul>
          </div>
          <div className="mt-8">
            <button 
              className="w-full bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors flex items-center justify-center"
              onClick={handleLogout}
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
              </svg>
              退出登录
            </button>
          </div>
        </nav>
      </div>
      
      {/* 主内容区域 */}
      <div className="flex-1 ml-64 p-8">
        <Outlet />
        
        {!window.location.pathname.includes('/admin/') && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-lg font-semibold text-gray-700 mb-2">账户管理</h2>
              <p className="text-gray-500 mb-4">管理管理员账号及普通账户</p>
              <Link to="/admin/account-management">
                <button className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors">
                  进入
                </button>
              </Link>
            </div>
            
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-lg font-semibold text-gray-700 mb-2">问题反馈</h2>
              <p className="text-gray-500 mb-4">查看和回复用户反馈</p>
              <Link to="/admin/feedback">
                <button className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors">
                  进入
                </button>
              </Link>
            </div>
            
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-lg font-semibold text-gray-700 mb-2">项目标题修改</h2>
              <p className="text-gray-500 mb-4">修改项目标题</p>
              <button className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors">
                进入
              </button>
            </div>
            
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-lg font-semibold text-gray-700 mb-2">国标数据导入</h2>
              <p className="text-gray-500 mb-4">更新最新的小孩身高与体重的国标数据</p>
              <Link to="/admin/standard-data">
                <button className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors">
                  进入
                </button>
              </Link>
            </div>
          </div>
        )}
        
        <div className="bg-white shadow-md mt-8 p-4 rounded-lg">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="text-gray-600 mb-4 md:mb-0">
              <p>GitHub仓库地址: <a href="https://github.com/hein1225/Height4Kid" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://github.com/hein1225/Height4Kid</a></p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Admin