import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/widget/animation_click.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../translations/export_lang.dart';
import '../../home/bloc/wallets/bloc_wallets.dart';

class SelectWallet extends StatefulWidget {
  const SelectWallet({Key? key, this.createTransaction = true})
      : super(key: key);
  final bool createTransaction;
  @override
  State<SelectWallet> createState() => _SelectWalletState();
}

class _SelectWalletState extends State<SelectWallet> {
  List<WalletModel> walletsTotal = [];
  List<Map<String, dynamic>> wallets = [];

  Widget item(Map<String, dynamic> wallet) {
    return AnimationClick(
      function: () {
        setState(() {
          for (dynamic tmpWallet in wallets) {
            tmpWallet['selected'] = false;
          }
          wallet['selected'] = !wallet['selected'];
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Image.network(
                  wallet['item'].typeWalletModel.icon,
                  width: 24,
                  height: 24,
                  color: purplePlum,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      wallet['item'].name,
                      style: body(color: grey1),
                    ),
                  ),
                )
              ],
            ),
          ),
          Checkbox(
              activeColor: emerald,
              shape: const CircleBorder(),
              value: wallet['selected'],
              onChanged: (value) {
                setState(() {
                  for (dynamic typeWallet in wallets) {
                    typeWallet['selected'] = false;
                  }
                  wallet['selected'] = value;
                });
              })
        ],
      ),
    );
  }

  @override
  void initState() {
    walletsTotal = widget.createTransaction
        ? BlocProvider.of<WalletsBloc>(context)
            .walletsTotal
            .where((element) => !element.isLoanWallet)
            .toList()
        : BlocProvider.of<WalletsBloc>(context).walletsTotal;
    wallets = List.generate(
        walletsTotal.length,
        (index) => <String, dynamic>{
              'item': walletsTotal[index],
              'selected': index == 0 ? true : false,
            });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: widget.createTransaction
              ? LocaleKeys.walletType.tr()
              : LocaleKeys.selectWallet.tr(),
          onBack: () {
            for (Map<String, dynamic> typeWallet in wallets) {
              if (typeWallet['selected']) {
                Navigator.of(context).pop(typeWallet['item']);
              }
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: () {
              for (Map<String, dynamic> typeWallet in wallets) {
                if (typeWallet['selected']) {
                  Navigator.of(context).pop(typeWallet['item']);
                }
              }
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: ListView(
        padding:
            const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 48),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              padding: const EdgeInsets.symmetric(vertical: 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                return item(wallets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
