import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/bloc/categories/bloc_categories.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/category_model.dart';
import 'package:monsey/common/model/goal_model.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/common/widget/unfocus_click.dart';
import 'package:monsey/feature/goal/bloc/goal/bloc_goal.dart';
import 'package:monsey/feature/goal/screen/delete_goal.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/widget/bottom_button.dart';
import '../../../common/widget/textfield.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class HandleGoal extends StatefulWidget {
  const HandleGoal({Key? key, this.goalModel}) : super(key: key);
  final GoalModel? goalModel;

  @override
  State<HandleGoal> createState() => _HandleGoalState();
}

class _HandleGoalState extends State<HandleGoal> {
  late WalletsBloc walletsBloc;
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  GoalModel? goalModel;
  CategoryModel? categoryModel;
  bool isCreate = true;
  TextEditingController nameGoalCtl = TextEditingController();
  FocusNode nameGoalFn = FocusNode();
  TextEditingController timeCtl = TextEditingController();
  FocusNode timeFn = FocusNode();
  TextEditingController moneyCtl = TextEditingController();
  FocusNode moneyFn = FocusNode();
  DateTime? timeEnd;
  int _currentIndex = 0;
  bool showSuggest = false;
  String suggestOne = '';
  String suggestTwo = '';
  String suggestThree = '';

