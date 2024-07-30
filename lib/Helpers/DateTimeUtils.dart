import 'package:flutter/material.dart';

class DateTimeUtils {
  static convertDate({required BuildContext context, required String time}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static readMessageDate(
      {required BuildContext context, required String sendTime}) {
    DateTime currentTime = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(sendTime));
    if (currentTime.day == date.day &&
        currentTime.month == date.month &&
        currentTime.year == date.year) {
      return "Today, ${TimeOfDay.fromDateTime(date).format(context)}";
    } else if (currentTime.year == date.year) {
      return "${date.day} ${getmonth(date.month)}, ${TimeOfDay.fromDateTime(date).format(context)}";
    } else {
      return "${date.day}/${getmonth(date.month)}/${date.year}, ${TimeOfDay.fromDateTime(date).format(context)}";
    }
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

  static getLastActiveTime(
      {required BuildContext context, required String sendTime}) {
    DateTime currentTime = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(sendTime));
    if (currentTime.day == date.day &&
        currentTime.month == date.month &&
        currentTime.year == date.year) {
      return "Last since today at ${TimeOfDay.fromDateTime(date).format(context)}";
    } else if ((currentTime.difference(date).inHours ~/ 24) == 1) {
      return "Last since yesterday at ${TimeOfDay.fromDateTime(date).format(context)}";
    } else {
      return "Last Active on ${date.day} ${getmonth(date.month)} at ${TimeOfDay.fromDateTime(date).format(context)}";
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
