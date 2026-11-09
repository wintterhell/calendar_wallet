class MonthlySummary {
  const MonthlySummary({
    required this.earned,
    required this.projected,
    required this.taxReserve,
  });

  final int earned;
  final int projected;
  final int taxReserve;

  static const empty = MonthlySummary(earned: 0, projected: 0, taxReserve: 0);
}
