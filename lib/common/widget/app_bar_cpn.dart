import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../feature/onboarding/bloc/user/bloc_user.dart';
import '../constant/colors.dart';

class AppBarCpn extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCpn(
      {Key? key,
      this.walletModel,
      this.size,
      this.child,
      this.center,
      this.right,
      this.color = Colors.transparent,
      this.bottom,
      this.function,
      this.left,
      this.showWallet = true})
      : super(key: key);
  final Size? size;
  final Widget? child;
  final Widget? center;
  final Widget? right;
  final Color color;
  final Widget? bottom;
  final Widget? left;
  final WalletModel? walletModel;
  final Function()? function;
  final bool showWallet;

  @override
  Size get preferredSize => size ?? const Size.fromHeight(kToolbarHeight + 240);

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return PreferredSize(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: color),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 16,
            ),
            child: child ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        left ??
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Image.asset(icArrowLeft,
                                    width: 24, height: 24, color: white)),
                        center ?? const SizedBox(),
                        right ?? const SizedBox(width: 24),
                      ],
                    ),
                    if (showWallet) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimationClick(
                          function: function ?? () {},
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: BlocBuilder<WalletsBloc, WalletsState>(
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
                        ),
                      )
                    ],
                  ],
                ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(color: color),
            child: bottom ?? const SizedBox(),
          )
        ],
      ),
      preferredSize: preferredSize,
    );
  }
}
