import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import '../util/helper.dart';
import 'animation_click.dart';

class TextFieldBalanceCpn extends StatelessWidget {
  const TextFieldBalanceCpn({
    required this.controller,
    required this.focusNode,
    this.labelText,
    this.showSuffixIcon = false,
    this.showPrefixIcon = false,
    this.colorSuffixIcon,
    this.colorPrefixIcon,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNext,
    this.hasMutilLine = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.functionPrefix,
    this.functionSuffer,
    this.enabled = true,
    this.hintText,
    this.labelStyle,
    this.isCreateTransaction = false,
    this.isExpense = false,
    this.showSymbol = true,
    Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? focusNext;
  final String? labelText;
  final bool showSuffixIcon;
  final bool showPrefixIcon;
  final String? prefixIcon;
  final Color? colorPrefixIcon;
  final String? suffixIcon;
  final Color? colorSuffixIcon;
  final bool hasMutilLine;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Function()? functionPrefix;
  final Function()? functionSuffer;
  final String? hintText;
  final TextStyle? labelStyle;
  final bool isExpense;
  final bool isCreateTransaction;
  final bool showSymbol;

  OutlineInputBorder createInputDecoration(BuildContext context,
      {Color? color}) {
    return OutlineInputBorder(borderSide: BorderSide(color: color ?? grey6));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        maxLines: maxLines ?? (hasMutilLine ? null : 1),
        minLines: minLines,
        textAlign: TextAlign.center,
        readOnly: readOnly,
        maxLength: maxLength,
        keyboardType: hasMutilLine
            ? TextInputType.multiline
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        ],
        onChanged: (string) {
          controller.value = TextEditingValue(
            text: formatAmount(string),
            selection:
                TextSelection.collapsed(offset: formatAmount(string).length),
          );
        },
        onSubmitted: (value) {
          focusNode.unfocus();
          FocusScope.of(context).requestFocus(focusNext);
        },
        cursorColor: isExpense ? redCrayola : bleuDeFrance,
        style: title1(color: isExpense ? redCrayola : bleuDeFrance),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: body(color: grey4),
          fillColor: isCreateTransaction ? grey6 : white,
          filled: true,
          prefixIcon: showPrefixIcon
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimationClick(
                      function: functionPrefix ?? () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: grey5,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'USD',
                            style: subhead(color: grey1),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          suffixIcon: showSuffixIcon
              ? AnimationClick(
                  function: functionSuffer ?? () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: suffixIcon != null
                        ? Image.asset(
                            suffixIcon!,
                            height: 24,
                            width: 24,
                            color: colorSuffixIcon ?? dodgerBlue,
                          )
                        : const SizedBox(),
                  ),
                )
              : const SizedBox(),
          suffixIconConstraints: const BoxConstraints(
            minHeight: 16,
            minWidth: 16,
          ),
          focusedBorder: createInputDecoration(context),
          enabledBorder: createInputDecoration(context),
          errorBorder: createInputDecoration(context, color: neonFuchsia),
          enabled: enabled,
        ));
  }
}
