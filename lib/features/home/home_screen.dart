import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../features/templates/templates_screen.dart';
import '../../state/app_state.dart';
import 'widgets/finance_header.dart';
import 'widgets/month_calendar.dart';
import 'widgets/template_palette.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: IconButton(
          tooltip: 'Настройка смен',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TemplatesScreen(),
              ),
            );
          },
          icon: const Icon(Icons.layers_outlined),
        ),
        actions: [
          IconButton(
            tooltip: 'Предыдущий месяц',
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Text(
              formatMonthTitle(month),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            tooltip: 'Следующий месяц',
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: const Column(
        children: [
          FinanceHeader(),
          TemplatePalette(),
          Expanded(child: MonthCalendar()),
        ],
      ),
    );
  }
}
