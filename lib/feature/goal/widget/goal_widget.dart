import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/feature/goal/screen/handle_goal.dart';
import 'package:monsey/translations/export_lang.dart';
import '../../../common/constant/colors.dart';
import '../../../common/model/goal_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/widget/slidaction_widget.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../screen/delete_goal.dart';
import 'circular_progress.dart';

Widget cardGoal(BuildContext context, GoalModel goalModel, int index) {
  final String symbol =
      BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
  final Duration duration = goalModel.timeEnd.difference(now);
  final bool check = duration.isNegative || duration.inDays == 0;
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/card${index % 12}@3x.png'),
          fit: BoxFit.cover),
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 24),
    child: SlidactionWidget(
      extentRatio: 0.6,
      editFunc: () {
        Navigator.of(context).pushNamed(Routes.handleGoal,
            arguments: HandleGoal(
              goalModel: goalModel,
            ));
      },
      removeFunc: () {
        Navigator.of(context).pushNamed(Routes.deleteGoal,
            arguments: DeleteGoal(goalModel: goalModel));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    goalModel.categoryModel?.icon ?? iconOthers,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgress(
                        moneyGoal: goalModel.moneyGoal,
                        moneySaving: goalModel.moneySaving,
                      ),
                      Text(
                          '${goalModel.moneySaving >= goalModel.moneyGoal ? '100' : (goalModel.moneySaving / goalModel.moneyGoal * 100).toStringAsFixed(2)}%',
                          style: caption2(color: white))
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 16),
                child: Text(
                  goalModel.name,
                  style: body(color: white, fontWeight: '700'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '$symbol${(goalModel.moneySaving < 1 && goalModel.moneySaving >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context, digit: 1).format(goalModel.moneySaving)}',
                        style: body(color: white, fontWeight: '700'),
                      ),
                      Text(
                        '/$symbol${(goalModel.moneyGoal < 1 && goalModel.moneyGoal >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context, digit: 1).format(goalModel.moneyGoal)}',
                        style: body(color: neutral, fontWeight: '400'),
                      )
                    ],
                  ),
                  Text(
                    !check
                        ? '${duration.inDays} ${LocaleKeys.daysLeft.tr()}'
                        : LocaleKeys.expired.tr(),
                    style: subhead(
                        color: !check ? white : redCrayola, fontWeight: '400'),
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
    ),
  );
}
