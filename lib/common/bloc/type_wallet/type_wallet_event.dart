import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class TypesWalletEvent extends Equatable {
  const TypesWalletEvent();
}

class InitialTypesWallet extends TypesWalletEvent {
  @override
  List<Object> get props => [];
}
