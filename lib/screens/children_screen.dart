import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/child.dart';
import '../utils/image_compressor.dart';
import 'cloud_sync_screen.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  bool _isEditing = false;
  Child? _editingKid;

  final _nameController = TextEditingController();
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  String _gender = 'girl';
  String? _avatarUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startAdd() {
    setState(() {
      _isEditing = true;
      _editingKid = null;
      _nameController.clear();
      _birthDate = DateTime.now().subtract(const Duration(days: 365));
      _gender = 'girl';
      _avatarUrl = null;
    });
  }

  void _startEdit(Child kid) {
    setState(() {
      _isEditing = true;
      _editingKid = kid;
      _nameController.text = kid.name;
      _birthDate = DateTime.parse(kid.birthday);
      _gender = kid.gender;
      _avatarUrl = kid.avatar;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingKid = null;
    });
  }

  // Show triple confirmation dialog for deleting a kid
  Future<void> _showDeleteConfirmation(BuildContext context, Child kid, AppProvider appProvider) async {
    // First confirmation
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('警告'),
          ],
        ),
        content: Text('确定要删除孩子"${kid.name}"吗？\n\n此操作将删除该孩子的所有成长记录，且无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    // Second confirmation
    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('再次确认'),
          ],
        ),
        content: const Text('这是第二次确认。\n\n删除后，所有数据将永久丢失，你真的要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('我确定'),
          ),
        ],
      ),
    );

    if (confirm2 != true) return;

    // Third confirmation - require typing the kid's name
    final confirm3 = await showDialog<bool>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text('最终确认'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('这是最后一次确认。\n\n请输入孩子姓名"${kid.name}"以确认删除：'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '输入孩子姓名',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim() == kid.name) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('输入的姓名不匹配'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('确认删除'),
            ),
          ],
        );
      },
    );

    if (confirm3 == true) {
      appProvider.deleteKid(kid.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除孩子"${kid.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Build avatar image widget - supports both network and base64 images
  Widget _buildAvatarImage(String avatarUrl, {double? size}) {
    if (avatarUrl.startsWith('data:image')) {
      // Base64 image
      final bytes = base64Decode(avatarUrl.split(',')[1]);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else {
      // Network image
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
  }

  void _saveKid(AppProvider appProvider) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入孩子姓名'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_editingKid != null) {
      // Update existing kid
      appProvider.updateKid(
        _editingKid!.copyWith(
          name: _nameController.text,
          birthday: _birthDate.toIso8601String().substring(0, 10),
          gender: _gender,
          avatar: _avatarUrl,
        ),
      );
    } else {
      // Add new kid
      appProvider.addKid(
        name: _nameController.text,
        birthDate: _birthDate.toIso8601String().substring(0, 10),
        gender: _gender,
        avatar: _avatarUrl,
      );
    }

    setState(() {
      _isEditing = false;
      _editingKid = null;
    });
  }

  Future<void> _pickAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // 显示压缩中提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('正在压缩图片...'),
                duration: Duration(seconds: 1),
              ),
            );
          }

          // 压缩图片
          final compressedDataUrl = await ImageCompressor.compressImage(
            file.bytes!,
            isBase64: false,
          );

          if (compressedDataUrl != null) {
            // 获取压缩前后的信息
            final originalInfo = ImageCompressor.getImageInfo(
              'data:image/${file.extension};base64,${base64Encode(file.bytes!)}',
            );
            final compressedInfo = ImageCompressor.getImageInfo(compressedDataUrl);

            setState(() {
              _avatarUrl = compressedDataUrl;
            });

            // 显示压缩结果
            if (mounted && originalInfo != null && compressedInfo != null) {
              final savedKB = (originalInfo['size'] - compressedInfo['size']) ~/ 1024;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '图片已压缩: ${originalInfo['sizeKB']}KB → ${compressedInfo['sizeKB']}KB (节省 $savedKB KB)',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // 压缩失败，使用原图
            final base64String = base64Encode(file.bytes!);
            final dataUrl = 'data:image/${file.extension};base64,$base64String';
            setState(() {
              _avatarUrl = dataUrl;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('图片压缩失败，已使用原图'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
        final secondaryColor = isPink ? AppTheme.pinkSecondary : AppTheme.blueSecondary;

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderButton(
                    icon: Icons.arrow_back_ios,
                    onTap: () => appProvider.setPage('home'),
                  ),
                  const Text(
                    '孩子管理',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    if (_isEditing) _buildKidForm(context, appProvider, primaryColor, secondaryColor),
                    if (_isEditing) const SizedBox(height: 24),
                    _buildKidList(appProvider, primaryColor),
                    if (!_isEditing && appProvider.kids.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      _buildAddKidButton(primaryColor, secondaryColor),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKidForm(
    BuildContext context,
    AppProvider appProvider,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final isEditing = _editingKid != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? '编辑孩子' : '添加孩子',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          // Avatar picker
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: _avatarUrl == null
                      ? LinearGradient(
                          colors: _gender == 'girl'
                              ? [AppTheme.pinkPrimary, AppTheme.pinkSecondary]
                              : [AppTheme.bluePrimary, AppTheme.blueSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _avatarUrl != null
                    ? ClipOval(
                        child: _buildAvatarImage(_avatarUrl!),
                      )
                    : const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '点击上传头像',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLight.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: '姓名',
            controller: _nameController,
            hint: '请输入孩子姓名',
          ),
          const SizedBox(height: 16),
          _buildGenderSelector(primaryColor),
          const SizedBox(height: 16),
          _buildDateSelector(context, primaryColor),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _cancelEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.formBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _saveKid(appProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '保存',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.formBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.formBorder),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: AppTheme.textLight.withValues(alpha: 0.5),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = 'girl'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == 'girl' ? AppTheme.pinkPrimary.withValues(alpha: 0.1) : AppTheme.formBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _gender == 'girl' ? AppTheme.pinkPrimary : AppTheme.formBorder,
                      width: _gender == 'girl' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _gender == 'girl' ? AppTheme.pinkPrimary : AppTheme.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '女孩',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _gender == 'girl' ? AppTheme.pinkPrimary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = 'boy'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == 'boy' ? AppTheme.bluePrimary.withValues(alpha: 0.1) : AppTheme.formBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _gender == 'boy' ? AppTheme.bluePrimary : AppTheme.formBorder,
                      width: _gender == 'boy' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _gender == 'boy' ? AppTheme.bluePrimary : AppTheme.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '男孩',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _gender == 'boy' ? AppTheme.bluePrimary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          cancelText: '取消',
          confirmText: '确定',
          helpText: '选择出生日期',
          fieldLabelText: '出生日期',
          fieldHintText: '年/月/日',
          errorFormatText: '日期格式不正确',
          errorInvalidText: '日期无效',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppTheme.textDark,
                ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _birthDate = picked;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '出生日期',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.formBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.formBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_birthDate.year}年${_birthDate.month}月${_birthDate.day}日',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textLight,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidList(AppProvider appProvider, Color primaryColor) {
    if (appProvider.kids.isEmpty) {
      return _buildEmptyState(primaryColor, appProvider);
    }

    return Column(
      children: appProvider.kids.map((kid) {
        final isSelected = appProvider.currentKidId == kid.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 6),
              ),
            ],
            border: isSelected
                ? Border.all(color: primaryColor, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: kid.avatar == null
                      ? LinearGradient(
                          colors: kid.gender == 'girl'
                              ? [AppTheme.pinkPrimary, AppTheme.pinkSecondary]
                              : [AppTheme.bluePrimary, AppTheme.blueSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: kid.avatar != null
                    ? ClipOval(
                        child: _buildAvatarImage(kid.avatar!, size: 56),
                      )
                    : Center(
                        child: Text(
                          kid.name.isNotEmpty ? kid.name[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kid.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${kid.getFormattedAge()} · ${kid.gender == 'girl' ? '女孩' : '男孩'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch button
              if (!isSelected)
                GestureDetector(
                  onTap: () {
                    appProvider.setCurrentKid(kid.id);
                    appProvider.setPage('home');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '切换',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '当前',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Edit button
              GestureDetector(
                onTap: () => _startEdit(kid),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button with triple confirmation
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context, kid, appProvider),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(Color primaryColor, AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 80,
            color: primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无孩子信息',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加孩子开始记录成长',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 32),
          // 添加孩子按钮
          GestureDetector(
            onTap: _startAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '添加孩子',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 导入数据按钮
          GestureDetector(
            onTap: () => _importData(context, appProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload_file,
                    color: primaryColor.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '导入已有数据',
                    style: TextStyle(
                      color: primaryColor.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 云同步按钮
          GestureDetector(
            onTap: () => _navigateToCloudSync(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_sync,
                    color: primaryColor.withValues(alpha: 0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '设置云同步',
                    style: TextStyle(
                      color: primaryColor.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 添加孩子按钮 - 醒目设计
  Widget _buildAddKidButton(Color primaryColor, Color secondaryColor) {
    return GestureDetector(
      onTap: _startAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '添加孩子',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Import data from backup file
  Future<void> _importData(BuildContext context, AppProvider appProvider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final jsonString = utf8.decode(file.bytes!);
          final success = await appProvider.importData(jsonString);

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('数据导入成功'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('导入失败，请检查文件格式或数据是否过大'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 导航到云同步设置页面
  void _navigateToCloudSync(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CloudSyncScreen(),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}
