import 'package:intl/intl.dart';

class Utils {

 static String toDate(DateTime dateTime) {
    final date = DateFormat('d MMMM y HH:mm', 'tr_TR').format(dateTime);
    return date;
  }
}
