import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/transaction_model.dart';

@immutable
abstract class TransactionsState extends Equatable {
  const TransactionsState();
}

class TransactionsLoading extends TransactionsState {
  @override
  List<Object> get props => [];
}

class TransactionsLoaded extends TransactionsState {
  const TransactionsLoaded({
    this.transactionAllMonths = const <TransactionAllMonthsModel>[],
    this.transactionsRangeDate = const <TransactionInDayModel>[],
  });

  final List<TransactionAllMonthsModel> transactionAllMonths;
  final List<TransactionInDayModel> transactionsRangeDate;

  @override
  List<Object> get props => [transactionsRangeDate, transactionAllMonths];
}

class TransactionsError extends TransactionsState {
  @override
  List<Object> get props => [];
}
