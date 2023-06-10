import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/wallet_model.dart';

@immutable
abstract class WalletsState extends Equatable {
  const WalletsState();
}

class WalletsLoading extends WalletsState {
  @override
  List<Object> get props => [];
}

class WalletsLoaded extends WalletsState {
  const WalletsLoaded(
      {this.wallets = const <WalletModel>[], this.totalBalanceAllWallets = 0});

  final List<WalletModel> wallets;
  final double totalBalanceAllWallets;

  @override
  List<Object> get props => [wallets, totalBalanceAllWallets];
}

class WalletsError extends WalletsState {
  @override
  List<Object> get props => [];
}
