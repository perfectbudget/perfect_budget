import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class TypesWalletState extends Equatable {
  const TypesWalletState();
}

class TypesWalletLoading extends TypesWalletState {
  @override
  List<Object> get props => [];
}

class TypesWalletLoaded extends TypesWalletState {
  const TypesWalletLoaded({
    this.typesWallet = const [],
  });

  final List<Map<String, dynamic>> typesWallet;

  @override
  List<Object> get props => [typesWallet];
}

class TypesWalletError extends TypesWalletState {
  @override
  List<Object> get props => [];
}
