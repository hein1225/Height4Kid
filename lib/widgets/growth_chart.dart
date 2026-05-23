import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/national_standard.dart';

/// 将年龄（岁，支持小数）格式化为 "X岁Y月" 的字符串
String formatAge(double ageInYears) {
  final ageMonths = (ageInYears * 12).round();
  final years = ageMonths ~/ 12;
  final months = ageMonths % 12;
  if (years == 0) {
    return '${months}个月';
  } else if (months == 0) {
    return '${years}岁';
  } else {
    return '${years}岁${months}个月';
  }
}

class GrowthChart extends StatefulWidget {
  final VoidCallback? onTapFullscreen;

  const GrowthChart({super.key, this.onTapFullscreen});

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  double? _selectedAge;
  int? _selectedRecordIndex;
  bool _showAgeInfo = false;
  bool _showStandardCurves = true; // 控制是否显示国标曲线

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
              const SizedBox(height: 8),
              // 国标曲线切换和图例
              Row(
                children: [
                  // 国标曲线显示切换
                  _buildStandardCurveToggle(isHeight, isPink),
                  const Spacer(),
                  // 曲线图例
                  _buildMiniLegend(isHeight),
                ],
              ),
              const SizedBox(height: 8),
              _buildCurrentValue(latestRecord, isHeight, isPink),
              const SizedBox(height: 12),
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
    final gender = isPink ? 'girl' : 'boy';
    final unit = isHeight ? 'cm' : 'kg';

    // 使用插值获取非整数岁的国标数据
    Map<String, double> standardValues = {};
    if (isHeight) {
      for (final level in ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2']) {
        final val = StandardData.interpolate(age.toDouble(), gender, isHeight: true, level: level);
        if (val > 0) {
          standardValues[level] = val;
        }
      }
    } else {
      final val = StandardData.getWeightStandard(age.toDouble(), gender);
      if (val > 0) {
        standardValues['normal'] = val;
      }
    }

    // 查找该年龄是否有历史记录（允许±0.5岁的误差）
    dynamic recordAtAge;
    double? recordAtAgeYears;
    for (final record in records) {
      final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
      final ageYears = ageMonths / 12;
      if ((ageYears - age).abs() < 0.5) {
        recordAtAge = record;
        recordAtAgeYears = ageYears;
        break;
      }
    }

    // 如果没有该年龄的记录，找最接近的记录
    dynamic closestRecord;
    double? closestRecordAgeYears;
    double? closestDistance;
    if (recordAtAge == null) {
      for (final record in records) {
        final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
        final ageYears = ageMonths / 12;
        final distance = (ageYears - age).abs();
        if (closestDistance == null || distance < closestDistance) {
          closestDistance = distance;
          closestRecord = record;
          closestRecordAgeYears = ageYears;
        }
      }
    }

