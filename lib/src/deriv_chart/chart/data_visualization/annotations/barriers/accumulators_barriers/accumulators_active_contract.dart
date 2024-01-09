/// Used to hold the active active accumulators contract information.
class AccumulatorsActiveContract {
  /// Initializes [AccumulatorsActiveContract].
  const AccumulatorsActiveContract({
    required this.profit,
    required this.currency,
  });

  /// Profit value of the current contract.
  final double? profit;

  /// The currency of the current contract.
  final String? currency;
}
