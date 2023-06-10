import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../common/model/chart_model.dart';

@immutable
abstract class ChartState extends Equatable {
  const ChartState();
}

class ChartLoading extends ChartState {
  @override
  List<Object> get props => [];
}

class ChartLoaded extends ChartState {
  const ChartLoaded(
      {this.showingBarGroups = const <ChartBarBalance>[],
      this.dataPieChart = const <ChartData>[],
      this.dataIncomePieChart = const <ChartData>[],
      this.dataExpensePieChart = const <ChartData>[],
      this.incomeTotal = 0,
      this.expenseTotal = 0,
      this.maxY = 1000});
  final List<ChartBarBalance> showingBarGroups;
  final List<ChartData> dataPieChart;
  final List<ChartData> dataIncomePieChart;
  final List<ChartData> dataExpensePieChart;
  final double incomeTotal;
  final double expenseTotal;
  final double maxY;
  @override
  List<Object> get props => [
        showingBarGroups,
        incomeTotal,
        expenseTotal,
        maxY,
        dataPieChart,
        dataIncomePieChart,
        dataExpensePieChart,
      ];
}

class ChartError extends ChartState {
  @override
  List<Object> get props => [];
}
