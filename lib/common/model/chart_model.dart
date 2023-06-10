// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/category_model.dart';

import 'transaction_model.dart';

class ColumnGroupBarModel extends Equatable {
  ColumnGroupBarModel({required this.x, required this.y1, required this.y2});
  final int x;
  double y1;
  double y2;

  @override
  List<Object?> get props => [x, y1, y2];
}

class ColumnBarChartModel extends Equatable {
  ColumnBarChartModel({required this.x, required this.y});
  final int x;
  double y;

  @override
  List<Object?> get props => [x, y];
}

class ChartData extends Equatable {
  ChartData({this.categoryModel, required this.balance, required this.trans});
  final CategoryModel? categoryModel;
  double balance;
  List<TransactionModel> trans;
  @override
  List<Object?> get props => [
        categoryModel,
        balance,
        trans,
      ];
}

class ChartPieTotalBalance extends Equatable {
  const ChartPieTotalBalance(this.type, this.color, {required this.balance});
  final String type;
  final Color color;
  final double balance;
  @override
  List<Object?> get props => [
        type,
        color,
        balance,
      ];
}

class ChartBarBalance extends Equatable {
  const ChartBarBalance(this.income, this.expense);
  final double income;
  final double expense;
  @override
  List<Object?> get props => [
        income,
        expense,
      ];
}
