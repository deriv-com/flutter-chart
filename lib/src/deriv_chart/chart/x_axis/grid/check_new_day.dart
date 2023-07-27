/// Returns true if a new day is started 0:0:0
bool checkNewDate(DateTime time) {
  final bool is0h0m0s = time.hour == 0 && time.minute == 0 && time.second == 0;

  return (time.month == 1 && time.day == 1 && is0h0m0s) ||
      (time.day == 1 && is0h0m0s) ||
      is0h0m0s;
}
