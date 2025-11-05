String iso(DateTime d) => d.toIso8601String().split('T').first;


String formatNowWithWeekday(DateTime now) {
  const week = ['一', '二', '三', '四', '五', '六', '日'];
  final wd = week[now.weekday - 1];
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
      '($wd) ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
}
