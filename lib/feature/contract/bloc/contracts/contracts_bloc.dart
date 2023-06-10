import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/model/contract_model.dart';
import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/util/helper.dart';
import 'bloc_contracts.dart';

class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
  ContractsBloc() : super(ContractsLoading()) {
    on<InitialContracts>(_onInitialContracts);
    on<CreateContract>(_onCreateContract);
    on<UpdateContract>(_onUpdateContract);
    on<RemoveContract>(_onRemoveContract);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  double moneyLendTotal = 0;
  double moneyBorrowTotal = 0;
  List<ContractModel> contractTotal = [];
  List<ContractModel> contractLend = [];
  List<ContractModel> contractBorrow = [];
  List<ContractModel> contractWaiting = [];

  Future<void> _onInitialContracts(
      InitialContracts event, Emitter<ContractsState> emit) async {
    emit(ContractsLoading());
    try {
      moneyLendTotal = 0;
      moneyBorrowTotal = 0;
      contractTotal.clear();
      contractLend.clear();
      contractBorrow.clear();
      contractWaiting.clear();
      contractTotal = await getContracts();
      for (ContractModel contractModel in contractTotal) {
        if (contractModel.status == StatusContract.WAITING &&
            contractModel.emailBorrower == firebaseUser.email) {
          contractWaiting.add(contractModel);
        }
        if (contractModel.status != StatusContract.WAITING) {
          if (contractModel.emailLender == firebaseUser.email) {
            contractLend.add(contractModel);
            moneyLendTotal += contractModel.money;
          } else {
            contractBorrow.add(contractModel);
            moneyBorrowTotal += contractModel.money;
          }
        }
      }
      emit(ContractsLoaded(
          contractTotal: contractTotal,
          contractLend: contractLend,
          contractBorrow: contractBorrow,
          contractWaiting: contractWaiting));
    } catch (_) {
      emit(ContractsError());
    }
  }

  Future<void> _onCreateContract(
      CreateContract event, Emitter<ContractsState> emit) async {
    final state = this.state;
    if (state is ContractsLoaded) {
      try {
        createContract(event.contract, event.context);
        emit(ContractsLoaded(
            contractLend: contractLend,
            contractBorrow: contractBorrow,
            contractWaiting: contractWaiting));
      } catch (e) {
        emit(ContractsError());
      }
    }
  }

  Future<void> _onUpdateContract(
      UpdateContract event, Emitter<ContractsState> emit) async {
    final state = this.state;
    if (state is ContractsLoaded) {
      try {
        updateContract(event.id, event.statusContract);
        emit(ContractsLoaded(
            contractLend: contractLend,
            contractBorrow: contractBorrow,
            contractWaiting: contractWaiting));
      } catch (_) {
        emit(ContractsError());
      }
    }
  }

  Future<void> _onRemoveContract(
      RemoveContract event, Emitter<ContractsState> emit) async {
    final state = this.state;
    if (state is ContractsLoaded) {
      try {
        removeContract(event.id);
        emit(
          ContractsLoaded(
              contractLend: contractLend,
              contractBorrow: contractBorrow,
              contractWaiting: contractWaiting),
        );
      } catch (_) {
        emit(ContractsError());
      }
    }
  }

  Future<List<ContractModel>> getContracts() async {
    final List<ContractModel> contracts = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getContracts),
            variables: <String, dynamic>{
              'email': firebaseUser.email,
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Contract'].length > 0) {
        for (Map<String, dynamic> contract in value.data!['Contract']) {
          contracts.add(ContractModel.fromJson(contract));
        }
      }
    });

    return contracts;
  }

  Future<ContractModel?> createContract(
      ContractModel contractModel, BuildContext context) async {
    ContractModel? contract;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.insertContract()),
            variables: <String, dynamic>{
              'email_borrower': contractModel.emailBorrower,
              'email_lender': contractModel.emailLender,
              'avatar_borrower': contractModel.avtBorrower,
              'avatar_lender': contractModel.avtLender,
              'name_contract': contractModel.nameContract,
              'money': contractModel.money,
              'status': handleStatusContract(contractModel.status),
              'real_money_to_pay': contractModel.realMoneyToPay,
              'interest_rate': contractModel.interestRate,
              'is_send_mail': contractModel.isSendMail,
              'is_send_notify': contractModel.isSendNotify,
            }))
        .then((value) {
      if (value.data!.isNotEmpty &&
          value.data!['insert_Contract_one'].isNotEmpty) {
        contract = ContractModel.fromJson(value.data!['insert_Contract_one']);
      }
    });
    return contract;
  }

  Future<void> updateContract(int id, StatusContract statusContract) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateContract()),
            variables: <String, dynamic>{
              'id': id,
              'status': handleStatusContract(statusContract),
            }));
  }

  Future<void> removeContract(int id) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.removeContract()),
            variables: <String, dynamic>{
              'id': id,
            }));
  }
}
