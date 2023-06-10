import 'package:equatable/equatable.dart';
import 'package:monsey/common/util/helper.dart';

class TransactionGoalModel extends Equatable {
  const TransactionGoalModel(
      {required this.balance,
      this.id,
      required this.goalId,
      required this.date,
      this.note,
      this.updateAt,
      this.createAt});

  factory TransactionGoalModel.fromJson(Map<String, dynamic> json) {
    return TransactionGoalModel(
      id: json['id'],
      goalId: json['goal_id'],
      balance: double.tryParse(json['balance'].toString()) ?? 0,
      date: DateTime.tryParse(json['date']) ?? now,
      note: json['note'],
    );
  }
  final int? id;
  final double balance;
  final DateTime date;
  final String? note;
  final int goalId;
  final DateTime? createAt;
  final DateTime? updateAt;

  @override
  List<Object?> get props =>
      [id, balance, date, note, goalId, createAt, updateAt];
}
