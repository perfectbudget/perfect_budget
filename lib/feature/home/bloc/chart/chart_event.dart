import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/constant/enums.dart';

@immutable
abstract class ChartEvent extends Equatable {
  const ChartEvent();
}

class InitialChart extends ChartEvent {
  const InitialChart(
      {required this.walletId, this.typeDate = TypeDate.MONTHLY});
  final int walletId;
  final TypeDate typeDate;

  @override
  List<Object> get props => [walletId, typeDate];
}

class ChangeTimeChart extends ChartEvent {
  const ChangeTimeChart(
      {required this.walletId,
      required this.dateTime,
      this.typeDate = TypeDate.MONTHLY});
  final int walletId;
  final DateTime dateTime;
  final TypeDate typeDate;
  @override
  List<Object> get props => [walletId, dateTime, typeDate];
}
