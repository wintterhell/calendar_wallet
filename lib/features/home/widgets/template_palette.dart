import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../state/app_state.dart';

class TemplatePalette extends ConsumerWidget {
  const TemplatePalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    final activeId = ref.watch(activeTemplateIdProvider);
    final finance = ref.watch(financeServiceProvider);
    final scheme = Theme.of(context).colorScheme;

    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeId == null
                ? 'Выберите смену, затем нажмите на день'
                : 'Тап по дню назначает выбранную смену',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final template = templates[index];
                final selected = template.id == activeId;
                return FilterChip(
                  selected: selected,
                  showCheckmark: false,
                  avatar: Icon(Icons.circle, size: 12, color: template.color),
                  label: Text(
                    '${template.name} · ${formatRub(finance.payout(template))}',
                  ),
                  selectedColor: template.color.withValues(alpha: 0.28),
                  onSelected: (value) {
                    ref.read(activeTemplateIdProvider.notifier).state =
                        value ? template.id : null;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
