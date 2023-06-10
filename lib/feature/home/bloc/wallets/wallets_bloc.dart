import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import '../../../../common/graphql/config.dart';
import '../../../../common/graphql/mutations.dart';
import '../../../../common/graphql/queries.dart';
import '../../../../common/model/wallet_model.dart';
import '../chart/bloc_chart.dart';
import 'wallets_event.dart';
import 'wallets_state.dart';

class WalletsBloc extends Bloc<WalletsEvent, WalletsState> {
  WalletsBloc() : super(WalletsLoading()) {
    on<InitialWallets>(_onInitialWallets);
    on<CreateWallet>(_onCreateWallet);
    on<EditWallet>(_onEditWallet);
    on<RemoveWallet>(_onRemoveWallet);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;

  List<WalletModel> walletsTotal = [];
  late WalletModel walletLend;

  Future<void> _onInitialWallets(
      InitialWallets event, Emitter<WalletsState> emit) async {
    emit(WalletsLoading());
    try {
      walletsTotal.clear();
      walletsTotal = await getWallets();
      double tmpTotal = 0;
      if (walletsTotal.isNotEmpty) {
        for (WalletModel wallet in walletsTotal) {
          if (wallet.isLoanWallet) {
            walletLend = wallet;
          }
          tmpTotal = tmpTotal + wallet.incomeBalance - wallet.expenseBalance;
        }
      }
      emit(WalletsLoaded(
          wallets: walletsTotal, totalBalanceAllWallets: tmpTotal));
    } catch (_) {
      emit(WalletsError());
    }
  }

  Future<void> _onCreateWallet(
      CreateWallet event, Emitter<WalletsState> emit) async {
    final state = this.state;
    if (state is WalletsLoaded) {
      emit(WalletsLoading());
      try {
        final WalletModel? newWallet =
            await createWallet(event.wallet, event.context);
        if (newWallet != null) {
          double tmpTotal = 0;
          tmpTotal = state.totalBalanceAllWallets +
              event.wallet.incomeBalance -
              event.wallet.expenseBalance;
          walletsTotal.add(newWallet);
          emit(WalletsLoaded(
              wallets: walletsTotal, totalBalanceAllWallets: tmpTotal));
        }
      } catch (_) {
        emit(WalletsError());
      }
    }
  }

  Future<void> _onEditWallet(
      EditWallet event, Emitter<WalletsState> emit) async {
    final state = this.state;
    if (state is WalletsLoaded) {
      emit(WalletsLoading());
      try {
        final List<WalletModel> wallets = state.wallets;
        editWallet(event.wallet);
        final WalletModel oldWallet =
            wallets.firstWhere((element) => element.id == event.wallet.id);
        wallets.remove(oldWallet);
        final WalletModel newWallet = WalletModel(
            id: oldWallet.id,
            typeWalletModel: event.wallet.typeWalletModel,
            name: event.wallet.name,
            incomeBalance: oldWallet.incomeBalance,
            expenseBalance: oldWallet.expenseBalance,
            typeWalletId: event.wallet.typeWalletId,
            userUuid: oldWallet.userUuid);
        wallets.add(newWallet);
        emit(
          WalletsLoaded(
              wallets: wallets,
              totalBalanceAllWallets: state.totalBalanceAllWallets),
        );
      } catch (_) {
        emit(WalletsError());
      }
    }
  }

  Future<void> _onRemoveWallet(
      RemoveWallet event, Emitter<WalletsState> emit) async {
    final state = this.state;
    if (state is WalletsLoaded) {
      try {
        removeWallet(event.wallet);
        double tmpTotal = state.totalBalanceAllWallets;
        tmpTotal =
            tmpTotal - event.wallet.incomeBalance + event.wallet.expenseBalance;
        event.context
            .read<ChartBloc>()
            .transactions
            .removeWhere((element) => element.walletId == event.wallet.id);
        walletsTotal.remove(event.wallet);
        emit(
          WalletsLoaded(
              wallets: walletsTotal, totalBalanceAllWallets: tmpTotal),
        );
      } catch (_) {
        emit(WalletsError());
      }
    }
  }

  Future<List<WalletModel>> getWallets() async {
    final List<WalletModel> wallets = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getWallets),
            variables: <String, dynamic>{'user_uuid': firebaseUser.uid}))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Wallet'].length > 0) {
        for (Map<String, dynamic> wallet in value.data!['Wallet']) {
          wallets.add(WalletModel.fromJson(wallet));
        }
      }
    });
    return wallets;
  }

  Future<WalletModel?> createWallet(
      WalletModel walletModel, BuildContext context) async {
    WalletModel? wallet;
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.createWallet()),
            variables: <String, dynamic>{
              'name': walletModel.name,
              'type_wallet_id': walletModel.typeWalletId,
              'income_balance': walletModel.incomeBalance,
              'expense_balance': walletModel.expenseBalance,
              'user_uuid': walletModel.userUuid,
            }))
        .then((value) {
      if (value.data!.isNotEmpty &&
          value.data!['insert_Wallet_one'].isNotEmpty) {
        wallet = WalletModel.fromJson(value.data!['insert_Wallet_one']);
      }
    });
    return wallet;
  }

  Future<void> editWallet(WalletModel walletModel) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateWallet()),
            variables: <String, dynamic>{
              'id': walletModel.id,
              'name': walletModel.name,
              'type_wallet_id': walletModel.typeWalletId,
            }));
  }

  Future<void> removeWallet(WalletModel walletModel) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.removeWallet()),
            variables: <String, dynamic>{
              'id': walletModel.id,
            }));
  }
}
