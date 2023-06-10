
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/bloc/categories/bloc_categories.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/graphql/queries.dart';
import 'package:monsey/common/model/user_model.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/feature/contract/bloc/trans_contract.dart/bloc_trans_contract.dart';
import 'package:monsey/feature/goal/bloc/goal/goal_bloc.dart';
import 'package:monsey/feature/goal/bloc/goal/goal_event.dart';
import 'package:monsey/feature/goal/screen/main_saving.dart';
import 'package:monsey/feature/home/bloc/chart/chart_bloc.dart';
import 'package:monsey/feature/home/bloc/chart/chart_event.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/bloc/type_wallet/bloc_type_wallet.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/subscription.dart';
import '../../contract/bloc/contracts/bloc_contracts.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../../profile/screen/profile.dart';
import '../widget/home_widget.dart';
import 'dashboard.dart';
import 'statictis.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.index = 0}) : super(key: key);
  final int index;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<Widget> listWidget = [];
  int _currentIndex = 0;

  Future<void> listenWallets() async {
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .subscribe(SubscriptionOptions(
            document: gql(Subscription.listenWallets),
            variables: <String, dynamic>{'user_uuid': firebaseUser.uid}))
        .listen((event) {
      if (event.data != null) {
        if (mounted) {
          context.read<WalletsBloc>().add(InitialWallets());
          context.read<ChartBloc>().add(const InitialChart(walletId: 0));
        }
      }
    });
  }

  Future<void> listenGoals() async {
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .subscribe(SubscriptionOptions(
            document: gql(Subscription.listenGoals),
            variables: <String, dynamic>{'user_uuid': firebaseUser.uid}))
        .listen((event) {
      if (event.data != null) {
        if (mounted) {
          context.read<GoalBloc>().add(InitialGoal());
        }
      }
    });
  }

  Future<void> listenContracts() async {
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .subscribe(SubscriptionOptions(
            document: gql(Subscription.listenContract),
            variables: <String, dynamic>{
              'email': firebaseUser.email,
            }))
        .listen((event) {
      if (event.data != null) {
        if (mounted) {
          context.read<ContractsBloc>().add(InitialContracts());
        }
      }
    });
  }

  Future<void> listenTransContracts() async {
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .subscribe(SubscriptionOptions(
            document: gql(Subscription.listenTransContract),
            variables: <String, dynamic>{
              'email_lender': firebaseUser.email,
            }))
        .listen((event) {
      if (event.data != null) {
        if (mounted) {
          context.read<TransContractBloc>().add(InitialTransContract());
        }
      }
    });
  }

  Future<UserModel?> getUserInfo() async {
    UserModel? userModel;
    final String token = await firebaseUser.getIdToken();
    Config.initializeClient(token)
        .value
        .query(QueryOptions(
            document: gql(Queries.getUser),
            variables: <String, dynamic>{'uuid': firebaseUser.uid}))
        .then((value) {
      if (value.data != null && value.data!['User'].length > 0) {
        userModel = UserModel.fromJson(value.data!['User'][0]);
        context.read<UserBloc>().add(GetUser(userModel!, context));
      }
    });
    return userModel;
  }

  @override
  void initState() {
    _currentIndex = widget.index;
    getUserInfo();
    listenContracts();
    listenTransContracts();
    listenGoals();
    listenWallets().whenComplete(() async {
      await createNotification(
          walletModel: context.read<WalletsBloc>().walletsTotal.isNotEmpty
              ? context.read<WalletsBloc>().walletsTotal[0]
              : null);
      await requestPermissions();
    });
    context.read<CategoriesBloc>().add(InitialCategories());
    context.read<TypesWalletBloc>().add(InitialTypesWallet());
    listWidget = [
      const Dashboard(),
      const MainSaving(),
      const Statictis(),
      const Profile(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listWidget.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            if (_currentIndex == 1) {
              context
                  .read<ChartBloc>()
                  .add(ChangeTimeChart(walletId: 0, dateTime: now));
            }
          });
        },
        items: [
          createItemNav(
              context, icHome, icHomeActive, LocaleKeys.dashboard.tr()),
          createItemNav(
              context, crosshairs, crosshairsActive, LocaleKeys.goal.tr()),
          createItemNav(context, icChart, icChartActive, LocaleKeys.chart.tr()),
          createItemNav(
              context, icAccount, icAccountActive, LocaleKeys.account.tr()),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:
  //     UpgradeAlert(
  //         upgrader: Upgrader(
  //             messages: UpgraderMessages(
  //                 code: context.read<UserBloc>().userModel != null
  //                     ? context.read<UserBloc>().userModel!.language
  //                     : 'en'),
  //             shouldPopScope: () => true,
  //             dialogStyle: Platform.isIOS || Platform.isMacOS
  //                 ? UpgradeDialogStyle.cupertino
  //                 : UpgradeDialogStyle.material),
  //         child: listWidget.elementAt(_currentIndex)),
  //     bottomNavigationBar: BottomNavigationBar(
  //       currentIndex: _currentIndex,
  //       showSelectedLabels: false,
  //       showUnselectedLabels: false,
  //       type: BottomNavigationBarType.fixed,
  //       elevation: 0,
  //       onTap: (value) {
  //         setState(() {
  //           _currentIndex = value;
  //           if (_currentIndex == 1) {
  //             context
  //                 .read<ChartBloc>()
  //                 .add(ChangeTimeChart(walletId: 0, dateTime: now));
  //           }
  //         });
  //       },
  //       items: [
  //         createItemNav(
  //             context, icHome, icHomeActive, LocaleKeys.dashboard.tr()),
  //         createItemNav(
  //             context, crosshairs, crosshairsActive, LocaleKeys.goal.tr()),
  //         createItemNav(context, icChart, icChartActive, LocaleKeys.chart.tr()),
  //         createItemNav(
  //             context, icAccount, icAccountActive, LocaleKeys.account.tr()),
  //       ],
  //     ),
  //   );
  // }
}
