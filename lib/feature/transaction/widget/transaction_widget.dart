import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/model/transaction_goal_model.dart';
import 'package:monsey/common/model/transaction_model.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/preference/shared_preference_builder.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/images.dart';
import '../../../common/constant/styles.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/slidaction_widget.dart';
import '../../home/bloc/chart/bloc_chart.dart';
import '../../home/screen/chart_analysis.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/transactions/bloc_transactions.dart';
import '../screen/handle_transaction.dart';

const _kAdIndex = 3;

int _getDestinationItemIndex(int rawIndex) {
  if (rawIndex >= _kAdIndex) {
    return rawIndex - 1;
  }
  return rawIndex;
}

Widget totalBalance(
    BuildContext context, String type, String icon, double balance,
    {bool hasArrow = false, bool arrowRight = true}) {
  final String symbol =
      BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration:
        BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      icon,
                      width: 24,
                      height: 24,
                      color: type == 'income' ? bleuDeFrance : redCrayola,
                    ),
                  ),
                  Text(
                    type == 'income'
                        ? LocaleKeys.income.tr()
                        : LocaleKeys.expense.tr(),
                    style: body(context: context),
                  )
                ],
              ),
            ),
            hasArrow
                ? Icon(
                    arrowRight
                        ? Icons.keyboard_arrow_right_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24,
                  )
                : const SizedBox()
          ],
        ),
        FittedBox(
          child: Text(
            balance == 0
                ? '${type != 'income' ? "-" : ""}' +
                    (symbol == '₫' ? '${symbol}0' : '${symbol}0.00')
                : handleStyleMoney(context, balance, type: type),
            style: title3(color: type == 'income' ? bleuDeFrance : redCrayola),
          ),
        )
      ],
    ),
  );
}

void removeTransaction(
  BuildContext context,
  TransactionModel? transactionModel,
  DateTime? startDate,
  DateTime? endDate,
) {
  BlocProvider.of<TransactionsBloc>(context)
      .add(RemoveTransaction(context, transactionModel!, startDate, endDate));
  Navigator.of(context).pop();
}

Widget listTile(BuildContext context, TransactionModel transaction) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading:
        Image.network(transaction.categoryModel!.icon, width: 24, height: 24),
    minLeadingWidth: 12,
    title: Text(
      transaction.note ?? transaction.categoryModel!.name,
      style: body(context: context),
    ),
    subtitle: Text(
      FormatTime.formatTime(dateTime: transaction.date, format: Format.mdy),
      style: subhead(color: grey3),
    ),
    trailing: Text(
      handleStyleMoney(context, transaction.balance, type: transaction.type),
      style: callout(
          color: transaction.type == 'income' ? bleuDeFrance : redCrayola),
    ),
  );
}

Widget listTileTransGoal(
    BuildContext context, TransactionGoalModel transaction) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Image.asset(
      iconSaving,
      width: 32,
      height: 32,
    ),
    minLeadingWidth: 12,
    title: Text(
      transaction.note ?? LocaleKeys.addMoney.tr(),
      style: body(context: context),
    ),
    subtitle: Text(
      FormatTime.formatTime(dateTime: transaction.date, format: Format.mdy),
      style: subhead(color: grey3),
    ),
    trailing: Text(
      handleStyleMoney(context, transaction.balance, type: 'income'),
      style: callout(color: blueCrayola),
    ),
  );
}

Widget slideActionTran(BuildContext context, DateTime? startDate,
    DateTime? endDate, TransactionModel transaction,
    {WalletModel? walletModel}) {
  return walletModel == null || walletModel.isLoanWallet
      ? listTile(context, transaction)
      : SlidactionWidget(
          showLabel: false,
          extentRatio: 0.4,
          editFunc: () {
            Navigator.of(context).pushNamed(Routes.handleTransaction,
                arguments: HandleTransaction(
                  walletModel: walletModel,
                  transactionModel: transaction,
                  startDate: startDate,
                  endDate: endDate,
                ));
          },
          removeFunc: () {
            AppWidget.showDialogCustom(LocaleKeys.removeThisTransaction.tr(),
                context: context, remove: () {
              removeTransaction(context, transaction, startDate, endDate);
            });
          },
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.handleTransaction,
                  arguments: HandleTransaction(
                    walletModel: walletModel,
                    transactionModel: transaction,
                    startDate: startDate,
                    endDate: endDate,
                  ));
            },
            child: listTile(context, transaction),
          ),
        );
}

