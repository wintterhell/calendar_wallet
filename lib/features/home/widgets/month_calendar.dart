import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../domain/models/calendar_day.dart';
import '../../../state/app_state.dart';
import 'day_cell.dart';
import 'day_editor_sheet.dart';

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

class MonthCalendar extends ConsumerWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final snapshot = ref.watch(calendarControllerProvider);
    final finance = ref.watch(financeServiceProvider);
    final templates = {
      for (final template in snapshot.templates) template.id: template,
    };
    final cells = _monthCells(month);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.72,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final date = cells[index];
                final day = snapshot.days[dateKey(date)] ??
                    CalendarDay(id: dateKey(date), date: dateOnly(date));
                final template = templates[day.templateId];
                return DayCell(
                  date: date,
                  inMonth: isSameMonth(date, month),
                  isToday: isSameDay(date, DateTime.now()),
                  day: day,
                  template: template,
                  income: finance.dayIncome(day, template),
                  onTap: () {
                    final brush = ref.read(activeTemplateIdProvider);
                    final controller =
                        ref.read(calendarControllerProvider.notifier);
                    if (brush != null) {
                      controller.assignTemplate(
                        date: date,
                        templateId: brush,
                        isSimulation: controller.defaultSimulation(date),
                      );
                      return;
                    }
                    showDayEditorSheet(context, date);
                  },
                  onLongPress: () => showDayEditorSheet(context, date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

List<DateTime> _monthCells(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final startOffset = (first.weekday + 6) % 7;
  final start = first.subtract(Duration(days: startOffset));
  return [for (var i = 0; i < 42; i++) start.add(Duration(days: i))];
}
