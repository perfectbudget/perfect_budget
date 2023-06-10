import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/home/bloc/chart/bloc_chart.dart';
import 'package:monsey/feature/home/widget/group_bar_chart_custom.dart';
import 'package:monsey/feature/home/widget/pie_chart_total.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/images.dart';
import '../../../common/model/wallet_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/format_time.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../../translations/export_lang.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../../transaction/screen/select_wallet.dart';
import '../../transaction/widget/transaction_widget.dart';
import '../bloc/wallets/bloc_wallets.dart';
import 'chart_analysis.dart';

const INDEX_MONTH_CURRENT = 10;
const INDEX_YEAR_CURRENT = 4;
const List<TypeDate> typeDate = [
  TypeDate.MONTHLY,
  TypeDate.YEARLY,
  TypeDate.ALLTIME
];

class Statictis extends StatefulWidget {
  const Statictis({Key? key}) : super(key: key);

  @override
  State<Statictis> createState() => _StatictisState();
}

class _StatictisState extends State<Statictis> with TickerProviderStateMixin {
  late TabController _controllerMonth;
  late TabController _controllerYear;
  int _curInxTypeDate = 0;
  int _curInxMonth = INDEX_MONTH_CURRENT;
  int _curInxYear = INDEX_YEAR_CURRENT;
  WalletModel? walletModel;
  DateTime _dateTime = now;

  TypeDate checkTypeDate() {
    return _curInxTypeDate == 0
        ? TypeDate.MONTHLY
        : _curInxTypeDate == 1
            ? TypeDate.YEARLY
            : TypeDate.ALLTIME;
  }

  Future<void> selectWallet() async {
    final result = await Navigator.of(context).pushNamed(Routes.selectWallet,
        arguments: const SelectWallet(createTransaction: false)) as WalletModel;
    setState(() {
      walletModel = result;
      context.read<ChartBloc>().add(ChangeTimeChart(
          typeDate: checkTypeDate(),
          walletId: walletModel!.id!,
          dateTime: _dateTime));
    });
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
                              walletId:
                                  walletModel == null ? 0 : walletModel!.id!,
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

  Widget tabbar() {
    final width = AppWidget.getWidthScreen(context);
    switch (_curInxTypeDate) {
      case 1:
        return TabBar(
            controller: _controllerYear,
            onTap: (value) {
              _curInxYear = value;
              _dateTime = DateTime(now.year - INDEX_YEAR_CURRENT + value);
              context.read<ChartBloc>().add(ChangeTimeChart(
                  typeDate: TypeDate.YEARLY,
                  walletId: walletModel == null ? 0 : walletModel!.id!,
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
                  walletId: walletModel == null ? 0 : walletModel!.id!,
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

  Future<void> navigateChart(String typeAnalysis) async {
    final dynamic result =
        await Navigator.of(context).pushNamed(Routes.chartAnalysis,
            arguments: ChartAnalysis(
              datetime: _dateTime,
              curInxMonth: _curInxMonth,
              curInxYear: _curInxYear,
              curInxTypeDate: _curInxTypeDate,
              walletModel: walletModel,
              typeAnalysis: typeAnalysis,
            ));
    setState(() {
      if (mounted) {
        _dateTime = result['dateTime'];
        if (result['typeDate'] == TypeDate.MONTHLY) {
          _curInxTypeDate = 0;
          _curInxMonth = result['curIndex'];
          _controllerMonth.animateTo(_curInxMonth);
        } else if (result['typeDate'] == TypeDate.YEARLY) {
          _curInxTypeDate = 1;
          _curInxYear = result['curIndex'];
          _controllerYear.animateTo(_curInxYear);
        } else {
          _curInxTypeDate = 2;
        }
      }
    });

    context.read<ChartBloc>().add(ChangeTimeChart(
        typeDate: result['typeDate'],
        walletId: walletModel == null ? 0 : walletModel!.id!,
        dateTime: result['dateTime']));
  }

  Widget totalBalanceWidget(double income, double expense) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: AnimationClick(
              function: () {
                navigateChart('income');
              },
              child: totalBalance(context, 'income', icIncome2, income,
                  hasArrow: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimationClick(
              function: () {
                navigateChart('expense');
              },
              child: totalBalance(context, 'expense', icExpense, expense,
                  hasArrow: true),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _controllerMonth = TabController(
        length: 12, vsync: this, initialIndex: INDEX_MONTH_CURRENT);
    _controllerYear =
        TabController(length: 6, vsync: this, initialIndex: INDEX_YEAR_CURRENT);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return BlocBuilder<WalletsBloc, WalletsState>(builder: (context, state) {
      if (state is WalletsLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (state is WalletsLoaded) {
        final List<WalletModel> wallets = state.wallets;
        return Scaffold(
          appBar: AppBarCpn(
            walletModel: walletModel,
            color: emerald,
            showWallet: false,
            left: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimationClick(
                    function: wallets.isEmpty
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              AppWidget.customSnackBar(
                                content: 'You need to create a wallet',
                              ),
                            );
                          }
                        : selectWallet,
                    child: Row(
                      children: [
                        Text(
                          walletModel != null
                              ? walletModel!.name
                              : LocaleKeys.allWallets.tr(),
                          style: body(color: white),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 16,
                          color: white,
                        )
                      ],
                    ),
                  ),
                  BlocBuilder<WalletsBloc, WalletsState>(
                    builder: (context, state) {
                      if (state is WalletsLoading) {
                        return Text(
                          symbol == '₫' ? '${symbol}0' : '${symbol}0.00',
                          style: title2(color: white),
                        );
                      }
                      if (state is WalletsLoaded) {
                        WalletModel? newWallet;
                        if (walletModel != null) {
                          newWallet = state.wallets
                              .firstWhere((e) => e.id == walletModel!.id);
                        }

                        return Text(
                          newWallet != null
                              ? calculatorBalance(
                                  context,
                                  newWallet.incomeBalance,
                                  newWallet.expenseBalance)
                              : '$symbol${state.totalBalanceAllWallets < 1 && state.totalBalanceAllWallets >= 0 ? '0' : ''}${formatMoney(context).format(state.totalBalanceAllWallets)}',
                          style: title2(color: white),
                        );
                      }
                      return Text(
                        symbol == '₫' ? '${symbol}0' : '${symbol}0.00',
                        style: title2(color: white),
                      );
                    },
                  )
                ],
              ),
            ),
            right: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: selectTypeDate,
                  icon: Image.asset(
                    icCalendar,
                    width: 32,
                    height: 32,
                    color: white,
                  ),
                )
              ],
            ),
            bottom: Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: white),
              child: tabbar(),
            ),
          ),
          body: BlocBuilder<ChartBloc, ChartState>(builder: (context, state) {
            if (state is ChartLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is ChartLoaded) {
              return Column(
                children: [
                  totalBalanceWidget(state.incomeTotal, state.expenseTotal),
                  Expanded(
                      child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: white,
                    ),
                    margin:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: _curInxTypeDate == 1
                        ? ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(12),
                            itemBuilder: (context, index) {
                              return GroupBarChartCustom(
                                index: index,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 20);
                            },
                            itemCount: state.showingBarGroups.length)
                        : const PieChartTotal(),
                  )),
                ],
              );
            }
            return const SizedBox();
          }),
        );
      }
      return const SizedBox();
    });
  }
}
