import 'package:flutter/material.dart';

class DateTimeUtils {
  static convertDate({required BuildContext context, required String time}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }
}
