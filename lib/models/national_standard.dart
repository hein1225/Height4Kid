
class HeightStandard {
  final int age;
  final double short;    // 矮小
  final double low;      // 偏矮
  final double normal;   // 标准
  final double high;     // 超高

  HeightStandard({
    required this.age,
    required this.short,
    required this.low,
    required this.normal,
    required this.high,
  });
}

class WeightStandard {
  final int age;
  final double thin;     // 偏瘦
  final double normal;   // 标准
  final double heavy;    // 超重
  final double obese;    // 肥胖

  WeightStandard({
    required this.age,
    required this.thin,
    required this.normal,
    required this.heavy,
    required this.obese,
  });
}

class StandardData {
  // 女孩身高标准 - 矮小/偏矮/标准/超高
  static final Map<int, HeightStandard> girlHeightStandards = {
    1: HeightStandard(age: 1, short: 69.7, low: 72.3, normal: 75, high: 77.7),
    2: HeightStandard(age: 2, short: 80.5, low: 83.8, normal: 87.2, high: 90.7),
    3: HeightStandard(age: 3, short: 88.2, low: 91.8, normal: 95.6, high: 99.4),
    4: HeightStandard(age: 4, short: 95.4, low: 99.2, normal: 103.1, high: 107),
    5: HeightStandard(age: 5, short: 101.8, low: 106, normal: 110.2, high: 114.5),
    6: HeightStandard(age: 6, short: 107.6, low: 112, normal: 116.6, high: 121.2),
    7: HeightStandard(age: 7, short: 112.7, low: 117.6, normal: 122.5, high: 127.6),
    8: HeightStandard(age: 8, short: 117.9, low: 123.1, normal: 128.5, high: 133.9),
    9: HeightStandard(age: 9, short: 122.6, low: 128.3, normal: 134.1, high: 139.9),
    10: HeightStandard(age: 10, short: 127.6, low: 133.8, normal: 140.1, high: 146.4),
    11: HeightStandard(age: 11, short: 133.4, low: 140, normal: 146.6, high: 153.3),
    12: HeightStandard(age: 12, short: 135.4, low: 143, normal: 148.9, high: 156.4),
    13: HeightStandard(age: 13, short: 139.5, low: 145.9, normal: 152.4, high: 158.8),
    14: HeightStandard(age: 14, short: 147.2, low: 152.9, normal: 158.6, high: 164.3),
    15: HeightStandard(age: 15, short: 148.8, low: 154.3, normal: 159.8, high: 165.3),
    16: HeightStandard(age: 16, short: 149.2, low: 154.7, normal: 160.1, high: 165.5),
    17: HeightStandard(age: 17, short: 149.5, low: 154.9, normal: 160.3, high: 165.7),
    18: HeightStandard(age: 18, short: 149.8, low: 155.2, normal: 160.6, high: 165.9),
  };

  // 男孩身高标准 - 矮小/偏矮/标准/超高
  static final Map<int, HeightStandard> boyHeightStandards = {
    1: HeightStandard(age: 1, short: 71.2, low: 73.8, normal: 76.5, high: 79.3),
    2: HeightStandard(age: 2, short: 81.6, low: 85.1, normal: 88.5, high: 92.1),
    3: HeightStandard(age: 3, short: 89.3, low: 93, normal: 96.8, high: 100.7),
    4: HeightStandard(age: 4, short: 96.3, low: 100.2, normal: 104.1, high: 108.2),
    5: HeightStandard(age: 5, short: 102.8, low: 107, normal: 111.3, high: 115.7),
    6: HeightStandard(age: 6, short: 108.6, low: 113.1, normal: 117.7, high: 122.4),
    7: HeightStandard(age: 7, short: 114, low: 119, normal: 124, high: 129.1),
    8: HeightStandard(age: 8, short: 119.3, low: 124.6, normal: 130, high: 135.5),
    9: HeightStandard(age: 9, short: 123.9, low: 129.6, normal: 135.4, high: 141.2),
    10: HeightStandard(age: 10, short: 127.9, low: 134, normal: 140.2, high: 146.4),
    11: HeightStandard(age: 11, short: 132.1, low: 138.7, normal: 145.3, high: 152.1),
    12: HeightStandard(age: 12, short: 137.2, low: 144.6, normal: 151.9, high: 159.4),
    13: HeightStandard(age: 13, short: 144, low: 151.8, normal: 159.5, high: 167.3),
    14: HeightStandard(age: 14, short: 151.5, low: 158.7, normal: 165.9, high: 173.1),
    15: HeightStandard(age: 15, short: 156.7, low: 163.3, normal: 169.8, high: 176.3),
    16: HeightStandard(age: 16, short: 159.1, low: 165.4, normal: 171.6, high: 177.8),
    17: HeightStandard(age: 17, short: 160.1, low: 166.3, normal: 172.3, high: 178.4),
    18: HeightStandard(age: 18, short: 160.5, low: 166.6, normal: 172.7, high: 178.7),
  };

