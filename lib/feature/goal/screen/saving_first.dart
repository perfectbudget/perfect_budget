import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:monsey/feature/goal/screen/handle_goal.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/images.dart';
import '../../../common/constant/styles.dart';
import '../../../common/route/routes.dart';

class SavingFirst extends StatelessWidget {
  const SavingFirst({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  firstGoal,
                  height: height / 4,
                  width: width / 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      LocaleKeys.accumulate.tr(),
                      style: header(context: context),
                    ),
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.handleGoal,
                      arguments: const HandleGoal());
                },
                child: DottedBorder(
                  color: neutral,
                  borderType: BorderType.RRect,
                  dashPattern: const [8, 4],
                  radius: const Radius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: SizedBox(
                      width: width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: emerald,
                                  borderRadius: BorderRadius.circular(32)),
                              child: const Icon(
                                Icons.add,
                                size: 24,
                                color: white,
                              )),
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.createFirst.tr(),
                            style: headline(context: context),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
