import 'package:equatable/equatable.dart';
import 'package:monsey/common/model/transaction_model.dart';
import 'package:monsey/common/model/user_model.dart';
import 'package:monsey/common/util/helper.dart';

import '../constant/enums.dart';

class ContractModel extends Equatable {
  const ContractModel(
      {this.id,
      required this.emailLender,
      required this.emailBorrower,
      required this.avtBorrower,
      required this.avtLender,
      required this.interestRate,
      required this.isSendMail,
      required this.isSendNotify,
      required this.money,
      required this.realMoneyToPay,
      required this.status,
      required this.nameContract,
      this.transactions,
      this.lender});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final List<TransactionModel> transactions = [];
    if (json['Transactions'] != null) {
      for (Map<String, dynamic> e in json['Transactions']) {
        transactions.add(TransactionModel.fromJson(e));
      }
    }
    return ContractModel(
        id: json['id'],
        emailLender: json['email_lender'],
        emailBorrower: json['email_borrower'],
        avtBorrower: json['avatar_borrower'],
        avtLender: json['avatar_lender'] ?? defaultAvatar,
        nameContract: json['name_contract'],
        money: json['money'],
        interestRate: json['interest_rate'].toDouble(),
        realMoneyToPay: json['real_money_to_pay'],
        isSendMail: json['is_send_mail'],
        isSendNotify: json['is_send_notify'],
        status: handleStatusContract2(json['status']),
        lender: UserModel.fromJson(json['Lender']),
        transactions: transactions);
  }
  final int? id;
  final String emailLender;
  final String emailBorrower;
  final String avtBorrower;
  final String avtLender;
  final String nameContract;
  final int money;
  final double interestRate;
  final int realMoneyToPay;
  final bool isSendMail;
  final bool isSendNotify;
  final StatusContract status;
  final List<TransactionModel>? transactions;
  final UserModel? lender;

  @override
  List<Object?> get props => [
        id!,
        status,
        emailBorrower,
        emailLender,
        avtBorrower,
        avtLender,
        nameContract,
        money,
        interestRate,
        isSendNotify,
        isSendMail,
        realMoneyToPay,
        transactions!,
        lender!,
      ];
}
