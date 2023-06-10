import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/goal_model.dart';

@immutable
abstract class GoalState extends Equatable {
  const GoalState();
}

class GoalLoading extends GoalState {
  @override
  List<Object> get props => [];
}

class GoalLoaded extends GoalState {
  const GoalLoaded(
      {this.goals = const <GoalModel>[], this.totalMoneySaving = 0});

  final List<GoalModel> goals;
  final double totalMoneySaving;

  @override
  List<Object> get props => [goals, totalMoneySaving];
}

class GoalError extends GoalState {
  @override
  List<Object> get props => [];
}
