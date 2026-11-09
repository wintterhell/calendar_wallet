import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/warehouse_presets.dart';
import '../../domain/models/warehouse_preset.dart';
import '../../state/app_state.dart';

class PresetPickerPage extends ConsumerWidget {
  const PresetPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Готовый пресет склада')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Выберите компанию — шаблоны смен появятся в ленте на главном экране. Ставки можно поправить позже.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          for (final preset in warehousePresets) ...[
            _PresetCard(
              preset: preset,
              onTap: () => _import(context, ref, preset),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _import(
    BuildContext context,
    WidgetRef ref,
    WarehousePreset preset,
  ) async {
    await ref.read(calendarControllerProvider.notifier).importPreset(preset);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлены шаблоны «${preset.name}»')),
    );
    Navigator.of(context).pop();
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.onTap});

  final WarehousePreset preset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(int.parse(preset.accentHex.replaceFirst('#', '0xFF')));
    final secondary =
        Color(int.parse(preset.secondaryHex.replaceFirst('#', '0xFF')));
    final onAccent = accent.computeLuminance() > 0.55
        ? const Color(0xFF1A1A1A)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent,
                Color.lerp(accent, secondary, 0.72) ?? secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: onAccent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: onAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        preset.monogram,
                        style: TextStyle(
                          color: onAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: preset.monogram.length > 1 ? 16 : 22,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: onAccent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.blurb,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: onAccent.withValues(alpha: 0.82),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: onAccent),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final template in preset.templates)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: onAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: onAccent.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          '${template.name} · ${formatRub(template.baseRate)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: onAccent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
