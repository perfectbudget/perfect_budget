import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/transaction_contract_model.dart';

@immutable
abstract class TransContractState extends Equatable {
  const TransContractState();
}

class TransContractLoading extends TransContractState {
  @override
  List<Object> get props => [];
}

class TransContractLoaded extends TransContractState {
  const TransContractLoaded({
    this.transContract = const <TransactionContractModel>[],
  });

  final List<TransactionContractModel> transContract;

  @override
  List<Object> get props => [transContract];
}

class TransContractError extends TransContractState {
  @override
  List<Object> get props => [];
}
