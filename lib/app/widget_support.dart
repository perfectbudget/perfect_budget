import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/translations/export_lang.dart';

import '../common/constant/images.dart';

mixin AppWidget {
  static double getHeightScreen(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidthScreen(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static Future<void> showLoading({required BuildContext context}) async {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      barrierColor: black.withOpacity(0.2),
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: const CupertinoActivityIndicator(
              animating: true,
            ));
      },
    );
  }

  static Future<void> showDialogCustom(String title,
      {required BuildContext context, Function()? remove}) async {
    showDialog<dynamic>(
      context: context,
      builder: (context) {
        final height = AppWidget.getHeightScreen(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: white,
          child: Container(
            padding: const EdgeInsets.all(30),
            height: height / 116 * 56,
            child: Column(
              children: [
                Expanded(child: Image.asset(removeWallet)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: headline(context: context),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.yes.tr(),
                          bgColor: emerald,
                          textColor: white,
                          borderRadius: 48,
                          onPressed: () {
                            remove!();
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48),
                            ),
                            side: const BorderSide(color: purplePlum)),
                        child: Text(LocaleKeys.no.tr(),
                            textAlign: TextAlign.center,
                            style: headline(color: purplePlum)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static PreferredSizeWidget createSimpleAppBar(
      {required BuildContext context,
      bool hasPop = true,
      Color? backgroundColor,
      bool hasLeading = true,
      String? title,
      Widget? action,
      Color? colorTitle,
      Color? arrowColor,
      Function()? onTap,
      Function()? onBack}) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? white,
      leading: hasLeading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimationClick(
                  child: GestureDetector(
                    onTap: () {
                      if (hasPop) {
                        if (onBack != null) {
                          onBack();
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Image.asset(
                      icArrowLeft,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      color: arrowColor ?? black,
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(),
      centerTitle: true,
      title: title == null
          ? null
          : Text(
              title,
              style: colorTitle == null
                  ? headline(context: context, fontWeight: '700')
                  : headline(color: colorTitle, fontWeight: '700'),
            ),
      actions: [
        onTap != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: onTap,
                        icon: action ??
                            const Icon(
                              Icons.add,
                              color: white,
                              size: 24,
                            ))
                  ],
                ),
              )
            : const SizedBox()
      ],
    );
  }

  static Widget typeButtonStartAction(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 48,
      double sizeAsset = 16,
      Color? colorAsset,
      String? icon}) {
    return AnimationClick(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: vertical ?? 16, horizontal: horizontal ?? 0),
          side: BorderSide(color: borderColor ?? white),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          backgroundColor: bgColor,
          minimumSize: Size(miniSizeHorizontal, 0),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                input!,
                textAlign: TextAlign.center,
                style: headline(context: context, color: textColor),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      SizedBox(
                          width: constraints.maxWidth * 0.3,
                          child: Image.asset(
                            icon,
                            width: sizeAsset,
                            height: sizeAsset,
                            color: colorAsset,
                          )),
                      Text(
                        input!,
                        textAlign: TextAlign.center,
                        style: headline(context: context, color: textColor),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  static SnackBar customSnackBar(
      {required String content, Color? color, int? milliseconds}) {
    return SnackBar(
      duration: Duration(milliseconds: milliseconds ?? 600),
      backgroundColor: color ?? emerald,
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: body(color: white),
      ),
    );
  }

  static Widget divider(BuildContext context,
      {double vertical = 24, Color color = grey6}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Divider(
        thickness: 1,
        color: color,
      ),
    );
  }
}
