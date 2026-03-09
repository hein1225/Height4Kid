import React, { useState, useEffect } from 'react'

function StandardData() {
  const [standardData, setStandardData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchStandardData();
  }, []);

  const fetchStandardData = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:8080/api/admin/standard-data', {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setStandardData(data);
      } else {
        setError('Failed to fetch standard data');
      }
    } catch (err) {
      setError('Network error');
    } finally {
      setLoading(false);
    }
  };

  // 删除所有国标数据
  const handleDeleteAllData = async () => {
    if (window.confirm('确定要删除所有国标数据吗？此操作不可恢复。')) {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch('http://localhost:8080/api/admin/standard-data/clear', {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (response.ok) {
          setStandardData([]);
        } else {
          setError('Failed to delete standard data');
        }
      } catch (err) {
        setError('Network error');
      }
    }
  };

  // 导出数据到本地（JSON格式）
  const handleExportData = () => {
    const dataStr = JSON.stringify(standardData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'standard_data.json';
    link.click();
    URL.revokeObjectURL(url);
  };

  // 导出数据到本地（XLSX格式）
  const handleExportDataXlsx = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:8080/api/admin/standard-data/export/xlsx', {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = 'standard_data.xlsx';
        link.click();
        URL.revokeObjectURL(url);
      } else {
        setError('Failed to export data');
      }
    } catch (err) {
      setError('Network error');
    }
  };

  // 处理JSON文件导入
  const handleFileImport = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const importedData = JSON.parse(event.target.result);
        await importData(importedData);
      } catch (err) {
        setError('Failed to parse imported data');
      }
    };
    reader.readAsText(file);
  };

  // 处理XLSX文件导入
  const handleFileImportXlsx = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    try {
      const token = localStorage.getItem('token');
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch('http://localhost:8080/api/admin/standard-data/import/xlsx', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        body: formData,
      });

      if (response.ok) {
        // 重新获取数据
        fetchStandardData();
      } else {
        setError('Failed to import data');
      }
    } catch (err) {
      setError('Network error');
    }
  };

  // 导入数据到数据库
  const importData = async (data) => {
    try {
      const token = localStorage.getItem('token');
      
      // 清空现有数据
      await fetch('http://localhost:8080/api/admin/standard-data/clear', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      // 导入新数据
      for (const item of data) {
        await fetch('http://localhost:8080/api/admin/standard-data', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(item),
        });
      }

      // 重新获取数据
      fetchStandardData();
    } catch (err) {
      setError('Failed to import data');
    }
  };

  // 按性别分组并按年龄排序
  const boysData = standardData
    .filter(data => data.gender === '男')
    .sort((a, b) => {
      // 提取年龄数字进行排序
      const ageA = parseInt(a.age);
      const ageB = parseInt(b.age);
      return ageA - ageB;
    });

  const girlsData = standardData
    .filter(data => data.gender === '女')
    .sort((a, b) => {
      // 提取年龄数字进行排序
      const ageA = parseInt(a.age);
      const ageB = parseInt(b.age);
      return ageA - ageB;
    });

  if (loading) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">国标数据管理</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}

      <div className="bg-white p-6 rounded-lg shadow-md mb-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">数据管理</h2>
        <div className="flex flex-col md:flex-row gap-4 flex-wrap">
          <button 
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors flex items-center"
            onClick={handleExportData}
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            导出数据 (JSON)
          </button>
          <button 
            className="bg-blue-700 text-white px-4 py-2 rounded-md hover:bg-blue-800 transition-colors flex items-center"
            onClick={handleExportDataXlsx}
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            导出数据 (XLSX)
          </button>
          <div className="flex items-center">
            <label className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors cursor-pointer flex items-center">
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              导入数据 (JSON)
              <input 
                type="file" 
                accept=".json" 
                className="hidden" 
                onChange={handleFileImport}
              />
            </label>
          </div>
          <div className="flex items-center">
            <label className="bg-green-700 text-white px-4 py-2 rounded-md hover:bg-green-800 transition-colors cursor-pointer flex items-center">
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              导入数据 (XLSX)
              <input 
                type="file" 
                accept=".xlsx" 
                className="hidden" 
                onChange={handleFileImportXlsx}
              />
            </label>
          </div>
          <button 
            className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition-colors flex items-center"
            onClick={handleDeleteAllData}
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            删除所有数据
          </button>
        </div>
        <p className="mt-4 text-sm text-gray-500">
          导出数据后，您可以在本地编辑文件，然后重新导入以更新国标数据。支持JSON和XLSX两种格式。
        </p>
      </div>

      {/* 男孩数据表格 */}
      <div className="bg-white p-6 rounded-lg shadow-md mb-8">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">男孩国标数据</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-4 py-2 text-left">年龄</th>
                <th className="px-4 py-2 text-left">身高矮小 (cm)</th>
                <th className="px-4 py-2 text-left">身高偏矮 (cm)</th>
                <th className="px-4 py-2 text-left">身高标准 (cm)</th>
                <th className="px-4 py-2 text-left">身高超高 (cm)</th>
                <th className="px-4 py-2 text-left">体重偏瘦 (kg)</th>
                <th className="px-4 py-2 text-left">体重标准 (kg)</th>
                <th className="px-4 py-2 text-left">体重超重 (kg)</th>
                <th className="px-4 py-2 text-left">体重肥胖 (kg)</th>
              </tr>
            </thead>
            <tbody>
              {boysData.map((data) => (
                <tr key={data.id} className="border-b">
                  <td className="px-4 py-2">{data.age}</td>
                <td className="px-4 py-2">{data.height_low}</td>
                <td className="px-4 py-2">{data.height_normal_low}</td>
                <td className="px-4 py-2">{data.height_normal_high}</td>
                <td className="px-4 py-2">{data.height_high}</td>
                <td className="px-4 py-2">{data.weight_low}</td>
                <td className="px-4 py-2">{data.weight_normal_low}</td>
                <td className="px-4 py-2">{data.weight_overweight}</td>
                <td className="px-4 py-2">{data.weight_high}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 女孩数据表格 */}
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">女孩国标数据</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-4 py-2 text-left">年龄</th>
                <th className="px-4 py-2 text-left">身高矮小 (cm)</th>
                <th className="px-4 py-2 text-left">身高偏矮 (cm)</th>
                <th className="px-4 py-2 text-left">身高标准 (cm)</th>
                <th className="px-4 py-2 text-left">身高超高 (cm)</th>
                <th className="px-4 py-2 text-left">体重偏瘦 (kg)</th>
                <th className="px-4 py-2 text-left">体重标准 (kg)</th>
                <th className="px-4 py-2 text-left">体重超重 (kg)</th>
                <th className="px-4 py-2 text-left">体重肥胖 (kg)</th>
              </tr>
            </thead>
            <tbody>
              {girlsData.map((data) => (
                <tr key={data.id} className="border-b">
                  <td className="px-4 py-2">{data.age}</td>
                <td className="px-4 py-2">{data.height_low}</td>
                <td className="px-4 py-2">{data.height_normal_low}</td>
                <td className="px-4 py-2">{data.height_normal_high}</td>
                <td className="px-4 py-2">{data.height_high}</td>
                <td className="px-4 py-2">{data.weight_low}</td>
                <td className="px-4 py-2">{data.weight_normal_low}</td>
                <td className="px-4 py-2">{data.weight_overweight}</td>
                <td className="px-4 py-2">{data.weight_high}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default StandardData