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
  dynamic _selectedChild;
  List<dynamic> _growthRecords = [];
  List<dynamic> _standardData = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChildren();
    _fetchStandardData();
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
            _selectedChild = _children[0];
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

  Future<void> _fetchStandardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final serverUrl = prefs.getString('server_url');

      if (token == null || serverUrl == null) {
        throw Exception('请先登录');
      }

      final dio = Dio();
      final response = await dio.get(
        '$serverUrl/api/user/standard-data',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _standardData = response.data;
        });
      }
    } catch (e) {
      print('获取国标数据失败: $e');
    }
  }

  List<Map<String, double>> _calculateAgeAndValues() {
    if (_selectedChild == null || _growthRecords.isEmpty) return [];

    final birthDate = DateTime.parse(_selectedChild['birth_date']);
    return _growthRecords.map((record) {
      final recordDate = DateTime.parse(record['record_date']);
      final ageYears = recordDate.difference(birthDate).inDays / 365.25;
      return {
        'age': ageYears,
        'height': double.tryParse(record['height'].toString()) ?? 0.0,
        'weight': double.tryParse(record['weight'].toString()) ?? 0.0
      };
    }).toList();
  }

  List<Map<String, double>> _getStandardHeightData() {
    if (_selectedChild == null || _standardData.isEmpty) return [];

    final gender = _selectedChild['gender'];
    return _standardData
        .where((data) => data['gender'] == gender)
        .map((data) {
          final age = int.parse(data['age'].replaceAll('岁', ''));
          return {
            'age': age.toDouble(),
            'low': double.tryParse(data['height_low'].toString()) ?? 0.0,
            'normalLow': double.tryParse(data['height_normal_low'].toString()) ?? 0.0,
            'normalHigh': double.tryParse(data['height_normal_high'].toString()) ?? 0.0,
            'high': double.tryParse(data['height_high'].toString()) ?? 0.0
          };
        })
        .toList();
  }

  List<Map<String, double>> _getStandardWeightData() {
    if (_selectedChild == null || _standardData.isEmpty) return [];

    final gender = _selectedChild['gender'];
    return _standardData
        .where((data) => data['gender'] == gender)
        .map((data) {
          final age = int.parse(data['age'].replaceAll('岁', ''));
          return {
            'age': age.toDouble(),
            'low': double.tryParse(data['weight_low'].toString()) ?? 0.0,
            'normalLow': double.tryParse(data['weight_normal_low'].toString()) ?? 0.0,
            'normalHigh': double.tryParse(data['weight_normal_high'].toString()) ?? 0.0,
            'high': double.tryParse(data['weight_high'].toString()) ?? 0.0
          };
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _selectedChild != null && _selectedChild['gender'] == 'male';
    final primaryColor = isMale ? Colors.blue : Colors.pink;
    final growthData = _calculateAgeAndValues();
    final standardHeightData = _getStandardHeightData();
    final standardWeightData = _getStandardWeightData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('成长曲线'),
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
                              if (value != null) {
                                _fetchGrowthRecords(value);
                              }
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
                        const SizedBox(height: 20),
                        
                        // 身高成长曲线
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('身高成长曲线', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                              const SizedBox(height: 10),
                              Container(
                                height: 200,
                                child: growthData.isEmpty
                                    ? const Center(child: Text('暂无成长记录'))
                                    : CustomPaint(
                                        painter: CurvePainter(
                                          data: growthData.map((item) => [item['age']!, item['height']!]).toList(),
                                          standardData: standardHeightData,
                                          color: primaryColor,
                                          showStandard: true,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 10, height: 10, color: primaryColor),
                                  const SizedBox(width: 5),
                                  const Text('实际身高'),
                                  const SizedBox(width: 20),
                                  Container(width: 10, height: 10, color: Colors.green),
                                  const SizedBox(width: 5),
                                  const Text('标准范围'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // 体重成长曲线
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('体重成长曲线', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                              const SizedBox(height: 10),
                              Container(
                                height: 200,
                                child: growthData.isEmpty
                                    ? const Center(child: Text('暂无成长记录'))
                                    : CustomPaint(
                                        painter: CurvePainter(
                                          data: growthData.map((item) => [item['age']!, item['weight']!]).toList(),
                                          standardData: standardWeightData,
                                          color: primaryColor,
                                          showStandard: true,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 10, height: 10, color: primaryColor),
                                  const SizedBox(width: 5),
                                  const Text('实际体重'),
                                  const SizedBox(width: 20),
                                  Container(width: 10, height: 10, color: Colors.green),
                                  const SizedBox(width: 5),
                                  const Text('标准范围'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // 成长记录列表
                        Expanded(
                          child: _growthRecords.isEmpty
                              ? const Center(child: Text('暂无成长记录'))
                              : ListView.builder(
                                  itemCount: _growthRecords.length,
                                  itemBuilder: (context, index) {
                                    final record = _growthRecords[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        title: Text('日期: ${record['record_date']}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('身高: ${record['height']} cm, 体重: ${record['weight']} kg'),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final List<List<double>> data;
  final List<Map<String, double>> standardData;
  final Color color;
  final bool showStandard;

  CurvePainter({required this.data, required this.standardData, required this.color, this.showStandard = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final standardPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 计算数据范围
    double minX = data.map((point) => point[0]).reduce((a, b) => a < b ? a : b);
    double maxX = data.map((point) => point[0]).reduce((a, b) => a > b ? a : b);
    double minY = data.map((point) => point[1]).reduce((a, b) => a < b ? a : b);
    double maxY = data.map((point) => point[1]).reduce((a, b) => a > b ? a : b);

    // 添加一些边距
    minX = 0;
    maxX = maxX + 1;
    minY = minY - 5;
    maxY = maxY + 5;

    // 计算坐标转换
    double xScale = size.width / (maxX - minX);
    double yScale = size.height / (maxY - minY);

    // 绘制标准曲线
    if (showStandard && standardData.isNotEmpty) {
      // 绘制标准范围填充
      Path standardPath = Path();
      for (int i = 0; i < standardData.length; i++) {
        final point = standardData[i];
        double x = (point['age']! - minX) * xScale;
        double y1 = size.height - (point['normalLow']! - minY) * yScale;
        double y2 = size.height - (point['normalHigh']! - minY) * yScale;

        if (i == 0) {
          standardPath.moveTo(x, y1);
        } else {
          standardPath.lineTo(x, y1);
        }
      }
      for (int i = standardData.length - 1; i >= 0; i--) {
        final point = standardData[i];
        double x = (point['age']! - minX) * xScale;
        double y2 = size.height - (point['normalHigh']! - minY) * yScale;
        standardPath.lineTo(x, y2);
      }
      standardPath.close();
      canvas.drawPath(standardPath, fillPaint);

      // 绘制标准范围上下线
      for (int i = 0; i < standardData.length - 1; i++) {
        final point1 = standardData[i];
        final point2 = standardData[i + 1];

        double x1 = (point1['age']! - minX) * xScale;
        double y1 = size.height - (point1['normalLow']! - minY) * yScale;
        double x2 = (point2['age']! - minX) * xScale;
        double y2 = size.height - (point2['normalLow']! - minY) * yScale;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), standardPaint);

        double y3 = size.height - (point1['normalHigh']! - minY) * yScale;
        double y4 = size.height - (point2['normalHigh']! - minY) * yScale;
        canvas.drawLine(Offset(x1, y3), Offset(x2, y4), standardPaint);
      }
    }

    // 绘制实际数据曲线
    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      double x = (data[i][0] - minX) * xScale;
      double y = size.height - (data[i][1] - minY) * yScale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // 绘制数据点
    for (int i = 0; i < data.length; i++) {
      double x = (data[i][0] - minX) * xScale;
      double y = size.height - (data[i][1] - minY) * yScale;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    }

    // 绘制坐标轴
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // X轴
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    // Y轴
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // 绘制X轴标签（整数年龄）
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= maxX.toInt(); i++) {
      double x = (i - minX) * xScale;
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - 5), axisPaint);
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - textPainter.height - 5));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
