import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

class ChildManagementPage extends StatefulWidget {
  const ChildManagementPage({super.key});

  @override
  State<ChildManagementPage> createState() => _ChildManagementPageState();
}

class _ChildManagementPageState extends State<ChildManagementPage> {
  List<dynamic> _children = [];
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

  void _addChild() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddChildPage()),
    ).then((_) => _fetchChildren());
  }

  void _editChild(dynamic child) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditChildPage(child: child)),
    ).then((_) => _fetchChildren());
  }

  void _deleteChild(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除小孩'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确定要删除该小孩吗？'),
            const SizedBox(height: 10),
            Text('删除后所有相关数据也会被删除。', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            Text('删除的小孩：$name', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(id);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
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
      print('请求URL: $serverUrl/api/user/children/$id');

      final response = await dio.delete(
        '$serverUrl/api/user/children/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 200) {
        _fetchChildren();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      } else {
        setState(() {
          _errorMessage = '删除失败';
        });
      }
    } on DioError catch (e) {
      print('Dio错误: ${e.toString()}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
        setState(() {
          _errorMessage = e.response?.data['message'] ?? '删除失败: ${e.response?.statusCode}';
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
          _errorMessage = '删除失败: ${e.message}';
        });
      }
    } catch (e) {
      print('其他错误: ${e.toString()}');
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小孩信息管理'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('还没有添加小孩信息'),
                          ElevatedButton(
                            onPressed: _addChild,
                            child: const Text('添加小孩信息'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        final isMale = child['gender'] == 'male';
                        final primaryColor = isMale ? Colors.blue : Colors.pink;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: child['avatar'] != ''
                                  ? NetworkImage(child['avatar'])
                                  : NetworkImage(
                                      isMale
                                          ? 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy'
                                          : 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl',
                                    ) as ImageProvider,
                            ),
                            title: Text(child['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${isMale ? '男' : '女'}，${child['birth_date']}'),
                                // 计算年龄
                                Text(
                                  _getAgeString(child['birth_date']),
                                  style: TextStyle(color: primaryColor),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _editChild(child),
                                  icon: const Icon(Icons.edit),
                                  color: primaryColor,
                                ),
                                IconButton(
                                  onPressed: () => _deleteChild(child['id'], child['name']),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChild,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getAgeString(String birthDateStr) {
    final birthDate = DateTime.parse(birthDateStr);
    final now = DateTime.now();
    final ageYears = now.difference(birthDate).inDays ~/ 365;
    final ageMonths = (now.difference(birthDate).inDays % 365) ~/ 30;
    return '$ageYears岁$ageMonths个月';
  }
}

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
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
        Navigator.pop(context);
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
    if (gender == 'male') {
      return 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy';
    } else {
      return 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _gender == 'male' ? Colors.blue : Colors.pink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加小孩信息'),
        backgroundColor: primaryColor,
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
                  backgroundColor: primaryColor,
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

class EditChildPage extends StatefulWidget {
  final dynamic child;
  const EditChildPage({super.key, required this.child});

  @override
  State<EditChildPage> createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String _gender = 'male';
  File? _avatarFile;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.child['name'];
    _birthDateController.text = widget.child['birth_date'];
    _gender = widget.child['gender'];
  }

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

  Future<void> _updateChild() async {
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

      String avatar = widget.child['avatar'];
      if (_avatarFile != null) {
        avatar = await _imageToBase64(_avatarFile!);
      }

      final dio = Dio();
      final response = await dio.put(
        '$serverUrl/api/user/children/${widget.child['id']}',
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
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = '更新失败';
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
    if (gender == 'male') {
      return 'https://via.placeholder.com/100/0D8ABC/FFFFFF?text=Boy';
    } else {
      return 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=Girl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _gender == 'male' ? Colors.blue : Colors.pink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑小孩信息'),
        backgroundColor: primaryColor,
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
                      : widget.child['avatar'] != ''
                        ? NetworkImage(widget.child['avatar'])
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
                onPressed: _isLoading ? null : _updateChild,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
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
