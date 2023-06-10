import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/home/screen/transactions_detail.dart';
import 'package:monsey/feature/home/widget/pie_chart_custom.dart';

import '../../../common/constant/enums.dart';
import '../../../common/constant/images.dart';
import '../../../common/model/chart_model.dart';
import '../../../common/util/format_time.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../../translations/export_lang.dart';
import '../../transaction/widget/transaction_widget.dart';
import '../bloc/chart/bloc_chart.dart';

const INDEX_MONTH_CURRENT = 10;
const INDEX_YEAR_CURRENT = 4;
const List<TypeDate> typeDate = [
  TypeDate.MONTHLY,
  TypeDate.YEARLY,
  TypeDate.ALLTIME
];

class ChartAnalysis extends StatefulWidget {
  const ChartAnalysis(
      {Key? key,
      this.walletModel,
      required this.typeAnalysis,
      required this.curInxTypeDate,
      this.curInxMonth,
      this.curInxYear,
      this.datetime})
      : super(key: key);
  final WalletModel? walletModel;
  final String typeAnalysis;
  final int curInxTypeDate;
  final int? curInxMonth;
  final int? curInxYear;
  final DateTime? datetime;
  @override
  State<ChartAnalysis> createState() => _ChartAnalysisState();
}

class _ChartAnalysisState extends State<ChartAnalysis>
    with TickerProviderStateMixin {
  late TabController _controllerMonth;
  late TabController _controllerYear;
  int _curInxTypeDate = 0;
  int _curInxMonth = 0;
  int _curInxYear = 0;
  DateTime _dateTime = now;
  TypeDate checkTypeDate() {
    return _curInxTypeDate == 0
        ? TypeDate.MONTHLY
        : _curInxTypeDate == 1
            ? TypeDate.YEARLY
            : TypeDate.ALLTIME;
  }

  Widget tabbar(int _curInx) {
    final width = AppWidget.getWidthScreen(context);
    switch (_curInx) {
      case 1:
        return TabBar(
            controller: _controllerYear,
            onTap: (value) {
              _curInxYear = value;
              _dateTime = DateTime(now.year - INDEX_YEAR_CURRENT + value);
              context.read<ChartBloc>().add(ChangeTimeChart(
                  typeDate: TypeDate.YEARLY,
                  walletId:
                      widget.walletModel == null ? 0 : widget.walletModel!.id!,
                  dateTime: _dateTime));
            },
            isScrollable: true,
            labelStyle: body(color: purplePlum),
            unselectedLabelStyle: body(color: grey2),
            labelColor: purplePlum,
            unselectedLabelColor: grey2,
            indicatorColor: purplePlum,
            indicatorWeight: 2,
            tabs: List.generate(
              6,
              (index) => SizedBox(
                width: width / 5 - 24,
                child: Tab(
                  text: FormatTime.formatTime(
                      dateTime: DateTime(now.year - INDEX_YEAR_CURRENT + index),
                      format: Format.y),
                ),
              ),
            ));
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '${LocaleKeys.allTime.tr()} (${now.year - INDEX_YEAR_CURRENT}-${now.year + 1})',
            style: subhead(context: context),
          ),
        );
      default:
        return TabBar(
            controller: _controllerMonth,
            onTap: (value) {
              _curInxMonth = value;
              _dateTime = DateTime(
                  now.year,
                  now.month - INDEX_MONTH_CURRENT + value,
                  now.day == 1 ? now.day : (now.day - 1));

              context.read<ChartBloc>().add(ChangeTimeChart(
                  walletId:
                      widget.walletModel == null ? 0 : widget.walletModel!.id!,
                  dateTime: _dateTime));
            },
            physics: const NeverScrollableScrollPhysics(),
            isScrollable: true,
            labelStyle: body(color: purplePlum),
            unselectedLabelStyle: body(color: grey2),
            labelColor: purplePlum,
            unselectedLabelColor: grey2,
            indicatorColor: purplePlum,
            indicatorWeight: 2,
            tabs: List.generate(
              12,
              (index) => SizedBox(
                width: width / 3 - 24,
                child: Tab(
                  text: FormatTime.formatTime(
                      dateTime: DateTime(
                          now.year,
                          now.month - INDEX_MONTH_CURRENT + index,
                          now.day == 1 ? now.day : (now.day - 1)),
                      format: Format.My),
                ),
              ),
            ));
    }
  }

  Future<void> selectTypeDate() async {
    await showModalBottomSheet<Map<String, DateTime?>>(
      backgroundColor: white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimationClick(
                function: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    LocaleKeys.done.tr(),
                    style: headline(context: context),
                  ),
                ),
              ),
              ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return AnimationClick(
                        function: () {
                          setState(() {
                            _curInxTypeDate = index;
                          });
                          context.read<ChartBloc>().add(ChangeTimeChart(
                              typeDate: checkTypeDate(),
                              walletId: widget.walletModel == null
                                  ? 0
                                  : widget.walletModel!.id!,
                              dateTime: now));
                          if (_curInxTypeDate == 0) {
                            _controllerMonth.animateTo(INDEX_MONTH_CURRENT);
                          }
                          if (_curInxTypeDate == 1) {
                            _controllerYear.animateTo(INDEX_YEAR_CURRENT);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                              index == 0
                                  ? LocaleKeys.monthly.tr()
                                  : index == 1
                                      ? LocaleKeys.yearly.tr()
                                      : LocaleKeys.allTime.tr(),
                              style: _curInxTypeDate == index
                                  ? headline(context: context)
                                  : body(color: grey3)),
                        ));
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 32);
                  },
                  itemCount: typeDate.length)
            ],
          ),
        );
      },
      context: context,
    );
  }

  @override
  void initState() {
    _dateTime = widget.datetime ?? now;
    _curInxTypeDate = widget.curInxTypeDate;
    _curInxMonth = widget.curInxMonth ?? INDEX_MONTH_CURRENT;
    _curInxYear = widget.curInxYear ?? INDEX_YEAR_CURRENT;
    _controllerMonth =
        TabController(length: 12, vsync: this, initialIndex: _curInxMonth);
    _controllerYear =
        TabController(length: 6, vsync: this, initialIndex: _curInxYear);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.typeAnalysis == 'income';
    return Scaffold(
      appBar: AppBarCpn(
        color: white,
        left: IconButton(
            onPressed: () {
              final result = {
                'typeDate': checkTypeDate(),
                'dateTime': _dateTime,
                'curIndex': _curInxTypeDate == 0
                    ? _curInxMonth
                    : _curInxTypeDate == 1
                        ? _curInxYear
                        : 0
              };
              Navigator.of(context).pop(result);
            },
            icon:
                Image.asset(icArrowLeft, width: 24, height: 24, color: grey1)),
        showWallet: false,
        center: Text(
          !isIncome
              ? LocaleKeys.expenseAnalysis.tr()
              : LocaleKeys.incomeAnalysis.tr(),
          style: headline(color: grey1),
        ),
        right: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: selectTypeDate,
              icon: Image.asset(
                icCalendar,
                width: 24,
                height: 24,
                color: grey2,
              ),
            )
          ],
        ),
        bottom: Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: white),
          child: tabbar(_curInxTypeDate),
        ),
      ),
      body: BlocBuilder<ChartBloc, ChartState>(builder: (context, state) {
        if (state is ChartLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is ChartLoaded) {
          List<ChartData> dataPieChart =
              isIncome ? state.dataIncomePieChart : state.dataExpensePieChart;
          dataPieChart = handleChartData(dataPieChart, isIncome);

          return ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: white,
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    !isIncome
                        ? totalBalance(
                            context, 'expense', icExpense, state.expenseTotal)
                        : totalBalance(
                            context, 'income', icIncome2, state.incomeTotal),
                    SizedBox(
                      height: 400,
                      child: PieChartCustom(
                        typeAnalysis: widget.typeAnalysis,
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dataPieChart.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemBuilder: (context, index) {
                  final String balance = handleStyleMoney(
                      context, dataPieChart[index].balance,
                      type: dataPieChart[index].categoryModel!.type);
                  final int balanceTmp = handleBalance(
                      dataPieChart,
                      index,
                      isIncome ? state.incomeTotal : state.expenseTotal,
                      dataPieChart[index]);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.transactionsDetail,
                          arguments: TransactionsDetail(
                            transactions: dataPieChart[index].trans,
                            title: dataPieChart[index].categoryModel!.name,
                            balance: balance,
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                  dataPieChart[index].categoryModel!.icon,
                                  width: 24,
                                  height: 24),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  dataPieChart[index].categoryModel!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: footnote(color: grey1),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            child: Text(
                              balance,
                              style: headline(
                                  color: isIncome ? blueCrayola : redCrayola),
                            ),
                          ),
                          Text(
                            '$balanceTmp%',
                            style: caption1(color: grey3),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          );
        }
        return const SizedBox();
      }),
    );
  }
}