  void handleInput() {
    final String text = timeCtl.text.trim();
    setState(() {
      if (text.isNotEmpty && int.tryParse(text) != null) {
        timeEnd = (isCreate ? now : goalModel!.timeStart)
            .add(Duration(days: int.tryParse(text) ?? 10));
      } else {
        timeEnd = null;
      }
    });
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

  OutlineInputBorder createInputDecoration(BuildContext context,
      {Color? color}) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: whisper));
  }

  void handleMoneyInput() {
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

  void updateGoal() {
    context.read<GoalBloc>().add(UpdateGoal(
        context,
        GoalModel(
            id: goalModel!.id,
            name: nameGoalCtl.text,
            days: int.tryParse(timeCtl.text) ?? 10,
            timeStart: goalModel!.timeStart,
            categoryId: categoryModel!.id,
            timeEnd: timeEnd!,
            moneyGoal: double.tryParse(moneyCtl.text.replaceAll(',', '')) ?? 0,
            moneySaving: goalModel!.moneySaving)));
  }

  @override
  void initState() {
    isCreate = widget.goalModel == null;
    if (!isCreate) {
      goalModel = widget.goalModel;
      nameGoalCtl = TextEditingController(text: goalModel!.name);
      timeCtl = TextEditingController(text: '${goalModel!.days}');
      moneyCtl = TextEditingController(
          text:
              '${formatAmount(goalModel!.moneyGoal.toString().endsWith('.0') ? goalModel!.moneyGoal.toStringAsFixed(0) : goalModel!.moneyGoal.toString())}');
      timeEnd = goalModel!.timeEnd;
      categoryModel = goalModel!.categoryModel;
    }
    categoryModel = context.read<CategoriesBloc>().listCategory[0];
    timeCtl.addListener(handleInput);
    moneyCtl.addListener(handleMoneyInput);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    walletsBloc = BlocProvider.of<WalletsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    nameGoalCtl.dispose();
    nameGoalFn.dispose();
    timeCtl.dispose();
    timeFn.dispose();
    moneyCtl.dispose();
    moneyFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return UnfocusClick(
      child: Scaffold(
        body: Scaffold(
          backgroundColor: white,
          appBar: AppWidget.createSimpleAppBar(
            context: context,
            title: isCreate ? null : goalModel!.name,
            onTap: isCreate
                ? null
                : () {
                    Navigator.of(context).pushNamed(Routes.deleteGoal,
                        arguments: DeleteGoal(goalModel: goalModel!));
                  },
            action: isCreate
                ? null
                : const Icon(Icons.delete_outline_rounded,
                    size: 24, color: black),
          ),
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
              BottomButton(
                child: AppWidget.typeButtonStartAction(
                    context: context,
                    input: isCreate
                        ? LocaleKeys.createGoal.tr()
                        : LocaleKeys.updateGoal.tr(),
                    onPressed: nameGoalCtl.text.isNotEmpty && timeEnd != null
                        ? (isCreate
                            ? () {
                                context.read<GoalBloc>().add(CreateGoal(
                                    context,
                                    GoalModel(
                                        name: nameGoalCtl.text,
                                        days: int.tryParse(timeCtl.text) ?? 10,
                                        timeStart: now,
                                        categoryId: categoryModel!.id,
                                        timeEnd: timeEnd!,
                                        moneyGoal: double.tryParse(moneyCtl.text
                                                .replaceAll(',', '')) ??
                                            100,
                                        moneySaving: 0)));
                                Navigator.of(context).pop();
                              }
                            : () {
                                if (goalModel!.transGoal!.isNotEmpty) {
                                  goalModel!.transGoal!
                                      .sort((a, b) => b.date.compareTo(a.date));
                                  final DateTime lasted =
                                      goalModel!.transGoal![0].date;
                                  if (lasted.isAfter(timeEnd!)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppWidget.customSnackBar(
                                        content: LocaleKeys.timeEndGreater.tr(),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                updateGoal();
                                Navigator.of(context).pop();
                              })
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              AppWidget.customSnackBar(
                                content: LocaleKeys.fillAllInformationGoal.tr(),
                              ),
                            );
                          },
                    bgColor: emerald,
                    textColor: white),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
          body: ListView(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCreate) ...[
                      Text(LocaleKeys.createGoals.tr(),
                          style: title1(context: context)),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.youHaveSave.tr(),
                            style: body(color: grey700),
                          ),
                          Text(
                            '$symbol${(goalModel!.moneySaving < 1 && goalModel!.moneySaving >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(goalModel!.moneySaving)}',
                            style: title3(context: context),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.timeBegin.tr(),
                            style: body(color: grey700),
                          ),
                          Text(
                            FormatTime.formatTime(
                                dateTime: goalModel!.timeStart,
                                format: Format.dMMy),
                            style: body(context: context),
                          )
                        ],
                      ),
                      AppWidget.divider(context, vertical: 16, color: grey300),
                    ],
                    const SizedBox(height: 8),
                    Text(LocaleKeys.youWantToSave.tr(),
                        style: body(context: context))
                  ],
                ),
              ),
              BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                if (state is CategoriesLoaded) {
                  return SizedBox(
                    height: 64,
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                                categoryModel = state.listCategory[index];
                              });
                            },
                            child: Opacity(
                              opacity: _currentIndex == index ? 1 : 0.3,
                              child: Image.network(
                                state.listCategory[index].icon,
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 32),
                        itemCount: state.listCategory.length),
                  );
                }
                return const SizedBox();
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(LocaleKeys.nameGoal.tr(),
                          style: body(context: context, fontWeight: '700')),
                    ),
                    TextFieldCpn(
                      controller: nameGoalCtl,
                      focusNode: nameGoalFn,
                      fillColor: grey200,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(LocaleKeys.time.tr(),
                          style: body(context: context, fontWeight: '700')),
                    ),
                    TextFieldCpn(
                      controller: timeCtl,
                      focusNode: timeFn,
                      keyboardType: TextInputType.number,
                      showSuffixIcon: true,
                      fillColor: grey200,
                      suffixWidget: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          LocaleKeys.days.tr(),
                          style: subhead(color: grey600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${LocaleKeys.timeEnd.tr()}: ${FormatTime.formatTime(dateTime: timeEnd, format: Format.dMMy)}',
                      style: subhead(context: context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(LocaleKeys.money.tr(),
                          style: body(context: context, fontWeight: '700')),
                    ),
                    TextField(
                        controller: moneyCtl,
                        focusNode: moneyFn,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                        style: body(color: grey1),
                        decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'USD',
                              style: subhead(color: grey600),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 16,
                            minWidth: 16,
                          ),
                          fillColor: grey200,
                          filled: true,
                          focusedBorder: createInputDecoration(context),
                          enabledBorder: createInputDecoration(context),
                          errorBorder: createInputDecoration(context,
                              color: neonFuchsia),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
