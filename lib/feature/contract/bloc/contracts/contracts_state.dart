import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../common/model/contract_model.dart';

@immutable
abstract class ContractsState extends Equatable {
  const ContractsState();
}

class ContractsLoading extends ContractsState {
  @override
  List<Object> get props => [];
}

class ContractsLoaded extends ContractsState {
  const ContractsLoaded({
    this.contractLend = const <ContractModel>[],
    this.contractBorrow = const <ContractModel>[],
    this.contractWaiting = const <ContractModel>[],
    this.contractTotal = const <ContractModel>[],
  });

  final List<ContractModel> contractLend;
  final List<ContractModel> contractBorrow;
  final List<ContractModel> contractWaiting;
  final List<ContractModel> contractTotal;

  @override
  List<Object> get props =>
      [contractLend, contractBorrow, contractWaiting, contractTotal];
}

class ContractsError extends ContractsState {
  @override
  List<Object> get props => [];
}
