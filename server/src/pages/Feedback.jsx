import React, { useState, useEffect } from 'react'

function Feedback() {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [replyingFeedback, setReplyingFeedback] = useState(null);
  const [reply, setReply] = useState('');

  useEffect(() => {
    fetchFeedbacks();
  }, []);

  const fetchFeedbacks = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/admin/feedback', {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setFeedbacks(data);
      } else {
        setError('Failed to fetch feedback');
      }
    } catch (err) {
      setError('Network error');
    } finally {
      setLoading(false);
    }
  };

  const handleReply = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/admin/feedback/${replyingFeedback.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ reply }),
      });

      if (response.ok) {
        setReplyingFeedback(null);
        setReply('');
        fetchFeedbacks();
      } else {
        setError('Failed to reply to feedback');
      }
    } catch (err) {
      setError('Network error');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this feedback?')) {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`/api/admin/feedback/${id}`, {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (response.ok) {
          fetchFeedbacks();
        } else {
          setError('Failed to delete feedback');
        }
      } catch (err) {
        setError('Network error');
      }
    }
  };

  if (loading) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-blue-600 mb-6">问题反馈</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}

      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">用户反馈列表</h2>
        <div className="space-y-4">
          {feedbacks.map((feedback) => (
            <div key={feedback.id} className="border rounded-lg p-4">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-md font-semibold text-gray-800">{feedback.title}</h3>
                  <p className="text-gray-600 mt-2">{feedback.content}</p>
                  <p className="text-sm text-gray-500 mt-2">反馈时间: {new Date(feedback.created_at).toLocaleString()}</p>
                  <p className="text-sm text-gray-500">反馈用户: ID {feedback.user_id}</p>
                </div>
                <div>
                  <span className={`px-2 py-1 rounded-md text-xs font-medium ${feedback.status === 'resolved' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                    {feedback.status === 'resolved' ? '已解决' : '待处理'}
                  </span>
                </div>
              </div>
              
              {feedback.reply && (
                <div className="mt-4 p-3 bg-gray-50 rounded-md">
                  <p className="text-sm font-semibold text-gray-700">管理员回复:</p>
                  <p className="text-gray-600 mt-1">{feedback.reply}</p>
                </div>
              )}
              
              <div className="mt-4 flex space-x-2">
                {!feedback.reply && (
                  <button 
                    className="bg-blue-500 text-white px-3 py-1 rounded-md hover:bg-blue-600 transition-colors text-sm"
                    onClick={() => setReplyingFeedback(feedback)}
                  >
                    回复
                  </button>
                )}
                <button 
                  className="bg-red-500 text-white px-3 py-1 rounded-md hover:bg-red-600 transition-colors text-sm"
                  onClick={() => handleDelete(feedback.id)}
                >
                  删除
                </button>
              </div>
              
              {replyingFeedback && replyingFeedback.id === feedback.id && (
                <div className="mt-4">
                  <form onSubmit={handleReply}>
                    <div>
                      <label className="block text-gray-700 mb-2">回复内容</label>
                      <textarea 
                        className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        rows="3"
                        value={reply}
                        onChange={(e) => setReply(e.target.value)}
                        required
                      ></textarea>
                    </div>
                    <div className="mt-3 flex space-x-2">
                      <button 
                        type="submit" 
                        className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors"
                      >
                        提交回复
                      </button>
                      <button 
                        type="button" 
                        className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600 transition-colors"
                        onClick={() => {
                          setReplyingFeedback(null);
                          setReply('');
                        }}
                      >
                        取消
                      </button>
                    </div>
                  </form>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export default Feedback