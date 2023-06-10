import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/util/listview_currency.dart';

class CurrencyCustom extends StatefulWidget {
  const CurrencyCustom({Key? key}) : super(key: key);

  @override
  State<CurrencyCustom> createState() => _CurrencyCustomState();
}

class _CurrencyCustomState extends State<CurrencyCustom> {
  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      backgroundColor: white,
      appBar: AppWidget.createSimpleAppBar(
        context: context,
        title: LocaleKeys.currency.tr(),
        hasLeading: true,
      ),
      body: SizedBox(
        height: height,
        child: CurrencyListView(
          showCurrencyName: true,
          showCurrencyCode: true,
          favorite: const ['ARS', 'GBP', 'JPY', 'USD', 'INR', 'VND', 'CNY'],
          onSelect: (Currency currency) {
            Navigator.of(context).pop(currency);
          },
        ),
      ),
    );
  }
}
