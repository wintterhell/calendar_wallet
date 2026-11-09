import '../core/constants.dart';
import '../domain/models/calendar_day.dart';
import '../domain/models/shift_template.dart';

ShiftTemplate _migrateNightSeedRate(ShiftTemplate template) {
  final alreadyIncludesPremium = template.id == SeedTemplateIds.night &&
      template.isNightShift &&
      template.baseRate == 6000;
  if (!alreadyIncludesPremium) return template;
  return template.copyWith(baseRate: 5000);
}

class AppSnapshot {
  const AppSnapshot({
    required this.templates,
    required this.days,
  });

  final List<ShiftTemplate> templates;
  final Map<String, CalendarDay> days;

  AppSnapshot copyWith({
    List<ShiftTemplate>? templates,
    Map<String, CalendarDay>? days,
  }) {
    return AppSnapshot(
      templates: templates ?? this.templates,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toJson() => {
        'templates': templates.map((t) => t.toJson()).toList(),
        'days': days.map((key, value) => MapEntry(key, value.toJson())),
      };

  factory AppSnapshot.fromJson(Map<String, dynamic> json) {
    final templatesJson = json['templates'] as List<dynamic>? ?? [];
    final daysJson = json['days'] as Map<String, dynamic>? ?? {};
    return AppSnapshot(
      templates: templatesJson
          .map((e) => ShiftTemplate.fromJson(e as Map<String, dynamic>))
          .map(_migrateNightSeedRate)
          .toList(),
      days: daysJson.map(
        (key, value) => MapEntry(
          key,
          CalendarDay.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}
