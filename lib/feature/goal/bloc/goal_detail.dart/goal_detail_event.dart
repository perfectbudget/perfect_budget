import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/goal_model.dart';
import 'package:monsey/common/model/transaction_goal_model.dart';

@immutable
abstract class GoalDetailEvent extends Equatable {
  const GoalDetailEvent();
}

class InitialGoalDetail extends GoalDetailEvent {
  const InitialGoalDetail(this.goalModel);
  final GoalModel goalModel;
  @override
  List<Object> get props => [goalModel];
}

class CreateTransactionGoal extends GoalDetailEvent {
  const CreateTransactionGoal(this.context, this.transGoalModel);
  final BuildContext context;
  final TransactionGoalModel transGoalModel;

  @override
  List<Object> get props => [context, transGoalModel];
}

class UpdateTransactionGoal extends GoalDetailEvent {
  const UpdateTransactionGoal(this.id, this.balance, this.note);
  final int id;
  final double balance;
  final String note;

  @override
  List<Object> get props => [id, balance, note];
}

class RemoveTransactionGoal extends GoalDetailEvent {
  const RemoveTransactionGoal(this.context, this.id, this.money);
  final BuildContext context;
  final int id;
  final double money;

  @override
  List<Object> get props => [context, id, money];
}
