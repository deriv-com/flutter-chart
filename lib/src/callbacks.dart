/// Pagination callback. The chart will call this to notify the app to fetch historical data.
typedef OnLoadHistory = Function(int fromEpoch, int toEpoch, int count);