
class HeightStandard {
  final int age; // 月龄（0-216）
  final double sdMinus2;   // -2SD (矮小)
  final double sdMinus1;   // -1SD (偏矮)
  final double median;     // 中位数
  final double sdPlus1;    // +1SD (偏高)
  final double sdPlus2;    // +2SD (超高)

  HeightStandard({
    required this.age,
    required this.sdMinus2,
    required this.sdMinus1,
    required this.median,
    required this.sdPlus1,
    required this.sdPlus2,
  });
}

class WeightStandard {
  final int age;  // 月龄（0-216）
  final double normal;   // 均值

  WeightStandard({
    required this.age,
    required this.normal,
  });
}

class BmiStandard {
  final int age; // 月龄（0-216）
  final double lowWeight;  // 低体重上限
  final double normalMax;  // 正常上限
  final double obeseMin;   // 肥胖下限

  BmiStandard({
    required this.age,
    required this.lowWeight,
    required this.normalMax,
    required this.obeseMin,
  });
}

class StandardData {
  // ========== 女孩身高标准 - 按月龄索引（0-216个月）==========
  // 0-11个月：每月一个数据点
  // 1-6岁：每3个月一个数据点（12, 15, 18, 21, 24...）
  // 7-18岁：每年一个数据点（84, 96, 108...）
  static final Map<int, HeightStandard> girlHeightStandards = {
    // 0-11个月（每月）
    0: HeightStandard(age: 0, sdMinus2: 46.6, sdMinus1: 48.4, median: 50.3, sdPlus1: 52.2, sdPlus2: 54.1),
    1: HeightStandard(age: 1, sdMinus2: 50.1, sdMinus1: 52.1, median: 54.1, sdPlus1: 56.1, sdPlus2: 58.1),
    2: HeightStandard(age: 2, sdMinus2: 53.5, sdMinus1: 55.6, median: 57.7, sdPlus1: 59.8, sdPlus2: 61.9),
    3: HeightStandard(age: 3, sdMinus2: 56.4, sdMinus1: 58.6, median: 60.8, sdPlus1: 62.9, sdPlus2: 65.1),
    4: HeightStandard(age: 4, sdMinus2: 58.8, sdMinus1: 61.0, median: 63.3, sdPlus1: 65.5, sdPlus2: 67.7),
    5: HeightStandard(age: 5, sdMinus2: 60.7, sdMinus1: 63.0, median: 65.3, sdPlus1: 67.6, sdPlus2: 69.9),
    6: HeightStandard(age: 6, sdMinus2: 62.4, sdMinus1: 64.7, median: 67.1, sdPlus1: 69.4, sdPlus2: 71.7),
    7: HeightStandard(age: 7, sdMinus2: 63.9, sdMinus1: 66.3, median: 68.7, sdPlus1: 71.0, sdPlus2: 73.4),
    8: HeightStandard(age: 8, sdMinus2: 65.3, sdMinus1: 67.7, median: 70.1, sdPlus1: 72.5, sdPlus2: 75.0),
    9: HeightStandard(age: 9, sdMinus2: 66.5, sdMinus1: 69.0, median: 71.5, sdPlus1: 73.9, sdPlus2: 76.4),
    10: HeightStandard(age: 10, sdMinus2: 67.8, sdMinus1: 70.3, median: 72.8, sdPlus1: 75.3, sdPlus2: 77.8),
    11: HeightStandard(age: 11, sdMinus2: 68.9, sdMinus1: 71.5, median: 74.0, sdPlus1: 76.6, sdPlus2: 79.1),
    // 1-6岁：每3个月一个数据点
    12: HeightStandard(age: 12, sdMinus2: 70.1, sdMinus1: 72.6, median: 75.2, sdPlus1: 77.8, sdPlus2: 80.4),
    15: HeightStandard(age: 15, sdMinus2: 73.2, sdMinus1: 75.9, median: 78.6, sdPlus1: 81.4, sdPlus2: 84.1),
    18: HeightStandard(age: 18, sdMinus2: 76.2, sdMinus1: 79.0, median: 81.9, sdPlus1: 84.7, sdPlus2: 87.5),
    21: HeightStandard(age: 21, sdMinus2: 79.0, sdMinus1: 81.9, median: 84.9, sdPlus1: 87.8, sdPlus2: 90.8),
    24: HeightStandard(age: 24, sdMinus2: 80.8, sdMinus1: 83.9, median: 87.0, sdPlus1: 90.1, sdPlus2: 93.1),
    27: HeightStandard(age: 27, sdMinus2: 83.2, sdMinus1: 86.4, median: 89.5, sdPlus1: 92.7, sdPlus2: 95.9),
    30: HeightStandard(age: 30, sdMinus2: 85.3, sdMinus1: 88.6, median: 91.9, sdPlus1: 95.2, sdPlus2: 98.5),
    33: HeightStandard(age: 33, sdMinus2: 87.3, sdMinus1: 90.7, median: 94.1, sdPlus1: 97.5, sdPlus2: 100.9),
    36: HeightStandard(age: 36, sdMinus2: 89.3, sdMinus1: 92.7, median: 96.2, sdPlus1: 99.7, sdPlus2: 103.2),
    39: HeightStandard(age: 39, sdMinus2: 91.1, sdMinus1: 94.6, median: 98.2, sdPlus1: 101.8, sdPlus2: 105.3),
    42: HeightStandard(age: 42, sdMinus2: 92.8, sdMinus1: 96.4, median: 100.1, sdPlus1: 103.7, sdPlus2: 107.4),
    45: HeightStandard(age: 45, sdMinus2: 94.4, sdMinus1: 98.2, median: 101.9, sdPlus1: 105.6, sdPlus2: 109.4),
    48: HeightStandard(age: 48, sdMinus2: 96.0, sdMinus1: 99.8, median: 103.7, sdPlus1: 107.5, sdPlus2: 111.3),
    51: HeightStandard(age: 51, sdMinus2: 97.6, sdMinus1: 101.5, median: 105.4, sdPlus1: 109.3, sdPlus2: 113.2),
    54: HeightStandard(age: 54, sdMinus2: 99.2, sdMinus1: 103.2, median: 107.2, sdPlus1: 111.2, sdPlus2: 115.2),
    57: HeightStandard(age: 57, sdMinus2: 100.8, sdMinus1: 104.9, median: 109.0, sdPlus1: 113.1, sdPlus2: 117.2),
    60: HeightStandard(age: 60, sdMinus2: 102.5, sdMinus1: 106.6, median: 110.8, sdPlus1: 115.0, sdPlus2: 119.1),
    63: HeightStandard(age: 63, sdMinus2: 104.1, sdMinus1: 108.3, median: 112.6, sdPlus1: 116.8, sdPlus2: 121.1),
    66: HeightStandard(age: 66, sdMinus2: 105.6, sdMinus1: 109.9, median: 114.3, sdPlus1: 118.6, sdPlus2: 123.0),
    69: HeightStandard(age: 69, sdMinus2: 107.1, sdMinus1: 111.5, median: 115.9, sdPlus1: 120.4, sdPlus2: 124.8),
    72: HeightStandard(age: 72, sdMinus2: 108.5, sdMinus1: 113.0, median: 117.5, sdPlus1: 122.0, sdPlus2: 126.5),
    75: HeightStandard(age: 75, sdMinus2: 109.9, sdMinus1: 114.5, median: 119.1, sdPlus1: 123.7, sdPlus2: 128.2),
    78: HeightStandard(age: 78, sdMinus2: 111.3, sdMinus1: 115.9, median: 120.6, sdPlus1: 125.3, sdPlus2: 129.9),
    81: HeightStandard(age: 81, sdMinus2: 112.0, sdMinus1: 117.3, median: 122.1, sdPlus1: 126.8, sdPlus2: 131.6),
    // 7-18岁：每年一个数据点
    84: HeightStandard(age: 84, sdMinus2: 112.3, sdMinus1: 118.2, median: 124.1, sdPlus1: 130.1, sdPlus2: 136.0),
    96: HeightStandard(age: 96, sdMinus2: 116.8, sdMinus1: 123.1, median: 129.3, sdPlus1: 135.6, sdPlus2: 141.8),
    108: HeightStandard(age: 108, sdMinus2: 121.3, sdMinus1: 128.1, median: 134.9, sdPlus1: 141.7, sdPlus2: 148.5),
    120: HeightStandard(age: 120, sdMinus2: 126.4, sdMinus1: 133.8, median: 141.2, sdPlus1: 148.6, sdPlus2: 156.0),
    132: HeightStandard(age: 132, sdMinus2: 132.1, sdMinus1: 139.7, median: 147.4, sdPlus1: 155.0, sdPlus2: 162.6),
    144: HeightStandard(age: 144, sdMinus2: 138.1, sdMinus1: 145.3, median: 152.4, sdPlus1: 159.6, sdPlus2: 166.7),
    156: HeightStandard(age: 156, sdMinus2: 143.8, sdMinus1: 149.9, median: 156.1, sdPlus1: 162.2, sdPlus2: 168.4),
    168: HeightStandard(age: 168, sdMinus2: 146.2, sdMinus1: 152.0, median: 157.8, sdPlus1: 163.6, sdPlus2: 169.4),
    180: HeightStandard(age: 180, sdMinus2: 147.0, sdMinus1: 152.7, median: 158.5, sdPlus1: 164.2, sdPlus2: 169.9),
    192: HeightStandard(age: 192, sdMinus2: 147.6, sdMinus1: 153.3, median: 158.9, sdPlus1: 164.6, sdPlus2: 170.3),
    204: HeightStandard(age: 204, sdMinus2: 147.8, sdMinus1: 153.5, median: 159.2, sdPlus1: 164.9, sdPlus2: 170.5),
    216: HeightStandard(age: 216, sdMinus2: 148.5, sdMinus1: 154.3, median: 160.0, sdPlus1: 165.7, sdPlus2: 171.5),
  };

