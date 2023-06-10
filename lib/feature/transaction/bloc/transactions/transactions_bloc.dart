import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/feature/home/bloc/chart/chart_bloc.dart';

import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/model/transaction_model.dart';
import 'bloc_transactions.dart';

const INDEX_MONTH_CURRENT = 10;
final List<DateTime> months = List.generate(
    12, (index) => DateTime(now.year, now.month - INDEX_MONTH_CURRENT + index));

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(TransactionsLoading()) {
    on<InitialTransactions>(_onInitialTransactions);
    on<RangeTransactions>(_onRangeTransaction);
    on<CreateTransaction>(_onCreateTransaction);
    on<EditTransaction>(_onEditTransaction);
    on<RemoveTransaction>(_onRemoveTransaction);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<TransactionInDayModel> totalTransactionRange = [];
  List<TransactionAllMonthsModel> transactionAllMonths = [];
  List<TransactionModel> transactions = [];

  void handleTransactions() {
    transactionAllMonths.clear();
    totalTransactionRange.clear();
    for (DateTime month in months) {
      final List<TransactionInDayModel> transactionsOneMonth = [];
      for (TransactionModel transaction in transactions) {
        if (isSameMonth(transaction.date, month)) {
          final int index = transactionsOneMonth.indexWhere(
              (element) => isSameDay(transaction.date, element.date));
          if (index != -1) {
            transactionsOneMonth[index].transactions.add(transaction);
          } else {
            transactionsOneMonth.add(TransactionInDayModel(
                date: transaction.date, transactions: [transaction]));
          }
        }
      }
      totalTransactionRange.addAll(transactionsOneMonth);
      transactionAllMonths.add(TransactionAllMonthsModel(
        date: month,
        transactionsOneMonth: transactionsOneMonth,
      ));
    }
  }

  Future<void> _onInitialTransactions(
      InitialTransactions event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      transactions.clear();
      transactions = await getTransactions(event.walletId);
      handleTransactions();
      emit(TransactionsLoaded(
        transactionAllMonths: transactionAllMonths,
        transactionsRangeDate: totalTransactionRange,
      ));
    } catch (_) {
      emit(TransactionsError());
    }
  }

  Future<void> _onRangeTransaction(
      RangeTransactions event, Emitter<TransactionsState> emit) async {
    final state = this.state;
    if (state is TransactionsLoaded) {
      try {
        final List<TransactionInDayModel> transactionsRange = [];
        for (TransactionInDayModel transactionInDayModel
            in totalTransactionRange) {
          if (transactionInDayModel.date.toUtc().isAfter(event.startDate) &&
              transactionInDayModel.date.toUtc().isBefore(event.endDate)) {
            transactionsRange.add(transactionInDayModel);
          }
        }
        emit(TransactionsLoaded(
          transactionAllMonths: transactionAllMonths,
          transactionsRangeDate: transactionsRange,
        ));
      } catch (_) {
        emit(TransactionsError());
      }
    }
  }

  Future<void> _onCreateTransaction(
      CreateTransaction event, Emitter<TransactionsState> emit) async {
    final state = this.state;
    if (state is TransactionsLoaded) {
      try {
        if (event.startDate == null) {
          emit(TransactionsLoading());
        }
        createTransaction(event.transactionModel);
        final TransactionModel newTran = TransactionModel(
            categoryModel: event.transactionModel.categoryModel,
            note: event.transactionModel.note,
            id: transactions.length,
            balance: event.transactionModel.balance,
            photoUrl: event.transactionModel.photoUrl,
            categoryId: event.transactionModel.categoryId,
            walletId: event.transactionModel.walletId,
            type: event.transactionModel.type,
            date: event.transactionModel.date);
        event.context.read<ChartBloc>().transactions.add(newTran);
        transactions.add(newTran);
        handleTransactions();
        if (event.startDate == null) {
          emit(TransactionsLoaded(
            transactionAllMonths: transactionAllMonths,
            transactionsRangeDate: totalTransactionRange,
          ));
        } else {
          add(RangeTransactions(event.transactionModel.walletId,
              event.startDate!, event.endDate!));
        }
      } catch (_) {
        emit(TransactionsError());
      }
    }
  }

  Future<void> _onEditTransaction(
      EditTransaction event, Emitter<TransactionsState> emit) async {
    final state = this.state;
    if (state is TransactionsLoaded) {
      try {
        if (event.startDate == null) {
          emit(TransactionsLoading());
        }
        editTransaction(event.transactionModel);
        event.context
            .read<ChartBloc>()
            .transactions
            .removeWhere((element) => element.id == event.transactionModel.id);
        event.context
            .read<ChartBloc>()
            .transactions
            .add(event.transactionModel);
        transactions
            .removeWhere((element) => element.id == event.transactionModel.id);
        transactions.add(event.transactionModel);
        handleTransactions();
        if (event.startDate == null) {
          emit(TransactionsLoaded(
            transactionAllMonths: transactionAllMonths,
            transactionsRangeDate: totalTransactionRange,
          ));
        } else {
          add(RangeTransactions(event.transactionModel.walletId,
              event.startDate!, event.endDate!));
        }
      } catch (_) {
        emit(TransactionsError());
      }
    }
  }

  Future<void> _onRemoveTransaction(
      RemoveTransaction event, Emitter<TransactionsState> emit) async {
    final state = this.state;
    if (state is TransactionsLoaded) {
      try {
        if (event.startDate == null) {
          emit(TransactionsLoading());
        }
        removeTransaction(event.transactionModel);
        event.context
            .read<ChartBloc>()
            .transactions
            .removeWhere((element) => element.id == event.transactionModel.id);
        transactions
            .removeWhere((element) => element.id == event.transactionModel.id);

        handleTransactions();
        if (event.startDate == null) {
          emit(TransactionsLoaded(
            transactionAllMonths: transactionAllMonths,
            transactionsRangeDate: totalTransactionRange,
          ));
        } else {
          add(RangeTransactions(event.transactionModel.walletId,
              event.startDate!, event.endDate!));
        }
      } catch (_) {
        emit(TransactionsError());
      }
    }
  }

  Future<List<TransactionModel>> getTransactions(int walletId) async {
    final List<TransactionModel> transactions = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getTransactionsByWalletId),
            variables: <String, dynamic>{'walletId': walletId}))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Transaction'].length > 0) {
        for (Map<String, dynamic> transaction in value.data!['Transaction']) {
          transactions.add(TransactionModel.fromJson(transaction));
        }
      }
    });
    return transactions;
  }

  Future<TransactionModel?> createTransaction(
      TransactionModel transactionModel) async {
    final String token = await firebaseUser.getIdToken();
    TransactionModel? newTran;
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.createTransaction()),
            variables: <String, dynamic>{
              'wallet_id': transactionModel.walletId,
              'category_id': transactionModel.categoryId,
              'balance': transactionModel.balance,
              'photo_url': transactionModel.photoUrl,
              'date': transactionModel.date.toIso8601String(),
              'note': transactionModel.note,
              'type': transactionModel.type,
            }))
        .then((value) {
      if (value.data!.isNotEmpty &&
          value.data!['insert_Transaction_one'].isNotEmpty) {
        newTran =
            TransactionModel.fromJson(value.data!['insert_Transaction_one']);
      }
    });
    return newTran;
  }

  Future<void> editTransaction(TransactionModel transactionModel) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateTransaction()),
            variables: <String, dynamic>{
              'id': transactionModel.id,
              'wallet_id': transactionModel.walletId,
              'category_id': transactionModel.categoryId,
              'balance': transactionModel.balance,
              'photo_url': transactionModel.photoUrl,
              'date': transactionModel.date.toIso8601String(),
              'note': transactionModel.note,
              'type': transactionModel.type,
            }));
  }

  Future<void> removeTransaction(TransactionModel transactionModel) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
        document: gql(Mutations.removeTransaction()),
        variables: <String, dynamic>{'id': transactionModel.id}));
  }
}
