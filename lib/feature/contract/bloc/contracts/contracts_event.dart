import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/constant/enums.dart';

import '../../../../common/model/contract_model.dart';

@immutable
abstract class ContractsEvent extends Equatable {
  const ContractsEvent();
}

class InitialContracts extends ContractsEvent {
  @override
  List<Object> get props => [];
}

class CreateContract extends ContractsEvent {
  const CreateContract(this.context, this.contract);
  final BuildContext context;
  final ContractModel contract;

  @override
  List<Object> get props => [context, contract];
}

class UpdateContract extends ContractsEvent {
  const UpdateContract(this.context, this.id, this.statusContract);
  final BuildContext context;
  final int id;
  final StatusContract statusContract;

  @override
  List<Object> get props => [context, id, statusContract];
}

class RemoveContract extends ContractsEvent {
  const RemoveContract(this.context, this.id);
  final BuildContext context;
  final int id;

  @override
  List<Object> get props => [context, id];
}
