import 'package:intl/intl.dart';

final _rub = NumberFormat.currency(
  locale: 'ru_RU',
  symbol: '₽',
  decimalDigits: 0,
);

final _monthTitle = DateFormat.yMMMM('ru');

String formatRub(int amount) => _rub.format(amount);

String formatMonthTitle(DateTime month) {
  final raw = _monthTitle.format(month);
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}

String dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;
