import React, { useState, useEffect } from 'react'
import axios from 'axios'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend, Filler } from 'chart.js'
import { Line } from 'react-chartjs-2'

// 注册Chart.js组件
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

function UserHomePage() {
  const [user, setUser] = useState(() => {
    try {
      const userStr = localStorage.getItem('user');
      if (userStr) {
        return JSON.parse(userStr);
      }
    } catch (error) {
      console.error('Error parsing user:', error);
    }
    return null;
  });

  const [children, setChildren] = useState([]);
  const [selectedChildId, setSelectedChildId] = useState(null);
  const [selectedChild, setSelectedChild] = useState(null);
  const [latestGrowthRecord, setLatestGrowthRecord] = useState(null);
  const [heightStatus, setHeightStatus] = useState('');
  const [weightStatus, setWeightStatus] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('growth-records');
  const [activeChartTab, setActiveChartTab] = useState('height');
  const [growthRecords, setGrowthRecords] = useState([]);
  const [showFeedbackModal, setShowFeedbackModal] = useState(false);
  const [feedbackContent, setFeedbackContent] = useState('');
  const [feedbackType, setFeedbackType] = useState('建议');
  const [showBackupSuccess, setShowBackupSuccess] = useState(false);
  const [newRecord, setNewRecord] = useState({
    record_date: '',
    height: '',
    weight: ''
  });
  const [showAddRecordModal, setShowAddRecordModal] = useState(false);
  const [showAddChildModal, setShowAddChildModal] = useState(false);
  const [showEditChildModal, setShowEditChildModal] = useState(false);
  const [currentChild, setCurrentChild] = useState({
    name: '',
    gender: '男',
    birth_date: ''
  });
  const [editChildId, setEditChildId] = useState(null);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/';
  };

  // 检查用户是否登录
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      window.location.href = '/';
    }
  }, []);

  // 获取小孩信息
  useEffect(() => {
    const fetchChildren = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get('/api/user/children', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        setChildren(response.data);
        if (response.data.length > 0) {
          setSelectedChildId(response.data[0].id);
          setSelectedChild(response.data[0]);
          await fetchLatestGrowthRecord(response.data[0].id);
          await fetchGrowthRecords(response.data[0].id);
        }
      } catch (err) {
        setError('获取小孩信息失败');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchChildren();
  }, []);

  // 获取最新成长记录
  const fetchLatestGrowthRecord = async (childId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`/api/user/growth-records/${childId}`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      if (response.data.length > 0) {
        const latestRecord = response.data[0];
        setLatestGrowthRecord(latestRecord);
        await analyzeGrowthStatus(latestRecord, childId);
      }
    } catch (err) {
      console.error('获取成长记录失败:', err);
    }
  };

  // 分析成长状态
  const analyzeGrowthStatus = async (record, childId) => {
    try {
      const token = localStorage.getItem('token');
      const child = children.find(c => c.id === childId);
      if (!child) return;

      // 计算年龄
      const birthDate = new Date(child.birth_date);
      const recordDate = new Date(record.record_date);
      const age = Math.floor((recordDate - birthDate) / (365.25 * 24 * 60 * 60 * 1000));
      const ageStr = `${age}岁`;

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
      });

      setHeightStatus(response.data.heightStatus);
      setWeightStatus(response.data.weightStatus);
    } catch (err) {
      console.error('分析成长状态失败:', err);
    }
  };

  // 处理小孩选择变化
  const handleChildChange = (e) => {
    const childId = parseInt(e.target.value);
    setSelectedChildId(childId);
    const child = children.find(c => c.id === childId);
    setSelectedChild(child);
    fetchLatestGrowthRecord(childId);
    fetchGrowthRecords(childId);
  };

  // 获取成长记录
  const fetchGrowthRecords = async (childId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`/api/user/growth-records/${childId}`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      setGrowthRecords(response.data);
    } catch (err) {
      console.error('获取成长记录失败:', err);
    }
  };

  // 处理添加成长记录
  const handleAddRecord = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.post('/api/user/growth-records', {
        child_id: selectedChildId,
        record_date: newRecord.record_date,
        height: parseFloat(newRecord.height),
        weight: parseFloat(newRecord.weight)
      }, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      setShowAddRecordModal(false);
      setNewRecord({ record_date: '', height: '', weight: '' });
      await fetchGrowthRecords(selectedChildId);
      await fetchLatestGrowthRecord(selectedChildId);
    } catch (err) {
      console.error('添加成长记录失败:', err);
    }
  };

  // 处理提交反馈
  const handleSubmitFeedback = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.post('/api/user/feedback', {
        content: feedbackContent,
        type: feedbackType
      }, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      setShowFeedbackModal(false);
      setFeedbackContent('');
      setFeedbackType('建议');
    } catch (err) {
      console.error('提交反馈失败:', err);
    }
  };

  // 处理备份数据
  const handleBackup = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get('/api/user/backup', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      const dataStr = JSON.stringify(response.data);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `height4kid-backup-${new Date().toISOString().slice(0, 10)}.json`;
      link.click();
      setShowBackupSuccess(true);
      setTimeout(() => setShowBackupSuccess(false), 3000);
    } catch (err) {
      console.error('备份失败:', err);
    }
  };

  // 处理还原数据
  const handleRestore = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const data = JSON.parse(event.target.result);
        const token = localStorage.getItem('token');
        await axios.post('/api/user/restore', data, {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        // 重新加载数据
        window.location.reload();
      } catch (err) {
        console.error('还原失败:', err);
      }
    };
    reader.readAsText(file);
  };

  // 处理添加小孩
  const handleAddChild = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.post('/api/user/children', {
        name: currentChild.name,
        gender: currentChild.gender,
        birth_date: currentChild.birth_date
      }, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      setShowAddChildModal(false);
      setCurrentChild({ name: '', gender: '男', birth_date: '' });
      // 重新加载小孩信息
      const response = await axios.get('/api/user/children', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      setChildren(response.data);
      if (response.data.length > 0) {
        setSelectedChildId(response.data[0].id);
        setSelectedChild(response.data[0]);
        await fetchLatestGrowthRecord(response.data[0].id);
        await fetchGrowthRecords(response.data[0].id);
      }
    } catch (err) {
      console.error('添加小孩失败:', err);
    }
  };

  // 处理编辑小孩
  const handleEditChild = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.put(`/api/user/children/${editChildId}`, {
        name: currentChild.name,
        gender: currentChild.gender,
        birth_date: currentChild.birth_date
      }, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      setShowEditChildModal(false);
      setCurrentChild({ name: '', gender: '男', birth_date: '' });
      setEditChildId(null);
      // 重新加载小孩信息
      const response = await axios.get('/api/user/children', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      setChildren(response.data);
      if (response.data.length > 0) {
        const child = response.data.find(c => c.id === selectedChildId);
        if (child) {
          setSelectedChild(child);
        } else {
          setSelectedChildId(response.data[0].id);
          setSelectedChild(response.data[0]);
          await fetchLatestGrowthRecord(response.data[0].id);
          await fetchGrowthRecords(response.data[0].id);
        }
      }
    } catch (err) {
      console.error('编辑小孩失败:', err);
    }
  };

  // 处理删除小孩
  const handleDeleteChild = async (childId) => {
    if (window.confirm('确定要删除这个小孩的信息吗？')) {
      try {
        const token = localStorage.getItem('token');
        await axios.delete(`/api/user/children/${childId}`, {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        // 重新加载小孩信息
        const response = await axios.get('/api/user/children', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        setChildren(response.data);
        if (response.data.length > 0) {
          setSelectedChildId(response.data[0].id);
          setSelectedChild(response.data[0]);
          await fetchLatestGrowthRecord(response.data[0].id);
          await fetchGrowthRecords(response.data[0].id);
        } else {
          setSelectedChildId(null);
          setSelectedChild(null);
          setLatestGrowthRecord(null);
          setGrowthRecords([]);
        }
      } catch (err) {
        console.error('删除小孩失败:', err);
      }
    }
  };

  // 打开编辑小孩弹窗
  const openEditChildModal = (child) => {
    setCurrentChild({
      name: child.name,
      gender: child.gender,
      birth_date: child.birth_date
    });
    setEditChildId(child.id);
    setShowEditChildModal(true);
  };

  // 获取身高曲线数据
  const getHeightChartData = () => {
    // 使用正确的国标数据
    const ages = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
    
    // 创建数据集数组，先添加国标数据
    const datasets = [
      {
        label: '身高矮小',
        data: ages.map((age, index) => ({ x: age, y: [71.2, 81.6, 89.3, 96.3, 102.8, 108.6, 114, 119.3, 123.9, 127.9, 132.1, 137.2, 144, 151.5, 156.7, 159.1, 160.1, 160.5][index] })),
        borderColor: 'rgba(255, 99, 132, 0.7)',
        backgroundColor: 'rgba(255, 99, 132, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '身高偏矮',
        data: ages.map((age, index) => ({ x: age, y: [73.8, 85.1, 93.2, 100, 107, 113.1, 119, 124.6, 129.6, 134, 138.7, 144.6, 151.8, 158.7, 163.3, 165.4, 166.3, 166.6][index] })),
        borderColor: 'rgba(255, 159, 64, 0.7)',
        backgroundColor: 'rgba(255, 159, 64, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '身高标准',
        data: ages.map((age, index) => ({ x: age, y: [76.5, 88.5, 96.8, 104.1, 111.3, 117.7, 124, 130, 135.4, 140.2, 145.3, 151.9, 159.5, 165.9, 169.8, 171.6, 172.3, 172.7][index] })),
        borderColor: 'rgba(75, 192, 192, 0.7)',
        backgroundColor: 'rgba(75, 192, 192, 0)',
        borderWidth: 3,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '身高超高',
        data: ages.map((age, index) => ({ x: age, y: [79.3, 92.1, 100.7, 108.2, 115.7, 122.4, 129.1, 135.5, 141.2, 146.4, 152.1, 159.4, 167.3, 173.1, 176.3, 177.8, 178.4, 178.7][index] })),
        borderColor: 'rgba(54, 162, 235, 0.7)',
        backgroundColor: 'rgba(54, 162, 235, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      }
    ];

    // 如果有成长记录，添加实际数据（使用 order=1 确保最先绘制，但通过数组位置确保最后渲染）
    if (growthRecords.length > 0) {
      const sortedRecords = [...growthRecords].sort((a, b) => new Date(a.record_date) - new Date(b.record_date));
      
      const actualData = sortedRecords.map(record => {
        if (!selectedChild) return null;
        const birthDate = new Date(selectedChild.birth_date);
        const recordDate = new Date(record.record_date);
        const age = (recordDate - birthDate) / (365.25 * 24 * 60 * 60 * 1000);
        return {
          x: parseFloat(age.toFixed(1)),
          y: record.height
        };
      }).filter(item => item !== null);
      
      // 实际数据放在数组最后，确保最后绘制
      datasets.push({
        label: '实际身高',
        data: actualData,
        borderColor: colors.primary,
        backgroundColor: colors.primary,
        borderWidth: 4,
        pointRadius: 7,
        pointHoverRadius: 9,
        pointBorderWidth: 3,
        pointBorderColor: '#ffffff',
        fill: false,
        tension: 0.4,
        order: 1
      });
    }

    return {
      datasets
    };
  };

  // 获取体重曲线数据
  const getWeightChartData = () => {
    // 使用正确的国标数据
    const ages = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
    
    // 创建数据集数组，先添加国标数据
    const datasets = [
      {
        label: '体重偏瘦',
        data: ages.map((age, index) => ({ x: age, y: [9, 11.24, 13.13, 14.88, 16.87, 18.71, 20.83, 23.23, 25.5, 27.93, 30.95, 34.67, 39.22, 44.08, 48, 50.62, 52.2, 53.08][index] })),
        borderColor: 'rgba(255, 99, 132, 0.7)',
        backgroundColor: 'rgba(255, 99, 132, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '体重标准',
        data: ages.map((age, index) => ({ x: age, y: [10.05, 12.54, 14.65, 16.64, 18.98, 21.26, 24.06, 27.33, 30.46, 33.74, 37.69, 42.49, 48.08, 53.37, 57.08, 59.35, 60.68, 61.4][index] })),
        borderColor: 'rgba(75, 192, 192, 0.7)',
        backgroundColor: 'rgba(75, 192, 192, 0)',
        borderWidth: 3,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '体重超重',
        data: ages.map((age, index) => ({ x: age, y: [11.23, 14.01, 16.39, 18.67, 21.46, 24.32, 28.05, 32.57, 36.92, 41.31, 46.33, 52.31, 59.04, 64.84, 68.35, 70.2, 71.2, 71.73][index] })),
        borderColor: 'rgba(255, 159, 64, 0.7)',
        backgroundColor: 'rgba(255, 159, 64, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      },
      {
        label: '体重肥胖',
        data: ages.map((age, index) => ({ x: age, y: [12.54, 15.37, 18.37, 21.01, 24.38, 28.03, 33.08, 39.41, 45.52, 51.38, 57.58, 64.68, 72.6, 79.07, 82.45, 83.85, 84.45, 84.72][index] })),
        borderColor: 'rgba(54, 162, 235, 0.7)',
        backgroundColor: 'rgba(54, 162, 235, 0)',
        borderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        fill: false,
        tension: 0.4,
        order: 2
      }
    ];

    // 如果有成长记录，添加实际数据（放在数组最后确保最后绘制）
    if (growthRecords.length > 0) {
      const sortedRecords = [...growthRecords].sort((a, b) => new Date(a.record_date) - new Date(b.record_date));
      
      const actualData = sortedRecords.map(record => {
        if (!selectedChild) return null;
        const birthDate = new Date(selectedChild.birth_date);
        const recordDate = new Date(record.record_date);
        const age = (recordDate - birthDate) / (365.25 * 24 * 60 * 60 * 1000);
        return {
          x: parseFloat(age.toFixed(1)),
          y: record.weight
        };
      }).filter(item => item !== null);
      
      // 实际数据放在数组最后，确保最后绘制
      datasets.push({
        label: '实际体重',
        data: actualData,
        borderColor: colors.primary,
        backgroundColor: colors.primary,
        borderWidth: 4,
        pointRadius: 7,
        pointHoverRadius: 9,
        pointBorderWidth: 3,
        pointBorderColor: '#ffffff',
        fill: false,
        tension: 0.4,
        order: 1
      });
    }

    return {
      datasets
    };
  };

  // 生成默认头像
  const generateAvatar = (gender) => {
    if (gender === '男' || gender === 'male') {
      return 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF6B6B%22/%3E%3Cpath d=%22M35 65 Q50 75 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Ccircle cx=%2225%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Ccircle cx=%2275%22 cy=%2230%22 r=%228%22 fill=%22%23FFD93D%22/%3E%3Crect x=%2242%22 y=%2215%22 width=%2216%22 height=%2210%22 rx=%225%22 fill=%22%23FF6B6B%22/%3E%3C/svg%3E';
    } else {
      return 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2248%22 fill=%22%23FFB6C1%22/%3E%3Ccircle cx=%2235%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Ccircle cx=%2265%22 cy=%2240%22 r=%226%22 fill=%22%23333%22/%3E%3Cellipse cx=%2250%22 cy=%2255%22 rx=%2215%22 ry=%2210%22 fill=%22%23FF69B4%22/%3E%3Cpath d=%22M35 65 Q50 72 65 65%22 stroke=%22%23333%22 stroke-width=%223%22 fill=%22none%22/%3E%3Cellipse cx=%2225%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cellipse cx=%2275%22 cy=%2228%22 rx=%2210%22 ry=%2212%22 fill=%22%23FFB6C1%22/%3E%3Cpath d=%22M35 18 Q50 8 65 18%22 stroke=%22%23FF69B4%22 stroke-width=%224%22 fill=%22none%22/%3E%3Ccircle cx=%2250%22 cy=%2212%22 r=%225%22 fill=%22%23FFD700%22/%3E%3C/svg%3E';
    }
  };

  // 获取小孩成长状态图片
  const getChildImageUrl = () => {
    if (!selectedChild) return '';
    
    const birthDate = new Date(selectedChild.birth_date);
    const now = new Date();
    const ageYears = (now - birthDate) / (365.25 * 24 * 60 * 60 * 1000);
    
    let ageGroup;
    if (ageYears < 1) {
      ageGroup = '婴儿';
    } else if (ageYears < 3) {
      ageGroup = '幼儿';
    } else if (ageYears < 12) {
      ageGroup = '儿童';
    } else {
      ageGroup = '青少年';
    }
    
    const gender = (selectedChild.gender === '男' || selectedChild.gender === 'male') ? '男孩' : '女孩';
    const color = (selectedChild.gender === '男' || selectedChild.gender === 'male') ? '%233B7615' : '%23FA6D80';
    const text = encodeURIComponent(`${gender} ${ageGroup}`);
    
    // 使用URL编码的SVG数据URL
    return `data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22300%22%3E%3Crect width=%22400%22 height=%22300%22 fill=%22%23f0f0f0%22/%3E%3Ccircle cx=%22200%22 cy=%22100%22 r=%2250%22 fill=%22${color}%22/%3E%3Crect x=%22180%22 y=%22150%22 width=%2240%22 height=%22100%22 fill=%22${color}%22/%3E%3Crect x=%22160%22 y=%22160%22 width=%2220%22 height=%2260%22 fill=%22${color}%22/%3E%3Crect x=%22220%22 y=%22160%22 width=%2220%22 height=%2260%22 fill=%22${color}%22/%3E%3Crect x=%22170%22 y=%22250%22 width=%2220%22 height=%2240%22 fill=%22${color}%22/%3E%3Crect x=%22210%22 y=%22250%22 width=%2220%22 height=%2240%22 fill=%22${color}%22/%3E%3Ctext x=%22200%22 y=%22280%22 text-anchor=%22middle%22 fill=%22%23333%22 font-family=%22Arial%22 font-size=%2224%22%3E${text}%3C/text%3E%3C/svg%3E`;
  };

  // 获取性别主题色
  const getGenderColors = () => {
    if (!selectedChild) {
      return { primary: '#3B82F6', secondary: '#10B981' };
    }
    if (selectedChild.gender === '男' || selectedChild.gender === 'male') {
      return { primary: '#3B82F6', secondary: '#10B981' };
    } else {
      return { primary: '#EC4899', secondary: '#F59E0B' };
    }
  };

  // 计算年龄字符串
  const getAgeString = () => {
    if (!selectedChild) return '';
    
    const birthDate = new Date(selectedChild.birth_date);
    const now = new Date();
    const ageYears = Math.floor((now - birthDate) / (365.25 * 24 * 60 * 60 * 1000));
    const ageMonths = Math.floor(((now - birthDate) % (365.25 * 24 * 60 * 60 * 1000)) / (30 * 24 * 60 * 60 * 1000));
    
    return `${ageYears}岁${ageMonths}个月`;
  };

  if (loading) {
    return <div className="flex justify-center items-center h-screen">加载中...</div>;
  }

  if (!user) {
    return <div className="flex justify-center items-center h-screen">用户未登录</div>;
  }

  const colors = getGenderColors();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 顶部导航栏 */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold" style={{ color: colors.primary }}>
            {selectedChild ? selectedChild.name : '身高成长小助手'}
          </h1>
          <div className="flex items-center space-x-4">
            {children.length > 0 && (
              <select
                value={selectedChildId}
                onChange={handleChildChange}
                className="border rounded-md px-3 py-1 focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
              >
                {children.map(child => (
                  <option key={child.id} value={child.id}>
                    {child.name}
                  </option>
                ))}
              </select>
            )}
            <span className="text-gray-600">欢迎，{user.username}</span>
            <button 
              className="bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors"
              onClick={handleLogout}
            >
              退出登录
            </button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        {/* 无小孩信息时的提示 */}
        {children.length === 0 ? (
          <div className="bg-white rounded-lg shadow-md p-8 text-center">
            <h2 className="text-xl font-semibold text-gray-700 mb-4">还没有添加小孩信息</h2>
            <p className="text-gray-600 mb-6">请先添加小孩信息，开始记录孩子的成长历程</p>
            <button 
              onClick={() => setShowAddChildModal(true)}
              className="inline-block bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors"
            >
              添加小孩信息
            </button>
          </div>
        ) : (
          <>
            {/* 第一部分：小孩信息 */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-8">
              <div className="flex items-center">
                <div className="mr-6">
                  <img 
                    src={selectedChild.avatar || generateAvatar(selectedChild.gender)} 
                    alt="小孩头像" 
                    className="w-20 h-20 rounded-full object-cover border-2" style={{ borderColor: colors.primary }}
                    onError={(e) => {
                      e.target.src = generateAvatar(selectedChild.gender);
                    }}
                  />
                </div>
                <div className="flex-1">
                  <h2 className="text-xl font-bold" style={{ color: colors.primary }}>{selectedChild.name}</h2>
                  <p className="text-gray-600">{getAgeString()} | {selectedChild.gender}</p>
                </div>
                <div>
                  <button 
                    onClick={() => setActiveTab('child-management')}
                    className="inline-block bg-gray-200 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    管理小孩信息
                  </button>
                </div>
              </div>
            </div>

            {/* 第二部分：成长状态 */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-8">
              <h2 className="text-xl font-bold mb-6" style={{ color: colors.primary }}>成长状态</h2>
              <div className="flex flex-col md:flex-row items-center">
                <div className="md:w-1/2 mb-6 md:mb-0 flex justify-center">
                  <img 
                    src={getChildImageUrl()} 
                    alt="成长状态" 
                    className="max-w-full h-auto rounded-lg"
                    onError={(e) => {
                      console.error('成长状态图片加载失败:', e);
                      e.target.src = `https://via.placeholder.com/400x300?text=Child`;
                    }}
                  />
                </div>
                <div className="md:w-1/2 md:pl-8">
                  <h3 className="text-lg font-semibold mb-4">最近记录</h3>
                  {latestGrowthRecord ? (
                    <div className="space-y-4">
                      <div className="flex justify-between items-center p-4 bg-gray-50 rounded-lg">
                        <span className="font-medium">身高</span>
                        <div className="text-right">
                          <p className="text-xl font-bold" style={{ color: colors.primary }}>{latestGrowthRecord.height} cm</p>
                          <p className="text-sm" style={{ color: colors.secondary }}>{heightStatus}</p>
                        </div>
                      </div>
                      <div className="flex justify-between items-center p-4 bg-gray-50 rounded-lg">
                        <span className="font-medium">体重</span>
                        <div className="text-right">
                          <p className="text-xl font-bold" style={{ color: colors.primary }}>{latestGrowthRecord.weight} kg</p>
                          <p className="text-sm" style={{ color: colors.secondary }}>{weightStatus}</p>
                        </div>
                      </div>
                      <div className="text-sm text-gray-500">
                        记录日期: {latestGrowthRecord.record_date}
                      </div>
                    </div>
                  ) : (
                    <div className="p-4 bg-gray-50 rounded-lg text-center">
                      <p className="text-gray-500">暂无成长记录</p>
                      <a 
                        href="/user/growth-records" 
                        className="inline-block mt-2 text-blue-600 hover:underline"
                      >
                        添加成长记录
                      </a>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* 第三部分：分类导航 */}
            <div className="bg-white rounded-lg shadow-md mb-8">
              <div className="border-b">
                <nav className="flex overflow-x-auto">
                  <button 
                    onClick={() => setActiveTab('growth-records')}
                    className={`px-4 py-3 border-b-2 font-medium whitespace-nowrap transition-colors ${
                      activeTab === 'growth-records' 
                        ? 'border-primary text-primary' 
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                    style={{ 
                      borderColor: activeTab === 'growth-records' ? colors.primary : 'transparent',
                      color: activeTab === 'growth-records' ? colors.primary : 'inherit'
                    }}
                  >
                    成长信息记录
                  </button>
                  <button 
                    onClick={() => setActiveTab('growth-analysis')}
                    className={`px-4 py-3 border-b-2 font-medium whitespace-nowrap transition-colors ${
                      activeTab === 'growth-analysis' 
                        ? 'border-primary text-primary' 
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                    style={{ 
                      borderColor: activeTab === 'growth-analysis' ? colors.primary : 'transparent',
                      color: activeTab === 'growth-analysis' ? colors.primary : 'inherit'
                    }}
                  >
                    成长曲线
                  </button>
                  <button 
                    onClick={() => setActiveTab('feedback')}
                    className={`px-4 py-3 border-b-2 font-medium whitespace-nowrap transition-colors ${
                      activeTab === 'feedback' 
                        ? 'border-primary text-primary' 
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                    style={{ 
                      borderColor: activeTab === 'feedback' ? colors.primary : 'transparent',
                      color: activeTab === 'feedback' ? colors.primary : 'inherit'
                    }}
                  >
                    问题反馈
                  </button>
                  <button 
                    onClick={() => setActiveTab('backup')}
                    className={`px-4 py-3 border-b-2 font-medium whitespace-nowrap transition-colors ${
                      activeTab === 'backup' 
                        ? 'border-primary text-primary' 
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                    style={{ 
                      borderColor: activeTab === 'backup' ? colors.primary : 'transparent',
                      color: activeTab === 'backup' ? colors.primary : 'inherit'
                    }}
                  >
                    备份与还原
                  </button>
                  <button 
                    onClick={() => setActiveTab('child-management')}
                    className={`px-4 py-3 border-b-2 font-medium whitespace-nowrap transition-colors ${
                      activeTab === 'child-management' 
                        ? 'border-primary text-primary' 
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                    style={{ 
                      borderColor: activeTab === 'child-management' ? colors.primary : 'transparent',
                      color: activeTab === 'child-management' ? colors.primary : 'inherit'
                    }}
                  >
                    小孩管理
                  </button>
                </nav>
              </div>
              <div className="p-6">
                {/* 成长信息记录 */}
                {activeTab === 'growth-records' && (
                  <div>
                    <div className="flex justify-between items-center mb-6">
                      <h3 className="text-lg font-semibold">成长信息记录</h3>
                      <button 
                        onClick={() => setShowAddRecordModal(true)}
                        className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                      >
                        添加记录
                      </button>
                    </div>
                    
                    {growthRecords.length === 0 ? (
                      <div className="text-center py-8">
                        <p className="text-gray-500 mb-4">暂无成长记录</p>
                        <button 
                          onClick={() => setShowAddRecordModal(true)}
                          className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                        >
                          添加第一条记录
                        </button>
                      </div>
                    ) : (
                      <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                          <thead className="bg-gray-50">
                            <tr>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">记录日期</th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">身高 (cm)</th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">体重 (kg)</th>
                            </tr>
                          </thead>
                          <tbody className="bg-white divide-y divide-gray-200">
                            {growthRecords.map((record, index) => (
                              <tr key={index}>
                                <td className="px-6 py-4 whitespace-nowrap">{record.record_date}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{record.height}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{record.weight}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    )}
                  </div>
                )}

                {/* 成长曲线 */}
                {activeTab === 'growth-analysis' && (
                  <div>
                    <h3 className="text-lg font-semibold mb-6">成长曲线</h3>
                    
                    {/* 身高体重标签切换 */}
                    <div className="border-b mb-6">
                      <nav className="flex">
                        <button 
                          onClick={() => setActiveChartTab('height')}
                          className={`px-4 py-2 border-b-2 font-medium transition-colors ${
                            activeChartTab === 'height' 
                              ? 'border-primary text-primary' 
                              : 'text-gray-600 hover:text-gray-900'
                          }`}
                          style={{ 
                            borderColor: activeChartTab === 'height' ? colors.primary : 'transparent',
                            color: activeChartTab === 'height' ? colors.primary : 'inherit'
                          }}
                        >
                          身高曲线
                        </button>
                        <button 
                          onClick={() => setActiveChartTab('weight')}
                          className={`px-4 py-2 border-b-2 font-medium transition-colors ${
                            activeChartTab === 'weight' 
                              ? 'border-primary text-primary' 
                              : 'text-gray-600 hover:text-gray-900'
                          }`}
                          style={{ 
                            borderColor: activeChartTab === 'weight' ? colors.primary : 'transparent',
                            color: activeChartTab === 'weight' ? colors.primary : 'inherit'
                          }}
                        >
                          体重曲线
                        </button>
                      </nav>
                    </div>
                    
                    {/* 身高曲线 */}
                    {activeChartTab === 'height' && (
                      <div className="bg-gray-50 p-4 rounded-lg">
                        <div className="h-[700px]">
                          <Line 
                            data={getHeightChartData()} 
                            options={{
                              responsive: true,
                              maintainAspectRatio: false,
                              plugins: {
                                legend: {
                                  position: 'top',
                                },
                                title: {
                                  display: true,
                                  text: '身高增长趋势与国家标准对比'
                                }
                              },
                              scales: {
                                y: {
                                  beginAtZero: false,
                                  min: 50,
                                  max: 200,
                                  title: {
                                    display: true,
                                    text: '身高 (cm)'
                                  },
                                  ticks: {
                                    stepSize: 25
                                  }
                                },
                                x: {
                                  type: 'linear',
                                  min: 0,
                                  max: 18,
                                  title: {
                                    display: true,
                                    text: '年龄 (岁)'
                                  },
                                  ticks: {
                                    stepSize: 2
                                  }
                                }
                              }
                            }}
                          />
                        </div>
                      </div>
                    )}
                    
                    {/* 体重曲线 */}
                    {activeChartTab === 'weight' && (
                      <div className="bg-gray-50 p-4 rounded-lg">
                        <div className="h-[700px]">
                          <Line 
                            data={getWeightChartData()} 
                            options={{
                              responsive: true,
                              maintainAspectRatio: false,
                              plugins: {
                                legend: {
                                  position: 'top',
                                },
                                title: {
                                  display: true,
                                  text: '体重增长趋势与国家标准对比'
                                }
                              },
                              scales: {
                                y: {
                                  beginAtZero: false,
                                  min: 0,
                                  max: 100,
                                  title: {
                                    display: true,
                                    text: '体重 (kg)'
                                  },
                                  ticks: {
                                    stepSize: 25
                                  }
                                },
                                x: {
                                  type: 'linear',
                                  min: 0,
                                  max: 18,
                                  title: {
                                    display: true,
                                    text: '年龄 (岁)'
                                  },
                                  ticks: {
                                    stepSize: 2
                                  }
                                }
                              }
                            }}
                          />
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {/* 问题反馈 */}
                {activeTab === 'feedback' && (
                  <div>
                    <h3 className="text-lg font-semibold mb-6">问题反馈</h3>
                    <button 
                      onClick={() => setShowFeedbackModal(true)}
                      className="w-full py-3 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                    >
                      添加反馈
                    </button>
                  </div>
                )}

                {/* 备份与还原 */}
                {activeTab === 'backup' && (
                  <div>
                    <h3 className="text-lg font-semibold mb-6">备份与还原</h3>
                    
                    <div className="space-y-4">
                      <button 
                        onClick={handleBackup}
                        className="w-full py-3 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                      >
                        备份数据
                      </button>
                      
                      <div>
                        <label className="block text-gray-700 mb-2">还原数据</label>
                        <input 
                          type="file" 
                          accept=".json"
                          onChange={handleRestore}
                          className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                        />
                        <p className="text-gray-500 text-sm mt-1">选择备份文件进行还原</p>
                      </div>
                    </div>
                  </div>
                )}

                {/* 小孩管理 */}
                {activeTab === 'child-management' && (
                  <div>
                    <div className="flex justify-between items-center mb-6">
                      <h3 className="text-lg font-semibold">小孩管理</h3>
                      <button 
                        onClick={() => setShowAddChildModal(true)}
                        className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                      >
                        添加小孩
                      </button>
                    </div>
                    
                    {children.length === 0 ? (
                      <div className="text-center py-8">
                        <p className="text-gray-500 mb-4">暂无小孩信息</p>
                        <button 
                          onClick={() => setShowAddChildModal(true)}
                          className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                        >
                          添加第一个小孩
                        </button>
                      </div>
                    ) : (
                      <div className="space-y-4">
                        {children.map(child => (
                          <div key={child.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                            <div className="flex items-center">
                              <img 
                                src={child.avatar || generateAvatar(child.gender)} 
                                alt={child.name} 
                                className="w-12 h-12 rounded-full object-cover mr-4"
                                onError={(e) => {
                                  e.target.src = generateAvatar(child.gender);
                                }}
                              />
                              <div>
                                <h4 className="font-medium">{child.name}</h4>
                                <p className="text-sm text-gray-500">{child.gender} | {child.birth_date}</p>
                              </div>
                            </div>
                            <div className="flex space-x-2">
                              <button 
                                onClick={() => openEditChildModal(child)}
                                className="px-3 py-1 border rounded-md hover:bg-gray-100"
                              >
                                编辑
                              </button>
                              <button 
                                onClick={() => handleDeleteChild(child.id)}
                                className="px-3 py-1 border border-red-500 text-red-500 rounded-md hover:bg-red-50"
                              >
                                删除
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </main>

      <footer className="bg-white border-t mt-12 py-6">
        <div className="container mx-auto px-4 text-center text-gray-500">
          <p>© 2026 身高成长小助手</p>
        </div>
      </footer>

      {/* 添加成长记录弹窗 */}
      {showAddRecordModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">添加成长记录</h3>
              <button 
                onClick={() => setShowAddRecordModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
            <form onSubmit={handleAddRecord}>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">记录日期</label>
                  <input
                    type="date"
                    value={newRecord.record_date}
                    onChange={(e) => setNewRecord({ ...newRecord, record_date: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">身高 (cm)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={newRecord.height}
                    onChange={(e) => setNewRecord({ ...newRecord, height: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">体重 (kg)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={newRecord.weight}
                    onChange={(e) => setNewRecord({ ...newRecord, weight: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setShowAddRecordModal(false)}
                  className="px-4 py-2 border rounded-md hover:bg-gray-100"
                >
                  取消
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                >
                  保存
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 提交反馈弹窗 */}
      {showFeedbackModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">提交反馈</h3>
              <button 
                onClick={() => setShowFeedbackModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
            <form onSubmit={handleSubmitFeedback}>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">反馈类型</label>
                  <select
                    value={feedbackType}
                    onChange={(e) => setFeedbackType(e.target.value)}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                  >
                    <option value="建议">建议</option>
                    <option value="问题">问题</option>
                    <option value="其他">其他</option>
                  </select>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">反馈内容</label>
                  <textarea
                    value={feedbackContent}
                    onChange={(e) => setFeedbackContent(e.target.value)}
                    rows={4}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setShowFeedbackModal(false)}
                  className="px-4 py-2 border rounded-md hover:bg-gray-100"
                >
                  取消
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                >
                  提交
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 备份成功提示 */}
      {showBackupSuccess && (
        <div className="fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-md shadow-lg z-50">
          备份成功！
        </div>
      )}

      {/* 添加小孩弹窗 */}
      {showAddChildModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">添加小孩</h3>
              <button 
                onClick={() => setShowAddChildModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
            <form onSubmit={handleAddChild}>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">姓名</label>
                  <input
                    type="text"
                    value={currentChild.name}
                    onChange={(e) => setCurrentChild({ ...currentChild, name: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">性别</label>
                  <select
                    value={currentChild.gender}
                    onChange={(e) => setCurrentChild({ ...currentChild, gender: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                  >
                    <option value="男">男</option>
                    <option value="女">女</option>
                  </select>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">出生日期</label>
                  <input
                    type="date"
                    value={currentChild.birth_date}
                    onChange={(e) => setCurrentChild({ ...currentChild, birth_date: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setShowAddChildModal(false)}
                  className="px-4 py-2 border rounded-md hover:bg-gray-100"
                >
                  取消
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                >
                  保存
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 编辑小孩弹窗 */}
      {showEditChildModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">编辑小孩</h3>
              <button 
                onClick={() => setShowEditChildModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
            <form onSubmit={handleEditChild}>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">姓名</label>
                  <input
                    type="text"
                    value={currentChild.name}
                    onChange={(e) => setCurrentChild({ ...currentChild, name: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">性别</label>
                  <select
                    value={currentChild.gender}
                    onChange={(e) => setCurrentChild({ ...currentChild, gender: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                  >
                    <option value="男">男</option>
                    <option value="女">女</option>
                  </select>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">出生日期</label>
                  <input
                    type="date"
                    value={currentChild.birth_date}
                    onChange={(e) => setCurrentChild({ ...currentChild, birth_date: e.target.value })}
                    className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2" style={{ ringColor: colors.primary }}
                    required
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setShowEditChildModal(false)}
                  className="px-4 py-2 border rounded-md hover:bg-gray-100"
                >
                  取消
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-md" style={{ backgroundColor: colors.primary, color: 'white' }}
                >
                  保存
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default UserHomePage;