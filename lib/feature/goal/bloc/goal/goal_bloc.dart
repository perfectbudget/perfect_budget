import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/model/goal_model.dart';
import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import 'bloc_goal.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc() : super(GoalLoading()) {
    on<InitialGoal>(_onInitialGoal);
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<RemoveGoal>(_onRemoveGoal);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  double totalMoneySaving = 0;
  List<GoalModel> goals = [];

  void computeTotalMoney() {
    totalMoneySaving = 0;
    for (GoalModel goal in goals) {
      totalMoneySaving += goal.moneySaving;
    }
  }

  Future<void> _onInitialGoal(
      InitialGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      goals.clear();
      goals = await getGoal();
      computeTotalMoney();
      emit(GoalLoaded(goals: goals, totalMoneySaving: totalMoneySaving));
    } catch (_) {
      emit(GoalError());
    }
  }

  Future<void> _onCreateGoal(CreateGoal event, Emitter<GoalState> emit) async {
    final state = this.state;
    if (state is GoalLoaded) {
      try {
        final GoalModel? newGoal = await createGoal(event.goal, event.context);
        if (newGoal != null) {
          goals.add(newGoal);
          computeTotalMoney();
          emit(GoalLoaded(goals: goals, totalMoneySaving: totalMoneySaving));
        }
      } catch (e) {
        emit(GoalError());
      }
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    final state = this.state;
    if (state is GoalLoaded) {
      try {
        updateGoal(event.goalModel);
        goals.removeWhere((element) => element.id == event.goalModel.id);
        goals.add(event.goalModel);
        computeTotalMoney();
        emit(GoalLoaded(goals: goals, totalMoneySaving: totalMoneySaving));
      } catch (_) {
        emit(GoalError());
      }
    }
  }

  Future<void> _onRemoveGoal(RemoveGoal event, Emitter<GoalState> emit) async {
    final state = this.state;
    if (state is GoalLoaded) {
      try {
        removeGoal(event.id);
        goals.removeWhere((element) => element.id == event.id);
        computeTotalMoney();
        emit(GoalLoaded(goals: goals, totalMoneySaving: totalMoneySaving));
      } catch (_) {
        emit(GoalError());
      }
    }
  }

  Future<List<GoalModel>> getGoal() async {
    final List<GoalModel> goals = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getAllGoals),
            variables: <String, dynamic>{
              'user_uuid': firebaseUser.uid,
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Goal'].length > 0) {
        for (Map<String, dynamic> goal in value.data!['Goal']) {
          goals.add(GoalModel.fromJson(goal));
        }
      }
    });

    return goals;
  }

  Future<GoalModel?> createGoal(
      GoalModel goalModel, BuildContext context) async {
    GoalModel? newGoal;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.insertGoal()),
            variables: <String, dynamic>{
              'name': goalModel.name,
              'days': goalModel.days,
              'money_saving': goalModel.moneySaving,
              'money_goal': goalModel.moneyGoal,
              'time_start': goalModel.timeStart.toIso8601String(),
              'time_end': goalModel.timeEnd.toIso8601String(),
              'category_id': goalModel.categoryId,
              'user_uuid': firebaseUser.uid
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['insert_Goal_one'].isNotEmpty) {
        newGoal = GoalModel.fromJson(value.data!['insert_Goal_one']);
      }
    });
    return newGoal;
  }

  Future<void> updateGoal(GoalModel goalModel) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateGoal()),
            variables: <String, dynamic>{
              'id': goalModel.id,
              'name': goalModel.name,
              'days': goalModel.days,
              'money_goal': goalModel.moneyGoal,
              'time_end': goalModel.timeEnd.toIso8601String(),
              'category_id': goalModel.categoryId,
              'user_uuid': firebaseUser.uid
            }));
  }

  Future<void> removeGoal(int id) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.deleteGoal()),
            variables: <String, dynamic>{
              'id': id,
            }));
  }
}
