
import 'dart:convert';

class Child {
  final String id;
  final String name;
  final String gender; // 'pink' 或 'blue'
  final String birthday;
  String? avatar;
  double height;
  double weight;

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthday,
    this.avatar,
    this.height = 0,
    this.weight = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthday': birthday,
      'avatar': avatar,
      'height': height,
      'weight': weight,
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String? ?? 'pink',
      birthday: json['birthday'] as String,
      avatar: json['avatar'] as String?,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
    );
  }

  Child copyWith({
    String? id,
    String? name,
    String? gender,
    String? birthday,
    String? avatar,
    double? height,
    double? weight,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      avatar: avatar ?? this.avatar,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  String getAgeGroup() {
    final birth = DateTime.parse(birthday);
    final today = DateTime.now();
    int years = today.year - birth.year;
    int months = today.month - birth.month;
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (years <= 3) return '0-3';
    if (years <= 6) return '4-6';
    if (years <= 12) return '7-12';
    return '13-18';
  }

  String getFormattedAge() {
    final birth = DateTime.parse(birthday);
    final today = DateTime.now();
    int years = today.year - birth.year;
    int months = today.month - birth.month;
    int days = today.day - birth.day;
    
    if (days < 0) {
      months--;
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (years > 0) {
      return '${years}岁${months}月';
    }
    return '${months}月${days}天';
  }

  int getAgeInMonths(String recordDate) {
    final birth = DateTime.parse(birthday);
    final record = DateTime.parse(recordDate);
    int months = (record.year - birth.year) * 12;
    months += record.month - birth.month;
    if (record.day < birth.day) {
      months--;
    }
    return months.clamp(0, 216);
  }
}
