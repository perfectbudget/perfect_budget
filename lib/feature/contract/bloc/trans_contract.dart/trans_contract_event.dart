import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/transaction_contract_model.dart';

@immutable
abstract class TransContractEvent extends Equatable {
  const TransContractEvent();
}

class InitialTransContract extends TransContractEvent {
  @override
  List<Object> get props => [];
}

class CreateTransContract extends TransContractEvent {
  const CreateTransContract(this.context, this.transContract);
  final BuildContext context;
  final TransactionContractModel transContract;

  @override
  List<Object> get props => [context, transContract];
}

class UpdateTransContract extends TransContractEvent {
  const UpdateTransContract(this.context, this.id);
  final BuildContext context;
  final int id;

  @override
  List<Object> get props => [context, id];
}

class RemoveTransContract extends TransContractEvent {
  const RemoveTransContract(this.context, this.transContract);
  final BuildContext context;
  final TransactionContractModel transContract;

  @override
  List<Object> get props => [context, transContract];
}
