import 'package:flutter/material.dart';

class DateTimeUtils {
  static convertDate({required BuildContext context, required String time}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static getLastmessageFormat(
      {required BuildContext context, required String sendTime}) {
    DateTime currentTime = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(sendTime));
    if (currentTime.day == date.day &&
        currentTime.month == date.month &&
        currentTime.year == date.year) {
      return TimeOfDay.fromDateTime(date).format(context);
    } else {
      return "${date.day} ${getmonth(date.month)}";
    }
  }

  static getmonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return "Jun";
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
