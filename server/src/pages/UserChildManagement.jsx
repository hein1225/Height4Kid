import React, { useState, useEffect } from 'react'
import axios from 'axios'
import { useNavigate } from 'react-router-dom'

function UserChildManagement() {
  const [children, setChildren] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showAddForm, setShowAddForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [currentChild, setCurrentChild] = useState(null)
  const [formData, setFormData] = useState({
    name: '',
    birth_date: '',
    gender: '男',
    avatar: ''
  })
  const [avatarFile, setAvatarFile] = useState(null)
  const navigate = useNavigate()

  // 获取小孩信息
  useEffect(() => {
    const fetchChildren = async () => {
      try {
        const token = localStorage.getItem('token')
        const response = await axios.get('/api/user/children', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        })
        setChildren(response.data)
      } catch (err) {
        setError('获取小孩信息失败')
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    fetchChildren()
  }, [])

  // 处理表单输入变化
  const handleInputChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  // 处理添加小孩
  const handleAddChild = async (e) => {
    e.preventDefault()
    try {
      const token = localStorage.getItem('token')
      let formDataWithAvatar = { ...formData }

      // 处理头像上传
      if (avatarFile) {
        const reader = new FileReader()
        reader.readAsDataURL(avatarFile)
        await new Promise((resolve) => {
          reader.onloadend = () => {
            formDataWithAvatar.avatar = reader.result
            resolve()
          }
        })
      } else {
        // 自动生成默认头像
        formDataWithAvatar.avatar = formData.gender === '男' 
          ? 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF6B6B%22/%3E%3Cpath d=%22M35 65 Q50 75 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Ccircle cx=%2225%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2275%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Crect x=%2242%22 y=%2215%22 width=%2216%22 height=%2210%22 rx=%225%22 fill=%22%23FF6B6B%22/%3E%3C/svg%3E'
          : 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFB6C1%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF69B4%22/%3E%3Cpath d=%22M35 65 Q50 72 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Cellipse cx=%2225%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cellipse cx=%2275%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cpath d=%22M35 18 Q50 8 65 18%22 stroke=%22%23FF69B4%22 stroke-width=%224%22 fill=%22none%22/%3E%3Ccircle cx=%2250%22 cy=%2212%22 r=%225%22 fill=%22%23FFD700%22/%3E%3C/svg%3E'
      }

      await axios.post('/api/user/children', formDataWithAvatar, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      setShowAddForm(false)
      setFormData({ name: '', birth_date: '', gender: '男', avatar: '' })
      setAvatarFile(null)
      // 重新获取小孩信息
      const response = await axios.get('/api/user/children', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })
      setChildren(response.data)
    } catch (err) {
      setError('添加小孩失败')
      console.error(err)
    }
  }

  // 处理编辑小孩
  const handleEditChild = async (e) => {
    e.preventDefault()
    try {
      const token = localStorage.getItem('token')
      let formDataWithAvatar = { ...formData }

      // 处理头像上传
      if (avatarFile) {
        const reader = new FileReader()
        reader.readAsDataURL(avatarFile)
        await new Promise((resolve) => {
          reader.onloadend = () => {
            formDataWithAvatar.avatar = reader.result
            resolve()
          }
        })
      } else if (!formData.avatar) {
        // 如果没有上传新头像且原头像为空，使用默认头像
        formDataWithAvatar.avatar = formData.gender === '男' 
          ? 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF6B6B%22/%3E%3Cpath d=%22M35 65 Q50 75 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Ccircle cx=%2225%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2275%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Crect x=%2242%22 y=%2215%22 width=%2216%22 height=%2210%22 rx=%225%22 fill=%22%23FF6B6B%22/%3E%3C/svg%3E'
          : 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFB6C1%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF69B4%22/%3E%3Cpath d=%22M35 65 Q50 72 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Cellipse cx=%2225%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cellipse cx=%2275%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cpath d=%22M35 18 Q50 8 65 18%22 stroke=%22%23FF69B4%22 stroke-width=%224%22 fill=%22none%22/%3E%3Ccircle cx=%2250%22 cy=%2212%22 r=%225%22 fill=%22%23FFD700%22/%3E%3C/svg%3E'
      }

      await axios.put(`/api/user/children/${currentChild.id}`, formDataWithAvatar, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      setShowEditForm(false)
      setCurrentChild(null)
      setFormData({ name: '', birth_date: '', gender: '男', avatar: '' })
      setAvatarFile(null)
      // 重新获取小孩信息
      const response = await axios.get('/api/user/children', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })
      setChildren(response.data)
    } catch (err) {
      setError('编辑小孩失败')
      console.error(err)
    }
  }

  // 处理删除小孩
  const handleDeleteChild = async (childId) => {
    if (window.confirm('确定要删除这个小孩吗？删除后将同时删除该小孩的所有成长记录。')) {
      try {
        const token = localStorage.getItem('token')
        await axios.delete(`/api/user/children/${childId}`, {
          headers: {
            Authorization: `Bearer ${token}`
          }
        })
        // 重新获取小孩信息
        const response = await axios.get('/api/user/children', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        })
        setChildren(response.data)
      } catch (err) {
        setError('删除小孩失败')
        console.error(err)
      }
    }
  }

  // 打开编辑表单
  const openEditForm = (child) => {
    setCurrentChild(child)
    setFormData({
      name: child.name,
      birth_date: child.birth_date,
      gender: child.gender,
      avatar: child.avatar || ''
    })
    setAvatarFile(null)
    setShowEditForm(true)
  }

  if (loading) {
    return <div className="flex justify-center items-center h-64">加载中...</div>
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center mb-6">
        <button
          className="text-gray-600 hover:text-gray-800 mr-4"
          onClick={() => navigate('/home')}
        >
          ← 返回
        </button>
        <h1 className="text-2xl font-bold text-blue-600">小孩信息管理</h1>
      </div>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <div className="flex justify-between items-center mb-4">
        <button
          className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
          onClick={() => setShowAddForm(true)}
        >
          添加小孩
        </button>
      </div>

      {/* 小孩列表 */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">头像</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">姓名</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">出生年月</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">性别</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {children.map(child => (
              <tr key={child.id}>
                <td className="px-6 py-4 whitespace-nowrap">
                  <img 
                    src={child.avatar || (child.gender === '男' ? 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF6B6B%22/%3E%3Cpath d=%22M35 65 Q50 75 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Ccircle cx=%2225%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2275%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Crect x=%2242%22 y=%2215%22 width=%2216%22 height=%2210%22 rx=%225%22 fill=%22%23FF6B6B%22/%3E%3C/svg%3E' : 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFB6C1%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF69B4%22/%3E%3Cpath d=%22M35 65 Q50 72 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Cellipse cx=%2225%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cellipse cx=%2275%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cpath d=%22M35 18 Q50 8 65 18%22 stroke=%22%23FF69B4%22 stroke-width=%224%22 fill=%22none%22/%3E%3Ccircle cx=%2250%22 cy=%2212%22 r=%225%22 fill=%22%23FFD700%22/%3E%3C/svg%3E')} 
                    alt="小孩头像" 
                    className="w-10 h-10 rounded-full object-cover"
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">{child.name}</td>
                <td className="px-6 py-4 whitespace-nowrap">{child.birth_date}</td>
                <td className="px-6 py-4 whitespace-nowrap">{child.gender}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    className="text-blue-600 hover:text-blue-800 mr-3"
                    onClick={() => openEditForm(child)}
                  >
                    编辑
                  </button>
                  <button
                    className="text-red-600 hover:text-red-800"
                    onClick={() => handleDeleteChild(child.id)}
                  >
                    删除
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {children.length === 0 && (
        <div className="mt-8 text-center">
          <p className="text-gray-500">还没有添加小孩信息，点击上方的"添加小孩"按钮开始添加。</p>
        </div>
      )}

      {/* 添加小孩弹窗 */}
      {showAddForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-lg mx-4">
            <div className="px-6 py-4 border-b">
              <h2 className="text-xl font-semibold text-gray-700">添加小孩</h2>
            </div>
            <form onSubmit={handleAddChild} className="p-6">
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">姓名</label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">出生年月</label>
                  <input
                    type="date"
                    name="birth_date"
                    value={formData.birth_date}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">性别</label>
                  <select
                    name="gender"
                    value={formData.gender}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="男">男</option>
                    <option value="女">女</option>
                  </select>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">头像</label>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setAvatarFile(e.target.files[0])}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <p className="text-gray-500 text-sm mt-1">可选，如不上传将使用默认头像</p>
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-3">
                <button
                  type="button"
                  className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 transition-colors"
                  onClick={() => setShowAddForm(false)}
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

      {/* 编辑小孩弹窗 */}
      {showEditForm && currentChild && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-lg mx-4">
            <div className="px-6 py-4 border-b">
              <h2 className="text-xl font-semibold text-gray-700">编辑小孩</h2>
            </div>
            <form onSubmit={handleEditChild} className="p-6">
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">姓名</label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">出生年月</label>
                  <input
                    type="date"
                    name="birth_date"
                    value={formData.birth_date}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">性别</label>
                  <select
                    name="gender"
                    value={formData.gender}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="男">男</option>
                    <option value="女">女</option>
                  </select>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">头像</label>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setAvatarFile(e.target.files[0])}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <p className="text-gray-500 text-sm mt-1">可选，如不上传将保持原头像或使用默认头像</p>
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-3">
                <button
                  type="button"
                  className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 transition-colors"
                  onClick={() => {
                    setShowEditForm(false)
                    setCurrentChild(null)
                    setFormData({ name: '', birth_date: '', gender: '男', avatar: '' })
                    setAvatarFile(null)
                  }}
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

export default UserChildManagement
