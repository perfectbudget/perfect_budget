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
import '../../../common/util/helper.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class EditWalletScreen extends StatefulWidget {
  const EditWalletScreen(
      {Key? key, required this.totalWallet, required this.walletModel})
      : super(key: key);
  final WalletModel walletModel;
  final int totalWallet;
  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  String? nameAccount;
  String? nameTypeWallet;
  TypeWalletModel? typeWalletModel;
  Future<void> setNameWallet() async {
    final result =
        await Navigator.of(context).pushNamed(Routes.nameWallet) as String;
    if (result != '')
      setState(() {
        nameAccount = result;
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

  void removeWallet() {
    context.read<WalletsBloc>().add(RemoveWallet(context, widget.walletModel));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    nameAccount = widget.walletModel.name;
    typeWalletModel = widget.walletModel.typeWalletModel!;
    nameTypeWallet = widget.walletModel.typeWalletModel!.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.editWallet.tr(),
          onTap: widget.walletModel.isLoanWallet
              ? () {}
              : () {
                  AppWidget.showDialogCustom(LocaleKeys.removeThisWallet.tr(),
                      context: context, remove: removeWallet);
                },
          action: widget.walletModel.isLoanWallet
              ? const SizedBox()
              : const Icon(Icons.delete_outline_rounded,
                  size: 24, color: grey1)),
      bottomNavigationBar: BottomButton(
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.save.tr(),
            onPressed: () {
              context.read<WalletsBloc>().add(EditWallet(WalletModel(
                  id: widget.walletModel.id,
                  name: nameAccount!,
                  incomeBalance: widget.walletModel.incomeBalance,
                  expenseBalance: widget.walletModel.expenseBalance,
                  typeWalletModel: typeWalletModel,
                  typeWalletId: typeWalletModel!.id,
                  userUuid: firebaseUser.uid)));
              Navigator.of(context).pop();
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/images/card${randomIndex(widget.totalWallet)}@3x.png'),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        typeWalletModel != null
                            ? typeWalletModel!.icon
                            : widget.walletModel.typeWalletModel!.icon,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        color: white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          nameAccount ?? widget.walletModel.name,
                          style: headline(color: white),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  LocaleKeys.balance.tr(),
                  style: callout(color: white.withOpacity(0.7)),
                ),
              ),
              Text(
                calculatorBalance(context, widget.walletModel.incomeBalance,
                    widget.walletModel.expenseBalance),
                style: title3(color: white),
              )
            ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
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
                Row(
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
                                calculatorBalance(
                                    context,
                                    widget.walletModel.incomeBalance,
                                    widget.walletModel.expenseBalance),
                                style: body(color: grey5),
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
                            BlocProvider.of<UserBloc>(context)
                                    .userModel!
                                    .currencyCode ??
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
                AppWidget.divider(context, vertical: 16),
                AnimationClick(
                  function: setTypeWallet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Image.network(typeWalletModel!.icon,
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
