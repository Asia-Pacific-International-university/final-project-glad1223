import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}
