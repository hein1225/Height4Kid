import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class GrowthRecordPage extends StatefulWidget {
  const GrowthRecordPage({super.key});

  @override
  State<GrowthRecordPage> createState() => _GrowthRecordPageState();
}

class _GrowthRecordPageState extends State<GrowthRecordPage> {
  List<dynamic> _children = [];
  int? _selectedChildId;
  dynamic _selectedChild;
  final TextEditingController _recordDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChildren();
    // 设置默认日期为今天
    _recordDateController.text = DateTime.now().toString().split(' ')[0];
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final serverUrl = prefs.getString('server_url');

      if (token == null || serverUrl == null) {
        throw Exception('请先登录');
      }

      // 配置Dio实例，添加超时和错误处理
      final dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      // 打印请求信息
      print('请求URL: $serverUrl/api/user/children');

      final response = await dio.get(
        '$serverUrl/api/user/children',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          _children = response.data;
          if (_children.isNotEmpty) {
            _selectedChildId = _children[0]['id'];
            _selectedChild = _children[0];
          }
        });
      } else {
        setState(() {
          _errorMessage = '获取小孩信息失败';
        });
      }
    } on DioError catch (e) {
      print('Dio错误: ${e.toString()}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
        setState(() {
          _errorMessage = e.response?.data['message'] ?? '获取小孩信息失败: ${e.response?.statusCode}';
        });
      } else if (e.type == DioErrorType.connectionTimeout) {
        setState(() {
          _errorMessage = '连接超时，请检查网络连接';
        });
      } else if (e.type == DioErrorType.unknown) {
        setState(() {
          _errorMessage = '网络错误，请检查服务端地址是否正确';
        });
      } else {
        setState(() {
          _errorMessage = '获取小孩信息失败: ${e.message}';
        });
      }
    } catch (e) {
      print('其他错误: ${e.toString()}');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGrowthRecord() async {
    // 数据验证
    if (_selectedChildId == null) {
      setState(() {
        _errorMessage = '请选择小孩';
      });
      return;
    }

    if (_recordDateController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入记录日期';
      });
      return;
    }

    if (_heightController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入身高';
      });
      return;
    }

    if (_weightController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入体重';
      });
      return;
    }

    try {
      double.parse(_heightController.text.trim());
      double.parse(_weightController.text.trim());
    } catch (e) {
      setState(() {
        _errorMessage = '身高和体重必须是数字';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final serverUrl = prefs.getString('server_url');

      if (token == null || serverUrl == null) {
        throw Exception('请先登录');
      }

      // 配置Dio实例，添加超时和错误处理
      final dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      // 打印请求信息
      print('请求URL: $serverUrl/api/user/growth-records');
      print('请求数据: {child_id: $_selectedChildId, record_date: ${_recordDateController.text.trim()}, height: ${_heightController.text.trim()}, weight: ${_weightController.text.trim()}}');

      final response = await dio.post(
        '$serverUrl/api/user/growth-records',
        data: {
          'child_id': _selectedChildId,
          'record_date': _recordDateController.text.trim(),
          'height': double.parse(_heightController.text.trim()),
          'weight': double.parse(_weightController.text.trim()),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录保存成功')),
        );
        _recordDateController.clear();
        _heightController.clear();
        _weightController.clear();
        // 重置为今天的日期
        _recordDateController.text = DateTime.now().toString().split(' ')[0];
      } else {
        setState(() {
          _errorMessage = '保存失败';
        });
      }
    } on DioError catch (e) {
      print('Dio错误: ${e.toString()}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
        setState(() {
          _errorMessage = e.response?.data['message'] ?? '保存失败: ${e.response?.statusCode}';
        });
      } else if (e.type == DioErrorType.connectionTimeout) {
        setState(() {
          _errorMessage = '连接超时，请检查网络连接';
        });
      } else if (e.type == DioErrorType.unknown) {
        setState(() {
          _errorMessage = '网络错误，请检查服务端地址是否正确';
        });
      } else {
        setState(() {
          _errorMessage = '保存失败: ${e.message}';
        });
      }
    } catch (e) {
      print('其他错误: ${e.toString()}');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _selectedChild != null && _selectedChild['gender'] == 'male';
    final primaryColor = isMale ? Colors.blue : Colors.pink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('成长信息记录'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isMale 
              ? [Colors.blue.shade100, Colors.white]
              : [Colors.pink.shade100, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red))) 
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedChildId,
                          items: _children.map((child) {
                            return DropdownMenuItem<int>(
                              value: child['id'],
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: child['avatar'] != ''
                                        ? NetworkImage(child['avatar'])
                                        : NetworkImage(
                                            child['gender'] == 'male'
                                                ? 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy'
                                                : 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl',
                                          ) as ImageProvider,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(child['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedChildId = value;
                              _selectedChild = _children.firstWhere((child) => child['id'] == value);
                            });
                          },
                          decoration: InputDecoration(
                            labelText: '选择小孩',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _recordDateController,
                          decoration: InputDecoration(
                            labelText: '记录日期',
                            hintText: '例如: 2024-01-01',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '身高 (cm)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '体重 (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveGrowthRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('保存记录', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
