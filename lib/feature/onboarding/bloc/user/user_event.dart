import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:monsey/common/model/user_model.dart';

@immutable
abstract class UserEvent extends Equatable {
  const UserEvent();
}

class GetUser extends UserEvent {
  const GetUser(this.userModel, this.context);
  final BuildContext context;
  final UserModel userModel;

  @override
  List<Object> get props => [userModel, context];
}

class UpdateCurrencyUser extends UserEvent {
  const UpdateCurrencyUser(this.currencyCode, this.currencySymbol);

  final String currencyCode;
  final String currencySymbol;

  @override
  List<Object> get props => [currencyCode, currencySymbol];
}

class UpdatePremiumUser extends UserEvent {
  @override
  List<Object> get props => [];
}

class UpdateLanguageUser extends UserEvent {
  const UpdateLanguageUser(this.language);

  final String language;

  @override
  List<Object> get props => [language];
}
