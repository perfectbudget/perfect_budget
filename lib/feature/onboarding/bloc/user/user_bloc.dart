import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/graphql/mutations.dart';
import 'package:monsey/common/model/user_model.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../../common/graphql/config.dart';
import 'bloc_user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoading()) {
    on<GetUser>(_onGetUser);
    on<UpdateCurrencyUser>(_onUpdateCurrencyUser);
    on<UpdatePremiumUser>(_onUpdatePremiumUser);
    on<UpdateLanguageUser>(_onUpdateLanguageUser);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;

  UserModel? userModel;

  Future<void> _onGetUser(GetUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      userModel = event.userModel;
      if (userModel != null) {
        locale = userModel!.language;
        event.context.setLocale(Locale(userModel!.language));
        emit(UserLoaded(user: userModel!));
      }
    } catch (_) {
      emit(UserError());
    }
  }

  Future<void> _onUpdateCurrencyUser(
      UpdateCurrencyUser event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      emit(UserLoading());
      try {
        updateUserInfo(event.currencyCode, event.currencySymbol);
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            datePremium: userModel!.datePremium,
            avatar: userModel!.avatar,
            language: userModel!.language,
            currencyCode: event.currencyCode,
            currencySymbol: event.currencySymbol);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdatePremiumUser(
      UpdatePremiumUser event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      emit(UserLoading());
      try {
        updatePremiumUser();
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            avatar: userModel!.avatar,
            datePremium: now,
            language: userModel!.language,
            currencyCode: userModel!.currencyCode,
            currencySymbol: userModel!.currencySymbol);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateLanguageUser(
      UpdateLanguageUser event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      emit(UserLoading());
      try {
        updateLanguageUser(event.language);
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            avatar: userModel!.avatar,
            datePremium: userModel!.datePremium,
            language: event.language,
            currencyCode: userModel!.currencyCode,
            currencySymbol: userModel!.currencySymbol);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> updateUserInfo(
      String currencyCode, String currencySymbol) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateCurencyUser()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'currency_code': currencyCode,
              'currency_symbol': currencySymbol
            }));
  }

  Future<void> updatePremiumUser() async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updatePremiumUser()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'date_premium': now.toIso8601String(),
            }));
  }

  Future<void> updateLanguageUser(String language) async {
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token).value.mutate(MutationOptions(
            document: gql(Mutations.updateLanguageUser()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'language': language,
            }));
  }
}
