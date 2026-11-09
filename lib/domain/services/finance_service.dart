import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../models/calendar_day.dart';
import '../models/monthly_summary.dart';
import '../models/shift_template.dart';

class FinanceService {
  const FinanceService();

  int payout(ShiftTemplate template) {
    if (!template.isNightShift) return template.baseRate;
    return suggestedNightRate(template.baseRate);
  }

  int dayIncome(CalendarDay day, ShiftTemplate? template) {
    final base = template == null ? 0 : payout(template);
    return base + day.extraBonus - day.extraFine;
  }

  /// Ставка с доплатой 20% за ночные часы (ст. 154 ТК РФ), если шаблон
  /// ещё не содержит эту надбавку в [ShiftTemplate.baseRate].
  int suggestedNightRate(int baseRate) {
    return (baseRate * (1 + AppConstants.nightPremiumRate)).round();
  }

  MonthlySummary summarize({
    required DateTime month,
    required DateTime today,
    required Iterable<CalendarDay> days,
    required Map<String, ShiftTemplate> templates,
  }) {
    final todayDate = dateOnly(today);
    var earned = 0;
    var projected = 0;

    for (final day in days) {
      if (!isSameMonth(day.date, month) || day.isEmpty) continue;
      final template =
          day.templateId == null ? null : templates[day.templateId];
      final income = dayIncome(day, template);
      projected += income;
      final isPastOrToday = !dateOnly(day.date).isAfter(todayDate);
      if (!day.isSimulation && isPastOrToday) {
        earned += income;
      }
    }

    return MonthlySummary(
      earned: earned,
      projected: projected,
      taxReserve: (projected * AppConstants.selfEmployedTaxRate).round(),
    );
  }
}