  // ========== 男孩身高标准 - 按月龄索引（0-216个月）==========
  static final Map<int, HeightStandard> boyHeightStandards = {
    // 0-11个月（每月）
    0: HeightStandard(age: 0, sdMinus2: 47.3, sdMinus1: 49.2, median: 51.2, sdPlus1: 53.1, sdPlus2: 55.0),
    1: HeightStandard(age: 1, sdMinus2: 51.1, sdMinus1: 53.1, median: 55.1, sdPlus1: 57.2, sdPlus2: 59.2),
    2: HeightStandard(age: 2, sdMinus2: 54.7, sdMinus1: 56.8, median: 59.0, sdPlus1: 61.1, sdPlus2: 63.2),
    3: HeightStandard(age: 3, sdMinus2: 57.8, sdMinus1: 60.0, median: 62.2, sdPlus1: 64.4, sdPlus2: 66.6),
    4: HeightStandard(age: 4, sdMinus2: 60.3, sdMinus1: 62.5, median: 64.8, sdPlus1: 67.1, sdPlus2: 69.4),
    5: HeightStandard(age: 5, sdMinus2: 62.3, sdMinus1: 64.6, median: 66.9, sdPlus1: 69.3, sdPlus2: 71.6),
    6: HeightStandard(age: 6, sdMinus2: 64.0, sdMinus1: 66.3, median: 68.7, sdPlus1: 71.1, sdPlus2: 73.5),
    7: HeightStandard(age: 7, sdMinus2: 65.4, sdMinus1: 67.9, median: 70.3, sdPlus1: 72.7, sdPlus2: 75.1),
    8: HeightStandard(age: 8, sdMinus2: 66.8, sdMinus1: 69.3, median: 71.7, sdPlus1: 74.2, sdPlus2: 76.7),
    9: HeightStandard(age: 9, sdMinus2: 68.0, sdMinus1: 70.5, median: 73.1, sdPlus1: 75.6, sdPlus2: 78.1),
    10: HeightStandard(age: 10, sdMinus2: 69.2, sdMinus1: 71.8, median: 74.3, sdPlus1: 76.9, sdPlus2: 79.4),
    11: HeightStandard(age: 11, sdMinus2: 70.3, sdMinus1: 72.9, median: 75.5, sdPlus1: 78.1, sdPlus2: 80.7),
    // 1-6岁：每3个月一个数据点
    12: HeightStandard(age: 12, sdMinus2: 71.4, sdMinus1: 74.1, median: 76.7, sdPlus1: 79.3, sdPlus2: 81.9),
    15: HeightStandard(age: 15, sdMinus2: 74.5, sdMinus1: 77.2, median: 80.0, sdPlus1: 82.7, sdPlus2: 85.5),
    18: HeightStandard(age: 18, sdMinus2: 77.4, sdMinus1: 80.2, median: 83.1, sdPlus1: 86.0, sdPlus2: 88.8),
    21: HeightStandard(age: 21, sdMinus2: 80.1, sdMinus1: 83.1, median: 86.1, sdPlus1: 89.1, sdPlus2: 92.0),
    24: HeightStandard(age: 24, sdMinus2: 82.0, sdMinus1: 85.1, median: 88.2, sdPlus1: 91.3, sdPlus2: 94.4),
    27: HeightStandard(age: 27, sdMinus2: 84.4, sdMinus1: 87.6, median: 90.8, sdPlus1: 94.0, sdPlus2: 97.2),
    30: HeightStandard(age: 30, sdMinus2: 86.6, sdMinus1: 89.9, median: 93.2, sdPlus1: 96.5, sdPlus2: 99.8),
    33: HeightStandard(age: 33, sdMinus2: 88.6, sdMinus1: 92.0, median: 95.4, sdPlus1: 98.8, sdPlus2: 102.2),
    36: HeightStandard(age: 36, sdMinus2: 90.5, sdMinus1: 94.0, median: 97.5, sdPlus1: 101.0, sdPlus2: 104.5),
    39: HeightStandard(age: 39, sdMinus2: 92.2, sdMinus1: 95.9, median: 99.5, sdPlus1: 103.1, sdPlus2: 106.7),
    42: HeightStandard(age: 42, sdMinus2: 93.9, sdMinus1: 97.6, median: 101.3, sdPlus1: 105.0, sdPlus2: 108.7),
    45: HeightStandard(age: 45, sdMinus2: 95.6, sdMinus1: 99.4, median: 103.1, sdPlus1: 106.9, sdPlus2: 110.7),
    48: HeightStandard(age: 48, sdMinus2: 97.2, sdMinus1: 101.0, median: 104.9, sdPlus1: 108.8, sdPlus2: 112.6),
    51: HeightStandard(age: 51, sdMinus2: 98.8, sdMinus1: 102.7, median: 106.6, sdPlus1: 110.6, sdPlus2: 114.5),
    54: HeightStandard(age: 54, sdMinus2: 100.3, sdMinus1: 104.4, median: 108.4, sdPlus1: 112.4, sdPlus2: 116.5),
    57: HeightStandard(age: 57, sdMinus2: 102.0, sdMinus1: 106.1, median: 110.2, sdPlus1: 114.3, sdPlus2: 118.4),
    60: HeightStandard(age: 60, sdMinus2: 103.6, sdMinus1: 107.8, median: 112.0, sdPlus1: 116.2, sdPlus2: 120.4),
    63: HeightStandard(age: 63, sdMinus2: 105.2, sdMinus1: 109.5, median: 113.7, sdPlus1: 118.0, sdPlus2: 122.3),
    66: HeightStandard(age: 66, sdMinus2: 106.7, sdMinus1: 111.1, median: 115.5, sdPlus1: 119.8, sdPlus2: 124.2),
    69: HeightStandard(age: 69, sdMinus2: 108.2, sdMinus1: 112.7, median: 117.1, sdPlus1: 121.6, sdPlus2: 126.1),
    72: HeightStandard(age: 72, sdMinus2: 109.7, sdMinus1: 114.3, median: 118.8, sdPlus1: 123.3, sdPlus2: 127.9),
    75: HeightStandard(age: 75, sdMinus2: 111.2, sdMinus1: 115.8, median: 120.4, sdPlus1: 125.0, sdPlus2: 129.7),
    78: HeightStandard(age: 78, sdMinus2: 112.6, sdMinus1: 117.3, median: 122.0, sdPlus1: 126.7, sdPlus2: 131.4),
    81: HeightStandard(age: 81, sdMinus2: 113.0, sdMinus1: 118.7, median: 123.5, sdPlus1: 128.3, sdPlus2: 133.1),
    // 7-18岁：每年一个数据点
    84: HeightStandard(age: 84, sdMinus2: 113.5, sdMinus1: 119.5, median: 125.5, sdPlus1: 131.5, sdPlus2: 137.5),
    96: HeightStandard(age: 96, sdMinus2: 118.4, sdMinus1: 124.5, median: 130.7, sdPlus1: 136.9, sdPlus2: 143.1),
    108: HeightStandard(age: 108, sdMinus2: 122.7, sdMinus1: 129.3, median: 135.8, sdPlus1: 142.4, sdPlus2: 148.9),
    120: HeightStandard(age: 120, sdMinus2: 126.8, sdMinus1: 133.8, median: 140.8, sdPlus1: 147.8, sdPlus2: 154.7),
    132: HeightStandard(age: 132, sdMinus2: 130.4, sdMinus1: 138.2, median: 146.0, sdPlus1: 153.8, sdPlus2: 161.6),
    144: HeightStandard(age: 144, sdMinus2: 134.5, sdMinus1: 143.3, median: 152.2, sdPlus1: 161.0, sdPlus2: 169.9),
    156: HeightStandard(age: 156, sdMinus2: 143.0, sdMinus1: 151.6, median: 160.2, sdPlus1: 168.8, sdPlus2: 177.4),
    168: HeightStandard(age: 168, sdMinus2: 150.2, sdMinus1: 157.9, median: 165.6, sdPlus1: 173.3, sdPlus2: 181.1),
    180: HeightStandard(age: 180, sdMinus2: 155.3, sdMinus1: 162.1, median: 169.0, sdPlus1: 175.9, sdPlus2: 182.8),
    192: HeightStandard(age: 192, sdMinus2: 157.7, sdMinus1: 164.2, median: 170.6, sdPlus1: 177.0, sdPlus2: 183.4),
    204: HeightStandard(age: 204, sdMinus2: 158.8, sdMinus1: 165.1, median: 171.4, sdPlus1: 177.7, sdPlus2: 184.0),
    216: HeightStandard(age: 216, sdMinus2: 158.8, sdMinus1: 165.1, median: 171.4, sdPlus1: 177.7, sdPlus2: 184.0),
  };