  // 女孩体重标准 - 偏瘦/标准/超重/肥胖
  static final Map<int, WeightStandard> girlWeightStandards = {
    1: WeightStandard(age: 1, thin: 8.45, normal: 9.4, heavy: 10.48, obese: 11.73),
    2: WeightStandard(age: 2, thin: 10.7, normal: 11.92, heavy: 13.31, obese: 14.92),
    3: WeightStandard(age: 3, thin: 12.65, normal: 14.13, heavy: 15.83, obese: 17.81),
    4: WeightStandard(age: 4, thin: 14.44, normal: 16.17, heavy: 18.19, obese: 20.54),
    5: WeightStandard(age: 5, thin: 16.2, normal: 18.26, heavy: 20.66, obese: 23.5),
    6: WeightStandard(age: 6, thin: 17.94, normal: 20.37, heavy: 23.27, obese: 26.74),
    7: WeightStandard(age: 7, thin: 19.74, normal: 22.64, heavy: 26.16, obese: 30.45),
    8: WeightStandard(age: 8, thin: 21.75, normal: 25.25, heavy: 29.56, obese: 34.94),
    9: WeightStandard(age: 9, thin: 23.96, normal: 28.19, heavy: 33.51, obese: 40.32),
    10: WeightStandard(age: 10, thin: 26.6, normal: 31.76, heavy: 38.41, obese: 47.15),
    11: WeightStandard(age: 11, thin: 29.99, normal: 36.1, heavy: 44.09, obese: 54.78),
    12: WeightStandard(age: 12, thin: 31.48, normal: 38.6, heavy: 46.7, obese: 58.59),
    13: WeightStandard(age: 13, thin: 34.04, normal: 40.77, heavy: 49.54, obese: 61.22),
    14: WeightStandard(age: 14, thin: 41.18, normal: 47.83, heavy: 56.61, obese: 66.77),
    15: WeightStandard(age: 15, thin: 43.42, normal: 49.82, heavy: 57.72, obese: 67.61),
    16: WeightStandard(age: 16, thin: 44.56, normal: 50.81, heavy: 58.45, obese: 67.93),
    17: WeightStandard(age: 17, thin: 45.01, normal: 51.2, heavy: 58.73, obese: 68.04),
    18: WeightStandard(age: 18, thin: 45.26, normal: 51.41, heavy: 58.88, obese: 68.1),
  };

  // 男孩体重标准 - 偏瘦/标准/超重/肥胖
  static final Map<int, WeightStandard> boyWeightStandards = {
    1: WeightStandard(age: 1, thin: 9, normal: 10.05, heavy: 11.23, obese: 12.54),
    2: WeightStandard(age: 2, thin: 11.24, normal: 12.54, heavy: 14.01, obese: 15.37),
    3: WeightStandard(age: 3, thin: 13.13, normal: 14.65, heavy: 16.39, obese: 18.37),
    4: WeightStandard(age: 4, thin: 14.88, normal: 16.64, heavy: 18.67, obese: 21.01),
    5: WeightStandard(age: 5, thin: 16.87, normal: 18.98, heavy: 21.46, obese: 24.38),
    6: WeightStandard(age: 6, thin: 18.71, normal: 21.26, heavy: 24.32, obese: 28.03),
    7: WeightStandard(age: 7, thin: 20.83, normal: 24.06, heavy: 28.05, obese: 33.08),
    8: WeightStandard(age: 8, thin: 23.23, normal: 27.33, heavy: 32.57, obese: 39.41),
    9: WeightStandard(age: 9, thin: 25.5, normal: 30.46, heavy: 36.92, obese: 45.52),
    10: WeightStandard(age: 10, thin: 27.93, normal: 33.74, heavy: 41.33, obese: 51.38),
    11: WeightStandard(age: 11, thin: 30.95, normal: 37.69, heavy: 46.33, obese: 57.58),
    12: WeightStandard(age: 12, thin: 34.67, normal: 42.49, heavy: 52.31, obese: 64.68),
    13: WeightStandard(age: 13, thin: 39.22, normal: 48.08, heavy: 59.04, obese: 72.6),
    14: WeightStandard(age: 14, thin: 44.08, normal: 53.37, heavy: 64.84, obese: 79.07),
    15: WeightStandard(age: 15, thin: 48, normal: 57.08, heavy: 68.35, obese: 82.45),
    16: WeightStandard(age: 16, thin: 50.62, normal: 59.35, heavy: 70.2, obese: 83.85),
    17: WeightStandard(age: 17, thin: 52.2, normal: 60.68, heavy: 71.2, obese: 84.45),
    18: WeightStandard(age: 18, thin: 53.08, normal: 61.4, heavy: 71.73, obese: 84.72),
  };

