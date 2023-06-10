import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/images.dart';
import '../../../common/constant/styles.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/mutations.dart';
import '../../../common/preference/shared_preference_builder.dart';
import '../../../common/route/routes.dart';
import '../../../translations/export_lang.dart';
import '../../contract/screen/contracts.dart';
import '../../home/screen/dashboard.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({Key? key}) : super(key: key);

  Future<void> deleteUser() async {
    final User firebaseUser = FirebaseAuth.instance.currentUser!;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
        document: gql(Mutations.deleteUser()),
        variables: <String, dynamic>{'uuid': firebaseUser.uid}));
  }

  Widget accountSetting(BuildContext context) {
    final List<Map<String, dynamic>> settings = [
      <String, dynamic>{
        'icon': icContract,
        'name': LocaleKeys.contracts.tr(),
        'onTap': () {
          Navigator.of(context)
              .pushNamed(Routes.contract, arguments: const Contracts());
        }
      },
      <String, dynamic>{
        'icon': icWallet,
        'name': LocaleKeys.wallet.tr(),
        'onTap': () {
          Navigator.of(context).pushNamed(Routes.dashboard,
              arguments: const Dashboard(hasLeading: true));
        }
      },
      <String, dynamic>{
        'icon': icCurrency,
        'name': LocaleKeys.currency.tr(),
        'onTap': () async {
          final currency = await Navigator.of(context)
              .pushNamed(Routes.currency) as Currency?;
          if (currency != null) {
            context
                .read<UserBloc>()
                .add(UpdateCurrencyUser(currency.code, currency.symbol));
          }
        }
      },
      <String, dynamic>{
        'icon': icLanguage,
        'name': LocaleKeys.language.tr(),
        'onTap': () async {
          Navigator.of(context).pushNamed(Routes.language);
        }
      },
      <String, dynamic>{
        'icon': icLock,
        'name': LocaleKeys.logout.tr(),
        'onTap': () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.onBoarding, (route) => false);
        }
      },
      <String, dynamic>{
        'name': LocaleKeys.deleteAccount.tr(),
        'onTap': () {
          AppWidget.showDialogCustom(LocaleKeys.deleteYourAccount.tr(),
              context: context, remove: () async {
            Navigator.of(context).pop();
            AppWidget.showLoading(context: context);
            await removeStorage();
            await deleteUser();
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.onBoarding, (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              AppWidget.customSnackBar(
                content: LocaleKeys.deleteSuccess.tr(),
              ),
            );
          });
        }
      }
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Text(
            LocaleKeys.accountSettings.tr(),
            style: headline(color: grey2),
          ),
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox();
            },
            shrinkWrap: true,
            itemCount: settings.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: settings[index]['onTap'],
                child: ListTile(
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      settings[index]['icon'] == null
                          ? const SizedBox()
                          : Image.asset(
                              settings[index]['icon'],
                              width: 24,
                              height: 24,
                              color: purplePlum,
                            ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          settings[index]['name'],
                          style: body(context: context),
                        ),
                      ),
                      if (index == 1) ...[
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
                        )
                      ],
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 24,
                        color: grey4,
                      )
                    ],
                  ),
                  subtitle: AppWidget.divider(context, vertical: 8),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            'v1.3.9',
            style: subhead(color: grey3),
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return accountSetting(context);
  }
}
