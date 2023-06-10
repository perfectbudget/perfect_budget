import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/feature/home/screen/edit_wallet.dart';
import 'package:monsey/feature/home/widget/home_widget.dart';
import 'package:monsey/feature/transaction/bloc/transactions/bloc_transactions.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/env.dart';
import '../../../common/constant/images.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../../transaction/screen/transaction_full.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key, this.hasLeading = false}) : super(key: key);
  final bool hasLeading;

  Widget listWallets(BuildContext context, List<WalletModel> wallets,
      double totalBalanceAllWallets, bool isPremium) {
    final symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return Scaffold(
      backgroundColor: emerald,
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          hasLeading: hasLeading,
          arrowColor: white,
          backgroundColor: emerald,
          title: LocaleKeys.wallets.tr(),
          onTap: () {
            // if (wallets.length >= 2 && !isPremium) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     AppWidget.customSnackBar(
            //       content: LocaleKeys.upgradePremium.tr(),
            //     ),
            //   );
            //   return;
            // } else {
            //   Navigator.of(context).pushNamed(Routes.createWallet);
            // }
            Navigator.of(context).pushNamed(Routes.createWallet);
          },
          colorTitle: white),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(
              LocaleKeys.totalBalance.tr(),
              style: headline(color: white.withOpacity(0.7)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                totalBalanceAllWallets == 0
                    ? symbol == '₫'
                        ? '${symbol}0'
                        : '${symbol}0.00'
                    : '${totalBalanceAllWallets > 0 ? "" : "-"}$symbol${formatMoney(context).format(totalBalanceAllWallets.abs())}',
                style: title2(color: white),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: snow,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32))),
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16, left: 32, right: 32),
                        child: Text(
                          LocaleKeys.availableWallets.tr().toUpperCase(),
                          style: title4(context: context),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 16);
                              },
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: wallets.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: hasLeading
                                      ? () {
                                          Navigator.of(context).pushNamed(
                                              Routes.editWallet,
                                              arguments: EditWalletScreen(
                                                  totalWallet: wallets.length,
                                                  walletModel: wallets[index]));
                                        }
                                      : () {
                                          context.read<TransactionsBloc>().add(
                                              InitialTransactions(
                                                  wallets[index].id!));
                                          Navigator.of(context).pushNamed(
                                              Routes.transactionFull,
                                              arguments: TransactionFull(
                                                  walletModel: wallets[index]));
                                        },
                                  child: cardWallet(context, wallets[index],
                                      wallets.length, index),
                                );
                              },
                            ),
                            // BlocBuilder<UserBloc, UserState>(
                            //     builder: (context, state) {
                            //   if (state is UserLoading) {
                            //     return const SizedBox();
                            //   }
                            //   if (state is UserLoaded) {
                            //     return checkPremium(state.user.datePremium)
                            //         ? const SizedBox()
                            //         : Container(
                            //             width: double.infinity,
                            //             margin: const EdgeInsets.only(
                            //                 top: 16, left: 24, right: 24),
                            //             padding: const EdgeInsets.symmetric(
                            //                 vertical: 16, horizontal: 32),
                            //             decoration: BoxDecoration(
                            //                 color: white,
                            //                 borderRadius:
                            //                     BorderRadius.circular(8)),
                            //             child: Column(children: [
                            //               Padding(
                            //                 padding: const EdgeInsets.only(
                            //                     bottom: 16),
                            //                 child: Text(
                            //                   LocaleKeys.upgradePremium.tr(),
                            //                   textAlign: TextAlign.center,
                            //                   style: headline(context: context),
                            //                 ),
                            //               ),
                            //               AppWidget.typeButtonStartAction(
                            //                   context: context,
                            //                   miniSizeHorizontal: 172,
                            //                   input: LocaleKeys.goPremium.tr(),
                            //                   onPressed: () {
                            //                     Navigator.of(context)
                            //                         .pushNamed(Routes.premium);
                            //                   },
                            //                   bgColor: emerald,
                            //                   textColor: white),
                            //             ]),
                            //           );
                            //   }
                            //   return const SizedBox();
                            // })
                          ],
                        ),
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    return BlocBuilder<WalletsBloc, WalletsState>(builder: (context, state) {
      if (state is WalletsLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (state is WalletsLoaded) {
        final List<WalletModel> wallets = state.wallets;
        const bool isPremium = false;
        return Scaffold(
          bottomNavigationBar: !isPremium && wallets.isNotEmpty
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
          body: wallets.isEmpty
              ? ListView(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: height / 14),
                  children: [
                      Row(
                        children: [
                          hasLeading
                              ? AnimationClick(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Image.asset(
                                        icArrowLeft,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Text(
                            LocaleKeys.myWallet.tr().toUpperCase(),
                            style: title4(context: context),
                          )
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16, bottom: 24),
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              LocaleKeys.anyWallet.tr(),
                              style: title3(context: context),
                            ),
                          ),
                          AppWidget.typeButtonStartAction(
                              context: context,
                              miniSizeHorizontal: 172,
                              input: LocaleKeys.createNow.tr(),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(Routes.createWallet);
                              },
                              bgColor: emerald,
                              textColor: white),
                        ]),
                      ),
                    ])
              : listWallets(
                  context, wallets, state.totalBalanceAllWallets, isPremium),
        );
      }
      return const SizedBox();
    });
  }
}
