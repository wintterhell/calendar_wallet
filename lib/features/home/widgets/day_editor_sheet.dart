import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../state/app_state.dart';

Future<void> showDayEditorSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => DayEditorSheet(date: date),
  );
}

class DayEditorSheet extends ConsumerStatefulWidget {
  const DayEditorSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DayEditorSheet> createState() => _DayEditorSheetState();
}

class _DayEditorSheetState extends ConsumerState<DayEditorSheet> {
  late bool _simulate;
  late final TextEditingController _noteController;
  late final TextEditingController _bonusAmount;
  late final TextEditingController _fineAmount;

  @override
  void initState() {
    super.initState();
    final existing =
        ref.read(calendarControllerProvider.notifier).dayFor(widget.date);
    _simulate = existing.isSimulation;
    _noteController = TextEditingController(text: existing.note);
    _bonusAmount = TextEditingController(text: '0');
    _fineAmount = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _bonusAmount.dispose();
    _fineAmount.dispose();
    super.dispose();
  }

  int _parseAmount(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    final templates = ref.watch(templatesProvider);
    final finance = ref.watch(financeServiceProvider);
    final day = controller.dayFor(date);
    final template = controller.templateById(day.templateId);
    final shiftPay = template == null ? 0 : finance.payout(template);
    final income = finance.dayIncome(day, template);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDayTitle(date),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              template == null
                  ? 'Смена не назначена'
                  : '${template.name} · ${formatRub(shiftPay)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Итого за день: ${formatRub(income)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Симуляция «Что, если...»'),
              subtitle: const Text('Влияет на прогноз, но не на «Заработано»'),
              value: _simulate,
              onChanged: (value) {
                setState(() => _simulate = value);
                controller.setSimulation(date: date, isSimulation: value);
              },
            ),
            const SizedBox(height: 4),
            Text('Смена', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in templates)
                  ChoiceChip(
                    selected: day.templateId == item.id,
                    label: Text(
                      '${item.name} · ${formatRub(finance.payout(item))}',
                    ),
                    selectedColor: item.color.withValues(alpha: 0.28),
                    onSelected: (_) {
                      controller.assignTemplate(
                        date: date,
                        templateId: item.id,
                        isSimulation: _simulate,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Премия и штраф', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AdjustmentColumn(
                    label: 'Премия',
                    applied: day.extraBonus,
                    controller: _bonusAmount,
                    tooltip: 'Добавить премию',
                    icon: Icons.add,
                    color: const Color(0xFF2F6F5E),
                    onPressed: () {
                      final delta = _parseAmount(_bonusAmount);
                      if (delta <= 0) return;
                      controller.adjustDay(date: date, bonusDelta: delta);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AdjustmentColumn(
                    label: 'Штраф',
                    applied: day.extraFine,
                    controller: _fineAmount,
                    tooltip: 'Добавить штраф',
                    icon: Icons.remove,
                    color: const Color(0xFFB42318),
                    onPressed: () {
                      final delta = _parseAmount(_fineAmount);
                      if (delta <= 0) return;
                      controller.adjustDay(date: date, fineDelta: delta);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Заметка', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Переработка, штраф за инвентаризацию…',
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              onChanged: (value) => controller.patchDay(date: date, note: value),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  _noteController.clear();
                  setState(() => _simulate = false);
                  controller.clearDay(date);
                },
                child: const Text('Очистить день'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentColumn extends StatelessWidget {
  const _AdjustmentColumn({
    required this.label,
    required this.applied,
    required this.controller,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final int applied;
  final TextEditingController controller;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          'в дне: ${formatRub(applied)}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () {
                  controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  );
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: tooltip,
              child: Material(
                color: color,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPressed,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String formatDayTitle(DateTime date) {
  const months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  const weekdays = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];
  return '${date.day} ${months[date.month - 1]}, ${weekdays[date.weekday - 1]}';
}
