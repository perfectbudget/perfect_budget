import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../common/model/goal_model.dart';

@immutable
abstract class GoalEvent extends Equatable {
  const GoalEvent();
}

class InitialGoal extends GoalEvent {
  @override
  List<Object> get props => [];
}

class CreateGoal extends GoalEvent {
  const CreateGoal(this.context, this.goal);
  final BuildContext context;
  final GoalModel goal;

  @override
  List<Object> get props => [context, goal];
}

class UpdateGoal extends GoalEvent {
  const UpdateGoal(this.context, this.goalModel);
  final BuildContext context;
  final GoalModel goalModel;

  @override
  List<Object> get props => [context, goalModel];
}

class RemoveGoal extends GoalEvent {
  const RemoveGoal(this.context, this.id);
  final BuildContext context;
  final int id;

  @override
  List<Object> get props => [context, id];
}
