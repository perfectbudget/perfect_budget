import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/colors.dart';
import '../bloc/slider/bloc_slider.dart';
import '../widget/onboarding_widget.dart';
import '../widget/option_login.dart';

final List<Map<String, String>> landings = [
  {
    'title': LocaleKeys.smartWallet.tr(),
    'subtitle': LocaleKeys.allowCreate.tr(),
    'image': onBoarding1,
  },
  {
    'title': LocaleKeys.quicklyCreate.tr(),
    'subtitle': LocaleKeys.createManage.tr(),
    'image': onBoarding2,
  },
  {
    'title': LocaleKeys.gainControl.tr(),
    'subtitle': LocaleKeys.trackGain.tr(),
    'image': onBoarding3,
  }
];

class OnBoarding extends StatelessWidget {
  const OnBoarding({Key? key}) : super(key: key);

  Widget landing(BuildContext context, int index, double height) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
          ),
          height: height / 4,
          child: Image.asset(
            landings[index]['image']!,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
          child: Text(
            landings[index]['title']!,
            style: title3(context: context, color: white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
          child: Text(
            landings[index]['subtitle']!,
            textAlign: TextAlign.center,
            style: body(context: context, color: white),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    final SliderBloc sliderBloc = BlocProvider.of<SliderBloc>(context);
    return Scaffold(
      backgroundColor: emerald,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: height / 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: BlocBuilder<SliderBloc, int>(
                      builder: (context, state) {
                        return PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: landings.length,
                          onPageChanged: (value) {
                            if (value > state) {
                              sliderBloc.add(SwipeRight());
                            } else {
                              sliderBloc.add(SwipeLeft());
                            }
                          },
                          itemBuilder: (context, index) {
                            return landing(context, index, height);
                          },
                        );
                      },
                    ),
                  ),
                  BlocBuilder<SliderBloc, int>(
                    builder: (context, state) {
                      return OnBoardingWidget.createIndicator(
                          lengthImage: landings.length, currentImage: state);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: OptionLogin(),
          )
        ],
      ),
    );
  }
}
