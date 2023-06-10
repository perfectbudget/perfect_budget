import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/model/transaction_contract_model.dart';
import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/util/helper.dart';
import 'bloc_trans_contract.dart';

class TransContractBloc extends Bloc<TransContractEvent, TransContractState> {
  TransContractBloc() : super(TransContractLoading()) {
    on<InitialTransContract>(_onInitialTransContract);
    on<CreateTransContract>(_onCreateTransContract);
    on<UpdateTransContract>(_onUpdateTransContract);
    on<RemoveTransContract>(_onRemoveTransContract);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<TransactionContractModel> transPayment = [];

  Future<void> _onInitialTransContract(
      InitialTransContract event, Emitter<TransContractState> emit) async {
    emit(TransContractLoading());
    try {
      transPayment.clear();
      transPayment = await getTransContract();
      emit(TransContractLoaded(transContract: transPayment));
    } catch (_) {
      emit(TransContractError());
    }
  }

  Future<void> _onCreateTransContract(
      CreateTransContract event, Emitter<TransContractState> emit) async {
    final state = this.state;
    if (state is TransContractLoaded) {
      emit(TransContractLoading());
      try {
        createTransContract(event.transContract);
        emit(TransContractLoaded(transContract: transPayment));
      } catch (e) {
        emit(TransContractError());
      }
    }
  }

  Future<void> _onUpdateTransContract(
      UpdateTransContract event, Emitter<TransContractState> emit) async {
    final state = this.state;
    if (state is TransContractLoaded) {
      emit(TransContractLoading());
      try {
        updateTransContract(event.id);
        emit(TransContractLoaded(transContract: transPayment));
      } catch (e) {
        emit(TransContractError());
      }
    }
  }

  Future<void> _onRemoveTransContract(
      RemoveTransContract event, Emitter<TransContractState> emit) async {
    final state = this.state;
    if (state is TransContractLoaded) {
      emit(TransContractLoading());
      try {
        removeTransContract(event.transContract);
        emit(
          TransContractLoaded(transContract: transPayment),
        );
      } catch (_) {
        emit(TransContractError());
      }
    }
  }

  Future<List<TransactionContractModel>> getTransContract() async {
    final List<TransactionContractModel> transContract = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getTransContract),
            variables: <String, dynamic>{
              'email_lender': firebaseUser.email,
            }))
        .then((value) {
      if (value.data!['TransactionContract'].length > 0) {
        for (Map<String, dynamic> contract
            in value.data!['TransactionContract']) {
          transContract.add(TransactionContractModel.fromJson(contract));
        }
      }
    });
    return transContract;
  }

  Future<TransactionContractModel?> createTransContract(
      TransactionContractModel transContract) async {
    TransactionContractModel? contract;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.insertTranContract()),
            variables: <String, dynamic>{
              'contract_id': transContract.contractId,
              'money_paid': transContract.moneyPaid,
              'note': transContract.note,
              'pay_date': transContract.payDate.toIso8601String(),
              'status': handleStatusTransContract(transContract.status),
            }))
        .then((value) {
      if (value.data!.isNotEmpty &&
          value.data!['insert_TransactionContract_one'].isNotEmpty) {
        contract = TransactionContractModel.fromJson(
            value.data!['insert_TransactionContract_one']);
      }
    });
    return contract;
  }

  Future<void> updateTransContract(int id) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateTransContract()),
            variables: <String, dynamic>{
              'id': id,
              'status': handleStatusContract(StatusContract.DONE),
            }));
  }

  Future<void> removeTransContract(
      TransactionContractModel transContract) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.removeTransContract()),
            variables: <String, dynamic>{
              'id': transContract.id,
            }));
  }
}
