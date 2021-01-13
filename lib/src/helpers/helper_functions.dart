/// Returns the rounded double with [places] decimals
double roundDouble(double value, int places) =>
    double.tryParse(value.toStringAsFixed(places));

/// Gets enum value as string from the given enum
/// E.g. MovingAverage.simple -> simple
String getEnumValue<T>(T t) =>
    t.toString().substring(t.toString().indexOf('.') + 1);
