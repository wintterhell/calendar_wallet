class CalendarDay {
  const CalendarDay({
    required this.id,
    required this.date,
    this.templateId,
    this.extraBonus = 0,
    this.extraFine = 0,
    this.note = '',
    this.isSimulation = false,
  });

  final String id;
  final DateTime date;
  final String? templateId;
  final int extraBonus;
  final int extraFine;
  final String note;
  final bool isSimulation;

  bool get hasNote => note.trim().isNotEmpty;

  bool get isEmpty =>
      templateId == null &&
      extraBonus == 0 &&
      extraFine == 0 &&
      !hasNote &&
      !isSimulation;

  CalendarDay copyWith({
    String? id,
    DateTime? date,
    String? templateId,
    int? extraBonus,
    int? extraFine,
    String? note,
    bool? isSimulation,
    bool clearTemplate = false,
  }) {
    return CalendarDay(
      id: id ?? this.id,
      date: date ?? this.date,
      templateId: clearTemplate ? null : (templateId ?? this.templateId),
      extraBonus: extraBonus ?? this.extraBonus,
      extraFine: extraFine ?? this.extraFine,
      note: note ?? this.note,
      isSimulation: isSimulation ?? this.isSimulation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'templateId': templateId,
        'extraBonus': extraBonus,
        'extraFine': extraFine,
        'note': note,
        'isSimulation': isSimulation,
      };

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      templateId: json['templateId'] as String?,
      extraBonus: (json['extraBonus'] as num?)?.toInt() ?? 0,
      extraFine: (json['extraFine'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
      isSimulation: json['isSimulation'] as bool? ?? false,
    );
  }
}
