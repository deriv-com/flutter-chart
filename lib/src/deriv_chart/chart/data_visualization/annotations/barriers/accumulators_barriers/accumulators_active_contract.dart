/// Used to hold the active active accumulators contract information.
class AccumulatorsActiveContract {
  /// Initializes [AccumulatorsActiveContract].
  const AccumulatorsActiveContract({
    required this.profit,
    required this.currency,
    required this.fractionalDigits,
  });

  /// Profit value of the current contract.
  final double? profit;

  /// The currency of the current contract.
  final String? currency;

  /// The number of decimal places to show the correct formatting of the profit
  /// value.
  final int fractionalDigits;
}
