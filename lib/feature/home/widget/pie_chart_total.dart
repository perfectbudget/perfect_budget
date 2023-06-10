import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/constant/styles.dart';
import '../../../common/model/chart_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../bloc/chart/bloc_chart.dart';
import '../screen/transactions_detail.dart';

class PieChartTotal extends StatefulWidget {
  const PieChartTotal({Key? key}) : super(key: key);
  @override
  State<PieChartTotal> createState() => _PieChartTotalState();
}

class _PieChartTotalState extends State<PieChartTotal> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(builder: (context, state) {
      if (state is ChartLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (state is ChartLoaded) {
        final List<ChartPieTotalBalance> totalBalancePieChart = [];
        final List<ChartData> dataPieChart = state.dataPieChart;
        final double income = state.incomeTotal;
        final double expense = state.expenseTotal;
        if (income > 0) {
          totalBalancePieChart.add(
              ChartPieTotalBalance('income', blueCrayola, balance: income));
        }
        if (expense > 0) {
          totalBalancePieChart.add(
              ChartPieTotalBalance('expense', redCrayola, balance: expense));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            SizedBox(
              height: 350,
              child: SfCircularChart(series: <CircularSeries>[
                totalBalancePieChart.isNotEmpty
                    ? DoughnutSeries<ChartPieTotalBalance, String>(
                        dataSource: totalBalancePieChart,
                        dataLabelSettings: DataLabelSettings(
                            builder: (dynamic data, dynamic point,
                                dynamic series, pointIndex, seriesIndex) {
                              return Text(
                                  handleStyleMoney(context, data.balance,
                                      type: data.type),
                                  style: footnote(
                                      color: data.type == 'income'
                                          ? blueCrayola
                                          : redCrayola));
                            },
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside),
                        pointColorMapper: (ChartPieTotalBalance data, _) =>
                            data.color,
                        xValueMapper: (ChartPieTotalBalance data, _) => '',
                        yValueMapper: (ChartPieTotalBalance data, index) {
                          return data.balance / (income + expense) * 100;
                        },
                        radius: '70%')
                    : DoughnutSeries<ChartPieTotalBalance, String>(
                        dataSource: const [
                            ChartPieTotalBalance('', grey4, balance: 0)
                          ],
                        pointColorMapper: (ChartPieTotalBalance data, _) =>
                            data.color,
                        xValueMapper: (ChartPieTotalBalance data, _) => '',
                        yValueMapper: (ChartPieTotalBalance data, _) => 100,
                        radius: '70%'),
              ]),
            ),
            ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 24),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.transactionsDetail,
                          arguments: TransactionsDetail(
                            transactions: dataPieChart[index].trans,
                            title: dataPieChart[index].categoryModel!.name,
                            balance: handleStyleMoney(
                                context, dataPieChart[index].balance,
                                type: dataPieChart[index].categoryModel!.type),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Image.network(dataPieChart[index].categoryModel!.icon,
                              width: 24, height: 24),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              dataPieChart[index].categoryModel!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: subhead(color: grey1),
                            ),
                          ),
                          Text(
                            handleStyleMoney(
                                context, dataPieChart[index].balance,
                                type: dataPieChart[index].categoryModel!.type),
                            style: headline(
                                color:
                                    dataPieChart[index].categoryModel!.type ==
                                            'income'
                                        ? blueCrayola
                                        : redCrayola),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 20);
                },
                itemCount: dataPieChart.length)
          ],
        );
      }
      return const SizedBox();
    });
  }
}
