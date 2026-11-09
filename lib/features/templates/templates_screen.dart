import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../domain/models/shift_template.dart';
import '../../state/app_state.dart';
import 'preset_picker_page.dart';
import 'template_editor_page.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    final finance = ref.watch(financeServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройка смен')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Новая смена'),
      ),
      body: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: templates.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PresetPickerPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.warehouse_outlined),
                    label: const Text('Выбрать готовый пресет склада'),
                  );
                }
                final template = templates[index - 1];
                final payout = finance.payout(template);
                return _TemplateTile(
                  template: template,
                  payout: payout,
                  onTap: () => _openEditor(context, template),
                );
              },
            ),
    );
  }

  void _openEditor(BuildContext context, [ShiftTemplate? existing]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TemplateEditorPage(existing: existing),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.payout,
    required this.onTap,
  });

  final ShiftTemplate template;
  final int payout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: template.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 36,
                decoration: BoxDecoration(
                  color: template.color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.isNightShift
                          ? '${formatRub(payout)}  ·  ночь +20%'
                          : formatRub(payout),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