  // ========== 女孩体重标准 - 按月龄索引（0-216个月）==========
  // 0-12月：每月一个数据点
  // 1-6岁：每3个月一个数据点
  // 7-18岁：每年一个数据点
  static final Map<int, WeightStandard> girlWeightStandards = {
    // 0-12月龄（每月）
    0: WeightStandard(age: 0, normal: 3.16),
    1: WeightStandard(age: 1, normal: 4.16),
    2: WeightStandard(age: 2, normal: 5.18),
    3: WeightStandard(age: 3, normal: 6.01),
    4: WeightStandard(age: 4, normal: 6.63),
    5: WeightStandard(age: 5, normal: 7.12),
    6: WeightStandard(age: 6, normal: 7.56),
    7: WeightStandard(age: 7, normal: 7.93),
    8: WeightStandard(age: 8, normal: 8.21),
    9: WeightStandard(age: 9, normal: 8.46),
    10: WeightStandard(age: 10, normal: 8.72),
    11: WeightStandard(age: 11, normal: 8.95),
    12: WeightStandard(age: 12, normal: 9.16),
    // 1-6岁：每3个月一个数据点
    15: WeightStandard(age: 15, normal: 9.76),
    18: WeightStandard(age: 18, normal: 10.40),
    21: WeightStandard(age: 21, normal: 11.03),
    24: WeightStandard(age: 24, normal: 11.58),
    27: WeightStandard(age: 27, normal: 12.18),
    30: WeightStandard(age: 30, normal: 12.71),
    33: WeightStandard(age: 33, normal: 13.24),
    36: WeightStandard(age: 36, normal: 13.74),
    39: WeightStandard(age: 39, normal: 14.27),
    42: WeightStandard(age: 42, normal: 14.83),
    45: WeightStandard(age: 45, normal: 15.26),
    48: WeightStandard(age: 48, normal: 15.75),
    51: WeightStandard(age: 51, normal: 16.27),
    54: WeightStandard(age: 54, normal: 16.78),
    57: WeightStandard(age: 57, normal: 17.35),
    60: WeightStandard(age: 60, normal: 17.92),
    63: WeightStandard(age: 63, normal: 18.45),
    66: WeightStandard(age: 66, normal: 19.07),
    69: WeightStandard(age: 69, normal: 19.61),
    72: WeightStandard(age: 72, normal: 20.16),
    75: WeightStandard(age: 75, normal: 20.71),
    78: WeightStandard(age: 78, normal: 21.23),
    81: WeightStandard(age: 81, normal: 21.84),
    // 7-18岁：每年一个数据点
    84: WeightStandard(age: 84, normal: 23.56),
    96: WeightStandard(age: 96, normal: 26.16),
    108: WeightStandard(age: 108, normal: 29.30),
    120: WeightStandard(age: 120, normal: 33.00),
    132: WeightStandard(age: 132, normal: 37.26),
    144: WeightStandard(age: 144, normal: 40.65),
    156: WeightStandard(age: 156, normal: 44.47),
    168: WeightStandard(age: 168, normal: 46.69),
    180: WeightStandard(age: 180, normal: 48.49),
    192: WeightStandard(age: 192, normal: 49.49),
    204: WeightStandard(age: 204, normal: 50.82),
    216: WeightStandard(age: 216, normal: 51.71),
  };

