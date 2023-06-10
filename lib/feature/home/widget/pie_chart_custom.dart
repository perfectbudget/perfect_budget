import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/translations/export_lang.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/constant/styles.dart';
import '../../../common/model/chart_model.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/chart/bloc_chart.dart';

class PieChartCustom extends StatefulWidget {
  const PieChartCustom({Key? key, required this.typeAnalysis})
      : super(key: key);
  final String typeAnalysis;
  @override
  State<PieChartCustom> createState() => _PieChartCustomState();
}

class _PieChartCustomState extends State<PieChartCustom> {
  int _currentIndex = 0;
  String _title = LocaleKeys.allCategories.tr();
  String? _balanceString;
  double _balance = 1000;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    final bool isIncome = widget.typeAnalysis == 'income';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<ChartBloc, ChartState>(builder: (context, state) {
        if (state is ChartLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is ChartLoaded) {
          List<ChartData> dataPieChart =
              isIncome ? state.dataIncomePieChart : state.dataExpensePieChart;
          dataPieChart = handleChartData(dataPieChart, isIncome);
          _balance = isIncome ? state.incomeTotal : state.expenseTotal;
          return SfCircularChart(annotations: [
            CircularChartAnnotation(
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_title, style: subhead(color: black, fontWeight: '700')),
                  Text(
                      _balanceString ??
                          '$symbol${_balance < 1 && _balance >= 0 ? '0' : ''}${formatMoney(context).format(_balance)}',
                      style: body(color: isIncome ? blueCrayola : redCrayola)),
                ],
              ),
            ),
          ], series: <CircularSeries>[
            if (dataPieChart.isNotEmpty)
              DoughnutSeries<ChartData, String>(
                  onPointTap: (pointInteractionDetails) {
                    if (mounted) {
                      setState(() {
                        _currentIndex = pointInteractionDetails.pointIndex!;
                        _title =
                            dataPieChart[_currentIndex].categoryModel!.name;
                        _balanceString =
                            '$symbol${dataPieChart[_currentIndex].balance < 1 && dataPieChart[_currentIndex].balance >= 0 ? '0' : ''}${formatMoney(context).format(dataPieChart[_currentIndex].balance)}';
                      });
                    }
                  },
                  selectionBehavior: SelectionBehavior(
                      enable: true,
                      toggleSelection: true,
                      selectedBorderWidth: 4,
                      selectedBorderColor: colors[_currentIndex]),
                  dataSource: dataPieChart,
                  dataLabelSettings: DataLabelSettings(
                      builder: (dynamic data, dynamic point, dynamic series,
                          pointIndex, seriesIndex) {
                        return Text('${point.y}%',
                            style: footnote(color: grey1));
                      },
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside),
                  pointColorMapper: (ChartData data, index) {
                    return colors[index];
                  },
                  xValueMapper: (ChartData data, _) => data.categoryModel!.name,
                  yValueMapper: (ChartData data, index) {
                    final int balanceTmp =
                        handleBalance(dataPieChart, index, _balance, data);

                    return balanceTmp;
                  },
                  radius: '80%')
            else
              DoughnutSeries<ChartData, String>(
                  dataSource: [ChartData(balance: 0, trans: const [])],
                  pointColorMapper: (ChartData data, _) => grey4,
                  xValueMapper: (ChartData data, _) => '',
                  yValueMapper: (ChartData data, _) => 100,
                  radius: '80%'),
          ]);
        }
        return const SizedBox();
      }),
    );
  }
}
