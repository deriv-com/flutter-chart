/// Used to hold the active active accumulators contract information.
class AccumulatorsActiveContract {
  /// Initializes [AccumulatorsActiveContract].
  const AccumulatorsActiveContract({
    required this.profit,
    required this.profitUnit,
    required this.fractionalDigits,
  });

  /// Profit value of the current contract.
  final double? profit;

  /// The profit unit label either currency or %, etc that will be shown next to
  /// profit value.
  final String? profitUnit;

  /// The number of decimal places to show the correct formatting of the profit
  /// value.
  final int fractionalDigits;
}