    final displayRecord = recordAtAge ?? closestRecord;
    final displayRecordAge = recordAtAgeYears ?? closestRecordAgeYears ?? age;

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
                formatAge(age),
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
            _buildRecordValueRow(displayRecord, isHeight, isPink, kid),
            const SizedBox(height: 8),
          ],
          // 显示国标参考值
          if (standardValues.isNotEmpty) ...[
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
            // 体重只显示标准值，身高显示所有值
            isHeight 
                ? _buildStandardValues(standardValues, unit)
                : _buildWeightStandardWithBmi(standardValues, unit, displayRecordAge, isPink ? 'girl' : 'boy'),
          ],
        ],
      ),
    );
  }

  // 体重标准值显示（只显示标准值，同时显示BMI评估）
  Widget _buildWeightStandardWithBmi(Map<String, double> standard, String unit, double age, String gender) {
    // 只显示体重均值
    final normalValue = standard['normal'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Text(
                '均值: ${normalValue?.toStringAsFixed(1)}$unit',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Text(
          'BMI评估标准：',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        _buildBmiStandardValues(age, gender),
      ],
    );
  }

  // BMI标准值显示
  Widget _buildBmiStandardValues(double age, String gender) {
    final bmiStandard = StandardData.getBmiStandard(age.toDouble(), gender);
    if (bmiStandard.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _buildBmiTag('低体重', '<${bmiStandard['lowWeight']!.toStringAsFixed(1)}', const Color(0xFFFF6B6B)),
        _buildBmiTag('正常', '${bmiStandard['lowWeight']!.toStringAsFixed(1)}-${bmiStandard['normalMax']!.toStringAsFixed(1)}', const Color(0xFF66BB6A)),
        _buildBmiTag('超重', '${bmiStandard['normalMax']!.toStringAsFixed(1)}-${bmiStandard['obeseMin']!.toStringAsFixed(1)}', const Color(0xFFFFA726)),
        _buildBmiTag('肥胖', '≥${bmiStandard['obeseMin']!.toStringAsFixed(1)}', const Color(0xFF2196F3)),
      ],
    );
  }

  Widget _buildBmiTag(String label, String range, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $range',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecordValueRow(dynamic record, bool isHeight, bool isPink, dynamic kid) {
    final unit = isHeight ? 'cm' : 'kg';
    final value = isHeight ? record.height : record.weight;
    final ageMonths = kid?.getAgeInMonths(record.date) ?? 0;
    final ageYears = ageMonths / 12;

    // 使用StandardData的评估方法，确保与成长状态一致
    final gender = isPink ? 'girl' : 'boy';
    String evalResult;
    if (isHeight) {
      evalResult = StandardData.evaluateHeight(value, ageYears, gender);
    } else {
      // 体重使用BMI评估
      final bmi = record.weight / ((record.height / 100) * (record.height / 100));
      evalResult = StandardData.evaluateBmi(bmi, ageYears, gender);
    }

    final levelLabels = isHeight
        ? {'矮小': '矮小', '偏矮': '偏矮', '正常': '正常', '偏高': '偏高', '超高': '超高'}
        : {'低体重': '低体重', '正常': '正常', '超重': '超重', '肥胖': '肥胖'};

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
        ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.formBorder),
            ),
            child: Text(
              levelLabels[evalResult] ?? evalResult,
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
          // 身高国标
          'sdMinus2': '矮小',
          'sdMinus1': '偏矮',
          'median': '正常',
          'sdPlus1': '偏高',
          'sdPlus2': '超高',
          // 体重国标
          'thin': '偏瘦',
          'normal': '标准',
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
      'sdMinus2': const Color(0xFFFFAB91),
      'sdMinus1': const Color(0xFFFFCC80),
      'median': const Color(0xFFA5D6A7),
      'sdPlus1': const Color(0xFF90CAF9),
      'sdPlus2': const Color(0xFF42A5F5),
      'thin': const Color(0xFFFFAB91),
      'normal': const Color(0xFFA5D6A7),
      'heavy': const Color(0xFFFFCC80),
      'obese': const Color(0xFF90CAF9),
    };

    final entries = standards.entries.toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: entries.map((entry) {
        // 根据中文评估结果匹配对应的key
        String? matchedKey;
        if (highlightLevel != null) {
          levelLabels.forEach((key, value) {
            if (value == highlightLevel) {
              matchedKey = key;
            }
          });
        }
        final isHighlighted = entry.key == matchedKey;
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
    
    // 计算BMI（体重模式下使用）
    final bmi = isHeight 
        ? null 
        : record.weight / ((record.height / 100) * (record.height / 100));
    final bmiEvalResult = bmi != null 
        ? StandardData.evaluateBmi(bmi, ageYears, gender) 
        : null;
    
    // 使用StandardData的评估方法，确保与成长状态一致
    final String evalResult = isHeight
        ? StandardData.evaluateHeight(value, ageYears, gender)
        : '';
    
    final levels = isHeight 
        ? ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2'] 
        : ['normal'];
    final levelLabels = isHeight
        ? {'sdMinus2': '矮小', 'sdMinus1': '偏矮', 'median': '正常', 'sdPlus1': '偏高', 'sdPlus2': '超高'}
        : {'normal': '均值'};

    // 计算每个等级的插值国标值
    Map<String, double> interpolatedStandards = {};
    for (final level in levels) {
      interpolatedStandards[level] = StandardData.interpolate(ageYears, gender, isHeight: isHeight, level: level);
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
          // 记录值 - 身高模式
          if (isHeight) ...[
            Row(
              children: [
                const Text(
                  '身高: ',
                  style: TextStyle(
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
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    evalResult,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // 记录值 - 体重模式：显示体重、BMI、BMI评估
          if (!isHeight) ...[
            Row(
              children: [
                const Text(
                  '体重: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '${record.weight.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'BMI: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  bmi!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.weightColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bmiEvalResult!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.weightColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // 国标对比 - 显示所有等级的插值国标值
          if (interpolatedStandards.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              isHeight ? '该年龄国标参考值：' : '该年龄体重均值：',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            _buildInterpolatedStandardValues(interpolatedStandards, unit, levelLabels, isHeight ? evalResult : ''),
          ],
          // 体重模式下显示BMI评估标准
          if (!isHeight) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'BMI评估标准：',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            _buildBmiStandardValues(ageYears, gender),
          ],
        ],
      ),
    );
  }

  // 国标曲线显示切换按钮
  Widget _buildStandardCurveToggle(bool isHeight, bool isPink) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showStandardCurves = !_showStandardCurves;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _showStandardCurves 
              ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.1)
              : AppTheme.formBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showStandardCurves 
                ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
                : AppTheme.formBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showStandardCurves ? Icons.visibility : Icons.visibility_off,
              size: 14,
              color: _showStandardCurves 
                  ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
                  : AppTheme.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              _showStandardCurves ? '隐藏国标' : '显示国标',
              style: TextStyle(
                fontSize: 11,
                color: _showStandardCurves 
                    ? (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
                    : AppTheme.textLight,
                fontWeight: _showStandardCurves ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 迷你图例 - 非全屏模式显示
  Widget _buildMiniLegend(bool isHeight) {
    final items = isHeight
        ? [
            {'label': '矮小', 'color': const Color(0xFFFFAB91)},
            {'label': '偏矮', 'color': const Color(0xFFFFCC80)},
            {'label': '正常', 'color': const Color(0xFFA5D6A7)},
            {'label': '偏高', 'color': const Color(0xFF90CAF9)},
            {'label': '超高', 'color': const Color(0xFF42A5F5)},
          ]
        : [
            {'label': '均值', 'color': const Color(0xFFA5D6A7)},
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
              ),
            ),
          ],
        );
      }).toList(),
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

    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          // 恢复屏幕方向
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          return true;
        },
        child: Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: isPink ? AppTheme.pinkBg : AppTheme.blueBg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textDark),
                onPressed: () {
                  // 恢复屏幕方向
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                  Navigator.of(context).pop();
                },
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
      ),
    ).then((_) {
      // 确保恢复屏幕方向
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
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

    // 非全屏模式：显示当前年龄前后1岁，从0岁开始
    double currentAge = kid != null ? kid.getAgeInMonths(DateTime.now().toString().substring(0, 10)) / 12 : 3;
    double minAge = (currentAge - 1).clamp(0, 17).toDouble();
    double maxAge = (currentAge + 1).clamp(0, 18).toDouble();

    // 不再取整，保留小数以支持非整数岁的插值显示

    // 动态计算Y轴范围：基于显示年龄范围内的国标值和记录值
    double rangeMinVal = double.infinity;
    double rangeMaxVal = double.negativeInfinity;

    // 考虑该年龄范围内的所有国标值（使用插值）
    final gender = isPink ? 'girl' : 'boy';
    double step = 0.1;
    for (double age = minAge; age <= maxAge; age += step) {
      if (isHeight) {
        // 身高：检查所有等级
        for (final level in ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2']) {
          final val = StandardData.interpolate(age, gender, isHeight: true, level: level);
          if (val > 0) {
            if (val < rangeMinVal) rangeMinVal = val;
            if (val > rangeMaxVal) rangeMaxVal = val;
          }
        }
      } else {
        // 体重：检查均值
        final val = StandardData.getWeightStandard(age, gender);
        if (val > 0) {
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
      // 动态计算Y轴范围，不限制最小值，只限制最大值防止过大
      minVal = (rangeMinVal - range * 0.1).clamp(0.0, double.infinity);
      maxVal = (rangeMaxVal + range * 0.1).clamp(0.0, isHeight ? 200.0 : 100.0);
    } else {
      // 没有数据时使用默认值
      if (isHeight) {
        minVal = 40;
        maxVal = 180;
      } else {
        minVal = 0;
        maxVal = 20;
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
                showStandardCurves: _showStandardCurves,
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
    final gender = isPink ? 'girl' : 'boy';
    
    // 找到最接近点击位置的有效年龄
    double? closestAge;
    double? closestAgeDistance;
    
    // 获取所有有国标数据的月龄点
    final standards = StandardData.getStandards(gender, isHeight);
    final availableMonths = standards.keys.where((m) => m >= minAge * 12 && m <= maxAge * 12).toList()..sort();
    
    // 遍历所有有国标数据的月龄点
    for (final month in availableMonths) {
      final age = month / 12.0;
      final x = paddingLeft + ((age - minAge) / (maxAge - minAge)) * drawWidth;
      final distance = (tapX - x).abs();
      if (closestAgeDistance == null || distance < closestAgeDistance) {
        closestAgeDistance = distance;
        closestAge = age;
      }
    }
    
    // 如果最近的有效年龄点在范围内，选中它
    if (closestAge != null && closestAgeDistance != null && closestAgeDistance < 25) {
      setState(() {
        _selectedAge = closestAge!;
        _selectedRecordIndex = null;
        _showAgeInfo = true;
      });
      return;
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
  final double? selectedAge;
  final int? selectedRecordIndex;
  final bool showAgeInfo;
  final bool showStandardCurves;

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
    this.showStandardCurves = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.only(left: 40, top: 20, right: 20, bottom: 30);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // 绘制网格线和标签
    _drawGrid(canvas, padding, chartWidth, chartHeight, minVal, maxVal, size);

    // 绘制国标曲线（根据用户选择）
    if (showStandardCurves) {
      _drawStandardCurves(canvas, padding, chartWidth, chartHeight, minVal, maxVal);
    }

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
    final colors = isHeight
        ? [
            const Color(0xFFFFAB91),  // sdMinus2 - 矮小
            const Color(0xFFFFCC80),  // sdMinus1 - 偏矮
            const Color(0xFFA5D6A7),  // median - 正常
            const Color(0xFF90CAF9),  // sdPlus1 - 偏高
            const Color(0xFF42A5F5),  // sdPlus2 - 超高
          ]
        : [
            const Color(0xFFA5D6A7),  // normal - 均值（体重只显示均值）
          ];

    final gender = isPink ? 'girl' : 'boy';

    // 使用更小的步进来绘制平滑曲线
    final step = 0.05;  // 每0.05岁（约0.6个月）一个点，更精细
    final startAge = minAge;
    final endAge = maxAge;

    // 身高显示所有等级，体重只显示正常值
    final levels = isHeight
        ? ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2']
        : ['normal'];

    for (int j = 0; j < levels.length; j++) {
      final paint = Paint()
        ..color = colors[j]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      bool firstPoint = true;

      for (double age = startAge; age <= endAge; age += step) {
        double val;
        if (isHeight) {
          val = StandardData.interpolate(age, gender, isHeight: true, level: levels[j]);
        } else {
          val = StandardData.getWeightStandard(age, gender);
        }

        // 跳过无效值
        if (val <= 0) continue;

        final x = padding.left + ((age - minAge) / (maxAge - minAge)) * chartWidth;
        
        // 限制Y坐标在图表范围内，防止曲线超出坐标轴
        double normalizedY = ((val - minVal) / (maxVal - minVal));
        normalizedY = normalizedY.clamp(0.0, 1.0);
        final y = padding.top + chartHeight - normalizedY * chartHeight;

        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
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
        
        // 限制Y坐标在图表范围内
        double normalizedY = (((isHeight ? record.height : record.weight) - minVal) / (maxVal - minVal));
        normalizedY = normalizedY.clamp(0.0, 1.0);
        final y = padding.top + chartHeight - normalizedY * chartHeight;
        
        points.add(Offset(x, y));
      }
    }

    if (points.isEmpty) return;

    // 绘制路径 - 使用半透明颜色
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
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

    // 绘制渐变填充 - 更透明
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.02)],
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

    // 绘制数据点 - 纯色、半透明、无边框
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedRecordIndex == i;
      final pointPaint = Paint()
        ..color = isSelected ? AppTheme.highlightPoint : color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], isSelected ? 6 : 3, pointPaint);

      // 选中时的外圈
      if (isSelected) {
        final outerPaint = Paint()
          ..color = AppTheme.highlightPoint.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], 14, outerPaint);
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
  double? _selectedAge;
  int? _selectedRecordIndex;

  @override
  Widget build(BuildContext context) {
    final color = widget.isHeight
        ? (widget.isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary)
        : AppTheme.weightColor;

    final standards = StandardData.getStandards(widget.isPink ? 'girl' : 'boy', widget.isHeight);

    // 全屏模式：显示0-18岁所有曲线
    const minAge = 0.0;
    const maxAge = 18.0;

    // 计算Y轴范围 - 基于所有年龄的国标值
    // standards 的键是月份（0-216），需要遍历所有月份
    double rangeMinVal = double.infinity;
    double rangeMaxVal = double.negativeInfinity;

    for (int month = 0; month <= 216; month++) {
      if (standards.containsKey(month)) {
        for (final val in standards[month]!.values) {
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
    // 动态计算Y轴范围，不限制最小值，只限制最大值防止过大
    final minVal = widget.isHeight
        ? (rangeMinVal - range * 0.05).clamp(0.0, double.infinity)
        : (rangeMinVal - range * 0.05).clamp(0.0, double.infinity);
    final maxVal = widget.isHeight
        ? (rangeMaxVal + range * 0.05).clamp(0.0, 200.0)
        : (rangeMaxVal + range * 0.05).clamp(0.0, 100.0);

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
            {'label': '正常', 'color': const Color(0xFFA5D6A7)},
            {'label': '偏高', 'color': const Color(0xFF90CAF9)},
            {'label': '超高', 'color': const Color(0xFF42A5F5)},
          ]
        : [
            {'label': '均值', 'color': const Color(0xFFA5D6A7)},
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
      // 点击在图表区域外，清除选择
      setState(() {
        _selectedAge = null;
        _selectedRecordIndex = null;
      });
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
        // 如果点击的是已选中的点，则取消选中
        if (_selectedRecordIndex == closestIndex) {
          setState(() {
            _selectedRecordIndex = null;
          });
        } else {
          setState(() {
            _selectedRecordIndex = closestIndex;
            _selectedAge = null;
          });
        }
        return;
      }
    }

    // 检查是否点击在X轴标签附近（支持非整数岁）
    final tapX = position.dx - paddingLeft;
    final gender = widget.isPink ? 'girl' : 'boy';
    
    // 找到最接近点击位置的有效年龄
    double? closestAge;
    double? closestAgeDistance;
    
    // 获取所有有国标数据的月龄点
    final standards = StandardData.getStandards(gender, widget.isHeight);
    final availableMonths = standards.keys.where((m) => m >= minAge * 12 && m <= maxAge * 12).toList()..sort();
    
    // 遍历所有有国标数据的月龄点
    for (final month in availableMonths) {
      final age = month / 12.0;
      final x = paddingLeft + ((age - minAge) / (maxAge - minAge)) * drawWidth;
      final distance = (tapX - x).abs();
      if (closestAgeDistance == null || distance < closestAgeDistance) {
        closestAgeDistance = distance;
        closestAge = age;
      }
    }
    
    // 如果最近的有效年龄点在范围内，选中它
    if (closestAge != null && closestAgeDistance != null && closestAgeDistance < 30) {
      // 如果点击的是已选中的年龄，则取消选中
      if (_selectedAge == closestAge) {
        setState(() {
          _selectedAge = null;
        });
      } else {
        setState(() {
          _selectedAge = closestAge;
          _selectedRecordIndex = null;
        });
      }
      return;
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
    // 使用StandardData的评估方法，确保与成长状态一致
    final String evalResult;
    if (widget.isHeight) {
      evalResult = StandardData.evaluateHeight(value, ageYears, gender);
    } else {
      // 体重使用BMI评估
      final bmi = record.weight / ((record.height / 100) * (record.height / 100));
      evalResult = StandardData.evaluateBmi(bmi, ageYears, gender);
    }
    
    final levels = widget.isHeight
        ? ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2']
        : ['normal'];
    final levelLabels = widget.isHeight
        ? {'sdMinus2': '矮小', 'sdMinus1': '偏矮', 'median': '正常', 'sdPlus1': '偏高', 'sdPlus2': '超高'}
        : {'normal': '均值'};

    Map<String, double> interpolatedStandards = {};
    for (final level in levels) {
      interpolatedStandards[level] = StandardData.interpolate(ageYears, gender, isHeight: widget.isHeight, level: level);
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
            '${widget.isHeight ? '身高' : '体重'}: ${value.toStringAsFixed(1)}$unit ($evalResult)',
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
            '该年龄(${formatAge(ageYears)})国标参考值：',
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
                // 根据中文评估结果匹配对应的key
                String? matchedKey;
                levelLabels.forEach((key, value) {
                  if (value == evalResult) {
                    matchedKey = key;
                  }
                });
                final isHighlighted = entry.key == matchedKey;
                final colors = {
                  'sdMinus2': const Color(0xFFFFAB91),
                  'sdMinus1': const Color(0xFFFFCC80),
                  'median': const Color(0xFFA5D6A7),
                  'sdPlus1': const Color(0xFF90CAF9),
                  'sdPlus2': const Color(0xFF42A5F5),
                  'thin': const Color(0xFFFFAB91),
                  'normal': const Color(0xFFA5D6A7),
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
    final gender = widget.isPink ? 'girl' : 'boy';
    final unit = widget.isHeight ? 'cm' : 'kg';

    // 使用插值获取非整数岁的国标数据（与非全屏模式保持一致）
    Map<String, double> standardValues = {};
    if (widget.isHeight) {
      for (final level in ['sdMinus2', 'sdMinus1', 'median', 'sdPlus1', 'sdPlus2']) {
        final val = StandardData.interpolate(age, gender, isHeight: true, level: level);
        if (val > 0) {
          standardValues[level] = val;
        }
      }
    } else {
      final val = StandardData.getWeightStandard(age, gender);
      if (val > 0) {
        standardValues['normal'] = val;
      }
    }

    final levelLabels = widget.isHeight
        ? {'sdMinus2': '矮小', 'sdMinus1': '偏矮', 'median': '正常', 'sdPlus1': '偏高', 'sdPlus2': '超高'}
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
                '${formatAge(age)} 国标参考值',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (standardValues.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: standardValues.entries.map((entry) {
                final colors = {
                  'sdMinus2': const Color(0xFFFFAB91),
                  'sdMinus1': const Color(0xFFFFCC80),
                  'median': const Color(0xFFA5D6A7),
                  'sdPlus1': const Color(0xFF90CAF9),
                  'sdPlus2': const Color(0xFF42A5F5),
                  'thin': const Color(0xFFFFAB91),
                  'normal': const Color(0xFFA5D6A7),
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
