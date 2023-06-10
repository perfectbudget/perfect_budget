import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/goal_model.dart';

@immutable
abstract class GoalDetailState extends Equatable {
  const GoalDetailState();
}

class GoalDetailLoading extends GoalDetailState {
  @override
  List<Object> get props => [];
}

class GoalDetailLoaded extends GoalDetailState {
  const GoalDetailLoaded({required this.goalDetail, required this.moneySaving});

  final GoalModel goalDetail;
  final double moneySaving;

  @override
  List<Object> get props => [goalDetail, moneySaving];
}

class GoalDetailError extends GoalDetailState {
  @override
  List<Object> get props => [];
}
