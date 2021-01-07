/// Accepts a list of entries and calculates min/max values for that list.
/// Reuses work done when new list is supplied.
/// TODO: Use OHLC interface?
///
/// Keep one instance for each unique `Series` or list of data with sliding window.
class MinMaxCalculator<T extends Tick> {}
