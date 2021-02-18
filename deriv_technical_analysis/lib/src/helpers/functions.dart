/// Returns the rounded double with [places] decimals
double roundDouble(double value, int places) =>
    double.tryParse(value.toStringAsFixed(places));
