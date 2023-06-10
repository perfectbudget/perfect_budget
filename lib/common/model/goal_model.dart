import 'package:equatable/equatable.dart';
import 'package:monsey/common/model/transaction_goal_model.dart';

import '../util/helper.dart';
import 'category_model.dart';

class GoalModel extends Equatable {
  const GoalModel({
    this.id,
    required this.name,
    required this.days,
    required this.timeStart,
    required this.timeEnd,
    required this.moneyGoal,
    required this.moneySaving,
    required this.categoryId,
    this.categoryModel,
    this.transGoal,
  });
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final List<TransactionGoalModel> transGoal = [];
    if (json['TransactionGoals'] != null) {
      for (Map<String, dynamic> e in json['TransactionGoals']) {
        transGoal.add(TransactionGoalModel.fromJson(e));
      }
    }

    return GoalModel(
        id: json['id'],
        name: json['name'],
        categoryId: int.tryParse(json['category_id'].toString()) ?? 1,
        moneySaving: double.tryParse(json['money_saving'].toString()) ?? 0,
        moneyGoal: double.tryParse(json['money_goal'].toString()) ?? 0,
        timeStart: DateTime.tryParse(json['time_start']) ?? now,
        timeEnd: DateTime.tryParse(json['time_end']) ?? now,
        days: int.tryParse(json['days'].toString()) ?? 0,
        categoryModel: CategoryModel.fromJson(json['Category']),
        transGoal: transGoal);
  }
  final int? id;
  final String name;
  final int days;
  final DateTime timeStart;
  final DateTime timeEnd;
  final double moneyGoal;
  final double moneySaving;
  final int categoryId;
  final CategoryModel? categoryModel;
  final List<TransactionGoalModel>? transGoal;

  @override
  List<Object?> get props => [
        name,
        days,
        timeStart,
        timeEnd,
        moneySaving,
        categoryModel,
        moneyGoal,
        transGoal,
        categoryId
      ];
}
