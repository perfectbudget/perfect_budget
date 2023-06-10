import 'package:intl/intl.dart';

import 'helper.dart';

enum Format { dMy, mdy, Mdy, dMydMy, My, EMd, E, M, y, dMMy }

mixin FormatTime {
  static String formatTime({Format? format, DateTime? dateTime}) {
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
    String formatted;
    DateFormat formatter;
    switch (format!) {
      case Format.dMy:
        formatter = DateFormat('dd/MM/yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.dMMy:
        formatter = DateFormat('dd MMM yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.y:
        formatter = DateFormat('yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.Mdy:
        formatter = DateFormat('MMMM dd, yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.mdy:
        formatter = DateFormat('MMM dd, yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.M:
        formatter = DateFormat('MMM', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.EMd:
        formatter = DateFormat('EEEE, MMMM dd', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.E:
        formatter = DateFormat('EEEE', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.dMydMy:
        if (sevenDaysAgo.year == now.year) {
          formatter = DateFormat('dd MMM yyyy', locale);
          formatted = DateFormat('dd MMM', locale).format(sevenDaysAgo) +
              ' - ' +
              formatter.format(now);
        } else {
          formatter = DateFormat('dd MMM yyyy', locale);
          formatted =
              formatter.format(sevenDaysAgo) + ' - ' + formatter.format(now);
        }
        break;
      case Format.My:
        formatter = DateFormat('MMMM yyyy', locale);
        formatted = formatter.format(dateTime ?? now);
        break;
    }
    return formatted;
  }

  static String convertTime(int duration) {
    final minutesStr = (duration / 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