  // ========== 男孩体重标准 - 按月龄索引（0-216个月）==========
  static final Map<int, WeightStandard> boyWeightStandards = {
    // 0-12月龄（每月）
    0: WeightStandard(age: 0, normal: 3.33),
    1: WeightStandard(age: 1, normal: 4.43),
    2: WeightStandard(age: 2, normal: 5.60),
    3: WeightStandard(age: 3, normal: 6.52),
    4: WeightStandard(age: 4, normal: 7.20),
    5: WeightStandard(age: 5, normal: 7.72),
    6: WeightStandard(age: 6, normal: 8.17),
    7: WeightStandard(age: 7, normal: 8.53),
    8: WeightStandard(age: 8, normal: 8.82),
    9: WeightStandard(age: 9, normal: 9.11),
    10: WeightStandard(age: 10, normal: 9.36),
    11: WeightStandard(age: 11, normal: 9.58),
    12: WeightStandard(age: 12, normal: 9.80),
    // 1-6岁：每3个月一个数据点
    15: WeightStandard(age: 15, normal: 10.40),
    18: WeightStandard(age: 18, normal: 10.98),
    21: WeightStandard(age: 21, normal: 11.60),
    24: WeightStandard(age: 24, normal: 12.17),
    27: WeightStandard(age: 27, normal: 12.78),
    30: WeightStandard(age: 30, normal: 13.29),
    33: WeightStandard(age: 33, normal: 13.83),
    36: WeightStandard(age: 36, normal: 14.40),
    39: WeightStandard(age: 39, normal: 14.90),
    42: WeightStandard(age: 42, normal: 15.34),
    45: WeightStandard(age: 45, normal: 15.89),
    48: WeightStandard(age: 48, normal: 16.40),
    51: WeightStandard(age: 51, normal: 16.93),
    54: WeightStandard(age: 54, normal: 17.51),
    57: WeightStandard(age: 57, normal: 18.03),
    60: WeightStandard(age: 60, normal: 18.69),
    63: WeightStandard(age: 63, normal: 19.20),
    66: WeightStandard(age: 66, normal: 19.88),
    69: WeightStandard(age: 69, normal: 20.50),
    72: WeightStandard(age: 72, normal: 21.17),
    75: WeightStandard(age: 75, normal: 21.74),
    78: WeightStandard(age: 78, normal: 22.40),
    81: WeightStandard(age: 81, normal: 22.95),
    // 7-18岁：每年一个数据点
    84: WeightStandard(age: 84, normal: 24.89),
    96: WeightStandard(age: 96, normal: 27.42),
    108: WeightStandard(age: 108, normal: 30.71),
    120: WeightStandard(age: 120, normal: 34.00),
    132: WeightStandard(age: 132, normal: 38.16),
    144: WeightStandard(age: 144, normal: 42.28),
    156: WeightStandard(age: 156, normal: 48.25),
    168: WeightStandard(age: 168, normal: 52.38),
    180: WeightStandard(age: 180, normal: 55.12),
    192: WeightStandard(age: 192, normal: 57.77),
    204: WeightStandard(age: 204, normal: 59.49),
    216: WeightStandard(age: 216, normal: 60.37),
  };

