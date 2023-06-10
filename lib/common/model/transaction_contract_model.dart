import 'package:equatable/equatable.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/model/contract_model.dart';
import 'package:monsey/common/util/helper.dart';

class TransactionContractModel extends Equatable {
  const TransactionContractModel(
      {this.id,
      required this.contractId,
      required this.status,
      required this.moneyPaid,
      this.note,
      required this.payDate,
      this.contractModel});

  factory TransactionContractModel.fromJson(Map<String, dynamic> json) {
    return TransactionContractModel(
        id: json['id'],
        contractId: json['contract_id'],
        moneyPaid: json['money_paid'],
        payDate: DateTime.tryParse(json['pay_date']) ?? now,
        note: json['note'],
        status: handleStatusTransContract2(json['status']),
        contractModel: ContractModel.fromJson(json['Contract']));
  }
  final int? id;
  final int contractId;
  final int moneyPaid;
  final DateTime payDate;
  final String? note;
  final StatusTranCt status;
  final ContractModel? contractModel;

  @override
  List<Object?> get props =>
      [id, contractId, moneyPaid, payDate, status, note, contractModel];
}
