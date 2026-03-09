import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class GrowthCurvePage extends StatefulWidget {
  const GrowthCurvePage({super.key});

  @override
  State<GrowthCurvePage> createState() => _GrowthCurvePageState();
}

class _GrowthCurvePageState extends State<GrowthCurvePage> {
  List<dynamic> _children = [];
  int? _selectedChildId;
  List<dynamic> _growthRecords = [];
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
            _fetchGrowthRecords(_selectedChildId!);
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

  Future<void> _fetchGrowthRecords(int childId) async {
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
        '$serverUrl/api/user/growth-records/$childId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _growthRecords = response.data;
        });
      } else {
        setState(() {
          _errorMessage = '获取成长记录失败';
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
        title: const Text('成长曲线'),
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
                            if (value != null) {
                              _fetchGrowthRecords(value);
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: '选择小孩',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _growthRecords.isEmpty
                            ? const Center(child: Text('暂无成长记录'))
                            : ListView.builder(
                                itemCount: _growthRecords.length,
                                itemBuilder: (context, index) {
                                  final record = _growthRecords[index];
                                  return ListTile(
                                    title: Text('日期: ${record['record_date']}'),
                                    subtitle: Text('身高: ${record['height']} cm, 体重: ${record['weight']} kg'),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}