  // ========== 女孩BMI标准 - 按月龄索引（0-216个月）==========
  static final Map<int, BmiStandard> girlBmiStandards = {
    // 0-11个月（每月）
    0: BmiStandard(age: 0, lowWeight: 10.8, normalMax: 14.1, obeseMin: 15.4),
    1: BmiStandard(age: 1, lowWeight: 12.5, normalMax: 15.8, obeseMin: 17.3),
    2: BmiStandard(age: 2, lowWeight: 13.6, normalMax: 17.4, obeseMin: 19.1),
    3: BmiStandard(age: 3, lowWeight: 14.2, normalMax: 18.2, obeseMin: 20.0),
    4: BmiStandard(age: 4, lowWeight: 14.5, normalMax: 18.5, obeseMin: 20.5),
    5: BmiStandard(age: 5, lowWeight: 14.6, normalMax: 18.7, obeseMin: 20.7),
    6: BmiStandard(age: 6, lowWeight: 14.7, normalMax: 18.8, obeseMin: 20.8),
    7: BmiStandard(age: 7, lowWeight: 14.7, normalMax: 18.8, obeseMin: 20.7),
    8: BmiStandard(age: 8, lowWeight: 14.6, normalMax: 18.7, obeseMin: 20.6),
    9: BmiStandard(age: 9, lowWeight: 14.5, normalMax: 18.5, obeseMin: 20.4),
    10: BmiStandard(age: 10, lowWeight: 14.5, normalMax: 18.3, obeseMin: 20.2),
    11: BmiStandard(age: 11, lowWeight: 14.4, normalMax: 18.2, obeseMin: 20.0),
    // 1-2岁：每月一个数据点
    12: BmiStandard(age: 12, lowWeight: 14.3, normalMax: 18.0, obeseMin: 19.8),
    13: BmiStandard(age: 13, lowWeight: 14.2, normalMax: 17.8, obeseMin: 19.6),
    14: BmiStandard(age: 14, lowWeight: 14.1, normalMax: 17.7, obeseMin: 19.4),
    15: BmiStandard(age: 15, lowWeight: 14.0, normalMax: 17.5, obeseMin: 19.2),
    16: BmiStandard(age: 16, lowWeight: 13.9, normalMax: 17.4, obeseMin: 19.1),
    17: BmiStandard(age: 17, lowWeight: 13.8, normalMax: 17.3, obeseMin: 18.9),
    18: BmiStandard(age: 18, lowWeight: 13.7, normalMax: 17.2, obeseMin: 18.8),
    19: BmiStandard(age: 19, lowWeight: 13.7, normalMax: 17.1, obeseMin: 18.7),
    20: BmiStandard(age: 20, lowWeight: 13.6, normalMax: 17.0, obeseMin: 18.6),
    21: BmiStandard(age: 21, lowWeight: 13.6, normalMax: 16.9, obeseMin: 18.5),
    22: BmiStandard(age: 22, lowWeight: 13.5, normalMax: 16.8, obeseMin: 18.4),
    23: BmiStandard(age: 23, lowWeight: 13.4, normalMax: 16.7, obeseMin: 18.3),
    // 2-6岁：每3个月一个数据点
    24: BmiStandard(age: 24, lowWeight: 13.6, normalMax: 16.9, obeseMin: 18.6),
    27: BmiStandard(age: 27, lowWeight: 13.5, normalMax: 16.8, obeseMin: 18.4),
    30: BmiStandard(age: 30, lowWeight: 13.4, normalMax: 16.6, obeseMin: 18.2),
    33: BmiStandard(age: 33, lowWeight: 13.3, normalMax: 16.5, obeseMin: 18.1),
    36: BmiStandard(age: 36, lowWeight: 13.2, normalMax: 16.4, obeseMin: 18.1),
    39: BmiStandard(age: 39, lowWeight: 13.1, normalMax: 16.4, obeseMin: 18.0),
    42: BmiStandard(age: 42, lowWeight: 13.1, normalMax: 16.4, obeseMin: 18.0),
    45: BmiStandard(age: 45, lowWeight: 13.0, normalMax: 16.3, obeseMin: 18.0),
    48: BmiStandard(age: 48, lowWeight: 12.9, normalMax: 16.3, obeseMin: 18.0),
    51: BmiStandard(age: 51, lowWeight: 12.9, normalMax: 16.3, obeseMin: 18.0),
    54: BmiStandard(age: 54, lowWeight: 12.8, normalMax: 16.3, obeseMin: 18.1),
    57: BmiStandard(age: 57, lowWeight: 12.8, normalMax: 16.3, obeseMin: 18.1),
    60: BmiStandard(age: 60, lowWeight: 12.8, normalMax: 16.3, obeseMin: 18.2),
    63: BmiStandard(age: 63, lowWeight: 12.7, normalMax: 16.3, obeseMin: 18.3),
    66: BmiStandard(age: 66, lowWeight: 12.7, normalMax: 16.4, obeseMin: 18.4),
    69: BmiStandard(age: 69, lowWeight: 12.7, normalMax: 16.4, obeseMin: 18.4),
    72: BmiStandard(age: 72, lowWeight: 12.6, normalMax: 16.5, obeseMin: 18.5),
    75: BmiStandard(age: 75, lowWeight: 12.6, normalMax: 16.5, obeseMin: 18.6),
    78: BmiStandard(age: 78, lowWeight: 12.6, normalMax: 16.5, obeseMin: 18.7),
    81: BmiStandard(age: 81, lowWeight: 12.6, normalMax: 16.6, obeseMin: 18.8),
    // 7-18岁：每年一个数据点
    84: BmiStandard(age: 84, lowWeight: 13.2, normalMax: 17.3, obeseMin: 19.3),
    96: BmiStandard(age: 96, lowWeight: 13.4, normalMax: 17.8, obeseMin: 20.3),
    108: BmiStandard(age: 108, lowWeight: 13.5, normalMax: 18.6, obeseMin: 21.2),
    120: BmiStandard(age: 120, lowWeight: 13.6, normalMax: 19.4, obeseMin: 22.1),
    132: BmiStandard(age: 132, lowWeight: 13.7, normalMax: 20.5, obeseMin: 23.0),
    144: BmiStandard(age: 144, lowWeight: 14.1, normalMax: 20.8, obeseMin: 23.7),
    156: BmiStandard(age: 156, lowWeight: 14.7, normalMax: 21.7, obeseMin: 24.5),
    168: BmiStandard(age: 168, lowWeight: 15.2, normalMax: 22.2, obeseMin: 24.9),
    180: BmiStandard(age: 180, lowWeight: 15.9, normalMax: 22.6, obeseMin: 25.2),
    192: BmiStandard(age: 192, lowWeight: 16.4, normalMax: 22.7, obeseMin: 25.3),
    204: BmiStandard(age: 204, lowWeight: 16.8, normalMax: 23.2, obeseMin: 25.5),
    216: BmiStandard(age: 216, lowWeight: 17.0, normalMax: 23.3, obeseMin: 25.8),
  };

