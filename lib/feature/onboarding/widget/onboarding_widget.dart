import 'package:flutter/material.dart';
import 'package:monsey/common/constant/colors.dart';

mixin OnBoardingWidget {
  static Widget createIndicator({int? currentImage, int? lengthImage}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(lengthImage!, (index) {
          return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: index == currentImage ? 12 : 8,
              width: index == currentImage ? 12 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      index == currentImage ? white : white.withOpacity(0.4)));
        }));
  }
}
