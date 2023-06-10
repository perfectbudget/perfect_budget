import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/transaction_model.dart';

import '../../../common/constant/images.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../../transaction/widget/transaction_widget.dart';

class TransactionsDetail extends StatefulWidget {
  const TransactionsDetail(
      {Key? key,
      required this.title,
      required this.balance,
      required this.transactions})
      : super(key: key);
  final String title;
  final String balance;
  final List<TransactionModel> transactions;

  @override
  State<TransactionsDetail> createState() => _TransactionsDetailState();
}

class _TransactionsDetailState extends State<TransactionsDetail> {
  List<TransactionInDayModel> transactionsInTime = [];

  void handleTransactions(List<TransactionModel> transactions) {
    for (TransactionModel transaction in transactions) {
      final int index = transactionsInTime
          .indexWhere((element) => isSameDay(transaction.date, element.date));
      if (index != -1) {
        transactionsInTime[index].transactions.add(transaction);
      } else {
        transactionsInTime.add(TransactionInDayModel(
            date: transaction.date, transactions: [transaction]));
      }
    }
  }

  @override
  void initState() {
    handleTransactions(widget.transactions);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium =
        checkPremium(context.read<UserBloc>().userModel!.datePremium);
    return Scaffold(
        appBar: AppBarCpn(
          showWallet: false,
          color: emerald,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Image.asset(icArrowLeft,
                          width: 24, height: 24, color: white)),
                  const Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      widget.title,
                      style: headline(color: white),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  const Expanded(child: SizedBox()),
                  Text(
                    widget.balance,
                    style: title2(color: white),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              )
            ],
          ),
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16);
          },
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemCount: transactionsInTime.length,
          itemBuilder: (context, index) {
            return transactionsInDay(context, transactionsInTime[index],
                showAds: index == 0 && !isPremium ? true : false);
          },
        ));
  }
}
