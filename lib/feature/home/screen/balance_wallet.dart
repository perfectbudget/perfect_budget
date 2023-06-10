import 'package:flutter/material.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/widget/textfield_balance.dart';
import '../../../common/widget/unfocus_click.dart';
import '../../../translations/export_lang.dart';

class BalanceWallet extends StatefulWidget {
  const BalanceWallet({Key? key}) : super(key: key);

  @override
  State<BalanceWallet> createState() => _BalanceWalletState();
}

class _BalanceWalletState extends State<BalanceWallet> {
  TextEditingController balanceWalletCtl = TextEditingController();
  FocusNode balanceWalletFn = FocusNode();
  @override
  void dispose() {
    balanceWalletCtl.dispose();
    balanceWalletFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.walletBalance.tr(),
          onBack: () {
            Navigator.of(context).pop(balanceWalletCtl.text.trim().isNotEmpty
                ? balanceWalletCtl.text.trim()
                : null);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: () {
              Navigator.of(context).pop(balanceWalletCtl.text.trim().isNotEmpty
                  ? balanceWalletCtl.text.trim()
                  : null);
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: UnfocusClick(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            TextFieldBalanceCpn(
                showSymbol: false,
                controller: balanceWalletCtl,
                focusNode: balanceWalletFn,
                showPrefixIcon: true),
          ],
        ),
      ),
    );
  }
}
