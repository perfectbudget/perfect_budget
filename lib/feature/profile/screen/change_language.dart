import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/onboarding/bloc/user/bloc_user.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../translations/export_lang.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  List<String> languages = [
    LocaleKeys.english.tr(),
    LocaleKeys.vietnam.tr(),
    LocaleKeys.japan.tr()
  ];
  List<Map<String, dynamic>> typeLanguages = [];

  Widget item(Map<String, dynamic> typeLanguage) {
    return AnimationClick(
      function: () {
        setState(() {
          for (dynamic language in typeLanguages) {
            language['selected'] = false;
          }
          typeLanguage['selected'] = true;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            typeLanguage['item'],
            style: body(color: grey1),
          ),
          Checkbox(
              activeColor: emerald,
              shape: const CircleBorder(),
              value: typeLanguage['selected'],
              onChanged: (value) {
                setState(() {
                  for (dynamic typeWallet in typeLanguages) {
                    typeWallet['selected'] = false;
                  }
                  typeLanguage['selected'] = value;
                });
              })
        ],
      ),
    );
  }

  void setLanguage() {
    for (Map<String, dynamic> typeLanguage in typeLanguages) {
      if (typeLanguage['selected']) {
        switch (typeLanguage['item']) {
          case 'Vietnamese':
            context.setLocale(const Locale('vi'));
            context.read<UserBloc>().add(const UpdateLanguageUser('vi'));
            break;
          case 'Japanese':
            context.setLocale(const Locale('ja'));
            context.read<UserBloc>().add(const UpdateLanguageUser('ja'));
            break;
          default:
            context.setLocale(const Locale('en'));
            context.read<UserBloc>().add(const UpdateLanguageUser('en'));
            break;
        }
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    typeLanguages = List.generate(
        languages.length,
        (index) => <String, dynamic>{
              'item': languages[index],
              'selected': index == 0 ? true : false
            });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.language.tr(),
          onBack: setLanguage),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: setLanguage,
            bgColor: emerald,
            textColor: white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              padding: const EdgeInsets.symmetric(vertical: 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: typeLanguages.length,
              itemBuilder: (context, index) {
                return item(typeLanguages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
