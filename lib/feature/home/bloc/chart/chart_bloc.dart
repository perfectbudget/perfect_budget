import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/util/helper.dart';

import '../../../../common/constant/enums.dart';
import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/model/chart_model.dart';
import '../../../../common/model/transaction_model.dart';
import 'bloc_chart.dart';

const INDEX_MONTH_CURRENT = 10;
const INDEX_YEAR_CURRENT = 4;
final List<DateTime> months = List.generate(
    12, (index) => DateTime(now.year, now.month - INDEX_MONTH_CURRENT + index));
final List<DateTime> years = List.generate(
    6,
    (index) => DateTime(
          now.year - INDEX_YEAR_CURRENT + index,
        ));

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartLoading()) {
    on<InitialChart>(_onInitialChart);
    on<ChangeTimeChart>(_onChangeTimeChart);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;

  List<TransactionModel> transactions = [];
  List<ChartBarBalance> showingBarGroups = [];
  List<ChartData> dataPieChart = [];
  List<ChartData> dataIncomePieChart = [];
  List<ChartData> dataExpensePieChart = [];

  double incomeTotal = 0;
  double expenseTotal = 0;
  double maxY = 1000;
  DateTime dateTime = now;
  TypeDate typeDate = TypeDate.MONTHLY;

  void handleData(
      List<ChartData> dataPieChart,
      List<ChartData> dataIncomePieChart,
      List<ChartData> dataExpensePieChart,
      List<ColumnGroupBarModel> rawBarGroups,
      bool isIncome,
      TypeDate typeDate,
      int date,
      TransactionModel trans) {
    if (isIncome) {
      incomeTotal += trans.balance;
    } else {
      expenseTotal += trans.balance;
    }
    //check in pie chart

    final int ind =
        dataPieChart.indexWhere((e) => trans.categoryId == e.categoryModel!.id);
    if (ind != -1) {
      dataPieChart[ind].balance += trans.balance;
      dataPieChart[ind].trans.add(trans);
    } else {
      dataPieChart.add(ChartData(
          trans: [trans],
          balance: trans.balance,
          categoryModel: trans.categoryModel!));
    }

    if (isIncome) {
      final int indIncome = dataIncomePieChart
          .indexWhere((e) => trans.categoryId == e.categoryModel!.id);
      if (indIncome != -1) {
        dataIncomePieChart[indIncome].balance += trans.balance;
        dataIncomePieChart[indIncome].trans.add(trans);
      } else {
        dataIncomePieChart.add(ChartData(
            trans: [trans],
            balance: trans.balance,
            categoryModel: trans.categoryModel!));
      }
    } else {
      final int indExpense = dataExpensePieChart
          .indexWhere((e) => trans.categoryId == e.categoryModel!.id);
      if (indExpense != -1) {
        dataExpensePieChart[indExpense].balance += trans.balance;
        dataExpensePieChart[indExpense].trans.add(trans);
      } else {
        dataExpensePieChart.add(ChartData(
            trans: [trans],
            categoryModel: trans.categoryModel!,
            balance: trans.balance));
      }
    }

    //check in bar chart
    final int index = rawBarGroups.indexWhere((element) =>
        typeDate == TypeDate.ALLTIME
            ? date == now.year - INDEX_YEAR_CURRENT + (element.x - 1)
            : date == element.x);
    if (isIncome) {
      rawBarGroups[index].y1 += trans.balance;
    } else {
      rawBarGroups[index].y2 += trans.balance;
    }
  }

  void handleTransactions(DateTime dateTime, TypeDate typeDate, int walletId) {
    dataPieChart.clear();
    dataIncomePieChart.clear();
    dataExpensePieChart.clear();
    incomeTotal = 0;
    expenseTotal = 0;
    List<TransactionModel> tmpTrans = transactions;
    final List<ColumnGroupBarModel> rawBarGroups = List.generate(
        typeDate == TypeDate.MONTHLY
            ? daysInMonth(dateTime)
            : typeDate == TypeDate.YEARLY
                ? 12
                : 6,
        (index) => ColumnGroupBarModel(x: index + 1, y1: 0, y2: 0));

    if (walletId != 0) {
      tmpTrans = transactions
          .where((element) => element.walletId == walletId)
          .toList();
    }
    for (TransactionModel transaction in tmpTrans) {
      final bool isIncome = transaction.type == 'income';
      if (typeDate == TypeDate.MONTHLY) {
        if (isSameMonth(transaction.date, dateTime)) {
          handleData(
              dataPieChart,
              dataIncomePieChart,
              dataExpensePieChart,
              rawBarGroups,
              isIncome,
              TypeDate.MONTHLY,
              transaction.date.day,
              transaction);
        }
      }
      if (typeDate == TypeDate.YEARLY) {
        if (isSameYear(transaction.date, dateTime)) {
          handleData(
              dataPieChart,
              dataIncomePieChart,
              dataExpensePieChart,
              rawBarGroups,
              isIncome,
              TypeDate.YEARLY,
              transaction.date.month,
              transaction);
        }
      }
      if (typeDate == TypeDate.ALLTIME) {
        if (isSameYear(transaction.date, dateTime)) {
          handleData(
              dataPieChart,
              dataIncomePieChart,
              dataExpensePieChart,
              rawBarGroups,
              isIncome,
              TypeDate.ALLTIME,
              transaction.date.year,
              transaction);
        }
      }
    }
    maxY = (incomeTotal == 0 && expenseTotal == 0)
        ? 1000
        : incomeTotal > expenseTotal
            ? incomeTotal
            : expenseTotal;
    showingBarGroups = List.generate(
        typeDate == TypeDate.MONTHLY
            ? rawBarGroups.length
            : (typeDate == TypeDate.YEARLY ? 12 : 6),
        (index) => ChartBarBalance(rawBarGroups[index].y1 / maxY * 10,
            rawBarGroups[index].y2 / maxY * 10));
  }

  Future<void> _onInitialChart(
      InitialChart event, Emitter<ChartState> emit) async {
    emit(ChartLoading());
    try {
      transactions.clear();
      transactions = await getTransactions();
      handleTransactions(now, event.typeDate, event.walletId);
      emit(ChartLoaded(
          dataPieChart: dataPieChart,
          dataIncomePieChart: dataIncomePieChart,
          dataExpensePieChart: dataExpensePieChart,
          showingBarGroups: showingBarGroups,
          incomeTotal: incomeTotal,
          expenseTotal: expenseTotal,
          maxY: maxY));
    } catch (_) {
      emit(ChartError());
    }
  }

  Future<void> _onChangeTimeChart(
      ChangeTimeChart event, Emitter<ChartState> emit) async {
    final state = this.state;
    if (state is ChartLoaded) {
      try {
        handleTransactions(event.dateTime, event.typeDate, event.walletId);
        dateTime = event.dateTime;
        typeDate = event.typeDate;
        emit(ChartLoaded(
            dataPieChart: dataPieChart,
            dataIncomePieChart: dataIncomePieChart,
            dataExpensePieChart: dataExpensePieChart,
            showingBarGroups: showingBarGroups,
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal,
            maxY: maxY));
      } catch (_) {
        emit(ChartError());
      }
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    final List<TransactionModel> transactions = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getAllTransactions),
            variables: <String, dynamic>{
              'user_uuid': firebaseUser.uid,
              '_gte': years[0].toIso8601String(),
              '_lte': years[5].toIso8601String(),
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Transaction'].length > 0) {
        for (Map<String, dynamic> transaction in value.data!['Transaction']) {
          transactions.add(TransactionModel.fromJson(transaction));
        }
      }
    });
    return transactions;
  }
}
