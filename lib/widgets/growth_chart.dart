import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/national_standard.dart';

class GrowthChart extends StatefulWidget {
  final VoidCallback? onTapFullscreen;

  const GrowthChart({super.key, this.onTapFullscreen});

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  int? _selectedAge;
  int? _selectedRecordIndex;
  bool _showAgeInfo = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final isHeight = appProvider.currentChartType == 'height';
        final records = appProvider.getSortedRecords();
        final kid = appProvider.currentKid;
        final latestRecord = records.isNotEmpty ? records.first : null;

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabs(context, appProvider, isPink),
              const SizedBox(height: 16),
              _buildCurrentValue(latestRecord, isHeight, isPink),
              const SizedBox(height: 16),
              _buildChart(isHeight, isPink, records, kid),
              if (_selectedAge != null && _showAgeInfo) ...[
                const SizedBox(height: 12),
                _buildAgeInfo(isHeight, isPink, records, kid),
              ],
              if (_selectedRecordIndex != null) ...[
                const SizedBox(height: 12),
                _buildRecordInfo(records, isHeight, isPink, kid),
              ],
            ],
          ),
        );
      },
    );
  }

  // 构建年龄点信息（点击年龄时显示）
  Widget _buildAgeInfo(bool isHeight, bool isPink, List<dynamic> records, dynamic kid) {
    final age = _selectedAge!;
    final standards = StandardData.getStandards(isPink ? 'girl' : 'boy', isHeight);
    final standard = standards[age];
    final unit = isHeight ? 'cm' : 'kg';

    // 查找该年龄是否有历史记录
    dynamic recordAtAge;
    for (final record in records) {
      final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
      final ageYears = ageMonths ~/ 12;
      if (ageYears == age) {
        recordAtAge = record;
        break;
      }
    }

    // 如果没有该年龄的记录，找上一个记录
    dynamic previousRecord;
    if (recordAtAge == null) {
      for (final record in records) {
        final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
        final ageYears = ageMonths ~/ 12;
        if (ageYears < age) {
          previousRecord = record;
          break;
        }
      }
    }

    final displayRecord = recordAtAge ?? previousRecord;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.formBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.formBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$age岁',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              if (recordAtAge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '有记录',
                    style: TextStyle(
                      fontSize: 11,
                      color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else if (displayRecord != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '参考上次记录',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // 如果有记录，显示记录值
          if (displayRecord != null) ...[
            _buildRecordValueRow(displayRecord, isHeight, isPink, kid, standards),
            const SizedBox(height: 8),
          ],
          // 显示国标参考值
          if (standard != null) ...[
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              '国标参考值：',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            _buildStandardValues(standard, unit),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordValueRow(dynamic record, bool isHeight, bool isPink, dynamic kid, Map<int, Map<String, double>> standards) {
    final unit = isHeight ? 'cm' : 'kg';
    final value = isHeight ? record.height : record.weight;
    final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
    final ageYears = ageMonths ~/ 12;
    final standard = standards[ageYears];

    // 找到最接近的国标等级
    String? closestLevel;
    double? closestDiff;
    if (standard != null) {
      for (final entry in standard.entries) {
        final diff = (value - entry.value).abs();
        if (closestDiff == null || diff < closestDiff) {
          closestDiff = diff;
          closestLevel = entry.key;
        }
      }
    }

    final levelLabels = isHeight
        ? {'short': '矮小', 'low': '偏矮', 'normal': '标准', 'high': '超高'}
        : {'thin': '偏瘦', 'normal': '标准', 'heavy': '超重', 'obese': '肥胖'};

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 12,
          color: AppTheme.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          record.date,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isHeight ? '身高: ' : '体重: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
          ),
        ),
        if (closestLevel != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.formBorder),
            ),
            child: Text(
              levelLabels[closestLevel] ?? closestLevel,
              style: TextStyle(
                fontSize: 10,
                color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStandardValues(Map<String, double> standard, String unit) {
    final entries = standard.entries.toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: entries.map((entry) {
        final labels = {
          'short': '矮小',
          'low': '偏矮',
          'normal': '标准',
          'high': '超高',
          'thin': '偏瘦',
          'heavy': '超重',
          'obese': '肥胖',
        };
        final label = labels[entry.key] ?? entry.key;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.formBorder),
          ),
          child: Text(
            '$label: ${entry.value.toStringAsFixed(1)}$unit',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 显示插值后的所有国标值
  Widget _buildInterpolatedStandardValues(Map<String, double> standards, String unit, Map<String, String> levelLabels, String? highlightLevel) {
    final colors = {
      'short': const Color(0xFFFFAB91),
      'low': const Color(0xFFFFCC80),
      'normal': const Color(0xFFA5D6A7),
      'high': const Color(0xFF90CAF9),
      'thin': const Color(0xFFFFAB91),
      'heavy': const Color(0xFFFFCC80),
      'obese': const Color(0xFF90CAF9),
    };

    final entries = standards.entries.toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: entries.map((entry) {
        final isHighlighted = entry.key == highlightLevel;
        final color = colors[entry.key] ?? AppTheme.textLight;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isHighlighted ? color.withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlighted ? color : AppTheme.formBorder,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Text(
            '${levelLabels[entry.key]}: ${entry.value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 11,
              color: isHighlighted ? AppTheme.textDark : AppTheme.textLight,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 点击历史记录点时显示
  Widget _buildRecordInfo(List<dynamic> records, bool isHeight, bool isPink, dynamic kid) {
    final index = _selectedRecordIndex!;
    if (index >= records.length) return const SizedBox.shrink();

    final record = records[index];
    final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
    final ageYears = ageMonths / 12; // 使用精确年龄（含小数）
    final ageYearsInt = ageMonths ~/ 12;
    final ageMonthsRemainder = ageMonths % 12;

    final unit = isHeight ? 'cm' : 'kg';
    final value = isHeight ? record.height : record.weight;

    // 使用插值计算该精确年龄的国标值
    final gender = isPink ? 'girl' : 'boy';
    final levels = isHeight ? ['short', 'low', 'normal', 'high'] : ['thin', 'normal', 'heavy', 'obese'];
    final levelLabels = isHeight
        ? {'short': '矮小', 'low': '偏矮', 'normal': '标准', 'high': '超高'}
        : {'thin': '偏瘦', 'normal': '标准', 'heavy': '超重', 'obese': '肥胖'};

    // 计算每个等级的插值国标值
    Map<String, double> interpolatedStandards = {};
    for (final level in levels) {
      interpolatedStandards[level] = StandardData.interpolate(ageYears, gender, isHeight: isHeight, level: level);
    }

    // 找到最接近的国标等级
    String? closestLevel;
    double? closestDiff;
    for (final entry in interpolatedStandards.entries) {
      final diff = (value - entry.value).abs();
      if (closestDiff == null || diff < closestDiff) {
        closestDiff = diff;
        closestLevel = entry.key;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(
                Icons.history,
                size: 14,
                color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
              ),
              const SizedBox(width: 6),
              Text(
                '历史记录',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 日期和年龄
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: AppTheme.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                record.date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${ageYearsInt}岁${ageMonthsRemainder}月)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 记录值
          Row(
            children: [
              Text(
                isHeight ? '身高: ' : '体重: ',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                ),
              ),
              if (closestLevel != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    levelLabels[closestLevel] ?? closestLevel,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // 国标对比 - 显示所有等级的插值国标值
          if (interpolatedStandards.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              '该年龄国标参考值：',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            _buildInterpolatedStandardValues(interpolatedStandards, unit, levelLabels, closestLevel),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, AppProvider appProvider, bool isPink) {
    final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
    final isHeight = appProvider.currentChartType == 'height';

    return Row(
      children: [
        _ChartTab(
          isActive: isHeight,
          color: primaryColor,
          label: '身高',
          onTap: () {
            appProvider.setChartType('height');
            setState(() {
              _selectedAge = null;
              _selectedRecordIndex = null;
              _showAgeInfo = false;
            });
          },
        ),
        const SizedBox(width: 12),
        _ChartTab(
          isActive: !isHeight,
          color: AppTheme.weightColor,
          label: '体重',
          onTap: () {
            appProvider.setChartType('weight');
            setState(() {
              _selectedAge = null;
              _selectedRecordIndex = null;
              _showAgeInfo = false;
            });
          },
        ),
        const Spacer(),
        // 全屏按钮
        GestureDetector(
          onTap: () {
            _showFullscreenChart(context, appProvider);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.formBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.formBorder),
            ),
            child: const Icon(
              Icons.fullscreen,
              size: 20,
              color: AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }

  // 显示全屏图表对话框
  void _showFullscreenChart(BuildContext context, AppProvider appProvider) {
    final isPink = appProvider.currentTheme == 'pink';
    final isHeight = appProvider.currentChartType == 'height';
    final records = appProvider.getSortedRecords();
    final kid = appProvider.currentKid;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: isPink ? AppTheme.pinkBg : AppTheme.blueBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppTheme.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isHeight ? '身高成长曲线 (1-18岁)' : '体重成长曲线 (1-18岁)',
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _FullscreenChartContent(
                isHeight: isHeight,
                isPink: isPink,
                records: records,
                kid: kid,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentValue(dynamic latestRecord, bool isHeight, bool isPink) {
    final color = isHeight
        ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
        : AppTheme.weightColor;

    final value = latestRecord != null
        ? (isHeight ? '${latestRecord.height}cm' : '${latestRecord.weight}kg')
        : '—';

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(bool isHeight, bool isPink, List<dynamic> records, dynamic kid) {
    final color = isHeight
        ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
        : AppTheme.weightColor;

    final standards = StandardData.getStandards(isPink ? 'girl' : 'boy', isHeight);

    // 非全屏模式：显示当前年龄前后2岁
    double currentAge = kid != null ? kid.getAgeInMonths(DateTime.now().toString().substring(0, 10)) / 12 : 3;
    double minAge = (currentAge - 2).clamp(1, 16).toDouble();
    double maxAge = (currentAge + 2).clamp(1, 18).toDouble();

    // 取整
    minAge = minAge.floor().toDouble();
    maxAge = maxAge.ceil().toDouble();

    // 动态计算Y轴范围：基于显示年龄范围内的国标值和记录值
    double rangeMinVal = double.infinity;
    double rangeMaxVal = double.negativeInfinity;

    // 考虑该年龄范围内的所有国标值
    for (int age = minAge.toInt(); age <= maxAge.toInt(); age++) {
      if (standards.containsKey(age)) {
        for (final val in standards[age]!.values) {
          if (val < rangeMinVal) rangeMinVal = val;
          if (val > rangeMaxVal) rangeMaxVal = val;
        }
      }
    }

    // 考虑该年龄范围内的所有记录值
    if (records.isNotEmpty && kid != null) {
      for (final record in records) {
        final ageMonths = kid.getAgeInMonths(record.date);
        final ageYears = ageMonths / 12;
        if (ageYears >= minAge && ageYears <= maxAge) {
          final val = isHeight ? record.height : record.weight;
          if (val < rangeMinVal) rangeMinVal = val;
          if (val > rangeMaxVal) rangeMaxVal = val;
        }
      }
    }

    // 添加一些边距，使曲线不会贴边
    double minVal, maxVal;
    final range = rangeMaxVal - rangeMinVal;
    if (rangeMinVal != double.infinity && rangeMaxVal != double.negativeInfinity) {
      minVal = (rangeMinVal - range * 0.1).clamp(isHeight ? 40.0 : 5.0, isHeight ? 170.0 : 75.0);
      maxVal = (rangeMaxVal + range * 0.1).clamp(isHeight ? 50.0 : 8.0, isHeight ? 180.0 : 80.0);
    } else {
      // 没有数据时使用默认值
      if (isHeight) {
        minVal = 40;
        maxVal = 180;
      } else {
        minVal = 5;
        maxVal = 80;
      }
    }

    return SizedBox(
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth = constraints.maxWidth;
          final chartHeight = constraints.maxHeight;

          return GestureDetector(
            onTapUp: (details) {
              _handleTap(details.localPosition, isHeight, isPink, records, kid, minAge, maxAge, chartWidth, chartHeight, minVal, maxVal);
            },
            child: CustomPaint(
              painter: _GrowthChartPainter(
                isHeight: isHeight,
                isPink: isPink,
                color: color,
                records: records,
                kid: kid,
                standards: standards,
                minAge: minAge,
                maxAge: maxAge,
                minVal: minVal,
                maxVal: maxVal,
                selectedAge: _selectedAge,
                selectedRecordIndex: _selectedRecordIndex,
                showAgeInfo: _showAgeInfo,
              ),
              size: Size(chartWidth, chartHeight),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset position, bool isHeight, bool isPink, List<dynamic> records,
      dynamic kid, double minAge, double maxAge, double chartWidth, double chartHeight, double minVal, double maxVal) {
    const paddingLeft = 40.0;
    const paddingTop = 20.0;
    const paddingRight = 20.0;
    const paddingBottom = 30.0;
    final drawWidth = chartWidth - paddingLeft - paddingRight;
    final drawHeight = chartHeight - paddingTop - paddingBottom;

    // 检查是否点击在图表区域内
    if (position.dx < paddingLeft || position.dx > chartWidth - paddingRight ||
        position.dy < paddingTop || position.dy > chartHeight - paddingBottom) {
      return;
    }

    // 首先检查是否点击在数据点上（优先级更高）
    if (records.isNotEmpty && kid != null) {
      // 找到最近的数据点
      int? closestIndex;
      double? closestDistance;

      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final ageMonths = kid.getAgeInMonths(record.date);
        final ageYears = ageMonths / 12;

        if (ageYears >= minAge && ageYears <= maxAge) {
          final x = paddingLeft + ((ageYears - minAge) / (maxAge - minAge)) * drawWidth;
          final value = isHeight ? record.height : record.weight;
          final y = paddingTop + drawHeight - ((value - minVal) / (maxVal - minVal)) * drawHeight;

          // 使用欧几里得距离计算
          final dx = position.dx - x;
          final dy = position.dy - y;
          final distance = math.sqrt(dx * dx + dy * dy);

          if (closestDistance == null || distance < closestDistance) {
            closestDistance = distance;
            closestIndex = i;
          }
        }
      }

      // 如果最近的数据点在一定范围内，选中它
      if (closestIndex != null && closestDistance != null && closestDistance < 30) {
        setState(() {
          _selectedRecordIndex = closestIndex;
          _selectedAge = null;
          _showAgeInfo = false;
        });
        return;
      }
    }

    // 计算点击位置对应的年龄
    final tapX = position.dx - paddingLeft;

    // 检查是否点击在X轴标签附近（年龄选择）
    final ageRange = maxAge.toInt() - minAge.toInt();
    int step = 1;
    if (ageRange > 6) step = 2;
    if (ageRange > 12) step = 3;

    for (int age = minAge.toInt(); age <= maxAge.toInt(); age += step) {
      final x = paddingLeft + ((age - minAge) / (maxAge - minAge)) * drawWidth;
      if ((tapX - x).abs() < 25) {
        setState(() {
          _selectedAge = age;
          _selectedRecordIndex = null;
          _showAgeInfo = true;
        });
        return;
      }
    }

    // 点击空白处，清除选择
    setState(() {
      _selectedAge = null;
      _selectedRecordIndex = null;
      _showAgeInfo = false;
    });
  }
}

class _ChartTab extends StatelessWidget {
  final bool isActive;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ChartTab({
    required this.isActive,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.2)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: isActive ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final bool isHeight;
  final bool isPink;
  final Color color;
  final List<dynamic> records;
  final dynamic kid;
  final Map<int, Map<String, double>> standards;
  final double minAge;
  final double maxAge;
  final double minVal;
  final double maxVal;
  final int? selectedAge;
  final int? selectedRecordIndex;
  final bool showAgeInfo;

  _GrowthChartPainter({
    required this.isHeight,
    required this.isPink,
    required this.color,
    required this.records,
    required this.kid,
    required this.standards,
    required this.minAge,
    required this.maxAge,
    required this.minVal,
    required this.maxVal,
    this.selectedAge,
    this.selectedRecordIndex,
    this.showAgeInfo = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.only(left: 40, top: 20, right: 20, bottom: 30);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // 绘制网格线和标签
    _drawGrid(canvas, padding, chartWidth, chartHeight, minVal, maxVal, size);

    // 绘制国标曲线
    _drawStandardCurves(canvas, padding, chartWidth, chartHeight, minVal, maxVal);

    // 绘制用户数据
    _drawUserData(canvas, padding, chartWidth, chartHeight, minVal, maxVal);

    // 绘制X轴标签
    _drawXAxisLabels(canvas, padding, chartWidth, chartHeight, size);

    // 绘制选中标记
    _drawSelection(canvas, padding, chartWidth, chartHeight, minVal, maxVal);
  }

  void _drawGrid(
    Canvas canvas,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minVal,
    double maxVal,
    Size size,
  ) {
    final gridPaint = Paint()
      ..color = AppTheme.chartGrid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 绘制水平网格线和Y轴标签
    for (int i = 0; i <= 5; i++) {
      final y = padding.top + (i / 5) * chartHeight;
      final val = maxVal - (i / 5) * (maxVal - minVal);

      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: val.round().toString(),
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.chartYLabel,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }
  }

  void _drawStandardCurves(
    Canvas canvas,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minVal,
    double maxVal,
  ) {
    final colors = [
      const Color(0xFFFFAB91),
      const Color(0xFFFFCC80),
      const Color(0xFFA5D6A7),
      const Color(0xFF90CAF9),
    ];

    // 只绘制关键年龄的曲线
    final keyAges = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
        .where((age) => age >= minAge && age <= maxAge)
        .toList();

    for (int i = 0; i < keyAges.length - 1; i++) {
      final age1 = keyAges[i];
      final age2 = keyAges[i + 1];

      if (standards.containsKey(age1) && standards.containsKey(age2)) {
        final keys = isHeight
            ? ['short', 'low', 'normal', 'high']
            : ['thin', 'normal', 'heavy', 'obese'];

        for (int j = 0; j < keys.length; j++) {
          final key = keys[j];
          final paint = Paint()
            ..color = colors[j].withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          final val1 = standards[age1]![key]!;
          final val2 = standards[age2]![key]!;

          final x1 = padding.left + ((age1 - minAge) / (maxAge - minAge)) * chartWidth;
          final y1 = padding.top + chartHeight - ((val1 - minVal) / (maxVal - minVal)) * chartHeight;
          final x2 = padding.left + ((age2 - minAge) / (maxAge - minAge)) * chartWidth;
          final y2 = padding.top + chartHeight - ((val2 - minVal) / (maxVal - minVal)) * chartHeight;

          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        }
      }
    }
  }

  void _drawUserData(
    Canvas canvas,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minVal,
    double maxVal,
  ) {
    if (records.isEmpty || kid == null) return;

    final path = Path();
    final areaPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      final ageMonths = kid.getAgeInMonths(record.date);
      final ageYears = ageMonths / 12;

      if (ageYears >= minAge && ageYears <= maxAge) {
        final x = padding.left + ((ageYears - minAge) / (maxAge - minAge)) * chartWidth;
        final y = padding.top + chartHeight - (((isHeight ? record.height : record.weight) - minVal) / (maxVal - minVal)) * chartHeight;
        points.add(Offset(x, y));
      }
    }

    if (points.isEmpty) return;

    // 绘制路径
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    path.moveTo(points.first.dx, points.first.dy);
    areaPath.moveTo(points.first.dx, padding.top + chartHeight);
    areaPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath.lineTo(points.last.dx, padding.top + chartHeight);
    areaPath.close();

    // 绘制渐变填充
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
    );

    final areaPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(
        padding.left,
        padding.top,
        chartWidth,
        chartHeight,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);

    // 绘制数据点
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedRecordIndex == i;
      final pointPaint = Paint()
        ..color = isSelected ? AppTheme.highlightPoint : color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], isSelected ? 10 : 6, pointPaint);

      // 白色边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4 : 3;
      canvas.drawCircle(points[i], isSelected ? 10 : 6, borderPaint);

      // 选中时的外圈
      if (isSelected) {
        final outerPaint = Paint()
          ..color = AppTheme.highlightPoint.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], 16, outerPaint);
      }
    }
  }

  void _drawXAxisLabels(
    Canvas canvas,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    Size size,
  ) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 每1岁一个标签
    final ageRange = maxAge.toInt() - minAge.toInt();
    // 根据范围决定显示间隔，避免重叠
    int step = 1;
    if (ageRange > 6) step = 2;
    if (ageRange > 12) step = 3;

    for (int age = minAge.toInt(); age <= maxAge.toInt(); age += step) {
      final x = padding.left + ((age - minAge) / (maxAge - minAge)) * chartWidth;
      final isSelected = selectedAge == age && showAgeInfo;

      // 选中时的背景
      if (isSelected) {
        final bgPaint = Paint()
          ..color = AppTheme.highlightPoint.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, size.height - 20), 18, bgPaint);
      }

      textPainter.text = TextSpan(
        text: '${age}岁',
        style: TextStyle(
          fontSize: isSelected ? 13 : 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected ? AppTheme.textDark : AppTheme.chartXLabel,
        ),
      );
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 25),
      );
    }
  }

  void _drawSelection(
    Canvas canvas,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
    double minVal,
    double maxVal,
  ) {
    // 绘制选中年龄的垂直线
    if (selectedAge != null && selectedAge! >= minAge && selectedAge! <= maxAge && showAgeInfo) {
      final x = padding.left + ((selectedAge! - minAge) / (maxAge - minAge)) * chartWidth;
      
      final linePaint = Paint()
        ..color = AppTheme.highlightPoint.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(x, padding.top),
        Offset(x, padding.top + chartHeight),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 全屏图表内容组件
class _FullscreenChartContent extends StatefulWidget {
  final bool isHeight;
  final bool isPink;
  final List<dynamic> records;
  final dynamic kid;

  const _FullscreenChartContent({
    required this.isHeight,
    required this.isPink,
    required this.records,
    required this.kid,
  });

  @override
  State<_FullscreenChartContent> createState() => _FullscreenChartContentState();
}

class _FullscreenChartContentState extends State<_FullscreenChartContent> {
  int? _selectedAge;
  int? _selectedRecordIndex;

  @override
  Widget build(BuildContext context) {
    final color = widget.isHeight
        ? (widget.isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
        : AppTheme.weightColor;

    final standards = StandardData.getStandards(widget.isPink ? 'girl' : 'boy', widget.isHeight);

    // 全屏模式：显示1-18岁所有曲线
    const minAge = 1.0;
    const maxAge = 18.0;

    // 计算Y轴范围 - 基于所有年龄的国标值
    double rangeMinVal = double.infinity;
    double rangeMaxVal = double.negativeInfinity;

    for (int age = 1; age <= 18; age++) {
      if (standards.containsKey(age)) {
        for (final val in standards[age]!.values) {
          if (val < rangeMinVal) rangeMinVal = val;
          if (val > rangeMaxVal) rangeMaxVal = val;
        }
      }
    }

    // 考虑所有记录值
    if (widget.records.isNotEmpty && widget.kid != null) {
      for (final record in widget.records) {
        final ageMonths = widget.kid.getAgeInMonths(record.date);
        final ageYears = ageMonths / 12;
        if (ageYears >= minAge && ageYears <= maxAge) {
          final val = widget.isHeight ? record.height : record.weight;
          if (val < rangeMinVal) rangeMinVal = val;
          if (val > rangeMaxVal) rangeMaxVal = val;
        }
      }
    }

    // 添加边距
    final range = rangeMaxVal - rangeMinVal;
    final minVal = widget.isHeight
        ? (rangeMinVal - range * 0.05).clamp(40.0, 170.0)
        : (rangeMinVal - range * 0.05).clamp(5.0, 75.0);
    final maxVal = widget.isHeight
        ? (rangeMaxVal + range * 0.05).clamp(50.0, 180.0)
        : (rangeMaxVal + range * 0.05).clamp(8.0, 80.0);

    return Column(
      children: [
        // 图例
        _buildLegend(widget.isHeight),
        const SizedBox(height: 16),
        // 图表
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  _handleFullscreenTap(
                    details.localPosition,
                    constraints.maxWidth,
                    constraints.maxHeight,
                    minAge,
                    maxAge,
                    minVal,
                    maxVal,
                  );
                },
                child: CustomPaint(
                  painter: _GrowthChartPainter(
                    isHeight: widget.isHeight,
                    isPink: widget.isPink,
                    color: color,
                    records: widget.records,
                    kid: widget.kid,
                    standards: standards,
                    minAge: minAge,
                    maxAge: maxAge,
                    minVal: minVal,
                    maxVal: maxVal,
                    selectedAge: _selectedAge,
                    selectedRecordIndex: _selectedRecordIndex,
                    showAgeInfo: _selectedAge != null,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              );
            },
          ),
        ),
        // 选中信息
        if (_selectedRecordIndex != null) ...[
          const SizedBox(height: 16),
          _buildFullscreenRecordInfo(standards),
        ],
        if (_selectedAge != null && _selectedRecordIndex == null) ...[
          const SizedBox(height: 16),
          _buildFullscreenAgeInfo(standards),
        ],
      ],
    );
  }

  Widget _buildLegend(bool isHeight) {
    final items = isHeight
        ? [
            {'label': '矮小', 'color': const Color(0xFFFFAB91)},
            {'label': '偏矮', 'color': const Color(0xFFFFCC80)},
            {'label': '标准', 'color': const Color(0xFFA5D6A7)},
            {'label': '超高', 'color': const Color(0xFF90CAF9)},
          ]
        : [
            {'label': '偏瘦', 'color': const Color(0xFFFFAB91)},
            {'label': '标准', 'color': const Color(0xFFA5D6A7)},
            {'label': '超重', 'color': const Color(0xFFFFCC80)},
            {'label': '肥胖', 'color': const Color(0xFF90CAF9)},
          ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _handleFullscreenTap(
    Offset position,
    double chartWidth,
    double chartHeight,
    double minAge,
    double maxAge,
    double minVal,
    double maxVal,
  ) {
    const paddingLeft = 50.0;
    const paddingTop = 20.0;
    const paddingRight = 20.0;
    const paddingBottom = 40.0;
    final drawWidth = chartWidth - paddingLeft - paddingRight;
    final drawHeight = chartHeight - paddingTop - paddingBottom;

    // 检查是否点击在图表区域内
    if (position.dx < paddingLeft ||
        position.dx > chartWidth - paddingRight ||
        position.dy < paddingTop ||
        position.dy > chartHeight - paddingBottom) {
      return;
    }

    // 首先检查是否点击在数据点上
    if (widget.records.isNotEmpty && widget.kid != null) {
      int? closestIndex;
      double? closestDistance;

      for (int i = 0; i < widget.records.length; i++) {
        final record = widget.records[i];
        final ageMonths = widget.kid.getAgeInMonths(record.date);
        final ageYears = ageMonths / 12;

        if (ageYears >= minAge && ageYears <= maxAge) {
          final x = paddingLeft + ((ageYears - minAge) / (maxAge - minAge)) * drawWidth;
          final value = widget.isHeight ? record.height : record.weight;
          final y = paddingTop + drawHeight - ((value - minVal) / (maxVal - minVal)) * drawHeight;

          final dx = position.dx - x;
          final dy = position.dy - y;
          final distance = math.sqrt(dx * dx + dy * dy);

          if (closestDistance == null || distance < closestDistance) {
            closestDistance = distance;
            closestIndex = i;
          }
        }
      }

      if (closestIndex != null && closestDistance != null && closestDistance < 30) {
        setState(() {
          _selectedRecordIndex = closestIndex;
          _selectedAge = null;
        });
        return;
      }
    }

    // 检查是否点击在X轴标签附近
    final tapX = position.dx - paddingLeft;
    for (int age = minAge.toInt(); age <= maxAge.toInt(); age++) {
      final x = paddingLeft + ((age - minAge) / (maxAge - minAge)) * drawWidth;
      if ((tapX - x).abs() < 30) {
        setState(() {
          _selectedAge = age;
          _selectedRecordIndex = null;
        });
        return;
      }
    }

    // 点击空白处，清除选择
    setState(() {
      _selectedAge = null;
      _selectedRecordIndex = null;
    });
  }

  Widget _buildFullscreenRecordInfo(Map<int, Map<String, double>> standards) {
    final index = _selectedRecordIndex!;
    if (index >= widget.records.length) return const SizedBox.shrink();

    final record = widget.records[index];
    final ageMonths = widget.kid?.getAgeInMonths(record.date) ?? 0;
    final ageYears = ageMonths / 12;

    final unit = widget.isHeight ? 'cm' : 'kg';
    final value = widget.isHeight ? record.height : record.weight;

    // 使用插值计算国标值
    final gender = widget.isPink ? 'girl' : 'boy';
    final levels = widget.isHeight
        ? ['short', 'low', 'normal', 'high']
        : ['thin', 'normal', 'heavy', 'obese'];
    final levelLabels = widget.isHeight
        ? {'short': '矮小', 'low': '偏矮', 'normal': '标准', 'high': '超高'}
        : {'thin': '偏瘦', 'normal': '标准', 'heavy': '超重', 'obese': '肥胖'};

    Map<String, double> interpolatedStandards = {};
    for (final level in levels) {
      interpolatedStandards[level] = StandardData.interpolate(ageYears, gender, isHeight: widget.isHeight, level: level);
    }

    String? closestLevel;
    double? closestDiff;
    for (final entry in interpolatedStandards.entries) {
      final diff = (value - entry.value).abs();
      if (closestDiff == null || diff < closestDiff) {
        closestDiff = diff;
        closestLevel = entry.key;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: widget.isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '历史记录 - ${record.date}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.isHeight ? '身高' : '体重'}: ${value.toStringAsFixed(1)}$unit (${levelLabels[closestLevel] ?? ''})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '该年龄(${ageYears.toStringAsFixed(1)}岁)国标参考值：',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLight.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: interpolatedStandards.entries.map((entry) {
              final isHighlighted = entry.key == closestLevel;
              final colors = {
                'short': const Color(0xFFFFAB91),
                'low': const Color(0xFFFFCC80),
                'normal': const Color(0xFFA5D6A7),
                'high': const Color(0xFF90CAF9),
                'thin': const Color(0xFFFFAB91),
                'heavy': const Color(0xFFFFCC80),
                'obese': const Color(0xFF90CAF9),
              };
              final color = colors[entry.key] ?? AppTheme.textLight;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted ? color.withValues(alpha: 0.2) : AppTheme.formBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHighlighted ? color : AppTheme.formBorder,
                    width: isHighlighted ? 2 : 1,
                  ),
                ),
                child: Text(
                  '${levelLabels[entry.key]}: ${entry.value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                    color: isHighlighted ? AppTheme.textDark : AppTheme.textLight,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenAgeInfo(Map<int, Map<String, double>> standards) {
    final age = _selectedAge!;
    final standard = standards[age];
    final unit = widget.isHeight ? 'cm' : 'kg';

    final levelLabels = widget.isHeight
        ? {'short': '矮小', 'low': '偏矮', 'normal': '标准', 'high': '超高'}
        : {'thin': '偏瘦', 'normal': '标准', 'heavy': '超重', 'obese': '肥胖'};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$age岁 国标参考值',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (standard != null)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: standard.entries.map((entry) {
                final colors = {
                  'short': const Color(0xFFFFAB91),
                  'low': const Color(0xFFFFCC80),
                  'normal': const Color(0xFFA5D6A7),
                  'high': const Color(0xFF90CAF9),
                  'thin': const Color(0xFFFFAB91),
                  'heavy': const Color(0xFFFFCC80),
                  'obese': const Color(0xFF90CAF9),
                };
                final color = colors[entry.key] ?? AppTheme.textLight;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${levelLabels[entry.key]}: ${entry.value.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
