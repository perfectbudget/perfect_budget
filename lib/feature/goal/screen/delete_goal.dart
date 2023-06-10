import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/feature/goal/screen/delete_done.dart';
import 'package:monsey/feature/goal/screen/success.dart';

import '../../../common/model/goal_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/goal/bloc_goal.dart';

class DeleteGoal extends StatelessWidget {
  const DeleteGoal({Key? key, required this.goalModel}) : super(key: key);
  final GoalModel goalModel;

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return Scaffold(
      backgroundColor: white,
      appBar: AppWidget.createSimpleAppBar(context: context),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 24),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                deleteGoal,
                height: height / 4,
              ),
            ),
            Column(
              children: [
                Text(
                  'Remove Goal',
                  textAlign: TextAlign.center,
                  style: title1(context: context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Do you want remove goal of saving '
                    "$symbol${(goalModel.moneyGoal < 1 && goalModel.moneyGoal >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(goalModel.moneyGoal)}"
                    ' to rent a house in ${goalModel.timeEnd.year}',
                    textAlign: TextAlign.center,
                    style: body(color: grey800),
                  ),
                ),
                Text(
                  'You have done ${goalModel.moneySaving >= goalModel.moneyGoal ? '100' : (goalModel.moneySaving / goalModel.moneyGoal * 100).toStringAsFixed(2)}%',
                  textAlign: TextAlign.center,
                  style: headline(color: blueCrayola),
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            AppWidget.typeButtonStartAction(
                context: context,
                input: 'Goal accomplished',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.success,
                      arguments: Success(goalModel: goalModel));
                  context
                      .read<GoalBloc>()
                      .add(RemoveGoal(context, goalModel.id!));
                },
                bgColor: redCrayola,
                textColor: white),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: AppWidget.typeButtonStartAction(
                  context: context,
                  input: 'Goals are too hard to achieve',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                        Routes.deleteDone,
                        arguments: DeleteDone(goalModel: goalModel));
                    context
                        .read<GoalBloc>()
                        .add(RemoveGoal(context, goalModel.id!));
                  },
                  bgColor: redCrayola,
                  textColor: white),
            ),
            AppWidget.typeButtonStartAction(
                context: context,
                input: 'Asking for what',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.deleteDone,
                      arguments: DeleteDone(goalModel: goalModel));
                  context
                      .read<GoalBloc>()
                      .add(RemoveGoal(context, goalModel.id!));
                },
                bgColor: redCrayola,
                textColor: white),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: AppWidget.typeButtonStartAction(
                  context: context,
                  input: 'Continue Goal',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  bgColor: emerald,
                  textColor: white),
            )
          ],
        ),
      ),
    );
  }
}
