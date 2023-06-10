import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/model/transaction_goal_model.dart';
import 'package:monsey/common/widget/textfield.dart';
import 'package:monsey/feature/goal/bloc/goal_detail.dart/bloc_goal_detail.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/styles.dart';
import '../../../common/model/goal_model.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/unfocus_click.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key, required this.goalModel}) : super(key: key);
  final GoalModel goalModel;

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  TextEditingController moneyCtl = TextEditingController();
  FocusNode moneyFn = FocusNode();
  TextEditingController noteCtl = TextEditingController(text: 'Add money');
  FocusNode noteFn = FocusNode();
  bool showSuggest = false;
  String suggestOne = '';
  String suggestTwo = '';
  String suggestThree = '';

  OutlineInputBorder createInputDecoration(BuildContext context,
      {Color? color}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color ?? grey6),
      borderRadius: BorderRadius.circular(12),
    );
  }

  String convertString(String suggest) {
    return formatMoney(context).format(!suggest.contains('.')
        ? (int.tryParse(suggest.replaceAll(',', '')) ?? 0)
        : (double.tryParse(suggest.replaceAll(',', '')) ?? 0));
  }

  Widget suggestText(String suggest) {
    return InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: () {
          setState(() {
            moneyCtl.text = convertString(suggest);
            moneyCtl.selection =
                TextSelection.collapsed(offset: moneyCtl.text.length);
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: grey3.withOpacity(0.2),
              borderRadius: BorderRadius.circular(48)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            convertString(suggest),
            textAlign: TextAlign.center,
            style: headline(fontWeight: '700', context: context),
          ),
        ));
  }

  void handleInput() {
    final String text = moneyCtl.text.trim();
    setState(() {
      if (text.isNotEmpty && text != '0' && text != '0.00') {
        showSuggest = true;
        if (text.contains('.')) {
          final List<String> number = text.split('.');
          suggestOne = number[0] + '0.' + number[1];
          suggestTwo = number[0] + '00.' + number[1];
          suggestThree = number[0] + '000.' + number[1];
        } else {
          suggestOne = text + '0';
          suggestTwo = text + '00';
          suggestThree = text + '000';
        }
      } else {
        showSuggest = false;
      }
    });
  }

  @override
  void initState() {
    moneyCtl.addListener(handleInput);
    super.initState();
  }

  @override
  void dispose() {
    moneyCtl.dispose();
    moneyFn.dispose();
    noteCtl.dispose();
    noteFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppWidget.createSimpleAppBar(
            context: context,
            title: LocaleKeys.addTransaction.tr(),
            onBack: () {
              Navigator.of(context).pop();
            }),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 8,
            ),
            showSuggest
                ? SizedBox(
                    height: 48,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      children: [
                        suggestText(suggestOne),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: suggestText(suggestTwo),
                        ),
                        suggestText(suggestThree)
                      ],
                    ),
                  )
                : const SizedBox(),
            const Divider(
              color: grey4,
            ),
            Padding(
                padding: const EdgeInsets.only(
                    bottom: 12, top: 6, left: 24, right: 24),
                child: AppWidget.typeButtonStartAction(
                    context: context,
                    input: LocaleKeys.addNow.tr(),
                    onPressed:
                        double.tryParse(moneyCtl.text.replaceAll(',', '')) !=
                                null
                            ? () {
                                context
                                    .read<GoalDetailBloc>()
                                    .add(CreateTransactionGoal(
                                        context,
                                        TransactionGoalModel(
                                          balance: double.tryParse(moneyCtl.text
                                                  .replaceAll(',', '')) ??
                                              0,
                                          note: noteCtl.text.trim().isNotEmpty
                                              ? noteCtl.text.trim()
                                              : 'Add Money',
                                          date: now,
                                          goalId: widget.goalModel.id!,
                                        )));
                                Navigator.of(context).pop();
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  AppWidget.customSnackBar(
                                    content: LocaleKeys.fillAllInformation.tr(),
                                  ),
                                );
                              },
                    bgColor: emerald,
                    textColor: white)),
          ],
        ),
        body: UnfocusClick(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            children: [
              Stack(
                children: [
                  TextField(
                      controller: moneyCtl,
                      focusNode: moneyFn,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      onChanged: (string) {
                        moneyCtl.value = TextEditingValue(
                          text: formatAmount(string),
                          selection: TextSelection.collapsed(
                              offset: formatAmount(string).length),
                        );
                      },
                      onSubmitted: (value) {
                        moneyFn.unfocus();
                      },
                      cursorColor: white,
                      style: header(color: white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 40),
                        fillColor: black,
                        filled: true,
                        focusedBorder: createInputDecoration(context),
                        enabledBorder: createInputDecoration(context),
                        errorBorder:
                            createInputDecoration(context, color: neonFuchsia),
                      )),
                  Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          BlocProvider.of<UserBloc>(context)
                                  .userModel!
                                  .currencyCode ??
                              'USD',
                          style: subhead(color: grey1),
                        ),
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Text(LocaleKeys.note.tr(),
                    style: body(context: context, fontWeight: '700')),
              ),
              TextFieldCpn(
                controller: noteCtl,
                focusNode: noteFn,
                hintText: LocaleKeys.note.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
