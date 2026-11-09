import 'package:calendar_wallet/core/constants.dart';
import 'package:calendar_wallet/domain/models/calendar_day.dart';
import 'package:calendar_wallet/domain/models/shift_template.dart';
import 'package:calendar_wallet/domain/services/finance_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const finance = FinanceService();
  const dayShift = ShiftTemplate(
    id: 'day',
    name: 'День',
    baseRate: 5000,
    isNightShift: false,
    colorHex: '#2F6F5E',
  );
  const gig = ShiftTemplate(
    id: 'gig',
    name: 'Подработка',
    baseRate: 4500,
    isNightShift: false,
    colorHex: '#B0893E',
  );

  test('earned ignores future and simulated days', () {
    final summary = finance.summarize(
      month: DateTime(2026, 11),
      today: DateTime(2026, 11, 10),
      templates: {'day': dayShift, 'gig': gig},
      days: [
        CalendarDay(
          id: '2026-11-01',
          date: DateTime(2026, 11, 1),
          templateId: 'day',
        ),
        CalendarDay(
          id: '2026-11-20',
          date: DateTime(2026, 11, 20),
          templateId: 'day',
        ),
        CalendarDay(
          id: '2026-11-12',
          date: DateTime(2026, 11, 12),
          templateId: 'gig',
          isSimulation: true,
        ),
      ],
    );

    expect(summary.earned, 5000);
    expect(summary.projected, 5000 + 5000 + 4500);
    expect(summary.taxReserve, (14500 * AppConstants.selfEmployedTaxRate).round());
  });

  test('bonus and fine change day income', () {
    final day = CalendarDay(
      id: '2026-11-01',
      date: DateTime(2026, 11, 1),
      templateId: 'day',
      extraBonus: 500,
      extraFine: 200,
    );
    expect(finance.dayIncome(day, dayShift), 5300);
  });

  test('night shift adds 20 percent to base rate', () {
    const night = ShiftTemplate(
      id: 'night',
      name: 'Ночь',
      baseRate: 5000,
      isNightShift: true,
      colorHex: '#3D4C73',
    );
    expect(finance.payout(night), 6000);
    expect(
      finance.dayIncome(
        CalendarDay(
          id: '2026-11-01',
          date: DateTime(2026, 11, 1),
          templateId: 'night',
        ),
        night,
      ),
      6000,
    );
  });
}
