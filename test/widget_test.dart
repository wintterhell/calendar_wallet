import 'package:flutter/material.dart';
import 'package:calendar_wallet/app.dart';
import 'package:calendar_wallet/core/constants.dart';
import 'package:calendar_wallet/data/app_snapshot.dart';
import 'package:calendar_wallet/data/local_store.dart';
import 'package:calendar_wallet/data/seed.dart';
import 'package:calendar_wallet/features/home/widgets/day_cell.dart';
import 'package:calendar_wallet/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders finance header and calendar weekdays', (tester) async {
    await initializeDateFormatting('ru');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(LocalStore(prefs)),
          calendarControllerProvider.overrideWith(_SeededCalendar.new),
        ],
        child: const CalendarWalletApp(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Заработано'), findsOneWidget);
    expect(find.text('Прогноз'), findsOneWidget);
    expect(find.text('Налог 6%'), findsOneWidget);
    expect(find.text('Пн'), findsOneWidget);

    await tester.tap(find.byTooltip('Настройка смен'));
    await tester.pumpAndSettle();
    expect(find.text('Настройка смен'), findsOneWidget);
    expect(find.text('Новая смена'), findsOneWidget);
    expect(find.text('День'), findsOneWidget);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Новая смена'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Склад ночь');
    await tester.enterText(find.byType(TextFormField).at(1), '5000');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.textContaining('К выплате:'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Склад ночь'), findsOneWidget);
    expect(find.textContaining('ночь +20%'), findsAtLeast(1));
  });

  testWidgets('day editor opens with simulation off and round adjustments',
      (tester) async {
    await initializeDateFormatting('ru');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(LocalStore(prefs)),
          calendarControllerProvider.overrideWith(_SeededCalendar.new),
          selectedMonthProvider.overrideWith((ref) => DateTime(2026, 11)),
        ],
        child: const CalendarWalletApp(),
      ),
    );

    final futureCell = find.byWidgetPredicate(
      (widget) =>
          widget is DayCell &&
          widget.inMonth &&
          widget.date.year == 2026 &&
          widget.date.month == 11 &&
          widget.date.day == 3,
    );
    expect(futureCell, findsOneWidget);
    await tester.ensureVisible(futureCell);
    await tester.longPress(futureCell);
    await tester.pumpAndSettle();

    expect(find.textContaining('Итого за день'), findsOneWidget);
    expect(find.text('Симуляция «Что, если...»'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.byTooltip('Добавить премию'), findsOneWidget);
    expect(find.byTooltip('Добавить штраф'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Заметка'), findsOneWidget);
    expect(find.text('0'), findsAtLeast(2));
  });

  testWidgets('warehouse preset import shows chips on home', (tester) async {
    await initializeDateFormatting('ru');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(LocalStore(prefs)),
          calendarControllerProvider.overrideWith(_SeededCalendar.new),
        ],
        child: const CalendarWalletApp(),
      ),
    );

    await tester.tap(find.byTooltip('Настройка смен'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выбрать готовый пресет склада'));
    await tester.pumpAndSettle();
    expect(find.text('Ozon Склад'), findsOneWidget);
    expect(find.text('Wildberries'), findsOneWidget);
    expect(find.text('Яндекс Маркет'), findsOneWidget);
    expect(find.text('Курьер'), findsOneWidget);

    await tester.tap(find.text('Ozon Склад'));
    await tester.pumpAndSettle();
    expect(find.text('Ozon День'), findsOneWidget);
    expect(find.text('Ozon Ночь'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('Ozon День'), findsWidgets);
  });
}

class _SeededCalendar extends CalendarController {
  @override
  AppSnapshot build() {
    return const AppSnapshot(templates: defaultTemplates, days: {});
  }
}
