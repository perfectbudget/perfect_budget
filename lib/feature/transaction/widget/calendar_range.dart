import 'package:flutter/material.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/translations/export_lang.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/constant/colors.dart';
import '../../../common/util/helper.dart';

class CalendarRange extends StatefulWidget {
  const CalendarRange({Key? key, this.startDate, this.endDate})
      : super(key: key);
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  State<CalendarRange> createState() => _CalendarCpnState();
}

class _CalendarCpnState extends State<CalendarRange> {
  DateTime? startDate;
  DateTime? endDate;
  late DateTime focusDate = now;
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
    startDate = widget.startDate ?? now;
    endDate = widget.endDate ?? now;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<dynamic>(
      onCalendarCreated: (pageController) {
        _pageController = pageController;
      },
      rangeSelectionMode: RangeSelectionMode.enforced,
      rangeStartDay: startDate,
      rangeEndDay: endDate,
      firstDay: DateTime.utc(now.year - 1, now.month, now.day),
      lastDay: DateTime.utc(now.year + 2, now.month, now.day),
      focusedDay: focusDate,
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
        rangeStartDecoration:
            BoxDecoration(color: blueCrayola, shape: BoxShape.circle),
        rangeEndDecoration:
            BoxDecoration(color: blueCrayola, shape: BoxShape.circle),
        rangeHighlightColor: blueCrayola,
        withinRangeTextStyle: TextStyle(color: white),
        withinRangeDecoration:
            BoxDecoration(color: blueCrayola, shape: BoxShape.circle),
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
                      )),
                ],
              ),
              AnimationClick(
                function: () {
                  setState(() {
                    focusDate = now;
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
      onRangeSelected: (start, end, focusedDay) {
        setState(() {
          focusDate = focusedDay;
          startDate = start;
          endDate = end;
        });
        if (startDate != null && endDate != null) {
          Navigator.of(context).pop({'start': startDate, 'end': endDate});
        }
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }
}
