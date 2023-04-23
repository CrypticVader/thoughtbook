import 'package:intl/intl.dart';

extension CustomFormat on DateTime {
  String customFormat() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = this;
    final isToday = date.day == today.day;
    final formatter = DateFormat(isToday ? 'h:mm a' : 'h:mm a, d MMMM');
    final formattedDate = formatter.format(this);
    if (date.year == now.year) {
      return formattedDate;
    } else {
      return '$formattedDate, ${date.year}';
    }
  }
}
