import 'package:flutter/material.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/translations/export_lang.dart';

class PremiumSuccessful extends StatelessWidget {
  const PremiumSuccessful({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          hasLeading: false,
          action: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  size: 24,
                  color: grey1,
                )
              ]),
          onTap: () {
            Navigator.of(context).pop();
          }),
      backgroundColor: white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: height / 8),
            child: Image.asset(premiumSuccess, height: height / 5),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(LocaleKeys.congratulations.tr(),
                style: title2(color: grey2)),
          ),
          Text(
            LocaleKeys.successfullyUpgraded.tr(),
            style: body(color: grey2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                flex: 2,
                child: AppWidget.typeButtonStartAction(
                    context: context,
                    input: LocaleKeys.experienceNow.tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    bgColor: emerald,
                    textColor: white),
              ),
              const Expanded(child: SizedBox()),
            ],
          )
        ],
      ),
    );
  }
}
