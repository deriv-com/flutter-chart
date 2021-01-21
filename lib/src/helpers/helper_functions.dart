/// Gets enum value as string from the given enum
/// E.g. MovingAverage.simple -> simple
String getEnumValue<T>(T t) =>
    t.toString().substring(t.toString().indexOf('.') + 1);
