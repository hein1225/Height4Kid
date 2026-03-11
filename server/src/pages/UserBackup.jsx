import React, { useState } from 'react'
import axios from 'axios'

function UserBackup() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  // 备份数据
  const handleBackup = async () => {
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const token = localStorage.getItem('token')
      const response = await axios.get('/api/user/children', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })

      const children = response.data
      const backupData = {
        children,
        timestamp: new Date().toISOString()
      }

      // 创建下载链接
      const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `height4kid_backup_${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

      setSuccess('备份成功，文件已下载到本地')
    } catch (err) {
      setError('备份失败，请稍后重试')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  // 还原数据
  const handleRestore = async (e) => {
    const file = e.target.files[0]
    if (!file) return

    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const reader = new FileReader()
      reader.onload = async (event) => {
        try {
          const backupData = JSON.parse(event.target.result)
          const token = localStorage.getItem('token')

          // 先删除现有小孩信息
          const childrenResponse = await axios.get('/api/user/children', {
            headers: {
              Authorization: `Bearer ${token}`
            }
          })

          for (const child of childrenResponse.data) {
            await axios.delete(`/api/user/children/${child.id}`, {
              headers: {
                Authorization: `Bearer ${token}`
              }
            })
          }

          // 导入备份的小孩信息
          for (const child of backupData.children) {
            await axios.post('/api/user/children', {
              name: child.name,
              birth_date: child.birth_date,
              gender: child.gender,
              avatar: child.avatar
            }, {
              headers: {
                Authorization: `Bearer ${token}`,
                'Content-Type': 'application/json'
              }
            })
          }

          setSuccess('还原成功，数据已更新')
          e.target.value = '' // 清空文件输入
        } catch (err) {
          setError('还原失败，请检查备份文件格式')
          console.error(err)
        } finally {
          setLoading(false)
        }
      }
      reader.readAsText(file)
    } catch (err) {
      setError('还原失败，请稍后重试')
      console.error(err)
      setLoading(false)
    }
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">备份与还原</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {success && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          {success}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* 备份数据 */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">备份数据</h2>
          <p className="text-gray-600 mb-6">
            点击下方按钮将您的小孩信息备份到本地文件，以便在需要时恢复数据。
          </p>
          <button
            onClick={handleBackup}
            className="w-full bg-blue-600 text-white py-3 rounded-md hover:bg-blue-700 transition-colors"
            disabled={loading}
          >
            {loading ? '备份中...' : '备份数据'}
          </button>
        </div>

        {/* 还原数据 */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold text-gray-700 mb-4">还原数据</h2>
          <p className="text-gray-600 mb-6">
            选择之前备份的JSON文件，将数据还原到系统中。
            <br />
            <span className="text-red-500 font-medium">注意：还原会覆盖现有数据，请谨慎操作。</span>
          </p>
          <div className="border-2 border-dashed border-gray-300 rounded-md p-8 text-center">
            <input
              type="file"
              accept=".json"
              onChange={handleRestore}
              className="hidden"
              id="backup-file"
            />
            <label
              htmlFor="backup-file"
              className="cursor-pointer"
            >
              <div className="flex flex-col items-center">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-gray-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                </svg>
                <p className="text-gray-600">点击或拖拽文件到此处</p>
                <p className="text-gray-400 text-sm mt-1">支持 .json 文件</p>
              </div>
            </label>
          </div>
        </div>
      </div>

      <div className="mt-8 bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold text-gray-700 mb-4">备份说明</h2>
        <ul className="list-disc list-inside text-gray-600 space-y-2">
          <li>备份文件包含所有小孩的基本信息</li>
          <li>备份文件为JSON格式，可以用文本编辑器打开查看</li>
          <li>建议定期备份数据，以防止数据丢失</li>
          <li>还原数据时会删除现有所有小孩信息，请确保备份文件是最新的</li>
          <li>如果您有多个设备，可以通过备份文件在不同设备间同步数据</li>
        </ul>
      </div>
    </div>
  )
}

export default UserBackup