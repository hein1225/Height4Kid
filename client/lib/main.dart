import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'src/pages/ChildManagementPage.dart';
import 'src/pages/GrowthRecordPage.dart';
import 'src/pages/GrowthCurvePage.dart';
import 'src/pages/FeedbackPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '身高成长小助手',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ServerConfigPage(),
    );
  }
}

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final serverUrl = prefs.getString('server_url');
    if (serverUrl != null) {
      _serverUrlController.text = serverUrl;
    }
  }

  Future<void> _saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final serverUrl = _serverUrlController.text.trim();
      if (serverUrl.isEmpty) {
        throw Exception('请输入服务端网址');
      }

      // 确保URL格式正确，添加https://前缀
      String formattedUrl = serverUrl;
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://' + formattedUrl;
      }
      
      // 验证URL格式
      try {
        final uri = Uri.parse(formattedUrl);
        if (uri.host.isEmpty) {
          throw Exception('无效的服务端地址，请输入完整的网址');
        }
      } catch (e) {
        setState(() {
          _errorMessage = '无效的服务端地址，请输入完整的网址';
        });
        return;
      }

      await _saveServerUrl(formattedUrl);

      // 配置Dio实例，添加超时和错误处理
      final dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      // 打印请求信息
      print('请求URL: $formattedUrl/api/login');
      print('请求数据: ${_usernameController.text.trim()}');

      // 尝试连接服务端
      try {
        final response = await dio.post(
          '$formattedUrl/api/login',
          data: {
            'username': _usernameController.text.trim(),
            'password': _passwordController.text.trim(),
          },
        );

        print('响应状态码: ${response.statusCode}');
        print('响应数据: ${response.data}');

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response.data['token']);
          await prefs.setString('user', response.data['user'].toString());
          await prefs.setString('server_url', formattedUrl);

          // 检查是否是第一次登录，判断是否有小孩信息
          final hasChildren = await _checkHasChildren(dio, formattedUrl, response.data['token']);
          if (!hasChildren) {
            // 第一次登录，跳转到添加小孩信息页面
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddChildInfoPage()),
            );
          } else {
            // 已有小孩信息，跳转到主页
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          setState(() {
            _errorMessage = response.data['message'] ?? '登录失败';
          });
        }
      } on DioError catch (e) {
        print('Dio错误: ${e.toString()}');
        if (e.response != null) {
          print('错误响应状态码: ${e.response?.statusCode}');
          print('错误响应数据: ${e.response?.data}');
          setState(() {
            _errorMessage = e.response?.data['message'] ?? '登录失败: ${e.response?.statusCode}';
          });
        } else if (e.type == DioErrorType.connectionTimeout) {
          setState(() {
            _errorMessage = '连接超时，请检查网络连接';
          });
        } else if (e.type == DioErrorType.unknown) {
          // 检查是否是DNS解析错误
          if (e.message?.contains('Failed host lookup') ?? false) {
            setState(() {
              _errorMessage = 'DNS解析错误，请检查网络连接或尝试使用IP地址登录';
            });
          } else {
            setState(() {
              _errorMessage = '网络错误，请检查服务端地址是否正确';
            });
          }
        } else {
          setState(() {
            _errorMessage = '登录失败: ${e.message}';
          });
        }
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

  Future<bool> _checkHasChildren(Dio dio, String serverUrl, String token) async {
    try {
      final response = await dio.get(
        '$serverUrl/api/user/children',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data != null && response.data.length > 0;
    } catch (e) {
      print('检查小孩信息失败: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('身高成长小助手'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '身高成长小助手',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '首次登录，请配置服务端网址',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _serverUrlController,
                decoration: InputDecoration(
                  labelText: '服务端网址',
                  hintText: '例如: http://localhost:8000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddChildInfoPage extends StatefulWidget {
  const AddChildInfoPage({super.key});

  @override
  State<AddChildInfoPage> createState() => _AddChildInfoPageState();
}

class _AddChildInfoPageState extends State<AddChildInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String _gender = 'male';
  File? _avatarFile;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // 压缩图片
      final compressedFile = await _compressImage(File(pickedFile.path));
      setState(() {
        _avatarFile = compressedFile;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final image = img.decodeImage(await file.readAsBytes())!;
    final resized = img.copyResize(image, width: 300);
    final compressedBytes = img.encodeJpg(resized, quality: 70);
    final compressedFile = File('${file.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    return compressedFile;
  }

  Future<String> _imageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _saveChild() async {
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

      String avatar = '';
      if (_avatarFile != null) {
        avatar = await _imageToBase64(_avatarFile!);
      } else {
        // 自动生成卡通头像
        avatar = _generateAvatar(_gender);
      }

      final dio = Dio();
      final response = await dio.post(
        '$serverUrl/api/user/children',
        data: {
          'name': _nameController.text.trim(),
          'birth_date': _birthDateController.text.trim(),
          'gender': _gender,
          'avatar': avatar,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = '添加失败';
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

  String _generateAvatar(String gender) {
    // 使用静态默认头像
    if (gender == 'male') {
      return 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy';
    } else {
      return 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加小孩信息'),
        backgroundColor: _gender == 'male' ? Colors.blue : Colors.pink,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gender == 'male' 
              ? [Colors.blue.shade100, Colors.white]
              : [Colors.pink.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarFile != null 
                      ? FileImage(_avatarFile!)
                      : NetworkImage(_generateAvatar(_gender)) as ImageProvider,
                    child: _avatarFile == null ? null : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('点击上传头像', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '姓名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: '出生年月',
                  hintText: '例如: 2020-01-01',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('性别:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Radio(
                    value: 'male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value.toString();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text('男'),
                  const SizedBox(width: 32),
                  Radio(
                    value: 'female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value.toString();
                      });
                    },
                    activeColor: Colors.pink,
                  ),
                  const Text('女'),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChild,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gender == 'male' ? Colors.blue : Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _children = [];
  int? _selectedChildId;
  dynamic _selectedChild;
  dynamic _latestGrowthRecord;
  String _heightStatus = '';
  String _weightStatus = '';
  bool _isLoading = false;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
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

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        // 处理小孩信息，替换旧的头像URL
        final processedChildren = response.data.map((child) {
          // 如果头像是旧的trae-api URL，使用新的默认头像
          if (child['avatar'] != null && child['avatar'].contains('trae-api-cn.mchost.guru')) {
            return {
              ...child,
              'avatar': _generateAvatar(child['gender'])
            };
          }
          return child;
        }).toList();

        setState(() {
          _children = processedChildren;
          _selectedChildId = _children[0]['id'];
          _selectedChild = _children[0];
        });
        await _fetchLatestGrowthRecord();
      }
    } catch (e) {
      print('获取小孩信息失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLatestGrowthRecord() async {
    if (_selectedChildId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final serverUrl = prefs.getString('server_url');

      if (token == null || serverUrl == null) {
        throw Exception('请先登录');
      }

      final dio = Dio();
      final response = await dio.get(
        '$serverUrl/api/user/growth-records/$_selectedChildId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        setState(() {
          _latestGrowthRecord = response.data[0];
        });
        await _analyzeGrowthStatus();
      }
    } catch (e) {
      print('获取成长记录失败: $e');
    }
  }

  Future<void> _analyzeGrowthStatus() async {
    if (_selectedChild == null || _latestGrowthRecord == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final serverUrl = prefs.getString('server_url');

      if (token == null || serverUrl == null) {
        throw Exception('请先登录');
      }

      // 计算年龄
      final birthDate = DateTime.parse(_selectedChild['birth_date']);
      final recordDate = DateTime.parse(_latestGrowthRecord['record_date']);
      final ageYears = recordDate.difference(birthDate).inDays / 365.25;
      final age = ageYears.toStringAsFixed(1);

      final dio = Dio();
      final response = await dio.post(
        '$serverUrl/api/user/analyze-growth',
        data: {
          'age': '${ageYears.floor()}岁',
          'gender': _selectedChild['gender'],
          'height': _latestGrowthRecord['height'],
          'weight': _latestGrowthRecord['weight'],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _heightStatus = response.data['heightStatus'];
          _weightStatus = response.data['weightStatus'];
        });
      }
    } catch (e) {
      print('分析成长状态失败: $e');
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get('https://api.github.com/repos/hein1225/Height4Kid/releases');
      
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final latestRelease = response.data[0];
        final latestVersion = latestRelease['tag_name'];
        final releaseUrl = latestRelease['html_url'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('最新版本: $latestVersion'),
            action: SnackBarAction(
              label: '查看详情',
              onPressed: () {
                // 这里可以添加打开浏览器的逻辑
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('检查更新失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查更新失败: $e')),
      );
    } finally {
      setState(() {
        _isCheckingUpdate = false;
      });
    }
  }

  String _getAgeString() {
    if (_selectedChild == null) return '';
    
    final birthDate = DateTime.parse(_selectedChild['birth_date']);
    final now = DateTime.now();
    final ageYears = now.difference(birthDate).inDays ~/ 365;
    final ageMonths = (now.difference(birthDate).inDays % 365) ~/ 30;
    
    return '$ageYears岁$ageMonths个月';
  }

  String _generateAvatar(String gender) {
    // 使用静态默认头像
    if (gender == 'male') {
      return 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy';
    } else {
      return 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl';
    }
  }

  String _getChildImageUrl() {
    if (_selectedChild == null) return '';
    
    final birthDate = DateTime.parse(_selectedChild['birth_date']);
    final now = DateTime.now();
    final ageYears = now.difference(birthDate).inDays / 365.25;
    
    String ageGroup;
    if (ageYears < 1) {
      ageGroup = 'Baby';
    } else if (ageYears < 3) {
      ageGroup = 'Toddler';
    } else if (ageYears < 12) {
      ageGroup = 'Child';
    } else {
      ageGroup = 'Teen';
    }
    
    final gender = _selectedChild['gender'] == 'male' ? 'Boy' : 'Girl';
    final color = _selectedChild['gender'] == 'male' ? '0D8ABC' : 'FF6B6B';
    
    // 使用静态默认图片
    return 'https://via.placeholder.com/400x300/$color/FFFFFF?text=$gender%20$ageGroup';
  }

  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份与还原'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('备份数据'),
              subtitle: const Text('将数据下载到本地'),
              onTap: () {
                Navigator.pop(context);
                _backupData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('还原数据'),
              subtitle: const Text('从本地上传备份数据'),
              onTap: () {
                Navigator.pop(context);
                _restoreData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData() async {
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
        final children = response.data;
        final backupData = {
          'children': children,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // 这里应该实现文件下载功能，将backupData保存到本地
        // 由于Flutter的文件操作需要额外的权限和处理，这里简化处理
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份功能开发中')),
        );
      }
    } catch (e) {
      print('备份失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份失败: $e')),
      );
    }
  }

  Future<void> _restoreData() async {
    try {
      // 这里应该实现文件选择和上传功能
      // 由于Flutter的文件操作需要额外的权限和处理，这里简化处理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('还原功能开发中')),
      );
    } catch (e) {
      print('还原失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('还原失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _selectedChild != null && _selectedChild['gender'] == 'male';
    final primaryColor = isMale ? Colors.blue : Colors.pink;
    final secondaryColor = isMale ? Colors.green : Colors.yellow;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedChild != null ? _selectedChild['name'] : '身高成长小助手'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update),
            onPressed: _isCheckingUpdate ? null : _checkUpdate,
            tooltip: '检查更新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('还没有添加小孩信息'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddChildInfoPage()),
                          ).then((_) => _fetchChildren());
                        },
                        child: const Text('添加小孩信息'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 第一部分：小孩信息和切换
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor.shade50, Colors.white],
                        ),
                      ),
                      child: Row(
                        children: [
                          // 头像
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(_generateAvatar(_selectedChild['gender'])) as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          // 小孩信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedChild != null ? _selectedChild['name'] : '',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getAgeString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // 切换小孩
                          DropdownButton<int>(
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
                                _selectedChild = _children.firstWhere((child) => child['id'] == value);
                              });
                              _fetchLatestGrowthRecord();
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // 第二部分：成长状态（全屏显示）
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryColor.shade100, secondaryColor.shade100],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 小孩全身图片
                              Expanded(
                                flex: 2,
                                child: _selectedChild != null
                                    ? Image.network(
                                        _getChildImageUrl(),
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      )
                                    : const Placeholder(),
                              ),
                              const SizedBox(height: 20),
                              // 身高体重和评估结果
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('最近记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    _latestGrowthRecord != null
                                        ? Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      const Text('身高', style: TextStyle(fontSize: 16)),
                                                      Text('${_latestGrowthRecord['height']} cm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                                      Text(_heightStatus, style: TextStyle(color: primaryColor)),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text('体重', style: TextStyle(fontSize: 16)),
                                                      Text('${_latestGrowthRecord['weight']} kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                                      Text(_weightStatus, style: TextStyle(color: primaryColor)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : const Text('暂无成长记录', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 第三部分：分类导航
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          // 成长信息记录
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GrowthRecordPage()),
                              ).then((_) => _fetchLatestGrowthRecord());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_calendar, size: 40, color: primaryColor),
                                  const SizedBox(height: 8),
                                  const Text('成长记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          // 成长曲线
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GrowthCurvePage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.show_chart, size: 40, color: primaryColor),
                                  const SizedBox(height: 8),
                                  const Text('成长曲线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          // 问题反馈
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FeedbackPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.feedback, size: 40, color: primaryColor),
                                  const SizedBox(height: 8),
                                  const Text('问题反馈', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          // 备份与还原
                          GestureDetector(
                            onTap: () {
                              _showBackupRestoreDialog();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.backup, size: 40, color: primaryColor),
                                  const SizedBox(height: 8),
                                  const Text('备份与还原', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}