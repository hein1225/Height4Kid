import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
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
                    '记录成长',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date selector
                    _buildDateSelector(context, primaryColor),
                    const SizedBox(height: 24),
                    // Height input
                    _buildInputField(
                      label: '身高',
                      unit: 'cm',
                      controller: _heightController,
                      primaryColor: primaryColor,
                      icon: Icons.height,
                    ),
                    const SizedBox(height: 20),
                    // Weight input
                    _buildInputField(
                      label: '体重',
                      unit: 'kg',
                      controller: _weightController,
                      primaryColor: AppTheme.weightColor,
                      icon: Icons.monitor_weight,
                    ),
                    const SizedBox(height: 40),
                    // Save button
                    _buildSaveButton(context, appProvider, primaryColor, secondaryColor),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.formBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
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
    );
  }

  Widget _buildInputField({
    required String label,
    required String unit,
    required TextEditingController controller,
    required Color primaryColor,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.formBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请输入$label',
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
              Text(
                unit,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppProvider appProvider,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return GestureDetector(
      onTap: () {
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

        appProvider.addRecord(
          date: _selectedDate.toIso8601String().substring(0, 10),
          height: height,
          weight: weight,
        );

        _heightController.clear();
        _weightController.clear();

        appProvider.setPage('home');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '保存记录',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
