import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/model/type_wallet_model.dart';

import '../../graphql/config.dart';
import '../../graphql/queries.dart';
import 'bloc_type_wallet.dart';

class TypesWalletBloc extends Bloc<TypesWalletEvent, TypesWalletState> {
  TypesWalletBloc() : super(TypesWalletLoading()) {
    on<InitialTypesWallet>(_onInitialTypesWallet);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<TypeWalletModel> resultTypes = [];
  Future<void> _onInitialTypesWallet(
      InitialTypesWallet event, Emitter<TypesWalletState> emit) async {
    try {
      resultTypes = await getTypesWallet();
      final List<Map<String, dynamic>> typesWallet = List.generate(
          resultTypes.length,
          (index) => <String, dynamic>{
                'item': resultTypes[index],
                'selected': index == 0 ? true : false
              });
      emit(TypesWalletLoaded(typesWallet: typesWallet));
    } catch (_) {
      emit(TypesWalletError());
    }
  }

  Future<List<TypeWalletModel>> getTypesWallet() async {
    final List<TypeWalletModel> typesWallet = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(document: gql(Queries.getTypeWallet)))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['TypeWallet'].length > 0) {
        for (Map<String, dynamic> type in value.data!['TypeWallet']) {
          typesWallet.add(TypeWalletModel.fromJson(type));
        }
      }
    });
    return typesWallet;
  }
}
