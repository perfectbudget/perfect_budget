import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/model/goal_model.dart';

import '../../../common/constant/colors.dart';
import '../../../common/constant/styles.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../../home/screen/home.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import 'handle_goal.dart';

class Success extends StatelessWidget {
  const Success({Key? key, required this.goalModel}) : super(key: key);
  final GoalModel goalModel;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return Scaffold(
      backgroundColor: white,
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          onBack: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.home, (Route<dynamic> route) => false,
                arguments: const Home(
                  index: 1,
                ));
          }),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Congratulations',
                textAlign: TextAlign.center,
                style: title1(context: context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
              child: Text(
                'You have completed your goal of saving '
                "$symbol${(goalModel.moneyGoal < 1 && goalModel.moneyGoal >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(goalModel.moneyGoal)}"
                ' to rent a house in ${goalModel.timeEnd.year}',
                textAlign: TextAlign.center,
                style: body(color: grey800),
              ),
            ),
            Expanded(child: Image.asset(success)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AppWidget.typeButtonStartAction(
                  context: context,
                  input: 'Create More Goal',
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
          ],
        ),
      ),
    );
  }
}
