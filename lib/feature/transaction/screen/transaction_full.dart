import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/widget/app_bar_cpn.dart';
import 'package:monsey/feature/transaction/bloc/transactions/bloc_transactions.dart';
import 'package:monsey/feature/transaction/widget/calendar_range.dart';

import '../../../common/constant/colors.dart';
import '../../../common/constant/env.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/animation_click.dart';
import '../../../translations/export_lang.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../widget/transaction_widget.dart';
import 'select_wallet.dart';

const INDEX_MONTH_CURRENT = 10;

class TransactionFull extends StatefulWidget {
  const TransactionFull({Key? key, required this.walletModel})
      : super(key: key);
  final WalletModel walletModel;
  @override
  State<TransactionFull> createState() => _TransactionFullState();
}

class _TransactionFullState extends State<TransactionFull>
    with SingleTickerProviderStateMixin {
  late bool showRangeDate = false;
  DateTime? startDate;
  DateTime? endDate;
  WalletModel? _walletModel;
  late TabController _controller;
  TransactionsBloc? transactionsBloc;

  Future<void> selectWallet() async {
    final result = await Navigator.of(context).pushNamed(Routes.selectWallet,
        arguments: const SelectWallet(createTransaction: false)) as WalletModel;
    transactionsBloc!.add(InitialTransactions(result.id!));
    setState(() {
      showRangeDate = false;
      _walletModel = result;
      _controller.animateTo(INDEX_MONTH_CURRENT);
    });
  }

  Future<void> selectRangeDate() async {
    await showModalBottomSheet<Map<String, DateTime?>>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: white,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2.5,
          child: ListView(
            children: [
              CalendarRange(
                startDate: startDate,
                endDate: endDate,
              ),
            ],
          ),
        );
      },
      context: context,
    ).then((dynamic value) {
      if (value != null) {
        setState(() {
          showRangeDate = true;
          startDate = value['start'];
          endDate = value['end'];
          transactionsBloc!
              .add(RangeTransactions(_walletModel!.id!, startDate!, endDate!));
        });
      }
    });
  }

  @override
  void initState() {
    _walletModel = widget.walletModel;
    _controller = TabController(
        length: 12, vsync: this, initialIndex: INDEX_MONTH_CURRENT);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    transactionsBloc = BlocProvider.of<TransactionsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final bool isPremium =
        checkPremium(context.read<UserBloc>().userModel!.datePremium);
    return Scaffold(
        appBar: AppBarCpn(
          walletModel: _walletModel,
          color: emerald,
          function: selectWallet,
          right: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimationClick(
                function: () {
                  if (showRangeDate) {
                    setState(() {
                      showRangeDate = false;
                    });
                  } else {
                    _controller.animateTo(INDEX_MONTH_CURRENT);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    showRangeDate
                        ? LocaleKeys.month.tr()
                        : LocaleKeys.today.tr(),
                    style: footnote(color: grey1),
                  ),
                ),
              ),
              IconButton(
                onPressed: selectRangeDate,
                icon: Image.asset(
                  icCalendar,
                  width: 24,
                  height: 24,
                  color: white,
                ),
              )
            ],
          ),
          bottom: Column(
            children: [
              !isPremium
                  ? MaxAdView(
          adUnitId: AdHelper().bannerAdUnitIdApplovin,
          adFormat: AdFormat.banner,
          isAutoRefreshEnabled: true,
          listener: AdViewAdListener(
              onAdLoadedCallback: (ad) {},
              onAdLoadFailedCallback: (adUnitId, error) {},
              onAdClickedCallback: (ad) {},
              onAdExpandedCallback: (ad) {},
              onAdCollapsedCallback: (ad) {}))
                  : const SizedBox(),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: white),
                child: showRangeDate
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          '${FormatTime.formatTime(dateTime: startDate, format: Format.Mdy)} - ${FormatTime.formatTime(dateTime: endDate, format: Format.Mdy)}',
                          style: title4(context: context),
                        ),
                      )
                    : TabBar(
                        controller: _controller,
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
                        )),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _walletModel!.isLoanWallet
            ? const SizedBox()
            : addTransaction(
                context,
                _walletModel!,
                startDate: showRangeDate ? startDate : null,
                endDate: showRangeDate ? endDate : null,
              ),
        body: showRangeDate
            ? BlocBuilder<TransactionsBloc, TransactionsState>(
                builder: (context, state) {
                  if (state is TransactionsLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (state is TransactionsLoaded) {
                    return transactionsAllDays(
                        context, _walletModel!, state.transactionsRangeDate,
                        startDate: startDate, endDate: endDate);
                  }
                  return const SizedBox();
                },
              )
            : BlocBuilder<TransactionsBloc, TransactionsState>(
                builder: (context, state) {
                  if (state is TransactionsLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (state is TransactionsLoaded) {
                    return TabBarView(
                      controller: _controller,
                      children: List.generate(
                        12,
                        (index) => transactionsAllDays(
                            context,
                            _walletModel!,
                            state.transactionAllMonths[index]
                                .transactionsOneMonth,
                            startDate: null,
                            endDate: null),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ));
  }
}
