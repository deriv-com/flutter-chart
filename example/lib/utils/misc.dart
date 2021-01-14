/// Returns the label of a given granualirty.
String getGranularityLabel(int granularity) {
  switch (granularity) {
    case 0:
      return '1 tick';
    case 60:
      return '1 min';
    case 120:
      return '2 min';
    case 180:
      return '3 min';
    case 300:
      return '5 min';
    case 600:
      return '10 min';
    case 900:
      return '15 min';
    case 1800:
      return '30 min';
    case 3600:
      return '1 hour';
    case 7200:
      return '2 hours';
    case 14400:
      return '4 hours';
    case 28800:
      return '8 hours';
    case 86400:
      return '1 day';
    default:
      return '???';
  }
}
