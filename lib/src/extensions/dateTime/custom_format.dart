import 'package:intl/intl.dart';

extension CustomFormat on DateTime {
  String customFormat() {
    final today = DateTime.now();
    final date = toLocal();
    final isToday = date.day == today.day;
    final formatter = DateFormat(isToday ? 'h:mm a' : 'h:mm a, d MMMM');
    final formattedDate = formatter.format(date);
    if (date.year == today.year) {
      return formattedDate;
    } else {
      return '$formattedDate, ${date.year}';
    }
  }
}
