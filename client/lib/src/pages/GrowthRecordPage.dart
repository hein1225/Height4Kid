import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class GrowthRecordPage extends StatefulWidget {
  const GrowthRecordPage({super.key});

  @override
  State<GrowthRecordPage> createState() => _GrowthRecordPageState();
}

class _GrowthRecordPageState extends State<GrowthRecordPage> {
  List<dynamic> _children = [];
  int? _selectedChildId;
  final TextEditingController _recordDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChildren();
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

      final dio = Dio();
      final response = await dio.get(
        '$serverUrl/api/user/children',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _children = response.data;
          if (_children.isNotEmpty) {
            _selectedChildId = _children[0]['id'];
          }
        });
      } else {
        setState(() {
          _errorMessage = '获取小孩信息失败';
        });
      }
    } catch (e) {
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

      if (_selectedChildId == null) {
        throw Exception('请选择小孩');
      }

      final dio = Dio();
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录保存成功')),
        );
        _recordDateController.clear();
        _heightController.clear();
        _weightController.clear();
      } else {
        setState(() {
          _errorMessage = '保存失败';
        });
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长信息记录'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedChildId,
                        items: _children.map((child) {
                          return DropdownMenuItem<int>(
                            value: child['id'],
                            child: Text(child['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedChildId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: '选择小孩',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _recordDateController,
                        decoration: const InputDecoration(
                          labelText: '记录日期',
                          hintText: '例如: 2024-01-01',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '身高 (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '体重 (kg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveGrowthRecord,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('保存记录'),
                      ),
                    ],
                  ),
                ),
    );
  }
}