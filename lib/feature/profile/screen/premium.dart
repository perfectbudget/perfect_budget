import 'package:flutter/material.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/feature/profile/screen/upgrade_premium.dart';

import '../../../common/constant/colors.dart';
import '../../../common/constant/images.dart';
import '../../../translations/export_lang.dart';

final List<Map<String, dynamic>> functionsSpecial = [
  <String, dynamic>{
    'icon': icCloud,
    'title': LocaleKeys.backupSync.tr(),
    'subTitle': LocaleKeys.sendStatement.tr(),
  },
  <String, dynamic>{
    'icon': icNoAds,
    'title': LocaleKeys.removeAds.tr(),
    'subTitle': LocaleKeys.removeAllAds.tr(),
  },
  // <String, dynamic>{
  //   'icon': icWallet,
  //   'title': LocaleKeys.unlimitedWallets.tr(),
  //   'subTitle': LocaleKeys.unlimitedWalletCreation.tr(),
  // }
];

class Premium extends StatefulWidget {
  const Premium({Key? key}) : super(key: key);

  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
        context: context,
        hasLeading: true,
        arrowColor: white,
        colorTitle: white,
        backgroundColor: emerald,
        title: LocaleKeys.getPremium2.tr(),
      ),
      bottomNavigationBar: const UpgradePremium(),
      backgroundColor: emerald,
      body: Column(
        children: [
          SizedBox(
            height: height / 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Image.asset(walletWithCash),
                    ),
                  ),
                  Text(
                    '\$1.99/ ' + LocaleKeys.year.tr(),
                    style: title2(color: white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.monseyPremium.tr(),
                        style: title3(context: context)),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Text(LocaleKeys.upgradePremiumAccount.tr(),
                          style: body(color: grey2)),
                    ),
                    ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox();
                      },
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: functionsSpecial.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: grey6,
                                borderRadius: BorderRadius.circular(48)),
                            child: Image.asset(functionsSpecial[index]['icon'],
                                width: 28, height: 28),
                          ),
                          title: Text(
                            functionsSpecial[index]['title'],
                            style:
                                headline(context: context, fontWeight: '700'),
                          ),
                          subtitle: Text(
                            functionsSpecial[index]['subTitle'],
                            style: body(color: grey3),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
