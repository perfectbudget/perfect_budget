import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/transaction_model.dart';

@immutable
abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
}

class InitialTransactions extends TransactionsEvent {
  const InitialTransactions(this.walletId);
  final int walletId;
  @override
  List<Object> get props => [walletId];
}

class RangeTransactions extends TransactionsEvent {
  const RangeTransactions(this.walletId, this.startDate, this.endDate);
  final DateTime startDate;
  final DateTime endDate;
  final int walletId;
  @override
  List<Object> get props => [walletId, startDate, endDate];
}

class CreateTransaction extends TransactionsEvent {
  const CreateTransaction(
      this.context, this.transactionModel, this.startDate, this.endDate);
  final BuildContext context;
  final TransactionModel transactionModel;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [context, transactionModel, startDate!, endDate!];
}

class EditTransaction extends TransactionsEvent {
  const EditTransaction(
      this.context, this.transactionModel, this.startDate, this.endDate);
  final BuildContext context;
  final TransactionModel transactionModel;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [context, transactionModel, startDate!, endDate!];
}

class RemoveTransaction extends TransactionsEvent {
  const RemoveTransaction(
      this.context, this.transactionModel, this.startDate, this.endDate);
  final BuildContext context;
  final TransactionModel transactionModel;
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  List<Object> get props => [context, transactionModel, startDate!, endDate!];
}
