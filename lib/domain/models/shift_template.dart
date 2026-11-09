import 'dart:ui';

class ShiftTemplate {
  const ShiftTemplate({
    required this.id,
    required this.name,
    required this.baseRate,
    required this.isNightShift,
    required this.colorHex,
  });

  final String id;
  final String name;
  final int baseRate;
  final bool isNightShift;
  final String colorHex;

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  ShiftTemplate copyWith({
    String? id,
    String? name,
    int? baseRate,
    bool? isNightShift,
    String? colorHex,
  }) {
    return ShiftTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      baseRate: baseRate ?? this.baseRate,
      isNightShift: isNightShift ?? this.isNightShift,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseRate': baseRate,
        'isNightShift': isNightShift,
        'colorHex': colorHex,
      };

  factory ShiftTemplate.fromJson(Map<String, dynamic> json) {
    return ShiftTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      baseRate: (json['baseRate'] as num?)?.toInt() ?? 0,
      isNightShift: json['isNightShift'] as bool? ?? false,
      colorHex: json['colorHex'] as String? ?? '#2F6F5E',
    );
  }
}
