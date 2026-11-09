import 'package:flutter/material.dart';

import '../../../core/formatters.dart';
import '../../../domain/models/calendar_day.dart';
import '../../../domain/models/shift_template.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.day,
    required this.template,
    required this.income,
    required this.onTap,
    this.onLongPress,
  });

  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final CalendarDay day;
  final ShiftTemplate? template;
  final int income;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = template?.color ?? scheme.outlineVariant;
    final muted = scheme.onSurface.withValues(alpha: inMonth ? 1 : 0.28);

    return Opacity(
      opacity: inMonth ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: day.isSimulation
                    ? accent.withValues(alpha: 0.85)
                    : isToday
                        ? scheme.primary.withValues(alpha: 0.7)
                        : scheme.outlineVariant.withValues(alpha: 0.35),
                width: isToday || day.isSimulation ? 1.4 : 1,
              ),
              color: template == null
                  ? Colors.transparent
                  : accent.withValues(alpha: 0.14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${date.day}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: muted,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w500,
                              ),
                        ),
                      ),
                      if (day.hasNote)
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (template != null)
                    Text(
                      template!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  if (income != 0)
                    Text(
                      formatRub(income),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: muted.withValues(alpha: 0.85),
                            fontSize: 10,
                          ),
                    ),
                  if (day.extraBonus > 0 || day.extraFine > 0)
                    Text(
                      [
                        if (day.extraBonus > 0) '+${day.extraBonus}',
                        if (day.extraFine > 0) '−${day.extraFine}',
                      ].join(' '),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
