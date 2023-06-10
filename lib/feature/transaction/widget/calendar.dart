import 'package:flutter/material.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/translations/export_lang.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/constant/colors.dart';
import '../../../common/util/helper.dart';

class CalendarCpn extends StatefulWidget {
  const CalendarCpn({Key? key, required this.previousSelectedDate})
      : super(key: key);
  final DateTime previousSelectedDate;
  @override
  State<CalendarCpn> createState() => _CalendarCpnState();
}

class _CalendarCpnState extends State<CalendarCpn> {
  late DateTime dateNow;
  late PageController _pageController;
  void _onLeftChevronTap() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onRightChevronTap() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    dateNow = widget.previousSelectedDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<dynamic>(
      onCalendarCreated: (pageController) {
        _pageController = pageController;
      },
      firstDay: DateTime.utc(dateNow.year - 1, dateNow.month, dateNow.day),
      lastDay: DateTime.utc(dateNow.year + 2, dateNow.month, dateNow.day),
      focusedDay: dateNow,
      headerVisible: true,
      daysOfWeekHeight: 60,
      headerStyle: const HeaderStyle(
          headerPadding: EdgeInsets.symmetric(vertical: 24),
          formatButtonVisible: false,
          leftChevronVisible: false,
          rightChevronVisible: false),
      calendarFormat: CalendarFormat.month,
      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(color: grey1),
        weekendTextStyle: TextStyle(color: grey1),
        todayDecoration:
            BoxDecoration(color: purplePlum, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders<dynamic>(
        headerTitleBuilder: (context, day) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: _onLeftChevronTap,
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        size: 24,
                      )),
                  Text(
                    FormatTime.formatTime(dateTime: day, format: Format.My),
                    style: headline(color: emerald),
                  ),
                  IconButton(
                      onPressed: _onRightChevronTap,
                      icon: const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 24,
                      ))
                ],
              ),
              AnimationClick(
                function: () {
                  setState(() {
                    dateNow = now;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                      color: purplePlum,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    LocaleKeys.today.tr(),
                    style: footnote(color: white),
                  ),
                ),
              )
            ],
          );
        },
        dowBuilder: (context, day) {
          final dynamic text = DateFormat.E().format(day).substring(0, 1);
          return Center(
            child: Text(
              text,
              style: body(context: context),
            ),
          );
        },
      ),
      currentDay: dateNow,
      onDaySelected: (selectedDay, focusDay) {
        setState(() {
          dateNow = selectedDay;
          Navigator.of(context).pop(dateNow);
        });
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }
}
