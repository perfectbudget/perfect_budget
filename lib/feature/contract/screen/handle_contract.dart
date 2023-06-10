import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/constant/styles.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/enums.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/queries.dart';
import '../../../common/model/contract_model.dart';
import '../../../common/model/user_model.dart';
import '../../../common/util/form_validator.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/bottom_button.dart';
import '../../../common/widget/textfield.dart';
import '../../../translations/export_lang.dart';
import '../../home/bloc/wallets/bloc_wallets.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/contracts/bloc_contracts.dart';

class HandleContract extends StatefulWidget {
  const HandleContract({Key? key, this.contractModel}) : super(key: key);
  final ContractModel? contractModel;
  @override
  State<HandleContract> createState() => _HandleContractState();
}

class _HandleContractState extends State<HandleContract> {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  ContractModel? _contractModel;
  UserModel? borrowerModel;
  TextEditingController emailCtl = TextEditingController();
  FocusNode emailFn = FocusNode();
  TextEditingController nameContractCtl = TextEditingController();
  FocusNode nameContractFn = FocusNode();
  TextEditingController moneyCtl = TextEditingController();
  FocusNode moneyFn = FocusNode();
  TextEditingController interestCtl = TextEditingController();
  FocusNode interestFn = FocusNode();
  TextEditingController realMoneyCtl = TextEditingController();
  FocusNode realMoneyFn = FocusNode();
  bool isSendMail = false;
  bool isSendNotify = false;
  bool isPolicy = false;
  bool isBorrower = false;
  late WalletsBloc walletsBloc;
  late ContractsBloc contractsBloc;
  late UserBloc userBloc;

  Future<void> getBorrowerInfo() async {
    if (FormValidator.validateEmail(emailCtl.text)) {
      final String token = await firebaseUser.getIdToken();
      Config.initializeClient(token)
          .value
          .query(QueryOptions(
              document: gql(Queries.getUserByEmail),
              variables: <String, dynamic>{'email': emailCtl.text}))
          .then((value) {
        setState(() {
          if (value.data!.isNotEmpty && value.data!['User'].length > 0) {
            borrowerModel = UserModel.fromJson(value.data!['User'][0]);
          } else {
            borrowerModel = null;
          }
        });
      });
    }
  }

