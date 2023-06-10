import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/contract_model.dart';
import 'package:monsey/common/widget/bottom_button.dart';
import 'package:monsey/common/widget/unfocus_click.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/feature/onboarding/bloc/user/user_bloc.dart';
import 'package:monsey/feature/transaction/widget/transaction_widget.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/model/user_model.dart';
import '../../../common/route/routes.dart';
import '../../../common/util/helper.dart';
import '../bloc/contracts/bloc_contracts.dart';
import 'detail_tran_contract.dart';

class DetailContract extends StatefulWidget {
  const DetailContract({Key? key, this.contractModel, this.status})
      : super(key: key);
  final ContractModel? contractModel;
  final StatusContract? status;
  @override
  State<DetailContract> createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  ContractModel? _contractModel;
  UserModel? borrowerModel;
  bool isBorrower = true;

  late WalletsBloc walletsBloc;
  late ContractsBloc contractsBloc;
  late UserBloc userBloc;

  String convertString(String suggest) {
    return formatMoney(context).format(!suggest.contains('.')
        ? (int.tryParse(suggest.replaceAll(',', '')) ?? 0)
        : (double.tryParse(suggest.replaceAll(',', '')) ?? 0));
  }

  Widget container({required Widget child, double? marginVer}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: marginVer ?? 16, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    isBorrower = widget.contractModel != null;
    _contractModel = widget.contractModel;
  }

  @override
  void didChangeDependencies() {
    walletsBloc = BlocProvider.of<WalletsBloc>(context);
    contractsBloc = BlocProvider.of<ContractsBloc>(context);
    userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusClick(
      child: Scaffold(
        appBar: AppWidget.createSimpleAppBar(
            context: context, title: LocaleKeys.contractDetails.tr()),
        bottomNavigationBar: BottomButton(
            child: _contractModel!.status == StatusContract.BORROWING &&
                    _contractModel!.emailLender != firebaseUser.email
                ? AppWidget.typeButtonStartAction(
                    context: context,
                    input: LocaleKeys.createTransaction.tr(),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.detailTranContract,
                          arguments: DetailTranContract(
                              contractModel: _contractModel!));
                    },
                    bgColor: emerald,
                    textColor: white)
                : const SizedBox()),
        body: ListView(
          children: [
            container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.lender.tr()}',
                        style: headline(context: context),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                          !isBorrower
                              ? userBloc.userModel!.email
                              : _contractModel!.lender!.email,
                          style: body(context: context)),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    decoration: const BoxDecoration(color: grey6),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.borrower.tr()}',
                        style: headline(context: context),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                          isBorrower
                              ? _contractModel!.emailBorrower
                              : borrowerModel!.email,
                          style: body(context: context)),
                    ],
                  ),
                ])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                LocaleKeys.information.tr().toUpperCase(),
                style: title4(context: context, fontWeight: '700'),
              ),
            ),
            container(
                marginVer: 8,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.nameContract.tr(),
                            style: callout(context: context, fontWeight: '700'),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            _contractModel!.nameContract,
                            style: callout(context: context),
                          ),
                        ],
                      ),
                      AppWidget.divider(context, vertical: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.money.tr(),
                            style: callout(context: context, fontWeight: '700'),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(convertString(_contractModel!.money.toString()),
                              style: callout(context: context)),
                        ],
                      ),
                      AppWidget.divider(context, vertical: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${LocaleKeys.profit.tr()} (%/${LocaleKeys.year.tr()})',
                            style: callout(context: context, fontWeight: '700'),
                          ),
                          const Expanded(child: SizedBox()),
                          Text('${_contractModel!.interestRate}%',
                              style: callout(context: context)),
                        ],
                      ),
                      AppWidget.divider(context, vertical: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.moneyHaveToPay.tr(),
                            style: callout(context: context, fontWeight: '700'),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                              convertString(
                                  _contractModel!.realMoneyToPay.toString()),
                              style: callout(context: context)),
                        ],
                      ),
                    ])),
            _contractModel!.transactions!.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                        '${LocaleKeys.transactionFinish.tr().toUpperCase()}',
                        style: title4(context: context, fontWeight: '700')),
                  )
                : const SizedBox(),
            _contractModel!.transactions!.isNotEmpty
                ? container(
                    marginVer: 0,
                    child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return listTile(
                              context, _contractModel!.transactions![index]);
                        },
                        separatorBuilder: (context, index) {
                          return Container(
                            width: double.infinity,
                            height: 1,
                            decoration: const BoxDecoration(color: grey6),
                          );
                        },
                        itemCount: _contractModel!.transactions!.length))
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
