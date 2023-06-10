import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/util/authentication_apple.dart';
import 'package:monsey/common/util/authentication_google.dart';
import 'package:monsey/common/util/login_hasura.dart';
import 'package:monsey/feature/home/screen/home.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/env.dart';
import '../../../common/constant/images.dart';
import '../../../common/route/routes.dart';
import 'web_view_privacy.dart';

class OptionLogin extends StatefulWidget {
  @override
  State<OptionLogin> createState() => _OptionLoginState();
}

class _OptionLoginState extends State<OptionLogin> {
  late bool isChecked = false;

  Future<void> signIn(BuildContext context, User firebaseUser) async {
    AppWidget.showLoading(context: context);
    final String token = await firebaseUser.getIdToken();
    await signInSocials(token);
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(Routes.home, arguments: const Home());
  }

  Widget createPrivacy({BuildContext? context, String? input, String? url}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context!).pushNamed(Routes.webViewPrivacy,
            arguments: WebViewPrivacy(
              title: input,
              url: url!,
            ));
      },
      child: Text(
        input!,
        style: headline(color: bleuDeFrance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: emerald,
              value: isChecked,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              onChanged: (bool? value) {
                setState(() {
                  isChecked = !isChecked;
                });
              },
            ),
            Expanded(
                child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: LocaleKeys.agreeToThe.tr(),
                style: headline(context: context),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Policy',
                    style: headline(color: bleuDeFrance),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed(Routes.webViewPrivacy,
                            arguments: const WebViewPrivacy(
                              title: 'Policy',
                              url: EnvValue.policy,
                            ));
                      },
                  ),
                  TextSpan(
                    text: LocaleKeys.and.tr(),
                    style: headline(context: context),
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: headline(color: bleuDeFrance),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed(Routes.webViewPrivacy,
                            arguments: const WebViewPrivacy(
                              title: 'Terms',
                              url: EnvValue.terms,
                            ));
                      },
                  )
                ],
              ),
            )),
          ],
        ),
        // AppWidget.typeButtonStartAction(
        //     context: context,
        //     input: LocaleKeys.loginFace.tr(),
        //     onPressed: () {
        //       // Navigator.of(context).pushNamed(Routes.home);
        //     },
        //     bgColor: bleuDeFrance,
        //     textColor: white,
        //     sizeAsset: 24,
        //     icon: icFacebook),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: AppWidget.typeButtonStartAction(
              context: context,
              input: LocaleKeys.loginGoogle.tr(),
              onPressed: isChecked
                  ? () async {
                      final User firebaseUser =
                          await AuthenticationGoogle.signInWithGoogle(
                              context: context);
                      await signIn(context, firebaseUser);
                    }
                  : () {},
              bgColor: redCrayola,
              textColor: white,
              sizeAsset: 24,
              icon: icGoogle),
        ),
        AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.signinApple.tr(),
            bgColor: grey1,
            onPressed: isChecked
                ? () async {
                    final User firebaseUser =
                        await AuthenticationApple.signInWithApple(
                            context: context);
                    await signIn(context, firebaseUser);
                  }
                : () {},
            textColor: white,
            sizeAsset: 24,
            icon: icApple)
      ],
    );
  }
}
