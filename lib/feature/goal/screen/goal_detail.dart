import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/model/goal_model.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/common/widget/slidaction_widget.dart';
import 'package:monsey/feature/goal/screen/add_transaction.dart';
import 'package:monsey/feature/goal/screen/handle_goal.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/colors.dart';
import '../../../common/constant/styles.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/subscription.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../../transaction/widget/transaction_widget.dart';
import '../bloc/goal_detail.dart/bloc_goal_detail.dart';
import '../widget/circular_progress.dart';

class GoalDetail extends StatefulWidget {
  const GoalDetail({Key? key, required this.goalModel}) : super(key: key);
  final GoalModel goalModel;

  @override
  State<GoalDetail> createState() => _GoalDetailState();
}

class _GoalDetailState extends State<GoalDetail> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  Future<void> listenGoal() async {
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .subscribe(SubscriptionOptions(
            document: gql(Subscription.listenGoalById),
            variables: <String, dynamic>{'id': widget.goalModel.id}))
        .listen((event) {
      if (event.data!['Goal'].isNotEmpty) {
        if (mounted) {
          final GoalModel goalModel =
              GoalModel.fromJson(event.data!['Goal'][0]);
          context.read<GoalDetailBloc>().add(InitialGoalDetail(goalModel));
        }
      }
    });
  }

  @override
  void initState() {
    listenGoal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    final String symbol =
        BlocProvider.of<UserBloc>(context).userModel?.currencySymbol ?? '\$';
    return BlocBuilder<GoalDetailBloc, GoalDetailState>(builder: (context, st) {
      if (st is GoalDetailLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (st is GoalDetailLoaded) {
        return Scaffold(
          backgroundColor: emerald,
          appBar: AppWidget.createSimpleAppBar(
              context: context,
              backgroundColor: emerald,
              arrowColor: white,
              colorTitle: white,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.handleGoal,
                    arguments: HandleGoal(goalModel: st.goalDetail));
              },
              title: st.goalDetail.name,
              action: Image.asset(
                icPencilEdit,
                width: 24,
                height: 24,
                color: white,
              )),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgress(
                            size: height / 8,
                            moneyGoal: st.goalDetail.moneyGoal,
                            moneySaving: st.moneySaving,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  '${st.moneySaving >= widget.goalModel.moneyGoal ? '100' : (st.moneySaving / st.goalDetail.moneyGoal * 100).toStringAsFixed(2)}%',
                                  style: title3(color: white)),
                              Text(
                                LocaleKeys.done.tr().toLowerCase(),
                                style: subhead(color: white),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: -32,
                        left: -32,
                        child: Image.network(
                          st.goalDetail.categoryModel?.icon ?? iconOthers,
                          height: height / 7,
                          fit: BoxFit.cover,
                        ))
                  ],
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: snow,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32))),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.youHaveSave.tr(),
                                  style: body(color: grey700),
                                ),
                                Text(
                                  '$symbol${(st.moneySaving < 1 && st.moneySaving >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(st.moneySaving)}',
                                  style: title3(color: blueCrayola),
                                )
                              ],
                            ),
                            AppWidget.divider(context,
                                vertical: 8, color: grey200),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.goal.tr(),
                                  style: body(color: grey700),
                                ),
                                Text(
                                  '$symbol${(st.goalDetail.moneyGoal < 1 && st.goalDetail.moneyGoal >= 0) && symbol != '₫' ? '0' : ''}${formatMoney(context).format(st.goalDetail.moneyGoal)}',
                                  style: body(
                                      color: redCrayola, fontWeight: '600'),
                                )
                              ],
                            ),
                            AppWidget.divider(context,
                                vertical: 8, color: grey200),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.timeEnd.tr(),
                                  style: body(color: grey700),
                                ),
                                Text(
                                  FormatTime.formatTime(
                                      dateTime: st.goalDetail.timeEnd,
                                      format: Format.dMMy),
                                  style: body(context: context),
                                )
                              ],
                            ),
                            AppWidget.divider(context,
                                vertical: 16, color: grey300),
                            Text(
                              LocaleKeys.transactionHistory.tr(),
                              style: headline(context: context),
                            ),
                            ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return SlidactionWidget(
                                    showLabel: false,
                                    extentRatio: 0.2,
                                    removeFunc: () {
                                      context.read<GoalDetailBloc>().add(
                                          RemoveTransactionGoal(
                                              context,
                                              st.goalDetail.transGoal![index]
                                                  .id!,
                                              st.goalDetail.transGoal![index]
                                                  .balance));
                                    },
                                    child: listTileTransGoal(context,
                                        st.goalDetail.transGoal![index]),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    AppWidget.divider(context,
                                        color: grey200, vertical: 0),
                                itemCount:
                                    st.goalDetail.transGoal?.length ?? 0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 24),
                        child: AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.addMoney.tr(),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  Routes.addTransaction,
                                  arguments:
                                      AddTransaction(goalModel: st.goalDetail));
                            },
                            bgColor: emerald,
                            textColor: white),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }
}
