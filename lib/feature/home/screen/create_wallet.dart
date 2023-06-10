import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/type_wallet_model.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/common/widget/bottom_button.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/images.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);
  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  String? nameAccount;
  String? balance;
  String? nameTypeWallet;
  TypeWalletModel? typeWalletModel;
  late WalletsBloc walletsBloc;
  Future<void> setNameWallet() async {
    final result =
        await Navigator.of(context).pushNamed(Routes.nameWallet) as String;
    if (result != '')
      setState(() {
        nameAccount = result;
      });
  }

  Future<void> setBalanceWallet() async {
    final result =
        await Navigator.of(context).pushNamed(Routes.balanceWallet) as String?;
    setState(() {
      if (result != null) {
        balance = ('\$') + result;
        print('resultado ' + result);
      } else {
        print('fallamos señor stark');
      }
    });
  }

  Future<void> setTypeWallet() async {
    final result = await Navigator.of(context).pushNamed(Routes.typeWallet)
        as TypeWalletModel;
    setState(() {
      typeWalletModel = result;
      nameTypeWallet = result.name;
    });
  }

  @override
  void didChangeDependencies() {
    walletsBloc = BlocProvider.of<WalletsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool checked =
        nameAccount != null && balance != null && nameTypeWallet != null;
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context, title: LocaleKeys.createWallet.tr()),
      bottomNavigationBar: BottomButton(
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.create.tr(),
            onPressed: checked
                ? () {
                    walletsBloc.add(CreateWallet(
                        context,
                        WalletModel(
                            name: nameAccount!,
                            incomeBalance: double.tryParse(balance!
                                    .substring(1)
                                    .replaceAll(',', '')) ??
                                0,
                            expenseBalance: 0,
                            typeWalletId: typeWalletModel!.id,
                            userUuid: firebaseUser.uid)));
                    Navigator.of(context).pop();
                  }
                : () {},
            bgColor: checked ? emerald : grey5,
            textColor: white),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                AnimationClick(
                  function: setNameWallet,
                  child: Row(
                    children: [
                      Image.asset(
                        icNote,
                        width: 24,
                        height: 24,
                        color: purplePlum,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            nameAccount ?? LocaleKeys.nameAccount.tr(),
                            style: body(
                                color: nameAccount == null ? grey3 : grey1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                AppWidget.divider(context, vertical: 16),
                AnimationClick(
                  function: setBalanceWallet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset(
                              icCalculator,
                              width: 24,
                              height: 24,
                              color: purplePlum,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  balance ?? LocaleKeys.balance.tr(),
                                  style: body(
                                      color: balance == null ? grey3 : grey1),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: grey5,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              'USD',
                              style: subhead(color: grey1),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: grey3,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                AppWidget.divider(context, vertical: 16),
                AnimationClick(
                  function: setTypeWallet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            typeWalletModel == null
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        color: grey5,
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                  )
                                : Image.network(typeWalletModel!.icon,
                                    width: 24, height: 24, color: purplePlum),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  nameTypeWallet ?? LocaleKeys.type.tr(),
                                  style: body(
                                      color: nameTypeWallet == null
                                          ? grey3
                                          : grey1),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: grey3,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
