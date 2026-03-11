import React, { useState, useEffect } from 'react'
import axios from 'axios'

function UserGrowthRecord() {
  const [children, setChildren] = useState([])
  const [growthRecords, setGrowthRecords] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showAddForm, setShowAddForm] = useState(false)
  const [selectedChildId, setSelectedChildId] = useState(null)
  const [formData, setFormData] = useState({
    child_id: '',
    record_date: '',
    height: '',
    weight: ''
  })

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
        if (response.data.length > 0) {
          setSelectedChildId(response.data[0].id)
          setFormData(prev => ({
            ...prev,
            child_id: response.data[0].id
          }))
          // 加载第一个小孩的成长记录
          fetchGrowthRecords(response.data[0].id)
        }
      } catch (err) {
        setError('获取小孩信息失败')
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    fetchChildren()
  }, [])

  // 获取成长记录
  const fetchGrowthRecords = async (childId) => {
    try {
      const token = localStorage.getItem('token')
      const response = await axios.get(`/api/user/growth-records/${childId}`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })
      setGrowthRecords(response.data)
    } catch (err) {
      setError('获取成长记录失败')
      console.error(err)
    }
  }

  // 处理小孩选择变化
  const handleChildChange = (e) => {
    const childId = e.target.value
    setSelectedChildId(childId)
    setFormData(prev => ({
      ...prev,
      child_id: childId
    }))
    fetchGrowthRecords(childId)
  }

  // 处理表单输入变化
  const handleInputChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  // 处理添加成长记录
  const handleAddGrowthRecord = async (e) => {
    e.preventDefault()
    try {
      const token = localStorage.getItem('token')
      await axios.post('/api/user/growth-records', formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      setShowAddForm(false)
      setFormData(prev => ({
        ...prev,
        record_date: '',
        height: '',
        weight: ''
      }))
      // 重新获取成长记录
      fetchGrowthRecords(selectedChildId)
    } catch (err) {
      setError('添加成长记录失败')
      console.error(err)
    }
  }

  if (loading) {
    return <div className="flex justify-center items-center h-64">加载中...</div>
  }

  if (children.length === 0) {
    return (
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold text-blue-600 mb-6">成长记录</h1>
        <div className="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded">
          还没有添加小孩信息，请先 <a href="/user/children" className="text-blue-600 hover:underline">添加小孩</a>。
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">成长记录</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <div className="flex justify-between items-center mb-4">
        <div className="w-1/3">
          <label className="block text-gray-700 mb-2">选择小孩</label>
          <select
            value={selectedChildId}
            onChange={handleChildChange}
            className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            {children.map(child => (
              <option key={child.id} value={child.id}>
                {child.name} ({child.gender})
              </option>
            ))}
          </select>
        </div>
        <button
          className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
          onClick={() => setShowAddForm(true)}
        >
          添加成长记录
        </button>
      </div>

      {/* 添加成长记录表单 */}
      {showAddForm && (
        <div className="bg-white p-6 rounded-lg shadow-md mb-6">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">添加成长记录</h2>
          <form onSubmit={handleAddGrowthRecord}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-gray-700 mb-2">记录日期</label>
                <input
                  type="date"
                  name="record_date"
                  value={formData.record_date}
                  onChange={handleInputChange}
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
              <div>
                <label className="block text-gray-700 mb-2">身高 (cm)</label>
                <input
                  type="number"
                  name="height"
                  value={formData.height}
                  onChange={handleInputChange}
                  step="0.1"
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
              <div>
                <label className="block text-gray-700 mb-2">体重 (kg)</label>
                <input
                  type="number"
                  name="weight"
                  value={formData.weight}
                  onChange={handleInputChange}
                  step="0.1"
                  className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
            </div>
            <div className="mt-4 flex justify-end">
              <button
                type="button"
                className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 transition-colors mr-2"
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
      )}

      {/* 成长记录列表 */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">记录日期</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">身高 (cm)</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">体重 (kg)</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {growthRecords.map(record => (
              <tr key={record.id}>
                <td className="px-6 py-4 whitespace-nowrap">{record.record_date}</td>
                <td className="px-6 py-4 whitespace-nowrap">{record.height}</td>
                <td className="px-6 py-4 whitespace-nowrap">{record.weight}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {growthRecords.length === 0 && (
        <div className="mt-8 text-center">
          <p className="text-gray-500">还没有成长记录，点击上方的"添加成长记录"按钮开始添加。</p>
        </div>
      )}
    </div>
  )
}

export default UserGrowthRecord
