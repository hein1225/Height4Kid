import React, { useState, useEffect } from 'react'
import axios from 'axios'

function UserGrowthAnalysis() {
  const [children, setChildren] = useState([])
  const [growthRecords, setGrowthRecords] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [selectedChildId, setSelectedChildId] = useState(null)
  const [analysisResults, setAnalysisResults] = useState([])

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
      // 分析成长记录
      analyzeGrowthRecords(childId, response.data)
    } catch (err) {
      setError('获取成长记录失败')
      console.error(err)
    }
  }

  // 分析成长记录
  const analyzeGrowthRecords = async (childId, records) => {
    try {
      const token = localStorage.getItem('token')
      const child = children.find(c => c.id === childId)
      if (!child) return

      const results = []
      for (const record of records) {
        // 计算年龄（以岁为单位）
        const birthDate = new Date(child.birth_date)
        const recordDate = new Date(record.record_date)
        const age = Math.floor((recordDate - birthDate) / (365.25 * 24 * 60 * 60 * 1000))
        
        // 只分析0-18岁的记录
        if (age >= 0 && age <= 18) {
          const ageStr = `${age}岁`
          const response = await axios.post('/api/user/analyze-growth', {
            age: ageStr,
            gender: child.gender,
            height: record.height,
            weight: record.weight
          }, {
            headers: {
              Authorization: `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          })
          
          results.push({
            ...record,
            age: ageStr,
            heightStatus: response.data.heightStatus,
            weightStatus: response.data.weightStatus
          })
        }
      }
      
      setAnalysisResults(results)
    } catch (err) {
      setError('分析成长记录失败')
      console.error(err)
    }
  }

  // 处理小孩选择变化
  const handleChildChange = (e) => {
    const childId = e.target.value
    setSelectedChildId(childId)
    fetchGrowthRecords(childId)
  }

  if (loading) {
    return <div className="flex justify-center items-center h-64">加载中...</div>
  }

  if (children.length === 0) {
    return (
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold text-blue-600 mb-6">成长分析</h1>
        <div className="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded">
          还没有添加小孩信息，请先 <a href="/user/children" className="text-blue-600 hover:underline">添加小孩</a>。
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">成长分析</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <div className="mb-4">
        <label className="block text-gray-700 mb-2">选择小孩</label>
        <select
          value={selectedChildId}
          onChange={handleChildChange}
          className="w-1/3 px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          {children.map(child => (
            <option key={child.id} value={child.id}>
              {child.name} ({child.gender})
            </option>
          ))}
        </select>
      </div>

      {/* 成长分析结果 */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">记录日期</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">年龄</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">身高 (cm)</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">身高状态</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">体重 (kg)</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">体重状态</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {analysisResults.map((result, index) => (
              <tr key={index}>
                <td className="px-6 py-4 whitespace-nowrap">{result.record_date}</td>
                <td className="px-6 py-4 whitespace-nowrap">{result.age}</td>
                <td className="px-6 py-4 whitespace-nowrap">{result.height}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 rounded ${result.heightStatus === '身高标准' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                    {result.heightStatus}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">{result.weight}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 rounded ${result.weightStatus === '体重标准' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                    {result.weightStatus}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {analysisResults.length === 0 && (
        <div className="mt-8 text-center">
          <p className="text-gray-500">还没有成长记录，无法进行分析。请先 <a href="/user/growth-records" className="text-blue-600 hover:underline">添加成长记录</a>。</p>
        </div>
      )}
    </div>
  )
}

export default UserGrowthAnalysis
