import 'package:flutter/material.dart';
import 'package:monsey/common/widget/textfield.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/widget/unfocus_click.dart';
import '../../../translations/export_lang.dart';

class NameWallet extends StatefulWidget {
  const NameWallet({Key? key}) : super(key: key);

  @override
  State<NameWallet> createState() => _NameWalletState();
}

class _NameWalletState extends State<NameWallet> {
  TextEditingController nameWalletCtl = TextEditingController();
  FocusNode nameWalletFn = FocusNode();
  @override
  void dispose() {
    nameWalletCtl.dispose();
    nameWalletFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.nameWallet.tr(),
          onBack: () {
            Navigator.of(context).pop(nameWalletCtl.text.trim());
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: () {
              Navigator.of(context).pop(nameWalletCtl.text.trim());
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: UnfocusClick(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          children: [
            TextFieldCpn(
              autoFocus: true,
              controller: nameWalletCtl,
              focusNode: nameWalletFn,
              hintText: LocaleKeys.yourNameWallet.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