  Widget checkbox(String text, {required bool check}) {
    return Row(
      children: [
        Checkbox(
          activeColor: emerald,
          value: check,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          onChanged: (bool? value) {
            setState(() {
              check = !check;
            });
          },
        ),
        Text(
          text,
          style: body(context: context),
        )
      ],
    );
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

  void handleRealMoney() {
    setState(() {
      if (FormValidator.isNumeric(s: interestCtl.text) &&
          FormValidator.isNumeric(s: moneyCtl.text)) {
        realMoneyCtl.text = (int.tryParse(moneyCtl.text)! +
                int.tryParse(moneyCtl.text)! *
                    double.tryParse(interestCtl.text)! /
                    100)
            .toStringAsFixed(0);
      } else {
        realMoneyCtl.clear();
      }
    });
  }

  Future<void> createContract() async {
    final int money = int.tryParse(moneyCtl.text) ?? 0;
    final double interestRate = double.tryParse(interestCtl.text) ?? 0;
    contractsBloc.add(CreateContract(
        context,
        ContractModel(
            avtBorrower:
                borrowerModel != null ? borrowerModel!.avatar : defaultAvatar,
            avtLender: userBloc.userModel!.avatar,
            nameContract: nameContractCtl.text,
            emailLender: firebaseUser.email!,
            emailBorrower: borrowerModel != null
                ? borrowerModel!.email
                : emailCtl.text.trim(),
            interestRate: interestRate,
            isSendMail: isSendMail,
            isSendNotify: isSendNotify,
            money: money,
            realMoneyToPay: (money + money * interestRate / 100).toInt(),
            status: StatusContract.WAITING,
            transactions: const [])));
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    isBorrower = widget.contractModel != null;
    if (isBorrower) {
      _contractModel = widget.contractModel;
      moneyCtl = TextEditingController(text: _contractModel!.money.toString());
      nameContractCtl =
          TextEditingController(text: _contractModel!.nameContract);
      interestCtl = TextEditingController(
          text: _contractModel!.interestRate.toStringAsFixed(1));
      realMoneyCtl = TextEditingController(
          text: _contractModel!.realMoneyToPay.toStringAsFixed(0));
      isSendMail = _contractModel!.isSendMail;
      isSendNotify = _contractModel!.isSendNotify;
    } else {
      emailCtl.addListener(getBorrowerInfo);
      moneyCtl.addListener(handleRealMoney);
      interestCtl.addListener(handleRealMoney);
    }
    super.initState();
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
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
        context: context,
        title: isBorrower
            ? LocaleKeys.confirmContract.tr()
            : LocaleKeys.createContract.tr(),
        hasLeading: true,
      ),
      bottomNavigationBar: BottomButton(
        child: isBorrower
            ? Row(
                children: [
                  Expanded(
                    child: AppWidget.typeButtonStartAction(
                        context: context,
                        input: LocaleKeys.accept.tr(),
                        onPressed: () {
                          contractsBloc.add(UpdateContract(context,
                              _contractModel!.id!, StatusContract.BORROWING));
                          Navigator.of(context).pop();
                        },
                        bgColor: emerald,
                        textColor: white),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () {
                      contractsBloc
                          .add(RemoveContract(context, _contractModel!.id!));
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                        side: const BorderSide(color: purplePlum)),
                    child: Text(LocaleKeys.reject.tr(),
                        textAlign: TextAlign.center,
                        style: headline(color: purplePlum)),
                  ))
                ],
              )
            : AppWidget.typeButtonStartAction(
                context: context,
                input: LocaleKeys.send.tr(),
                onPressed: FormValidator.validateEmail(emailCtl.text) &&
                        FormValidator.isNumeric(s: interestCtl.text) &&
                        FormValidator.isNumeric(s: moneyCtl.text) &&
                        emailCtl.text.trim() != userBloc.userModel!.email
                    ? createContract
                    : () {},
                bgColor: emerald,
                textColor: white),
      ),
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
                      style: body(context: context, fontWeight: '700'),
                    ),
                    Expanded(
                      child: Text(
                        userBloc.userModel!.email,
                        textAlign: TextAlign.end,
                        style: callout(context: context, fontWeight: '600'),
                      ),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 1,
                  decoration: const BoxDecoration(color: grey6),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    LocaleKeys.borrower.tr(),
                    style: subhead(context: context),
                  ),
                ),
                TextFieldCpn(
                  readOnly: isBorrower,
                  controller: emailCtl,
                  focusNode: emailFn,
                  hintText: LocaleKeys.email.tr(),
                ),
                borrowerModel != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${LocaleKeys.borrower.tr()}',
                            style: body(context: context, fontWeight: '700'),
                          ),
                          Expanded(
                            child: Text(
                              borrowerModel!.email,
                              textAlign: TextAlign.end,
                              style:
                                  callout(context: context, fontWeight: '600'),
                            ),
                          )
                        ],
                      )
                    : const SizedBox(),
              ])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              LocaleKeys.information.tr().toUpperCase(),
              style: title4(context: context, fontWeight: '700'),
            ),
          ),
          container(
              marginVer: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.nameContract.tr(),
                    style: subhead(context: context),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFieldCpn(
                    readOnly: isBorrower,
                    controller: nameContractCtl,
                    focusNode: nameContractFn,
                    hintText: LocaleKeys.enter.tr(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    LocaleKeys.amount.tr(),
                    style: subhead(context: context),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFieldCpn(
                    readOnly: isBorrower,
                    controller: moneyCtl,
                    focusNode: moneyFn,
                    hintText: '100,000',
                    showSuffixIcon: true,
                    suffixWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        userBloc.userModel!.currencyCode!,
                        style: subhead(context: context),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    '${LocaleKeys.profit.tr()} (%/${LocaleKeys.year.tr()})',
                    style: subhead(context: context),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFieldCpn(
                    readOnly: isBorrower,
                    controller: interestCtl,
                    focusNode: interestFn,
                    hintText: '10',
                    showSuffixIcon: true,
                    suffixWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '%',
                        style: subhead(context: context),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    LocaleKeys.moneyHaveToPay.tr(),
                    style: subhead(context: context),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFieldCpn(
                    readOnly: true,
                    controller: realMoneyCtl,
                    focusNode: realMoneyFn,
                    hintText: '110,000',
                    showSuffixIcon: true,
                    suffixWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        userBloc.userModel!.currencyCode!,
                        style: subhead(context: context),
                      ),
                    ),
                  )
                ],
              )),
          Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: emerald,
                    value: isSendNotify,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    onChanged: isBorrower
                        ? null
                        : (bool? value) {
                            setState(() {
                              isSendNotify = !isSendNotify;
                            });
                          },
                  ),
                  Expanded(
                    child: Text(
                      LocaleKeys.reminderNotification.tr(),
                      style: body(context: context),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    activeColor: emerald,
                    value: isSendMail,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    onChanged: isBorrower
                        ? null
                        : (bool? value) {
                            setState(() {
                              isSendMail = !isSendMail;
                            });
                          },
                  ),
                  Expanded(
                    child: Text(
                      LocaleKeys.reminderEmail.tr(),
                      style: body(context: context),
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    activeColor: emerald,
                    value: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    onChanged: (val) {},
                  ),
                  Expanded(
                    child: Text(
                      LocaleKeys.noLegal.tr(),
                      style: body(color: redCrayola),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
