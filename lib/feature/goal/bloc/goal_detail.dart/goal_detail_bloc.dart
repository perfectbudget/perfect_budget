import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/model/goal_model.dart';

import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/model/transaction_goal_model.dart';
import 'bloc_goal_detail.dart';

class GoalDetailBloc extends Bloc<GoalDetailEvent, GoalDetailState> {
  GoalDetailBloc() : super(GoalDetailLoading()) {
    on<InitialGoalDetail>(_onInitialGoalDetail);
    on<CreateTransactionGoal>(_onCreateTransactionGoal);
    on<RemoveTransactionGoal>(_onRemoveTransactionGoal);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  GoalModel? goalDetail;
  double moneySaving = 0;

  Future<void> _onInitialGoalDetail(
      InitialGoalDetail event, Emitter<GoalDetailState> emit) async {
    emit(GoalDetailLoading());
    try {
      goalDetail = event.goalModel;
      moneySaving = goalDetail!.moneySaving;
      emit(GoalDetailLoaded(goalDetail: goalDetail!, moneySaving: moneySaving));
    } catch (_) {
      emit(GoalDetailError());
    }
  }

  Future<void> _onCreateTransactionGoal(
      CreateTransactionGoal event, Emitter<GoalDetailState> emit) async {
    final state = this.state;
    if (state is GoalDetailLoaded) {
      try {
        createTransactionGoal(event.transGoalModel, event.context);
        moneySaving += event.transGoalModel.balance;
        updateMoneySavingGoalDetail(goalDetail!.id!, moneySaving);
        emit(GoalDetailLoaded(
            goalDetail: goalDetail!, moneySaving: moneySaving));
      } catch (e) {
        emit(GoalDetailError());
      }
    }
  }

  Future<void> _onRemoveTransactionGoal(
      RemoveTransactionGoal event, Emitter<GoalDetailState> emit) async {
    final state = this.state;
    if (state is GoalDetailLoaded) {
      try {
        removeTransactionGoal(event.id);
        goalDetail!.transGoal!.removeWhere((element) => element.id == event.id);
        moneySaving -= event.money;
        updateMoneySavingGoalDetail(goalDetail!.id!, moneySaving);
        emit(GoalDetailLoaded(
            goalDetail: goalDetail!, moneySaving: moneySaving));
      } catch (_) {
        emit(GoalDetailError());
      }
    }
  }

  Future<GoalModel?> getGoalDetail(int id) async {
    GoalModel? goalDetail;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getGoalById),
            variables: <String, dynamic>{
              'id': id,
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Goal'].isNotEmpty) {
        goalDetail = GoalModel.fromJson(value.data!['Goal'][0]);
      }
    });
    return goalDetail;
  }

  Future<TransactionGoalModel?> createTransactionGoal(
      TransactionGoalModel transGoalModel, BuildContext context) async {
    TransactionGoalModel? newTransGoal;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.insertTransactionGoal()),
            variables: <String, dynamic>{
              'balance': transGoalModel.balance,
              'goal_id': transGoalModel.goalId,
              'note': transGoalModel.note,
            }))
        .then((value) {
      if (value.data!.isNotEmpty &&
          value.data!['insert_TransactionGoal_one'].isNotEmpty) {
        newTransGoal = TransactionGoalModel.fromJson(
            value.data!['insert_TransactionGoal_one']);
      }
    });
    return newTransGoal;
  }

  Future<void> updateMoneySavingGoalDetail(int id, double money) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateMoneySavingGoal()),
            variables: <String, dynamic>{
              'id': id,
              'money_saving': money,
            }));
  }

  Future<void> removeTransactionGoal(int id) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.deleteTransactionGoal()),
            variables: <String, dynamic>{
              'id': id,
            }));
  }
}