  // ========== 男孩BMI标准 - 按月龄索引（0-216个月）==========
  static final Map<int, BmiStandard> boyBmiStandards = {
    // 0-11个月（每月）
    0: BmiStandard(age: 0, lowWeight: 11.0, normalMax: 14.3, obeseMin: 15.7),
    1: BmiStandard(age: 1, lowWeight: 12.8, normalMax: 16.3, obeseMin: 17.7),
    2: BmiStandard(age: 2, lowWeight: 14.1, normalMax: 18.0, obeseMin: 19.6),
    3: BmiStandard(age: 3, lowWeight: 14.7, normalMax: 18.9, obeseMin: 20.7),
    4: BmiStandard(age: 4, lowWeight: 14.9, normalMax: 19.3, obeseMin: 21.1),
    5: BmiStandard(age: 5, lowWeight: 15.0, normalMax: 19.4, obeseMin: 21.3),
    6: BmiStandard(age: 6, lowWeight: 15.1, normalMax: 19.4, obeseMin: 21.4),
    7: BmiStandard(age: 7, lowWeight: 15.1, normalMax: 19.3, obeseMin: 21.2),
    8: BmiStandard(age: 8, lowWeight: 15.0, normalMax: 19.2, obeseMin: 21.1),
    9: BmiStandard(age: 9, lowWeight: 15.0, normalMax: 19.0, obeseMin: 20.9),
    10: BmiStandard(age: 10, lowWeight: 14.9, normalMax: 18.9, obeseMin: 20.7),
    11: BmiStandard(age: 11, lowWeight: 14.8, normalMax: 18.7, obeseMin: 20.5),
    // 1-2岁：每月一个数据点
    12: BmiStandard(age: 12, lowWeight: 14.7, normalMax: 18.5, obeseMin: 20.3),
    13: BmiStandard(age: 13, lowWeight: 14.6, normalMax: 18.3, obeseMin: 20.1),
    14: BmiStandard(age: 14, lowWeight: 14.5, normalMax: 18.2, obeseMin: 19.9),
    15: BmiStandard(age: 15, lowWeight: 14.4, normalMax: 18.0, obeseMin: 19.7),
    16: BmiStandard(age: 16, lowWeight: 14.3, normalMax: 17.9, obeseMin: 19.6),
    17: BmiStandard(age: 17, lowWeight: 14.2, normalMax: 17.7, obeseMin: 19.4),
    18: BmiStandard(age: 18, lowWeight: 14.1, normalMax: 17.6, obeseMin: 19.3),
    19: BmiStandard(age: 19, lowWeight: 14.0, normalMax: 17.5, obeseMin: 19.2),
    20: BmiStandard(age: 20, lowWeight: 14.0, normalMax: 17.4, obeseMin: 19.1),
    21: BmiStandard(age: 21, lowWeight: 13.9, normalMax: 17.3, obeseMin: 19.0),
    22: BmiStandard(age: 22, lowWeight: 13.8, normalMax: 17.2, obeseMin: 18.9),
    23: BmiStandard(age: 23, lowWeight: 13.8, normalMax: 17.1, obeseMin: 18.8),
    // 2-6岁：每3个月一个数据点
    24: BmiStandard(age: 24, lowWeight: 13.9, normalMax: 17.3, obeseMin: 19.0),
    27: BmiStandard(age: 27, lowWeight: 13.8, normalMax: 17.1, obeseMin: 18.8),
    30: BmiStandard(age: 30, lowWeight: 13.6, normalMax: 16.9, obeseMin: 18.6),
    33: BmiStandard(age: 33, lowWeight: 13.5, normalMax: 16.8, obeseMin: 18.4),
    36: BmiStandard(age: 36, lowWeight: 13.5, normalMax: 16.7, obeseMin: 18.3),
    39: BmiStandard(age: 39, lowWeight: 13.4, normalMax: 16.6, obeseMin: 18.2),
    42: BmiStandard(age: 42, lowWeight: 13.3, normalMax: 16.5, obeseMin: 18.1),
    45: BmiStandard(age: 45, lowWeight: 13.3, normalMax: 16.5, obeseMin: 18.1),
    48: BmiStandard(age: 48, lowWeight: 13.2, normalMax: 16.5, obeseMin: 18.1),
    51: BmiStandard(age: 51, lowWeight: 13.2, normalMax: 16.5, obeseMin: 18.2),
    54: BmiStandard(age: 54, lowWeight: 13.2, normalMax: 16.5, obeseMin: 18.2),
    57: BmiStandard(age: 57, lowWeight: 13.1, normalMax: 16.5, obeseMin: 18.3),
    60: BmiStandard(age: 60, lowWeight: 13.1, normalMax: 16.6, obeseMin: 18.4),
    63: BmiStandard(age: 63, lowWeight: 13.0, normalMax: 16.6, obeseMin: 18.6),
    66: BmiStandard(age: 66, lowWeight: 13.0, normalMax: 16.7, obeseMin: 18.7),
    69: BmiStandard(age: 69, lowWeight: 13.0, normalMax: 16.8, obeseMin: 18.9),
    72: BmiStandard(age: 72, lowWeight: 13.0, normalMax: 16.9, obeseMin: 19.1),
    75: BmiStandard(age: 75, lowWeight: 12.9, normalMax: 17.0, obeseMin: 19.3),
    78: BmiStandard(age: 78, lowWeight: 12.9, normalMax: 17.1, obeseMin: 19.5),
    81: BmiStandard(age: 81, lowWeight: 12.9, normalMax: 17.1, obeseMin: 19.7),
    // 7-18岁：每年一个数据点
    84: BmiStandard(age: 84, lowWeight: 13.4, normalMax: 18.1, obeseMin: 20.4),
    96: BmiStandard(age: 96, lowWeight: 13.6, normalMax: 18.4, obeseMin: 20.5),
    108: BmiStandard(age: 108, lowWeight: 13.8, normalMax: 19.4, obeseMin: 22.2),
    120: BmiStandard(age: 120, lowWeight: 14.1, normalMax: 20.1, obeseMin: 22.7),
    132: BmiStandard(age: 132, lowWeight: 14.3, normalMax: 21.4, obeseMin: 24.2),
    144: BmiStandard(age: 144, lowWeight: 14.6, normalMax: 21.8, obeseMin: 24.6),
    156: BmiStandard(age: 156, lowWeight: 15.4, normalMax: 22.1, obeseMin: 25.0),
    168: BmiStandard(age: 168, lowWeight: 15.6, normalMax: 22.5, obeseMin: 25.3),
    180: BmiStandard(age: 180, lowWeight: 15.7, normalMax: 22.8, obeseMin: 26.1),
    192: BmiStandard(age: 192, lowWeight: 16.4, normalMax: 23.2, obeseMin: 26.4),
    204: BmiStandard(age: 204, lowWeight: 16.7, normalMax: 23.7, obeseMin: 26.6),
    216: BmiStandard(age: 216, lowWeight: 17.2, normalMax: 23.8, obeseMin: 27.4),
  };

