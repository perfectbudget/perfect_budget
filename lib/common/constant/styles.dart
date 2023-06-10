import 'package:flutter/material.dart';
import 'package:monsey/common/constant/colors.dart';

FontWeight checkWeight(String weight) {
  switch (weight) {
    case '500':
      return FontWeight.w500;
    case '600':
      return FontWeight.w600;
    case '700':
      return FontWeight.w700;
    default:
      return FontWeight.w400;
  }
}

TextStyle mulish(double fontSize, double height,
    {BuildContext? context,
    String fontWeight = '400',
    Color? color,
    String? fontFamily,
    bool hasUnderLine = false}) {
  return TextStyle(
      fontSize: fontSize,
      height: height / fontSize,
      color: color ?? Theme.of(context!).color11,
      fontWeight: checkWeight(fontWeight),
      decoration: hasUnderLine ? TextDecoration.underline : TextDecoration.none,
      fontFamily: fontFamily ?? 'Mulish');
}

TextStyle header(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(42, 41,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle title1(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(34, 41,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle title2(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(28, 34,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle title3(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(22, 36,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle title4(
    {BuildContext? context,
    String fontWeight = '600',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(18, 24,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle headline(
    {BuildContext? context,
    String fontWeight = '700',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(17, 22,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle body(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(16, 24,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle callout(
    {BuildContext? context,
    String fontWeight = '600',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(16, 21,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle subhead(
    {BuildContext? context,
    String fontWeight = '500',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(14, 20,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle dayCalendar(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(14, 40,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle footnote(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(13, 18,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle caption1(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(12, 16,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}

TextStyle caption2(
    {BuildContext? context,
    String fontWeight = '400',
    bool hasUnderLine = false,
    String fontFamily = 'Mulish',
    Color? color}) {
  return mulish(10, 13,
      context: context,
      fontWeight: fontWeight,
      hasUnderLine: hasUnderLine,
      fontFamily: fontFamily,
      color: color);
}
