import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/feature/goal/bloc/goal/goal_bloc.dart';
import 'package:monsey/feature/goal/bloc/goal/goal_state.dart';
import 'package:monsey/feature/goal/screen/goal_detail.dart';
import 'package:monsey/feature/goal/screen/handle_goal.dart';
import 'package:monsey/feature/goal/screen/saving_first.dart';
import 'package:monsey/feature/goal/widget/goal_widget.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class MainSaving extends StatelessWidget {
  const MainSaving({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return BlocBuilder<GoalBloc, GoalState>(builder: (context, state) {
      if (state is GoalLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (state is GoalLoaded) {
        return state.goals.isEmpty
            ? const SavingFirst()
            : Scaffold(
                appBar: AppBarCpn(
                  color: emerald,
                  showWallet: false,
                  left: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.totalBalanceSaving.tr(),
                          style: body(color: white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$symbol${(state.totalMoneySaving < 1 && state.totalMoneySaving >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(state.totalMoneySaving)}',
                          style: title2(color: white),
                        )
                      ],
                    ),
                  ),
                ),
                body: DecoratedBox(
                  decoration: const BoxDecoration(color: snow),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Text(
                            LocaleKeys.yourGoal.tr(),
                            style: title4(context: context, fontWeight: '700'),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 16);
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            shrinkWrap: true,
                            itemCount: state.goals.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      Routes.goalDetail,
                                      arguments: GoalDetail(
                                          goalModel: state.goals[index]));
                                },
                                child: cardGoal(
                                    context, state.goals[index], index),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: AppWidget.typeButtonStartAction(
                              context: context,
                              input: LocaleKeys.addMoreGoal.tr(),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    Routes.handleGoal,
                                    arguments: const HandleGoal());
                              },
                              bgColor: emerald,
                              textColor: white),
                        )
                      ]),
                ),
              );
      }
      return const SizedBox();
    });
  }
}
