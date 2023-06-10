import 'package:equatable/equatable.dart';
import 'package:monsey/common/model/category_model.dart';
import 'package:monsey/common/util/helper.dart';

class TransactionModel extends Equatable {
  const TransactionModel(
      {this.categoryModel,
      required this.balance,
      required this.categoryId,
      required this.walletId,
      required this.type,
      this.photoUrl,
      this.id,
      required this.date,
      this.note,
      this.updateAt,
      this.createAt});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      walletId: json['wallet_id'],
      categoryId: json['category_id'],
      balance: double.tryParse(json['balance'].toString()) ?? 0,
      date: DateTime.tryParse(json['date']) ?? now,
      note: json['note'],
      type: json['type'],
      photoUrl: json['photo_url'],
      categoryModel: CategoryModel.fromJson(json['Category']),
    );
  }
  final int? id;
  final int walletId;
  final int categoryId;
  final double balance;
  final DateTime date;
  final String? note;
  final String type;
  final String? photoUrl;
  final CategoryModel? categoryModel;
  final DateTime? createAt;
  final DateTime? updateAt;

  @override
  List<Object?> get props => [
        id,
        walletId,
        categoryId,
        balance,
        date,
        note,
        type,
        photoUrl,
        categoryModel,
        createAt,
        updateAt
      ];
}

class TransactionInDayModel extends Equatable {
  const TransactionInDayModel({
    required this.date,
    required this.transactions,
  });
  final DateTime date;
  final List<TransactionModel> transactions;

  @override
  List<Object?> get props => [date, transactions];
}

class TransactionAllMonthsModel extends Equatable {
  const TransactionAllMonthsModel({
    required this.date,
    required this.transactionsOneMonth,
  });
  final DateTime date;
  final List<TransactionInDayModel> transactionsOneMonth;

  @override
  List<Object?> get props => [date, transactionsOneMonth];
}
