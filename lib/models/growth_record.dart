
import 'dart:convert';

class GrowthRecord {
  final String id;
  final String childId;
  final String date;
  final double height;
  final double weight;
  final String? note;

  GrowthRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.height,
    required this.weight,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date,
      'height': height,
      'weight': weight,
      'note': note,
    };
  }

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: json['date'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }

  GrowthRecord copyWith({
    String? id,
    String? childId,
    String? date,
    double? height,
    double? weight,
    String? note,
  }) {
    return GrowthRecord(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      note: note ?? this.note,
    );
  }
}
