import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/feature/onboarding/bloc/user/bloc_user.dart';
import 'package:monsey/feature/profile/widget/account_setting.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/util/helper.dart';
import '../../../translations/export_lang.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is UserLoaded) {
          final bool isPremium = checkPremium(state.user.datePremium);
          return Scaffold(
            backgroundColor: isPremium ? emerald : white,
            appBar: AppWidget.createSimpleAppBar(
                context: context,
                title: LocaleKeys.profile.tr(),
                hasLeading: false,
                colorTitle: isPremium ? white : emerald,
                backgroundColor: isPremium ? emerald : white,
                action: Image.asset(icPencilEdit,
                    width: 24,
                    height: 24,
                    color: isPremium ? white : purplePlum)),
            body: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isPremium
                        ? Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(state.user.avatar),
                                radius: 60,
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 5,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: blueCrayola,
                                          borderRadius:
                                              BorderRadius.circular(48)),
                                      child: Image.asset(icCrown,
                                          color: white, height: 24, width: 24)))
                            ],
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(state.user.avatar),
                            radius: 60,
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 32),
                      child: Text(
                        state.user.name,
                        style: isPremium
                            ? title3(color: white)
                            : title3(context: context),
                      ),
                    ),
                    Text(
                      state.user.email,
                      style: body(color: isPremium ? white : grey3),
                    ),
                    isPremium
                        ? const SizedBox(
                            height: 16,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                const Expanded(child: SizedBox()),
                                Expanded(
                                  flex: 2,
                                  child: AppWidget.typeButtonStartAction(
                                      context: context,
                                      input: LocaleKeys.getPremium.tr(),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(Routes.premium);
                                      },
                                      bgColor: emerald,
                                      textColor: white,
                                      sizeAsset: 24,
                                      colorAsset: white,
                                      icon: icAward),
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                  ],
                ),
                const Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32))),
                    child: AccountSetting(),
                  ),
                )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
