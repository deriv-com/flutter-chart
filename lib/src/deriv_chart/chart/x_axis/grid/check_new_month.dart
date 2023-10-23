/// Returns true if a new month is started 0:0:0
bool checkNewMonth(DateTime time) {
  final bool is0h0m0s = time.hour == 0 && time.minute == 0 && time.second == 0;

  return time.day == 1 && is0h0m0s;
}
