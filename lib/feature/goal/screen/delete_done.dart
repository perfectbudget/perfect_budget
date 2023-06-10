import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/goal/screen/handle_goal.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/styles.dart';
import '../../../common/model/goal_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../home/screen/home.dart';
import '../../onboarding/bloc/user/bloc_user.dart';

class DeleteDone extends StatelessWidget {
  const DeleteDone({Key? key, required this.goalModel}) : super(key: key);
  final GoalModel goalModel;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return Scaffold(
      backgroundColor: white,
      appBar: AppWidget.createSimpleAppBar(context: context, hasLeading: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              'Ok Fine!',
              textAlign: TextAlign.center,
              style: title1(context: context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
              child: Text(
                'Your goal of saving '
                "$symbol${(goalModel.moneyGoal < 1 && goalModel.moneyGoal >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(goalModel.moneyGoal)}"
                ' to rent a house in ${goalModel.timeEnd.year} have remove',
                textAlign: TextAlign.center,
                style: body(color: grey800),
              ),
            ),
            Expanded(child: Image.asset(deleteDone)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AppWidget.typeButtonStartAction(
                  context: context,
                  input: 'Create Other Goal',
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.home, (Route<dynamic> route) => false,
                        arguments: const Home(
                          index: 1,
                        ));
                    Navigator.of(context).pushNamed(Routes.handleGoal,
                        arguments: const HandleGoal());
                  },
                  bgColor: emerald,
                  textColor: white),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: AnimationClick(
                function: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.home, (Route<dynamic> route) => false,
                      arguments: const Home(
                        index: 1,
                      ));
                },
                child: Text(
                  'Back to home page',
                  style: headline(color: blueCrayola),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
