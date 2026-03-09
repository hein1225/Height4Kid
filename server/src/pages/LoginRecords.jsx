import React, { useState, useEffect } from 'react'

function LoginRecords() {
  const [loginRecords, setLoginRecords] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchLoginRecords();
  }, []);

  const fetchLoginRecords = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:8000/api/admin/login-records', {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setLoginRecords(data);
      } else {
        setError('Failed to fetch login records');
      }
    } catch (err) {
      setError('Network error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">普通账户登录记录</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}

      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">登录记录列表</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-100">
                <th className="px-4 py-2 text-left">ID</th>
                <th className="px-4 py-2 text-left">用户ID</th>
                <th className="px-4 py-2 text-left">登录时间</th>
                <th className="px-4 py-2 text-left">IP地址</th>
              </tr>
            </thead>
            <tbody>
              {loginRecords.map((record) => (
                <tr key={record.id} className="border-b">
                  <td className="px-4 py-2">{record.id}</td>
                  <td className="px-4 py-2">{record.user_id}</td>
                  <td className="px-4 py-2">{new Date(record.login_time).toLocaleString()}</td>
                  <td className="px-4 py-2">{record.ip}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default LoginRecords