  static Map<int, Map<String, double>> getStandards(String gender, bool isHeight) {
    Map<int, dynamic> dataMap;
    if (isHeight) {
      dataMap = gender == 'girl' ? girlHeightStandards : boyHeightStandards;
    } else {
      dataMap = gender == 'girl' ? girlWeightStandards : boyWeightStandards;
    }

    Map<int, Map<String, double>> result = {};
    dataMap.forEach((age, data) {
      if (isHeight) {
        final hs = data as HeightStandard;
        result[age] = {
          'short': hs.short,
          'low': hs.low,
          'normal': hs.normal,
          'high': hs.high,
        };
      } else {
        final ws = data as WeightStandard;
        result[age] = {
          'thin': ws.thin,
          'normal': ws.normal,
          'heavy': ws.heavy,
          'obese': ws.obese,
        };
      }
    });
    return result;
  }

  static double interpolate(double ageInYears, String gender, {bool isHeight = true, String level = 'normal'}) {
    Map<int, dynamic> standards;
    if (isHeight) {
      standards = gender == 'girl' ? girlHeightStandards : boyHeightStandards;
    } else {
      standards = gender == 'girl' ? girlWeightStandards : boyWeightStandards;
    }

    int lowerAge = ageInYears.floor().clamp(1, 18);
    int upperAge = ageInYears.ceil().clamp(1, 18);

    if (lowerAge == upperAge) {
      final standard = standards[lowerAge];
      if (isHeight) {
        return _getHeightValue(standard as HeightStandard, level);
      } else {
        return _getWeightValue(standard as WeightStandard, level);
      }
    }

    final lowerStandard = standards[lowerAge];
    final upperStandard = standards[upperAge];

    double t = (ageInYears - lowerAge) / (upperAge - lowerAge);

    double lowerValue, upperValue;

    if (isHeight) {
      lowerValue = _getHeightValue(lowerStandard as HeightStandard, level);
      upperValue = _getHeightValue(upperStandard as HeightStandard, level);
    } else {
      lowerValue = _getWeightValue(lowerStandard as WeightStandard, level);
      upperValue = _getWeightValue(upperStandard as WeightStandard, level);
    }

    return lowerValue + (upperValue - lowerValue) * t;
  }

  static double _getHeightValue(HeightStandard standard, String level) {
    switch (level) {
      case 'short':
        return standard.short;
      case 'low':
        return standard.low;
      case 'normal':
        return standard.normal;
      case 'high':
        return standard.high;
      default:
        return standard.normal;
    }
  }

  static double _getWeightValue(WeightStandard standard, String level) {
    switch (level) {
      case 'thin':
        return standard.thin;
      case 'normal':
        return standard.normal;
      case 'heavy':
        return standard.heavy;
      case 'obese':
        return standard.obese;
      default:
        return standard.normal;
    }
  }

  // 评估身高状态
  // 身高 ≤ 身高矮小值 → 评估为"矮小"
  // 身高矮小值 < 身高 ≤ 身高偏矮值 → 评估为"偏矮"
  // 身高偏矮值 < 身高 ≤ 身高超高值 → 评估为"标准"
  // 身高 > 身高超高值 → 评估为"超高"
  static String evaluateHeight(double height, double ageInYears, String gender) {
    final standards = gender == 'girl' ? girlHeightStandards : boyHeightStandards;
    
    int age = ageInYears.round().clamp(1, 18);
    final standard = standards[age];
    if (standard == null) return '标准';

    if (height <= standard.short) {
      return '矮小';
    } else if (height <= standard.low) {
      return '偏矮';
    } else if (height <= standard.high) {
      return '标准';
    } else {
      return '超高';
    }
  }

  // 评估体重状态
  // 体重 ≤ 体重偏瘦值 → 评估为"偏瘦"
  // 体重偏瘦值 < 体重 ≤ 体重超重值 → 评估为"标准"
  // 体重超重值 < 体重 ≤ 体重肥胖值 → 评估为"超重"
  // 体重 > 体重肥胖值 → 评估为"肥胖"
  static String evaluateWeight(double weight, double ageInYears, String gender) {
    final standards = gender == 'girl' ? girlWeightStandards : boyWeightStandards;
    
    int age = ageInYears.round().clamp(1, 18);
    final standard = standards[age];
    if (standard == null) return '标准';

    if (weight <= standard.thin) {
      return '偏瘦';
    } else if (weight <= standard.heavy) {
      return '标准';
    } else if (weight <= standard.obese) {
      return '超重';
    } else {
      return '肥胖';
    }
  }
}
