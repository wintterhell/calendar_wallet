import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/formatters.dart';
import '../data/app_snapshot.dart';
import '../data/local_store.dart';
import '../data/seed.dart';
import '../domain/models/calendar_day.dart';
import '../domain/models/warehouse_preset.dart';
import '../domain/models/monthly_summary.dart';
import '../domain/models/shift_template.dart';
import '../domain/services/finance_service.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw StateError('LocalStore must be overridden in ProviderScope');
});

final financeServiceProvider = Provider<FinanceService>((ref) {
  return const FinanceService();
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Кисть для быстрого назначения смены тапом по ячейке календаря.
final activeTemplateIdProvider = StateProvider<String?>((ref) => null);

class CalendarController extends Notifier<AppSnapshot> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  AppSnapshot build() => _store.load();

  Future<void> _persist() => _store.save(state);

  ShiftTemplate? templateById(String? id) {
    if (id == null) return null;
    for (final template in state.templates) {
      if (template.id == id) return template;
    }
    return null;
  }

  CalendarDay dayFor(DateTime date) {
    final key = dateKey(date);
    return state.days[key] ??
        CalendarDay(id: key, date: dateOnly(date));
  }

  Future<void> assignTemplate({
    required DateTime date,
    required String templateId,
    required bool isSimulation,
  }) async {
    final existing = dayFor(date);
    final next = Map<String, CalendarDay>.from(state.days);
    next[existing.id] = existing.copyWith(
      templateId: templateId,
      isSimulation: isSimulation,
    );
    state = state.copyWith(days: next);
    ref.read(activeTemplateIdProvider.notifier).state = templateId;
    await _persist();
  }

  bool defaultSimulation(DateTime date) => dayFor(date).isSimulation;

  Future<void> setSimulation({
    required DateTime date,
    required bool isSimulation,
  }) {
    return patchDay(date: date, isSimulation: isSimulation);
  }

  Future<void> adjustDay({
    required DateTime date,
    int bonusDelta = 0,
    int fineDelta = 0,
  }) async {
    final existing = dayFor(date);
    await patchDay(
      date: date,
      extraBonus: (existing.extraBonus + bonusDelta).clamp(0, 1 << 30),
      extraFine: (existing.extraFine + fineDelta).clamp(0, 1 << 30),
    );
  }

  Future<void> patchDay({
    required DateTime date,
    int? extraBonus,
    int? extraFine,
    String? note,
    bool? isSimulation,
  }) async {
    final existing = dayFor(date);
    final nextDay = existing.copyWith(
      extraBonus: extraBonus,
      extraFine: extraFine,
      note: note,
      isSimulation: isSimulation,
    );
    final next = Map<String, CalendarDay>.from(state.days);
    if (nextDay.isEmpty) {
      next.remove(existing.id);
    } else {
      next[existing.id] = nextDay;
    }
    state = state.copyWith(days: next);
    await _persist();
  }

  Future<void> clearDay(DateTime date) async {
    final next = Map<String, CalendarDay>.from(state.days)..remove(dateKey(date));
    state = state.copyWith(days: next);
    await _persist();
  }

  Future<void> upsertTemplate(ShiftTemplate template) async {
    await _writeTemplates([template], selectId: template.id);
  }

  Future<void> importPreset(WarehousePreset preset) async {
    await _writeTemplates(
      preset.templates,
      selectId: preset.templates.first.id,
    );
  }

  Future<void> _writeTemplates(
    List<ShiftTemplate> incoming, {
    required String selectId,
  }) async {
    final templates = [...state.templates];
    for (final template in incoming) {
      final index = templates.indexWhere((item) => item.id == template.id);
      if (index >= 0) {
        templates[index] = template;
      } else {
        templates.add(template);
      }
    }
    state = state.copyWith(templates: templates);
    ref.read(activeTemplateIdProvider.notifier).state = selectId;
    await _persist();
  }

  Future<void> deleteTemplate(String id) async {
    final active = ref.read(activeTemplateIdProvider);
    state = state.copyWith(
      templates: state.templates.where((item) => item.id != id).toList(),
    );
    if (active == id) {
      ref.read(activeTemplateIdProvider.notifier).state = null;
    }
    await _persist();
  }

  Future<void> resetTemplates() async {
    state = state.copyWith(templates: defaultTemplates);
    await _persist();
  }
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, AppSnapshot>(CalendarController.new);

final templatesProvider = Provider<List<ShiftTemplate>>((ref) {
  return ref.watch(calendarControllerProvider).templates;
});

final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final snapshot = ref.watch(calendarControllerProvider);
  final month = ref.watch(selectedMonthProvider);
  final templates = {
    for (final template in snapshot.templates) template.id: template,
  };
  return ref.read(financeServiceProvider).summarize(
        month: month,
        today: DateTime.now(),
        days: snapshot.days.values,
        templates: templates,
      );
});

Future<Override> localStoreOverride() async {
  final prefs = await SharedPreferences.getInstance();
  return localStoreProvider.overrideWithValue(LocalStore(prefs));
}
