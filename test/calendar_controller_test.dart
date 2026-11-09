import 'package:calendar_wallet/core/formatters.dart';
import 'package:calendar_wallet/data/local_store.dart';
import 'package:calendar_wallet/data/warehouse_presets.dart';
import 'package:calendar_wallet/domain/models/shift_template.dart';
import 'package:calendar_wallet/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(LocalStore(prefs)),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 11)),
      ],
    );
    addTearDown(container.dispose);
  });

  test('new template is persisted and used in monthly finance', () async {
    const custom = ShiftTemplate(
      id: 'tpl_custom',
      name: 'Склад',
      baseRate: 4000,
      isNightShift: true,
      colorHex: '#4F7C8A',
    );

    final controller = container.read(calendarControllerProvider.notifier);
    await controller.upsertTemplate(custom);
    await controller.assignTemplate(
      date: DateTime(2026, 11, 2),
      templateId: custom.id,
      isSimulation: false,
    );

    final snapshot = container.read(calendarControllerProvider);
    expect(snapshot.templates.any((item) => item.id == custom.id), isTrue);
    expect(snapshot.days[dateKey(DateTime(2026, 11, 2))]?.templateId, custom.id);

    final summary = container.read(monthlySummaryProvider);
    expect(summary.projected, 4800);
    expect(summary.earned, 4800);
    expect(summary.taxReserve, (4800 * 0.06).round());
  });

  test('changing a day recalculates tax in real time', () async {
    final controller = container.read(calendarControllerProvider.notifier);
    await controller.assignTemplate(
      date: DateTime(2026, 11, 1),
      templateId: 'tpl_day',
      isSimulation: false,
    );
    expect(container.read(monthlySummaryProvider).projected, 5000);

    await controller.assignTemplate(
      date: DateTime(2026, 11, 3),
      templateId: 'tpl_gig',
      isSimulation: true,
    );
    final summary = container.read(monthlySummaryProvider);
    expect(summary.projected, 9500);
    expect(summary.earned, 5000);
    expect(summary.taxReserve, (9500 * 0.06).round());
  });

  test('bonus, fine and note persist and update monthly totals', () async {
    final controller = container.read(calendarControllerProvider.notifier);
    await controller.assignTemplate(
      date: DateTime(2026, 11, 2),
      templateId: 'tpl_day',
      isSimulation: false,
    );
    await controller.adjustDay(
      date: DateTime(2026, 11, 2),
      bonusDelta: 500,
      fineDelta: 200,
    );
    await controller.patchDay(
      date: DateTime(2026, 11, 2),
      note: 'Переработка 2 часа',
    );

    final day = controller.dayFor(DateTime(2026, 11, 2));
    expect(day.extraBonus, 500);
    expect(day.extraFine, 200);
    expect(day.note, 'Переработка 2 часа');

    final summary = container.read(monthlySummaryProvider);
    expect(summary.projected, 5300);
    expect(summary.earned, 5300);
    expect(summary.taxReserve, (5300 * 0.06).round());
  });

  test('future empty days do not default to simulation', () {
    final controller = container.read(calendarControllerProvider.notifier);
    final future = DateTime(2026, 11, 20);
    expect(controller.defaultSimulation(future), isFalse);
    expect(controller.dayFor(future).isSimulation, isFalse);
  });

  test('importing a warehouse preset adds templates once', () async {
    final controller = container.read(calendarControllerProvider.notifier);
    final ozon = warehousePresets.first;
    await controller.importPreset(ozon);
    await controller.importPreset(ozon);

    final names = container
        .read(calendarControllerProvider)
        .templates
        .map((item) => item.name)
        .toList();
    expect(names.where((name) => name == 'Ozon День').length, 1);
    expect(names.where((name) => name == 'Ozon Ночь').length, 1);
    expect(container.read(activeTemplateIdProvider), PresetTemplateIds.ozonDay);
  });
}
