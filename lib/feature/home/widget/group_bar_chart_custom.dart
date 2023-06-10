import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';

import '../../../common/util/format_time.dart';
import '../../../common/util/helper.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/chart/bloc_chart.dart';

class GroupBarChartCustom extends StatefulWidget {
  const GroupBarChartCustom({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<GroupBarChartCustom> createState() => _GroupBarChartCustomState();
}

class _GroupBarChartCustomState extends State<GroupBarChartCustom> {
  double widthIncome = 0;
  double widthExpense = 0;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return BlocBuilder<ChartBloc, ChartState>(builder: (context, state) {
      if (state is ChartLoading) {
        return const SizedBox();
      }
      if (state is ChartLoaded) {
        widthIncome =
            state.showingBarGroups[widget.index].income * state.maxY / 10;
        widthExpense =
            state.showingBarGroups[widget.index].expense * state.maxY / 10;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Text(
                    FormatTime.formatTime(
                        format: Format.M,
                        dateTime: DateTime(now.year, widget.index + 1)),
                    style: footnote(color: grey2, fontWeight: '500'))),
            Expanded(
              flex: 10,
              child: LayoutBuilder(builder: (context, constraint) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: widthIncome != 0
                            ? (widthIncome / state.maxY * constraint.maxWidth)
                            : 1,
                        height: 15,
                        curve: Curves.linearToEaseOut,
                        decoration: const BoxDecoration(
                            color: blueCrayola,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(6),
                                topRight: Radius.circular(6))),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: widthExpense != 0
                            ? (widthExpense / state.maxY * constraint.maxWidth)
                            : 1,
                        height: 15,
                        curve: Curves.linearToEaseOut,
                        decoration: const BoxDecoration(
                            color: redCrayola,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(6),
                                topRight: Radius.circular(6))),
                      )
                    ],
                  ),
                );
              }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    widthIncome == 0
                        ? symbol == '₫'
                            ? '${symbol}0'
                            : '${symbol}0.00'
                        : handleStyleMoney(context, widthIncome,
                            type: 'income'),
                    style: body(color: blueCrayola)),
                Text(
                    widthExpense == 0
                        ? symbol == '₫'
                            ? '-${symbol}0'
                            : '-${symbol}0.00'
                        : handleStyleMoney(context, widthExpense,
                            type: 'expense'),
                    style: body(color: redCrayola)),
              ],
            )
          ],
        );
      }
      return const SizedBox();
    });
  }
}
