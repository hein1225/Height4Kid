import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/growth_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  GrowthRecord? _editingRecord;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startEdit(GrowthRecord record) {
    setState(() {
      _editingRecord = record;
      _heightController.text = record.height.toString();
      _weightController.text = record.weight.toString();
      _selectedDate = DateTime.parse(record.date);
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingRecord = null;
      _heightController.clear();
      _weightController.clear();
    });
  }

  void _saveEdit(AppProvider appProvider) {
    if (_editingRecord == null) return;

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效的身高和体重'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    appProvider.updateRecord(
      _editingRecord!.id,
      date: _selectedDate.toIso8601String().substring(0, 10),
      height: height,
      weight: weight,
    );

    setState(() {
      _editingRecord = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('记录已更新'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, GrowthRecord record, AppProvider appProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('确认删除'),
          ],
        ),
        content: Text('确定要删除 ${record.date} 的记录吗？\n\n身高: ${record.height}cm\n体重: ${record.weight}kg'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      appProvider.deleteRecord(record.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('记录已删除'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      cancelText: '取消',
      confirmText: '确定',
      helpText: '选择日期',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
        final records = appProvider.getSortedRecords();

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
                    '成长档案',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            if (_editingRecord != null)
              _buildEditForm(context, appProvider, primaryColor),
            Expanded(
              child: records.isEmpty
                  ? _buildEmptyState(isPink)
                  : _buildRecordList(records, primaryColor, appProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditForm(BuildContext context, AppProvider appProvider, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '编辑记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Date picker
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
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
                    '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
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
          ),
          const SizedBox(height: 12),
          // Height input
          _buildInputField(
            label: '身高 (cm)',
            controller: _heightController,
            hint: '请输入身高',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          // Weight input
          _buildInputField(
            label: '体重 (kg)',
            controller: _weightController,
            hint: '请输入体重',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _cancelEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.formBg,
                      borderRadius: BorderRadius.circular(16),
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
                  onTap: () => _saveEdit(appProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
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
            keyboardType: keyboardType,
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

  Widget _buildEmptyState(bool isPink) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(List<dynamic> records, Color primaryColor, AppProvider appProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isLatest = index == 0;

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
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(
                      record.date,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (isLatest)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          child: const Text(
                            '最新',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      // Edit button
                      GestureDetector(
                        onTap: () => _startEdit(record),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(context, record, appProvider),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDataItem(
                      label: '身高',
                      value: '${record.height}cm',
                      color: primaryColor,
                      icon: Icons.height,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppTheme.formBorder,
                  ),
                  Expanded(
                    child: _buildDataItem(
                      label: '体重',
                      value: '${record.weight}kg',
                      color: AppTheme.weightColor,
                      icon: Icons.monitor_weight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
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