Widget transactionsInDay(
    BuildContext context, TransactionInDayModel transactionsInDay,
    {WalletModel? walletModel,
    DateTime? startDate,
    DateTime? endDate,
    bool showAds = false}) {
  final int length = transactionsInDay.transactions.length;
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration:
        BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            FormatTime.formatTime(
                    dateTime: transactionsInDay.date, format: Format.EMd)
                .toUpperCase(),
            style: title4(context: context),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          height: 1,
          decoration: const BoxDecoration(color: grey6),
        ),
        ListView.separated(
          separatorBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: 1,
              decoration: const BoxDecoration(color: grey6),
            );
          },
          padding: const EdgeInsets.only(bottom: 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: length < 4 ? length + 1 : length,
          itemBuilder: (context, index) {
            transactionsInDay.transactions
                .sort((a, b) => b.date.compareTo(a.date));
            if (length < 4) {
              return index == length
                  // ? (showAds ? const AdsNative() : const SizedBox())
                  ? (showAds ? const SizedBox() : const SizedBox())
                  : slideActionTran(
                      context,
                      startDate,
                      endDate,
                      transactionsInDay.transactions[index],
                      walletModel: walletModel,
                    );
            } else {
              final item = transactionsInDay
                  .transactions[_getDestinationItemIndex(index)];
              return index == _kAdIndex
                  // ? (showAds ? const AdsNative() : const SizedBox())
                  ? (showAds ? const SizedBox() : const SizedBox())
                  : slideActionTran(
                      context,
                      startDate,
                      endDate,
                      item,
                      walletModel: walletModel,
                    );
            }
          },
        )
      ],
    ),
  );
}

Widget addTransaction(BuildContext context, WalletModel walletModel,
    {double padding = 16, DateTime? startDate, DateTime? endDate}) {
  return AnimationClick(
    function: () async {
      final preCgExpense = await getCategory(input: 'categoryExpense');
      final preCgIncome = await getCategory();
      Navigator.of(context).pushNamed(Routes.handleTransaction,
          arguments: HandleTransaction(
            walletModel: walletModel,
            preCgExpense: preCgExpense,
            preCgIncome: preCgIncome,
            startDate: startDate,
            endDate: endDate,
          ));
    },
    child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: emerald, borderRadius: BorderRadius.circular(20)),
        child: const Icon(
          Icons.add,
          size: 24,
          color: white,
        )),
  );
}

Widget transactionsAllDays(BuildContext context, WalletModel walletModel,
    List<TransactionInDayModel> transactionInMonth,
    {Function()? function, DateTime? startDate, DateTime? endDate}) {
  transactionInMonth.toSet();
  transactionInMonth.sort((a, b) => b.date.compareTo(a.date));
  double totalIncome = 0;
  double totalExpense = 0;
  for (TransactionInDayModel transactionInDayModel in transactionInMonth) {
    for (TransactionModel transactionModel
        in transactionInDayModel.transactions) {
      if (transactionModel.type == 'income') {
        totalIncome += transactionModel.balance;
      } else {
        totalExpense += transactionModel.balance;
      }
    }
  }
  final bool isPremium =
      checkPremium(context.read<UserBloc>().userModel!.datePremium);
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          Expanded(
            child: AnimationClick(
                function: () {
                  context.read<ChartBloc>().add(ChangeTimeChart(
                      walletId: walletModel.id!, dateTime: now));
                  Navigator.of(context).pushNamed(Routes.chartAnalysis,
                      arguments: ChartAnalysis(
                        datetime: now,
                        curInxTypeDate: 0,
                        walletModel: walletModel,
                        typeAnalysis: 'income',
                      ));
                },
                child: totalBalance(context, 'income', icIncome2, totalIncome)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimationClick(
                function: () {
                  context.read<ChartBloc>().add(ChangeTimeChart(
                      walletId: walletModel.id!, dateTime: now));
                  Navigator.of(context).pushNamed(Routes.chartAnalysis,
                      arguments: ChartAnalysis(
                        datetime: now,
                        curInxTypeDate: 0,
                        walletModel: walletModel,
                        typeAnalysis: 'expense',
                      ));
                },
                child:
                    totalBalance(context, 'expense', icExpense, totalExpense)),
          )
        ],
      ),
      const SizedBox(height: 16),
      transactionInMonth.isEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.transactions.tr().toUpperCase(),
                        style: title4(context: context),
                      ),
                      walletModel.isLoanWallet
                          ? const SizedBox()
                          : addTransaction(context, walletModel,
                              padding: 10,
                              startDate: startDate,
                              endDate: endDate)
                    ],
                  ),
                  AppWidget.divider(context, vertical: 8),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 32, right: 32, top: 16),
                    child: Text(
                        walletModel.isLoanWallet
                            ? "You don't have any transaction yet"
                            : LocaleKeys.tapButton.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: title4(color: grey3)),
                  )
                ],
              ))
          : ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              padding: const EdgeInsets.symmetric(vertical: 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactionInMonth.length,
              itemBuilder: (context, index) {
                return transactionsInDay(context, transactionInMonth[index],
                    walletModel: walletModel,
                    startDate: startDate,
                    endDate: endDate,
                    showAds: index == 0 && !isPremium ? true : false);
              },
            )
    ],
  );
}
