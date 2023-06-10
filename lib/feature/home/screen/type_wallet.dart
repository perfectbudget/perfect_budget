import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/bloc/type_wallet/type_wallet_bloc.dart';
import 'package:monsey/common/bloc/type_wallet/type_wallet_state.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/widget/animation_click.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../translations/export_lang.dart';

class TypeWallet extends StatefulWidget {
  const TypeWallet({Key? key}) : super(key: key);

  @override
  State<TypeWallet> createState() => _TypeWalletState();
}

class _TypeWalletState extends State<TypeWallet> {
  List<Map<String, dynamic>> typeWallets = [];
  late TypesWalletBloc typesWalletBloc;

  Widget item(Map<String, dynamic> typeWallet) {
    return AnimationClick(
      function: () {
        setState(() {
          for (dynamic typeWallet in typeWallets) {
            typeWallet['selected'] = false;
          }
          typeWallet['selected'] = !typeWallet['selected'];
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(
                typeWallet['item'].icon,
                width: 24,
                height: 24,
                color: purplePlum,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  typeWallet['item'].name,
                  style: body(color: grey1),
                ),
              )
            ],
          ),
          Checkbox(
              activeColor: emerald,
              shape: const CircleBorder(),
              value: typeWallet['selected'],
              onChanged: (value) {
                setState(() {
                  for (dynamic typeWallet in typeWallets) {
                    typeWallet['selected'] = false;
                  }
                  typeWallet['selected'] = value;
                });
              })
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    typesWalletBloc = BlocProvider.of<TypesWalletBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.walletType.tr(),
          onBack: () {
            for (Map<String, dynamic> typeWallet in typeWallets) {
              if (typeWallet['selected']) {
                Navigator.of(context).pop(typeWallet['item']);
              }
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: () {
              for (Map<String, dynamic> typeWallet in typeWallets) {
                if (typeWallet['selected']) {
                  Navigator.of(context).pop(typeWallet['item']);
                }
              }
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        children: [
          BlocBuilder<TypesWalletBloc, TypesWalletState>(
            builder: (context, state) {
              if (state is TypesWalletLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (state is TypesWalletLoaded) {
                typeWallets = state.typesWallet;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.typesWallet.length,
                    itemBuilder: (context, index) {
                      return item(state.typesWallet[index]);
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
