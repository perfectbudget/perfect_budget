import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/bloc/type_wallet/bloc_type_wallet.dart';
import 'package:monsey/common/constant/dark_mode.dart';
import 'package:monsey/common/route/route_generator.dart';
import 'package:monsey/feature/contract/bloc/trans_contract.dart/bloc_trans_contract.dart';
import 'package:monsey/feature/goal/bloc/goal/goal_bloc.dart';
import 'package:monsey/feature/goal/bloc/goal_detail.dart/bloc_goal_detail.dart';
import 'package:monsey/feature/home/bloc/chart/chart_bloc.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/feature/home/screen/home.dart';
import 'package:monsey/feature/onboarding/bloc/user/bloc_user.dart';
import 'package:monsey/feature/onboarding/screen/onboarding.dart';
import 'package:monsey/feature/transaction/bloc/transactions/bloc_transactions.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../common/bloc/categories/bloc_categories.dart';
import '../feature/contract/bloc/contracts/bloc_contracts.dart';
import '../feature/onboarding/bloc/slider/bloc_slider.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: 'Main Navigator');

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String?> getToken() async {
    print('Entre a Firebase');
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    print('Pase firebaseUser');
    if (firebaseUser == null) {
      return null;
    }
    print('Antes de getIdToken');
    final String? token = await firebaseUser.getIdToken();
    print('Después de idtoken');
    print(token);
    return token;
  }

  @override
  void initState() {
    print('Entre al initState');
    getToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<SliderBloc>(
          create: (BuildContext context) => SliderBloc(),
        ),
        BlocProvider<WalletsBloc>(
          create: (BuildContext context) => WalletsBloc(),
        ),
        BlocProvider<TransactionsBloc>(
          create: (BuildContext context) => TransactionsBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (BuildContext context) => UserBloc(),
        ),
        BlocProvider<CategoriesBloc>(
          create: (BuildContext context) => CategoriesBloc(),
        ),
        BlocProvider<TypesWalletBloc>(
          create: (BuildContext context) => TypesWalletBloc(),
        ),
        BlocProvider<ChartBloc>(
          create: (BuildContext context) => ChartBloc(),
        ),
        BlocProvider<ContractsBloc>(
          create: (BuildContext context) => ContractsBloc(),
        ),
        BlocProvider<TransContractBloc>(
          create: (BuildContext context) => TransContractBloc(),
        ),
        BlocProvider<GoalBloc>(
          create: (BuildContext context) => GoalBloc(),
        ),
        BlocProvider<GoalDetailBloc>(
          create: (BuildContext context) => GoalDetailBloc(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/',
        navigatorKey: navigatorKey,
        onGenerateRoute: RouteGenerator.generateRoute,
        title: 'Perfect Budget',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        // darkTheme: darkMode,
        // themeMode: themeMode,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: FutureBuilder<String?>(
            future: getToken(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return const Center(
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  );
                case ConnectionState.done:
                  if (snapshot.data != null) {
                    return const Home();
                  } else {
                    return const OnBoarding();
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
