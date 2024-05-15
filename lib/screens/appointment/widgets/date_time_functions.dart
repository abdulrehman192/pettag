import 'package:intl/intl.dart';

String convertDateFromMillisecondsSinceEpoch(String dateTime) =>
    DateFormat('MM/dd/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime)));


String pastDueDate(int index, String dueDate) {
  int pastDueDateInMillis = DateTime.now().millisecondsSinceEpoch - int.parse(dueDate);

  int days = (pastDueDateInMillis.toInt() / 1000 ) ~/ 86400;

  if(days == 1) {
    return '$days day late';
  } else {
    if(days < 30 ) {
      return '${days.toInt()} days late';
    } else {
      if(days / 30 < 12) {
        if(days/30 < 2) {
          return '1 month late';
        }else {
          return '${days ~/ 30} months late';
        }
      } else {
        if(days/360 <2) {
          return '1 year late';
        }else {
          return '${days~/360} years late';
        }
      }
    }
  }
  return days.toString();

}
