import React, { useState, useEffect } from 'react'

function AccountManagement() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [currentUser, setCurrentUser] = useState({ username: '', password: '', role: 'user' });
  const [confirmPassword, setConfirmPassword] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/admin/users', {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsers(data);
      } else {
        setError('Failed to fetch users');
      }
    } catch (err) {
      setError('Network error');
    } finally {
      setLoading(false);
    }
  };

  const handleAddUser = async (e) => {
    e.preventDefault();
    // 验证密码是否一致
    if (currentUser.password !== confirmPassword) {
      setError('密码与确认密码不一致');
      return;
    }
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/admin/users', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(currentUser),
      });

      if (response.ok) {
        setCurrentUser({ username: '', password: '', role: 'user' });
        setConfirmPassword('');
        setShowAddModal(false);
        setError('');
        fetchUsers();
      } else {
        setError('添加用户失败');
      }
    } catch (err) {
      setError('网络错误');
    }
  };

  const handleUpdateUser = async (e) => {
    e.preventDefault();
    // 如果修改了密码，验证密码是否一致
    if (currentUser.password && currentUser.password !== confirmPassword) {
      setError('密码与确认密码不一致');
      return;
    }
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/admin/users/${currentUser.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(currentUser),
      });

      if (response.ok) {
        setCurrentUser({ username: '', password: '', role: 'user' });
        setConfirmPassword('');
        setShowEditModal(false);
        setError('');
        fetchUsers();
      } else {
        setError('更新用户失败');
      }
    } catch (err) {
      setError('网络错误');
    }
  };

  const handleDeleteUser = async (id) => {
    if (window.confirm('确定要删除此用户吗？')) {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`/api/admin/users/${id}`, {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (response.ok) {
          fetchUsers();
        } else {
          setError('删除用户失败');
        }
      } catch (err) {
        setError('网络错误');
      }
    }
  };

  const openAddModal = () => {
    setCurrentUser({ username: '', password: '', role: 'user' });
    setConfirmPassword('');
    setError('');
    setShowAddModal(true);
  };

  const openEditModal = (user) => {
    setCurrentUser({ ...user, password: '' });
    setConfirmPassword('');
    setError('');
    setShowEditModal(true);
  };

  if (loading) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">账户管理</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}

      <div className="bg-white p-6 rounded-lg shadow-md mb-8">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-700">用户列表</h2>
          <button 
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
            onClick={openAddModal}
          >
            添加用户
          </button>
        </div>
        <div className="overflow-x-auto mt-4">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-4 py-2 text-left">ID</th>
                <th className="px-4 py-2 text-left">用户名</th>
                <th className="px-4 py-2 text-left">角色</th>
                <th className="px-4 py-2 text-left">操作</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b">
                  <td className="px-4 py-2">{user.id}</td>
                  <td className="px-4 py-2">{user.username}</td>
                  <td className="px-4 py-2">{user.role === 'admin' ? '管理员' : '普通用户'}</td>
                  <td className="px-4 py-2">
                    <button 
                      className="bg-blue-500 text-white px-2 py-1 rounded-md hover:bg-blue-600 transition-colors mr-2"
                      onClick={() => openEditModal(user)}
                    >
                      编辑
                    </button>
                    <button 
                      className="bg-red-500 text-white px-2 py-1 rounded-md hover:bg-red-600 transition-colors"
                      onClick={() => handleDeleteUser(user.id)}
                    >
                      删除
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 添加用户弹窗 */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-full max-w-md">
            <h2 className="text-xl font-semibold text-gray-700 mb-4">添加新用户</h2>
            {error && <div className="text-red-500 mb-4">{error}</div>}
            <form onSubmit={handleAddUser}>
              <div className="mb-4">
                <label className="block text-gray-700 mb-2">用户名</label>
                <input 
                  type="text" 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.username}
                  onChange={(e) => setCurrentUser({ ...currentUser, username: e.target.value })}
                  required
                />
              </div>
              <div className="mb-4">
                <label className="block text-gray-700 mb-2">密码</label>
                <input 
                  type="password" 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.password}
                  onChange={(e) => setCurrentUser({ ...currentUser, password: e.target.value })}
                  required
                />
              </div>
              <div className="mb-4">
                <label className="block text-gray-700 mb-2">确认密码</label>
                <input 
                  type="password" 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                />
              </div>
              <div className="mb-6">
                <label className="block text-gray-700 mb-2">角色</label>
                <select 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.role}
                  onChange={(e) => setCurrentUser({ ...currentUser, role: e.target.value })}
                >
                  <option value="user">普通用户</option>
                  <option value="admin">管理员</option>
                </select>
              </div>
              <div className="flex justify-end space-x-2">
                <button 
                  type="button" 
                  className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600 transition-colors"
                  onClick={() => setShowAddModal(false)}
                >
                  取消
                </button>
                <button 
                  type="submit" 
                  className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
                >
                  保存
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 编辑用户弹窗 */}
      {showEditModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-full max-w-md">
            <h2 className="text-xl font-semibold text-gray-700 mb-4">编辑用户</h2>
            {error && <div className="text-red-500 mb-4">{error}</div>}
            <form onSubmit={handleUpdateUser}>
              <div className="mb-4">
                <label className="block text-gray-700 mb-2">用户名</label>
                <input 
                  type="text" 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.username}
                  onChange={(e) => setCurrentUser({ ...currentUser, username: e.target.value })}
                  required
                />
              </div>
              <div className="mb-4">
                <label className="block text-gray-700 mb-2">密码（留空则不修改）</label>
                <input 
                  type="password" 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.password}
                  onChange={(e) => setCurrentUser({ ...currentUser, password: e.target.value })}
                />
              </div>
              {currentUser.password && (
                <div className="mb-4">
                  <label className="block text-gray-700 mb-2">确认密码</label>
                  <input 
                    type="password" 
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                </div>
              )}
              <div className="mb-6">
                <label className="block text-gray-700 mb-2">角色</label>
                <select 
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={currentUser.role}
                  onChange={(e) => setCurrentUser({ ...currentUser, role: e.target.value })}
                >
                  <option value="user">普通用户</option>
                  <option value="admin">管理员</option>
                </select>
              </div>
              <div className="flex justify-end space-x-2">
                <button 
                  type="button" 
                  className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600 transition-colors"
                  onClick={() => setShowEditModal(false)}
                >
                  取消
                </button>
                <button 
                  type="submit" 
                  className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
                >
                  保存
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

export default AccountManagement