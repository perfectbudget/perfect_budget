import 'dart:async';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monsey/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'common/constant/env.dart';
import 'translations/codegen_loader.g.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

bool isInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  final ByteData data =
      await PlatformAssetBundle().load('assets/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  tz.initializeTimeZones();
  final Map? configuration =
      await AppLovinMAX.initialize(AdHelper().keySdkApplovin);

  if (configuration != null) {
    isInitialized = false;
  }
  await EasyLocalization.ensureInitialized();
  if (Platform.isIOS || Platform.isMacOS) {
    await Firebase.initializeApp();
  } else {
    // await Firebase.initializeApp(
    //     options: const FirebaseOptions(
    //         apiKey: 'AIzaSyBmQ9M22gs8fqo_GaEIeZ-hDWV4FOF73tg',
    //         appId: '1:800228398325:android:7a109cd382e0796e0021bc',
    //         messagingSenderId: '800228398325',
    //         authDomain: 'perfect-budget-backend.vercel.app',
    //         projectId: 'perfectbudget-1ede1'));
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi'), Locale('ja')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      child: const MyApp()));
}