  // ========== 通用插值方法 ==========

  /// 获取两个相邻数据点之间的插值
  /// [ageInMonths] 月龄
  /// [standards] 标准数据Map
  /// [getValue] 提取数值的回调函数
  static double _interpolateValue(
    double ageInMonths,
    Map<int, dynamic> standards,
    double Function(dynamic) getValue,
  ) {
    // 获取所有可用的月龄索引并排序
    List<int> availableMonths = standards.keys.toList()..sort();

    // 边界情况：小于最小月龄
    if (ageInMonths <= availableMonths.first) {
      return getValue(standards[availableMonths.first]);
    }

    // 边界情况：大于最大月龄
    if (ageInMonths >= availableMonths.last) {
      return getValue(standards[availableMonths.last]);
    }

    // 找到相邻的两个数据点
    int? lowerMonth;
    int? upperMonth;

    for (int i = 0; i < availableMonths.length - 1; i++) {
      if (ageInMonths >= availableMonths[i] && ageInMonths <= availableMonths[i + 1]) {
        lowerMonth = availableMonths[i];
        upperMonth = availableMonths[i + 1];
        break;
      }
    }

    if (lowerMonth == null || upperMonth == null) {
      return getValue(standards[availableMonths.last]);
    }

    if (lowerMonth == upperMonth) {
      return getValue(standards[lowerMonth]);
    }

    // 线性插值
    double lowerValue = getValue(standards[lowerMonth]);
    double upperValue = getValue(standards[upperMonth]);
    double t = (ageInMonths - lowerMonth) / (upperMonth - lowerMonth);

    return lowerValue + (upperValue - lowerValue) * t;
  }

