import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../domain/models/shift_template.dart';
import '../../state/app_state.dart';

class TemplateEditorPage extends ConsumerStatefulWidget {
  const TemplateEditorPage({super.key, this.existing});

  final ShiftTemplate? existing;

  @override
  ConsumerState<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends ConsumerState<TemplateEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _rate;
  late String _colorHex;
  late bool _night;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _rate = TextEditingController(
      text: existing == null ? '' : '${existing.baseRate}',
    );
    _colorHex = existing?.colorHex ?? AppConstants.templatePalette.first;
    _night = existing?.isNightShift ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  int get _baseRate => int.tryParse(_rate.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeServiceProvider);
    final payout = _night ? finance.suggestedNightRate(_baseRate) : _baseRate;
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Шаблон смены' : 'Новая смена'),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Удалить',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Склад день, Доставка вечер',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название смены';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rate,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Базовая ставка, ₽',
                hintText: '5000',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Укажите ставку';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Ставка должна быть числом';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ночная смена'),
              subtitle: const Text('Доплата 20% за ночные часы, ст. 154 ТК РФ'),
              value: _night,
              onChanged: (value) => setState(() => _night = value),
            ),
            Text(
              _night
                  ? 'К выплате: ${formatRub(payout)}  ·  ставка ${formatRub(_baseRate)} + 20%'
                  : 'К выплате: ${formatRub(payout)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Text('Цвет в календаре', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in AppConstants.templatePalette)
                  _ColorDot(
                    hex: hex,
                    selected: _colorHex.toUpperCase() == hex.toUpperCase(),
                    onTap: () => setState(() => _colorHex = hex),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;
    final template = ShiftTemplate(
      id: existing?.id ?? 'tpl_${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      baseRate: _baseRate,
      isNightShift: _night,
      colorHex: _colorHex,
    );
    await ref.read(calendarControllerProvider.notifier).upsertTemplate(template);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить шаблон?'),
        content: const Text('Дни с этой сменой останутся, но ставка обнулится.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(calendarControllerProvider.notifier).deleteTemplate(existing.id);
    if (mounted) Navigator.of(context).pop();
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Ink(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : color.withValues(alpha: 0.3),
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}
