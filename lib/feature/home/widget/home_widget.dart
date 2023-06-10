import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/route/routes.dart';
import '../../../common/widget/slidaction_widget.dart';
import '../bloc/wallets/bloc_wallets.dart';
import '../screen/edit_wallet.dart';

BottomNavigationBarItem createItemNav(
    BuildContext context, String iconInactive, String iconActive, String label,
    {bool hasIntro = false}) {
  return BottomNavigationBarItem(
      activeIcon: Image.asset(
        iconActive,
        width: 24,
        height: 24,
        color: emerald,
        fit: BoxFit.cover,
      ),
      icon: Image.asset(
        iconInactive,
        width: 24,
        height: 24,
        color: grey3,
        fit: BoxFit.cover,
      ),
      label: label);
}

void removeWallet(BuildContext context, WalletModel walletModel) {
  context.read<WalletsBloc>().add(RemoveWallet(context, walletModel));
  Navigator.of(context).pop();
}

Widget cardWallet(
    BuildContext context, WalletModel walletModel, int lengthList, int index) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/card${index % 12}@3x.png'),
          fit: BoxFit.cover),
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 24),
    child: SlidactionWidget(
      extentRatio: walletModel.isLoanWallet ? 0.3 : 0.6,
      editFunc: () {
        Navigator.of(context).pushNamed(Routes.editWallet,
            arguments: EditWalletScreen(
                totalWallet: lengthList, walletModel: walletModel));
      },
      removeFunc: walletModel.isLoanWallet
          ? null
          : () {
              AppWidget.showDialogCustom(LocaleKeys.removeThisWallet.tr(),
                  context: context, remove: () {
                removeWallet(context, walletModel);
              });
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    walletModel.typeWalletModel!.icon,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    color: white,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      walletModel.name,
                      style: headline(color: white),
                    ),
                  )
                ],
              ),
              Image.asset(
                icCircleArrowRight,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                color: white,
              )
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
            calculatorBalance(
                context, walletModel.incomeBalance, walletModel.expenseBalance),
            style: title3(color: white),
          )
        ]),
      ),
    ),
  );
}