  // ========== 身高相关方法 ==========

  /// 获取身高标准值（支持月龄插值）
  static double getHeightStandard(double ageInYears, String gender, {String level = 'median'}) {
    double ageInMonths = ageInYears * 12;
    Map<int, dynamic> standards = gender == 'girl' ? girlHeightStandards : boyHeightStandards;

    return _interpolateValue(ageInMonths, standards, (standard) {
      return _getHeightValue(standard as HeightStandard, level);
    });
  }

  static double _getHeightValue(HeightStandard standard, String level) {
    switch (level) {
      case 'sdMinus2':
        return standard.sdMinus2;
      case 'sdMinus1':
        return standard.sdMinus1;
      case 'median':
        return standard.median;
      case 'sdPlus1':
        return standard.sdPlus1;
      case 'sdPlus2':
        return standard.sdPlus2;
      default:
        return standard.median;
    }
  }

  // 评估身高状态 - 基于国标数据（支持月龄插值）
  static String evaluateHeight(double height, double ageInYears, String gender) {
    double ageInMonths = ageInYears * 12;
    Map<int, dynamic> standards = gender == 'girl' ? girlHeightStandards : boyHeightStandards;

    double sdMinus2 = _interpolateValue(ageInMonths, standards, (s) => (s as HeightStandard).sdMinus2);
    double sdMinus1 = _interpolateValue(ageInMonths, standards, (s) => (s as HeightStandard).sdMinus1);
    double sdPlus1 = _interpolateValue(ageInMonths, standards, (s) => (s as HeightStandard).sdPlus1);
    double sdPlus2 = _interpolateValue(ageInMonths, standards, (s) => (s as HeightStandard).sdPlus2);

    if (height < sdMinus2) {
      return '矮小';
    } else if (height < sdMinus1) {
      return '偏矮';
    } else if (height <= sdPlus1) {
      return '正常';
    } else if (height <= sdPlus2) {
      return '偏高';
    } else {
      return '超高';
    }
  }

  // ========== 体重相关方法 ==========

  /// 获取体重标准值（支持月龄插值）
  static double getWeightStandard(double ageInYears, String gender) {
    double ageInMonths = ageInYears * 12;
    Map<int, dynamic> standards = gender == 'girl' ? girlWeightStandards : boyWeightStandards;

    return _interpolateValue(ageInMonths, standards, (standard) {
      return (standard as WeightStandard).normal;
    });
  }

  // ========== BMI相关方法 ==========

  /// 获取BMI标准值（支持月龄插值）
  static Map<String, double> getBmiStandard(double ageInYears, String gender) {
    double ageInMonths = ageInYears * 12;
    Map<int, dynamic> standards = gender == 'girl' ? girlBmiStandards : boyBmiStandards;

    double lowWeight = _interpolateValue(ageInMonths, standards, (s) => (s as BmiStandard).lowWeight);
    double normalMax = _interpolateValue(ageInMonths, standards, (s) => (s as BmiStandard).normalMax);
    double obeseMin = _interpolateValue(ageInMonths, standards, (s) => (s as BmiStandard).obeseMin);

    return {
      'lowWeight': lowWeight,
      'normalMax': normalMax,
      'obeseMin': obeseMin,
    };
  }

  // 评估BMI状态 - 基于国标数据（支持月龄插值）
  static String evaluateBmi(double bmi, double ageInYears, String gender) {
    Map<String, double> standard = getBmiStandard(ageInYears, gender);

    double lowWeight = standard['lowWeight']!;
    double normalMax = standard['normalMax']!;
    double obeseMin = standard['obeseMin']!;

    if (bmi < lowWeight) {
      return '低体重';
    } else if (bmi <= normalMax) {
      return '正常';
    } else if (bmi < obeseMin) {
      return '超重';
    } else {
      return '肥胖';
    }
  }

  // ========== 通用查询方法 ==========

  static Map<int, Map<String, double>> getStandards(String gender, bool isHeight) {
    Map<int, dynamic> dataMap;
    if (isHeight) {
      dataMap = gender == 'girl' ? girlHeightStandards : boyHeightStandards;
    } else {
      dataMap = gender == 'girl' ? girlWeightStandards : boyWeightStandards;
    }

    Map<int, Map<String, double>> result = {};
    dataMap.forEach((index, data) {
      if (isHeight) {
        final hs = data as HeightStandard;
        result[index] = {
          'sdMinus2': hs.sdMinus2,
          'sdMinus1': hs.sdMinus1,
          'median': hs.median,
          'sdPlus1': hs.sdPlus1,
          'sdPlus2': hs.sdPlus2,
        };
      } else {
        final ws = data as WeightStandard;
        result[index] = {
          'normal': ws.normal,
        };
      }
    });
    return result;
  }

  /// 通用插值方法（兼容旧接口）
  static double interpolate(double ageInYears, String gender, {bool isHeight = true, String level = 'median'}) {
    if (isHeight) {
      return getHeightStandard(ageInYears, gender, level: level);
    } else {
      return getWeightStandard(ageInYears, gender);
    }
  }
}
